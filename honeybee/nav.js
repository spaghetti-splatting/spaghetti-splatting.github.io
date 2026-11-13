// Camera navigation for the Kernel Curves WebGPU viewer.
//
// Two modes share one camera state (position, yaw, pitch, roll about the
// scene up axis):
//   orbit: left drag turns the camera about a pivot, right/middle drag (or
//          shift + left drag) pans, the wheel zooms toward the cursor.
//   walk:  the SwitchSplat / Spark walking controls: WASD move, Q/E down/up,
//          arrows turn, left drag looks, right drag slides, wheel moves
//          forward, Shift is 3x faster.
// Both modes: [ and ] roll, \ levels the horizon, double click (or double tap)
// focuses on the picked point, R resets to the opening view. Touch: one
// finger turns, two fingers pinch-zoom and pan.
// Drag inertia follows Spark (exponential decay, time constant 0.08 s).
//
// The camera axes follow the dataset (COLMAP / OpenCV): x right, y down,
// z forward. camera() writes the matrices in the layout of cameras.json
// (see gpu/camera.js).

const v3 = {
  add: (a, b) => [a[0] + b[0], a[1] + b[1], a[2] + b[2]],
  sub: (a, b) => [a[0] - b[0], a[1] - b[1], a[2] - b[2]],
  scale: (a, s) => [a[0] * s, a[1] * s, a[2] * s],
  dot: (a, b) => a[0] * b[0] + a[1] * b[1] + a[2] * b[2],
  cross: (a, b) => [a[1] * b[2] - a[2] * b[1], a[2] * b[0] - a[0] * b[2], a[0] * b[1] - a[1] * b[0]],
  len: (a) => Math.sqrt(a[0] * a[0] + a[1] * a[1] + a[2] * a[2]),
  norm: (a) => { const l = Math.sqrt(a[0] * a[0] + a[1] * a[1] + a[2] * a[2]) || 1; return [a[0] / l, a[1] / l, a[2] / l]; },
  lerp: (a, b, t) => [a[0] + (b[0] - a[0]) * t, a[1] + (b[1] - a[1]) * t, a[2] + (b[2] - a[2]) * t],
};
export {v3};

const PITCH_LIMIT = Math.PI / 2 - 0.01;
const INERTIA = 0.08;           // s, Spark pointer inertia
const ROTATE_PER_PX = 0.0042;   // rad per CSS pixel (orbit)
const LOOK_PER_PX = 0.0025;     // rad per CSS pixel (walk)
const KEY_TURN = 1.4;           // rad/s for the arrow keys
const WHEEL_ZOOM = 0.0015;      // log-distance per wheel unit
const wrapAngle = (a) => Math.atan2(Math.sin(a), Math.cos(a));
const smooth = (t) => t * t * (3 - 2 * t);

// getProjectionMatrix of utils/graphics_utils.py as a row-major array.
function projectionMatrix(znear, zfar, fovx, fovy) {
  const top = Math.tan(fovy / 2) * znear;
  const right = Math.tan(fovx / 2) * znear;
  const p = [[0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0]];
  p[0][0] = 2 * znear / (2 * right);
  p[1][1] = 2 * znear / (2 * top);
  p[3][2] = 1;
  p[2][2] = zfar / (zfar - znear);
  p[2][3] = -(zfar * znear) / (zfar - znear);
  return p;
}

// Flat layout of a stored (transposed) torch matrix: float 4i+j = m[j][i].
function flatTransposed(m) {
  const out = new Float32Array(16);
  for (let i = 0; i < 4; i++) for (let j = 0; j < 4; j++) out[4 * i + j] = m[j][i];
  return out;
}

