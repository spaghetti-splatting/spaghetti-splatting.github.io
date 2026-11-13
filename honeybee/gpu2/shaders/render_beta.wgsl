// P9 of a Beta-kernel model: a port of renderCUDA<EvalColorOnly, COLOR,
// BetaKernel<BetaFit::Eval>> (forward.cu of the code tree 7cdb6976) for the
// colour laws PerSegment and Textured, with LoadPrimitiveBatch,
// StageColorOnlyRecord, screenColorOnlyRecord,
// screenEvaluateFragmentColorOnly (auxiliary.h), the eval tier of
// kernels/beta.cuh (long_chord_fast, short_chord, the axial peak, the foot)
// and the tube texture (tubeTextureRay, tubeTextureSample,
// tubeTextureColor). render.wgsl, the Gaussian render, does not change.
//
// One workgroup of 16 x 16 threads renders one tile; one thread renders one
// pixel. CUDA stages 64 primitives per round for this render
// (RENDER_EVAL_BATCH); the port stages 256. The order of the fragments of a
// pixel and the stop of a pixel do not depend on the batch size, so the
// image does not change. The batch loader forms the eval-tier coefficient
// set of each staged primitive from the exponent of its kernel record
// (BetaKernel::stage<Render>). The explicit fmaf calls of the source use the
// WGSL fma (as render.wgsl); rsqrtf -> inverseSqrt, __expf -> exp,
// __log2f -> log2, exp2f -> exp2, atan2f -> atan2.

struct PrimBeta {
  aniso: vec4f,
  bis: vec4f,
  ab: vec4f,
  geo: vec4f,
  rect: vec4u,
  record: vec4f,
  outline0: vec4f,
  outline1: vec4f,
  outline2: vec4f,
};

// The texture inputs of a Textured render (TubeTexture) and the colour law.
struct BetaParams {
  tan_fovx: f32,
  tan_fovy: f32,
  principal_x: f32,  // P02
  principal_y: f32,  // P12
  axial: u32,        // K_t
  around: u32,       // K_phi
  textured: u32,     // 1: ColorMode::Textured; 0: ColorMode::PerSegment
  pad0: u32,
};

@group(0) @binding(0) var<storage, read> ranges: array<u32>;         // [tiles, 2]
@group(0) @binding(1) var<storage, read> point_list: array<u32>;     // sorted values
@group(0) @binding(2) var<storage, read> prims: array<PrimBeta>;     // [K]
@group(0) @binding(3) var<storage, read> rgb: array<f32>;            // [K, 3]
@group(0) @binding(4) var<storage, read> prim_aux: array<vec4u>;     // [K] (beta_gather.wgsl)
@group(0) @binding(5) var<storage, read> tex_frame: array<f32>;      // [M, 12] or a dummy
@group(0) @binding(6) var<storage, read> tex_texels: array<f32>;     // [M, K_t, K_phi, 3] or a dummy
@group(0) @binding(7) var<storage, read_write> out_color: array<f32>; // [3, H, W]
@group(0) @binding(8) var<uniform> cam: Camera;
@group(0) @binding(9) var<uniform> bp: BetaParams;

const BLOCK_SIZE: u32 = 256u;
const UNI_SCREEN_POINT_LAMBDA: f32 = 0.1;
const MIN_ALPHA_SKIP: f32 = 0.0;
const BETA_FOOT_FLOOR: f32 = 1.0e-30;
const BETA_GRADIENT_FLOOR: f32 = 1.0e-4;
const BETA_SERIES_LIMIT: f32 = 0.1;
const BETA_FLT_MIN: f32 = 1.17549435e-38;
const BETA_SQRT2: f32 = 1.41421356;
const BETA_INV_SQRT2: f32 = 0.707106781;
const BETA_FIT_Z_SCALE: f32 = -3.1215594;
const BETA_FIT_Z_OFF: f32 = 1.8495809;

