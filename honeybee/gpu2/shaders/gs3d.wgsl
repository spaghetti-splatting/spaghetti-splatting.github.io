// 3D Gaussian splatting (Kerbl et al. 2023), the forward pass of the authors'
// diff-gaussian-rasterization (cuda_rasterizer/forward.cu) for the viewer:
//   gs_preprocess  preprocessCUDA: frustum test (z_view <= 0.2), 3D covariance
//                  from scale and rotation, EWA 2D covariance with the 0.3 px
//                  dilation (antialiasing off), conic, 3-sigma radius, tile
//                  rectangle, SH colour (degree 3, + 0.5, clamped at 0).
//   gs_duplicate   duplicateWithKeys: (tile, depth bits) keys, value = index.
//   gs_render      renderCUDA: one workgroup per 16 x 16 tile, front-to-back
//                  blending, alpha = min(0.99, o exp(power)), skip below
//                  1/255, stop when T < 1e-4.
// The sort (GpuSort), the scan of the tile counts (GpuScan), args_after_scan
// and tile_ranges (frame.wgsl) are the passes of the curve renderer.
// Camera: the Camera struct of common.wgsl; w_aa and beta hold tan(fovx / 2)
// and tan(fovy / 2) for this renderer (gs3d.js, writeCamera).

@group(0) @binding(0) var<storage, read> gs_geo: array<f32>;          // N x 12
@group(0) @binding(1) var<storage, read> gs_sh: array<u32>;           // N x 24 (48 f16)
@group(0) @binding(2) var<uniform> cam: Camera;
@group(0) @binding(3) var<storage, read_write> gs_prims: array<vec4f>; // N x 3
@group(0) @binding(4) var<storage, read_write> gs_rects: array<vec2u>; // N
@group(0) @binding(5) var<storage, read_write> gs_tiles: array<u32>;   // N

@group(0) @binding(0) var<storage, read> dup_prims: array<vec4f>;
@group(0) @binding(1) var<storage, read> dup_rects: array<vec2u>;
@group(0) @binding(2) var<storage, read> dup_offsets: array<u32>;      // inclusive scan of the tile counts
@group(0) @binding(3) var<storage, read> dup_tiles: array<u32>;
@group(0) @binding(4) var<storage, read_write> key_hi: array<u32>;
@group(0) @binding(5) var<storage, read_write> key_lo: array<u32>;
@group(0) @binding(6) var<storage, read_write> key_value: array<u32>;
@group(0) @binding(7) var<uniform> dup_cam: Camera;

@group(0) @binding(0) var<storage, read> rd_ranges: array<u32>;
@group(0) @binding(1) var<storage, read> rd_values: array<u32>;
@group(0) @binding(2) var<storage, read> rd_prims: array<vec4f>;
@group(0) @binding(3) var<storage, read_write> rd_out: array<f32>;     // [3, H, W]
@group(0) @binding(4) var<uniform> rd_cam: Camera;

const SH_C0: f32 = 0.28209479177387814;
const SH_C1: f32 = 0.4886025119029199;
const SH_C2 = array<f32, 5>(1.0925484305920792, -1.0925484305920792, 0.31539156525252005,
                            -1.0925484305920792, 0.5462742152960396);
const SH_C3 = array<f32, 7>(-0.5900435899266435, 2.890611442640554, -0.4570457994644658,
                            0.3731763325901154, -0.4570457994644658, 1.445305721320277,
                            -0.5900435899266435);

fn gm(k: u32) -> f32 { return cam.proj[k >> 2u][k & 3u]; }
fn gv(k: u32) -> f32 { return cam.view[k >> 2u][k & 3u]; }

fn sh_coef(i: u32, k: u32) -> vec3f {
  // sh[3 k + c] as f16, two per word.
  let base = 48u * i + 3u * k;
  var out: vec3f;
  for (var c = 0u; c < 3u; c++) {
    let h = base + c;
    let pair = unpack2x16float(gs_sh[h >> 1u]);
    out[c] = select(pair.x, pair.y, (h & 1u) == 1u);
  }
  return out;
}

fn sh_color(i: u32, p: vec3f) -> vec3f {
  let d = normalize(p - cam.campos.xyz);
  let x = d.x; let y = d.y; let z = d.z;
  var r = SH_C0 * sh_coef(i, 0u);
  r = r - SH_C1 * y * sh_coef(i, 1u) + SH_C1 * z * sh_coef(i, 2u) - SH_C1 * x * sh_coef(i, 3u);
  let xx = x * x; let yy = y * y; let zz = z * z;
  let xy = x * y; let yz = y * z; let xz = x * z;
  r = r + SH_C2[0] * xy * sh_coef(i, 4u) + SH_C2[1] * yz * sh_coef(i, 5u)
        + SH_C2[2] * (2.0 * zz - xx - yy) * sh_coef(i, 6u)
        + SH_C2[3] * xz * sh_coef(i, 7u) + SH_C2[4] * (xx - yy) * sh_coef(i, 8u);
  r = r + SH_C3[0] * y * (3.0 * xx - yy) * sh_coef(i, 9u)
        + SH_C3[1] * xy * z * sh_coef(i, 10u)
        + SH_C3[2] * y * (4.0 * zz - xx - yy) * sh_coef(i, 11u)
        + SH_C3[3] * z * (2.0 * zz - 3.0 * xx - 3.0 * yy) * sh_coef(i, 12u)
        + SH_C3[4] * x * (4.0 * zz - xx - yy) * sh_coef(i, 13u)
        + SH_C3[5] * z * (xx - yy) * sh_coef(i, 14u)
        + SH_C3[6] * x * (xx - 3.0 * yy) * sh_coef(i, 15u);
  return max(r + 0.5, vec3f(0.0));
}