export class Navigation {
  // canvas: the event target. up: the world up vector of the scene.
  constructor(canvas, {up = [0, 1, 0]} = {}) {
    this.canvas = canvas;
    this.mode = 'orbit';
    this.fovy = 50 * Math.PI / 180;
    this.znear = 0.01;
    this.zfar = 100;
    this.position = [0, 0, 5];
    this.pivot = [0, 0, 0];
    this.yaw = 0; this.pitch = 0; this.roll = 0;
    this.sceneScale = 1;      // a typical object distance, scene units
    this.moveSpeed = 0.25;    // scene units per second (walk)
    this.version = 0;         // bumps on every change of the camera
    this.setUp(up);
    this.keys = new Set();
    this.pointers = new Map();
    this.velocity = {yaw: 0, pitch: 0, pan: [0, 0], move: [0, 0, 0]};
    this.flight = null;
    this.home = null;
    this.grabber = null;      // optional {begin(x, y, e) -> Promise<bool>, move(x, y), end()}
    this.picker = null;       // optional (x, y) -> Promise<[x, y, z] | null>
    this.onInput = null;      // called on any user input (for idle detection)
    this._listeners = [];
    this._attach();
  }

  // ---- frame of reference -------------------------------------------------
  setUp(up) {
    this.up = v3.norm(up);
    // Two horizontal axes e1, e2 with e1 x e2 = up... any fixed pair works.
    const helper = Math.abs(this.up[0]) < 0.9 ? [1, 0, 0] : [0, 0, 1];
    this.e1 = v3.norm(v3.cross(helper, this.up));
    this.e2 = v3.cross(this.up, this.e1);
  }

  axes(yaw = this.yaw, pitch = this.pitch, roll = this.roll) {
    const h = v3.add(v3.scale(this.e1, Math.cos(yaw)), v3.scale(this.e2, Math.sin(yaw)));
    const f = v3.add(v3.scale(h, Math.cos(pitch)), v3.scale(this.up, Math.sin(pitch)));
    const r0 = v3.norm(v3.cross(f, this.up));
    const d0 = v3.cross(f, r0);
    const c = Math.cos(roll), s = Math.sin(roll);
    return {right: v3.add(v3.scale(r0, c), v3.scale(d0, s)), down: v3.add(v3.scale(r0, -s), v3.scale(d0, c)), forward: f};
  }

  anglesFromForward(f, right = null) {
    f = v3.norm(f);
    const pitch = Math.max(-PITCH_LIMIT, Math.min(PITCH_LIMIT, Math.asin(Math.max(-1, Math.min(1, v3.dot(f, this.up))))));
    const yaw = Math.atan2(v3.dot(f, this.e2), v3.dot(f, this.e1));
    let roll = 0;
    if (right) {
      const {right: r0, down: d0} = this.axes(yaw, pitch, 0);
      roll = Math.atan2(v3.dot(right, d0), v3.dot(right, r0));
    }
    return {yaw, pitch, roll};
  }

  // Place the camera like a cameras.json record (view matrix, campos).
  setFromRecord(record, pivotHint) {
    const v = record.view_matrix;
    const right = [v[0], v[4], v[8]];
    const forward = [v[2], v[6], v[10]];
    const a = this.anglesFromForward(forward, right);
    this.yaw = a.yaw; this.pitch = a.pitch; this.roll = a.roll;
    this.position = [...record.campos];
    this.fovy = record.FoVy;
    this.znear = record.znear;
    this.zfar = record.zfar;
    const dist = pivotHint ? Math.max(1e-3, v3.dot(v3.sub(pivotHint, this.position), forward)) : this.sceneScale;
    this.pivot = v3.add(this.position, v3.scale(v3.norm(forward), dist));
    this.changed();
  }

  remember() {
    this.home = this.state();
  }

  state() {
    return {position: [...this.position], pivot: [...this.pivot], yaw: this.yaw, pitch: this.pitch, roll: this.roll, fovy: this.fovy};
  }

  // Animate to a state over `seconds`.
  flyTo(target, seconds = 0.6) {
    this.stop();
    this.flight = {from: this.state(), to: target, t: 0, seconds};
  }

  reset() {
    if (this.home) this.flyTo(this.home, 0.6);
  }

  level() {
    this.flyTo({...this.state(), roll: 0}, 0.25);
  }

  rollBy(rad) {
    this.roll = wrapAngle(this.roll + rad);
    this.changed();
  }

  setMode(mode) {
    this.mode = mode;
    this.stop();
    if (mode === 'orbit') {
      // Keep the pivot in front of the camera at its distance.
      const f = this.axes().forward;
      const d = Math.max(v3.dot(v3.sub(this.pivot, this.position), f), 0.05 * this.sceneScale);
      this.pivot = v3.add(this.position, v3.scale(f, d));
    }
    this.changed();
  }

