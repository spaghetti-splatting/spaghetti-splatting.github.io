// WebGPU viewer of the paper hair runs: device, buffers, passes, UI.
// The passes port the colour-only CUDA evaluation render of the export code
// tree (notes/webgpu_viewer_plan.md, section 4). All GPU data is float32 or
// u32. Plain ES module, no external code.

import {cameraFromRecord, Orbit} from './camera.js';

// ---------------------------------------------------------------------------
// Counts buffer slots (shaders/common.wgsl holds the same values).
// ---------------------------------------------------------------------------
export const SLOT = {
  ROWS: 0, KEPT: 1, PAIRS: 2, PAIRS_RAW: 3, SORT_GROUPS: 4, SORT_COUNTS: 5,
  FACE_ROWS: 6, PLAN_BASE: 16,
};
const COUNT_SLOTS = 64;
const ARGS_WORDS = 256;
const WORKGROUP = 256;
// The fixed pair capacity of the plan (section 4.2).
export const PAIR_CAPACITY = 16777216;

const STORAGE = GPUBufferUsage.STORAGE;
const COPY_SRC = GPUBufferUsage.COPY_SRC;
const COPY_DST = GPUBufferUsage.COPY_DST;

// The 1D or 2D grid of `groups` workgroups (scan.wgsl, grid_of).
export function gridOf(groups) {
  if (groups <= 65535) return [groups, 1, 1];
  return [32768, Math.ceil(groups / 32768), 1];
}

// The bit count of n (rasterizer_impl.cu, getHigherMsb).
export function higherMsb(n) {
  let msb = 16;
  let step = msb;
  while (step > 1) {
    step = Math.floor(step / 2);
    if ((n >>> msb) !== 0) msb += step; else msb -= step;
  }
  if ((n >>> msb) !== 0) msb += 1;
  return msb;
}

// ---------------------------------------------------------------------------
// Device
// ---------------------------------------------------------------------------
export async function createDevice() {
  if (!navigator.gpu) throw new Error('WebGPU is not available in this browser.');
  const adapter = await navigator.gpu.requestAdapter({powerPreference: 'high-performance'});
  if (!adapter) throw new Error('No WebGPU adapter.');
  const limits = adapter.limits;
  if (limits.maxComputeWorkgroupStorageSize < 32768) {
    throw new Error(`The adapter gives maxComputeWorkgroupStorageSize ` +
        `${limits.maxComputeWorkgroupStorageSize}; the render needs 32768.`);
  }
  const features = [];
  if (adapter.features.has('timestamp-query')) features.push('timestamp-query');
  const device = await adapter.requestDevice({
    requiredFeatures: features,
    requiredLimits: {
      maxComputeWorkgroupStorageSize: 32768,
      maxBufferSize: limits.maxBufferSize,
      maxStorageBufferBindingSize: limits.maxStorageBufferBindingSize,
    },
  });
  const info = adapter.info || {};
  return {adapter, device, adapterName: `${info.vendor || ''} ${info.architecture || ''}`.trim(),
          timestamps: features.includes('timestamp-query')};
}

// ---------------------------------------------------------------------------
// Shader modules: common.wgsl goes in front of every file.
// ---------------------------------------------------------------------------
const textCache = new Map();
async function fetchText(url) {
  if (!textCache.has(url)) {
    const response = await fetch(url, {cache: 'no-store'});
    if (!response.ok) throw new Error(`fetch ${url}: ${response.status}`);
    textCache.set(url, await response.text());
  }
  return textCache.get(url);
}

const moduleCache = new Map();
export async function loadModule(device, name) {
  const key = name;
  if (moduleCache.has(key) && moduleCache.get(key).device === device) {
    return moduleCache.get(key).module;
  }
  const base = new URL('shaders/', import.meta.url);
  const common = await fetchText(new URL('common.wgsl', base).href);
  const body = await fetchText(new URL(name, base).href);
  const module = device.createShaderModule({label: name, code: common + '\n' + body});
  const info = await module.getCompilationInfo();
  const errors = info.messages.filter(m => m.type === 'error');
  if (errors.length) {
    throw new Error(`WGSL errors in ${name}:\n` + errors.map(
        m => `line ${m.lineNum - common.split('\n').length}: ${m.message}`).join('\n'));
  }
  moduleCache.set(key, {device, module});
  return module;
}

function makeBuffer(device, size, usage, label) {
  // A binding needs at least 4 bytes.
  return device.createBuffer({label, size: Math.max(4, Math.ceil(size / 4) * 4), usage});
}

function makeUniform(device, words, label) {
  const data = new Uint32Array(Math.max(4, words.length));
  data.set(words);
  const buffer = device.createBuffer({label, size: data.byteLength,
                                      usage: GPUBufferUsage.UNIFORM | COPY_DST});
  device.queue.writeBuffer(buffer, 0, data);
  return buffer;
}

function bindGroup(device, pipeline, entries, label) {
  return device.createBindGroup({
    label, layout: pipeline.getBindGroupLayout(0),
    entries: Object.entries(entries).map(([binding, buffer]) => ({
      binding: Number(binding), resource: {buffer}})),
  });
}

// ---------------------------------------------------------------------------
// GPU context: the counts buffer, the indirect arguments, the pipelines of
// the scan, the compaction and the sort.
// ---------------------------------------------------------------------------
export class GpuContext {
  constructor(device) {
    this.device = device;
    this.counts = makeBuffer(device, COUNT_SLOTS * 4, STORAGE | COPY_SRC | COPY_DST, 'counts');
    this.args = makeBuffer(device, ARGS_WORDS * 4,
                           STORAGE | GPUBufferUsage.INDIRECT | COPY_DST | COPY_SRC, 'indirect args');
    this.nextSlot = SLOT.PLAN_BASE;
    this.nextArgs = 0;
    this.pipelines = {};
  }

