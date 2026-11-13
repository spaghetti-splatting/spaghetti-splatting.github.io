// P3: the preprocess of one kept row, a port of preprocessCUDA /
// PreprocessPrimitive (forward.cu 607-710) and its helpers (forward.cu,
// auxiliary.h). P6: the key duplication, a port of duplicateWithKeys
// (rasterizer_impl.cu). Both call the same tile_row_span (tileRowSpanOBB),
// so the count of P3 equals the keys of P6.
//
// Arithmetic: fma_exact stands where the sm_89 SASS of preprocessCUDA has an
// FFMA on the path that sets the tiles: the clip-space points, the view
// depth, the clipped endpoints, the corners of the enclosing quad and the
// band crossings. ndc2Pix computes in double in CUDA; ndc_to_pixel forms the
// same single rounding. The fast-math intrinsics become WGSL built-ins
// (plan, section 4.2): expf -> exp, logf -> log, rsqrtf -> inverseSqrt,
// a division -> /.
//
// The primitive index is the position in the kept-row list (P1).

struct Prim {
  aniso: vec4f,  // c3_00, c3_01, c3_11, +-ratio_a (the sign bit is the point limit)
  bis: vec4f,    // q0, lambda_int, cutoff_q2, ratio_b
  ab: vec4f,     // a_img.xy, b_img.xy (the clipped endpoints in pixels)
  geo: vec4f,    // p_perp, p_along, depth, radius (0 for a row with no tile)
  rect: vec4u,   // tile rectangle tx0, ty0, tx1, ty1
};

@group(0) @binding(0) var<storage, read> kept_rows: array<u32>;   // [K]
@group(0) @binding(1) var<storage, read> endpoints: array<f32>;   // [N, 2, 3]
@group(0) @binding(2) var<storage, read> uni: array<f32>;         // [N, 8]
@group(0) @binding(3) var<storage, read> amplitude: array<f32>;   // [N]
@group(0) @binding(4) var<storage, read> face_factor: array<f32>; // [N]
@group(0) @binding(5) var<storage, read> counts: array<u32>;
@group(0) @binding(6) var<storage, read_write> prims: array<Prim>; // [K]
@group(0) @binding(7) var<storage, read_write> tiles: array<u32>;  // [K]
@group(0) @binding(8) var<uniform> cam: Camera;

@group(0) @binding(0) var<storage, read> dup_prims: array<Prim>;
@group(0) @binding(1) var<storage, read> dup_offsets: array<u32>;  // inclusive scan of tiles
@group(0) @binding(2) var<storage, read> dup_counts: array<u32>;
@group(0) @binding(3) var<storage, read_write> key_hi: array<u32>;
@group(0) @binding(4) var<storage, read_write> key_lo: array<u32>;
@group(0) @binding(5) var<storage, read_write> pair_value: array<u32>;
@group(0) @binding(6) var<uniform> dup_cam: Camera;

const BLOCK_X: u32 = 16u;
const BLOCK_Y: u32 = 16u;
const UNI_CLIP_W_MIN: f32 = 1e-3;
const MIN_TAU_CULL: f32 = 0.0009770396478266127;
const EXTENT_CUT_TAU: f32 = 3.929278140e-03;
const UNI_SCREEN_POINT_LAMBDA: f32 = 0.1;
const UNI_ERF_FIT_SATURATION: f32 = 12.0;
const UNI_FAST_AXIAL_2C: f32 = 2.2567583;
const UNI_FAST_AXIAL_A: f32 = 0.08945;
const SQRT_PI_SCREEN: f32 = 1.7724538509055159;
const BOUNDS_EPS: f32 = 0.02;

fn vm(k: u32) -> f32 {
  return cam.view[k >> 2u][k & 3u];
}

fn pm(k: u32) -> f32 {
  return cam.proj[k >> 2u][k & 3u];
}

// transformPoint4x4 with the FFMA pattern of the SASS:
// row = fma(z, m[8+r], fma(x, m[r], y * m[4+r])) + m[12+r].
fn project_point(p: vec3f) -> vec4f {
  var out: vec4f;
  for (var r = 0u; r < 4u; r = r + 1u) {
    out[r] = fma_exact(p.z, pm(8u + r), fma_exact(p.x, pm(r), p.y * pm(4u + r))) + pm(12u + r);
  }
  return out;
}