  stop() {
    this.velocity = {yaw: 0, pitch: 0, pan: [0, 0], move: [0, 0, 0]};
  }

  changed() {
    this.version++;
  }

  distance() {
    return v3.len(v3.sub(this.pivot, this.position));
  }

  // ---- camera matrices --------------------------------------------------
  // width, height: render size in pixels.
  camera(width, height) {
    const {right, down, forward} = this.axes();
    const fovy = this.fovy;
    const fovx = 2 * Math.atan(Math.tan(fovy / 2) * width / height);
    const rwv = [right, down, forward];
    const t = rwv.map((row) => -v3.dot(row, this.position));
    const rt = [
      [right[0], right[1], right[2], t[0]],
      [down[0], down[1], down[2], t[1]],
      [forward[0], forward[1], forward[2], t[2]],
      [0, 0, 0, 1],
    ];
    const p = projectionMatrix(this.znear, this.zfar, fovx, fovy);
    const full = [[0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0]];
    for (let i = 0; i < 4; i++) for (let j = 0; j < 4; j++) {
      let s = 0;
      for (let k = 0; k < 4; k++) s += p[i][k] * rt[k][j];
      full[i][j] = s;
    }
    return {
      name: 'nav', width, height, fovx, fovy, znear: this.znear, zfar: this.zfar,
      view: flatTransposed(rt), proj: flatTransposed(full),
      campos: Float32Array.from(this.position),
      right, down, forward,
    };
  }

  // World ray through a CSS pixel of the canvas.
  ray(cssX, cssY) {
    const w = this.canvas.clientWidth, h = this.canvas.clientHeight;
    const {right, down, forward} = this.axes();
    const ty = Math.tan(this.fovy / 2);
    const tx = ty * w / h;
    const x = (2 * cssX / w - 1) * tx;
    const y = (2 * cssY / h - 1) * ty;
    return v3.norm(v3.add(forward, v3.add(v3.scale(right, x), v3.scale(down, y))));
  }

  // ---- per-frame update -------------------------------------------------
  // Returns true when the camera moved.
  update(dt) {
    const before = this.version;
    dt = Math.max(1e-4, Math.min(0.1, dt));
    if (this.flight) {
      const fl = this.flight;
      fl.t += dt / fl.seconds;
      const t = smooth(Math.min(1, fl.t));
      const a = fl.from, b = fl.to;
      this.position = v3.lerp(a.position, b.position, t);
      this.pivot = v3.lerp(a.pivot, b.pivot, t);
      this.yaw = a.yaw + wrapAngle(b.yaw - a.yaw) * t;
      this.pitch = a.pitch + (b.pitch - a.pitch) * t;
      this.roll = a.roll + wrapAngle(b.roll - a.roll) * t;
      this.fovy = a.fovy + (b.fovy - a.fovy) * t;
      if (fl.t >= 1) this.flight = null;
      this.changed();
      return true;
    }
    const decay = Math.exp(-dt / INERTIA);
    const vel = this.velocity;
    // Drag inertia after release.
    if (!this.dragging()) {
      if (Math.abs(vel.yaw) + Math.abs(vel.pitch) > 1e-4) {
        this.turn(vel.yaw * dt, vel.pitch * dt);
        vel.yaw *= decay; vel.pitch *= decay;
      } else { vel.yaw = 0; vel.pitch = 0; }
      if (Math.abs(vel.pan[0]) + Math.abs(vel.pan[1]) > 1e-3) {
        this.panPixels(vel.pan[0] * dt, vel.pan[1] * dt);
        vel.pan[0] *= decay; vel.pan[1] *= decay;
      } else { vel.pan = [0, 0]; }
    }
    // Keys.
    const k = this.keys;
    const want = [0, 0, 0];
    if (k.has('KeyW')) want[2] += 1;
    if (k.has('KeyS')) want[2] -= 1;
    if (k.has('KeyD')) want[0] += 1;
    if (k.has('KeyA')) want[0] -= 1;
    if (k.has('KeyE')) want[1] -= 1;   // up (camera y is down)
    if (k.has('KeyQ')) want[1] += 1;
    const fast = (k.has('ShiftLeft') || k.has('ShiftRight')) ? 3 : 1;
    const slow = (k.has('ControlLeft') || k.has('ControlRight')) ? 0.2 : 1;
    const speed = this.moveSpeed * fast * slow;
    const s = 1 - decay;
    for (let i = 0; i < 3; i++) vel.move[i] += (want[i] * speed - vel.move[i]) * s;
    if (Math.abs(vel.move[0]) + Math.abs(vel.move[1]) + Math.abs(vel.move[2]) > 1e-6 * this.sceneScale) {
      const {right, down, forward} = this.axes();
      const step = v3.add(v3.add(v3.scale(right, vel.move[0] * dt), v3.scale(down, vel.move[1] * dt)),
                          v3.scale(forward, vel.move[2] * dt));
      this.position = v3.add(this.position, step);
      this.pivot = v3.add(this.pivot, step);
      this.changed();
    } else vel.move = [0, 0, 0];
    let turnYaw = 0, turnPitch = 0;
    if (k.has('ArrowLeft')) turnYaw += KEY_TURN * dt;
    if (k.has('ArrowRight')) turnYaw -= KEY_TURN * dt;
    if (k.has('ArrowUp')) turnPitch += KEY_TURN * dt;
    if (k.has('ArrowDown')) turnPitch -= KEY_TURN * dt;
    if (turnYaw || turnPitch) this.look(turnYaw, turnPitch);
    return this.version !== before;
  }

