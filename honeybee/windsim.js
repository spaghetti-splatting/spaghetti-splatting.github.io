// Wind option: a live wind simulation on the fur graph (gpu2/shaders/windsim.wgsl).
// Data: <model>/windsim/ (sim.json, x_rest.f32, free*.f32/u32, adj*.f32/u32, rows.u32, row_nodes.u32).
// Fixed substep dt = 1 / (fps * substeps). Each display frame runs floor(elapsed * fps * substeps) substeps of the
// real time since the last frame, at most 8. The sim time t of a substep is (step mod period) * dt.
// Switch-on from rest: x = x_rest, v = 0, t = 0. Wind off: the wind goes to 0 and the fur settles for 4 s; then the
// rest endpoints and frame quaternions come back bit for bit and the simulation stops.
// The data loads without progress lines, so the loading screen (loader.js) stays closed.

import {loadModule, gridOf, readBuffer} from './gpu2/viewer.js';
import {fetchBytes} from './model.js';

const STORAGE = GPUBufferUsage.STORAGE;
const COPY_SRC = GPUBufferUsage.COPY_SRC;
const COPY_DST = GPUBufferUsage.COPY_DST;
const SLOT = 256;           // byte stride of the substep parameters (uniform offset alignment)
const PARAM_BYTES = 48;     // SimParams of windsim.wgsl
const MAX_SUBSTEPS = 8;     // substeps per display frame
const SETTLE_MS = 4000;     // wind off: settle time before the rest values come back
const TURB_REF = 0.7;       // turbulence of the ea_k modes in sim.json

export class WindSim {
  constructor(device) {
    this.device = device;
    this.on = false;          // the wind blows
    this.running = false;     // the simulation runs: wind on, or the settle time after the switch-off
    this.strength = 1;
    this.turbulence = TURB_REF;
    this.step = 0;            // substep counter, mod the period
    this.acc = 0;             // real time not simulated yet (s)
    this.clock = 0;           // performance.now() of the last frame
    this.offAt = 0;           // performance.now() at the switch-off
  }

