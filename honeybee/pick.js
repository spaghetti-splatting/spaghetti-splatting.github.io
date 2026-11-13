// GPU picking (gpu2/shaders/pick.wgsl): the nearest candidate to the camera
// under the cursor, in the camera of the last rendered frame.

import {loadModule, gridOf} from './gpu2/viewer.js';

export class Picker {
  constructor(device, renderer) {
    this.device = device;
    this.renderer = renderer;
  }

  async init() {
    const d = this.device;
    const module = await loadModule(d, 'pick.wgsl');
    const make = (entryPoint) => d.createComputePipeline({label: entryPoint, layout: 'auto', compute: {module, entryPoint}});
    this.pipes = {
      v: [make('pick_v_depth'), make('pick_v_index'), make('pick_v_point')],
      r: [make('pick_r_depth'), make('pick_r_index'), make('pick_r_point')],
    };
    this.params = d.createBuffer({size: 32, usage: GPUBufferUsage.UNIFORM | GPUBufferUsage.COPY_DST});
    this.result = d.createBuffer({size: 32, usage: GPUBufferUsage.STORAGE | GPUBufferUsage.COPY_DST | GPUBufferUsage.COPY_SRC});
    this.staging = d.createBuffer({size: 32, usage: GPUBufferUsage.MAP_READ | GPUBufferUsage.COPY_DST});
    this.busy = null;
    this.groups = {};
    return this;
  }

  // Sources: rows of the model, and optionally the hair vertex buffer.
  setSources({endpoints, amplitude, rows, xs = null, vertices = 0}) {
    const d = this.device;
    const cam = this.renderer.cameraBuffer;
    const entries = (pipe, extra) => d.createBindGroup({layout: pipe.getBindGroupLayout(0), entries: [
      {binding: 0, resource: {buffer: this.params}},
      {binding: 1, resource: {buffer: cam}},
      {binding: 2, resource: {buffer: this.result}},
      ...extra]});
    this.groups.r = this.pipes.r.map((p) => entries(p, [
      {binding: 4, resource: {buffer: endpoints}}, {binding: 5, resource: {buffer: amplitude}}]));
    this.counts = {r: rows, v: vertices};
    this.groups.v = xs ? this.pipes.v.map((p) => entries(p, [{binding: 3, resource: {buffer: xs}}])) : null;
  }

  // mode 'r' (rows) or 'v' (hair vertices). x, y, radius in render pixels.
  async pick(mode, x, y, radius, minAmplitude = 0) {
    if (!this.groups[mode]) return null;
    while (this.busy) await this.busy;
    let release;
    this.busy = new Promise((r) => { release = r; });
    try {
      const d = this.device;
      const count = this.counts[mode];
      const p = new ArrayBuffer(32);
      const f = new Float32Array(p);
      const u = new Uint32Array(p);
      f[0] = x; f[1] = y; f[2] = radius; f[3] = minAmplitude; u[4] = count;
      d.queue.writeBuffer(this.params, 0, p);
      d.queue.writeBuffer(this.result, 0, new Uint32Array([0xffffffff, 0xffffffff, 0, 0, 0, 0, 0, 0]));
      const enc = d.createCommandEncoder({label: 'pick'});
      const pass = enc.beginComputePass();
      const grid = gridOf(Math.ceil(count / 256));
      for (let k = 0; k < 3; k++) {
        pass.setPipeline(this.pipes[mode][k]);
        pass.setBindGroup(0, this.groups[mode][k]);
        pass.dispatchWorkgroups(...grid);
      }
      pass.end();
      enc.copyBufferToBuffer(this.result, 0, this.staging, 0, 32);
      d.queue.submit([enc.finish()]);
      await this.staging.mapAsync(GPUMapMode.READ);
      const out = new ArrayBuffer(32);
      new Uint8Array(out).set(new Uint8Array(this.staging.getMappedRange()));
      this.staging.unmap();
      const ou = new Uint32Array(out);
      const of = new Float32Array(out);
      if (ou[1] === 0xffffffff) return null;
      return {index: ou[1], depth: of[0], point: [of[2], of[3], of[4]]};
    } finally {
      this.busy = null;
      release();
    }
  }
}