  dragging() {
    for (const p of this.pointers.values()) if (p.kind !== 'grab' && p.kind !== 'pending') return true;
    return false;
  }

  // Orbit: turn about the pivot. Walk: turn in place.
  turn(dyaw, dpitch) {
    if (this.mode === 'orbit') {
      const d = this.distance();
      this.yaw = wrapAngle(this.yaw + dyaw);
      this.pitch = Math.max(-PITCH_LIMIT, Math.min(PITCH_LIMIT, this.pitch + dpitch));
      const f = this.axes().forward;
      this.position = v3.sub(this.pivot, v3.scale(f, d));
    } else {
      this.look(dyaw, dpitch);
    }
    this.changed();
  }

  look(dyaw, dpitch) {
    const d = this.distance();
    this.yaw = wrapAngle(this.yaw + dyaw);
    this.pitch = Math.max(-PITCH_LIMIT, Math.min(PITCH_LIMIT, this.pitch + dpitch));
    this.pivot = v3.add(this.position, v3.scale(this.axes().forward, d));
    this.changed();
  }

  // Move camera and pivot in the image plane by CSS pixels (scene follows the cursor).
  panPixels(dx, dy) {
    const h = this.canvas.clientHeight || 1;
    const depth = this.mode === 'orbit' ? this.distance() : this.sceneScale * 0.5;
    const perPx = 2 * depth * Math.tan(this.fovy / 2) / h;
    const {right, down} = this.axes();
    const move = v3.add(v3.scale(right, -dx * perPx), v3.scale(down, -dy * perPx));
    this.position = v3.add(this.position, move);
    this.pivot = v3.add(this.pivot, move);
    this.changed();
  }

  // Zoom toward a CSS pixel; amount > 0 moves closer.
  zoomAt(cssX, cssY, amount) {
    if (this.mode === 'walk') {
      const w = this.ray(cssX, cssY);
      const step = v3.scale(w, amount * 0.4 * this.moveSpeed);
      this.position = v3.add(this.position, step);
      this.pivot = v3.add(this.pivot, step);
      this.changed();
      return;
    }
    const f = this.axes().forward;
    const d = this.distance();
    const factor = Math.exp(-amount);
    const minD = 0.01 * this.sceneScale;
    const w = this.ray(cssX, cssY);
    const x = v3.add(this.position, v3.scale(w, d / Math.max(1e-6, v3.dot(w, f))));
    if (d * factor < minD && amount > 0) {
      // At the closest distance: carry the pivot forward (fly through).
      const step = v3.scale(f, (d - minD) + 0.05 * this.sceneScale * amount);
      this.position = v3.add(this.position, step);
      this.pivot = v3.add(this.pivot, v3.scale(f, 0.05 * this.sceneScale * amount));
    } else {
      this.position = v3.add(x, v3.scale(v3.sub(this.position, x), factor));
      this.pivot = v3.add(x, v3.scale(v3.sub(this.pivot, x), factor));
    }
    this.changed();
  }

