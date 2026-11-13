// P3 and P6 of a Beta-kernel model: a port of preprocessCUDA<BetaKernel<
// BetaFit::Training>> / PreprocessPrimitive (forward.cu 971-1116 of the code
// tree 7cdb6976), its helpers (forward.cu, auxiliary.h) and the functions of
// kernels/beta.cuh that the preprocess calls, and of
// duplicateWithKeys<KernelType::Beta> (rasterizer_impl.cu) with
// tileRowSpanOutline. The Gaussian passes of preprocess.wgsl do not change;
// this file holds copies of the helpers of that file that the Beta path
// shares (project_point, view_depth, ndc_to_pixel, hypot, kernel_frame,
// amplitude_factors; tileRowSpanOBB in the single-exit form below).
//
// Arithmetic: as preprocess.wgsl. fma_exact stands where the source calls
// fmaf explicitly (beta.cuh, the colour-only record) and at the FFMA
// patterns that preprocess.wgsl takes from the sm_89 SASS (clip-space
// points, view depth, clipped endpoints, quad corners, band crossings); the
// outline corners and their band crossings take the same pattern. The
// fast-math intrinsics become WGSL built-ins: __log2f -> log2, exp2f -> exp2,
// rsqrtf -> inverseSqrt, a division -> /. The double product of
// BuildTileOutline (det c_3) is formed from exact float32 products.
//
// The primitive index is the position in the kept-row list (P1). P2b
// (beta_gather.wgsl) gives the amplitude and the shape parameter b of each
// kept row in prim_aux.

struct PrimBeta {
  aniso: vec4f,     // c3_00, c3_01, c3_11, +-ratio_a (the sign bit is the point limit)
  bis: vec4f,       // q0, lambda_int, cutoff_q2, ratio_b
  ab: vec4f,        // a_img.xy, b_img.xy (the clipped endpoints in pixels)
  geo: vec4f,       // p_perp, p_along, depth, radius (0 for a row with no tile)
  rect: vec4u,      // tile rectangle tx0, ty0, tx1, ty1
  record: vec4f,    // the kernel record {+-gamma, +-gamma', a2 B, X}
  outline0: vec4f,  // TileOutline vf.xy, va.xy
  outline1: vec4f,  // TileOutline vb.xy, wa, wb
  outline2: vec4f,  // TileOutline ka, kb, m, bitcast(flags)
};

@group(0) @binding(0) var<storage, read> kept_rows: array<u32>;   // [K]
@group(0) @binding(1) var<storage, read> endpoints: array<f32>;   // [N, 2, 3]
@group(0) @binding(2) var<storage, read> uni: array<f32>;         // [N, 8]
@group(0) @binding(3) var<storage, read> prim_aux: array<vec4u>;  // [K] (beta_gather.wgsl)
@group(0) @binding(4) var<storage, read> counts: array<u32>;
@group(0) @binding(5) var<storage, read_write> prims: array<PrimBeta>; // [K]
@group(0) @binding(6) var<storage, read_write> tiles: array<u32>;  // [K]
@group(0) @binding(7) var<uniform> cam: Camera;

@group(0) @binding(0) var<storage, read> dup_prims: array<PrimBeta>;
@group(0) @binding(1) var<storage, read> dup_offsets: array<u32>;  // inclusive scan of tiles
@group(0) @binding(2) var<storage, read> dup_counts: array<u32>;
@group(0) @binding(3) var<storage, read_write> key_hi: array<u32>;
@group(0) @binding(4) var<storage, read_write> key_lo: array<u32>;
@group(0) @binding(5) var<storage, read_write> pair_value: array<u32>;
@group(0) @binding(6) var<uniform> dup_cam: Camera;

const BLOCK_X: u32 = 16u;
const BLOCK_Y: u32 = 16u;
const UNI_CLIP_W_MIN: f32 = 1e-3;
const EXTENT_CUT_TAU: f32 = 3.929278140e-03;
const UNI_SCREEN_POINT_LAMBDA: f32 = 0.1;
const BOUNDS_EPS: f32 = 0.02;

// kernels/beta.cuh
const BETA_SERIES_LIMIT: f32 = 0.1;
const BETA_FLT_MIN: f32 = 1.17549435e-38;
const BETA_SQRT2: f32 = 1.41421356;
const BETA_INV_SQRT2: f32 = 0.707106781;
const BETA_GAMMA_MIN: f32 = 0.2;
const BETA_GAMMA_MAX: f32 = 12.5;
const BETA_NEAR_PLANE: f32 = 0.01;
const BETA_JACOBIAN_LIMIT: f32 = 1.3;
const BETA_FIT_Z_SCALE: f32 = -3.1215594;
const BETA_FIT_Z_OFF: f32 = 1.8495809;
const BETA_LOG2_E: f32 = 1.44269504;

// The training tier of the fit (BetaFit::Training): N_p = 9 terms, Chebyshev
// degree 6, and the degree 6 of the series of F(1) and 1 / F(1).
const TRAIN_POLYNOMIAL = array<f32, 63>(
  -1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
  0.86907756, -0.08104082, 0.012049758, -0.00021792683, 2.1956479e-05, -1.45608055e-05, -2.4834957e-05,
  -0.70016533, 0.17784852, -0.029768402, 0.0013841696, -0.0002165212, 0.00020030937, 0.000181285,
  0.538863, -0.25318372, 0.051725097, -0.0043851244, 0.00028628978, -0.0007355512, -0.0004591238,
  -0.39315897, 0.28637674, -0.07442167, 0.010118952, -3.2378295e-05, 0.0011633757, 0.000537747,
  0.25465247, -0.25353765, 0.08320036, -0.016473958, 0.00047484812, -0.00091163174, -0.00032065576,
  -0.12885943, 0.15803069, -0.06287364, 0.016344883, -0.0015109606, 0.00043000313, 0.00010007449,
  0.04232212, -0.059212293, 0.027284678, -0.008595316, 0.0013526595, -0.00018219583, -1.2701726e-05,
  -0.006454065, 0.00980119, -0.005036595, 0.0018203161, -0.0003864131, 5.108729e-05, -1.2723773e-06);
const TRAIN_PEAK = array<f32, 7>(
  0.9317711, -0.04327248, 0.0059742252, 8.372514e-06, -1.3490912e-05, 1.0639736e-06, 1.9153707e-07);
const TRAIN_INVERSE_PEAK = array<f32, 7>(
  1.0743952, 0.049604684, -0.0057441797, -0.0003010808, 2.6747155e-05, 7.308961e-07, -3.6029135e-07);

// The staged values of the kernel object of one row (BetaKernel: the
// exponent gamma, then the set p_0 .. p_9 of the fit) and the series
// y_0 .. y_4 of the exponent (betaSeries, fill_series).
var<private> staged: array<f32, 11>;
var<private> series_y: array<f32, 5>;

fn vm(k: u32) -> f32 {
  return cam.view[k >> 2u][k & 3u];
}

fn pm(k: u32) -> f32 {
  return cam.proj[k >> 2u][k & 3u];
}

fn dot3(x: vec3f, y: vec3f) -> f32 {
  return x.x * y.x + x.y * y.y + x.z * y.z;
}

// ===== Copies of preprocess.wgsl =====

fn project_point(p: vec3f) -> vec4f {
  var out: vec4f;
  for (var r = 0u; r < 4u; r = r + 1u) {
    out[r] = fma_exact(p.z, pm(8u + r), fma_exact(p.x, pm(r), p.y * pm(4u + r))) + pm(12u + r);
  }
  return out;
}

fn view_depth(p: vec3f) -> f32 {
  return fma_exact(p.z, vm(10u), fma_exact(p.x, vm(2u), p.y * vm(6u))) + vm(14u);
}

