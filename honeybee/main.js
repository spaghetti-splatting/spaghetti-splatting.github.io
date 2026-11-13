// Kernel Curves WebGPU viewer: page, frame loop, scene loading.
//
// Rendering: George's WGSL port of the colour-only CUDA evaluation render
// (gpu2/viewer.js, gpu2/shaders: the Gaussian passes of gpu/ unchanged, plus
// the Beta kernel and the tube texture of the code tree 7cdb6976 for the
// teaser export). This file adds the navigation
// (nav.js), the hair simulation and grab (hair.js), GPU picking (pick.js), a
// scaled present pass, adaptive resolution, and the UI.

import {createDevice, GpuContext, loadModule} from './gpu2/viewer.js';
import {ViewerRenderer, SLOT, PAIR_CAPACITY} from './model.js';
import {Navigation, v3} from './nav.js';
import {Picker} from './pick.js';
import {HairSim, hairBytes} from './hair.js';
import {ShotTool} from './shot.js';
import {Gs3dRenderer, isGs3d} from './gs3d.js';
import {WindSim} from './windsim.js';

const $ = (id) => document.getElementById(id);
const params = new URLSearchParams(location.search);
const MAX_PIXELS = 4.2e6;
// Resolution options with a fixed number of render rows (George 2026-11-12).
const FIXED_ROWS = {'720p': 720, '480p': 480, '360p': 360};

function displayName(id) {
  let m = id.match(/^geomhair(\d+)_/);
  if (m) return `Hair · GeomHair ${m[1]}`;
  m = id.match(/^yuksel_w?([a-z]+)_/);
  if (m) return `Hair · Yuksel ${m[1]}`;
  if (id === 'tweet_a7rv_g8_3dgs') return 'Scene · Spaghetti tweet · 3DGS (authors\' model)';
  if (id.startsWith('tweet_a7rv_g8')) return 'Scene · Spaghetti tweet (A7R V group 8, all views)';
  if (id.startsWith('teaser_a7rv_g8')) return 'Scene · Teaser spaghetti (A7R V group 8)';
  if (id.startsWith('spaghetti_videomodel')) return 'Scene · Spaghetti (video model)';
  if (id.startsWith('a7rv')) return 'Scene · A7R V capture';
  if (id.startsWith('garden')) return 'Scene · Garden';
  if (id.startsWith('bonsai')) return 'Scene · Bonsai';
  if (id.startsWith('honeybee')) return 'Scene · Honeybee';
  return id;
}

const ui = {
  progress: (t) => { $('progress').textContent = t; },
  warn: (t) => { $('warning').textContent = t || ''; },
  toast(text, ms = 4000) {
    const el = $('toast');
    el.textContent = text;
    el.classList.remove('hidden', 'fade');
    clearTimeout(this._t1); clearTimeout(this._t2);
    this._t1 = setTimeout(() => el.classList.add('fade'), ms);
    this._t2 = setTimeout(() => el.classList.add('hidden'), ms + 700);
  },
};