  // Focus: look at a world point and make it the pivot.
  focus(point, {approach = 0} = {}) {
    const to = v3.sub(point, this.position);
    const dist = v3.len(to);
    const a = this.anglesFromForward(to);
    const keep = 1 - approach;
    const position = v3.sub(point, v3.scale(v3.norm(to), dist * keep));
    this.flyTo({position, pivot: [...point], yaw: a.yaw, pitch: a.pitch, roll: this.roll, fovy: this.fovy}, 0.45);
  }

  // ---- input --------------------------------------------------------------
  _listen(target, type, fn, opts = {passive: false}) {
    target.addEventListener(type, fn, opts);
    this._listeners.push(() => target.removeEventListener(type, fn, opts));
  }

  _pos(e) {
    const r = this.canvas.getBoundingClientRect();
    return [e.clientX - r.left, e.clientY - r.top];
  }

  _attach() {
    const c = this.canvas;
    c.tabIndex = 0;
    this._listen(c, 'contextmenu', (e) => e.preventDefault());
    this._listen(c, 'pointerdown', (e) => this._down(e));
    this._listen(window, 'pointermove', (e) => this._move(e));
    this._listen(window, 'pointerup', (e) => this._up(e));
    this._listen(window, 'pointercancel', (e) => this._up(e));
    this._listen(c, 'wheel', (e) => {
      e.preventDefault();
      const [x, y] = this._pos(e);
      const unit = e.deltaMode === 1 ? 33 : e.deltaMode === 2 ? 400 : 1;
      this.flight = null;
      this.zoomAt(x, y, -e.deltaY * unit * WHEEL_ZOOM * (e.ctrlKey ? 3 : 1));
      this.onInput?.();
    });
    this._listen(c, 'dblclick', (e) => this._focusAt(...this._pos(e)));
    this._listen(document, 'keydown', (e) => {
      if (e.target instanceof HTMLInputElement || e.target instanceof HTMLSelectElement) return;
      const nav = ['KeyW', 'KeyA', 'KeyS', 'KeyD', 'KeyQ', 'KeyE', 'ArrowUp', 'ArrowDown', 'ArrowLeft', 'ArrowRight'];
      if (e.metaKey || e.altKey) return;
      if (nav.includes(e.code) && !e.ctrlKey) { e.preventDefault(); this.flight = null; }
      this.keys.add(e.code);
      if (e.code === 'BracketLeft') this.rollBy(-2 * Math.PI / 180);
      if (e.code === 'BracketRight') this.rollBy(2 * Math.PI / 180);
      if (e.code === 'Backslash') this.level();
      this.onInput?.();
    });
    this._listen(document, 'keyup', (e) => this.keys.delete(e.code));
    this._listen(window, 'blur', () => this.keys.clear());
  }

  async _focusAt(x, y) {
    if (!this.picker) return;
    const p = await this.picker(x, y);
    if (p) this.focus(p, {approach: this.mode === 'orbit' ? 0.35 : 0});
  }

  _down(e) {
    this.canvas.focus({preventScroll: true});
    this.flight = null;
    this.onInput?.();
    const [x, y] = this._pos(e);
    const p = {id: e.pointerId, x, y, x0: x, y0: y, t0: performance.now(), button: e.button,
               type: e.pointerType, shift: e.shiftKey, kind: 'pending', queue: []};
    this.pointers.set(e.pointerId, p);
    this.canvas.setPointerCapture(e.pointerId);
    // Double tap on touch focuses.
    if (e.pointerType === 'touch') {
      const now = performance.now();
      if (this._lastTap && now - this._lastTap.t < 320 && Math.hypot(x - this._lastTap.x, y - this._lastTap.y) < 30) {
        this._focusAt(x, y);
        this._lastTap = null;
      } else this._lastTap = {t: now, x, y};
    }
    const touches = [...this.pointers.values()].filter((q) => q.type === 'touch');
    if (touches.length >= 2) {
      // Pinch: cancel any grab of the first finger.
      for (const q of touches) {
        if (q.kind === 'grab') this.grabber?.end();
        q.kind = 'pinch';
      }
      this._pinch = null;
      return;
    }
    const primary = e.button === 0 && !e.shiftKey;
    if (primary && this.grabber) {
      p.kind = 'pending';
      this.grabber.begin(x, y, e).then((hit) => {
        if (!this.pointers.has(p.id) || p.kind !== 'pending') {
          if (hit) this.grabber.end();
          return;
        }
        if (hit) {
          p.kind = 'grab';
          this.grabber.move(p.x, p.y);
        } else {
          p.kind = 'rotate';
          // Replay the motion made while the pick ran.
          this._drag(p, p.x - p.x0, p.y - p.y0);
        }
      });
      return;
    }
    p.kind = primary ? 'rotate' : 'pan';
  }