// The view z of transformPoint4x3, the depth key.
fn view_depth(p: vec3f) -> f32 {
  return fma_exact(p.z, vm(10u), fma_exact(p.x, vm(2u), p.y * vm(6u))) + vm(14u);
}

// ndc2Pix: ((v + 1.0) * S - 1.0) * 0.5 in double, then rounded to float. The
// double steps are exact, so the result is the single rounding of
// v S + (S - 1), times 0.5.
fn ndc_to_pixel(v: f32, size: u32) -> f32 {
  let s = f32(size);
  return fma_exact(v, s, s - 1.0) * 0.5;
}

// hypotf as the SASS forms it: sqrt(fma(M, M, m * m)) with M the larger and m
// the smaller magnitude (the power-of-2 scaling of the SASS is exact).
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

// ===== auxiliary.h: the fitted erf and the unfiltered factor =====

fn fast_axial_sigmoid(u: f32) -> f32 {
  let z = u * fma_exact(UNI_FAST_AXIAL_A, u * u, 1.0);
  return 1.0 / (1.0 + exp(-UNI_FAST_AXIAL_2C * z));
}

struct ErfFit {
  value: f32,
  slope: f32,
};

fn erf_fit_half(lambda: f32) -> ErfFit {
  var fit: ErfFit;
  if (!(lambda < UNI_ERF_FIT_SATURATION)) {
    fit.value = 1.0;
    fit.slope = 0.0;
    return fit;
  }
  let x = 0.5 * lambda;
  let s = fast_axial_sigmoid(x);
  fit.value = 2.0 * s - 1.0;
  fit.slope = 2.0 * UNI_FAST_AXIAL_2C * s * (1.0 - s) * fma_exact(3.0 * UNI_FAST_AXIAL_A, x * x, 1.0);
  return fit;
}

// screenStationUnfiltered: rho_theta U(g), the value alone.
fn station_unfiltered(q0: f32, lambda_int: f32, g: f32) -> f32 {
  let lambda_u = lambda_int / g;
  let series = lambda_int < UNI_SCREEN_POINT_LAMBDA * g;
  var unit: f32;
  if (series) {
    let g2 = g * g;
    let twelfth = lambda_int * lambda_int / 12.0;
    let dg2 = g2 - twelfth;
    unit = g2 * g2 / dg2;
  } else if (lambda_u < UNI_ERF_FIT_SATURATION) {
    let x = 0.5 * lambda_u;
    let cubic = fma_exact(UNI_FAST_AXIAL_A, x * x, 1.0);
    let t = exp(-UNI_FAST_AXIAL_2C * x * cubic);
    unit = lambda_int * g * (1.0 + t) / (SQRT_PI_SCREEN * (1.0 - t));
  } else {
    unit = lambda_int * g / SQRT_PI_SCREEN;
  }
  return q0 * unit;
}

// ===== auxiliary.h: the kernel frame and the factors of K =====

