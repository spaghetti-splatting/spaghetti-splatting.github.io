// 3DGS renderer of the viewer (header.json "kind": "3dgs", tools/export_3dgs.py):
// the forward pass of the authors' tile rasterizer (gpu2/shaders/gs3d.wgsl).
// It has the interface of ViewerRenderer (model.js) that main.js, the picker
// and the shot tool use: loadModel, encodeFrame, size.outColor ([3, H, W]
// float32), cameraBuffer (Camera of common.wgsl), ctx.counts, releaseModel.
// The scan, the radix sort, args_after_scan and tile_ranges are those of the
// curve renderer (gpu2/viewer.js, frame.wgsl).

import {GpuContext, GpuScan, GpuSort, SLOT, PAIR_CAPACITY, gridOf, higherMsb, loadModule} from './gpu2/viewer.js';
import {fetchBytes} from './model.js';

const STORAGE = GPUBufferUsage.STORAGE;
const COPY_SRC = GPUBufferUsage.COPY_SRC;
const COPY_DST = GPUBufferUsage.COPY_DST;
const BUFFER_ALL = STORAGE | COPY_DST | COPY_SRC;
const CAMERA_BYTES = 224;
const SAMPLE = 60000;

const buf = (device, size, usage, label) => device.createBuffer({label, size: Math.max(16, Math.ceil(size / 16) * 16), usage});

function uniform(device, words, label) {
  const b = device.createBuffer({label, size: 16, usage: GPUBufferUsage.UNIFORM | COPY_DST});
  const d = new Uint32Array(4); d.set(words);
  device.queue.writeBuffer(b, 0, d);
  return b;
}

function group(device, pipeline, entries, label) {
  return device.createBindGroup({label, layout: pipeline.getBindGroupLayout(0),
    entries: Object.entries(entries).map(([k, b]) => ({binding: Number(k), resource: {buffer: b}}))});
}

export const isGs3d = (header) => header && header.kind === '3dgs';

const GS_FILES = [['geo', 'gs_geo.f32', 48], ['sh', 'gs_sh.f16', 96], ['endpoints', 'endpoints.f32', 24], ['amplitude', 'amplitude.f32', 4]];

export class Gs3dRenderer {
  constructor(device, timestamps) {
    this.device = device;
    this.timestamps = timestamps;
    this.model = null;
    this.size = null;
    this.sorts = new Map();
    this.pairs = null;   // may be shared with the curve renderer (main.js)
  }

  async init() {
    const d = this.device;
    this.ctx = await new GpuContext(d).init();
    const gs = await loadModule(d, 'gs3d.wgsl');
    const fr = await loadModule(d, 'frame.wgsl');
    const make = (module, entryPoint) => d.createComputePipeline({label: entryPoint, layout: 'auto', compute: {module, entryPoint}});
    this.pPre = make(gs, 'gs_preprocess');
    this.pDup = make(gs, 'gs_duplicate');
    this.pRender = make(gs, 'gs_render');
    this.pArgs = make(fr, 'args_after_scan');
    this.pRanges = make(fr, 'tile_ranges');
    this.pairArgs = this.ctx.allocArgs(3);
    this.frameParams = uniform(d, [0, this.pairArgs, PAIR_CAPACITY, 0], 'gs frame params');
    this.cameraBuffer = d.createBuffer({label: 'gs camera', size: CAMERA_BYTES, usage: GPUBufferUsage.UNIFORM | COPY_DST});
    this.slotMark = this.ctx.mark();
    return this;
  }

  ensurePairs() {
    if (this.pairs) return;
    const p = (label) => buf(this.device, PAIR_CAPACITY * 4, STORAGE | COPY_SRC, label);
    this.pairs = {a: {hi: p('key hi a'), lo: p('key lo a'), value: p('value a')},
                  b: {hi: p('key hi b'), lo: p('key lo b'), value: p('value b')}};
  }

