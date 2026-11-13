// Live wind on the fur graph (windsim.js). Data: <model>/windsim/ (sim.json and the .f32 / .u32 files).
// One substep (dt = 1 / (fps * substeps)):
//   node_step  (free node i, graph node g = free[i]): x0 = x; U = s w0 + s turb sum_k ea_k sin(kvec_k . x_rest + phase_k
//              - omega_k t); U -= (U . n_i) n_i; v += dt (c_drag (chi_i U - v) + k_rest (x_rest - x)); x += dt v.
//   jacobi     (pbd_iters sweeps, ping-pong between two position buffers; the pinned nodes hold x_rest in both):
//              x_new = x + (sum_e (|d| - l0_e) / |d| d inv_e) / deg_i, d = x[adj_e] - x.
//   velocity   v = (x - x0) / dt.
// rows_out (once per display frame): the endpoints of a moving row = rest + (x - x_rest) at its two nodes. The row
// turns with its chord: Q = the smallest rotation from the rest chord to the current chord; frame quaternion =
// Q (x) q_rest. The scales, the filter variance and the SV8 sites keep their rest values.

struct SimParams {
  t: f32,          // sim time of the substep, mod period_s
  s: f32,          // wind strength (0 when the wind is off)
  turb: f32,       // turbulence / 0.7
  dt: f32,
  c_drag: f32,
  k_rest: f32,
  free_count: u32, // F
  modes: u32,      // K
  rows: u32,       // R
  pad0: u32,
  pad1: u32,
  pad2: u32,
};

@group(0) @binding(0) var<uniform> sp: SimParams;
@group(0) @binding(1) var<storage, read> modes: array<vec4f>;        // [1 + 2K]: w0; (kvec, phase) x K; (ea, omega) x K
@group(0) @binding(2) var<storage, read> x_rest: array<f32>;         // [G, 3]
@group(0) @binding(3) var<storage, read> free_ids: array<u32>;       // [F]
@group(0) @binding(4) var<storage, read> free_chi: array<f32>;       // [F]
@group(0) @binding(5) var<storage, read> free_n: array<f32>;         // [F, 3]
@group(0) @binding(6) var<storage, read> free_deg: array<f32>;       // [F]
@group(0) @binding(7) var<storage, read> adj_off: array<u32>;        // [F + 1]
@group(0) @binding(8) var<storage, read> adj: array<u32>;            // [E2]
@group(0) @binding(9) var<storage, read> adj_l0: array<f32>;         // [E2]
@group(0) @binding(10) var<storage, read> adj_inv: array<f32>;       // [E2]
@group(0) @binding(11) var<storage, read_write> x_cur: array<f32>;   // [G, 3], node_step
@group(0) @binding(12) var<storage, read> x_src: array<f32>;         // [G, 3]
@group(0) @binding(13) var<storage, read_write> x_dst: array<f32>;   // [G, 3], jacobi
@group(0) @binding(14) var<storage, read_write> vel: array<f32>;     // [F, 3]
@group(0) @binding(15) var<storage, read_write> x_old: array<f32>;   // [F, 3]
@group(0) @binding(16) var<storage, read> rows: array<u32>;          // [R], model rows
@group(0) @binding(17) var<storage, read> row_nodes: array<u32>;     // [R, 2]
@group(0) @binding(18) var<storage, read> ends_rest: array<f32>;     // [N, 2, 3]
@group(0) @binding(19) var<storage, read> uni_rest: array<f32>;      // [N, 8]
@group(0) @binding(20) var<storage, read_write> endpoints: array<f32>;  // [N, 2, 3]
@group(0) @binding(21) var<storage, read_write> uni: array<f32>;        // [N, 8]

fn rest3(i: u32) -> vec3f {
  return vec3f(x_rest[3u * i], x_rest[3u * i + 1u], x_rest[3u * i + 2u]);
}

fn src3(i: u32) -> vec3f {
  return vec3f(x_src[3u * i], x_src[3u * i + 1u], x_src[3u * i + 2u]);
}

@compute @workgroup_size(256)
fn node_step(@builtin(local_invocation_index) lid: u32,
             @builtin(workgroup_id) wid: vec3u,
             @builtin(num_workgroups) nwg: vec3u) {
  let i = linear_group(wid, nwg) * WORKGROUP_SIZE + lid;
  if (i >= sp.free_count) {
    return;
  }
  let g = free_ids[i];
  let xr = rest3(g);
  let x = vec3f(x_cur[3u * g], x_cur[3u * g + 1u], x_cur[3u * g + 2u]);
  x_old[3u * i] = x.x;
  x_old[3u * i + 1u] = x.y;
  x_old[3u * i + 2u] = x.z;
  var sum = vec3f(0.0);
  for (var k = 0u; k < sp.modes; k = k + 1u) {
    let kp = modes[1u + k];
    let eo = modes[1u + sp.modes + k];
    sum = sum + eo.xyz * sin(dot(kp.xyz, xr) + kp.w - eo.w * sp.t);
  }
  var u = sp.s * modes[0].xyz + (sp.s * sp.turb) * sum;
  let n = vec3f(free_n[3u * i], free_n[3u * i + 1u], free_n[3u * i + 2u]);
  u = u - dot(u, n) * n;
  var v = vec3f(vel[3u * i], vel[3u * i + 1u], vel[3u * i + 2u]);
  v = v + sp.dt * (sp.c_drag * (free_chi[i] * u - v) + sp.k_rest * (xr - x));
  vel[3u * i] = v.x;
  vel[3u * i + 1u] = v.y;
  vel[3u * i + 2u] = v.z;
  let xn = x + sp.dt * v;
  x_cur[3u * g] = xn.x;
  x_cur[3u * g + 1u] = xn.y;
  x_cur[3u * g + 2u] = xn.z;
}

