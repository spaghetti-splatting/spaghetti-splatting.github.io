// Shot tool: camera view finding and keyframed camera paths for video shots.
//
// The 16:9 frame in the middle of the canvas is the 1920 x 1080 image of the
// video scripts (George's spaghetti tweet: fixed horizontal field of view,
// principal point at the centre). Its horizontal field of view is `fovx`; the
// canvas fovy is set every frame so that the frame has exactly that fovx.
//
// A pose is {p: camera centre, q: unit quaternion [w, x, y, z] of the
// camera-to-world rotation with OpenCV axes (x right, y down, z forward),
// fovx: degrees}. The camera-to-world 4 x 4 matrix of a pose is the "cams"
// layout of the tweet scripts (cams_v11.npz).
//
// A path has keys (poses). Interpolation: centripetal Catmull-Rom for the
// centre, Catmull-Rom in the quaternion group (Barry-Goldman pyramid of
// slerps) for the rotation, Catmull-Rom of log fovx. Timing: the path is
// reparametrized by a cost arc length (translation divided by the distance to
// the focus point + rotation angle + |d log fovx|), so the screen motion is
// close to constant; a trapezoidal speed profile adds ease in / out ramps.
// "Frame per key" timing puts every key at its own frame number; the cost between keys follows a monotone cubic of the
// frame number, so the speed stays continuous.
// A path imported from a cams file is "dense": one pose per frame, read-only.

import {v3} from './nav.js';

const $ = (id) => document.getElementById(id);
const DEG = Math.PI / 180;
export const TWEET_FOVX = 0.6879178028352678 / DEG;   // tweet_timeline_v4.py: fovx of the 1920 x 1080 frames
const ASPECT = 16 / 9;
const MODULES = {
  m01: {label: 'm01 orbit · frames 0–150', start: 0, end: 150},
  m02: {label: 'm02 zoom · frames 150–360', start: 150, end: 360},
  m09: {label: 'm09 fly-through · frames 1140–1320', start: 1140, end: 1320},
};

// ---- quaternions [w, x, y, z] ----------------------------------------------
const q = {
  mul: (a, b) => [a[0] * b[0] - a[1] * b[1] - a[2] * b[2] - a[3] * b[3],
                  a[0] * b[1] + a[1] * b[0] + a[2] * b[3] - a[3] * b[2],
                  a[0] * b[2] - a[1] * b[3] + a[2] * b[0] + a[3] * b[1],
                  a[0] * b[3] + a[1] * b[2] - a[2] * b[1] + a[3] * b[0]],
  conj: (a) => [a[0], -a[1], -a[2], -a[3]],
  dot: (a, b) => a[0] * b[0] + a[1] * b[1] + a[2] * b[2] + a[3] * b[3],
  norm: (a) => { const l = Math.hypot(a[0], a[1], a[2], a[3]) || 1; return a.map((x) => x / l); },
  log(a) {  // unit quaternion -> rotation vector / 2
    const s = Math.hypot(a[1], a[2], a[3]);
    if (s < 1e-12) return [0, 0, 0];
    const th = Math.atan2(s, a[0]);
    return [a[1] * th / s, a[2] * th / s, a[3] * th / s];
  },
  exp(v) {
    const th = Math.hypot(v[0], v[1], v[2]);
    if (th < 1e-12) return [1, v[0], v[1], v[2]];
    const s = Math.sin(th) / th;
    return [Math.cos(th), v[0] * s, v[1] * s, v[2] * s];
  },
  // a (a^-1 b)^t, also for t outside [0, 1]; shortest arc.
  slerp(a, b, t) {
    if (q.dot(a, b) < 0) b = b.map((x) => -x);
    const l = q.log(q.mul(q.conj(a), b));
    return q.norm(q.mul(a, q.exp([l[0] * t, l[1] * t, l[2] * t])));
  },
  angle: (a, b) => 2 * Math.acos(Math.min(1, Math.abs(q.dot(a, b)))),
  // Columns: right, down, forward (camera-to-world rotation).
  fromAxes(r, d, f) {
    const m00 = r[0], m01 = d[0], m02 = f[0], m10 = r[1], m11 = d[1], m12 = f[1], m20 = r[2], m21 = d[2], m22 = f[2];
    const tr = m00 + m11 + m22;
    let w, x, y, z;
    if (tr > 0) { const s = 2 * Math.sqrt(tr + 1); w = s / 4; x = (m21 - m12) / s; y = (m02 - m20) / s; z = (m10 - m01) / s; }
    else if (m00 > m11 && m00 > m22) { const s = 2 * Math.sqrt(1 + m00 - m11 - m22); w = (m21 - m12) / s; x = s / 4; y = (m01 + m10) / s; z = (m02 + m20) / s; }
    else if (m11 > m22) { const s = 2 * Math.sqrt(1 + m11 - m00 - m22); w = (m02 - m20) / s; x = (m01 + m10) / s; y = s / 4; z = (m12 + m21) / s; }
    else { const s = 2 * Math.sqrt(1 + m22 - m00 - m11); w = (m10 - m01) / s; x = (m02 + m20) / s; y = (m12 + m21) / s; z = s / 4; }
    return q.norm([w, x, y, z]);
  },
  axes(a) {
    const [w, x, y, z] = a;
    return {
      right: [1 - 2 * (y * y + z * z), 2 * (x * y + w * z), 2 * (x * z - w * y)],
      down: [2 * (x * y - w * z), 1 - 2 * (x * x + z * z), 2 * (y * z + w * x)],
      forward: [2 * (x * z + w * y), 2 * (y * z - w * x), 1 - 2 * (x * x + y * y)],
    };
  },
};