  async init() {
    const device = this.device;
    const scan = await loadModule(device, 'scan.wgsl');
    const sort = await loadModule(device, 'sort.wgsl');
    const make = (module, entryPoint) => device.createComputePipeline({
      label: entryPoint, layout: 'auto', compute: {module, entryPoint}});
    this.pipelines.scanPlan = make(scan, 'scan_plan');
    this.pipelines.scanUp = make(scan, 'scan_up');
    this.pipelines.scanDown = make(scan, 'scan_down');
    this.pipelines.compact = make(scan, 'compact_scatter');
    this.pipelines.sortCount = make(sort, 'sort_count');
    this.pipelines.sortScatter = make(sort, 'sort_scatter');
    return this;
  }

  // The allocation state, so a later reset frees the slots of a model.
  mark() {
    return {slot: this.nextSlot, args: this.nextArgs};
  }

  reset(state) {
    this.nextSlot = state.slot;
    this.nextArgs = state.args;
  }

  allocSlots(count) {
    const first = this.nextSlot;
    this.nextSlot += count;
    if (this.nextSlot > COUNT_SLOTS) throw new Error('counts buffer full');
    return first;
  }

  allocArgs(words) {
    const first = this.nextArgs;
    this.nextArgs += words;
    if (this.nextArgs > ARGS_WORDS) throw new Error('indirect argument buffer full');
    return first;
  }
}

// ---------------------------------------------------------------------------
// Prefix sum of u32 values. The element count comes from counts[sourceSlot]
// at run time; maxN sizes the buffers. input and output must differ.
// ---------------------------------------------------------------------------
export class GpuScan {
  constructor(ctx, {input, output, maxN, sourceSlot, exclusive, label}) {
    const device = ctx.device;
    this.ctx = ctx;
    const sizes = [Math.max(1, maxN)];
    while (sizes[sizes.length - 1] > WORKGROUP) {
      sizes.push(Math.ceil(sizes[sizes.length - 1] / WORKGROUP));
    }
    this.levels = sizes.length;
    this.levelSlot = ctx.allocSlots(this.levels);
    this.argsIndex = ctx.allocArgs(3 * this.levels);
    this.exclusive = !!exclusive;
    const inputs = [input];
    const outputs = [output];
    const sums = [];
    for (let level = 0; level < this.levels; level++) {
      sums.push(makeBuffer(device, Math.ceil(sizes[level] / WORKGROUP) * 4, STORAGE,
                           `${label} sums ${level}`));
      if (level + 1 < this.levels) {
        inputs.push(sums[level]);
        outputs.push(makeBuffer(device, sizes[level + 1] * 4, STORAGE, `${label} scan ${level + 1}`));
      }
    }
    const dummy = makeBuffer(device, 4, STORAGE, `${label} dummy`);
    this.ownBuffers = [...sums, ...outputs.slice(1), dummy];
    const p = ctx.pipelines;
    this.planGroup = bindGroup(device, p.scanPlan, {
      0: ctx.counts, 1: ctx.args,
      2: makeUniform(device, [sourceSlot, this.levelSlot, this.argsIndex, this.levels], `${label} plan`),
    }, `${label} plan`);
    this.upGroups = [];
    this.downGroups = [];
    for (let level = 0; level < this.levels; level++) {
      const hasUpper = level + 1 < this.levels;
      const params = makeUniform(device, [
        this.levelSlot + level, level === 0 && this.exclusive ? 1 : 0, hasUpper ? 1 : 0, 0],
        `${label} params ${level}`);
      this.upGroups.push(bindGroup(device, p.scanUp, {
        0: inputs[level], 1: outputs[level], 2: sums[level], 3: ctx.counts, 4: params,
      }, `${label} up ${level}`));
      this.downGroups.push(bindGroup(device, p.scanDown, {
        0: inputs[level], 1: outputs[level], 3: ctx.counts, 4: params,
        5: hasUpper ? outputs[level + 1] : dummy,
      }, `${label} down ${level}`));
    }
  }

  destroy() {
    for (const buffer of this.ownBuffers) buffer.destroy();
  }

  encode(pass) {
    const p = this.ctx.pipelines;
    const args = this.ctx.args;
    pass.setPipeline(p.scanPlan);
    pass.setBindGroup(0, this.planGroup);
    pass.dispatchWorkgroups(1);
    pass.setPipeline(p.scanUp);
    for (let level = 0; level < this.levels; level++) {
      pass.setBindGroup(0, this.upGroups[level]);
      pass.dispatchWorkgroupsIndirect(args, (this.argsIndex + 3 * level) * 4);
    }
    pass.setPipeline(p.scanDown);
    for (let level = this.levels - 2; level >= 0; level--) {
      pass.setBindGroup(0, this.downGroups[level]);
      pass.dispatchWorkgroupsIndirect(args, (this.argsIndex + 3 * level) * 4);
    }
    if (this.levels === 1 && this.exclusive) {
      pass.setBindGroup(0, this.downGroups[0]);
      pass.dispatchWorkgroupsIndirect(args, this.argsIndex * 4);
    }
  }
}