class App {
  async init() {
    const {device, adapterName, timestamps} = await createDevice();
    this.device = device;
    this.adapterName = adapterName;
    device.addEventListener('uncapturederror', (e) => { console.error(e.error.message); ui.warn(`WebGPU error: ${e.error.message}`); });
    device.lost.then((info) => ui.progress(`error: the GPU device was lost (${info.message}). Reload the page.`));
    this.ctx = await new GpuContext(device).init();
    this.renderer = await new ViewerRenderer(device, this.ctx, timestamps).init();
    this.curveRenderer = this.renderer;
    this.timestamps = timestamps;
    this.picker = await new Picker(device, this.renderer).init();
    this.canvas = $('view');
    this.format = navigator.gpu.getPreferredCanvasFormat();
    this.context = this.canvas.getContext('webgpu');
    this.context.configure({device, format: this.format, alphaMode: 'opaque'});
    const present = await loadModule(device, 'present.wgsl');
    this.present = device.createRenderPipeline({
      label: 'present', layout: 'auto',
      vertex: {module: present, entryPoint: 'present_vertex'},
      fragment: {module: present, entryPoint: 'present_fragment', targets: [{format: this.format}]},
      primitive: {topology: 'triangle-list'},
    });
    this.presentParams = device.createBuffer({size: 16, usage: GPUBufferUsage.UNIFORM | GPUBufferUsage.COPY_DST});
    this.countsRead = device.createBuffer({size: 16, usage: GPUBufferUsage.MAP_READ | GPUBufferUsage.COPY_DST});
    this.countsPending = false;
    this.nav = new Navigation(this.canvas);
    this.nav.picker = (x, y) => this.pickPoint(x, y);
    this.nav.onInput = () => { this.lastInput = performance.now(); if (this.shot?.playing) this.shot.stop(); };
    const res = params.get('res');
    this.quality = res === 'full' ? '1' : (['1', '0.75', '0.5'].includes(res) || FIXED_ROWS[res] ? res : 'auto');
    $('quality').value = this.quality;
    this.autoScale = 0.75;
    this.frameMs = [];
    this.gpuMs = 16;
    this.inFlight = false;
    this.lastKey = '';
    this.grabTool = true;
    this.viewIndex = -1;
    const view = params.get('view');
    this.viewMode = view === 'primitives' || view === 'render' ? view : 'split';   // George 2026-11-12: split view on at load; ?view=render gives the render
    this.viewBeforeSplit = 'render';
    this.splitAt = 0.5;   // divider position, fraction of the canvas width
    this.bindUi();
    this.toast = (t, ms) => ui.toast(t, ms);
    this.shot = new ShotTool(this);
    this.names = await (await fetch(window.KC_DATA + 'models.json', {cache: 'no-store'})).json();
    const sel = $('scene');
    for (const n of this.names) sel.add(new Option(displayName(n), n));
    const want = params.get('scene');
    const w = (want || '#').toLowerCase();
    const pick = this.names.find((n) => n === want) || this.names.find((n) => n.toLowerCase().startsWith(w))
      || this.names.find((n) => displayName(n).toLowerCase().includes(w));
    sel.value = pick || this.names[0];
    await this.loadScene(sel.value);
    this.last = performance.now();
    requestAnimationFrame((t) => this.tick(t));
  }

