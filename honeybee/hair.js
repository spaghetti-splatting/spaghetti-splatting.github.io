// Interactive hair on the GPU (gpu2/shaders/hair.wgsl, deform.wgsl).
//
// Data: <run>/sim/ of tools/hairprep.py: strand vertex offsets, the export row of each
// segment, the rest vertices (bit-exact copies of the endpoints), the head SDF.
// Parameters (SI, from StrandSim / sim.js): style spring 1000 /s^2 at the root to 40 /s^2
// at the tip over 0.05 m, bending 3000, damping 3 /s, drag 10 /s, grab spring 1500 /s^2,
// grab radius 0.04 m, head margin 1 mm, DFTL velocity correction 0.5, substeps of 1/240 s.
// Wind 1.0 m/s (the WebGL demo used 1.6 m/s; with drag 10 /s and the tip spring 40 /s^2 that
// holds the tips about 0.4 m away, which looked too wild).

import {loadModule, gridOf} from './gpu2/viewer.js';
import {fetchBytes} from './model.js';

export const HAIR_DEFAULTS = {
  styleRoot: 1000, styleTip: 40, styleRange: 0.05, bending: 3000, damping: 3, drag: 10,
  stiffK: 1500, grabM: 0.04, correction: 0.5, windSpeed: 1.0, substep: 1 / 240,
};
const NO_COLLISION = -1.0e30;
const PARAM_BYTES = 144;

export async function hairBytes(name) {
  const r = await fetch(`${window.KC_DATA}${name}/sim/sim.json`);
  if (!r.ok) return null;
  const meta = await r.json();
  const s = meta.sdf_shape;
  return {meta, bytes: 4 * (meta.strands + 1) + 4 * meta.vertices + 12 * meta.vertices + 4 * s[0] * s[1] * s[2]};
}

function sdfSampler(meta, sdf) {
  const [nx, ny, nz] = meta.sdf_shape;
  const [ox, oy, oz] = meta.sdf_origin;
  const iv = 1 / meta.sdf_voxel;
  return (px, py, pz) => {
    let fx = (px - ox) * iv, fy = (py - oy) * iv, fz = (pz - oz) * iv;
    if (fx < 0 || fy < 0 || fz < 0 || fx > nx - 1.001 || fy > ny - 1.001 || fz > nz - 1.001) return 1e6;
    const i = fx | 0, j = fy | 0, k = fz | 0;
    fx -= i; fy -= j; fz -= k;
    const o = (i * ny + j) * nz + k, sj = nz, si = ny * nz, S = sdf;
    const c00 = S[o] + (S[o + 1] - S[o]) * fz, c01 = S[o + sj] + (S[o + sj + 1] - S[o + sj]) * fz;
    const c10 = S[o + si] + (S[o + si + 1] - S[o + si]) * fz;
    const c11 = S[o + si + sj] + (S[o + si + sj + 1] - S[o + si + sj]) * fz;
    const c0 = c00 + (c01 - c00) * fy, c1 = c10 + (c11 - c10) * fy;
    return c0 + (c1 - c0) * fx;
  };
}

export class HairSim {
  constructor(device, renderer, picker) {
    this.device = device;
    this.renderer = renderer;
    this.picker = picker;
    this.params = {...HAIR_DEFAULTS};
    this.active = false;       // the simulation runs this frame
    this.grabbing = false;
    this.wind = false;
    this.delta = [0, 0, 0];
    this.time = 0;
    this.quiet = 0;            // seconds below the settle threshold
    this.statsPending = false;
    this.frameCount = 0;
    this.lastStats = {speed: 0, offset: 0};
  }

