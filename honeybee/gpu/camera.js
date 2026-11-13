// Camera matrices and orbit control of the WebGPU viewer.
//
// A camera holds view_matrix, proj_matrix and campos in the layout of
// cameras.json: t.contiguous().flatten() of the torch tensors, the floats in
// the order that the CUDA kernel reads through data_ptr. view_matrix is
// world_view_transform = getWorld2View2(R, T)^T, proj_matrix is
// full_proj_transform = world_view_transform @ getProjectionMatrix(...)^T
// (utils/graphics_utils.py, scene/cameras.py). Flat float k is row k / 4,
// column k % 4 of the stored (transposed) matrix.

// A camera record of cameras.json as float32 arrays.
export function cameraFromRecord(record) {
  return {
    name: record.name,
    width: record.width,
    height: record.height,
    fovx: record.FoVx,
    fovy: record.FoVy,
    znear: record.znear,
    zfar: record.zfar,
    view: Float32Array.from(record.view_matrix),
    proj: Float32Array.from(record.proj_matrix),
    campos: Float32Array.from(record.campos),
  };
}

// getProjectionMatrix(znear, zfar, fovX, fovY) as a row-major 4x4 array
// (before the transpose). torch.zeros(4, 4) holds float32 entries.
function projectionMatrix(znear, zfar, fovx, fovy) {
  const tanHalfFovY = Math.tan(fovy / 2);
  const tanHalfFovX = Math.tan(fovx / 2);
  const top = tanHalfFovY * znear;
  const bottom = -top;
  const right = tanHalfFovX * znear;
  const left = -right;
  const p = [[0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0]];
  const zSign = 1.0;
  p[0][0] = Math.fround(2.0 * znear / (right - left));
  p[1][1] = Math.fround(2.0 * znear / (top - bottom));
  p[0][2] = Math.fround((right + left) / (right - left));
  p[1][2] = Math.fround((top + bottom) / (top - bottom));
  p[3][2] = zSign;
  p[2][2] = Math.fround(zSign * zfar / (zfar - znear));
  p[2][3] = Math.fround(-(zfar * znear) / (zfar - znear));
  return p;
}

function matmul4(a, b) {
  const out = [[0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0]];
  for (let i = 0; i < 4; i++) {
    for (let j = 0; j < 4; j++) {
      let sum = 0;
      for (let k = 0; k < 4; k++) sum += a[i][k] * b[k][j];
      out[i][j] = sum;
    }
  }
  return out;
}

// The flat layout of a stored (transposed) torch matrix: float 4 i + j is
// stored[i][j] = m[j][i].
function flatTransposed(m) {
  const out = new Float32Array(16);
  for (let i = 0; i < 4; i++) for (let j = 0; j < 4; j++) out[4 * i + j] = m[j][i];
  return out;
}

const sub = (a, b) => [a[0] - b[0], a[1] - b[1], a[2] - b[2]];
const add = (a, b) => [a[0] + b[0], a[1] + b[1], a[2] + b[2]];
const scale = (a, s) => [a[0] * s, a[1] * s, a[2] * s];
const dot = (a, b) => a[0] * b[0] + a[1] * b[1] + a[2] * b[2];
const cross = (a, b) => [a[1] * b[2] - a[2] * b[1], a[2] * b[0] - a[0] * b[2], a[0] * b[1] - a[1] * b[0]];
const normalize = (a) => scale(a, 1 / Math.hypot(a[0], a[1], a[2]));

// Rotation of v about the unit axis by angle (Rodrigues).
function rotate(v, axis, angle) {
  const c = Math.cos(angle);
  const s = Math.sin(angle);
  return add(add(scale(v, c), scale(cross(axis, v), s)), scale(axis, dot(axis, v) * (1 - c)));
}

// Orbit control about a target point. The camera axes follow the COLMAP
// convention of the dataset: x to the right, y down, z forward.
export class Orbit {
  // camera: a cameraFromRecord object; center: the centre of the bounding
  // box of the endpoints.
  constructor(camera, center) {
    const v = camera.view;
    // Rt = view^T, so the rows of the world-to-view rotation are
    // Rt[r][c] = v[4 c + r].
    this.right = [v[0], v[4], v[8]];
    this.down = [v[1], v[5], v[9]];
    this.forward = [v[2], v[6], v[10]];
    this.position = [camera.campos[0], camera.campos[1], camera.campos[2]];
    this.fovx = camera.fovx;
    this.fovy = camera.fovy;
    this.znear = camera.znear;
    this.zfar = camera.zfar;
    this.width = camera.width;
    this.height = camera.height;
    // The target: the point on the view axis nearest to the box centre.
    const toCenter = sub(center, this.position);
    let along = dot(toCenter, this.forward);
    if (!(along > 0)) along = Math.hypot(toCenter[0], toCenter[1], toCenter[2]) || 1;
    this.target = add(this.position, scale(this.forward, along));
  }

  distance() {
    const d = sub(this.position, this.target);
    return Math.hypot(d[0], d[1], d[2]);
  }

  // Left drag: rotate the camera about the target.
  rotate(dxPixels, dyPixels) {
    const yaw = -dxPixels * 0.005;
    const pitch = dyPixels * 0.005;
    const turn = (v) => rotate(rotate(v, normalize(this.down), yaw), normalize(this.right), pitch);
    const offset = sub(this.position, this.target);
    const newRight = turn(this.right);
    const newDown = turn(this.down);
    const newOffset = turn(offset);
    this.right = newRight;
    this.down = newDown;
    this.position = add(this.target, newOffset);
    this.orthonormalize();
  }

  // Right drag: move the camera and the target in the image plane.
  pan(dxPixels, dyPixels) {
    const perPixel = 2 * this.distance() * Math.tan(this.fovy / 2) / this.height;
    const move = add(scale(this.right, -dxPixels * perPixel), scale(this.down, -dyPixels * perPixel));
    this.position = add(this.position, move);
    this.target = add(this.target, move);
  }

  // Wheel: move the camera along the view axis.
  dolly(wheelDelta) {
    const distance = this.distance();
    const step = Math.min(wheelDelta * 0.001 * distance, 0.95 * distance);
    this.position = add(this.position, scale(this.forward, -step));
  }

  orthonormalize() {
    this.forward = normalize(cross(this.right, this.down));
    this.right = normalize(this.right);
    this.down = normalize(cross(this.forward, this.right));
  }

  // The camera of the current orbit state in the cameras.json layout.
  camera() {
    const rwv = [this.right, this.down, this.forward];
    const t = rwv.map(row => -dot(row, this.position));
    const rt = [
      [rwv[0][0], rwv[0][1], rwv[0][2], t[0]],
      [rwv[1][0], rwv[1][1], rwv[1][2], t[1]],
      [rwv[2][0], rwv[2][1], rwv[2][2], t[2]],
      [0, 0, 0, 1],
    ];
    const p = projectionMatrix(this.znear, this.zfar, this.fovx, this.fovy);
    // full_proj = Rt^T P^T = (P Rt)^T.
    const full = matmul4(p, rt);
    return {
      name: 'orbit', width: this.width, height: this.height,
      fovx: this.fovx, fovy: this.fovy, znear: this.znear, zfar: this.zfar,
      view: flatTransposed(rt),
      proj: flatTransposed(full),
      campos: Float32Array.from(this.position),
    };
  }
}