export function poseToC2W(pose) {
  const {right: r, down: d, forward: f} = q.axes(pose.q);
  return [[r[0], d[0], f[0], pose.p[0]], [r[1], d[1], f[1], pose.p[1]], [r[2], d[2], f[2], pose.p[2]], [0, 0, 0, 1]];
}

function c2wToPose(m, fovx) {
  return {p: [m[0][3], m[1][3], m[2][3]], q: q.fromAxes([m[0][0], m[1][0], m[2][0]], [m[0][1], m[1][1], m[2][1]],
    [m[0][2], m[1][2], m[2][2]]), fovx};
}

// ---- spline evaluation --------------------------------------------------------
// Centripetal Catmull-Rom (alpha 0.5) of points P0..P3 on the segment P1 -> P2.
function catmullRom(P0, P1, P2, P3, t) {
  const kn = (a, b) => Math.max(1e-6, Math.sqrt(v3.len(v3.sub(b, a))));
  const t0 = 0, t1 = t0 + kn(P0, P1), t2 = t1 + kn(P1, P2), t3 = t2 + kn(P2, P3);
  const u = t1 + (t2 - t1) * t;
  const L = (A, B, ta, tb) => v3.lerp(A, B, (u - ta) / (tb - ta));
  const A1 = L(P0, P1, t0, t1), A2 = L(P1, P2, t1, t2), A3 = L(P2, P3, t2, t3);
  const B1 = L(A1, A2, t0, t2), B2 = L(A2, A3, t1, t3);
  return L(B1, B2, t1, t2);
}

function quatCR(Q0, Q1, Q2, Q3, t) {
  const A1 = q.slerp(Q0, Q1, t + 1), A2 = q.slerp(Q1, Q2, t), A3 = q.slerp(Q2, Q3, t - 1);
  const B1 = q.slerp(A1, A2, (t + 1) / 2), B2 = q.slerp(A2, A3, t / 2);
  return q.slerp(B1, B2, t);
}

function scalarCR(a, b, c, d, t) {
  const t2 = t * t, t3 = t2 * t;
  return 0.5 * (2 * b + (-a + c) * t + (2 * a - 5 * b + 4 * c - d) * t2 + (-a + 3 * b - 3 * c + d) * t3);
}

// Point closest (least squares) to the optical axes of the keys.
function focusOf(keys) {
  const A = [[0, 0, 0], [0, 0, 0], [0, 0, 0]], b = [0, 0, 0];
  for (const k of keys) {
    const f = q.axes(k.q).forward;
    for (let i = 0; i < 3; i++) for (let j = 0; j < 3; j++) {
      const m = (i === j ? 1 : 0) - f[i] * f[j];
      A[i][j] += m; b[i] += m * k.p[j];
    }
  }
  const det = A[0][0] * (A[1][1] * A[2][2] - A[1][2] * A[2][1]) - A[0][1] * (A[1][0] * A[2][2] - A[1][2] * A[2][0])
    + A[0][2] * (A[1][0] * A[2][1] - A[1][1] * A[2][0]);
  if (keys.length < 2 || Math.abs(det) < 1e-6 * keys.length ** 3) return null;
  const inv = (r, c) => {
    const rr = [0, 1, 2].filter((x) => x !== c), cc = [0, 1, 2].filter((x) => x !== r);
    const s = ((r + c) % 2 ? -1 : 1);
    return s * (A[rr[0]][cc[0]] * A[rr[1]][cc[1]] - A[rr[0]][cc[1]] * A[rr[1]][cc[0]]) / det;
  };
  return [0, 1, 2].map((i) => inv(i, 0) * b[0] + inv(i, 1) * b[1] + inv(i, 2) * b[2]);
}

// Trapezoidal speed profile: progress s(tau) with ramps of length r at both ends.
function trapezoid(tau, r) {
  if (r <= 0) return tau;
  r = Math.min(0.5, r);
  const v = 1 / (1 - r);
  if (tau < r) return v * tau * tau / (2 * r);
  if (tau > 1 - r) { const e = 1 - tau; return 1 - v * e * e / (2 * r); }
  return v * (tau - r / 2);
}