  // ---- scenes ---------------------------------------------------------------
  async loadScene(name) {
    // Switching to the paired scene (ours <-> 3DGS) keeps the camera.
    const keep = this.model && this.model.header.pair === name ? {nav: this.nav.state(), view: this.viewIndex} : null;
    this.loading = true;
    this.model = null;
    const header = await (await fetch(`${window.KC_DATA}${name}/header.json`, {cache: 'no-store'})).json();
    await this.useRenderer(isGs3d(header));
    if (this.hair) { this.hair.destroy(); this.hair = null; }
    if (this.graphWind) { this.graphWind.destroy(); this.graphWind = null; }
    $('wind-loop').checked = false;
    this.nav.grabber = null;
    $('hair-tools').classList.add('hidden');
    const hairInfo = await hairBytes(name);
    const model = await this.renderer.loadModel(name, ui.progress, hairInfo ? hairInfo.bytes : 0);
    if (hairInfo) {
      this.hair = new HairSim(this.device, this.renderer, this.picker);
      await this.hair.load(name, hairInfo.meta, model.reportBytes);
    }
    this.picker.setSources({endpoints: model.buffers.endpoints, amplitude: model.buffers.amplitude, rows: model.rows,
                            xs: this.hair ? this.hair.b.xs : null, vertices: this.hair ? this.hair.V : 0});
    // Focus threshold: the median amplitude of the rows.
    const amp = model.amplitudeSample;
    this.focusAmplitude = amp[Math.floor(0.5 * amp.length)];
    this.setupCamera(model, hairInfo ? hairInfo.meta : null);
    if (keep) {
      Object.assign(this.nav, keep.nav);
      this.nav.changed();
      this.viewIndex = keep.view;
      this.updateViewLabel();
    }
    this.model = model;
    // The primitive view needs primitive_view.json; other models show the render.
    this.setView(model.buffers.primShade ? this.viewMode : 'render');
    this.loading = false;
    this.lastKey = '';
    const kind = this.hair ? 'hair' : 'scene';
    $('hair-tools').classList.toggle('hidden', !this.hair);
    this.updateGrabber();
    await this.shot.loadScene(model.header.shots_scene || name, model);
    this.updatePairButton(model);
    if (params.get('shot') === '1') this.shot.toggle(true);
    $('info').textContent = `${model.rows.toLocaleString()} ${isGs3d(model.header) ? 'Gaussians (3DGS)' : 'segments'}${this.hair ? ` · ${this.hair.S.toLocaleString()} strands simulated` : ''} · ${this.adapterName}`;
    ui.progress(`loaded ${name}: ${model.rows} rows, ${model.cameras.length} cameras`);
    history.replaceState(null, '', `?scene=${encodeURIComponent(name)}${this.nav.mode === 'walk' ? '&mode=walk' : ''}${this.shot.open ? '&shot=1' : ''}${params.get('wind') === '0' ? '&wind=0' : ''}`);
    if (keep) ui.toast(isGs3d(model.header) ? 'Now: 3DGS (authors\' model), same camera' : 'Now: our renderer, same camera', 2500);
    else if (kind === 'hair') ui.toast('Drag a strand to pull the hair · drag the background to turn · wheel to zoom', 6000);
    else ui.toast('Drag to turn · right drag to pan · wheel to zoom · Tab for walk mode (WASD)', 6000);
    // Wind on from the start (George 2026-11-12), the path of the checkbox; ?wind=0 keeps it off.
    // Test hook ?windsim_test=<substeps>: the comparison with the torch reference; the wind stays off.
    const windTest = Number(params.get('windsim_test'));
    if (windTest > 0) this.windTest(windTest);
    else if (params.get('wind') !== '0') {
      $('wind-loop').checked = true;
      this.setGraphWind(true).catch((err) => { $('wind-loop').checked = false; ui.toast(`Wind off: ${err.message || err}`, 4000); });
    }
  }

  // The curve renderer or the 3DGS renderer; the other one frees its model.
  async useRenderer(gs) {
    if (gs && !this.gsRenderer) this.gsRenderer = await new Gs3dRenderer(this.device, this.timestamps).init();
    const next = gs ? this.gsRenderer : this.curveRenderer;
    const other = gs ? this.curveRenderer : this.gsRenderer;
    if (other) other.releaseModel();
    // One set of sort pair buffers (6 x 64 MB) for both renderers.
    if (this.gsRenderer) {
      if (!this.gsRenderer.pairs && this.curveRenderer.pairs) this.gsRenderer.pairs = this.curveRenderer.pairs;
      if (gs) { this.gsRenderer.ensurePairs(); this.curveRenderer.pairs = this.gsRenderer.pairs; }
    }
    this.renderer = next;
    this.picker.renderer = next;
    this.presentBuffer = null;
  }

  updatePairButton(model) {
    const b = $('btn-pair');
    const pair = model.header.pair;
    b.classList.toggle('hidden', !pair || !this.names.includes(pair));
    b.textContent = isGs3d(model.header) ? '⇄ Ours' : '⇄ 3DGS';
  }

  togglePair() {
    const pair = this.model?.header.pair;
    if (!pair || !this.names.includes(pair) || this.loading) return;
    $('scene').value = pair;
    this.loadScene(pair).catch((err) => ui.progress(`error: ${err.message || err}`));
  }