fn ndc_to_pixel(v: f32, size: u32) -> f32 {
  let s = f32(size);
  return fma_exact(v, s, s - 1.0) * 0.5;
}

fn hypot(x: f32, y: f32) -> f32 {
  let ax = abs(x);
  let ay = abs(y);
  let big = max(ax, ay);
  let small = min(ax, ay);
  if (small == 0.0) {
    return big;
  }
  return sqrt(fma_exact(big, big, small * small));
}

struct KernelFrame {
  r: mat3x3f,
  s: vec3f,
  filter_variance: f32,
  m0: vec3f,
  m1: vec3f,
  c_int00: f32,
  c_int01: f32,
  c_int11: f32,
};

fn kernel_frame(row: u32, jx: vec3f, jy: vec3f) -> KernelFrame {
  var frame: KernelFrame;
  let u = 8u * row;
  let w = uni[u];
  let x = uni[u + 1u];
  let y = uni[u + 2u];
  let z = uni[u + 3u];
  frame.r = mat3x3f(
      vec3f(1.0 - 2.0 * (y * y + z * z), 2.0 * (x * y + w * z), 2.0 * (x * z - w * y)),
      vec3f(2.0 * (x * y - w * z), 1.0 - 2.0 * (x * x + z * z), 2.0 * (y * z + w * x)),
      vec3f(2.0 * (x * z + w * y), 2.0 * (y * z - w * x), 1.0 - 2.0 * (x * x + y * y)));
  frame.s = vec3f(uni[u + 4u], uni[u + 5u], uni[u + 6u]);
  frame.filter_variance = uni[u + 7u];
  frame.c_int00 = 0.0;
  frame.c_int01 = 0.0;
  frame.c_int11 = 0.0;
  for (var j = 0u; j < 3u; j = j + 1u) {
    let col = frame.r[j];
    let p0 = jx.x * col.x + jx.y * col.y + jx.z * col.z;
    let p1 = jy.x * col.x + jy.y * col.y + jy.z * col.z;
    frame.m0[j] = p0 * frame.s[j];
    frame.m1[j] = p1 * frame.s[j];
    frame.c_int00 = frame.c_int00 + frame.m0[j] * frame.m0[j];
    frame.c_int01 = frame.c_int01 + frame.m0[j] * frame.m1[j];
    frame.c_int11 = frame.c_int11 + frame.m1[j] * frame.m1[j];
  }
  return frame;
}

struct AmplitudeFactors {
  transverse_product: f32,
  ray_product: f32,
  normal_norm: f32,
  positive_scales: bool,
  metric: f32,
  exact: bool,
};

fn amplitude_factors(frame: KernelFrame, jx: vec3f, jy: vec3f, ray: vec3f,
                     ex: f32, ey: f32) -> AmplitudeFactors {
  var factors: AmplitudeFactors;
  let s0 = frame.s.x;
  let s1 = frame.s.y;
  let s2 = frame.s.z;
  factors.transverse_product = 0.5 * s0 * (s1 + s2);
  let other_product = vec3f(s1 * s2, s0 * s2, s0 * s1);
  var term: vec3f;
  var largest = 0.0;
  for (var j = 0u; j < 3u; j = j + 1u) {
    let col = frame.r[j];
    let ray_component = ray.x * col.x + ray.y * col.y + ray.z * col.z;
    term[j] = ray_component * other_product[j];
    largest = fmaxf(largest, abs(term[j]));
  }
  let inverse_largest = select(0.0, 1.0 / largest, largest > 0.0);
  var sum = 0.0;
  for (var j = 0u; j < 3u; j = j + 1u) {
    let scaled = term[j] * inverse_largest;
    sum = sum + scaled * scaled;
  }
  let root = sqrt(sum);
  factors.ray_product = largest * root;
  let normal = vec3f(jx.y * jy.z - jx.z * jy.y,
                     jx.z * jy.x - jx.x * jy.z,
                     jx.x * jy.y - jx.y * jy.x);
  factors.normal_norm = sqrt(normal.x * normal.x + normal.y * normal.y + normal.z * normal.z);
  factors.positive_scales = s0 > 0.0 && s1 > 0.0 && s2 > 0.0;
  factors.metric = 0.0;
  for (var j = 0u; j < 3u; j = j + 1u) {
    let edge_weight = -ey * frame.m0[j] + ex * frame.m1[j];
    factors.metric = factors.metric + edge_weight * edge_weight;
  }
  factors.exact = ex == 0.0 && ey == 0.0;
  return factors;
}

// ===== kernels/beta.cuh, the training tier =====

// betaSeries: y_0 .. y_4 of the odd series of F (the values; the
// preprocess reads no slope).
fn fill_series(gamma: f32) {
  let r2 = fma_exact(gamma, -0.3, 0.3);
  let r3 = fma_exact(gamma, -5.0 / 21.0, 10.0 / 21.0);
  let r4 = fma_exact(gamma, -7.0 / 36.0, 21.0 / 36.0);
  series_y[0] = 1.0;
  series_y[1] = gamma * (-1.0 / 3.0);
  series_y[2] = series_y[1] * r2;
  series_y[3] = series_y[2] * r3;
  series_y[4] = series_y[3] * r4;
}

// sum_j a_j T_j(z) for j = 0 .. 6 with fmaf, in the order of betaFitSet.
// t holds T_1 .. T_6.
struct Cheb {
  t1: f32, t2: f32, t3: f32, t4: f32, t5: f32, t6: f32,
};

fn cheb6(a0: f32, a1: f32, a2: f32, a3: f32, a4: f32, a5: f32, a6: f32, t: Cheb) -> f32 {
  var acc = a0;
  acc = fma_exact(a1, t.t1, acc);
  acc = fma_exact(a2, t.t2, acc);
  acc = fma_exact(a3, t.t3, acc);
  acc = fma_exact(a4, t.t4, acc);
  acc = fma_exact(a5, t.t5, acc);
  acc = fma_exact(a6, t.t6, acc);
  return acc;
}