// Monotone cubic (Fritsch-Carlson) interpolation of y(x) at x0: the speed is continuous at the keys and the camera
// never moves backwards along the path.
function pchip(xs, ys, x0) {
  const n = xs.length;
  const h = [], d = [];
  for (let i = 0; i < n - 1; i++) { h.push(xs[i + 1] - xs[i]); d.push((ys[i + 1] - ys[i]) / h[i]); }
  const m = new Array(n).fill(0);
  if (n === 2) { m[0] = m[1] = d[0]; } else {
    for (let i = 1; i < n - 1; i++) {
      if (d[i - 1] * d[i] <= 0) m[i] = 0;
      else { const w1 = 2 * h[i] + h[i - 1], w2 = h[i] + 2 * h[i - 1]; m[i] = (w1 + w2) / (w1 / d[i - 1] + w2 / d[i]); }
    }
    const end = (h0, h1, d0, d1) => {
      let v = ((2 * h0 + h1) * d0 - h0 * d1) / (h0 + h1);
      if (Math.sign(v) !== Math.sign(d0)) v = 0;
      else if (Math.sign(d0) !== Math.sign(d1) && Math.abs(v) > Math.abs(3 * d0)) v = 3 * d0;
      return v;
    };
    m[0] = end(h[0], h[1], d[0], d[1]);
    m[n - 1] = end(h[n - 2], h[n - 3], d[n - 2], d[n - 3]);
  }
  let i = 0;
  while (i < n - 2 && x0 > xs[i + 1]) i++;
  const t = (x0 - xs[i]) / h[i], t2 = t * t, t3 = t2 * t;
  return (2 * t3 - 3 * t2 + 1) * ys[i] + (t3 - 2 * t2 + t) * h[i] * m[i] + (-2 * t3 + 3 * t2) * ys[i + 1] + (t3 - t2) * h[i] * m[i + 1];
}

// Pose of a keyed path at the parameter u in [0, K-1].
function evalKeys(keys, u) {
  const K = keys.length;
  if (K === 1) return {...keys[0]};
  const i = Math.min(K - 2, Math.max(0, Math.floor(u)));
  const t = u - i;
  const P = (j) => {
    if (j < 0) return v3.sub(v3.scale(keys[0].p, 2), keys[1].p);
    if (j >= K) return v3.sub(v3.scale(keys[K - 1].p, 2), keys[K - 2].p);
    return keys[j].p;
  };
  const Qs = keys.map((k) => k.q.slice());
  for (let j = 1; j < K; j++) if (q.dot(Qs[j], Qs[j - 1]) < 0) Qs[j] = Qs[j].map((x) => -x);
  const Q = (j) => {
    if (j < 0) return q.slerp(Qs[1], Qs[0], 2);
    if (j >= K) return q.slerp(Qs[K - 2], Qs[K - 1], 2);
    return Qs[j];
  };
  const F = (j) => Math.log(keys[Math.max(0, Math.min(K - 1, j))].fovx);
  return {
    p: catmullRom(P(i - 1), P(i), P(i + 1), P(i + 2), t),
    q: quatCR(Q(i - 1), Q(i), Q(i + 1), Q(i + 2), t),
    fovx: Math.exp(scalarCR(F(i - 1), F(i), F(i + 1), F(i + 2), t)),
  };
}

// Dense table of a keyed path: parameter u and cumulative cost.
function costTable(path, fallbackFocus) {
  const keys = path.keys;
  const K = keys.length;
  const focus = focusOf(keys) || fallbackFocus;
  const per = 120;
  const us = [], cost = [];
  let prev = null, c = 0;
  for (let i = 0; i <= per * (K - 1); i++) {
    const u = i / per;
    const pose = evalKeys(keys, u);
    if (prev) {
      const dist = Math.max(1e-3, v3.len(v3.sub(pose.p, focus)));
      c += v3.len(v3.sub(pose.p, prev.p)) / dist + q.angle(pose.q, prev.q) + Math.abs(Math.log(pose.fovx / prev.fovx));
    }
    us.push(u); cost.push(c); prev = pose;
  }
  return {us, cost, focus, keyCost: keys.map((_, j) => cost[j * per])};
}

function uAtCost(tab, c) {
  const {us, cost} = tab;
  let lo = 0, hi = cost.length - 1;
  if (c <= 0) return 0;
  if (c >= cost[hi]) return us[hi];
  while (hi - lo > 1) { const m = (lo + hi) >> 1; if (cost[m] < c) lo = m; else hi = m; }
  const w = (c - cost[lo]) / Math.max(1e-12, cost[hi] - cost[lo]);
  return us[lo] + (us[hi] - us[lo]) * w;
}

// Poses of all frames of a path.
export function samplePath(path, fallbackFocus = [0, 0, 0]) {
  const N = Math.max(2, path.frames | 0);
  if (path.dense) {
    const S = path.samples;
    return Array.from({length: N}, (_, f) => {
      const x = f * (S.length - 1) / (N - 1), i = Math.min(S.length - 2, Math.floor(x)), t = x - i;
      if (S.length === 1) return {...S[0]};
      return {p: v3.lerp(S[i].p, S[i + 1].p, t), q: q.slerp(S[i].q, S[i + 1].q, t), fovx: S[i].fovx + (S[i + 1].fovx - S[i].fovx) * t};
    });
  }
  const keys = path.keys;
  if (!keys.length) return [];
  if (keys.length === 1) return Array.from({length: N}, () => ({...keys[0]}));
  const tab = costTable(path, fallbackFocus);
  const total = tab.cost[tab.cost.length - 1];
  const out = [];
  const timed = path.timing === 'keys' && keys.every((k, j) => Number.isFinite(k.frame) && (j === 0 || k.frame > keys[j - 1].frame));
  for (let f = 0; f < N; f++) {
    let c;
    if (timed) {
      c = pchip(keys.map((k) => k.frame), tab.keyCost, Math.max(keys[0].frame, Math.min(keys[keys.length - 1].frame, f)));
    } else {
      c = total * trapezoid(f / (N - 1), path.ramp ?? 0.15);
    }
    out.push(evalKeys(keys, uAtCost(tab, c)));
  }
  out.focus = tab.focus;
  out.keyFrames = keys.map((_, j) => {
    // frame of key j under the current timing
    let best = 0, bd = Infinity;
    for (let f = 0; f < N; f++) {
      const d = v3.len(v3.sub(out[f].p, keys[j].p)) + q.angle(out[f].q, keys[j].q);
      if (d < bd) { bd = d; best = f; }
    }
    return best;
  });
  return out;
}