  async load(model) {
    const d = this.device, m = model.buffers;
    const base = `${window.KC_DATA}${model.name}/windsim/`;
    const response = await fetch(base + 'sim.json', {cache: 'no-store'});
    if (!response.ok) throw new Error(`${base}sim.json: ${response.status}`);
    const meta = await response.json();
    if (meta.N !== model.rows) throw new Error(`sim.json: ${meta.N} rows, the model has ${model.rows}`);
    if (meta.pbd_iters % 2) throw new Error(`sim.json: pbd_iters ${meta.pbd_iters} is odd`);
    const {G, F, R, E2, K} = meta;
    const files = [['x_rest.f32', 12 * G], ['free.u32', 4 * F], ['free_chi.f32', 4 * F], ['free_n.f32', 12 * F],
      ['free_deg.f32', 4 * F], ['adj_off.u32', 4 * (F + 1)], ['adj.u32', 4 * E2], ['adj_l0.f32', 4 * E2],
      ['adj_inv.f32', 4 * E2], ['rows.u32', 4 * R], ['row_nodes.u32', 8 * R]];
    const data = await Promise.all(files.map(([file, bytes]) => fetchBytes(base + file, bytes)));
    const [xRest, free, chi, normal, deg, adjOff, adj, l0, inv, rows, rowNodes] = data;
    // w0; (kvec_k, phase_k); (ea_k, 2 pi freq_k).
    const modes = new Float32Array(4 * (1 + 2 * K));
    modes.set(meta.w0, 0);
    for (let k = 0; k < K; k++) {
      modes.set([...meta.kvec[k], meta.phase[k]], 4 * (1 + k));
      modes.set([...meta.ea[k], 2 * Math.PI * meta.freq[k]], 4 * (1 + K + k));
    }
    const buffer = (label, size, usage) => d.createBuffer({label, size: Math.max(16, size), usage});
    const upload = (label, bytes, usage = STORAGE | COPY_DST) => {
      const b = buffer(label, bytes.byteLength, usage);
      d.queue.writeBuffer(b, 0, bytes);
      return b;
    };
    const B = this.b = {
      params: buffer('windsim params', SLOT * MAX_SUBSTEPS, GPUBufferUsage.UNIFORM | COPY_DST),
      modes: upload('windsim modes', modes),
      xRest: upload('windsim x rest', xRest, STORAGE | COPY_DST | COPY_SRC),
      xa: upload('windsim x a', xRest, STORAGE | COPY_DST | COPY_SRC),
      xb: upload('windsim x b', xRest, STORAGE | COPY_DST | COPY_SRC),
      free: upload('windsim free', free),
      chi: upload('windsim chi', chi),
      normal: upload('windsim n', normal),
      deg: upload('windsim deg', deg),
      adjOff: upload('windsim adj off', adjOff),
      adj: upload('windsim adj', adj),
      l0: upload('windsim l0', l0),
      inv: upload('windsim inv', inv),
      vel: buffer('windsim v', 12 * F, STORAGE | COPY_DST),
      xOld: buffer('windsim x0', 12 * F, STORAGE),
      rows: upload('windsim rows', rows),
      rowNodes: upload('windsim row nodes', rowNodes, STORAGE | COPY_DST | COPY_SRC),
      endsRest: buffer('endpoints rest', m.endpoints.size, STORAGE | COPY_DST | COPY_SRC),
      uniRest: buffer('uni rest', m.uni.size, STORAGE | COPY_DST | COPY_SRC),
    };
    const encoder = d.createCommandEncoder({label: 'windsim rest copy'});
    encoder.copyBufferToBuffer(m.endpoints, 0, B.endsRest, 0, m.endpoints.size);
    encoder.copyBufferToBuffer(m.uni, 0, B.uniRest, 0, m.uni.size);
    d.queue.submit([encoder.finish()]);
    const module = await loadModule(d, 'windsim.wgsl');
    const pipe = (entryPoint) => d.createComputePipeline({label: entryPoint, layout: 'auto', compute: {module, entryPoint}});
    this.p = {node: pipe('node_step'), jacobi: pipe('jacobi'), velocity: pipe('velocity'), rows: pipe('rows_out')};
    const params = (k) => ({buffer: B.params, offset: k * SLOT, size: PARAM_BYTES});
    const group = (pipeline, entries) => d.createBindGroup({layout: pipeline.getBindGroupLayout(0),
      entries: Object.entries(entries).map(([k, r]) => ({binding: Number(k), resource: r.buffer ? r : {buffer: r}}))});
    this.g = {
      node: [...Array(MAX_SUBSTEPS).keys()].map((k) => group(this.p.node,
        {0: params(k), 1: B.modes, 2: B.xRest, 3: B.free, 4: B.chi, 5: B.normal, 11: B.xa, 14: B.vel, 15: B.xOld})),
      jacobi: [[B.xa, B.xb], [B.xb, B.xa]].map(([src, dst]) => group(this.p.jacobi,
        {0: params(0), 3: B.free, 6: B.deg, 7: B.adjOff, 8: B.adj, 9: B.l0, 10: B.inv, 12: src, 13: dst})),
      velocity: group(this.p.velocity, {0: params(0), 3: B.free, 12: B.xa, 14: B.vel, 15: B.xOld}),
      rows: group(this.p.rows, {0: params(0), 2: B.xRest, 12: B.xa, 16: B.rows, 17: B.rowNodes, 18: B.endsRest,
                                19: B.uniRest, 20: m.endpoints, 21: m.uni}),
    };
    this.meta = meta;
    this.base = base;
    this.model = model;
    this.rate = meta.fps * meta.substeps;
    this.dt = 1 / this.rate;
    this.period = Math.round(meta.period_s * this.rate);
    this.writeParams(MAX_SUBSTEPS, 0, this.turbulence);
  }

  // Parameters of the next n substeps: wind strength s, turbulence turb.
  writeParams(n, s, turb) {
    const meta = this.meta;
    const data = new ArrayBuffer(SLOT * n);
    for (let k = 0; k < n; k++) {
      const f = new Float32Array(data, k * SLOT, PARAM_BYTES / 4), u = new Uint32Array(data, k * SLOT, PARAM_BYTES / 4);
      f[0] = ((this.step + k) % this.period) * this.dt;
      f[1] = s;
      f[2] = turb / TURB_REF;
      f[3] = this.dt;
      f[4] = meta.c_drag;
      f[5] = meta.k_rest;
      u[6] = meta.F;
      u[7] = meta.K;
      u[8] = meta.R;
    }
    this.device.queue.writeBuffer(this.b.params, 0, data);
  }

  // n substeps (n <= 8), then the moving rows.
  encodeSteps(encoder, n, s, turb) {
    const meta = this.meta;
    this.writeParams(n, s, turb);
    const grid = gridOf(Math.ceil(meta.F / 256));
    const pass = encoder.beginComputePass({label: 'windsim'});
    for (let k = 0; k < n; k++) {
      pass.setPipeline(this.p.node);
      pass.setBindGroup(0, this.g.node[k]);
      pass.dispatchWorkgroups(...grid);
      pass.setPipeline(this.p.jacobi);
      for (let it = 0; it < meta.pbd_iters; it++) {
        pass.setBindGroup(0, this.g.jacobi[it & 1]);
        pass.dispatchWorkgroups(...grid);
      }
      pass.setPipeline(this.p.velocity);
      pass.setBindGroup(0, this.g.velocity);
      pass.dispatchWorkgroups(...grid);
    }
    pass.setPipeline(this.p.rows);
    pass.setBindGroup(0, this.g.rows);
    pass.dispatchWorkgroups(...gridOf(Math.ceil(meta.R / 256)));
    pass.end();
    this.step = (this.step + n) % this.period;
  }