// ---------------------------------------------------------------------------
// P1: stable compaction of the flagged rows. flags [rows] u32 in, the kept
// row list out, K in counts[SLOT.KEPT].
// ---------------------------------------------------------------------------
export class GpuCompact {
  constructor(ctx, {flags, rows, keptRows, label}) {
    const device = ctx.device;
    this.ctx = ctx;
    this.rows = rows;
    this.offsets = makeBuffer(device, rows * 4, STORAGE | COPY_SRC, `${label} offsets`);
    // The scan reads N from counts[SLOT.ROWS], which the host writes.
    this.scan = new GpuScan(ctx, {input: flags, output: this.offsets, maxN: rows,
                                  sourceSlot: SLOT.ROWS, exclusive: true, label: `${label} scan`});
    this.group = bindGroup(device, ctx.pipelines.compact, {
      0: flags, 1: this.offsets, 2: keptRows, 3: ctx.counts,
      4: makeUniform(device, [rows, 0, 0, 0], `${label} params`),
    }, `${label} scatter`);
  }

  destroy() {
    this.scan.destroy();
    this.offsets.destroy();
  }

  encode(pass) {
    this.scan.encode(pass);
    pass.setPipeline(this.ctx.pipelines.compact);
    pass.setBindGroup(0, this.group);
    const [x, y, z] = gridOf(Math.ceil(this.rows / WORKGROUP));
    pass.dispatchWorkgroups(x, y, z);
  }
}

// ---------------------------------------------------------------------------
// P7: stable LSD radix sort of the pairs in the "a" buffers. The pair count
// is counts[SLOT.PAIRS], the workgroup count counts[SLOT.SORT_GROUPS], and
// the caller writes the grid of the sort workgroups at args word argsIndex.
// The result is in result() after encode().
// ---------------------------------------------------------------------------
export class GpuSort {
  constructor(ctx, {capacity, a, b, tileBits, argsIndex, label}) {
    const device = ctx.device;
    this.ctx = ctx;
    this.argsIndex = argsIndex;
    const maxGroups = Math.ceil(capacity / WORKGROUP);
    this.digitCounts = makeBuffer(device, 16 * maxGroups * 4, STORAGE, `${label} digit counts`);
    this.digitOffsets = makeBuffer(device, 16 * maxGroups * 4, STORAGE, `${label} digit offsets`);
    this.scan = new GpuScan(ctx, {input: this.digitCounts, output: this.digitOffsets,
                                  maxN: 16 * maxGroups, sourceSlot: SLOT.SORT_COUNTS,
                                  exclusive: true, label: `${label} digit scan`});
    // 8 passes over key_lo, then ceil(tile_bits / 4) passes over key_hi.
    this.passes = [];
    for (let shift = 0; shift < 32; shift += 4) this.passes.push({useHi: 0, shift});
    for (let shift = 0; shift < tileBits; shift += 4) this.passes.push({useHi: 1, shift});
    const p = ctx.pipelines;
    this.groups = this.passes.map((pass, index) => {
      const [src, dst] = index % 2 === 0 ? [a, b] : [b, a];
      // key_lo moves while a later pass reads it.
      const moveLo = pass.useHi === 0 && index + 1 < 8 ? 1 : 0;
      const params = makeUniform(device, [pass.shift, pass.useHi, moveLo, 0],
                                 `${label} pass ${index}`);
      return {
        count: bindGroup(device, p.sortCount, {
          0: pass.useHi ? src.hi : src.lo, 1: ctx.counts, 2: this.digitCounts, 3: params,
        }, `${label} count ${index}`),
        scatter: bindGroup(device, p.sortScatter, {
          0: src.hi, 1: src.lo, 2: src.value, 3: dst.hi, 4: dst.lo, 5: dst.value,
          6: this.digitOffsets, 7: ctx.counts, 8: params,
        }, `${label} scatter ${index}`),
      };
    });
    this.resultBuffers = this.passes.length % 2 === 0 ? a : b;
  }

  result() {
    return this.resultBuffers;
  }

  destroy() {
    this.scan.destroy();
    this.digitCounts.destroy();
    this.digitOffsets.destroy();
  }

  encode(pass) {
    const p = this.ctx.pipelines;
    const offset = this.argsIndex * 4;
    for (const group of this.groups) {
      pass.setPipeline(p.sortCount);
      pass.setBindGroup(0, group.count);
      pass.dispatchWorkgroupsIndirect(this.ctx.args, offset);
      this.scan.encode(pass);
      pass.setPipeline(p.sortScatter);
      pass.setBindGroup(0, group.scatter);
      pass.dispatchWorkgroupsIndirect(this.ctx.args, offset);
    }
  }
}

// ---------------------------------------------------------------------------
// Read-back helper.
// ---------------------------------------------------------------------------
export async function readBuffer(device, buffer, byteLength, byteOffset = 0) {
  const size = Math.ceil(byteLength / 4) * 4;
  const staging = device.createBuffer({size: Math.max(4, size),
                                       usage: GPUBufferUsage.MAP_READ | COPY_DST});
  const encoder = device.createCommandEncoder();
  encoder.copyBufferToBuffer(buffer, byteOffset, staging, 0, size);
  device.queue.submit([encoder.finish()]);
  await staging.mapAsync(GPUMapMode.READ);
  const copy = staging.getMappedRange().slice(0, byteLength);
  staging.unmap();
  staging.destroy();
  return copy;
}

// ---------------------------------------------------------------------------
// Renderer: the buffers of one model and the passes P0-P10 of one frame.
// ---------------------------------------------------------------------------