  setupCamera(model, hairMeta) {
    const nav = this.nav;
    const cams = model.cameras;
    // Scene up: the mean camera up (-y axis of the COLMAP cameras).
    let up = [0, 0, 0];
    for (const c of cams) { const v = c.view_matrix; up = v3.sub(up, [v[1], v[5], v[9]]); }
    nav.setUp(v3.len(up) > 0.3 * cams.length ? up : [0, 1, 0]);
    const start = cams.find((c) => c.split === 'test') || cams[0];
    this.viewIndex = cams.indexOf(start);
    // Distances from the opening camera to the sampled midpoints.
    const pos = start.campos;
    const v = start.view_matrix;
    const fwd = [v[2], v[6], v[10]];
    const dists = [], ahead = [];
    for (const m of model.mids) {
      const d = v3.sub(m, pos);
      const dist = v3.len(d);
      dists.push(dist);
      if (v3.dot(d, fwd) > 0.97 * dist) ahead.push(v3.dot(d, fwd));
    }
    dists.sort((a, b) => a - b);
    ahead.sort((a, b) => a - b);
    const median = dists[Math.floor(dists.length / 2)] || 1;
    let pivotDist = ahead.length > 20 ? ahead[Math.floor(ahead.length * 0.4)] : median;
    let pivot = v3.add(pos, v3.scale(fwd, pivotDist));
    if (hairMeta) {
      // Hair: orbit about the head centre.
      const c = model.bounds.center;
      pivotDist = Math.max(0.1, v3.dot(v3.sub(c, pos), fwd));
      pivot = v3.add(pos, v3.scale(fwd, pivotDist));
    }
    nav.sceneScale = pivotDist;
    nav.moveSpeed = 0.25 * median;   // SwitchSplat calibrated walking: 0.25 x median distance per second
    nav.setFromRecord(start, pivot);
    nav.fovy = Math.max(nav.fovy, 30 * Math.PI / 180);
    nav.setMode(params.get('mode') === 'walk' ? 'walk' : 'orbit');
    $('mode-orbit').classList.toggle('on', nav.mode === 'orbit');
    $('mode-walk').classList.toggle('on', nav.mode === 'walk');
    $('fov').value = Math.round(nav.fovy * 180 / Math.PI);
    nav.remember();
    this.updateViewLabel();
  }

  goToView(step) {
    const cams = this.model?.cameras;
    if (!cams) return;
    this.viewIndex = (this.viewIndex + step + cams.length) % cams.length;
    const c = cams[this.viewIndex];
    const v = c.view_matrix;
    const a = this.nav.anglesFromForward([v[2], v[6], v[10]], [v[0], v[4], v[8]]);
    const fwd = v3.norm([v[2], v[6], v[10]]);
    const pivot = v3.add(c.campos, v3.scale(fwd, this.nav.sceneScale));
    this.nav.flyTo({position: [...c.campos], pivot, yaw: a.yaw, pitch: a.pitch, roll: a.roll, fovy: c.FoVy}, 0.8);
    this.updateViewLabel();
  }

  updateViewLabel() {
    const cams = this.model?.cameras || [];
    const c = cams[this.viewIndex];
    $('view-label').textContent = c ? `${c.split} ${this.viewIndex + 1}/${cams.length}` : 'view';
  }

  updateGrabber() {
    if (!this.hair || !this.grabTool) { this.nav.grabber = null; return; }
    const hair = this.hair;
    this.nav.grabber = {
      begin: (x, y) => {
        const s = this.renderScaleOf();
        return hair.begin(x * s.x, y * s.y, 14 * s.x).then((hit) => {
          if (hit) this.canvas.classList.add('dragging');
          return hit;
        });
      },
      move: (x, y) => hair.move(this.nav.position, this.nav.ray(x, y), this.nav.axes().forward),
      end: () => { hair.end(); this.canvas.classList.remove('dragging'); },
    };
  }

  // Render pixels per CSS pixel of the last rendered frame.
  renderScaleOf() {
    const size = this.renderer.size;
    const cw = this.canvas.clientWidth || 1, ch = this.canvas.clientHeight || 1;
    return size ? {x: size.width / cw, y: size.height / ch} : {x: 1, y: 1};
  }