// The eval tier of the fit (BetaFit::Eval): N_p = 6 terms, Chebyshev degree
// 3, and the degree 4 of the series of F(1) and 1 / F(1).
const EVAL_TERMS: u32 = 6u;
const EVAL_VALUES: u32 = 8u;  // RENDER_VALUES = 1 + (N_p + 1)
const EVAL_POLYNOMIAL = array<f32, 24>(
  -1.0, 0.0, 0.0, 0.0,
  0.8639625, -0.080043316, 0.011840287, -0.00032925335,
  -0.65780294, 0.16117837, -0.025375213, 0.0017560583,
  0.40191287, -0.1712049, 0.028378023, -0.0027375722,
  -0.16230038, 0.09921428, -0.017412446, 0.0016617817,
  0.030476268, -0.023956835, 0.004615334, -0.00040338145);
const EVAL_PEAK = array<f32, 5>(
  0.9317711, -0.04327248, 0.0059742285, 8.387385e-06, -1.3679006e-05);
const EVAL_INVERSE_PEAK = array<f32, 5>(
  1.0743953, 0.049604684, -0.005744186, -0.00030108364, 2.7100898e-05);

// The colour-only record of the batch, the staged values of the kernel
// object of each slot (gamma, p_0 .. p_6), a2 B of the record, and the
// texture slot.
var<workgroup> batch_id: array<u32, 256>;
var<workgroup> batch_lane0: array<vec4f, 256>;
var<workgroup> batch_lane1: array<vec4f, 256>;
var<workgroup> batch_a2: array<vec2f, 256>;
var<workgroup> batch_e: array<vec2f, 256>;
var<workgroup> batch_bis: array<vec4f, 256>;
var<workgroup> batch_shape: array<array<f32, 8>, 256>;
var<workgroup> batch_filter: array<f32, 256>;
var<workgroup> batch_slot: array<i32, 256>;
var<workgroup> done_votes: atomic<u32>;
var<workgroup> done_total: u32;

// The kernel object of one fragment: its staged values and the series of
// its exponent (fill_series).
var<private> staged: array<f32, 8>;
var<private> series_y: array<f32, 5>;

fn vm(k: u32) -> f32 {
  return cam.view[k >> 2u][k & 3u];
}

// BetaKernel::stage<Render> with betaFitSet<Eval, Render>, into slot `slot`
// of the batch.
fn stage_eval(slot: u32, gamma: f32) {
  batch_shape[slot][0] = gamma;
  let gp1 = gamma + 1.0;
  let r = inverseSqrt(gp1);
  let z = fma(r, BETA_FIT_Z_SCALE, BETA_FIT_Z_OFF);
  let z2 = z + z;
  var t: array<f32, 5>;
  t[0] = 1.0;
  t[1] = z;
  for (var j = 2u; j <= 4u; j = j + 1u) {
    t[j] = fma(z2, t[j - 1u], -t[j - 2u]);
  }
  var d: array<f32, 6>;
  for (var k = 0u; k < EVAL_TERMS; k = k + 1u) {
    var acc = EVAL_POLYNOMIAL[k * 4u];
    for (var j = 1u; j <= 3u; j = j + 1u) {
      acc = fma(EVAL_POLYNOMIAL[k * 4u + j], t[j], acc);
    }
    d[k] = acc;
  }
  var g = EVAL_PEAK[0];
  var g_inverse = EVAL_INVERSE_PEAK[0];
  for (var j = 1u; j <= 4u; j = j + 1u) {
    g = fma(EVAL_PEAK[j], t[j], g);
    g_inverse = fma(EVAL_INVERSE_PEAK[j], t[j], g_inverse);
  }
  let f1 = r * g;
  let inverse_f1 = (gp1 * r) * g_inverse;
  batch_shape[slot][1] = f1;
  batch_shape[slot][2] = d[0];
  var power = inverse_f1;
  for (var k = 1u; k < EVAL_TERMS; k = k + 1u) {
    batch_shape[slot][k + 2u] = d[k] * power;
    power = power * inverse_f1;
  }
}