const MODEL_FILES = [
  ['endpoints', 'endpoints.f32', 6],
  ['logScales', 'prefilter_log_scales.f32', 3],
  ['uni', 'uni.f32', 8],
  ['amplitude', 'amplitude.f32', 1],
  ['s3d', 's3d.f32', 1],
  ['face', 'face.u32', 1],
  ['sites', 'sv_sites.f32', 24],
  ['colors', 'sv_colors.f32', 24],
  ['logTau', 'sv_log_tau.f32', 8],
];
const PRIM_BYTES = 80;
const CAMERA_BYTES = 224;
const BUFFER_ALL = STORAGE | COPY_DST | COPY_SRC;

export class Renderer {
  constructor(device, ctx, timestamps) {
    this.device = device;
    this.ctx = ctx;
    this.timestamps = timestamps;
    this.model = null;
    this.size = null;
    this.sorts = new Map();
  }

  async init() {
    const device = this.device;
    const make = async (file, entryPoint) => device.createComputePipeline({
      label: entryPoint, layout: 'auto',
      compute: {module: await loadModule(device, file), entryPoint}});
    this.p0 = await make('prefilter.wgsl', 'prefilter');
    this.p2 = await make('face.wgsl', 'face_factor_pass');
    this.p3 = await make('preprocess.wgsl', 'preprocess');
    this.p4 = await make('sv8.wgsl', 'sv8_color');
    this.p6 = await make('preprocess.wgsl', 'duplicate_keys');
    this.p8 = await make('frame.wgsl', 'tile_ranges');
    this.argsKept = await make('frame.wgsl', 'args_after_compaction');
    this.argsPairs = await make('frame.wgsl', 'args_after_scan');
    const display = await loadModule(device, 'display.wgsl');
    this.p10 = device.createRenderPipeline({
      label: 'display', layout: 'auto',
      vertex: {module: display, entryPoint: 'display_vertex'},
      fragment: {module: display, entryPoint: 'display_fragment',
                 targets: [{format: 'bgra8unorm'}]},
      primitive: {topology: 'triangle-list'},
    });
    this.p9 = await make('render.wgsl', 'render');
    this.keptArgs = this.ctx.allocArgs(3);
    this.pairArgs = this.ctx.allocArgs(3);
    this.cameraBuffer = device.createBuffer({label: 'camera', size: CAMERA_BYTES,
                                             usage: GPUBufferUsage.UNIFORM | COPY_DST});
    this.frameParams = makeUniform(device, [this.keptArgs, this.pairArgs, PAIR_CAPACITY, 0], 'frame params');
    if (this.timestamps) {
      this.querySet = device.createQuerySet({type: 'timestamp', count: 2});
      this.queryResolve = device.createBuffer({size: 16, usage: GPUBufferUsage.QUERY_RESOLVE | COPY_SRC});
    }
    this.slotMark = this.ctx.mark();
    return this;
  }

  // Load the files of one run. onProgress(text) reports each step.
  async loadModel(name, onProgress) {
    const device = this.device;
    const base = `data/${name}/`;
    const header = await (await fetch(base + 'header.json', {cache: 'no-store'})).json();
    const cameras = await (await fetch(base + 'cameras.json', {cache: 'no-store'})).json();
    const rows = header.N;
    if (header.L !== 8) throw new Error(`uni has ${header.L} lanes; the port reads 8`);
    const model = {name, header, cameras, rows, buffers: {}};
    let loaded = 0;
    for (const [key, file, width] of MODEL_FILES) {
      onProgress(`loading ${name}: ${file} (${loaded + 1}/${MODEL_FILES.length})`);
      const response = await fetch(base + file, {cache: 'no-store'});
      if (!response.ok) throw new Error(`fetch ${file}: ${response.status}`);
      const data = await response.arrayBuffer();
      if (data.byteLength !== rows * width * 4) {
        throw new Error(`${file}: ${data.byteLength} bytes, expected ${rows * width * 4}`);
      }
      const buffer = makeBuffer(device, data.byteLength, BUFFER_ALL, file);
      device.queue.writeBuffer(buffer, 0, data);
      model.buffers[key] = buffer;
      if (key === 'endpoints') model.bounds = boundsOf(new Float32Array(data));
      loaded++;
    }
    const frame = {
      flags: makeBuffer(device, rows * 4, BUFFER_ALL, 'keep flags'),
      kept: makeBuffer(device, rows * 4, BUFFER_ALL, 'kept rows'),
      faceFactor: makeBuffer(device, rows * 4, BUFFER_ALL, 'face factor'),
      prims: makeBuffer(device, rows * PRIM_BYTES, BUFFER_ALL, 'primitives'),
      tiles: makeBuffer(device, rows * 4, BUFFER_ALL, 'tiles touched'),
      offsets: makeBuffer(device, rows * 4, BUFFER_ALL, 'tile offsets'),
      rgb: makeBuffer(device, rows * 12, BUFFER_ALL, 'sv8 rgb'),
    };
    device.queue.writeBuffer(frame.faceFactor, 0, new Float32Array(rows).fill(1.0));
    model.frame = frame;
    if (!this.pairs) {
      const pairBuffer = (label) => makeBuffer(device, PAIR_CAPACITY * 4, STORAGE | COPY_SRC, label);
      this.pairs = {
        a: {hi: pairBuffer('key hi a'), lo: pairBuffer('key lo a'), value: pairBuffer('value a')},
        b: {hi: pairBuffer('key hi b'), lo: pairBuffer('key lo b'), value: pairBuffer('value b')},
      };
    }
    this.releaseModel();
    this.model = model;
    this.buildModelGroups();
    device.queue.writeBuffer(this.ctx.counts, SLOT.ROWS * 4, new Uint32Array([rows]));
    onProgress(`loaded ${name}: ${rows} rows, ${cameras.length} cameras`);
    return model;
  }