  _move(e) {
    const p = this.pointers.get(e.pointerId);
    if (!p) return;
    const [x, y] = this._pos(e);
    const dx = x - p.x, dy = y - p.y;
    p.x = x; p.y = y;
    if (p.kind === 'pending') return;
    this.onInput?.();
    if (p.kind === 'grab') { this.grabber.move(x, y); return; }
    if (p.kind === 'pinch') { this._pinchMove(); return; }
    this._drag(p, dx, dy);
  }

  _drag(p, dx, dy) {
    const now = performance.now();
    const dt = Math.max(1e-3, (now - (p.tLast || now - 16)) / 1000);
    p.tLast = now;
    if (p.kind === 'rotate') {
      let dyaw, dpitch;
      // Orbit: the scene follows the cursor. Walk: the view follows the
      // cursor (Spark mouse look, reverseRotate off). Yaw > 0 turns left.
      if (this.mode === 'orbit') { dyaw = -dx * ROTATE_PER_PX; dpitch = -dy * ROTATE_PER_PX; }
      else { dyaw = -dx * LOOK_PER_PX; dpitch = -dy * LOOK_PER_PX; }
      this.turn(dyaw, dpitch);
      const a = 0.5;
      this.velocity.yaw = a * this.velocity.yaw + (1 - a) * dyaw / dt;
      this.velocity.pitch = a * this.velocity.pitch + (1 - a) * dpitch / dt;
    } else if (p.kind === 'pan') {
      this.panPixels(dx, dy);
      const a = 0.5;
      this.velocity.pan = [a * this.velocity.pan[0] + (1 - a) * dx / dt, a * this.velocity.pan[1] + (1 - a) * dy / dt];
    }
  }

  _pinchMove() {
    const t = [...this.pointers.values()].filter((q) => q.kind === 'pinch');
    if (t.length < 2) return;
    const [a, b] = t;
    const mid = [(a.x + b.x) / 2, (a.y + b.y) / 2];
    const span = Math.hypot(a.x - b.x, a.y - b.y);
    if (this._pinch) {
      this.panPixels(mid[0] - this._pinch.mid[0], mid[1] - this._pinch.mid[1]);
      if (span > 1 && this._pinch.span > 1) this.zoomAt(mid[0], mid[1], Math.log(span / this._pinch.span) * 1.2);
    }
    this._pinch = {mid, span};
  }

  _up(e) {
    const p = this.pointers.get(e.pointerId);
    if (!p) return;
    this.pointers.delete(e.pointerId);
    try { this.canvas.releasePointerCapture(e.pointerId); } catch (_) { /* already released */ }
    if (p.kind === 'grab') this.grabber.end();
    if (p.kind === 'pending') p.kind = 'cancelled';
    // No inertia after a still hold.
    if (performance.now() - (p.tLast || 0) > 80) { this.velocity.yaw = 0; this.velocity.pitch = 0; this.velocity.pan = [0, 0]; }
    if (p.kind === 'pinch') {
      this._pinch = null;
      this.velocity = {yaw: 0, pitch: 0, pan: [0, 0], move: this.velocity.move};
      for (const q of this.pointers.values()) if (q.kind === 'pinch') q.kind = 'ignore';
    }
  }

  dispose() {
    for (const off of this._listeners) off();
    this._listeners = [];
  }
}
