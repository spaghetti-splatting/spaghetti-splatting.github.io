// Shared constants and helpers. viewer.js puts this file in front of every
// other shader file. All arithmetic is float32 or u32.

const WORKGROUP_SIZE: u32 = 256u;

// Slots of the counts buffer (array<u32>). The GPU writes the counts of one
// frame there, so no pass reads a count back to the host.
const SLOT_ROWS: u32 = 0u;          // N, the active rows (host write)
const SLOT_KEPT: u32 = 1u;          // K, the kept rows of the prefilter (P1)
const SLOT_PAIRS: u32 = 2u;         // pair count, clamped to the capacity (P5)
const SLOT_PAIRS_RAW: u32 = 3u;     // pair count before the clamp (P5)
const SLOT_SORT_GROUPS: u32 = 4u;   // ceil(pairs / 256), sort workgroups
const SLOT_SORT_COUNTS: u32 = 5u;   // 16 * sort workgroups, digit counts
const SLOT_FACE_ROWS: u32 = 6u;     // rows of the face-factor pass (P2)
// The scan plans write their level sizes from this slot upward.
const SLOT_PLAN_BASE: u32 = 16u;

// The linear workgroup index of a 1D or 2D dispatch. A dispatch of more than
// 65535 workgroups uses a 2D grid (viewer.js, gridOf).
fn linear_group(wid: vec3u, nwg: vec3u) -> u32 {
  return wid.x + wid.y * nwg.x;
}

// ---- Exact float32 arithmetic helpers ----
// nvcc contracts a * b + c into one FFMA (one rounding). SwiftShader computes
// the WGSL built-in fma with two roundings, so the port forms the fused
// result exactly from error-free transformations. The helpers need IEEE
// round-to-nearest float32 additions and multiplications without
// contraction.

// s + e = a + b exactly (Knuth TwoSum).
fn two_sum(a: f32, b: f32) -> vec2f {
  let s = a + b;
  let bb = s - a;
  let e = (a - (s - bb)) + (b - bb);
  return vec2f(s, e);
}

// hi + lo = a exactly, with 12 significant bits in hi (Veltkamp split).
fn split_f32(a: f32) -> vec2f {
  let t = 4097.0 * a;
  let hi = t - (t - a);
  return vec2f(hi, a - hi);
}

// p + e = a * b exactly (Dekker TwoProduct).
fn two_product(a: f32, b: f32) -> vec2f {
  let p = a * b;
  let sa = split_f32(a);
  let sb = split_f32(b);
  let e = ((sa.x * sb.x - p) + sa.x * sb.y + sa.y * sb.x) + sa.y * sb.y;
  return vec2f(p, e);
}

// a + b rounded to odd: the rounded sum, with its last bit set when the sum
// is not exact (Boldo and Melquiond).
fn add_round_odd(a: f32, b: f32) -> f32 {
  let r = two_sum(a, b);
  var bits = bitcast<u32>(r.x);
  if (r.y != 0.0 && (bits & 1u) == 0u) {
    // Move one unit toward the exact sum. r.x and r.y have the same sign
    // when the exact sum is larger in magnitude than r.x.
    if ((r.y > 0.0) == (r.x > 0.0)) {
      bits = bits + 1u;
    } else {
      bits = bits - 1u;
    }
  }
  return bitcast<f32>(bits);
}

// The correctly rounded a * b + c (one rounding), as the CUDA FFMA and
// fmaf compute it. Emulation of Boldo and Melquiond (2008).
fn fma_exact(a: f32, b: f32, c: f32) -> f32 {
  let p = two_product(a, b);
  let t = two_sum(c, p.y);
  let v = two_sum(p.x, t.x);
  let z = add_round_odd(t.y, v.y);
  return v.x + z;
}

// CUDA fmaxf and fminf (FMNMX) return the other operand when one operand
// is NaN. WGSL max and min do not define that case.
fn is_nan(x: f32) -> bool {
  return (bitcast<u32>(x) & 0x7fffffffu) > 0x7f800000u;
}

fn is_finite(x: f32) -> bool {
  return (bitcast<u32>(x) & 0x7f800000u) != 0x7f800000u;
}

fn fmaxf(a: f32, b: f32) -> f32 {
  if (is_nan(a)) { return b; }
  if (is_nan(b)) { return a; }
  return max(a, b);
}

fn fminf(a: f32, b: f32) -> f32 {
  if (is_nan(a)) { return b; }
  if (is_nan(b)) { return a; }
  return min(a, b);
}

// CUDA signbit.
fn sign_bit(x: f32) -> bool {
  return (bitcast<u32>(x) & 0x80000000u) != 0u;
}

// The camera of one frame. view and proj hold the 16 floats of view_matrix
// and proj_matrix in the order that the CUDA kernel reads them through
// data_ptr: float k is view[k / 4][k % 4].
struct Camera {
  view: array<vec4f, 4>,
  proj: array<vec4f, 4>,
  campos: vec4f,
  background: vec4f,
  width: u32,
  height: u32,
  tiles_x: u32,
  tiles_y: u32,
  w_aa: f32,                // AA_2D_PX as float32
  beta: f32,                // w_aa * w_aa in float32 (the CUDA pixel filter)
  pad_x: f32,               // 1 + 2 pixel_pad / width (prefilter)
  pad_y: f32,               // 1 + 2 pixel_pad / height (prefilter)
  support_scale: f32,       // VISIBILITY_PREFILTER_SCALE
  face_pixel_variance: f32, // float32(AA_2D_PX * AA_2D_PX) of the torch face factor
  half_width: f32,          // float32(0.5 * width) of the torch face factor
  half_height: f32,         // float32(0.5 * height) of the torch face factor
  rows: u32,                // N
  capacity: u32,            // pair capacity
  diag: u32,                // 1: P2 and P4 also fill the diagnostic rows
  pad0: u32,
};