  releaseModel() {
    if (!this.model) return;
    for (const buffer of Object.values(this.model.buffers)) buffer.destroy();
    for (const buffer of Object.values(this.model.frame)) buffer.destroy();
    this.compact.destroy();
    this.tileScan.destroy();
    for (const sort of this.sorts.values()) sort.destroy();
    this.sorts.clear();
    if (this.size) {
      this.size.outColor.destroy();
      this.size.ranges.destroy();
      this.size = null;
    }
    this.ctx.reset(this.slotMark);
    this.model = null;
  }

  buildModelGroups() {
    const device = this.device;
    const m = this.model.buffers;
    const f = this.model.frame;
    const ctx = this.ctx;
    const cam = this.cameraBuffer;
    this.compact = new GpuCompact(ctx, {flags: f.flags, rows: this.model.rows, keptRows: f.kept,
                                        label: 'P1'});
    this.tileScan = new GpuScan(ctx, {input: f.tiles, output: f.offsets, maxN: this.model.rows,
                                      sourceSlot: SLOT.KEPT, exclusive: false, label: 'P5'});
    this.groups = {
      p0: bindGroup(device, this.p0, {0: m.endpoints, 1: m.logScales, 2: f.flags, 3: cam}, 'P0'),
      argsKept: bindGroup(device, this.argsKept, {0: ctx.counts, 1: ctx.args, 3: this.frameParams}, 'args K'),
      p2: bindGroup(device, this.p2, {0: m.endpoints, 1: m.uni, 2: m.s3d, 3: m.face, 4: f.kept,
                                      5: ctx.counts, 6: f.faceFactor, 7: cam}, 'P2'),
      p3: bindGroup(device, this.p3, {0: f.kept, 1: m.endpoints, 2: m.uni, 3: m.amplitude,
                                      4: f.faceFactor, 5: ctx.counts, 6: f.prims, 7: f.tiles, 8: cam}, 'P3'),
      p4: bindGroup(device, this.p4, {0: f.kept, 1: f.tiles, 2: m.endpoints, 3: m.sites, 4: m.colors,
                                      5: m.logTau, 6: ctx.counts, 7: f.rgb, 8: cam}, 'P4'),
      argsPairs: bindGroup(device, this.argsPairs, {0: ctx.counts, 1: ctx.args, 2: f.offsets,
                                                    3: this.frameParams}, 'args pairs'),
      p6: bindGroup(device, this.p6, {0: f.prims, 1: f.offsets, 2: ctx.counts, 3: this.pairs.a.hi,
                                      4: this.pairs.a.lo, 5: this.pairs.a.value, 6: cam}, 'P6'),
    };
  }

  // Buffers and groups of one image size.
  setSize(width, height) {
    if (this.size && this.size.width === width && this.size.height === height) return;
    const device = this.device;
    if (this.size) {
      this.size.outColor.destroy();
      this.size.ranges.destroy();
    }
    const tilesX = Math.ceil(width / 16);
    const tilesY = Math.ceil(height / 16);
    const tileBits = higherMsb(tilesX * tilesY);
    if (!this.sorts.has(tileBits)) {
      this.sorts.set(tileBits, new GpuSort(this.ctx, {capacity: PAIR_CAPACITY, a: this.pairs.a,
                                                      b: this.pairs.b, tileBits,
                                                      argsIndex: this.pairArgs, label: 'P7'}));
    }
    const sort = this.sorts.get(tileBits);
    const sorted = sort.result();
    const outColor = makeBuffer(device, 3 * width * height * 4, BUFFER_ALL, 'image');
    const ranges = makeBuffer(device, 2 * tilesX * tilesY * 4, BUFFER_ALL, 'tile ranges');
    this.size = {
      width, height, tilesX, tilesY, tileBits, sort, outColor, ranges,
      p8: bindGroup(device, this.p8, {0: sorted.hi, 1: this.ctx.counts, 2: ranges}, 'P8'),
      p9: bindGroup(device, this.p9, {0: ranges, 1: sorted.value, 2: this.model.frame.prims,
                                      3: this.model.frame.rgb, 4: outColor, 5: this.cameraBuffer}, 'P9'),
      p10: bindGroup(device, this.p10, {0: outColor,
                                        1: makeUniform(device, [width, height, 0, 0], 'display')}, 'P10'),
    };
  }

  // Write the camera uniform of one frame.
  writeCamera(camera, diag) {
    const header = this.model.header;
    const constants = header.constants;
    const data = new ArrayBuffer(CAMERA_BYTES);
    const f = new Float32Array(data);
    const u = new Uint32Array(data);
    f.set(camera.view, 0);
    f.set(camera.proj, 16);
    f.set(camera.campos, 32);
    f.set(header.background.map(Math.fround), 36);
    u[40] = camera.width;
    u[41] = camera.height;
    u[42] = Math.ceil(camera.width / 16);
    u[43] = Math.ceil(camera.height / 16);
    // CUDA: w_aa_px is a float32 argument; beta = w_aa_px * w_aa_px in float32.
    const wAa = Math.fround(constants.AA_2D_PX);
    f[44] = wAa;
    f[45] = Math.fround(wAa * wAa);
    // Host code of fusedPointReferenceVisibilityCUDA, in float32.
    const pad = Math.fround(constants.VISIBILITY_PREFILTER_PIXEL_PAD);
    f[46] = Math.fround(1.0 + Math.fround(Math.fround(2.0 * pad) / Math.fround(camera.width)));
    f[47] = Math.fround(1.0 + Math.fround(Math.fround(2.0 * pad) / Math.fround(camera.height)));
    f[48] = Math.fround(constants.VISIBILITY_PREFILTER_SCALE);
    // Torch face factor: AA_2D_PX * AA_2D_PX and 0.5 * width in double,
    // then float32.
    f[49] = Math.fround(constants.AA_2D_PX * constants.AA_2D_PX);
    f[50] = Math.fround(0.5 * camera.width);
    f[51] = Math.fround(0.5 * camera.height);
    u[52] = this.model.rows;
    u[53] = PAIR_CAPACITY;
    u[54] = diag ? 1 : 0;
    this.device.queue.writeBuffer(this.cameraBuffer, 0, data);
  }

