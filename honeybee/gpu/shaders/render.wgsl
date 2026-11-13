// P9: the colour-only render, a port of renderCUDA<EvalColorOnly, PerSegment>
// (forward.cu) with LoadPrimitiveBatch, StageColorOnlyRecord,
// screenColorOnlyRecord and screenEvaluateFragmentColorOnly (auxiliary.h).
// One workgroup of 16 x 16 threads (BLOCK_X, BLOCK_Y) renders one tile; one
// thread renders one pixel. The workgroup stages batches of 256 primitives
// in workgroup memory. The block-wide done vote (__syncthreads_count) is a
// workgroup atomic counter between barriers. The explicit fmaf calls of the
// source use the WGSL fma; rsqrtf becomes inverseSqrt and __expf exp.

struct Prim {
  aniso: vec4f,
  bis: vec4f,
  ab: vec4f,
  geo: vec4f,
  rect: vec4u,
};

@group(0) @binding(0) var<storage, read> ranges: array<u32>;       // [tiles, 2]
@group(0) @binding(1) var<storage, read> point_list: array<u32>;   // sorted values
@group(0) @binding(2) var<storage, read> prims: array<Prim>;       // [K]
@group(0) @binding(3) var<storage, read> rgb: array<f32>;          // [K, 3]
@group(0) @binding(4) var<storage, read_write> out_color: array<f32>; // [3, H, W]
@group(0) @binding(5) var<uniform> cam: Camera;

const BLOCK_SIZE: u32 = 256u;
const UNI_SCREEN_POINT_LAMBDA: f32 = 0.1;
const UNI_ERF_FIT_SATURATION: f32 = 12.0;
const UNI_FAST_AXIAL_2C: f32 = 2.2567583;
const UNI_FAST_AXIAL_A: f32 = 0.08945;
const SQRT_PI_SCREEN: f32 = 1.7724538509055159;
const HALF_SQRT_PI_SCREEN: f32 = 0.88622692545275801;
const MIN_ALPHA_SKIP: f32 = 0.0;

// The colour-only record of the batch (17 words for each primitive).
var<workgroup> batch_id: array<u32, 256>;
var<workgroup> batch_lane0: array<vec4f, 256>;
var<workgroup> batch_lane1: array<vec4f, 256>;
var<workgroup> batch_a2: array<vec2f, 256>;
var<workgroup> batch_e: array<vec2f, 256>;
var<workgroup> batch_bis: array<vec4f, 256>;
var<workgroup> done_votes: atomic<u32>;
var<workgroup> done_total: u32;

fn fast_axial_sigmoid(u: f32) -> f32 {
  let z = u * fma(UNI_FAST_AXIAL_A, u * u, 1.0);
  return 1.0 / (1.0 + exp(-UNI_FAST_AXIAL_2C * z));
}

// screenStationUnfiltered: rho_theta U(g), the value alone.
fn station_unfiltered(q0: f32, lambda_int: f32, g: f32) -> f32 {
  let lambda_u = lambda_int / g;
  var unit: f32;
  if (lambda_int < UNI_SCREEN_POINT_LAMBDA * g) {
    let g2 = g * g;
    let twelfth = lambda_int * lambda_int / 12.0;
    let dg2 = g2 - twelfth;
    unit = g2 * g2 / dg2;
  } else if (lambda_u < UNI_ERF_FIT_SATURATION) {
    let x = 0.5 * lambda_u;
    let cubic = fma(UNI_FAST_AXIAL_A, x * x, 1.0);
    let t = exp(-UNI_FAST_AXIAL_2C * x * cubic);
    unit = lambda_int * g * (1.0 + t) / (SQRT_PI_SCREEN * (1.0 - t));
  } else {
    unit = lambda_int * g / SQRT_PI_SCREEN;
  }
  return q0 * unit;
}

struct Fragment {
  keep: bool,  // false outside the extent level set
  tau: f32,
};