@compute @workgroup_size(256)
fn gs_preprocess(@builtin(local_invocation_index) lid: u32,
                 @builtin(workgroup_id) wid: vec3u,
                 @builtin(num_workgroups) nwg: vec3u) {
  let i = linear_group(wid, nwg) * WORKGROUP_SIZE + lid;
  if (i >= cam.rows) {
    return;
  }
  gs_tiles[i] = 0u;
  let g = 12u * i;
  let p = vec3f(gs_geo[g], gs_geo[g + 1u], gs_geo[g + 2u]);
  let tv = vec3f(p.x * gv(0u) + p.y * gv(4u) + p.z * gv(8u) + gv(12u),
                 p.x * gv(1u) + p.y * gv(5u) + p.z * gv(9u) + gv(13u),
                 p.x * gv(2u) + p.y * gv(6u) + p.z * gv(10u) + gv(14u));
  if (tv.z <= 0.2) {
    return;
  }
  let hx = p.x * gm(0u) + p.y * gm(4u) + p.z * gm(8u) + gm(12u);
  let hy = p.x * gm(1u) + p.y * gm(5u) + p.z * gm(9u) + gm(13u);
  let hw = p.x * gm(3u) + p.y * gm(7u) + p.z * gm(11u) + gm(15u);
  let pw = 1.0 / (hw + 0.0000001);
  // Sigma = R S^2 R^T.
  let s = vec3f(gs_geo[g + 3u], gs_geo[g + 4u], gs_geo[g + 5u]);
  let r = gs_geo[g + 6u]; let qx = gs_geo[g + 7u]; let qy = gs_geo[g + 8u]; let qz = gs_geo[g + 9u];
  let R = mat3x3f(  // columns
    vec3f(1.0 - 2.0 * (qy * qy + qz * qz), 2.0 * (qx * qy + r * qz), 2.0 * (qx * qz - r * qy)),
    vec3f(2.0 * (qx * qy - r * qz), 1.0 - 2.0 * (qx * qx + qz * qz), 2.0 * (qy * qz + r * qx)),
    vec3f(2.0 * (qx * qz + r * qy), 2.0 * (qy * qz - r * qx), 1.0 - 2.0 * (qx * qx + qy * qy)));
  let M = mat3x3f(R[0] * s.x, R[1] * s.y, R[2] * s.z);
  let Sigma = M * transpose(M);
  // EWA: T = J W, W the world-to-view rotation.
  let tanx = cam.w_aa;
  let tany = cam.beta;
  let fx = f32(cam.width) / (2.0 * tanx);
  let fy = f32(cam.height) / (2.0 * tany);
  let limx = 1.3 * tanx;
  let limy = 1.3 * tany;
  let tx = min(limx, max(-limx, tv.x / tv.z)) * tv.z;
  let ty = min(limy, max(-limy, tv.y / tv.z)) * tv.z;
  let tz = tv.z;
  // Rows of W (view = Rt^T in the flat layout).
  let w0 = vec3f(gv(0u), gv(4u), gv(8u));
  let w1 = vec3f(gv(1u), gv(5u), gv(9u));
  let w2 = vec3f(gv(2u), gv(6u), gv(10u));
  let t0 = (fx / tz) * w0 - (fx * tx / (tz * tz)) * w2;
  let t1 = (fy / tz) * w1 - (fy * ty / (tz * tz)) * w2;
  let a = dot(t0, Sigma * t0) + 0.3;
  let b = dot(t0, Sigma * t1);
  let c = dot(t1, Sigma * t1) + 0.3;
  let det = a * c - b * b;
  if (det == 0.0) {
    return;
  }
  let det_inv = 1.0 / det;
  let conic = vec3f(c * det_inv, -b * det_inv, a * det_inv);
  let mid = 0.5 * (a + c);
  let l1 = mid + sqrt(max(0.1, mid * mid - det));
  let l2 = mid - sqrt(max(0.1, mid * mid - det));
  let radius = ceil(3.0 * sqrt(max(l1, l2)));
  let px = ((hx * pw + 1.0) * f32(cam.width) - 1.0) * 0.5;
  let py = ((hy * pw + 1.0) * f32(cam.height) - 1.0) * 0.5;
  let gx = i32(cam.tiles_x);
  let gy = i32(cam.tiles_y);
  let rmin = vec2i(min(gx, max(0, i32((px - radius) / 16.0))), min(gy, max(0, i32((py - radius) / 16.0))));
  let rmax = vec2i(min(gx, max(0, i32((px + radius + 15.0) / 16.0))), min(gy, max(0, i32((py + radius + 15.0) / 16.0))));
  let area = (rmax.x - rmin.x) * (rmax.y - rmin.y);
  if (area == 0) {
    return;
  }
  let rgb = sh_color(i, p);
  gs_prims[3u * i] = vec4f(px, py, tv.z, gs_geo[g + 10u]);
  gs_prims[3u * i + 1u] = vec4f(conic, 0.0);
  gs_prims[3u * i + 2u] = vec4f(rgb, 0.0);
  gs_rects[i] = vec2u(u32(rmin.x) | (u32(rmin.y) << 16u), u32(rmax.x) | (u32(rmax.y) << 16u));
  gs_tiles[i] = u32(area);
}