  setOn(on) {
    if (on && !this.running) {
      this.running = true;
      this.step = 0;
      this.acc = 0;
      this.clock = performance.now();
    }
    if (!on && this.on) this.offAt = performance.now();
    this.on = on;
  }

  // One display frame at the time now (performance.now() clock).
  encode(encoder, now) {
    if (!this.on && now - this.offAt >= SETTLE_MS) {
      this.encodeRestore(encoder);
      return;
    }
    this.acc += Math.max(0, now - this.clock) / 1000;
    this.clock = now;
    let n = Math.floor(this.acc * this.rate);
    if (n > MAX_SUBSTEPS) {
      n = MAX_SUBSTEPS;
      this.acc = 0;
    } else {
      this.acc -= n / this.rate;
    }
    if (n > 0) this.encodeSteps(encoder, n, this.on ? this.strength : 0, this.turbulence);
  }

  // x = x_rest, v = 0, t = 0.
  encodeReset(encoder) {
    const B = this.b;
    encoder.copyBufferToBuffer(B.xRest, 0, B.xa, 0, B.xRest.size);
    encoder.copyBufferToBuffer(B.xRest, 0, B.xb, 0, B.xRest.size);
    encoder.clearBuffer(B.vel);
    this.step = 0;
  }

  // The rest endpoints and frame quaternions, bit for bit; the simulation stops at rest.
  encodeRestore(encoder) {
    const m = this.model.buffers;
    encoder.copyBufferToBuffer(this.b.endsRest, 0, m.endpoints, 0, m.endpoints.size);
    encoder.copyBufferToBuffer(this.b.uniRest, 0, m.uni, 0, m.uni.size);
    this.encodeReset(encoder);
    this.running = false;
  }

  // Test hook (main.js, ?windsim_test=<substeps>): from rest, strength 1, turbulence 0.7, t from 0, run the
  // substeps, read (x - x_rest) at the row nodes back as [R, 6] and compare it with ref_disp600.f32.
  async test(steps) {
    const d = this.device, meta = this.meta, R = meta.R;
    this.running = false;
    this.on = false;
    let encoder = d.createCommandEncoder({label: 'windsim test reset'});
    this.encodeReset(encoder);
    d.queue.submit([encoder.finish()]);
    const t0 = performance.now();
    for (let done = 0; done < steps; done += MAX_SUBSTEPS) {
      encoder = d.createCommandEncoder({label: 'windsim test'});
      this.encodeSteps(encoder, Math.min(MAX_SUBSTEPS, steps - done), 1, TURB_REF);
      d.queue.submit([encoder.finish()]);
    }
    await d.queue.onSubmittedWorkDone();
    const ms = performance.now() - t0;
    const x = new Float32Array(await readBuffer(d, this.b.xa, 12 * meta.G));
    const xr = new Float32Array(await readBuffer(d, this.b.xRest, 12 * meta.G));
    const nodes = new Uint32Array(await readBuffer(d, this.b.rowNodes, 8 * R));
    const ref = new Float32Array(await fetchBytes(this.base + 'ref_disp600.f32', 24 * R));
    const err = new Float32Array(6 * R), mag = new Float32Array(6 * R);
    for (let r = 0; r < R; r++) {
      for (let j = 0; j < 2; j++) {
        const g = nodes[2 * r + j];
        for (let c = 0; c < 3; c++) {
          const k = 6 * r + 3 * j + c;
          err[k] = Math.abs(Math.fround(x[3 * g + c] - xr[3 * g + c]) - ref[k]);
          mag[k] = Math.abs(ref[k]);
        }
      }
    }
    err.sort();
    mag.sort();
    const q = (a, p) => a[Math.min(a.length - 1, Math.floor(p * a.length))];
    return {steps, rows: R, nodes: meta.G, free: meta.F, max_abs_err: err[err.length - 1], p99_abs_err: q(err, 0.99),
            p50_abs_err: q(err, 0.5), median_abs_ref: q(mag, 0.5), gpu_wall_ms: Math.round(ms)};
  }

  destroy() {
    for (const b of Object.values(this.b || {})) b.destroy();
    this.b = null;
  }
}