// BetaKernel::stage<Render>: staged[0] = gamma, and betaFitSet<Training,
// Render>: staged[1 + k] = p_k for k = 0 .. 9. The loops of the source are
// written out (constant indices).
fn stage_training(gamma: f32) {
  staged[0] = gamma;
  let gp1 = gamma + 1.0;
  let r = inverseSqrt(gp1);
  let z = fma_exact(r, BETA_FIT_Z_SCALE, BETA_FIT_Z_OFF);
  let z2 = z + z;
  var t: Cheb;
  t.t1 = z;
  t.t2 = fma_exact(z2, t.t1, -1.0);
  t.t3 = fma_exact(z2, t.t2, -t.t1);
  t.t4 = fma_exact(z2, t.t3, -t.t2);
  t.t5 = fma_exact(z2, t.t4, -t.t3);
  t.t6 = fma_exact(z2, t.t5, -t.t4);
  let d0 = cheb6(TRAIN_POLYNOMIAL[0], TRAIN_POLYNOMIAL[1], TRAIN_POLYNOMIAL[2], TRAIN_POLYNOMIAL[3], TRAIN_POLYNOMIAL[4], TRAIN_POLYNOMIAL[5], TRAIN_POLYNOMIAL[6], t);
  let d1 = cheb6(TRAIN_POLYNOMIAL[7], TRAIN_POLYNOMIAL[8], TRAIN_POLYNOMIAL[9], TRAIN_POLYNOMIAL[10], TRAIN_POLYNOMIAL[11], TRAIN_POLYNOMIAL[12], TRAIN_POLYNOMIAL[13], t);
  let d2 = cheb6(TRAIN_POLYNOMIAL[14], TRAIN_POLYNOMIAL[15], TRAIN_POLYNOMIAL[16], TRAIN_POLYNOMIAL[17], TRAIN_POLYNOMIAL[18], TRAIN_POLYNOMIAL[19], TRAIN_POLYNOMIAL[20], t);
  let d3 = cheb6(TRAIN_POLYNOMIAL[21], TRAIN_POLYNOMIAL[22], TRAIN_POLYNOMIAL[23], TRAIN_POLYNOMIAL[24], TRAIN_POLYNOMIAL[25], TRAIN_POLYNOMIAL[26], TRAIN_POLYNOMIAL[27], t);
  let d4 = cheb6(TRAIN_POLYNOMIAL[28], TRAIN_POLYNOMIAL[29], TRAIN_POLYNOMIAL[30], TRAIN_POLYNOMIAL[31], TRAIN_POLYNOMIAL[32], TRAIN_POLYNOMIAL[33], TRAIN_POLYNOMIAL[34], t);
  let d5 = cheb6(TRAIN_POLYNOMIAL[35], TRAIN_POLYNOMIAL[36], TRAIN_POLYNOMIAL[37], TRAIN_POLYNOMIAL[38], TRAIN_POLYNOMIAL[39], TRAIN_POLYNOMIAL[40], TRAIN_POLYNOMIAL[41], t);
  let d6 = cheb6(TRAIN_POLYNOMIAL[42], TRAIN_POLYNOMIAL[43], TRAIN_POLYNOMIAL[44], TRAIN_POLYNOMIAL[45], TRAIN_POLYNOMIAL[46], TRAIN_POLYNOMIAL[47], TRAIN_POLYNOMIAL[48], t);
  let d7 = cheb6(TRAIN_POLYNOMIAL[49], TRAIN_POLYNOMIAL[50], TRAIN_POLYNOMIAL[51], TRAIN_POLYNOMIAL[52], TRAIN_POLYNOMIAL[53], TRAIN_POLYNOMIAL[54], TRAIN_POLYNOMIAL[55], t);
  let d8 = cheb6(TRAIN_POLYNOMIAL[56], TRAIN_POLYNOMIAL[57], TRAIN_POLYNOMIAL[58], TRAIN_POLYNOMIAL[59], TRAIN_POLYNOMIAL[60], TRAIN_POLYNOMIAL[61], TRAIN_POLYNOMIAL[62], t);
  let g = cheb6(TRAIN_PEAK[0], TRAIN_PEAK[1], TRAIN_PEAK[2], TRAIN_PEAK[3], TRAIN_PEAK[4],
                TRAIN_PEAK[5], TRAIN_PEAK[6], t);
  let g_inverse = cheb6(TRAIN_INVERSE_PEAK[0], TRAIN_INVERSE_PEAK[1], TRAIN_INVERSE_PEAK[2],
                        TRAIN_INVERSE_PEAK[3], TRAIN_INVERSE_PEAK[4], TRAIN_INVERSE_PEAK[5],
                        TRAIN_INVERSE_PEAK[6], t);
  let f1 = r * g;
  let inverse_f1 = (gp1 * r) * g_inverse;
  staged[1] = f1;
  staged[2] = d0;
  var power = inverse_f1;
  staged[3] = d1 * power;
  power = power * inverse_f1;
  staged[4] = d2 * power;
  power = power * inverse_f1;
  staged[5] = d3 * power;
  power = power * inverse_f1;
  staged[6] = d4 * power;
  power = power * inverse_f1;
  staged[7] = d5 * power;
  power = power * inverse_f1;
  staged[8] = d6 * power;
  power = power * inverse_f1;
  staged[9] = d7 * power;
  power = power * inverse_f1;
  staged[10] = d8 * power;
  power = power * inverse_f1;
}

struct Endpoint {
  value: f32,
};

// BetaKernel::endpoint: F(v) of the exponent at |v| in [0, 1].
fn beta_endpoint(v: f32) -> Endpoint {
  let gamma = staged[0];
  let omega = fmaxf(fma_exact(-v, v, 1.0), BETA_FLT_MIN);
  let lw = log2(omega);
  let psi = exp2((gamma + 1.0) * lw);
  var acc = staged[10];
  acc = fma_exact(acc, v, staged[9]);
  acc = fma_exact(acc, v, staged[8]);
  acc = fma_exact(acc, v, staged[7]);
  acc = fma_exact(acc, v, staged[6]);
  acc = fma_exact(acc, v, staged[5]);
  acc = fma_exact(acc, v, staged[4]);
  acc = fma_exact(acc, v, staged[3]);
  acc = fma_exact(acc, v, staged[2]);
  acc = fma_exact(acc, v, staged[1]);
  let complement = psi * acc;
  let u = v * v;
  var sum = series_y[4];
  sum = fma_exact(sum, u, series_y[3]);
  sum = fma_exact(sum, u, series_y[2]);
  sum = fma_exact(sum, u, series_y[1]);
  sum = fma_exact(sum, u, series_y[0]);
  var end: Endpoint;
  end.value = select(staged[1] - complement, sum * v, v <= BETA_SERIES_LIMIT);
  return end;
}

const BRANCH_SERIES: u32 = 0u;
const BRANCH_FIT: u32 = 1u;
const BRANCH_TAIL: u32 = 2u;

struct Peak {
  branch: u32,
  end_value: f32,
  p: f32,
};

// BetaKernel::axial_peak (the two exponents are equal under the DBS rule).
fn axial_peak(lambda: f32) -> Peak {
  var peak: Peak;
  peak.end_value = 0.0;
  let gamma = staged[0];
  if (lambda < UNI_SCREEN_POINT_LAMBDA) {
    peak.branch = BRANCH_SERIES;
    let base = fma_exact(-0.3 * lambda, lambda, 1.0);
    let power = exp2(gamma * log2(base));
    peak.p = fma_exact(5.0 / 9.0, power, 4.0 / 9.0);
  } else if (lambda <= BETA_SQRT2) {
    peak.branch = BRANCH_FIT;
    let v = lambda * BETA_INV_SQRT2;
    peak.end_value = beta_endpoint(v).value;
    peak.p = peak.end_value / v;
  } else {
    peak.branch = BRANCH_TAIL;
    peak.p = BETA_SQRT2 * staged[1] / lambda;
  }
  return peak;
}

// BetaKernel::unfiltered: g^2 / P(lambda_int / g).
fn unfiltered_unit(lambda_int: f32, g: f32) -> f32 {
  let peak = axial_peak(lambda_int / g);
  return g * g / peak.p;
}

// BetaKernel::station_unfiltered.
fn station_unfiltered_beta(a: f32, n: f32, w: f32, g: f32, root_metric: f32,
                           lambda: f32) -> f32 {
  let peak = axial_peak(lambda);
  if (peak.branch == BRANCH_SERIES) {
    return a * g * g * n / peak.p;
  }
  let f = select(staged[1], peak.end_value, peak.branch == BRANCH_FIT);
  return a * g * root_metric / (BETA_SQRT2 * w * f);
}

// BetaKernel::station_filtered.
fn station_filtered_beta(h_adj: f32, det: f32, lambda: f32) -> f32 {
  let gamma = staged[0];
  if (lambda < UNI_SCREEN_POINT_LAMBDA) {
    let base = fma_exact(-0.3, h_adj / det, 1.0);
    let power = exp2(gamma * log2(base));
    return fma_exact(5.0 / 9.0, power, 4.0 / 9.0) * inverseSqrt(det);
  }
  let peak = axial_peak(lambda);
  let f = select(staged[1], peak.end_value, peak.branch == BRANCH_FIT);
  return BETA_SQRT2 * f * inverseSqrt(h_adj);
}

