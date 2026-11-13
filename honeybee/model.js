// Model loading for the viewer: George's Renderer (gpu2/viewer.js) with a
// streaming loadModel that reports bytes, so the spaghetti loader shows real
// progress, and that keeps a small CPU sample of the segment midpoints for the
// navigation (scene scale, walking speed, opening pivot).
// The files, the GPU buffers and the bind groups are those of
// Renderer.loadModel (Renderer.modelFiles, prepareModel, installModel), so a
// Beta / Textured export (code tree 7cdb6976) loads as a Gaussian one does.

import {Renderer, SLOT, PAIR_CAPACITY, modelFiles} from './gpu2/viewer.js';

const STORAGE = GPUBufferUsage.STORAGE;
const COPY_SRC = GPUBufferUsage.COPY_SRC;
const COPY_DST = GPUBufferUsage.COPY_DST;
const BUFFER_ALL = STORAGE | COPY_DST | COPY_SRC;
const SAMPLE = 60000;

// float16 bits -> float32 value, for the .f16 files of a float16 export.
let HALF_TABLE = null;
function halfTable() {
  if (HALF_TABLE) return HALF_TABLE;
  HALF_TABLE = new Float32Array(65536);
  for (let h = 0; h < 65536; h++) {
    const s = h & 0x8000 ? -1 : 1, e = (h >> 10) & 0x1f, m = h & 0x3ff;
    HALF_TABLE[h] = e === 0 ? s * m * 2 ** -24 : e === 31 ? (m ? NaN : s * Infinity) : s * (1 + m / 1024) * 2 ** (e - 15);
  }
  return HALF_TABLE;
}

export function halfToFloat(bytes) {
  const u = new Uint16Array(bytes);
  const t = halfTable();
  const out = new Float32Array(u.length);
  for (let i = 0; i < u.length; i++) out[i] = t[u[i]];
  return out;
}

function makeBuffer(device, size, usage, label) {
  return device.createBuffer({label, size: Math.max(4, Math.ceil(size / 4) * 4), usage});
}

// Fetch a file into a new ArrayBuffer of a known size, reporting bytes.
export async function fetchBytes(url, expected, onBytes) {
  const response = await fetch(url);
  if (!response.ok) throw new Error(`fetch ${url}: ${response.status}`);
  if (!response.body || !expected) {
    const data = await response.arrayBuffer();
    onBytes?.(data.byteLength);
    return data;
  }
  const out = new Uint8Array(expected);
  const reader = response.body.getReader();
  let offset = 0;
  for (;;) {
    const {done, value} = await reader.read();
    if (done) break;
    if (offset + value.byteLength > expected) throw new Error(`${url}: more than ${expected} bytes`);
    out.set(value, offset);
    offset += value.byteLength;
    onBytes?.(value.byteLength);
  }
  if (offset !== expected) throw new Error(`${url}: ${offset} bytes, expected ${expected}`);
  return out.buffer;
}

export class ViewerRenderer extends Renderer {
  // progress(text) gets "loading <name>: a / b MB (a/b)" lines, the format of loader.js.
  async loadModel(name, progress, extraBytes = 0) {
    const device = this.device;
    const base = `${window.KC_DATA}${name}/`;
    const header = await (await fetch(base + 'header.json')).json();
    const cameras = await (await fetch(base + 'cameras.json')).json();
    const rows = header.N;
    await this.prepareModel(header);
    const files = modelFiles(header);
    // Optional primitive view: primitive_view.json and its [N, 8] float32 file
    // (prototyping/honeybee_yz_primitive_bake.py of the tubes worktree), or its
    // float16 copy (.f16, prototyping/honeybee_yz_webgpu_f16_export.py).
    const viewResponse = await fetch(base + 'primitive_view.json');
    const primView = viewResponse.ok ? await viewResponse.json() : null;
    if (primView && primView.rows !== rows) {
      throw new Error(`primitive_view.json: ${primView.rows} rows, the model has ${rows}`);
    }
    const primF16 = !!primView && primView.file.endsWith('.f16');
    const primBytes = primView ? rows * 8 * (primF16 ? 2 : 4) : 0;
    const model = {name, header, cameras, rows, buffers: {}, primView};
    const f16 = header.f16_files || {};
    const zero = new Set(header.omitted_zero_files || []);
    const bytesOf = (file, w, count) => zero.has(file) ? 0 : (f16[file] ? 2 : 4) * w * count;
    const total = files.reduce((s, [, file, w, count]) => s + bytesOf(file, w, count), 0) + primBytes + extraBytes;
    let loaded = 0;
    const mb = (b) => Math.round(b / 1048576);
    const report = () => progress(`loading ${name}: ${mb(loaded)} / ${mb(total)} MB (${mb(loaded)}/${Math.max(1, mb(total))})`);
    model.reportBytes = (b) => { loaded += b; report(); };
    report();
    for (const [key, file, width, count] of files) {
      const size = count * width * 4;
      const buffer = makeBuffer(device, size, BUFFER_ALL, file);
      model.buffers[key] = buffer;
      if (zero.has(file)) continue;   // createBuffer gives zeros
      let data;
      if (f16[file]) data = halfToFloat(await fetchBytes(base + f16[file], size / 2, model.reportBytes)).buffer;
      else data = await fetchBytes(base + file, size, model.reportBytes);
      device.queue.writeBuffer(buffer, 0, data);
      if (key === 'endpoints') this.sampleGeometry(model, new Float32Array(data));
      if (key === 'amplitude') model.amplitudeSample = sampleOf(new Float32Array(data), 20000);
    }
    if (primView) {
      let data = await fetchBytes(base + primView.file, primBytes, model.reportBytes);
      if (primF16) data = halfToFloat(data).buffer;
      const buffer = makeBuffer(device, data.byteLength, BUFFER_ALL, primView.file);
      device.queue.writeBuffer(buffer, 0, data);
      model.buffers.primShade = buffer;
    }
    this.installModel(model);
    return model;
  }

  // Bounds and a midpoint sample (every k-th row).
  sampleGeometry(model, ep) {
    const rows = model.rows;
    const step = Math.max(1, Math.floor(rows / SAMPLE));
    const mids = [];
    const lo = [Infinity, Infinity, Infinity];
    const hi = [-Infinity, -Infinity, -Infinity];
    for (let r = 0; r < rows; r += step) {
      const o = 6 * r;
      const m = [0.5 * (ep[o] + ep[o + 3]), 0.5 * (ep[o + 1] + ep[o + 4]), 0.5 * (ep[o + 2] + ep[o + 5])];
      if (!Number.isFinite(m[0] + m[1] + m[2])) continue;
      mids.push(m);
      for (let c = 0; c < 3; c++) { lo[c] = Math.min(lo[c], m[c]); hi[c] = Math.max(hi[c], m[c]); }
    }
    model.mids = mids;
    model.bounds = {lo, hi, center: [0, 1, 2].map((c) => 0.5 * (lo[c] + hi[c]))};
  }
}

function sampleOf(a, n) {
  const step = Math.max(1, Math.floor(a.length / n));
  const out = [];
  for (let i = 0; i < a.length; i += step) out.push(a[i]);
  return out.sort((x, y) => x - y);
}

export {SLOT, PAIR_CAPACITY};