  async loadModel(name, progress, extraBytes = 0) {
    const d = this.device;
    const base = `${window.KC_DATA}${name}/`;
    const header = await (await fetch(base + 'header.json', {cache: 'no-store'})).json();
    const cameras = await (await fetch(base + 'cameras.json')).json();
    const rows = header.N;
    const model = {name, header, cameras, rows, buffers: {}};
    const total = GS_FILES.reduce((s, [, , w]) => s + w * rows, 0) + extraBytes;
    let loaded = 0;
    const mb = (b) => Math.round(b / 1048576);
    const report = () => progress(`loading ${name}: ${mb(loaded)} / ${mb(total)} MB (${mb(loaded)}/${Math.max(1, mb(total))})`);
    model.reportBytes = (b) => { loaded += b; report(); };
    report();
    for (const [key, file, width] of GS_FILES) {
      const data = await fetchBytes(base + file, width * rows, model.reportBytes);
      const b = buf(d, data.byteLength, BUFFER_ALL, file);
      d.queue.writeBuffer(b, 0, data);
      model.buffers[key] = b;
      if (key === 'geo') this.sampleGeometry(model, new Float32Array(data));
      if (key === 'amplitude') {
        const a = new Float32Array(data);
        const step = Math.max(1, Math.floor(a.length / 20000));
        const s = [];
        for (let i = 0; i < a.length; i += step) s.push(a[i]);
        model.amplitudeSample = s.sort((x, y) => x - y);
      }
    }
    this.install(model);
    return model;
  }

  // Bounds and a sample of the centres (Gaussians of opacity >= 0.3).
  sampleGeometry(model, geo) {
    const n = model.rows;
    const step = Math.max(1, Math.floor(n / SAMPLE));
    const mids = [];
    const lo = [Infinity, Infinity, Infinity], hi = [-Infinity, -Infinity, -Infinity];
    for (let i = 0; i < n; i += step) {
      const o = 12 * i;
      if (geo[o + 10] < 0.3) continue;
      const m = [geo[o], geo[o + 1], geo[o + 2]];
      mids.push(m);
      for (let c = 0; c < 3; c++) { lo[c] = Math.min(lo[c], m[c]); hi[c] = Math.max(hi[c], m[c]); }
    }
    model.mids = mids;
    model.bounds = {lo, hi, center: [0, 1, 2].map((c) => 0.5 * (lo[c] + hi[c]))};
  }

  install(model) {
    const d = this.device;
    this.ensurePairs();
    this.releaseModel();
    const n = model.rows;
    const f = {
      prims: buf(d, n * 48, BUFFER_ALL, 'gs prims'),
      rects: buf(d, n * 8, BUFFER_ALL, 'gs rects'),
      tiles: buf(d, n * 4, BUFFER_ALL, 'gs tiles'),
      offsets: buf(d, n * 4, BUFFER_ALL, 'gs offsets'),
    };
    model.frame = f;
    this.model = model;
    const ctx = this.ctx;
    const m = model.buffers;
    const cam = this.cameraBuffer;
    // The scan and args_after_scan read N from counts[SLOT.KEPT].
    this.tileScan = new GpuScan(ctx, {input: f.tiles, output: f.offsets, maxN: n, sourceSlot: SLOT.KEPT, exclusive: false, label: 'gs P5'});
    this.groups = {
      pre: group(d, this.pPre, {0: m.geo, 1: m.sh, 2: cam, 3: f.prims, 4: f.rects, 5: f.tiles}, 'gs pre'),
      args: group(d, this.pArgs, {0: ctx.counts, 1: ctx.args, 2: f.offsets, 3: this.frameParams}, 'gs args'),
      dup: group(d, this.pDup, {0: f.prims, 1: f.rects, 2: f.offsets, 3: f.tiles, 4: this.pairs.a.hi, 5: this.pairs.a.lo,
                                6: this.pairs.a.value, 7: cam}, 'gs dup'),
    };
    d.queue.writeBuffer(ctx.counts, 0, new Uint32Array([n, n]));   // SLOT.ROWS, SLOT.KEPT
  }