// screenStationAmplitude<BetaKernel>: K at one station g.
fn station_amplitude_beta(factors: AmplitudeFactors, g: f32, con_o: vec3f,
                          taper: vec3f, ex: f32, ey: f32) -> f32 {
  let zero_mass = !factors.exact && !(factors.metric > 0.0);
  let a = factors.transverse_product;
  let w = factors.ray_product;
  let n = factors.normal_norm;
  var unfiltered = 0.0;
  if (!zero_mass) {
    let root_metric = sqrt(factors.metric);
    let lambda = root_metric / (g * n * w);
    unfiltered = station_unfiltered_beta(a, n, w, g, root_metric, lambda);
  }
  let stretch = g * g - 1.0;
  let c00 = con_o.x + stretch * taper.x;
  let c01 = con_o.y + stretch * taper.y;
  let c11 = con_o.z + stretch * taper.z;
  let det = c00 * c11 - c01 * c01;
  let adj_ex = c11 * ex - c01 * ey;
  let adj_ey = c00 * ey - c01 * ex;
  let h_raw = ex * adj_ex + ey * adj_ey;
  let h_f = select(0.0, h_raw, h_raw > 0.0);
  let lambda_f = sqrt(h_f / det);
  let filtered = station_filtered_beta(h_f, det, lambda_f);
  return unfiltered * filtered;
}

// ===== auxiliary.h: ClipCenterlineNearPlane =====

struct Clip {
  ok: bool,
  a: vec4f,
  b: vec4f,
};

fn clip_near_plane(pa: vec4f, pb: vec4f) -> Clip {
  var result: Clip;
  result.ok = false;
  let d = pb - pa;
  let num = pa.w - UNI_CLIP_W_MIN;
  let den = d.w;
  var t0 = 0.0;
  var t1 = 1.0;
  if (den == 0.0) {
    if (num < 0.0) {
      return result;
    }
  } else {
    let tk = -num / den;
    if (den > 0.0) {
      t0 = fmaxf(t0, tk);
    } else {
      t1 = fminf(t1, tk);
    }
  }
  if (t0 > t1) {
    return result;
  }
  for (var c = 0u; c < 4u; c = c + 1u) {
    result.a[c] = fma_exact(d[c], t0, pa[c]);
    result.b[c] = fma_exact(d[c], t1, pa[c]);
  }
  result.ok = true;
  return result;
}

// ===== auxiliary.h: the tapered tile outline =====

const TILE_OUTLINE_RECTANGLE: u32 = 1u;
const TILE_OUTLINE_STRIP_A: u32 = 2u;
const TILE_OUTLINE_STRIP_B: u32 = 4u;

struct Outline {
  vf: vec2f,
  va: vec2f,
  vb: vec2f,
  wa: f32,
  wb: f32,
  ka: f32,
  kb: f32,
  m: f32,
  flags: u32,
};

fn outline_of(p: PrimBeta) -> Outline {
  var o: Outline;
  o.vf = p.outline0.xy;
  o.va = p.outline0.zw;
  o.vb = p.outline1.xy;
  o.wa = p.outline1.z;
  o.wb = p.outline1.w;
  o.ka = p.outline2.x;
  o.kb = p.outline2.y;
  o.m = p.outline2.z;
  o.flags = bitcast<u32>(p.outline2.w);
  return o;
}

// The corners of one convex quadrilateral, in cyclic order.
struct Quad {
  p0: vec2f,
  p1: vec2f,
  p2: vec2f,
  p3: vec2f,
};

// The three quadrilaterals of the outline (tileOutlineCorners): Q_mid,
// the end quad of A and the end quad of B.
struct Corners {
  mid: Quad,
  end_a: Quad,
  end_b: Quad,
};

// The projection on e of p - a (tileOutlineTrapezoid).
fn along_e(p: vec2f, a: vec2f, e: vec2f) -> f32 {
  return fma_exact(p.y - a.y, e.y, (p.x - a.x) * e.x);
}

// tileOutlineTrapezoid: the corners in convex cyclic order.
fn outline_trapezoid(a: vec2f, e: vec2f, p0: vec2f, p1: vec2f, m0: vec2f, m1: vec2f) -> Quad {
  let swap_p = along_e(p0, a, e) > along_e(p1, a, e);
  let swap_m = along_e(m0, a, e) > along_e(m1, a, e);
  return Quad(select(p0, p1, swap_p), select(p1, p0, swap_p),
              select(m1, m0, swap_m), select(m0, m1, swap_m));
}

// a + s v with the FFMA of the corner arithmetic.
fn offset_point(a: vec2f, s: f32, v: vec2f) -> vec2f {
  return vec2f(fma_exact(s, v.x, a.x), fma_exact(s, v.y, a.y));
}

// tileOutlineCorners.
fn outline_corners(a: vec2f, b: vec2f, p_along: f32, o: Outline) -> Corners {
  let e = b - a;
  let len = hypot(e.x, e.y);
  let short = len < 1e-4;
  let safe_dir = select(e, vec2f(1.0, 0.0), short);
  let safe_len = select(len, 1.0, short);
  let n = vec2f(-safe_dir.y / safe_len, safe_dir.x / safe_len);
  let u = vec2f(safe_dir.x / safe_len, safe_dir.y / safe_len);
  let a_m = offset_point(a, -o.wa, o.vf);
  let a_p = offset_point(a, o.wa, o.vf);
  let b_m = offset_point(b, -o.wb, o.vf);
  let b_p = offset_point(b, o.wb, o.vf);
  var a_fp: vec2f;
  var a_fm: vec2f;
  var b_fp: vec2f;
  var b_fm: vec2f;
  if ((o.flags & TILE_OUTLINE_STRIP_A) != 0u) {
    let a0 = offset_point(a, -p_along, u);
    a_fp = offset_point(a0, o.wa, n);
    a_fm = offset_point(a0, -o.wa, n);
  } else {
    let a0 = offset_point(a, -o.ka, e);
    a_fp = offset_point(a0, o.wa, o.va);
    a_fm = offset_point(a0, -o.wa, o.va);
  }
  if ((o.flags & TILE_OUTLINE_STRIP_B) != 0u) {
    let b0 = offset_point(b, p_along, u);
    b_fp = offset_point(b0, o.wb, n);
    b_fm = offset_point(b0, -o.wb, n);
  } else {
    let b0 = offset_point(b, o.kb, e);
    b_fp = offset_point(b0, o.wb, o.vb);
    b_fm = offset_point(b0, -o.wb, o.vb);
  }
  return Corners(Quad(a_m, b_m, b_p, a_p),
                 outline_trapezoid(a, e, a_p, a_fp, a_m, a_fm),
                 outline_trapezoid(a, e, b_p, b_fp, b_m, b_fm));
}

// One step of tileOutlineBandInterval: the corner p0 and the edge
// p0 -> p1, merged into range = (xlo, xhi).
fn band_edge(p0: vec2f, p1: vec2f, ylo: f32, yhi: f32, range: vec2f) -> vec2f {
  var xlo = range.x;
  var xhi = range.y;
  if (p0.y >= ylo && p0.y <= yhi) {
    xlo = fminf(xlo, p0.x);
    xhi = fmaxf(xhi, p0.x);
  }
  if (fmaxf(p0.y, p1.y) < ylo || fminf(p0.y, p1.y) > yhi) {
    return vec2f(xlo, xhi);
  }
  let dy = p1.y - p0.y;
  if (dy != 0.0) {
    let ta = fminf(fmaxf((ylo - p0.y) / dy, 0.0), 1.0);
    let tb = fminf(fmaxf((yhi - p0.y) / dy, 0.0), 1.0);
    let xa = fma_exact(ta, p1.x - p0.x, p0.x);
    let xb = fma_exact(tb, p1.x - p0.x, p0.x);
    xlo = fminf(xlo, fminf(xa, xb));
    xhi = fmaxf(xhi, fmaxf(xa, xb));
  } else {
    xlo = fminf(xlo, fminf(p0.x, p1.x));
    xhi = fmaxf(xhi, fmaxf(p0.x, p1.x));
  }
  return vec2f(xlo, xhi);
}