// The kernel object of the staged slot j, and fill_series.
fn load_kernel(j: u32) {
  for (var k = 0u; k < EVAL_VALUES; k = k + 1u) {
    staged[k] = batch_shape[j][k];
  }
  let gamma = staged[0];
  let r2 = fma(gamma, -0.3, 0.3);
  let r3 = fma(gamma, -5.0 / 21.0, 10.0 / 21.0);
  let r4 = fma(gamma, -7.0 / 36.0, 21.0 / 36.0);
  series_y[0] = 1.0;
  series_y[1] = gamma * (-1.0 / 3.0);
  series_y[2] = series_y[1] * r2;
  series_y[3] = series_y[2] * r3;
  series_y[4] = series_y[3] * r4;
}

struct Endpoint {
  v: f32,
  lw: f32,
  psi: f32,
  complement: f32,
  value: f32,
  series: bool,
};

// BetaKernel::endpoint.
fn beta_endpoint(v: f32) -> Endpoint {
  let gamma = staged[0];
  var end: Endpoint;
  end.v = v;
  let omega = fmaxf(fma(-v, v, 1.0), BETA_FLT_MIN);
  end.lw = log2(omega);
  end.psi = exp2((gamma + 1.0) * end.lw);
  var acc = staged[1u + EVAL_TERMS];
  for (var k = i32(EVAL_TERMS) - 1; k >= 0; k = k - 1) {
    acc = fma(acc, v, staged[1 + k]);
  }
  end.complement = end.psi * acc;
  let u = v * v;
  var sum = series_y[4];
  for (var n = 3; n >= 0; n = n - 1) {
    sum = fma(sum, u, series_y[n]);
  }
  end.series = v <= BETA_SERIES_LIMIT;
  end.value = select(staged[1] - end.complement, sum * v, end.series);
  return end;
}

// BetaKernel::axial_peak, the value P.
fn axial_peak(lambda: f32) -> f32 {
  let gamma = staged[0];
  if (lambda < UNI_SCREEN_POINT_LAMBDA) {
    let base = fma(-0.3 * lambda, lambda, 1.0);
    let power = exp2(gamma * log2(base));
    return fma(5.0 / 9.0, power, 4.0 / 9.0);
  } else if (lambda <= BETA_SQRT2) {
    let v = lambda * BETA_INV_SQRT2;
    return beta_endpoint(v).value / v;
  }
  return BETA_SQRT2 * staged[1] / lambda;
}

// screenStationUnfiltered: rho_theta U(g) = Q0 g^2 / P(lambda_int / g).
fn station_unfiltered(q0: f32, lambda_int: f32, g: f32) -> f32 {
  let p = axial_peak(lambda_int / g);
  return q0 * (g * g / p);
}

// betaInterval: D = F(v_hi) - F(v_lo).
fn beta_interval(lo: Endpoint, hi: Endpoint, positive: bool, negative: bool) -> f32 {
  let both_series = lo.series && hi.series;
  let f_hi = select(lo.value, hi.value, positive);
  let f_lo = select(hi.value, lo.value, positive);
  let small = f_hi - f_lo;
  let tail_positive = lo.complement - hi.complement;
  let tail = select(-tail_positive, tail_positive, positive);
  let cross = hi.value + lo.value;
  return select(cross, select(tail, small, both_series), positive || negative);
}

struct Fragment {
  keep: bool,   // false outside the extent level set
  tau: f32,
  t_bar: f32,
};