  releaseModel() {
    if (!this.model) return;
    for (const b of Object.values(this.model.buffers)) b.destroy();
    for (const b of Object.values(this.model.frame)) b.destroy();
    this.tileScan.destroy();
    for (const s of this.sorts.values()) s.destroy();
    this.sorts.clear();
    if (this.size) { this.size.outColor.destroy(); this.size.ranges.destroy(); this.size = null; }
    this.ctx.reset(this.slotMark);
    this.model = null;
  }

  setSize(width, height) {
    if (this.size && this.size.width === width && this.size.height === height) return;
    const d = this.device;
    if (this.size) { this.size.outColor.destroy(); this.size.ranges.destroy(); }
    const tilesX = Math.ceil(width / 16), tilesY = Math.ceil(height / 16);
    const tileBits = higherMsb(tilesX * tilesY);
    if (!this.sorts.has(tileBits)) {
      this.sorts.set(tileBits, new GpuSort(this.ctx, {capacity: PAIR_CAPACITY, a: this.pairs.a, b: this.pairs.b, tileBits,
                                                      argsIndex: this.pairArgs, label: 'gs P7'}));
    }
    const sort = this.sorts.get(tileBits);
    const sorted = sort.result();
    const outColor = buf(d, 3 * width * height * 4, BUFFER_ALL, 'gs image');
    const ranges = buf(d, 2 * tilesX * tilesY * 4, BUFFER_ALL, 'gs ranges');
    this.size = {width, height, tilesX, tilesY, sort, outColor, ranges,
      gRanges: group(d, this.pRanges, {0: sorted.hi, 1: this.ctx.counts, 2: ranges}, 'gs ranges'),
      gRender: group(d, this.pRender, {0: ranges, 1: sorted.value, 2: this.model.frame.prims, 3: outColor, 4: this.cameraBuffer}, 'gs render'),
    };
  }

  writeCamera(camera) {
    const data = new ArrayBuffer(CAMERA_BYTES);
    const f = new Float32Array(data);
    const u = new Uint32Array(data);
    f.set(camera.view, 0);
    f.set(camera.proj, 16);
    f.set(camera.campos, 32);
    f.set(this.model.header.background || [0, 0, 0], 36);
    u[40] = camera.width;
    u[41] = camera.height;
    u[42] = Math.ceil(camera.width / 16);
    u[43] = Math.ceil(camera.height / 16);
    f[44] = Math.tan(camera.fovx * 0.5);
    f[45] = Math.tan(camera.fovy * 0.5);
    u[52] = this.model.rows;
    u[53] = PAIR_CAPACITY;
    this.device.queue.writeBuffer(this.cameraBuffer, 0, data);
  }

  encodeFrame(encoder, camera) {
    this.setSize(camera.width, camera.height);
    this.writeCamera(camera);
    const size = this.size;
    const args = this.ctx.args;
    encoder.clearBuffer(size.ranges);
    const pass = encoder.beginComputePass({label: 'gs frame'});
    const grid = gridOf(Math.ceil(this.model.rows / 256));
    pass.setPipeline(this.pPre);
    pass.setBindGroup(0, this.groups.pre);
    pass.dispatchWorkgroups(...grid);
    this.tileScan.encode(pass);
    pass.setPipeline(this.pArgs);
    pass.setBindGroup(0, this.groups.args);
    pass.dispatchWorkgroups(1);
    pass.setPipeline(this.pDup);
    pass.setBindGroup(0, this.groups.dup);
    pass.dispatchWorkgroups(...grid);
    size.sort.encode(pass);
    pass.setPipeline(this.pRanges);
    pass.setBindGroup(0, size.gRanges);
    pass.dispatchWorkgroupsIndirect(args, this.pairArgs * 4);
    pass.setPipeline(this.pRender);
    pass.setBindGroup(0, size.gRender);
    pass.dispatchWorkgroups(size.tilesX, size.tilesY, 1);
    pass.end();
  }
}