// tileOutlineBandInterval of one quadrilateral (edges in cyclic order).
fn band_quad(q: Quad, ylo: f32, yhi: f32, range: vec2f) -> vec2f {
  var r = band_edge(q.p0, q.p1, ylo, yhi, range);
  r = band_edge(q.p1, q.p2, ylo, yhi, r);
  r = band_edge(q.p2, q.p3, ylo, yhi, r);
  return band_edge(q.p3, q.p0, ylo, yhi, r);
}

// ===== tileRowSpanOBB and tileRowSpanOutline, in single-exit form =====
// The values equal those of tile_row_span and of tileRowSpanOutline. The
// corners of the rectangle and of the outline do not depend on the tile
// row, so the caller forms them once for each row of tiles loop. SwiftShader
// did not finish the pipeline of the form with early returns in 300 s.

// One edge p0 -> p1 of the rectangle and the corner p0 in the band
// (the loop body of tileRowSpanOBB), merged into range = (xlo, xhi).
fn obb_edge(p0: vec2f, p1: vec2f, ylo: f32, yhi: f32, range: vec2f) -> vec2f {
  var xlo = range.x;
  var xhi = range.y;
  if (p0.y >= ylo && p0.y <= yhi) {
    xlo = fminf(xlo, p0.x);
    xhi = fmaxf(xhi, p0.x);
  }
  let dy = p1.y - p0.y;
  if (dy != 0.0) {
    let t0 = (ylo - p0.y) / dy;
    if (t0 > 0.0 && t0 < 1.0) {
      let x = fma_exact(t0, p1.x - p0.x, p0.x);
      xlo = fminf(xlo, x);
      xhi = fmaxf(xhi, x);
    }
    let t1 = (yhi - p0.y) / dy;
    if (t1 > 0.0 && t1 < 1.0) {
      let x = fma_exact(t1, p1.x - p0.x, p0.x);
      xlo = fminf(xlo, x);
      xhi = fmaxf(xhi, x);
    }
  }
  return vec2f(xlo, xhi);
}

// The four corners c[0] .. c[3] of the rectangle of tileRowSpanOBB.
fn obb_corners(a: vec2f, b: vec2f, p_perp: f32, p_along: f32) -> Quad {
  let dir = b - a;
  let len = hypot(dir.x, dir.y);
  let short = len < 1e-4;
  let safe_dir = select(dir, vec2f(1.0, 0.0), short);
  let safe_len = select(len, 1.0, short);
  let u_norm = vec2f(-safe_dir.y / safe_len, safe_dir.x / safe_len);
  let u_dir = vec2f(safe_dir.x / safe_len, safe_dir.y / safe_len);
  let pp = p_perp + BOUNDS_EPS;
  let pa = p_along + BOUNDS_EPS;
  let c3 = vec2f(fma_exact(-u_dir.x, pa, fma_exact(u_norm.x, pp, a.x)),
                 fma_exact(-u_dir.y, pa, fma_exact(u_norm.y, pp, a.y)));
  let c0 = vec2f(fma_exact(-u_dir.x, pa, fma_exact(-u_norm.x, pp, a.x)),
                 fma_exact(-u_dir.y, pa, fma_exact(-u_norm.y, pp, a.y)));
  let c2 = vec2f(fma_exact(u_dir.x, pa, fma_exact(u_norm.x, pp, b.x)),
                 fma_exact(u_dir.y, pa, fma_exact(u_norm.y, pp, b.y)));
  let c1 = vec2f(fma_exact(u_dir.x, pa, fma_exact(-u_norm.x, pp, b.x)),
                 fma_exact(u_dir.y, pa, fma_exact(-u_norm.y, pp, b.y)));
  return Quad(c0, c1, c2, c3);
}

// The tile span [sx0, sx1) of the x range (xlo, xhi) widened by m, within
// [tx0, tx1); .z is 1 when the span is not empty. m = 0 gives the span of
// tileRowSpanOBB.
fn span_of(range: vec2f, width: u32, tx0: i32, tx1: i32, m: f32) -> vec3u {
  let w1 = f32(width - 1u);
  let xlo_s = fminf(fmaxf(range.x - m, 0.0), w1);
  let xhi_s = fminf(fmaxf(range.y + m, 0.0), w1);
  let sx0 = max(tx0, i32(floor(xlo_s * 0.0625)));
  let sx1 = min(tx1, i32(floor(xhi_s * 0.0625)) + 1);
  let ok = range.y >= range.x && sx1 > sx0;
  return select(vec3u(0u), vec3u(u32(sx0), u32(sx1), 1u), ok);
}

// tileRowSpanOutline of the tile strip ty: rq holds the rectangle corners
// (obb_corners) and c the outline corners (outline_corners).
fn tile_row_span_outline(rq: Quad, o: Outline, c: Corners, ty: u32, width: u32,
                         tx0: u32, tx1: u32) -> vec3u {
  let ylo = f32(ty * BLOCK_Y);
  let yhi = f32(ty * BLOCK_Y + (BLOCK_Y - 1u));
  var r = obb_edge(rq.p0, rq.p1, ylo, yhi, vec2f(3.4e38, -3.4e38));
  r = obb_edge(rq.p1, rq.p2, ylo, yhi, r);
  r = obb_edge(rq.p2, rq.p3, ylo, yhi, r);
  r = obb_edge(rq.p3, rq.p0, ylo, yhi, r);
  let rect = span_of(r, width, i32(tx0), i32(tx1), 0.0);
  let olo = ylo - o.m;
  let ohi = yhi + o.m;
  var q = band_quad(c.mid, olo, ohi, vec2f(3.4e38, -3.4e38));
  q = band_quad(c.end_a, olo, ohi, q);
  q = band_quad(c.end_b, olo, ohi, q);
  let outline_span = span_of(q, width, i32(rect.x), i32(rect.y), o.m);
  let use_rect = rect.z == 0u || (o.flags & TILE_OUTLINE_RECTANGLE) != 0u;
  return select(outline_span, rect, use_rect);
}

// The float32 rounding of the double a * b - c * d of two float32 products
// (BuildTileOutline: det c_3 in double, then cast to float). Both products
// are exact as hi + lo pairs; the sum takes one TwoSum.
fn product_difference(a: f32, b: f32, c: f32, d: f32) -> f32 {
  let p = two_product(a, b);
  let q = two_product(c, d);
  let s = two_sum(p.x, -q.x);
  let low = (p.y - q.y) + s.y;
  return s.x + low;
}

// The distance of p from the segment a + t e, t in [0, 1]
// (OutlineSegmentDistance).
fn outline_segment_distance(p: vec2f, a: vec2f, e: vec2f, e2: f32) -> f32 {
  let dx = p.x - a.x;
  let dy = p.y - a.y;
  let t = fminf(fmaxf((dx * e.x + dy * e.y) / e2, 0.0), 1.0);
  return hypot(dx - t * e.x, dy - t * e.y);
}

fn finite2(v: vec2f) -> bool {
  return is_finite(v.x) && is_finite(v.y);
}

// w, v and kappa of one end of the outline (BuildTileOutline).
struct OutlineEnd {
  w: f32,
  v: vec2f,
  kappa: f32,
};

fn outline_end(g: f32, s_3: f32, c3_n: vec2f, n: vec2f, det3: f32, tr3: f32, beta: f32,
               k: f32, l: f32) -> OutlineEnd {
  let gg = g * g;
  let s_x = gg * s_3 + beta;
  let det_x = gg * gg * det3 + gg * beta * tr3 + beta * beta;
  var end: OutlineEnd;
  end.w = k * sqrt(s_x);
  end.v = vec2f((gg * c3_n.x + beta * n.x) / s_x, (gg * c3_n.y + beta * n.y) / s_x);
  end.kappa = k * sqrt(det_x / s_x) / l;
  return end;
}