  // Record the passes P0-P9 of one frame into the encoder.
  encodeFrame(encoder, camera, {diag = false} = {}) {
    this.setSize(camera.width, camera.height);
    this.writeCamera(camera, diag);
    const size = this.size;
    const rows = this.model.rows;
    const args = this.ctx.args;
    encoder.clearBuffer(size.ranges);
    const descriptor = {label: 'frame'};
    if (this.timestamps) {
      descriptor.timestampWrites = {querySet: this.querySet, beginningOfPassWriteIndex: 0,
                                    endOfPassWriteIndex: 1};
    }
    const pass = encoder.beginComputePass(descriptor);
    const rowGrid = gridOf(Math.ceil(rows / WORKGROUP));
    // P0: visibility prefilter.
    pass.setPipeline(this.p0);
    pass.setBindGroup(0, this.groups.p0);
    pass.dispatchWorkgroups(...rowGrid);
    // P1: stable compaction of the kept rows.
    this.compact.encode(pass);
    pass.setPipeline(this.argsKept);
    pass.setBindGroup(0, this.groups.argsKept);
    pass.dispatchWorkgroups(1);
    // P2: face factor (all rows for the diagnostics).
    pass.setPipeline(this.p2);
    pass.setBindGroup(0, this.groups.p2);
    if (diag) pass.dispatchWorkgroups(...rowGrid);
    else pass.dispatchWorkgroupsIndirect(args, this.keptArgs * 4);
    // P3: preprocess.
    pass.setPipeline(this.p3);
    pass.setBindGroup(0, this.groups.p3);
    pass.dispatchWorkgroupsIndirect(args, this.keptArgs * 4);
    // P4: SV8 colour.
    pass.setPipeline(this.p4);
    pass.setBindGroup(0, this.groups.p4);
    pass.dispatchWorkgroupsIndirect(args, this.keptArgs * 4);
    // P5: inclusive scan of the tile counts, then the pair count.
    this.tileScan.encode(pass);
    pass.setPipeline(this.argsPairs);
    pass.setBindGroup(0, this.groups.argsPairs);
    pass.dispatchWorkgroups(1);
    // P6: key duplication.
    pass.setPipeline(this.p6);
    pass.setBindGroup(0, this.groups.p6);
    pass.dispatchWorkgroupsIndirect(args, this.keptArgs * 4);
    // P7: radix sort.
    size.sort.encode(pass);
    // P8: tile ranges.
    pass.setPipeline(this.p8);
    pass.setBindGroup(0, size.p8);
    pass.dispatchWorkgroupsIndirect(args, this.pairArgs * 4);
    // P9: render, one workgroup per tile.
    pass.setPipeline(this.p9);
    pass.setBindGroup(0, size.p9);
    pass.dispatchWorkgroups(size.tilesX, size.tilesY, 1);
    pass.end();
    if (this.timestamps) encoder.resolveQuerySet(this.querySet, 0, 2, this.queryResolve, 0);
  }

  // P10: copy the image to the canvas texture.
  encodeDisplay(encoder, view) {
    const pass = encoder.beginRenderPass({colorAttachments: [{
      view, loadOp: 'clear', storeOp: 'store', clearValue: {r: 0, g: 0, b: 0, a: 1}}]});
    pass.setPipeline(this.p10);
    pass.setBindGroup(0, this.size.p10);
    pass.draw(3);
    pass.end();
  }
}

function boundsOf(endpoints) {
  const lo = [Infinity, Infinity, Infinity];
  const hi = [-Infinity, -Infinity, -Infinity];
  for (let i = 0; i < endpoints.length; i += 3) {
    for (let c = 0; c < 3; c++) {
      const v = endpoints[i + c];
      if (v < lo[c]) lo[c] = v;
      if (v > hi[c]) hi[c] = v;
    }
  }
  return {lo, hi, center: [0, 1, 2].map(c => 0.5 * (lo[c] + hi[c]))};
}

// ---------------------------------------------------------------------------
// Page
// ---------------------------------------------------------------------------
async function postFile(run, file, body) {
  const response = await fetch(`/parity/${run}/${file}`, {method: 'POST', body});
  if (!response.ok) throw new Error(`POST ${file}: ${response.status}`);
}

function splitCameras(model, split) {
  return model.cameras.filter(c => c.split === split);
}