// ---- UI / state ---------------------------------------------------------------
const uid = () => Math.random().toString(36).slice(2, 8);

export class ShotTool {
  constructor(app) {
    this.app = app;
    this.open = false;
    this.fovx = TWEET_FOVX;
    this.doc = null;            // {scene, paths: [...], views: [...], current}
    this.refs = [];             // imported dense paths (read-only, from the server)
    this.playing = false;
    this.frame = 0;
    this.samples = null;
    this.show = {grid: true, path: true, cams: true};
    this.overlay = $('shot-overlay');
    this.octx = this.overlay.getContext('2d');
    this.saveTimer = null;
    this.status = '';
    this.bind();
  }

  get nav() { return this.app.nav; }
  get path() {
    const d = this.doc;
    if (!d) return null;
    return d.paths.find((p) => p.id === d.current) || this.refs.find((p) => p.id === d.current) || d.paths[0] || null;
  }

  // ---- scene load / persistence --------------------------------------------
  async loadScene(scene, model) {
    this.stop();
    this.scene = scene;
    this.model = model;
    this.capture = model.cameras.map((c) => c.campos);
    let doc = null;
    try {
      const r = await fetch(`api/shots/${encodeURIComponent(scene)}`, {cache: 'no-store'});
      if (r.ok) doc = await r.json();
    } catch (e) { /* offline: local only */ }
    if (!doc) {
      const local = localStorage.getItem(`kc-shots-${scene}`);
      doc = local ? JSON.parse(local) : null;
    }
    if (!doc || !doc.paths) doc = {scene, paths: [], views: [], current: null};
    if (!doc.paths.length) doc.paths.push(this.newPath('path 1'));
    doc.views = doc.views || [];
    this.doc = doc;
    if (!this.path) doc.current = doc.paths[0].id;
    try {
      const r = await fetch('api/refs', {cache: 'no-store'});
      this.refs = r.ok ? (await r.json()).map((x) => ({...x, id: `ref:${x.name}`, dense: true, ref: true})) : [];
    } catch (e) { this.refs = []; }
    this.resample();
    this.render();
  }

  newPath(name) {
    return {id: uid(), name, keys: [], frames: 150, ramp: 0.15, timing: 'constant', module: 'm01'};
  }

  touch() {
    this.resample();
    this.render();
    if (!this.doc) return;
    localStorage.setItem(`kc-shots-${this.scene}`, JSON.stringify(this.doc));
    clearTimeout(this.saveTimer);
    this.setStatus('saving…');
    this.saveTimer = setTimeout(() => this.save(), 700);
  }

  async save() {
    try {
      const r = await fetch(`api/shots/${encodeURIComponent(this.scene)}`, {method: 'POST',
        headers: {'Content-Type': 'application/json'}, body: JSON.stringify(this.doc)});
      if (!r.ok) throw new Error(`${r.status}`);
      this.setStatus(`saved ${new Date().toLocaleTimeString()}`);
    } catch (e) {
      this.setStatus(`server save failed (${e.message}); kept in this browser`);
    }
  }

  setStatus(t) { this.status = t; const el = $('shot-status'); if (el) el.textContent = t; }

  resample() {
    const p = this.path;
    this.samples = p ? samplePath(p, this.nav.pivot) : null;
    if (this.samples && this.frame >= this.samples.length) this.frame = this.samples.length - 1;
    this.app.forceFrame = true;
  }

  // ---- camera <-> pose ------------------------------------------------------
  currentPose() {
    const {right, down, forward} = this.nav.axes();
    return {p: [...this.nav.position], q: q.fromAxes(right, down, forward), fovx: this.fovx};
  }

  applyPose(pose, fly = 0) {
    const {right, forward} = q.axes(pose.q);
    const a = this.nav.anglesFromForward(forward, right);
    const focus = this.samples?.focus;
    const dist = focus ? Math.max(0.05, v3.dot(v3.sub(focus, pose.p), forward)) : this.nav.distance();
    const target = {position: [...pose.p], pivot: v3.add(pose.p, v3.scale(forward, dist)), yaw: a.yaw, pitch: a.pitch,
                    roll: a.roll, fovy: this.nav.fovy};
    this.fovx = pose.fovx;
    $('fov').value = Math.round(this.fovx);
    if (fly > 0) { this.nav.flyTo(target, fly); return; }
    this.nav.flight = null;
    Object.assign(this.nav, {position: target.position, pivot: target.pivot, yaw: a.yaw, pitch: a.pitch, roll: a.roll});
    this.nav.changed();
  }