  async pickPoint(x, y) {
    if (!this.model) return null;
    const s = this.renderScaleOf();
    const hit = await this.picker.pick('r', x * s.x, y * s.y, 6 * s.x, this.focusAmplitude);
    return hit ? hit.point : null;
  }

  // ---- frame loop -------------------------------------------------------------
  renderSize(scale, rows = 0) {
    const dpr = Math.min(window.devicePixelRatio || 1, 2);
    const cw = Math.max(1, Math.round(this.canvas.clientWidth * dpr));
    const ch = Math.max(1, Math.round(this.canvas.clientHeight * dpr));
    if (this.canvas.width !== cw || this.canvas.height !== ch) { this.canvas.width = cw; this.canvas.height = ch; }
    let s = rows ? Math.min(1, rows / ch) : scale;   // fixed rows: never more rows than the canvas
    if (cw * ch * s * s > MAX_PIXELS) s = Math.sqrt(MAX_PIXELS / (cw * ch));
    return {w: Math.max(16, Math.round(cw * s)), h: Math.max(16, Math.round(ch * s)), cw, ch};
  }

  tick(now) {
    requestAnimationFrame((t) => this.tick(t));
    const dt = Math.min(0.1, (now - this.last) / 1000);
    this.last = now;
    if (!this.model || this.loading) return;
    this.shot.beforeFrame(dt);
    if (this.nav.update(dt)) this.lastMotion = now;
    const hair = this.hair;
    const interacting = this.nav.pointers.size > 0 || now - (this.lastMotion || 0) < 220;
    const wind = this.graphWind;
    const simulating = !!(hair && hair.active) || !!(wind && wind.running);
    const moving = interacting || simulating || this.nav.flight || this.shot.playing;
    // Quantized, so the render buffers (reallocated on a size change) change rarely.
    const rows = FIXED_ROWS[this.quality] || 0;
    const scale = this.quality === 'auto' ? (moving ? Math.round(this.autoScale * 10) / 10 : 1) : (rows ? 1 : Number(this.quality));
    const {w, h, cw, ch} = this.renderSize(scale, rows);
    const key = `${this.nav.version}|${w}x${h}|${cw}x${ch}`;
    const snap = hair && hair.snapToRest;
    if (!simulating && !snap && key === this.lastKey && !this.forceFrame) return;
    if (this.inFlight) return;
    this.shot.drawOverlay();
    if (this.inFlight) return;
    this.forceFrame = false;
    this.lastKey = key;
    const device = this.device;
    const camera = this.nav.camera(w, h);
    const encoder = device.createCommandEncoder({label: 'frame'});
    if (hair) {
      if (snap || this.resetHair) { hair.encodeReset(encoder); this.resetHair = false; }
      else if (simulating) { hair.aimWind(camera); hair.encodeStep(encoder, dt); }
    }
    if (wind && wind.running) wind.encode(encoder, now);
    // Split view: the primitive view left of the divider, the render right of it.
    const split = this.viewMode === 'split' && this.renderer === this.curveRenderer;
    if (split) this.renderer.viewMode = 'primitives';
    this.renderer.encodeFrame(encoder, camera);
    device.queue.writeBuffer(this.presentParams, 0, new Uint32Array([w, h, cw, ch]));
    if (this.presentKey !== `${w}x${h}` || this.presentBuffer !== this.renderer.size.outColor) {
      this.presentBuffer = this.renderer.size.outColor;
      this.presentKey = `${w}x${h}`;
      this.presentGroup = device.createBindGroup({layout: this.present.getBindGroupLayout(0), entries: [
        {binding: 0, resource: {buffer: this.presentBuffer}}, {binding: 1, resource: {buffer: this.presentParams}}]});
    }
    const target = this.context.getCurrentTexture().createView();
    const pass = encoder.beginRenderPass({colorAttachments: [{view: target,
      loadOp: 'clear', storeOp: 'store', clearValue: {r: 0, g: 0, b: 0, a: 1}}]});
    pass.setPipeline(this.present);
    pass.setBindGroup(0, this.presentGroup);
    const cut = split ? Math.round(this.splitAt * this.canvas.width) : 0;
    if (split) pass.setScissorRect(0, 0, cut, this.canvas.height);
    pass.draw(3);
    pass.end();
    if (split) {
      // Second frame at the same camera and viewport: the render, right of the divider.
      this.renderer.viewMode = 'render';
      this.renderer.encodeFrame(encoder, camera);
      this.renderer.viewMode = 'split';
      const right = encoder.beginRenderPass({colorAttachments: [{view: target, loadOp: 'load', storeOp: 'store'}]});
      right.setPipeline(this.present);
      right.setBindGroup(0, this.presentGroup);
      right.setScissorRect(cut, 0, this.canvas.width - cut, this.canvas.height);
      right.draw(3);
      right.end();
    }
    const readCounts = !this.countsPending && (this.frameNo = (this.frameNo || 0) + 1) % 20 === 1;
    if (readCounts) encoder.copyBufferToBuffer(this.renderer.ctx.counts, 0, this.countsRead, 0, 16);
    const t0 = performance.now();
    device.queue.submit([encoder.finish()]);
    this.inFlight = true;
    if (hair && simulating) hair.afterSubmit();
    device.queue.onSubmittedWorkDone().then(() => {
      this.inFlight = false;
      const ms = performance.now() - t0;
      this.onFrameDone(ms, moving, w, h);
    });
    if (readCounts) {
      this.countsPending = true;
      this.countsRead.mapAsync(GPUMapMode.READ).then(() => {
        const c = new Uint32Array(this.countsRead.getMappedRange().slice(0));
        this.countsRead.unmap();
        this.countsPending = false;
        this.kept = c[SLOT.KEPT];
        this.pairs = c[SLOT.PAIRS_RAW];
        if (this.pairs > PAIR_CAPACITY) {
          ui.warn(`${this.pairs.toLocaleString()} tile pairs exceed the capacity; lowering the resolution`);
          this.autoScale = Math.max(0.35, this.autoScale * 0.8);
          if (this.quality !== 'auto') { this.quality = 'auto'; $('quality').value = 'auto'; }
          this.forceFrame = true;
        } else ui.warn('');
      }).catch(() => { this.countsPending = false; });
    }
  }