  async load(name, meta, reportBytes) {
    const d = this.device;
    const base = `${window.KC_DATA}${name}/sim/`;
    const V = meta.vertices, S = meta.strands;
    const s = meta.sdf_shape;
    const offsets = new Uint32Array(await fetchBytes(base + 'strands.u32', 4 * (S + 1), reportBytes));
    const rows = new Uint32Array(await fetchBytes(base + 'rows.u32', 4 * V, reportBytes));
    const rest = new Float32Array(await fetchBytes(base + 'rest.f32', 12 * V, reportBytes));
    const sdf = new Float32Array(await fetchBytes(base + 'sdf.f32', 4 * s[0] * s[1] * s[2], reportBytes));
    this.meta = meta;
    this.V = V; this.S = S;
    this.metres = meta.metres;
    const sample = sdfSampler(meta, sdf);
    const margin = 0.001 * this.metres;
    const rest4 = new Float32Array(4 * V);
    const aux = new Float32Array(4 * V);
    for (let st = 0; st < S; st++) {
      let arc = 0;
      for (let i = offsets[st]; i < offsets[st + 1]; i++) {
        const x = rest[3 * i], y = rest[3 * i + 1], z = rest[3 * i + 2];
        let len = 0;
        if (i > offsets[st]) {
          const dx = x - rest[3 * i - 3], dy = y - rest[3 * i - 2], dz = z - rest[3 * i - 1];
          len = Math.sqrt(dx * dx + dy * dy + dz * dz);
          arc += len / this.metres;
        }
        rest4.set([x, y, z, arc], 4 * i);
        const r = sample(x, y, z);
        aux[4 * i] = len;
        aux[4 * i + 1] = r < 0 ? NO_COLLISION : Math.min(margin, r);
      }
    }
    const buf = (data, label, usage = GPUBufferUsage.STORAGE | GPUBufferUsage.COPY_DST | GPUBufferUsage.COPY_SRC) => {
      const b = d.createBuffer({label, size: Math.max(16, data.byteLength), usage});
      d.queue.writeBuffer(b, 0, data);
      return b;
    };
    const m = this.renderer.model.buffers;
    this.b = {
      offsets: buf(offsets, 'hair offsets'),
      rows: buf(rows, 'hair rows'),
      rest4: buf(rest4, 'hair rest'),
      aux: buf(aux, 'hair aux'),
      grabBase: buf(new Float32Array(4 * V), 'hair grab base'),
      xs: buf(rest4, 'hair x'),
      vs: buf(new Float32Array(4 * V), 'hair v'),
      sdf: buf(sdf, 'hair sdf'),
      stats: buf(new Uint32Array(4), 'hair stats'),
      uniRest: d.createBuffer({label: 'uni rest', size: m.uni.size, usage: GPUBufferUsage.STORAGE | GPUBufferUsage.COPY_DST}),
      sitesRest: d.createBuffer({label: 'sites rest', size: m.sites.size, usage: GPUBufferUsage.STORAGE | GPUBufferUsage.COPY_DST}),
      params: d.createBuffer({size: PARAM_BYTES, usage: GPUBufferUsage.UNIFORM | GPUBufferUsage.COPY_DST}),
      deformParams: d.createBuffer({size: 16, usage: GPUBufferUsage.UNIFORM | GPUBufferUsage.COPY_DST}),
      statsRead: d.createBuffer({size: 16, usage: GPUBufferUsage.MAP_READ | GPUBufferUsage.COPY_DST}),
    };
    d.queue.writeBuffer(this.b.deformParams, 0, new Uint32Array([V, 0, 0, 0]));
    const enc = d.createCommandEncoder();
    enc.copyBufferToBuffer(m.uni, 0, this.b.uniRest, 0, m.uni.size);
    enc.copyBufferToBuffer(m.sites, 0, this.b.sitesRest, 0, m.sites.size);
    d.queue.submit([enc.finish()]);

    const hairModule = await loadModule(d, 'hair.wgsl');
    const deformModule = await loadModule(d, 'deform.wgsl');
    const pipe = (module, entryPoint) => d.createComputePipeline({label: entryPoint, layout: 'auto', compute: {module, entryPoint}});
    this.p = {
      substep: pipe(hairModule, 'substep'),
      grab: pipe(hairModule, 'grab_begin'),
      reset: pipe(hairModule, 'reset_state'),
      deform: pipe(deformModule, 'deform'),
    };
    const group = (pipeline, entries) => d.createBindGroup({layout: pipeline.getBindGroupLayout(0),
      entries: Object.entries(entries).map(([k, buffer]) => ({binding: Number(k), resource: {buffer}}))});
    const B = this.b;
    this.g = {
      substep: group(this.p.substep, {0: B.params, 1: B.offsets, 2: B.rest4, 3: B.aux, 4: B.grabBase, 5: B.xs, 6: B.vs, 7: B.sdf, 8: B.stats}),
      grab: group(this.p.grab, {0: B.params, 1: B.offsets, 2: B.rest4, 3: B.aux, 4: B.grabBase, 5: B.xs, 8: B.stats}),
      reset: group(this.p.reset, {0: B.params, 2: B.rest4, 3: B.aux, 5: B.xs, 6: B.vs}),
      deform: group(this.p.deform, {0: B.deformParams, 1: B.rows, 2: B.xs, 3: B.rest4, 4: B.uniRest, 5: m.uni,
                                    6: B.sitesRest, 7: m.sites, 8: m.endpoints}),
    };
    this.writeParams(0);
  }