  // The 16:9 frame in CSS pixels.
  frameRect() {
    const cw = this.app.canvas.clientWidth, ch = this.app.canvas.clientHeight;
    let w = cw, h = cw / ASPECT;
    if (h > ch) { h = ch; w = ch * ASPECT; }
    return {x: (cw - w) / 2, y: (ch - h) / 2, w, h, cw, ch};
  }

  // Called every frame before rendering: fovy from fovx, playback.
  beforeFrame(dt) {
    if (!this.open) return;
    const r = this.frameRect();
    const fovy = 2 * Math.atan(Math.tan(this.fovx * DEG / 2) * r.ch / r.w);
    if (Math.abs(fovy - this.nav.fovy) > 1e-7 && !this.nav.flight) { this.nav.fovy = fovy; this.nav.changed(); }
    if (this.playing && this.samples?.length) {
      this.playT += dt;
      const fps = this.path?.fps || 30;
      let f = Math.floor(this.playT * fps);
      if (f >= this.samples.length) {
        if ($('shot-loop').checked) { this.playT = 0; f = 0; } else { f = this.samples.length - 1; this.stop(); }
      }
      if (f !== this.frame || this.playing) { this.frame = f; this.applyPose(this.samples[f]); this.syncScrub(); }
    }
  }

  play() {
    if (!this.samples?.length) return;
    if (this.frame >= this.samples.length - 1) this.frame = 0;
    this.playing = true;
    this.playT = this.frame / (this.path?.fps || 30);
    $('shot-play').textContent = '❚❚';
  }

  stop() {
    this.playing = false;
    const b = $('shot-play');
    if (b) b.textContent = '▶';
  }

  syncScrub() {
    const n = this.samples?.length || 1;
    $('shot-scrub').max = n - 1;
    $('shot-scrub').value = this.frame;
    const p = this.path;
    const off = p && !p.ref && MODULES[p.module] ? MODULES[p.module].start : (p?.start || 0);
    $('shot-frame').textContent = `${this.frame}/${n - 1}` + (off ? ` (video ${off + this.frame})` : '');
  }

  // ---- edits ------------------------------------------------------------------
  editable() {
    const p = this.path;
    if (!p || p.ref) { this.app.toast('This is a reference path (read-only). Use “Copy as keys” first.'); return null; }
    return p;
  }

  addKey(at = null) {
    const p = this.editable();
    if (!p) return;
    const k = {...this.currentPose(), id: uid(), label: ''};
    if (at === null) {
      // Insert after the key nearest the playhead when scrubbing in the middle, else append.
      p.keys.push(k);
    } else p.keys.splice(at, 0, k);
    if (p.timing === 'keys') this.refreshKeyFrames(p);
    this.touch();
    this.app.toast(`key ${p.keys.length} added`, 1500);
  }

  refreshKeyFrames(p) {
    const N = p.frames;
    const K = p.keys.length;
    p.keys.forEach((k, j) => { if (!Number.isFinite(k.frame)) k.frame = Math.round(j * (N - 1) / Math.max(1, K - 1)); });
    p.keys[0].frame = 0;
    if (K > 1) p.keys[K - 1].frame = N - 1;
  }

  saveView() {
    const v = {...this.currentPose(), id: uid(), rating: 'good', note: ''};
    this.doc.views.push(v);
    this.touch();
    this.app.toast(`view ${this.doc.views.length} saved`, 1500);
  }

  copyAsKeys(step) {
    const p = this.path;
    if (!p || !this.samples) return;
    const S = this.samples;
    const keys = [];
    for (let f = 0; f < S.length; f += step) keys.push({...S[f], id: uid(), label: `f${f}`});
    if ((S.length - 1) % step) keys.push({...S[S.length - 1], id: uid(), label: `f${S.length - 1}`});
    const np = {...this.newPath(`${p.name} (keys)`), keys, frames: S.length, ramp: 0, timing: 'keys',
                module: p.module || 'm01'};
    keys.forEach((k) => { k.frame = Number(k.label.slice(1)); });
    this.doc.paths.push(np);
    this.doc.current = np.id;
    this.touch();
  }

  async exportCams() {
    const p = this.path;
    if (!p || !this.samples?.length) return;
    const mod = $('shot-module').value;
    const m = MODULES[mod];
    const frames = m ? m.end - m.start : this.samples.length;
    const S = m && frames !== this.samples.length ? samplePath({...p, frames}, this.nav.pivot) : this.samples;
    const body = {scene: this.scene, name: p.name, module: mod, start: m ? m.start : 0, end: m ? m.end : S.length,
      fovx_deg: S.map((s) => s.fovx), cams: S.map(poseToC2W), path: p};
    this.setStatus('exporting…');
    try {
      const r = await fetch('api/export', {method: 'POST', headers: {'Content-Type': 'application/json'}, body: JSON.stringify(body)});
      const j = await r.json();
      if (!r.ok) throw new Error(j.error || r.status);
      this.setStatus(`wrote ${j.npz}`);
      this.app.toast(`cams written: ${j.npz}`, 8000);
    } catch (e) { this.setStatus(`export failed: ${e.message}`); }
  }

  download() {
    const blob = new Blob([JSON.stringify({...this.doc, refs: undefined}, null, 1)], {type: 'application/json'});
    const a = document.createElement('a');
    a.href = URL.createObjectURL(blob);
    a.download = `shots_${this.scene}.json`;
    a.click();
  }