  onFrameDone(ms, moving, w, h) {
    this.gpuMs = 0.8 * this.gpuMs + 0.2 * ms;
    if (moving && this.quality === 'auto') {
      if (ms > 30) this.autoScale = Math.max(0.35, this.autoScale * 0.9);
      else if (ms < 15) this.autoScale = Math.min(1, this.autoScale * 1.06);
    }
    const now = performance.now();
    this.frameMs.push(now);
    while (this.frameMs.length && now - this.frameMs[0] > 1000) this.frameMs.shift();
    if (!this._statT || now - this._statT > 250) {
      this._statT = now;
      const hz = this.frameMs.length;
      const hair = this.hair;
      const sim = hair && hair.active ? ` · sim ${hair.lastStats.speed.toFixed(2)} m/s` : '';
      $('fps').textContent = `${moving ? hz : '—'} fps · ${ms.toFixed(1)} ms · ${w}×${h}` +
        (this.kept ? ` · ${this.kept.toLocaleString()} kept · ${(this.pairs / 1e6).toFixed(1)}M pairs` : '') + sim;
    }
  }

  // ---- UI -------------------------------------------------------------------------
  setMode(mode) {
    this.nav.setMode(mode);
    $('mode-orbit').classList.toggle('on', mode === 'orbit');
    $('mode-walk').classList.toggle('on', mode === 'walk');
    if (mode === 'walk') ui.toast('Walk: W A S D to move, Q E down / up, drag to look, Shift 3×', 3500);
  }