struct KernelFrame {
  r: mat3x3f,          // r[j][i] = R[i][j]: column j of the frame
  s: vec3f,
  filter_variance: f32,
  m0: vec3f,           // M[0][j] = P[0][j] s_j
  m1: vec3f,           // M[1][j] = P[1][j] s_j
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

// screenStationAmplitude: K at one station g.
fn station_amplitude(factors: AmplitudeFactors, g: f32, con_o: vec3f, taper: vec3f,
                     ex: f32, ey: f32) -> f32 {
  let zero_mass = !factors.exact && !(factors.metric > 0.0);
  let a = factors.transverse_product;
  let w = factors.ray_product;
  let n = factors.normal_norm;
  var unfiltered: f32;
  if (zero_mass) {
    unfiltered = 0.0;
  } else {
    let root_metric = sqrt(factors.metric);
    let lambda = root_metric / (g * n * w);
    if (lambda < UNI_SCREEN_POINT_LAMBDA) {
      let lambda2 = lambda * lambda;
      let d = 1.0 - lambda2 / 12.0;
      unfiltered = a * g * g * n / d;
    } else {
      let fit = erf_fit_half(lambda);
      unfiltered = a * g * root_metric / (SQRT_PI_SCREEN * w * fit.value);
    }
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
  var filtered: f32;
  if (lambda_f < UNI_SCREEN_POINT_LAMBDA) {
    let p_f = 1.0 - h_f / (12.0 * det);
    filtered = p_f * inverseSqrt(det);
  } else {
    let fit_f = erf_fit_half(lambda_f);
    filtered = SQRT_PI_SCREEN * fit_f.value * inverseSqrt(h_f);
  }
  return unfiltered * filtered;
}

// ===== forward.cu: ClipCenterline (auxiliary.h) =====

struct Clip {
  ok: bool,
  a: vec4f,
  b: vec4f,
};

fn clip_centerline(pa: vec4f, pb: vec4f) -> Clip {
  var result: Clip;
  result.ok = false;
  let d = pb - pa;
  var t0 = 0.0;
  var t1 = 1.0;
  var cnum = array<f32, 5>(pa.w - UNI_CLIP_W_MIN, pa.x + pa.w, pa.w - pa.x,
                           pa.y + pa.w, pa.w - pa.y);
  var cden = array<f32, 5>(d.w, d.x + d.w, d.w - d.x, d.y + d.w, d.w - d.y);
  var culled = false;
  var cull_t0 = 0.0;
  var cull_t1 = 1.0;
  for (var k = 0u; k < 5u; k = k + 1u) {
    if (cden[k] == 0.0) {
      if (cnum[k] < 0.0) {
        culled = true;
        break;
      }
      continue;
    }
    let tk = -cnum[k] / cden[k];
    if (cden[k] > 0.0) {
      cull_t0 = fmaxf(cull_t0, tk);
    } else {
      cull_t1 = fminf(cull_t1, tk);
    }
  }
  if (culled || cull_t0 > cull_t1) {
    return result;
  }
  // Only the near plane moves the endpoints.
  if (cden[0] == 0.0) {
    if (cnum[0] < 0.0) {
      return result;
    }
  } else {
    let tk = -cnum[0] / cden[0];
    if (cden[0] > 0.0) {
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

// ===== auxiliary.h: tileRowSpanOBB =====
// The tile-x span [x0, x1) of the oriented rectangle in tile row ty. The
// result .z is 1 when the span is not empty.
fn tile_row_span(a: vec2f, b: vec2f, p_perp: f32, p_along: f32, ty: u32,
                 width: u32, tx0: u32, tx1: u32) -> vec3u {
  let dir = b - a;
  let len = hypot(dir.x, dir.y);
  let short = len < 1e-4;
  let safe_dir = select(dir, vec2f(1.0, 0.0), short);
  let safe_len = select(len, 1.0, short);
  let u_norm = vec2f(-safe_dir.y / safe_len, safe_dir.x / safe_len);
  let u_dir = vec2f(safe_dir.x / safe_len, safe_dir.y / safe_len);
  let pp = p_perp + BOUNDS_EPS;
  let pa = p_along + BOUNDS_EPS;
  var c: array<vec2f, 4>;
  c[3] = vec2f(fma_exact(-u_dir.x, pa, fma_exact(u_norm.x, pp, a.x)),
               fma_exact(-u_dir.y, pa, fma_exact(u_norm.y, pp, a.y)));
  c[0] = vec2f(fma_exact(-u_dir.x, pa, fma_exact(-u_norm.x, pp, a.x)),
               fma_exact(-u_dir.y, pa, fma_exact(-u_norm.y, pp, a.y)));
  c[2] = vec2f(fma_exact(u_dir.x, pa, fma_exact(u_norm.x, pp, b.x)),
               fma_exact(u_dir.y, pa, fma_exact(u_norm.y, pp, b.y)));
  c[1] = vec2f(fma_exact(u_dir.x, pa, fma_exact(-u_norm.x, pp, b.x)),
               fma_exact(u_dir.y, pa, fma_exact(-u_norm.y, pp, b.y)));
  let ylo = f32(ty * BLOCK_Y);
  let yhi = f32(ty * BLOCK_Y + (BLOCK_Y - 1u));
  var xlo = 3.4e38;
  var xhi = -3.4e38;
  for (var i = 0u; i < 4u; i = i + 1u) {
    let p0 = c[i];
    let p1 = c[(i + 1u) & 3u];
    if (p0.y >= ylo && p0.y <= yhi) {
      xlo = fminf(xlo, p0.x);
      xhi = fmaxf(xhi, p0.x);
    }
    let dy = p1.y - p0.y;
    if (dy != 0.0) {
      var t = (ylo - p0.y) / dy;
      if (t > 0.0 && t < 1.0) {
        let x = fma_exact(t, p1.x - p0.x, p0.x);
        xlo = fminf(xlo, x);
        xhi = fmaxf(xhi, x);
      }
      t = (yhi - p0.y) / dy;
      if (t > 0.0 && t < 1.0) {
        let x = fma_exact(t, p1.x - p0.x, p0.x);
        xlo = fminf(xlo, x);
        xhi = fmaxf(xhi, x);
      }
    }
  }
  if (!(xhi >= xlo)) {
    return vec3u(0u, 0u, 0u);
  }
  let w1 = f32(width - 1u);
  let xlo_s = fminf(fmaxf(xlo, 0.0), w1);
  let xhi_s = fminf(fmaxf(xhi, 0.0), w1);
  let sx0 = max(i32(tx0), i32(floor(xlo_s * 0.0625)));
  let sx1 = min(i32(tx1), i32(floor(xhi_s * 0.0625)) + 1);
  if (sx1 > sx0) {
    return vec3u(u32(sx0), u32(sx1), 1u);
  }
  return vec3u(0u, 0u, 0u);
}

// ===== forward.cu: PreprocessPrimitive =====

@compute @workgroup_size(256)
fn preprocess(@builtin(local_invocation_index) lid: u32,
              @builtin(workgroup_id) wid: vec3u,
              @builtin(num_workgroups) nwg: vec3u) {
  let idx = linear_group(wid, nwg) * WORKGROUP_SIZE + lid;
  if (idx >= counts[SLOT_KEPT]) {
    return;
  }
  let source_idx = kept_rows[idx];
  tiles[idx] = 0u;
  prims[idx].geo = vec4f(0.0, 0.0, 0.0, 0.0);

  // One amplitude per segment; the face rows take 1 / K (torch multiply).
  let amp = amplitude[source_idx] * face_factor[source_idx];
  let o = 6u * source_idx;
  let pa3 = vec3f(endpoints[o], endpoints[o + 1u], endpoints[o + 2u]);
  let pb3 = vec3f(endpoints[o + 3u], endpoints[o + 4u], endpoints[o + 5u]);
  let line_center = vec3f((pa3.x + pb3.x) * 0.5, (pa3.y + pb3.y) * 0.5, (pa3.z + pb3.z) * 0.5);
  let depth = view_depth(line_center);

  let clip = clip_centerline(project_point(pa3), project_point(pb3));
  if (!clip.ok) {
    return;
  }
  let width = cam.width;
  let height = cam.height;
  let a_img = vec2f(ndc_to_pixel(clip.a.x / clip.a.w, width), ndc_to_pixel(clip.a.y / clip.a.w, height));
  let b_img = vec2f(ndc_to_pixel(clip.b.x / clip.b.w, width), ndc_to_pixel(clip.b.y / clip.b.w, height));
  let beta = cam.beta;

  // ===== ProjectScreenKernel =====
  let center_hom = project_point(line_center);
  var screen_valid = center_hom.w > UNI_CLIP_W_MIN && is_finite(center_hom.w);
  let safe_w = select(1.0, center_hom.w, screen_valid);
  let inv_w2 = 1.0 / (safe_w * safe_w);
  let half_w = 0.5 * f32(width);
  let half_h = 0.5 * f32(height);
  let jx = vec3f(half_w * (safe_w * pm(0u) - center_hom.x * pm(3u)) * inv_w2,
                 half_w * (safe_w * pm(4u) - center_hom.x * pm(7u)) * inv_w2,
                 half_w * (safe_w * pm(8u) - center_hom.x * pm(11u)) * inv_w2);
  let jy = vec3f(half_h * (safe_w * pm(1u) - center_hom.y * pm(3u)) * inv_w2,
                 half_h * (safe_w * pm(5u) - center_hom.y * pm(7u)) * inv_w2,
                 half_h * (safe_w * pm(9u) - center_hom.y * pm(11u)) * inv_w2);
  let midpoint_img = vec2f(ndc_to_pixel(center_hom.x / safe_w, width),
                           ndc_to_pixel(center_hom.y / safe_w, height));
  let frame = kernel_frame(source_idx, jx, jy);
  let c3_00 = frame.c_int00 + frame.filter_variance * dot3(jx, jx);
  let c3_01 = frame.c_int01 + frame.filter_variance * dot3(jx, jy);
  let c3_11 = frame.c_int11 + frame.filter_variance * dot3(jy, jy);
  let c00 = c3_00 + beta;
  let c01 = c3_01;
  let c11 = c3_11 + beta;
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
  let ray = raw * inverse_ray_norm;
  let factors = amplitude_factors(frame, jx, jy, ray, chord.x, chord.y);
  let con_o = vec3f(c00, c01, c11);
  let taper = vec3f(c3_00, c3_01, c3_11);
  let rho = fmaxf(amp, 0.0);
  let q0 = rho * factors.transverse_product * factors.normal_norm;
  let lambda_int = sqrt(factors.metric) / (factors.normal_norm * factors.ray_product);
  let k_a = station_amplitude(factors, ratio_a, con_o, taper, chord.x, chord.y);
  let k_c = station_amplitude(factors, 1.0, con_o, taper, chord.x, chord.y);
  let k_b = station_amplitude(factors, ratio_b, con_o, taper, chord.x, chord.y);
  let peak = rho * fmaxf(k_a, fmaxf(k_c, k_b));
  let u_a = station_unfiltered(q0, lambda_int, ratio_a);
  let u_c = station_unfiltered(q0, lambda_int, 1.0);
  let u_b = station_unfiltered(q0, lambda_int, ratio_b);
  screen_valid = screen_valid && factors.positive_scales && is_finite(lambda_int)
      && is_finite(u_a) && is_finite(u_c) && is_finite(u_b);
  if (!screen_valid) {
    return;
  }
  let center_img = midpoint_img;

  // The peak-alpha cull.
  if (peak < MIN_TAU_CULL) {
    return;
  }
  // ComputeExtentCutoffQ2 with GaussianKernel().cutoff_q2.
  let cutoff_q2 = fmaxf(log(fmaxf(peak, EXTENT_CUT_TAU) / EXTENT_CUT_TAU), 1e-6);

  // ===== ComputeQuadFrame =====
  let dir = b_img - a_img;
  let len = hypot(dir.x, dir.y);
  let short = len < 1e-4;
  let safe_dir = select(dir, vec2f(1.0, 0.0), short);
  let safe_len = select(len, 1.0, short);
  let u_norm = vec2f(-safe_dir.y / safe_len, safe_dir.x / safe_len);
  let u_dir = vec2f(safe_dir.x / safe_len, safe_dir.y / safe_len);

  // ===== ComputePrimitiveExtent =====
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
  let diag = hypot(f32(width), f32(height));
  p_perp = fminf(p_perp, diag);
  p_along = fminf(p_along, diag);

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

  // ===== QuadTileBounds =====
  let wf = f32(width - 1u);
  let hf = f32(height - 1u);
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

  // ===== WritePrimitiveRow =====
  var prim: Prim;
  prim.aniso = vec4f(c3_00, c3_01, c3_11, select(ratio_a, -abs(ratio_a), point_limit));
  prim.bis = vec4f(q0, lambda_int, cutoff_q2, ratio_b);
  prim.ab = vec4f(a_img, b_img);
  prim.geo = vec4f(p_perp, p_along, depth, f32(max_distance));
  prim.rect = vec4u(u32(tx0), u32(ty0), u32(tx1), u32(ty1));
  prims[idx] = prim;
  var n_tiles = 0u;
  for (var ty = u32(ty0); ty < u32(ty1); ty = ty + 1u) {
    let span = tile_row_span(a_img, b_img, p_perp, p_along, ty, width, u32(tx0), u32(tx1));
    if (span.z != 0u) {
      n_tiles = n_tiles + (span.y - span.x);
    }
  }
  tiles[idx] = n_tiles;
}

fn dot3(x: vec3f, y: vec3f) -> f32 {
  return x.x * y.x + x.y * y.y + x.z * y.z;
}

// ===== P6: duplicateWithKeys =====
// The key of a pair is (tile, depth bits): key_hi = tile id, key_lo = the
// bits of the float32 depth. The value is the primitive index.
@compute @workgroup_size(256)
fn duplicate_keys(@builtin(local_invocation_index) lid: u32,
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
  let depth_bits = bitcast<u32>(prim.geo.z);
  let capacity = dup_cam.capacity;
  for (var y = prim.rect.y; y < prim.rect.w; y = y + 1u) {
    let span = tile_row_span(a_img, b_img, prim.geo.x, prim.geo.y, y,
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