  // ---- panel ------------------------------------------------------------------
  toggle(on = !this.open) {
    this.open = on;
    $('shot-panel').classList.toggle('hidden', !on);
    $('btn-shot').classList.toggle('on', on);
    this.overlay.classList.toggle('hidden', !on);
    $('fov').value = Math.round(on ? this.fovx : this.nav.fovy / DEG);
    $('fov-label').firstChild.textContent = on ? 'fovx ' : 'fov ';
    if (!on) this.stop();
    this.app.forceFrame = true;
    this.render();
  }

  bind() {
    $('btn-shot').onclick = () => this.toggle();
    $('shot-path').onchange = (e) => { this.stop(); this.doc.current = e.target.value; this.frame = 0; this.resample(); this.render(); this.save(); };
    $('shot-new').onclick = () => { const p = this.newPath(`path ${this.doc.paths.length + 1}`); this.doc.paths.push(p); this.doc.current = p.id; this.frame = 0; this.touch(); };
    $('shot-dup').onclick = () => {
      const p = this.path; if (!p) return;
      const c = JSON.parse(JSON.stringify(p)); c.id = uid(); c.name = `${p.name} copy`; delete c.ref; delete c.dense;
      if (p.dense) { this.copyAsKeys(15); return; }
      this.doc.paths.push(c); this.doc.current = c.id; this.touch();
    };
    $('shot-rename').onclick = () => { const p = this.editable(); if (!p) return; const n = prompt('Path name', p.name); if (n) { p.name = n; this.touch(); } };
    $('shot-del').onclick = () => {
      const p = this.editable(); if (!p) return;
      if (!confirm(`Delete path “${p.name}” (${p.keys.length} keys)?`)) return;
      this.doc.paths = this.doc.paths.filter((x) => x !== p);
      if (!this.doc.paths.length) this.doc.paths.push(this.newPath('path 1'));
      this.doc.current = this.doc.paths[0].id; this.touch();
    };
    $('shot-frames').onchange = (e) => { const p = this.editable(); if (!p) return; p.frames = Math.max(2, Number(e.target.value) | 0); if (p.timing === 'keys') { p.keys.forEach((k) => { delete k.frame; }); this.refreshKeyFrames(p); } this.touch(); };
    $('shot-ramp').onchange = (e) => { const p = this.editable(); if (!p) return; p.ramp = Math.max(0, Math.min(0.5, Number(e.target.value))); this.touch(); };
    $('shot-timing').onchange = (e) => {
      const p = this.editable(); if (!p) return;
      if (e.target.value === 'keys' && p.timing !== 'keys') {
        const kf = this.samples?.keyFrames;
        p.keys.forEach((k, j) => { k.frame = kf ? kf[j] : undefined; });
        this.refreshKeyFrames(p);
      }
      p.timing = e.target.value; this.touch();
    };
    $('shot-module').onchange = (e) => {
      const p = this.path; if (!p || p.ref) return;
      p.module = e.target.value;
      const m = MODULES[p.module];
      if (m && confirm(`Set the path length to ${m.end - m.start} frames (${m.label})?`)) { p.frames = m.end - m.start; if (p.timing === 'keys') { p.keys.forEach((k) => { delete k.frame; }); this.refreshKeyFrames(p); } }
      this.touch();
    };
    $('shot-key').onclick = () => this.addKey();
    $('shot-view').onclick = () => this.saveView();
    $('shot-play').onclick = () => (this.playing ? this.stop() : this.play());
    $('shot-scrub').oninput = (e) => { this.stop(); this.frame = Number(e.target.value); if (this.samples?.[this.frame]) this.applyPose(this.samples[this.frame]); this.syncScrub(); };
    $('shot-export').onclick = () => this.exportCams();
    $('shot-download').onclick = () => this.download();
    for (const k of ['grid', 'path', 'cams']) $(`shot-show-${k}`).onchange = (e) => { this.show[k] = e.target.checked; this.app.forceFrame = true; };
    for (const id of ['shot-key', 'shot-view', 'shot-play', 'shot-new', 'shot-dup']) $(id).addEventListener('click', () => this.app.canvas.focus({preventScroll: true}));
  }