// The colour-only product fl(cutoff h_adj) det c at the station g is not
// finite or above 1e37 (BuildTileOutline).
fn strip_product_large(g: f32, eta: f32, eps: f32, det3: f32, tr3: f32, beta: f32,
                       cutoff: f32) -> bool {
  let gg = g * g;
  let h_adj = fma_exact(gg, eta, beta * eps);
  let det = fma_exact(gg, fma_exact(gg, det3, beta * tr3), beta * beta);
  let cutoff_h_adj = cutoff * h_adj;
  let product = cutoff_h_adj * det;
  return !is_finite(product) || product > 1e37;
}

// The running (R, finite) over the four corners of q: R the largest
// distance of a corner from the segment, finite 1 while every corner is
// finite.
fn corner_reach(p: vec2f, a: vec2f, e: vec2f, e2: f32, reach: vec2f) -> vec2f {
  let finite = reach.y != 0.0 && finite2(p);
  return vec2f(fmaxf(reach.x, outline_segment_distance(p, a, e, e2)), select(0.0, 1.0, finite));
}

fn quad_reach(q: Quad, a: vec2f, e: vec2f, e2: f32, reach: vec2f) -> vec2f {
  var r = corner_reach(q.p0, a, e, e2, reach);
  r = corner_reach(q.p1, a, e, e2, r);
  r = corner_reach(q.p2, a, e, e2, r);
  return corner_reach(q.p3, a, e, e2, r);
}

// BuildTileOutline<BetaKernel>.
fn build_tile_outline(c3: vec3f, c_f: vec3f, ratio_a: f32, ratio_b: f32, point_limit: bool,
                      cutoff: f32, a: vec2f, b: vec2f, n: vec2f, p_along: f32,
                      beta: f32, width: u32, height: u32) -> Outline {
  var o: Outline;
  o.vf = vec2f(0.0);
  o.va = vec2f(0.0);
  o.vb = vec2f(0.0);
  o.wa = 0.0;
  o.wb = 0.0;
  o.ka = 0.0;
  o.kb = 0.0;
  o.m = 0.0;
  o.flags = TILE_OUTLINE_RECTANGLE;
  if (point_limit) {
    return o;
  }
  let e = b - a;
  let e2 = e.x * e.x + e.y * e.y;
  let l = sqrt(e2);
  let k = sqrt(cutoff);
  let det3 = fmaxf(product_difference(c3.x, c3.z, c3.y, c3.y), 0.0);
  let tr3 = c3.x + c3.z;
  let cf_n = vec2f(c_f.x * n.x + c_f.y * n.y, c_f.y * n.x + c_f.z * n.y);
  let s_f = n.x * cf_n.x + n.y * cf_n.y;
  o.vf = vec2f(cf_n.x / s_f, cf_n.y / s_f);
  let c3_n = vec2f(c3.x * n.x + c3.y * n.y, c3.y * n.x + c3.z * n.y);
  let s_3 = n.x * c3_n.x + n.y * c3_n.y;
  let end_a = outline_end(ratio_a, s_3, c3_n, n, det3, tr3, beta, k, l);
  let end_b = outline_end(ratio_b, s_3, c3_n, n, det3, tr3, beta, k, l);
  o.wa = end_a.w;
  o.wb = end_b.w;
  o.va = end_a.v;
  o.vb = end_b.v;
  o.ka = end_a.kappa;
  o.kb = end_b.kappa;
  let g_max = fmaxf(ratio_a, ratio_b);
  let gg_max = g_max * g_max;
  let tr_max = gg_max * tr3 + 2.0 * beta;
  let det_max = gg_max * gg_max * det3 + gg_max * beta * tr3 + beta * beta;
  let u = 5.9604644775390625e-8;
  let r = 16.0 * u * tr_max * tr_max / det_max;
  let dd = fmaxf(fmaxf(abs(a.x), abs(a.y)), fmaxf(abs(b.x), abs(b.y)))
         + f32(width) + f32(height);
  let degenerate = !(det_max > 0.0) || !is_finite(det_max) || (beta == 0.0 && det3 == 0.0);
  // The colour-only product at g_A and g_B (screenColorOnlyRecord, then
  // h_adj, det and the product of the render).
  let a3x = c3.z * e.x - c3.y * e.y;
  let a3y = c3.x * e.y - c3.y * e.x;
  let eta = fmaxf(e.x * a3x + e.y * a3y, 0.0);
  let eps = e.x * e.x + e.y * e.y;
  let rec_det3 = fmaxf(c3.x * c3.z - c3.y * c3.y, 0.0);
  let rec_tr3 = c3.x + c3.z;
  var flags = 0u;
  if (strip_product_large(ratio_a, eta, eps, rec_det3, rec_tr3, beta, cutoff)) {
    flags = flags | TILE_OUTLINE_STRIP_A;
  }
  if (strip_product_large(ratio_a + (ratio_b - ratio_a), eta, eps, rec_det3, rec_tr3, beta, cutoff)) {
    flags = flags | TILE_OUTLINE_STRIP_B;
  }
  o.flags = flags;
  let c = outline_corners(a, b, p_along, o);
  // finite and R over the 12 corners, in the order c[0] .. c[11].
  var reach = quad_reach(c.mid, a, e, e2, vec2f(0.0, 1.0));
  reach = quad_reach(c.end_a, a, e, e2, reach);
  reach = quad_reach(c.end_b, a, e, e2, reach);
  var finite = reach.y != 0.0;
  let big_r = reach.x;
  o.m = r * big_r + 0.02 + 4.0 * u * dd;
  let strip_a = (flags & TILE_OUTLINE_STRIP_A) != 0u;
  let strip_b = (flags & TILE_OUTLINE_STRIP_B) != 0u;
  finite = finite && finite2(o.vf) && is_finite(o.wa) && is_finite(o.wb)
      && (strip_a || (finite2(o.va) && is_finite(o.ka)))
      && (strip_b || (finite2(o.vb) && is_finite(o.kb)))
      && is_finite(big_r) && is_finite(r) && is_finite(o.m);
  if (degenerate || !finite) {
    o.flags = TILE_OUTLINE_RECTANGLE;
  }
  return o;
}

// ===== forward.cu: PreprocessPrimitive<BetaKernel<BetaFit::Training>> =====