// Parity mode: render each camera of the split once and post the float32
// image. Index i counts the cameras of the split in cameras.json order.
async function runParity(renderer, model, params, ui) {
  const device = renderer.device;
  const diag = params.get('diag') === '1';
  const split = params.get('split') || 'test';
  const tests = splitCameras(model, split);
  const times = [];
  const pairCounts = [];
  const warnings = [];
  for (let i = 0; i < tests.length; i++) {
    const camera = cameraFromRecord(tests[i]);
    const withDiag = diag && i === 0;
    ui.progress(`parity ${model.name}: ${split} view ${i} (${camera.name}), ${i}/${tests.length}`);
    const t0 = performance.now();
    const encoder = device.createCommandEncoder();
    renderer.encodeFrame(encoder, camera, {diag: withDiag});
    device.queue.submit([encoder.finish()]);
    const size = renderer.size;
    const image = await readBuffer(device, size.outColor, 3 * camera.width * camera.height * 4);
    const ms = performance.now() - t0;
    times.push(ms);
    const counts = new Uint32Array(await readBuffer(device, renderer.ctx.counts, 64 * 4));
    pairCounts.push(counts[SLOT.PAIRS_RAW]);
    if (counts[SLOT.PAIRS_RAW] > PAIR_CAPACITY) {
      warnings.push(`view ${i}: ${counts[SLOT.PAIRS_RAW]} pairs exceed the capacity ${PAIR_CAPACITY}`);
    }
    await postFile(model.name, `webgpu_${i}.f32`, image);
    if (withDiag) {
      const frame = model.frame;
      const kept = counts[SLOT.KEPT];
      await postFile(model.name, 'diag_keep_idx.u32', await readBuffer(device, frame.kept, kept * 4));
      await postFile(model.name, 'diag_face_factor.f32', await readBuffer(device, frame.faceFactor, model.rows * 4));
      await postFile(model.name, 'diag_sv_rgb.f32', await readBuffer(device, frame.rgb, kept * 12));
      await postFile(model.name, 'diag_tiles.u32', await readBuffer(device, frame.tiles, kept * 4));
      await postFile(model.name, 'diag_counts.json', JSON.stringify(
          {pair_count: counts[SLOT.PAIRS_RAW], kept_count: kept}));
    }
    console.log(`parity view ${i} ${camera.name}: ${ms.toFixed(0)} ms, ${counts[SLOT.PAIRS_RAW]} pairs, K ${counts[SLOT.KEPT]}`);
  }
  await postFile(model.name, 'done.json', JSON.stringify({
    run: model.name, split, views: tests.length, camera_names: tests.map(c => c.name),
    view_ms: times, pair_counts: pairCounts, warnings, adapter: ui.adapterName,
    finished: new Date().toISOString()}, null, 1));
  ui.progress(`parity ${model.name}: done, ${tests.length} views`);
}

// Orbit check: render the first test camera, then frames under orbit
// control, and post the WebGPU errors that the device reports.
async function runOrbitTest(renderer, model, ui, errors, canvas) {
  const device = renderer.device;
  const first = cameraFromRecord(splitCameras(model, 'test')[0] || model.cameras[0]);
  canvas.width = first.width;
  canvas.height = first.height;
  const orbit = new Orbit(first, model.bounds.center);
  const moves = [
    () => {}, () => orbit.rotate(40, 15), () => orbit.pan(-30, 20), () => orbit.dolly(-400),
  ];
  const frames = [];
  for (let i = 0; i < moves.length; i++) {
    moves[i]();
    const camera = i === 0 ? first : orbit.camera();
    const t0 = performance.now();
    const encoder = device.createCommandEncoder();
    renderer.encodeFrame(encoder, camera);
    if (ui.context) renderer.encodeDisplay(encoder, ui.context.getCurrentTexture().createView());
    device.queue.submit([encoder.finish()]);
    await device.queue.onSubmittedWorkDone();
    const counts = new Uint32Array(await readBuffer(device, renderer.ctx.counts, 64 * 4));
    frames.push({frame: i, ms: performance.now() - t0, kept: counts[SLOT.KEPT],
                 pairs: counts[SLOT.PAIRS_RAW]});
    ui.progress(`orbit check ${model.name}: frame ${i + 1}/${moves.length}`);
  }
  await postFile(model.name, 'orbit_done.json', JSON.stringify(
      {run: model.name, frames, errors, finished: new Date().toISOString()}, null, 1));
}

export async function main() {
  const params = new URLSearchParams(location.search);
  const el = (id) => document.getElementById(id);
  const ui = {
    progress: (text) => { el('progress').textContent = text; console.log(text); },
    warn: (text) => { el('warning').textContent = text; if (text) console.warn(text); },
    context: null, adapterName: '',
  };
  const errors = [];
  try {
    const {device, adapterName, timestamps} = await createDevice();
    ui.adapterName = adapterName;
    device.addEventListener('uncapturederror', (event) => {
      errors.push(event.error.message);
      console.error(`WebGPU error: ${event.error.message}`);
      ui.warn(`WebGPU error: ${event.error.message}`);
    });
    device.lost.then((info) => {
      errors.push(`device lost: ${info.message}`);
      console.error(`WebGPU device lost: ${info.message}`);
    });
    const ctx = await new GpuContext(device).init();
    const renderer = await new Renderer(device, ctx, timestamps).init();
    const canvas = el('view');
    ui.context = canvas.getContext('webgpu');
    ui.context.configure({device, format: 'bgra8unorm', alphaMode: 'opaque'});
    const names = await (await fetch('data/models.json', {cache: 'no-store'})).json();
    const modelSelect = el('model');
    for (const name of names) modelSelect.add(new Option(name, name));
    const requested = params.get('model');
    if (requested && names.includes(requested)) modelSelect.value = requested;

    if (params.get('parity') === '1') {
      ui.context = null;
      const model = await renderer.loadModel(modelSelect.value, ui.progress);
      await runParity(renderer, model, params, ui);
      return;
    }
    if (params.get('orbit_test') === '1') {
      const model = await renderer.loadModel(modelSelect.value, ui.progress);
      await runOrbitTest(renderer, model, ui, errors, canvas);
      return;
    }
    await interactive(renderer, ui, modelSelect, el, canvas);
  } catch (error) {
    errors.push(String(error));
    console.error(error);
    ui.progress(`error: ${error.message || error}`);
    if (params.get('parity') === '1' || params.get('orbit_test') === '1') {
      const run = params.get('model') || 'unknown';
      const file = params.get('parity') === '1' ? 'done.json' : 'orbit_done.json';
      await postFile(run, file, JSON.stringify({run, error: String(error), errors}));
    }
  }
}