// screenEvaluateFragmentColorOnly<PerSegment>: the optical depth of a kept
// fragment.
fn evaluate_fragment(lane0: vec4f, lane1: vec4f, zab: vec4f, ex: f32, ey: f32,
                     dx: f32, dy: f32, beta: f32) -> Fragment {
  var fragment = Fragment(false, 0.0);
  let point_limit = sign_bit(lane1.w);
  let cutoff = zab.z;
  let ratio_a = abs(lane1.w);
  let ratio_b = abs(zab.w);
  let eta = lane0.z;
  let eps = lane0.w;
  let det3 = lane1.x;
  let tr3 = lane1.y;
  var tau_geo: f32;
  var g: f32;
  if (point_limit) {
    g = ratio_a + 0.5 * (ratio_b - ratio_a);
    let gg = g * g;
    let det = fma(gg, fma(gg, det3, beta * tr3), beta * beta);
    let qx = dx - 0.5 * ex;
    let qy = dy - 0.5 * ey;
    let adj_qx = lane0.x * qx + lane0.y * qy;
    let adj_qy = lane0.y * qx + lane1.z * qy;
    let exponent_adj = gg * (qx * adj_qx + qy * adj_qy) + beta * (qx * qx + qy * qy);
    if (exponent_adj > cutoff * det) {
      return fragment;
    }
    let inv_root_det = inverseSqrt(det);
    let inv_det = inv_root_det * inv_root_det;
    let exponent = exponent_adj * inv_det;
    let h = fma(gg, eta, beta * eps) * inv_det;
    let rho_edge = (gg * (ex * adj_qx + ey * adj_qy) + beta * (ex * qx + ey * qy)) * inv_det;
    let peak = 1.0 - h / 12.0;
    let shape = peak + rho_edge * rho_edge / 6.0;
    let exp_term = exp(-fmaxf(exponent, 0.0));
    tau_geo = exp_term * shape * inv_root_det;
  } else {
    // 1. The station of this pixel on the chord.
    let a3d = lane0.x * dx + lane0.y * dy;
    let beta_ed = beta * (ex * dx + ey * dy);
    let t_star = fminf(fmaxf((a3d + beta_ed) * lane1.z, 0.0), 1.0);
    g = ratio_a + t_star * (ratio_b - ratio_a);
    let gg = g * g;
    // 2. The two forms of the station conic and its determinant.
    let h_adj = fma(gg, eta, beta * eps);
    let rd = fma(gg, a3d, beta_ed);
    let det = fma(gg, fma(gg, det3, beta * tr3), beta * beta);
    // 3. The capsule level set.
    let cross = dx * ey - dy * ex;
    let cross2 = cross * cross;
    let cutoff_h_adj = cutoff * h_adj;
    if (cross2 > cutoff_h_adj) {
      return fragment;
    }
    let rd_b = h_adj - rd;
    let nearer = fminf(rd, rd_b);
    if (nearer < 0.0 && nearer * nearer > cutoff_h_adj * det) {
      return fragment;
    }
    // 4. The kept fragment.
    let inv_root_h_adj = inverseSqrt(h_adj);
    let rs = inv_root_h_adj * inverseSqrt(det);
    let inv_h_adj = inv_root_h_adj * inv_root_h_adj;
    let exponent = cross2 * inv_h_adj;
    let u0 = rd * rs;
    let u1 = rd_b * rs;
    let s0 = fast_axial_sigmoid(u0);
    let s1 = fast_axial_sigmoid(u1);
    let bp_raw = 2.0 * (s0 + s1 - 1.0);
    let exp_term = exp(-exponent);
    tau_geo = select(0.0, exp_term * bp_raw * HALF_SQRT_PI_SCREEN * inv_root_h_adj, bp_raw > 0.0);
  }
  fragment.keep = true;
  fragment.tau = station_unfiltered(zab.x, zab.y, g) * tau_geo;
  return fragment;
}