@compute @workgroup_size(256)
fn preprocess_beta(@builtin(local_invocation_index) lid: u32,
                   @builtin(workgroup_id) wid: vec3u,
                   @builtin(num_workgroups) nwg: vec3u) {
  let idx = linear_group(wid, nwg) * WORKGROUP_SIZE + lid;
  if (idx >= counts[SLOT_KEPT]) {
    return;
  }
  let source_idx = kept_rows[idx];
  tiles[idx] = 0u;
  prims[idx].geo = vec4f(0.0, 0.0, 0.0, 0.0);

  let aux = prim_aux[idx];
  let amp = bitcast<f32>(aux.x);
  let shape_b = bitcast<f32>(aux.y);
  let o = 6u * source_idx;
  let pa3 = vec3f(endpoints[o], endpoints[o + 1u], endpoints[o + 2u]);
  let pb3 = vec3f(endpoints[o + 3u], endpoints[o + 4u], endpoints[o + 5u]);
  let line_center = vec3f((pa3.x + pb3.x) * 0.5, (pa3.y + pb3.y) * 0.5, (pa3.z + pb3.z) * 0.5);
  let depth = view_depth(line_center);
  // The near plane of DBS: the midpoint view depth.
  if (depth < BETA_NEAR_PLANE) {
    return;
  }
  // The near-plane clip alone, no side-plane cull.
  let clip = clip_near_plane(project_point(pa3), project_point(pb3));
  if (!clip.ok) {
    return;
  }
  let width = cam.width;
  let height = cam.height;
  let a_img = vec2f(ndc_to_pixel(clip.a.x / clip.a.w, width), ndc_to_pixel(clip.a.y / clip.a.w, height));
  let b_img = vec2f(ndc_to_pixel(clip.b.x / clip.b.w, width), ndc_to_pixel(clip.b.y / clip.b.w, height));
  // The pixel filter B = w_aa_px^2 I (w_aa_px = AA_2D_PX_BETA).
  let filter_variance = cam.beta;

  // ===== ProjectScreenKernel<BetaKernel> =====
  let center_hom = project_point(line_center);
  var screen_valid = center_hom.w > UNI_CLIP_W_MIN && is_finite(center_hom.w);
  let safe_w = select(1.0, center_hom.w, screen_valid);
  let inv_w2 = 1.0 / (safe_w * safe_w);
  // The Jacobian clamp of DBS persp_proj.
  let limit = BETA_JACOBIAN_LIMIT * safe_w;
  let clamped_x = fminf(fmaxf(center_hom.x, -limit), limit);
  let clamped_y = fminf(fmaxf(center_hom.y, -limit), limit);
  let jacobian_clamped = clamped_x != center_hom.x || clamped_y != center_hom.y;
  let half_w = 0.5 * f32(width);
  let half_h = 0.5 * f32(height);
  let jx = vec3f(half_w * (safe_w * pm(0u) - clamped_x * pm(3u)) * inv_w2,
                 half_w * (safe_w * pm(4u) - clamped_x * pm(7u)) * inv_w2,
                 half_w * (safe_w * pm(8u) - clamped_x * pm(11u)) * inv_w2);
  let jy = vec3f(half_h * (safe_w * pm(1u) - clamped_y * pm(3u)) * inv_w2,
                 half_h * (safe_w * pm(5u) - clamped_y * pm(7u)) * inv_w2,
                 half_h * (safe_w * pm(9u) - clamped_y * pm(11u)) * inv_w2);
  let midpoint_img = vec2f(ndc_to_pixel(center_hom.x / safe_w, width),
                           ndc_to_pixel(center_hom.y / safe_w, height));
  let frame = kernel_frame(source_idx, jx, jy);
  // betaTwoCumulantFilter under the DBS rule: gamma = 4 e^b clamped to
  // [0.2, 12.5], gamma' = gamma, a1 = a2 = m = 1, X = 0.
  let gamma_raw = 4.0 * exp2(shape_b * BETA_LOG2_E);
  let gamma_clamped = !(gamma_raw >= BETA_GAMMA_MIN && gamma_raw <= BETA_GAMMA_MAX);
  let gamma = fminf(fmaxf(gamma_raw, BETA_GAMMA_MIN), BETA_GAMMA_MAX);
  let jxx = frame.filter_variance * dot3(jx, jx);
  let jxy = frame.filter_variance * dot3(jx, jy);
  let jyy = frame.filter_variance * dot3(jy, jy);
  // fmaf(a1 = 1, c_int, a2 jxx) is the one rounding of c_int + jxx.
  let c3_00 = frame.c_int00 + jxx;
  let c3_01 = frame.c_int01 + jxy;
  let c3_11 = frame.c_int11 + jyy;
  let pixel = filter_variance;
  let c00 = c3_00 + pixel;
  let c01 = c3_01;
  let c11 = c3_11 + pixel;
  stage_training(gamma);
  fill_series(gamma);
  let record = vec4f(select(gamma, -gamma, gamma_clamped), gamma, pixel, 0.0);
  let ratio_a = safe_w / clip.a.w;
  let ratio_b = safe_w / clip.b.w;
  let det_c = c00 * c11 - c01 * c01;
  screen_valid = screen_valid && det_c > 0.0 && is_finite(det_c);
  let inv_det_c = select(0.0, 1.0 / det_c, screen_valid);
  let chord = b_img - a_img;
  let adj_ex = c11 * chord.x - c01 * chord.y;
  let adj_ey = c00 * chord.y - c01 * chord.x;
  let h_adj = chord.x * adj_ex + chord.y * adj_ey;
  let h = fmaxf(h_adj * inv_det_c, 0.0);
  let lambda = sqrt(h);
  let inv_h_adj = select(0.0, 1.0 / h_adj, h > 1e-8);
  let point_limit = !(lambda > UNI_SCREEN_POINT_LAMBDA) || !(inv_h_adj > 0.0);
  let camera = cam.campos.xyz;
  let raw = line_center - camera;
  let inverse_ray_norm = inverseSqrt(dot3(raw, raw));
  var ray = raw * inverse_ray_norm;
  if (jacobian_clamped) {
    // ClampedJacobianRay.
    let nrm = vec3f(jx.y * jy.z - jx.z * jy.y,
                    jx.z * jy.x - jx.x * jy.z,
                    jx.x * jy.y - jx.y * jy.x);
    let inverse_norm = inverseSqrt(dot3(nrm, nrm));
    ray = nrm * inverse_norm;
  }
  let factors = amplitude_factors(frame, jx, jy, ray, chord.x, chord.y);
  let con_o = vec3f(c00, c01, c11);
  let taper = vec3f(c3_00, c3_01, c3_11);
  let rho = fmaxf(amp, 0.0);
  let q0 = rho * factors.transverse_product * factors.normal_norm;
  let lambda_int = sqrt(factors.metric) / (factors.normal_norm * factors.ray_product);
  // No peak cull for a Beta row; this test removes a row of zero mass.
  screen_valid = screen_valid && (factors.exact || factors.metric > 0.0);
  let k_a = station_amplitude_beta(factors, ratio_a, con_o, taper, chord.x, chord.y);
  let k_c = station_amplitude_beta(factors, 1.0, con_o, taper, chord.x, chord.y);
  let k_b = station_amplitude_beta(factors, ratio_b, con_o, taper, chord.x, chord.y);
  let peak = rho * fmaxf(k_a, fmaxf(k_c, k_b));
  let u_a = q0 * unfiltered_unit(lambda_int, ratio_a);
  let u_c = q0 * unfiltered_unit(lambda_int, 1.0);
  let u_b = q0 * unfiltered_unit(lambda_int, ratio_b);
  screen_valid = screen_valid && factors.positive_scales && is_finite(lambda_int)
      && is_finite(u_a) && is_finite(u_c) && is_finite(u_b);
  if (!screen_valid) {
    return;
  }
  let center_img = midpoint_img;

  // ComputeExtentCutoffQ2 with BetaKernel::cutoff_q2 (no peak cull).
  let ratio = EXTENT_CUT_TAU / fmaxf(peak, EXTENT_CUT_TAU);
  let cutoff_q2 = fmaxf(0.5 * (1.0 - exp2(log2(ratio) / gamma)), 1e-6);

  // ===== ComputeQuadFrame =====
  let dir = b_img - a_img;
  let len = hypot(dir.x, dir.y);
  let short = len < 1e-4;
  let safe_dir = select(dir, vec2f(1.0, 0.0), short);
  let safe_len = select(len, 1.0, short);
  let u_norm = vec2f(-safe_dir.y / safe_len, safe_dir.x / safe_len);
  let u_dir = vec2f(safe_dir.x / safe_len, safe_dir.y / safe_len);

  // ===== ComputePrimitiveExtent<BetaKernel> =====
  let k = sqrt(cutoff_q2);
  let g_max = fmaxf(ratio_a, ratio_b);
  let stretch_max = fmaxf(g_max * g_max - 1.0, 0.0);
  let cm00 = c00 + stretch_max * c3_00;
  let cm01 = c01 + stretch_max * c3_01;
  let cm11 = c11 + stretch_max * c3_11;
  let var_perp = u_norm.x * (cm00 * u_norm.x + cm01 * u_norm.y)
               + u_norm.y * (cm01 * u_norm.x + cm11 * u_norm.y);
  let var_along = u_dir.x * (cm00 * u_dir.x + cm01 * u_dir.y)
                + u_dir.y * (cm01 * u_dir.x + cm11 * u_dir.y);
  var p_perp = k * sqrt(fmaxf(var_perp, 1e-8));
  var p_along: f32;
  if (point_limit) {
    p_along = k * sqrt(fmaxf(var_along, 1e-8));
  } else {
    let x = u_norm.x * (cm00 * u_dir.x + cm01 * u_dir.y)
          + u_norm.y * (cm01 * u_dir.x + cm11 * u_dir.y);
    let det = cm00 * cm11 - cm01 * cm01;
    p_along = k * sqrt(fmaxf(var_along, 1e-8)
        + 2.0 * abs(x) * sqrt(fmaxf(det, 0.0)) / fmaxf(var_perp, 1e-8));
  }
  // The cap of a Beta row: the image diagonal plus the distance of the
  // projected midpoint from the image centre.
  let diag = hypot(f32(width), f32(height));
  let cap = diag + hypot(center_img.x - 0.5 * f32(width - 1u), center_img.y - 0.5 * f32(height - 1u));
  p_perp = fminf(p_perp, cap);
  p_along = fminf(p_along, cap);

  // ===== BuildEnclosingQuad and MeasureEnclosingQuad =====
  var quad: array<vec2f, 4>;
  quad[3] = vec2f(fma_exact(-u_dir.x, p_along, fma_exact(u_norm.x, p_perp, a_img.x)),
                  fma_exact(-u_dir.y, p_along, fma_exact(u_norm.y, p_perp, a_img.y)));
  quad[0] = vec2f(fma_exact(-u_dir.x, p_along, fma_exact(-u_norm.x, p_perp, a_img.x)),
                  fma_exact(-u_dir.y, p_along, fma_exact(-u_norm.y, p_perp, a_img.y)));
  quad[2] = vec2f(fma_exact(u_dir.x, p_along, fma_exact(u_norm.x, p_perp, b_img.x)),
                  fma_exact(u_dir.y, p_along, fma_exact(u_norm.y, p_perp, b_img.y)));
  quad[1] = vec2f(fma_exact(u_dir.x, p_along, fma_exact(-u_norm.x, p_perp, b_img.x)),
                  fma_exact(u_dir.y, p_along, fma_exact(-u_norm.y, p_perp, b_img.y)));
  var min_x = quad[0].x;
  var max_x = quad[0].x;
  var min_y = quad[0].y;
  var max_y = quad[0].y;
  var max_corner_radius = 0.0;
  for (var i = 0u; i < 4u; i = i + 1u) {
    let corner = quad[i];
    if (!is_finite(corner.x) || !is_finite(corner.y)) {
      return;
    }
    min_x = fminf(min_x, corner.x);
    max_x = fmaxf(max_x, corner.x);
    min_y = fminf(min_y, corner.y);
    max_y = fmaxf(max_y, corner.y);
    max_corner_radius = fmaxf(max_corner_radius, hypot(corner.x - center_img.x, corner.y - center_img.y));
  }
  let wf = f32(width - 1u);
  let hf = f32(height - 1u);
  // QuadOutsideImage: the off-image cull of DBS.
  if (max_x + BOUNDS_EPS < 0.0 || min_x - BOUNDS_EPS > wf
      || max_y + BOUNDS_EPS < 0.0 || min_y - BOUNDS_EPS > hf) {
    return;
  }

  // ===== QuadTileBounds =====
  let min_x_screen = fminf(fmaxf(min_x - BOUNDS_EPS, 0.0), wf);
  let max_x_screen = fminf(fmaxf(max_x + BOUNDS_EPS, 0.0), wf);
  let min_y_screen = fminf(fmaxf(min_y - BOUNDS_EPS, 0.0), hf);
  let max_y_screen = fminf(fmaxf(max_y + BOUNDS_EPS, 0.0), hf);
  let gx = i32(cam.tiles_x);
  let gy = i32(cam.tiles_y);
  let tx0 = max(0, min(gx, i32(floor(min_x_screen * 0.0625))));
  let ty0 = max(0, min(gy, i32(floor(min_y_screen * 0.0625))));
  let tx1 = max(0, min(gx, i32(floor(max_x_screen * 0.0625)) + 1));
  let ty1 = max(0, min(gy, i32(floor(max_y_screen * 0.0625)) + 1));
  if (tx0 >= tx1 || ty0 >= ty1) {
    return;
  }
  let radius_cap = f32(max(width, height));
  let max_distance = max(1, i32(ceil(fminf(max_corner_radius, radius_cap))));

  // ===== BuildTileOutline<BetaKernel> (beta = a2 B of the record) =====
  let outline = build_tile_outline(taper, con_o, ratio_a, ratio_b, point_limit, cutoff_q2,
                                   a_img, b_img, u_norm, p_along, record.z, width, height);

  // ===== WritePrimitiveRow =====
  var prim: PrimBeta;
  prim.aniso = vec4f(c3_00, c3_01, c3_11, select(ratio_a, -abs(ratio_a), point_limit));
  prim.bis = vec4f(q0, lambda_int, cutoff_q2, ratio_b);
  prim.ab = vec4f(a_img, b_img);
  prim.geo = vec4f(p_perp, p_along, depth, f32(max_distance));
  prim.rect = vec4u(u32(tx0), u32(ty0), u32(tx1), u32(ty1));
  prim.record = record;
  prim.outline0 = vec4f(outline.vf, outline.va);
  prim.outline1 = vec4f(outline.vb, outline.wa, outline.wb);
  prim.outline2 = vec4f(outline.ka, outline.kb, outline.m, bitcast<f32>(outline.flags));
  prims[idx] = prim;
  let corners = outline_corners(a_img, b_img, p_along, outline);
  let rect_corners = obb_corners(a_img, b_img, p_perp, p_along);
  var n_tiles = 0u;
  for (var ty = u32(ty0); ty < u32(ty1); ty = ty + 1u) {
    let span = tile_row_span_outline(rect_corners, outline, corners, ty, width,
                                     u32(tx0), u32(tx1));
    if (span.z != 0u) {
      n_tiles = n_tiles + (span.y - span.x);
    }
  }
  tiles[idx] = n_tiles;
}

