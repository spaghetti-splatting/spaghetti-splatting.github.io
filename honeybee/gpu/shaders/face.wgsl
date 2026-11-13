// P2: the amplitude factor 1 / K of the face Gaussians, a port of
// LineSplatScene._face_peak_factor (linesplat/scene.py, from line 2969).
// A face row has A = B = seg_mid, so the centre is endpoint A. The frame and
// the 1/e scales come from the payload uni: for a zero-length row the payload
// keeps the stored column order. The view-space leaf offset is None in the
// evaluation, so the centre takes no offset. Every other row keeps the
// factor 1 (the buffer starts at 1).
// In the frame, P2 runs over the kept rows. With cam.diag = 1 it runs over
// all N rows, which fills the diagnostic diag_face_factor.f32.

@group(0) @binding(0) var<storage, read> endpoints: array<f32>;   // [N, 2, 3]
@group(0) @binding(1) var<storage, read> uni: array<f32>;         // [N, 8]
@group(0) @binding(2) var<storage, read> s3d: array<f32>;         // [N]
@group(0) @binding(3) var<storage, read> face: array<u32>;        // [N]
@group(0) @binding(4) var<storage, read> kept_rows: array<u32>;   // [K]
@group(0) @binding(5) var<storage, read> counts: array<u32>;
@group(0) @binding(6) var<storage, read_write> face_factor: array<f32>; // [N]
@group(0) @binding(7) var<uniform> cam: Camera;

const AA3D_CLIP_W_MIN: f32 = 1e-3;
const FACE_PEAK_K_MIN: f32 = 1e-12;

fn pm(k: u32) -> f32 {
  return cam.proj[k >> 2u][k & 3u];
}

@compute @workgroup_size(256)
fn face_factor_pass(@builtin(local_invocation_index) lid: u32,
                    @builtin(workgroup_id) wid: vec3u,
                    @builtin(num_workgroups) nwg: vec3u) {
  let index = linear_group(wid, nwg) * WORKGROUP_SIZE + lid;
  var row = index;
  if (cam.diag != 0u) {
    if (index >= cam.rows) {
      return;
    }
  } else {
    if (index >= counts[SLOT_KEPT]) {
      return;
    }
    row = kept_rows[index];
  }
  if (face[row] == 0u) {
    return;
  }
  let p = 6u * row;
  let cx = endpoints[p];
  let cy = endpoints[p + 1u];
  let cz = endpoints[p + 2u];
  // hom = (centre, 1) @ proj_matrix.
  let hx = cx * pm(0u) + cy * pm(4u) + cz * pm(8u) + pm(12u);
  let hy = cx * pm(1u) + cy * pm(5u) + cz * pm(9u) + pm(13u);
  let hw = cx * pm(3u) + cy * pm(7u) + cz * pm(11u) + pm(15u);
  let kept = hw > AA3D_CLIP_W_MIN && is_finite(hw) && hx + hw >= 0.0
      && hw - hx >= 0.0 && hy + hw >= 0.0 && hw - hy >= 0.0;
  if (!kept) {
    face_factor[row] = 1.0;
    return;
  }
  let u = 8u * row;
  let qw = uni[u];
  let qx = uni[u + 1u];
  let qy = uni[u + 2u];
  let qz = uni[u + 3u];
  let s = vec3f(uni[u + 4u], uni[u + 5u], uni[u + 6u]);
  // _quat_to_rotmat of the unit quaternion (w, x, y, z).
  let r = mat3x3f(
      vec3f(1.0 - 2.0 * (qy * qy + qz * qz), 2.0 * (qx * qy + qw * qz), 2.0 * (qx * qz - qw * qy)),
      vec3f(2.0 * (qx * qy - qw * qz), 1.0 - 2.0 * (qx * qx + qz * qz), 2.0 * (qy * qz + qw * qx)),
      vec3f(2.0 * (qx * qz + qw * qy), 2.0 * (qy * qz - qw * qx), 1.0 - 2.0 * (qx * qx + qy * qy)));
  // r[j] is column j of the rotation: r[j][i] = R[i][j].
  let inverse_w2 = 1.0 / (hw * hw);
  let jx = cam.half_width * (hw * vec3f(pm(0u), pm(4u), pm(8u))
      - hx * vec3f(pm(3u), pm(7u), pm(11u))) * inverse_w2;
  let jy = cam.half_height * (hw * vec3f(pm(1u), pm(5u), pm(9u))
      - hy * vec3f(pm(3u), pm(7u), pm(11u))) * inverse_w2;
  // m[a][j] = (sum_i J[a][i] R[i][j]) s[j].
  let m0 = vec3f(dot(jx, r[0]), dot(jx, r[1]), dot(jx, r[2])) * s;
  let m1 = vec3f(dot(jy, r[0]), dot(jy, r[1]), dot(jy, r[2])) * s;
  var c00 = dot(m0, m0) + cam.face_pixel_variance;
  var c01 = dot(m0, m1);
  var c11 = dot(m1, m1) + cam.face_pixel_variance;
  let world_variance = s3d[row] * s3d[row];
  c00 = c00 + world_variance * dot(jx, jx);
  c01 = c01 + world_variance * dot(jx, jy);
  c11 = c11 + world_variance * dot(jy, jy);
  let area = 0.5 * s.x * (s.y + s.z);
  let normal = length(cross(jx, jy));
  let k = area * normal / sqrt(c00 * c11 - c01 * c01);
  // clamp_min keeps a NaN.
  var clamped = k;
  if (!is_nan(k)) {
    clamped = max(k, FACE_PEAK_K_MIN);
  }
  face_factor[row] = 1.0 / clamped;
}