@compute @workgroup_size(16, 16)
fn render(@builtin(local_invocation_id) local: vec3u,
          @builtin(local_invocation_index) lid: u32,
          @builtin(workgroup_id) wid: vec3u) {
  let width = cam.width;
  let height = cam.height;
  let beta = cam.beta;
  let pix = vec2u(wid.x * 16u + local.x, wid.y * 16u + local.y);
  let inside = pix.x < width && pix.y < height;
  let pixf = vec2f(f32(pix.x), f32(pix.y));
  var done = !inside;
  let tile_id = wid.y * cam.tiles_x + wid.x;
  let range_start = ranges[2u * tile_id];
  let range_end = ranges[2u * tile_id + 1u];
  let rounds = (range_end - range_start + BLOCK_SIZE - 1u) / BLOCK_SIZE;
  var to_do = i32(range_end - range_start);
  var transmittance = 1.0;
  var color = vec3f(0.0);

  for (var i = 0u; i < rounds; i = i + 1u) {
    // __syncthreads_count(done): the block stops when every pixel is done.
    if (lid == 0u) {
      atomicStore(&done_votes, 0u);
    }
    workgroupBarrier();
    if (done) {
      atomicAdd(&done_votes, 1u);
    }
    workgroupBarrier();
    if (lid == 0u) {
      done_total = atomicLoad(&done_votes);
    }
    let num_done = workgroupUniformLoad(&done_total);
    if (num_done == BLOCK_SIZE) {
      break;
    }

    // LoadPrimitiveBatch with StageColorOnlyRecord.
    let progress = i * BLOCK_SIZE + lid;
    if (range_start + progress < range_end) {
      let coll_id = point_list[range_start + progress];
      batch_id[lid] = coll_id;
      // The colour-only route reads the taper lane, the two endpoints and
      // the bisector lane alone.
      let taper = prims[coll_id].aniso;
      let ab = prims[coll_id].ab;
      let a2 = ab.xy;
      let b2 = ab.zw;
      // screenColorOnlyRecord.
      let ex = b2.x - a2.x;
      let ey = b2.y - a2.y;
      let a3x = taper.z * ex - taper.y * ey;
      let a3y = taper.x * ey - taper.y * ex;
      let eta = fmaxf(ex * a3x + ey * a3y, 0.0);
      let eps = ex * ex + ey * ey;
      let det3 = fmaxf(taper.x * taper.z - taper.y * taper.y, 0.0);
      let tr3 = taper.x + taper.z;
      if (sign_bit(taper.w)) {
        batch_lane0[lid] = vec4f(taper.z, -taper.y, eta, eps);
        batch_lane1[lid] = vec4f(det3, tr3, taper.x, taper.w);
      } else {
        batch_lane0[lid] = vec4f(a3x, a3y, eta, eps);
        batch_lane1[lid] = vec4f(det3, tr3, 1.0 / (eta + beta * eps), taper.w);
      }
      batch_a2[lid] = a2;
      batch_e[lid] = vec2f(ex, ey);
      batch_bis[lid] = prims[coll_id].bis;
    }
    workgroupBarrier();

    let batch_count = u32(min(i32(BLOCK_SIZE), to_do));
    for (var j = 0u; !done && j < batch_count; j = j + 1u) {
      let a2 = batch_a2[j];
      let e = batch_e[j];
      let fragment = evaluate_fragment(batch_lane0[j], batch_lane1[j], batch_bis[j], e.x, e.y,
                                       pixf.x - a2.x, pixf.y - a2.y, beta);
      if (!fragment.keep) {
        continue;  // The level-set reject: the fragment writes nothing.
      }
      let alpha = fminf(1.0 - exp(-fragment.tau), 0.9999);
      let test_t = transmittance * (1.0 - alpha);
      if (alpha < MIN_ALPHA_SKIP) {
        continue;
      }
      let c = 3u * batch_id[j];
      color = color + vec3f(rgb[c], rgb[c + 1u], rgb[c + 2u]) * alpha * transmittance;
      transmittance = test_t;
      if (test_t < 0.0001) {
        done = true;
      }
    }
    to_do = to_do - i32(BLOCK_SIZE);
  }

  if (inside) {
    let plane = width * height;
    let pix_id = width * pix.y + pix.x;
    out_color[pix_id] = color.x + transmittance * cam.background.x;
    out_color[plane + pix_id] = color.y + transmittance * cam.background.y;
    out_color[2u * plane + pix_id] = color.z + transmittance * cam.background.z;
  }
}