// screenEvaluateFragmentColorOnly<COLOR, BetaKernel<Eval>> for the staged
// slot j. The foot t_bar is formed only for a Textured render (forms_foot).
fn evaluate_fragment(j: u32, lane0: vec4f, lane1: vec4f, zab: vec4f, ex: f32, ey: f32,
                     dx: f32, dy: f32, beta: f32, textured: bool) -> Fragment {
  var fragment = Fragment(false, 0.0, 0.5);
  let point_limit = sign_bit(lane1.w);
  let cutoff = zab.z;
  let ratio_a = abs(lane1.w);
  let ratio_b = abs(zab.w);
  let eta = lane0.z;
  let eps = lane0.w;
  let det3 = lane1.x;
  let tr3 = lane1.y;
  var tau_geo: f32;
  var unfiltered: f32;
  if (point_limit) {
    let g = ratio_a + 0.5 * (ratio_b - ratio_a);
    let gg = g * g;
    let det = fma(gg, fma(gg, det3, beta * tr3), beta * beta);
    let qx = dx - 0.5 * ex;
    let qy = dy - 0.5 * ey;
    let adj_qx = lane0.x * qx + lane0.y * qy;
    let adj_qy = lane0.y * qx + lane1.z * qy;
    let exponent_adj = gg * (qx * adj_qx + qy * adj_qy) + beta * (qx * qx + qy * qy);
    let h_adj = fma(gg, eta, beta * eps);
    let rho_adj = gg * (ex * adj_qx + ey * adj_qy) + beta * (ex * qx + ey * qy);
    // The capsule level set of the chord in the station conic.
    let rho_adj_abs = abs(rho_adj);
    var outside: bool;
    if (2.0 * rho_adj_abs < h_adj) {
      outside = (exponent_adj - cutoff * det) * h_adj > rho_adj * rho_adj;
    } else {
      outside = exponent_adj - rho_adj_abs + 0.25 * h_adj > cutoff * det;
    }
    if (outside) {
      return fragment;
    }
    load_kernel(j);
    unfiltered = station_unfiltered(zab.x, zab.y, g);
    let inv_root_det = inverseSqrt(det);
    let inv_det = inv_root_det * inv_root_det;
    let exponent = exponent_adj * inv_det;
    let h = h_adj * inv_det;
    let rho_edge = rho_adj * inv_det;
    // BetaKernel::short_chord(max(q2, 0), h, rho_edge).
    let q2 = fmaxf(exponent, 0.0);
    let dsc = fma(rho_edge, rho_edge, h * (0.5 - q2));
    let root = sqrt(fmaxf(dsc, 0.0));
    let big_r = rho_edge + select(root, -root, sign_bit(rho_edge));
    var r_lo = -1.0;
    var r_hi = 1.0;
    var support = dsc >= 0.0;
    if (big_r == 0.0) {
      support = support && q2 < 0.5;
    } else {
      let t_b = (q2 - 0.5) / big_r;
      if (h > 0.0) {
        let t_a = big_r / h;
        r_lo = fminf(t_a, t_b);
        r_hi = fmaxf(t_a, t_b);
      } else if (rho_edge > 0.0) {
        r_lo = t_b;
      } else {
        r_hi = t_b;
      }
    }
    let root_scale2 = fmaxf(dsc, 0.5 * BETA_GRADIENT_FLOOR * h);
    if (!(root_scale2 > 0.0) && (r_lo > -0.5 || r_hi < 0.5)) {
      r_lo = 0.5;
      r_hi = -0.5;
    }
    let t_lo = fmaxf(r_lo, -0.5);
    let t_hi = fminf(r_hi, 0.5);
    support = support && t_hi > t_lo;
    let half = select(0.0, 0.5 * (t_hi - t_lo), support);
    let mid = 0.5 * (t_hi + t_lo);
    let node = 0.774596669;
    let gamma = staged[0];
    var tk: array<f32, 3>;
    var kk: array<f32, 3>;
    for (var i = 0; i < 3; i = i + 1) {
      tk[i] = fma(half, f32(i - 1) * node, mid);
      let q = fma(tk[i], fma(tk[i], h, -2.0 * rho_edge), q2);
      let base = fma(-2.0, q, 1.0);
      kk[i] = select(0.0, exp2(gamma * log2(base)), support && base > 0.0);
    }
    let side = 5.0 / 9.0;
    let middle = 8.0 / 9.0;
    let weight_sum = fma(side, kk[0] + kk[2], middle * kk[1]);
    tau_geo = half * weight_sum * inv_root_det;
    if (textured) {
      let moment_sum = fma(side, fma(tk[0], kk[0], tk[2] * kk[2]), middle * tk[1] * kk[1]);
      let offset = select(0.0, moment_sum / weight_sum, weight_sum >= BETA_FOOT_FLOOR);
      fragment.t_bar = fminf(fmaxf(0.5 + offset, 0.0), 1.0);
    }
  } else {
    // 1. The station of this pixel on the chord.
    let a3d = lane0.x * dx + lane0.y * dy;
    let beta_ed = beta * (ex * dx + ey * dy);
    let t_star = fminf(fmaxf((a3d + beta_ed) * lane1.z, 0.0), 1.0);
    let g = ratio_a + t_star * (ratio_b - ratio_a);
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
    load_kernel(j);
    unfiltered = station_unfiltered(zab.x, zab.y, g);
    // 4. The kept fragment.
    let inv_root_h_adj = inverseSqrt(h_adj);
    let rs = inv_root_h_adj * inverseSqrt(det);
    let inv_h_adj = inv_root_h_adj * inv_root_h_adj;
    let exponent = cross2 * inv_h_adj;
    let u0 = rd * rs;
    let u1 = rd_b * rs;
    // BetaKernel::long_chord_fast (long_record).
    let a = fma(-2.0, exponent, 1.0);
    let positive_a = a > 0.0;
    let a_safe = select(1.0, a, positive_a);
    let log2_a = log2(a_safe);
    let inverse_c = inverseSqrt(0.5 * a_safe);
    let c = 0.5 * a_safe * inverse_c;
    let v_lo = fminf(fmaxf(-u0 * inverse_c, -1.0), 1.0);
    let v_hi = fminf(fmaxf(u1 * inverse_c, -1.0), 1.0);
    let lo = beta_endpoint(abs(v_lo));
    let hi = beta_endpoint(abs(v_hi));
    let positive = v_lo >= 0.0;
    let negative = v_hi <= 0.0;
    let d_raw = beta_interval(lo, hi, positive, negative);
    let live = positive_a && d_raw > 0.0;
    let gamma = staged[0];
    let a_power = exp2(gamma * log2_a);
    if (textured) {
      // The foot: t_bar = foot + M / (lambda L) (long_foot_offset).
      let lambda = h_adj * rs;
      let foot = rd * inv_h_adj;
      let d_live = select(0.0, d_raw, live);
      let foot_live = live && lambda * (c * d_live) >= BETA_FOOT_FLOOR;
      let d_safe = select(1.0, d_live, foot_live);
      let delta = lo.psi - hi.psi;
      let offset = select(0.0, c * delta / (2.0 * (gamma + 1.0) * lambda * d_safe), foot_live);
      fragment.t_bar = fminf(fmaxf(foot + offset, 0.0), 1.0);
    }
    let l = c * a_power * d_raw;
    tau_geo = select(0.0, l * inv_root_h_adj, live);
  }
  fragment.keep = true;
  fragment.tau = unfiltered * tau_geo;
  return fragment;
}