  render() {
    if (!this.doc) return;
    const p = this.path;
    const sel = $('shot-path');
    sel.innerHTML = '';
    const g1 = document.createElement('optgroup'); g1.label = 'My paths';
    for (const x of this.doc.paths) g1.appendChild(new Option(`${x.name} · ${x.keys.length} keys`, x.id));
    sel.appendChild(g1);
    if (this.refs.length) {
      const g2 = document.createElement('optgroup'); g2.label = 'George’s paths (read-only)';
      for (const x of this.refs) g2.appendChild(new Option(x.name, x.id));
      sel.appendChild(g2);
    }
    sel.value = p ? p.id : '';
    const ro = !p || p.ref;
    $('shot-frames').value = p ? (p.dense ? p.samples.length : p.frames) : '';
    $('shot-ramp').value = p?.ramp ?? 0.15;
    $('shot-timing').value = p?.timing || 'constant';
    for (const id of ['shot-frames', 'shot-ramp', 'shot-timing', 'shot-key', 'shot-rename', 'shot-del']) $(id).disabled = ro;
    $('shot-module').value = p?.module && MODULES[p.module] ? p.module : 'm01';
    $('shot-dup').textContent = p?.dense ? 'Copy as keys' : 'Duplicate';
    $('shot-note').textContent = p?.ref ? (p.note || '') : '';
    // keys
    const list = $('shot-keys');
    list.innerHTML = '';
    if (p && !p.dense) {
      const kf = this.samples?.keyFrames || [];
      p.keys.forEach((k, j) => {
        const row = document.createElement('div'); row.className = 'shot-item';
        const frameField = p.timing === 'keys'
          ? `<input class="kf" type="number" min="0" max="${p.frames - 1}" value="${k.frame ?? kf[j] ?? 0}" title="Frame of this key">`
          : `<span class="kf-auto" title="Frame under constant-speed timing">f${kf[j] ?? '–'}</span>`;
        row.innerHTML = `<b>${j + 1}</b>${frameField}<input class="lbl" placeholder="label" value="${(k.label || '').replace(/"/g, '&quot;')}">`
          + '<button data-a="go" title="Go to this key">⤴</button><button data-a="set" title="Replace with the current view">⟳</button>'
          + '<button data-a="ins" title="Insert the current view before this key">+</button>'
          + '<button data-a="up" title="Move up">↑</button><button data-a="down" title="Move down">↓</button><button data-a="del" title="Delete">✕</button>';
        row.querySelector('.lbl').onchange = (e) => { k.label = e.target.value; this.touch(); };
        const kfIn = row.querySelector('.kf');
        if (kfIn) kfIn.onchange = (e) => { k.frame = Number(e.target.value) | 0; this.touch(); };
        row.querySelectorAll('button').forEach((b) => { b.onclick = () => this.keyAction(p, j, b.dataset.a); });
        list.appendChild(row);
      });
      if (!p.keys.length) list.innerHTML = '<div class="shot-empty">Frame a view, then press <b>K</b> (or + Key) for each key.</div>';
    } else if (p) list.innerHTML = `<div class="shot-empty">${p.samples.length} frames from ${p.src || 'a cams file'}. Play or scrub it; “Copy as keys” makes an editable path.</div>`;
    // views
    const vl = $('shot-views');
    vl.innerHTML = '';
    this.doc.views.forEach((v, j) => {
      const row = document.createElement('div'); row.className = 'shot-item';
      row.innerHTML = `<b>${j + 1}</b><select class="rate"><option value="good">good</option><option value="ok">ok</option><option value="bad">bad</option></select>`
        + `<input class="lbl" placeholder="note" value="${(v.note || '').replace(/"/g, '&quot;')}">`
        + '<button data-a="go" title="Go to this view">⤴</button><button data-a="set" title="Replace with the current view">⟳</button>'
        + '<button data-a="key" title="Append to the current path as a key">→K</button><button data-a="del" title="Delete">✕</button>';
      row.querySelector('.rate').value = v.rating || 'good';
      row.classList.add(`rate-${v.rating || 'good'}`);
      row.querySelector('.rate').onchange = (e) => { v.rating = e.target.value; this.touch(); };
      row.querySelector('.lbl').onchange = (e) => { v.note = e.target.value; this.touch(); };
      row.querySelectorAll('button').forEach((b) => { b.onclick = () => this.viewAction(v, j, b.dataset.a); });
      vl.appendChild(row);
    });
    if (!this.doc.views.length) vl.innerHTML = '<div class="shot-empty">Press <b>V</b> to save a still view.</div>';
    this.syncScrub();
    this.setStatus(this.status);
  }

  keyAction(p, j, a) {
    const k = p.keys[j];
    if (a === 'go') { this.stop(); this.applyPose(k, 0.5); const kf = this.samples?.keyFrames; if (kf) { this.frame = kf[j]; this.syncScrub(); } return; }
    if (a === 'set') Object.assign(k, this.currentPose());
    if (a === 'ins') { p.keys.splice(j, 0, {...this.currentPose(), id: uid(), label: ''}); if (p.timing === 'keys') { p.keys[j].frame = j > 0 ? Math.round((p.keys[j - 1].frame + p.keys[j + 1].frame) / 2) : 0; } }
    if (a === 'up' && j > 0) [p.keys[j - 1], p.keys[j]] = [p.keys[j], p.keys[j - 1]];
    if (a === 'down' && j < p.keys.length - 1) [p.keys[j + 1], p.keys[j]] = [p.keys[j], p.keys[j + 1]];
    if (a === 'del') p.keys.splice(j, 1);
    if (p.timing === 'keys' && p.keys.length) this.refreshKeyFrames(p);
    this.touch();
  }

  viewAction(v, j, a) {
    if (a === 'go') { this.stop(); this.applyPose(v, 0.5); return; }
    if (a === 'set') Object.assign(v, this.currentPose());
    if (a === 'key') {
      const p = this.editable(); if (!p) return;
      p.keys.push({p: [...v.p], q: [...v.q], fovx: v.fovx, id: uid(), label: v.note || `view ${j + 1}`});
      if (p.timing === 'keys') this.refreshKeyFrames(p);
    }
    if (a === 'del') this.doc.views.splice(j, 1);
    this.touch();
  }

  onKey(e) {
    if (!this.open) return false;
    switch (e.code) {
      case 'KeyK': this.addKey(); return true;
      case 'KeyV': this.saveView(); return true;
      case 'KeyP': if (this.playing) this.stop(); else this.play(); return true;
      default: return false;
    }
  }