  // Split view (V): the primitive view left, the render right. V again returns to the view before.
  toggleSplit() {
    if (this.viewMode === 'split') { this.setView(this.viewBeforeSplit); return; }
    this.viewBeforeSplit = this.viewMode;
    this.setView('split');
  }

  // View (P): the trained render, or Yizheng's primitive view for a model
  // with primitive_view.json.
  setView(mode) {
    const has = !!(this.model && this.model.buffers.primShade);
    if ((mode === 'primitives' || mode === 'split') && !has) {
      if (this.model) ui.toast('This model has no primitive view', 2500);
      mode = 'render';
    }
    this.viewMode = mode;
    this.curveRenderer.viewMode = mode;
    $('split-ui').classList.toggle('hidden', mode !== 'split');
    $('view-mode').value = mode;
    $('view-mode').disabled = !has;
    this.forceFrame = true;
  }

  bindUi() {
    $('scene').addEventListener('change', (e) => this.loadScene(e.target.value).catch((err) => ui.progress(`error: ${err.message || err}`)));
    $('mode-orbit').onclick = () => this.setMode('orbit');
    $('mode-walk').onclick = () => this.setMode('walk');
    $('btn-home').onclick = () => this.nav.reset();
    $('btn-pair').onclick = () => this.togglePair();
    $('btn-full').onclick = () => this.toggleFull();
    $('btn-help').onclick = () => $('help').classList.toggle('hidden');
    $('help').onclick = () => $('help').classList.add('hidden');
    $('view-prev').onclick = () => this.goToView(-1);
    $('view-next').onclick = () => this.goToView(1);
    $('fov').oninput = (e) => {
      if (this.shot?.open) { this.shot.fovx = Number(e.target.value); this.nav.changed(); return; }
      this.nav.fovy = Number(e.target.value) * Math.PI / 180; this.nav.changed();
    };
    $('quality').onchange = (e) => { this.quality = e.target.value; this.forceFrame = true; this.canvas.focus(); };
    $('view-mode').onchange = (e) => { this.setView(e.target.value); this.canvas.focus({preventScroll: true}); };
    $('wind-loop').onchange = (e) => {
      this.setGraphWind(e.target.checked).catch((err) => ui.toast(`Wind: ${err.message || err}`, 4000));
      this.canvas.focus({preventScroll: true});
    };
    $('tool-grab').onclick = () => this.toggleGrab();
    $('tool-wind').onclick = () => this.toggleWind();
    $('tool-reset').onclick = () => { this.resetHair = true; this.setWind(false); };
    $('grab-size').oninput = (e) => {
      const cm = Number(e.target.value);
      $('grab-size-v').textContent = `${cm} cm`;
      if (this.hair) this.hair.params.grabM = cm / 100;
    };
    for (const id of ['mode-orbit', 'mode-walk', 'btn-home', 'btn-pair', 'tool-grab', 'tool-wind', 'tool-reset', 'view-prev', 'view-next']) {
      $(id).addEventListener('click', () => this.canvas.focus({preventScroll: true}));
    }
    // Split divider: a pointer drag (mouse or touch) moves it. The camera does not move.
    const divider = $('split-divider');
    const moveSplit = (e) => {
      const r = this.canvas.getBoundingClientRect();
      this.splitAt = Math.min(0.95, Math.max(0.05, (e.clientX - r.left) / (r.width || 1)));
      $('split-ui').style.setProperty('--split', `${this.splitAt * 100}%`);
      this.forceFrame = true;
    };
    divider.addEventListener('pointerdown', (e) => {
      e.preventDefault(); e.stopPropagation();
      divider.setPointerCapture(e.pointerId);
      moveSplit(e);
    });
    divider.addEventListener('pointermove', (e) => {
      if (!divider.hasPointerCapture(e.pointerId)) return;
      e.preventDefault(); e.stopPropagation();
      moveSplit(e);
    });
    for (const type of ['pointerup', 'pointercancel']) {
      divider.addEventListener(type, (e) => {
        e.stopPropagation();
        if (divider.hasPointerCapture(e.pointerId)) divider.releasePointerCapture(e.pointerId);
      });
    }
    document.addEventListener('keydown', (e) => {
      if (e.target instanceof HTMLInputElement || e.target instanceof HTMLSelectElement) return;
      if (e.metaKey || e.ctrlKey || e.altKey) return;
      if (this.shot?.onKey(e)) { e.preventDefault(); return; }
      if (e.code === 'KeyC' && this.shot) { this.shot.toggle(); return; }
      switch (e.code) {
        case 'Tab': e.preventDefault(); this.setMode(this.nav.mode === 'orbit' ? 'walk' : 'orbit'); break;
        case 'KeyR': this.nav.reset(); break;
        case 'KeyT': this.togglePair(); break;
        case 'KeyF': this.toggleFull(); break;
        case 'KeyH': $('help').classList.toggle('hidden'); break;
        case 'Escape': $('help').classList.add('hidden'); break;
        case 'KeyG': if (this.hair) this.toggleGrab(); break;
        case 'KeyB': if (this.hair) this.toggleWind(); break;
        case 'KeyX': if (this.hair) { this.resetHair = true; this.setWind(false); } break;
        case 'KeyP': this.setView(this.viewMode === 'primitives' ? 'render' : 'primitives'); break;
        case 'KeyV': this.toggleSplit(); break;
        default: break;
      }
    });
    window.addEventListener('resize', () => { this.forceFrame = true; });
  }