@compute @workgroup_size(256)
fn jacobi(@builtin(local_invocation_index) lid: u32,
          @builtin(workgroup_id) wid: vec3u,
          @builtin(num_workgroups) nwg: vec3u) {
  let i = linear_group(wid, nwg) * WORKGROUP_SIZE + lid;
  if (i >= sp.free_count) {
    return;
  }
  let g = free_ids[i];
  let xg = src3(g);
  var delta = vec3f(0.0);
  for (var e = adj_off[i]; e < adj_off[i + 1u]; e = e + 1u) {
    let d = src3(adj[e]) - xg;
    let ln = max(length(d), 1.0e-12);
    delta = delta + (ln - adj_l0[e]) / ln * d * adj_inv[e];
  }
  let xn = xg + delta / free_deg[i];
  x_dst[3u * g] = xn.x;
  x_dst[3u * g + 1u] = xn.y;
  x_dst[3u * g + 2u] = xn.z;
}

@compute @workgroup_size(256)
fn velocity(@builtin(local_invocation_index) lid: u32,
            @builtin(workgroup_id) wid: vec3u,
            @builtin(num_workgroups) nwg: vec3u) {
  let i = linear_group(wid, nwg) * WORKGROUP_SIZE + lid;
  if (i >= sp.free_count) {
    return;
  }
  let g = free_ids[i];
  let v = (src3(g) - vec3f(x_old[3u * i], x_old[3u * i + 1u], x_old[3u * i + 2u])) / sp.dt;
  vel[3u * i] = v.x;
  vel[3u * i + 1u] = v.y;
  vel[3u * i + 2u] = v.z;
}

fn quat_mul(a: vec4f, b: vec4f) -> vec4f {
  // (w, x, y, z) Hamilton product.
  let av = a.yzw;
  let bv = b.yzw;
  let v = a.x * bv + b.x * av + cross(av, bv);
  return vec4f(a.x * b.x - dot(av, bv), v);
}

@compute @workgroup_size(256)
fn rows_out(@builtin(local_invocation_index) lid: u32,
            @builtin(workgroup_id) wid: vec3u,
            @builtin(num_workgroups) nwg: vec3u) {
  let r = linear_group(wid, nwg) * WORKGROUP_SIZE + lid;
  if (r >= sp.rows) {
    return;
  }
  let row = rows[r];
  let na = row_nodes[2u * r];
  let nb = row_nodes[2u * r + 1u];
  let da = src3(na) - rest3(na);
  let db = src3(nb) - rest3(nb);
  let e = 6u * row;
  let a0 = vec3f(ends_rest[e], ends_rest[e + 1u], ends_rest[e + 2u]);
  let b0 = vec3f(ends_rest[e + 3u], ends_rest[e + 4u], ends_rest[e + 5u]);
  let a = a0 + da;
  let b = b0 + db;
  endpoints[e] = a.x;
  endpoints[e + 1u] = a.y;
  endpoints[e + 2u] = a.z;
  endpoints[e + 3u] = b.x;
  endpoints[e + 4u] = b.y;
  endpoints[e + 5u] = b.z;
  let n0 = normalize(b0 - a0);
  let n1 = normalize(b - a);
  let dn = dot(n0, n1);
  var q: vec4f;
  if (dn < -0.999999) {
    // Half turn about any axis normal to the chord (deform.wgsl).
    var axis = cross(n0, vec3f(1.0, 0.0, 0.0));
    if (dot(axis, axis) < 1.0e-6) {
      axis = cross(n0, vec3f(0.0, 1.0, 0.0));
    }
    q = vec4f(0.0, normalize(axis));
  } else {
    q = normalize(vec4f(1.0 + dn, cross(n0, n1)));
  }
  let u = 8u * row;
  let q_rest = vec4f(uni_rest[u], uni_rest[u + 1u], uni_rest[u + 2u], uni_rest[u + 3u]);
  let q_new = normalize(quat_mul(q, q_rest));
  uni[u] = q_new.x;
  uni[u + 1u] = q_new.y;
  uni[u + 2u] = q_new.z;
  uni[u + 3u] = q_new.w;
}