  // ---- overlay ------------------------------------------------------------------
  hud() {
    const pos = this.nav.position;
    let dmin = Infinity;
    for (const c of this.capture || []) dmin = Math.min(dmin, v3.len(v3.sub(c, pos)));
    const el = $('shot-hud');
    const cls = dmin < 0.8 ? 'ok' : dmin < 1.5 ? 'warn' : 'bad';
    el.innerHTML = `nearest capture camera <span class="${cls}">${dmin.toFixed(2)}</span> · fovx ${this.fovx.toFixed(1)}°`;
  }

  drawOverlay() {
    const cv = this.overlay;
    const dpr = Math.min(window.devicePixelRatio || 1, 2);
    const cw = this.app.canvas.clientWidth, ch = this.app.canvas.clientHeight;
    if (cv.width !== Math.round(cw * dpr) || cv.height !== Math.round(ch * dpr)) { cv.width = Math.round(cw * dpr); cv.height = Math.round(ch * dpr); }
    const g = this.octx;
    g.setTransform(dpr, 0, 0, dpr, 0, 0);
    g.clearRect(0, 0, cw, ch);
    if (!this.open) return;
    const r = this.frameRect();
    g.fillStyle = 'rgba(0,0,0,0.6)';
    g.fillRect(0, 0, cw, r.y); g.fillRect(0, r.y + r.h, cw, ch - r.y - r.h);
    g.fillRect(0, r.y, r.x, r.h); g.fillRect(r.x + r.w, r.y, cw - r.x - r.w, r.h);
    g.strokeStyle = 'rgba(242,180,90,0.9)'; g.lineWidth = 1;
    g.strokeRect(r.x + 0.5, r.y + 0.5, r.w - 1, r.h - 1);
    if (this.show.grid) {
      g.strokeStyle = 'rgba(255,255,255,0.18)';
      g.beginPath();
      for (const t of [1 / 3, 2 / 3]) {
        g.moveTo(r.x + r.w * t, r.y); g.lineTo(r.x + r.w * t, r.y + r.h);
        g.moveTo(r.x, r.y + r.h * t); g.lineTo(r.x + r.w, r.y + r.h * t);
      }
      g.moveTo(cw / 2 - 6, ch / 2); g.lineTo(cw / 2 + 6, ch / 2); g.moveTo(cw / 2, ch / 2 - 6); g.lineTo(cw / 2, ch / 2 + 6);
      g.stroke();
    }
    const {right, down, forward} = this.nav.axes();
    const ty = Math.tan(this.nav.fovy / 2), tx = ty * cw / ch;
    const pos = this.nav.position;
    const proj = (X) => {
      const d = v3.sub(X, pos);
      const z = v3.dot(d, forward);
      if (z < 1e-3) return null;
      return [cw / 2 * (1 + v3.dot(d, right) / z / tx), ch / 2 * (1 + v3.dot(d, down) / z / ty)];
    };
    if (this.show.cams && this.capture) {
      g.fillStyle = 'rgba(120,200,255,0.75)';
      for (const c of this.capture) { const s = proj(c); if (s) g.fillRect(s[0] - 1.5, s[1] - 1.5, 3, 3); }
    }
    const S = this.samples;
    if (this.show.path && S && S.length > 1) {
      g.strokeStyle = 'rgba(242,180,90,0.85)'; g.lineWidth = 2;
      g.beginPath();
      let pen = false;
      for (const s of S) { const P = proj(s.p); if (!P) { pen = false; continue; } if (pen) g.lineTo(P[0], P[1]); else g.moveTo(P[0], P[1]); pen = true; }
      g.stroke();
      // frame ticks every 30 frames
      g.fillStyle = 'rgba(242,180,90,0.9)';
      for (let f = 0; f < S.length; f += 30) { const P = proj(S[f].p); if (P) g.fillRect(P[0] - 1.5, P[1] - 1.5, 3, 3); }
      const p = this.path;
      if (p && !p.dense) {
        g.font = '11px system-ui'; g.textBaseline = 'middle';
        p.keys.forEach((k, j) => {
          const P = proj(k.p); if (!P) return;
          g.fillStyle = '#f2b45a'; g.beginPath(); g.arc(P[0], P[1], 5, 0, 2 * Math.PI); g.fill();
          g.fillStyle = '#1b1306'; g.textAlign = 'center'; g.fillText(String(j + 1), P[0], P[1] + 0.5);
          // view direction
          const f = q.axes(k.q).forward;
          const Q = proj(v3.add(k.p, v3.scale(f, 0.25 * this.nav.sceneScale)));
          if (Q) { g.strokeStyle = 'rgba(242,180,90,0.6)'; g.lineWidth = 1; g.beginPath(); g.moveTo(P[0], P[1]); g.lineTo(Q[0], Q[1]); g.stroke(); }
        });
      }
      const cur = S[this.frame] && proj(S[this.frame].p);
      if (cur) { g.strokeStyle = '#fff'; g.lineWidth = 2; g.beginPath(); g.arc(cur[0], cur[1], 7, 0, 2 * Math.PI); g.stroke(); }
    }
    this.hud();
  }
}

export {MODULES};