  destroy() {
    if (!this.b) return;
    for (const b of Object.values(this.b)) b.destroy();
    this.b = null;
  }

  writeParams(h, n = 1) {
    const P = this.params, m = this.metres, meta = this.meta;
    const data = new ArrayBuffer(PARAM_BYTES);
    const f = new Float32Array(data), u = new Uint32Array(data);
    u[0] = this.S; u[1] = this.V; u[2] = this.grabbing ? 1 : 0; u[3] = this.wind ? 1 : 0;
    f[4] = h; f[5] = Math.exp(-P.damping * h); f[6] = P.drag; f[7] = P.bending;
    f[8] = P.styleRoot; f[9] = P.styleTip; f[10] = P.styleRange; f[11] = P.stiffK;
    f[12] = P.correction; f[13] = m; f[14] = this.time; f[15] = 1;
    f.set(this.delta, 16);
    f.set(this.windVector || [0, 0, 0], 20);
    f.set([...meta.sdf_origin, 1 / meta.sdf_voxel], 24);
    u.set([...meta.sdf_shape, 0], 28);
    f.set([...(this.grabPoint || [0, 0, 0]), P.grabM * m], 32);
    this.device.queue.writeBuffer(this.b.params, 0, data);
  }

  // Wind from the camera's left, across the head (as in the WebGL demo).
  setWind(on, camera) {
    this.wind = on;
    if (on) this.wake();
    this.aimWind(camera);
  }

  aimWind(camera) {
    if (!this.wind || !camera) { this.windVector = [0, 0, 0]; return; }
    const r = camera.right, f = camera.forward;
    const w = [r[0] + 0.4 * f[0], r[1] + 0.4 * f[1], r[2] + 0.4 * f[2]];
    const l = Math.hypot(...w) || 1;
    const s = this.params.windSpeed * this.metres / l;
    this.windVector = w.map((c) => c * s);
  }

  wake() {
    this.active = true;
    this.quiet = 0;
  }

  // Encode the substeps of one frame, then the deformation of the rows.
  encodeStep(encoder, frameDt) {
    const h = this.params.substep;
    const sim = Math.min(Math.max(frameDt, 1 / 240), 1 / 30);
    const n = Math.max(1, Math.min(8, Math.round(sim / h)));
    this.time += n * h;
    this.writeParams(h, n);
    this.device.queue.writeBuffer(this.b.stats, 0, new Uint32Array([0, 0, 0, 0]));
    const pass = encoder.beginComputePass({label: 'hair'});
    pass.setPipeline(this.p.substep);
    pass.setBindGroup(0, this.g.substep);
    for (let k = 0; k < n; k++) pass.dispatchWorkgroups(Math.ceil(this.S / 64));
    this.encodeDeformInPass(pass);
    pass.end();
    this.frameCount++;
    if (!this.statsPending && this.frameCount % 6 === 0) {
      encoder.copyBufferToBuffer(this.b.stats, 0, this.b.statsRead, 0, 16);
      this.statsPending = 'copy';
    }
    this.lastDt = n * h;
  }