// ===== P6: duplicateWithKeys<KernelType::Beta> =====
@compute @workgroup_size(256)
fn duplicate_keys_beta(@builtin(local_invocation_index) lid: u32,
                       @builtin(workgroup_id) wid: vec3u,
                       @builtin(num_workgroups) nwg: vec3u) {
  let idx = linear_group(wid, nwg) * WORKGROUP_SIZE + lid;
  if (idx >= dup_counts[SLOT_KEPT]) {
    return;
  }
  let prim = dup_prims[idx];
  if (!(prim.geo.w > 0.0)) {
    return;
  }
  var off = 0u;
  if (idx > 0u) {
    off = dup_offsets[idx - 1u];
  }
  let a_img = prim.ab.xy;
  let b_img = prim.ab.zw;
  let outline = outline_of(prim);
  let corners = outline_corners(a_img, b_img, prim.geo.y, outline);
  let rect_corners = obb_corners(a_img, b_img, prim.geo.x, prim.geo.y);
  let depth_bits = bitcast<u32>(prim.geo.z);
  let capacity = dup_cam.capacity;
  for (var y = prim.rect.y; y < prim.rect.w; y = y + 1u) {
    let span = tile_row_span_outline(rect_corners, outline, corners, y,
                                     dup_cam.width, prim.rect.x, prim.rect.z);
    if (span.z == 0u) {
      continue;
    }
    for (var x = span.x; x < span.y; x = x + 1u) {
      if (off < capacity) {
        key_hi[off] = y * dup_cam.tiles_x + x;
        key_lo[off] = depth_bits;
        pair_value[off] = idx;
      }
      off = off + 1u;
    }
  }
}