  toggleGrab() {
    this.grabTool = !this.grabTool;
    $('tool-grab').classList.toggle('on', this.grabTool);
    this.updateGrabber();
  }

  setWind(on) {
    if (!this.hair) return;
    this.hair.setWind(on, this.nav.camera(16, 16));
    $('tool-wind').classList.toggle('on', on);
  }

  toggleWind() {
    this.setWind(!(this.hair && this.hair.wind));
  }

  // The live wind simulation of the model (windsim.js). Its data loads at the first use, with no line in
  // #progress, so the loading screen stays closed. Null while a load runs or after a failed load.
  async windSim() {
    if (this.graphWind) return this.graphWind;
    if (this.windLoading || !this.model) return null;
    this.windLoading = true;
    const wind = new WindSim(this.device);
    try {
      await wind.load(this.model);
    } catch (err) {
      wind.destroy();
      $('wind-loop').checked = false;
      ui.toast(`No wind for this model: ${err.message || err}`, 4000);
      return null;
    } finally {
      this.windLoading = false;
    }
    this.graphWind = wind;
    return wind;
  }

  // Wind (checkbox): the live wind simulation.
  async setGraphWind(on) {
    if (on && !this.graphWind) {
      if (!(await this.windSim())) return;
      on = $('wind-loop').checked;
    }
    const wind = this.graphWind;
    if (!wind) return;
    wind.setOn(on);
    $('wind-loop').checked = on;
    this.forceFrame = true;
  }

  // Test hook (?windsim_test=<substeps>): the result goes to the console and to the hidden element #windsim-test.
  async windTest(steps) {
    let text;
    try {
      const wind = await this.windSim();
      text = wind ? JSON.stringify(await wind.test(steps)) : 'error: no wind data';
    } catch (err) {
      text = `error: ${err.message || err}`;
    }
    console.log(`windsim_test ${text}`);
    const el = document.createElement('pre');
    el.id = 'windsim-test';
    el.className = 'hidden';
    el.textContent = text;
    document.body.appendChild(el);
  }

  toggleFull() {
    if (document.fullscreenElement) document.exitFullscreen();
    else document.documentElement.requestFullscreen?.();
  }
}

const app = new App();
window.__kc = app;  // test hook (tools/cdp_smoke.py)
app.init().catch((error) => {
  console.error(error);
  ui.progress(`error: ${error.message || error}`);
});