// tubeTextureSample and tubeTextureColor: the texture colour M(u, v) of one
// fragment of the slot.
fn texture_color(slot: u32, origin: vec3f, ray: vec3f, u: f32) -> vec3f {
  let f = 12u * slot;
  let point_a = vec3f(tex_frame[f], tex_frame[f + 1u], tex_frame[f + 2u]);
  let f1 = vec3f(tex_frame[f + 3u], tex_frame[f + 4u], tex_frame[f + 5u]);
  let f2 = vec3f(tex_frame[f + 6u], tex_frame[f + 7u], tex_frame[f + 8u]);
  let rho = tex_frame[f + 9u];
  let offset = origin - point_a;
  let o1 = offset.x * f1.x + offset.y * f1.y + offset.z * f1.z;
  let o2 = offset.x * f2.x + offset.y * f2.y + offset.z * f2.z;
  let d1 = ray.x * f1.x + ray.y * f1.y + ray.z * f1.z;
  let d2 = ray.x * f2.x + ray.y * f2.y + ray.z * f2.z;
  let alpha = d1 * d1 + d2 * d2;
  var v = 0.5;
  if (alpha != 0.0 && is_finite(alpha) && is_finite(o1) && is_finite(o2)) {
    let lambda_c = -(o1 * d1 + o2 * d2) / alpha;
    let c1 = o1 + lambda_c * d1;
    let c2 = o2 + lambda_c * d2;
    let q = rho * rho - (c1 * c1 + c2 * c2);
    var p1 = c1;
    var p2 = c2;
    if (q >= 0.0) {
      let half_chord = sqrt(q / alpha);
      if (lambda_c - half_chord > 0.0) {
        p1 = c1 - half_chord * d1;
        p2 = c2 - half_chord * d2;
      } else if (lambda_c + half_chord > 0.0) {
        p1 = c1 + half_chord * d1;
        p2 = c2 + half_chord * d2;
      }
    }
    if (is_finite(p1) && is_finite(p2)) {
      v = atan2(p2, p1) * 0.15915494309189535 + 0.5;
    }
  }
  let axial = i32(bp.axial);
  let around = i32(bp.around);
  let x = u * f32(axial - 1);
  let i0 = min(i32(floor(x)), axial - 2);
  let wx = x - f32(i0);
  let y = v * f32(around) - 0.5;
  let fy = floor(y);
  let j0 = ((i32(fy) % around) + around) % around;
  let j1 = (j0 + 1) % around;
  let wy = y - fy;
  let texel = array<i32, 4>(i0 * around + j0, (i0 + 1) * around + j0,
                            i0 * around + j1, (i0 + 1) * around + j1);
  let weight = array<f32, 4>((1.0 - wx) * (1.0 - wy), wx * (1.0 - wy),
                             (1.0 - wx) * wy, wx * wy);
  let base = slot * 3u * bp.axial * bp.around;
  var color = vec3f(0.0);
  for (var ch = 0u; ch < 3u; ch = ch + 1u) {
    var value = 0.0;
    for (var k = 0u; k < 4u; k = k + 1u) {
      value = value + weight[k] * tex_texels[base + 3u * u32(texel[k]) + ch];
    }
    color[ch] = value;
  }
  return color;
}