// Interactive page: model and camera selectors, orbit control, FPS line.
async function interactive(renderer, ui, modelSelect, el, canvas) {
  const device = renderer.device;
  const cameraSelect = el('camera');
  let model = null;
  let orbit = null;
  let camera = null;
  let busy = false;
  const frameTimes = [];
  let lastFrameEnd = null;

  async function selectModel() {
    model = await renderer.loadModel(modelSelect.value, ui.progress);
    cameraSelect.innerHTML = '';
    model.cameras.forEach((c, i) => cameraSelect.add(new Option(`${c.split} ${c.name}`, String(i))));
    const firstTest = model.cameras.findIndex(c => c.split === 'test');
    cameraSelect.value = String(Math.max(0, firstTest));
    selectCamera();
  }

  function selectCamera() {
    camera = cameraFromRecord(model.cameras[Number(cameraSelect.value)]);
    orbit = new Orbit(camera, model.bounds.center);
    canvas.width = camera.width;
    canvas.height = camera.height;
  }

  modelSelect.addEventListener('change', () => selectModel().catch(e => ui.progress(`error: ${e}`)));
  cameraSelect.addEventListener('change', selectCamera);
  // Orbit control: left drag rotates, right drag pans, the wheel moves along
  // the view axis.
  let drag = null;
  canvas.addEventListener('contextmenu', (event) => event.preventDefault());
  canvas.addEventListener('pointerdown', (event) => {
    drag = {x: event.clientX, y: event.clientY, button: event.button};
    canvas.setPointerCapture(event.pointerId);
  });
  canvas.addEventListener('pointermove', (event) => {
    if (!drag || !orbit) return;
    const scaleX = canvas.width / canvas.clientWidth;
    const dx = (event.clientX - drag.x) * scaleX;
    const dy = (event.clientY - drag.y) * scaleX;
    drag.x = event.clientX;
    drag.y = event.clientY;
    if (drag.button === 0) orbit.rotate(dx, dy);
    else orbit.pan(dx, dy);
    camera = orbit.camera();
  });
  canvas.addEventListener('pointerup', () => { drag = null; });
  canvas.addEventListener('wheel', (event) => {
    event.preventDefault();
    if (!orbit) return;
    orbit.dolly(event.deltaY);
    camera = orbit.camera();
  }, {passive: false});

  const readbacks = [];
  async function frame() {
    if (busy || !model || !camera) return;
    busy = true;
    const start = performance.now();
    const encoder = device.createCommandEncoder();
    renderer.encodeFrame(encoder, camera);
    renderer.encodeDisplay(encoder, ui.context.getCurrentTexture().createView());
    let stamp = null;
    if (renderer.timestamps) {
      stamp = readbacks.pop() || device.createBuffer({size: 16, usage: GPUBufferUsage.MAP_READ | COPY_DST});
      encoder.copyBufferToBuffer(renderer.queryResolve, 0, stamp, 0, 16);
    }
    const countsCopy = device.createBuffer({size: 16, usage: GPUBufferUsage.MAP_READ | COPY_DST});
    encoder.copyBufferToBuffer(renderer.ctx.counts, 0, countsCopy, 0, 16);
    device.queue.submit([encoder.finish()]);
    await device.queue.onSubmittedWorkDone();
    let ms = lastFrameEnd === null ? performance.now() - start : performance.now() - lastFrameEnd;
    lastFrameEnd = performance.now();
    if (stamp) {
      await stamp.mapAsync(GPUMapMode.READ);
      const t = new BigUint64Array(stamp.getMappedRange());
      const gpuMs = Number(t[1] - t[0]) / 1e6;
      stamp.unmap();
      readbacks.push(stamp);
      if (gpuMs > 0) ms = gpuMs;
    }
    await countsCopy.mapAsync(GPUMapMode.READ);
    const counts = new Uint32Array(countsCopy.getMappedRange().slice(0));
    countsCopy.destroy();
    ui.warn(counts[SLOT.PAIRS_RAW] > PAIR_CAPACITY
        ? `warning: ${counts[SLOT.PAIRS_RAW]} pairs exceed the capacity ${PAIR_CAPACITY}; the image is not complete`
        : '');
    frameTimes.push(ms);
    if (frameTimes.length > 60) frameTimes.shift();
    const mean = frameTimes.reduce((a, b) => a + b, 0) / frameTimes.length;
    el('fps').textContent = `${renderer.timestamps ? 'GPU' : 'frame'} time ${mean.toFixed(1)} ms ` +
        `(${(1000 / mean).toFixed(1)} FPS, mean of ${frameTimes.length}); K ${counts[SLOT.KEPT]}, ` +
        `pairs ${counts[SLOT.PAIRS_RAW]}; ${ui.adapterName}`;
    busy = false;
  }

  function loop() {
    frame().catch((error) => { busy = false; ui.progress(`error: ${error.message || error}`); });
    requestAnimationFrame(loop);
  }
  await selectModel();
  requestAnimationFrame(loop);
}
