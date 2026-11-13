// Deformation of the rendered hair rows from the simulated vertices (see hair.wgsl).
// One thread per strand vertex i > root; row = rows[i] is the segment from vertex i-1 to i.
// The row turns rigidly with its chord: Q = the smallest rotation from the rest chord to the
// current chord; endpoints = (x_{i-1}, x_i); frame quaternion = Q (x) q_rest; SV8 sites = Q s.
// When the chord equals the rest chord bit for bit, the row gets its rest values unchanged.

struct DeformParams {
  vertices: u32,
  pad0: u32,
  pad1: u32,
  pad2: u32,
};

@group(0) @binding(0) var<uniform> dp: DeformParams;
@group(0) @binding(1) var<storage, read> rows: array<u32>;          // [V], 0xffffffff at a root
@group(0) @binding(2) var<storage, read> xs: array<vec4f>;          // [V]
@group(0) @binding(3) var<storage, read> rest4: array<vec4f>;       // [V]
@group(0) @binding(4) var<storage, read> uni_rest: array<f32>;      // [N, 8]
@group(0) @binding(5) var<storage, read_write> uni: array<f32>;     // [N, 8]
@group(0) @binding(6) var<storage, read> sites_rest: array<f32>;    // [N, 8, 3]
@group(0) @binding(7) var<storage, read_write> sites: array<f32>;   // [N, 8, 3]
@group(0) @binding(8) var<storage, read_write> endpoints: array<f32>; // [N, 2, 3]

fn quat_mul(a: vec4f, b: vec4f) -> vec4f {
  // (w, x, y, z) Hamilton product.
  let av = a.yzw;
  let bv = b.yzw;
  let v = a.x * bv + b.x * av + cross(av, bv);
  return vec4f(a.x * b.x - dot(av, bv), v);
}

fn quat_rotate(q: vec4f, s: vec3f) -> vec3f {
  let t = 2.0 * cross(q.yzw, s);
  return s + q.x * t + cross(q.yzw, t);
}

@compute @workgroup_size(256)
fn deform(@builtin(global_invocation_id) gid: vec3u, @builtin(num_workgroups) nwg: vec3u) {
  let i = gid.x + gid.y * nwg.x * 256u;
  if (i >= dp.vertices) {
    return;
  }
  let row = rows[i];
  if (row == 0xffffffffu) {
    return;
  }
  let a = xs[i - 1u].xyz;
  let b = xs[i].xyz;
  let ra = rest4[i - 1u].xyz;
  let rb = rest4[i].xyz;
  let c = b - a;
  let c0 = rb - ra;
  let e = 6u * row;
  endpoints[e] = a.x;
  endpoints[e + 1u] = a.y;
  endpoints[e + 2u] = a.z;
  endpoints[e + 3u] = b.x;
  endpoints[e + 4u] = b.y;
  endpoints[e + 5u] = b.z;
  let u = 8u * row;
  let st = 24u * row;
  if (all(c == c0)) {
    for (var k = 0u; k < 4u; k = k + 1u) {
      uni[u + k] = uni_rest[u + k];
    }
    for (var k = 0u; k < 24u; k = k + 1u) {
      sites[st + k] = sites_rest[st + k];
    }
    return;
  }
  let n0 = normalize(c0);
  let n1 = normalize(c);
  let d = dot(n0, n1);
  var q: vec4f;
  if (d < -0.999999) {
    // Half turn about any axis normal to the chord.
    var axis = cross(n0, vec3f(1.0, 0.0, 0.0));
    if (dot(axis, axis) < 1.0e-6) {
      axis = cross(n0, vec3f(0.0, 1.0, 0.0));
    }
    q = vec4f(0.0, normalize(axis));
  } else {
    q = normalize(vec4f(1.0 + d, cross(n0, n1)));
  }
  let q_rest = vec4f(uni_rest[u], uni_rest[u + 1u], uni_rest[u + 2u], uni_rest[u + 3u]);
  let q_new = normalize(quat_mul(q, q_rest));
  uni[u] = q_new.x;
  uni[u + 1u] = q_new.y;
  uni[u + 2u] = q_new.z;
  uni[u + 3u] = q_new.w;
  for (var k = 0u; k < 8u; k = k + 1u) {
    let o = st + 3u * k;
    let s = quat_rotate(q, vec3f(sites_rest[o], sites_rest[o + 1u], sites_rest[o + 2u]));
    sites[o] = s.x;
    sites[o + 1u] = s.y;
    sites[o + 2u] = s.z;
  }
}