  encodeDeformInPass(pass) {
    pass.setPipeline(this.p.deform);
    pass.setBindGroup(0, this.g.deform);
    pass.dispatchWorkgroups(...gridOf(Math.ceil(this.V / 256)));
  }

  // Call after the submit of a frame that ran encodeStep.
  afterSubmit() {
    if (this.statsPending !== 'copy') return;
    this.statsPending = 'map';
    const dt = this.lastDt || 1 / 60;
    this.b.statsRead.mapAsync(GPUMapMode.READ).then(() => {
      const a = new Float32Array(this.b.statsRead.getMappedRange().slice(0));
      this.b.statsRead.unmap();
      this.statsPending = false;
      const speed = Math.sqrt(a[0]) / this.metres;   // m/s
      const offset = Math.sqrt(a[1]) / this.metres;  // m
      this.lastStats = {speed, offset};
      if (this.grabbing || this.wind || speed > 0.004) { this.quiet = 0; return; }
      this.quiet += 6 * dt;
      if (this.quiet > 0.8) {
        this.active = false;
        // Back at rest within half a millimetre: snap to the exact trained hair.
        if (offset < 0.0005) this.snapToRest = true;
      }
    }).catch(() => { this.statsPending = false; });
  }

  // x = x0, v = 0, rows = their rest values bit for bit.
  encodeReset(encoder) {
    this.grabbing = false;
    this.writeParams(this.params.substep);
    const pass = encoder.beginComputePass({label: 'hair reset'});
    pass.setPipeline(this.p.reset);
    pass.setBindGroup(0, this.g.reset);
    pass.dispatchWorkgroups(...gridOf(Math.ceil(this.V / 256)));
    this.encodeDeformInPass(pass);
    pass.end();
    this.active = false;
    this.snapToRest = false;
  }

  // ---- grab -----------------------------------------------------------------
  // Pick the nearest strand vertex under the cursor (render pixels). Returns true on a hit.
  async begin(px, py, radiusPx) {
    const hit = await this.picker.pick('v', px, py, radiusPx);
    if (!hit) return false;
    this.grabPoint = hit.point;
    this.delta = [0, 0, 0];
    this.grabbing = true;
    this.writeParams(this.params.substep);
    const enc = this.device.createCommandEncoder({label: 'grab'});
    const pass = enc.beginComputePass();
    pass.setPipeline(this.p.grab);
    pass.setBindGroup(0, this.g.grab);
    pass.dispatchWorkgroups(Math.ceil(this.S / 64));
    pass.end();
    this.device.queue.submit([enc.finish()]);
    this.wake();
    return true;
  }

  // Cursor ray (world origin, unit direction) and camera forward: the target is on the
  // plane through the grab point, parallel to the image.
  move(origin, dir, forward) {
    if (!this.grabbing) return;
    const p = this.grabPoint;
    const denom = dir[0] * forward[0] + dir[1] * forward[1] + dir[2] * forward[2];
    if (Math.abs(denom) < 1e-6) return;
    const t = ((p[0] - origin[0]) * forward[0] + (p[1] - origin[1]) * forward[1] + (p[2] - origin[2]) * forward[2]) / denom;
    const target = [origin[0] + t * dir[0], origin[1] + t * dir[1], origin[2] + t * dir[2]];
    this.delta = [target[0] - p[0], target[1] - p[1], target[2] - p[2]];
    this.wake();
  }

  end() {
    this.grabbing = false;
    this.wake();
  }
}