@compute @workgroup_size(16, 16)
fn render_beta(@builtin(local_invocation_id) local: vec3u,
               @builtin(local_invocation_index) lid: u32,
               @builtin(workgroup_id) wid: vec3u) {
  let width = cam.width;
  let height = cam.height;
  let textured = bp.textured != 0u;
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

  // tubeTextureRay: the camera ray of this pixel.
  var ray_origin = vec3f(0.0);
  var ray = vec3f(0.0);
  if (textured) {
    ray_origin = cam.campos.xyz;
    let nx = (2.0 * pixf.x + 1.0) / f32(width) - 1.0;
    let ny = (2.0 * pixf.y + 1.0) / f32(height) - 1.0;
    let rx = (nx - bp.principal_x) * bp.tan_fovx;
    let ry = (ny - bp.principal_y) * bp.tan_fovy;
    let rz = 1.0;
    ray = vec3f(vm(0u) * rx + vm(1u) * ry + vm(2u) * rz,
                vm(4u) * rx + vm(5u) * ry + vm(6u) * rz,
                vm(8u) * rx + vm(9u) * ry + vm(10u) * rz);
  }

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

    // LoadPrimitiveBatch<EvalColorOnly, BetaKernel> with StageColorOnlyRecord.
    let progress = i * BLOCK_SIZE + lid;
    if (range_start + progress < range_end) {
      let coll_id = point_list[range_start + progress];
      batch_id[lid] = coll_id;
      let record = prims[coll_id].record;
      stage_eval(lid, abs(record.x));
      let beta = record.z;
      batch_filter[lid] = beta;
      batch_slot[lid] = bitcast<i32>(prim_aux[coll_id].z);
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
      let fragment = evaluate_fragment(j, batch_lane0[j], batch_lane1[j], batch_bis[j], e.x, e.y,
                                       pixf.x - a2.x, pixf.y - a2.y, batch_filter[j], textured);
      if (!fragment.keep) {
        continue;  // The level-set reject: the fragment writes nothing.
      }
      let alpha = fminf(1.0 - exp(-fragment.tau), 0.9999);
      let test_t = transmittance * (1.0 - alpha);
      if (alpha < MIN_ALPHA_SKIP) {
        continue;
      }
      let cc = 3u * batch_id[j];
      var c = vec3f(rgb[cc], rgb[cc + 1u], rgb[cc + 2u]);
      if (textured) {
        let slot = batch_slot[j];
        if (slot >= 0) {
          c = c + texture_color(u32(slot), ray_origin, ray, fragment.t_bar);
        }
      }
      color = color + c * alpha * transmittance;
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