@compute @workgroup_size(256)
fn gs_duplicate(@builtin(local_invocation_index) lid: u32,
                @builtin(workgroup_id) wid: vec3u,
                @builtin(num_workgroups) nwg: vec3u) {
  let i = linear_group(wid, nwg) * WORKGROUP_SIZE + lid;
  if (i >= dup_cam.rows) {
    return;
  }
  let n = dup_tiles[i];
  if (n == 0u) {
    return;
  }
  var off = dup_offsets[i] - n;
  let depth = bitcast<u32>(dup_prims[3u * i].z);
  let rc = dup_rects[i];
  let x0 = rc.x & 0xffffu; let y0 = rc.x >> 16u;
  let x1 = rc.y & 0xffffu; let y1 = rc.y >> 16u;
  for (var y = y0; y < y1; y++) {
    for (var x = x0; x < x1; x++) {
      if (off < dup_cam.capacity) {
        key_hi[off] = y * dup_cam.tiles_x + x;
        key_lo[off] = depth;
        key_value[off] = i;
      }
      off++;
    }
  }
}

var<workgroup> sh_xy_o: array<vec4f, 256>;   // x, y, opacity, -
var<workgroup> sh_conic: array<vec4f, 256>;
var<workgroup> sh_rgb: array<vec4f, 256>;
var<workgroup> wg_done: atomic<u32>;
var<workgroup> wg_done_n: u32;

@compute @workgroup_size(16, 16)
fn gs_render(@builtin(local_invocation_id) lxy: vec3u,
             @builtin(local_invocation_index) lid: u32,
             @builtin(workgroup_id) wid: vec3u) {
  let W = rd_cam.width;
  let H = rd_cam.height;
  let pix = vec2u(wid.x * 16u + lxy.x, wid.y * 16u + lxy.y);
  let inside = pix.x < W && pix.y < H;
  let pixf = vec2f(pix);
  let tile = wid.y * rd_cam.tiles_x + wid.x;
  let start = rd_ranges[2u * tile];
  let end = max(rd_ranges[2u * tile + 1u], start);
  var done = !inside;
  var T = 1.0;
  var C = vec3f(0.0);
  var next = start;
  loop {
    if (next >= end) { break; }
    if (lid == 0u) { atomicStore(&wg_done, 0u); }
    workgroupBarrier();
    if (done) { atomicAdd(&wg_done, 1u); }
    workgroupBarrier();
    if (lid == 0u) { wg_done_n = atomicLoad(&wg_done); }
    let all_done = workgroupUniformLoad(&wg_done_n);
    if (all_done == 256u) { break; }
    let k = next + lid;
    if (k < end) {
      let id = rd_values[k];
      let a = rd_prims[3u * id];
      sh_xy_o[lid] = vec4f(a.x, a.y, a.w, 0.0);
      sh_conic[lid] = rd_prims[3u * id + 1u];
      sh_rgb[lid] = rd_prims[3u * id + 2u];
    }
    workgroupBarrier();
    let count = min(256u, end - next);
    for (var j = 0u; j < count; j++) {
      if (!done) {
        let xo = sh_xy_o[j];
        let co = sh_conic[j];
        let d = xo.xy - pixf;
        let power = -0.5 * (co.x * d.x * d.x + co.z * d.y * d.y) - co.y * d.x * d.y;
        if (power <= 0.0) {
          let alpha = min(0.99, xo.z * exp(power));
          if (alpha >= 1.0 / 255.0) {
            let test_T = T * (1.0 - alpha);
            if (test_T < 0.0001) {
              done = true;
            } else {
              C = C + sh_rgb[j].xyz * alpha * T;
              T = test_T;
            }
          }
        }
      }
    }
    workgroupBarrier();
    next = next + 256u;
  }
  if (inside) {
    let o = rgb_out(C + T * rd_cam.background.xyz);
    let plane = W * H;
    let q = pix.y * W + pix.x;
    rd_out[q] = o.x;
    rd_out[plane + q] = o.y;
    rd_out[2u * plane + q] = o.z;
  }
}

fn rgb_out(c: vec3f) -> vec3f {
  return c;
}
