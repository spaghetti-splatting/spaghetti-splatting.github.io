// Interactive hair: strand simulation, pinch grab, and the deformation of
// the rendered rows. common.wgsl is in front of this file.
//
// Simulation: one thread per strand, root to tip. A port of the substep of
// StrandSim (prototyping/hair_strand_sim.py, _substep_kernel) as the browser
// demo sim.js has it, with the three steps fused into one sweep:
//   1. a = -k(arc) u + k_b f_bend + drag (wind - v) + grab;  v = (v + h a) e^{-damping h};  p = x + h v
//      u = x - x0; k(arc) = k_tip + (k_root - k_tip) exp(-arc / range) (style spring with gravity preloading);
//      f_bend = -(D_{k-1} - 2 D_k + D_{k+1}), D_k = u_{k-1} - 2 u_k + u_{k+1} (linearized bending)
//   2. DFTL (Mueller et al. 2012): p_k back to its rest length from the final leader p_{k-1}, then out of
//      the head SDF (two passes)
//   3. v_k = (p_k - x_k) / h - c d_{k+1} / h (DFTL velocity correction, c = 0.5); x_k = p_k
// Step 3 of vertex k needs d_{k+1}, so the sweep commits vertex k-1 at step k. The window
// u_{k-2} .. u_{k+2} of old displacements stays in registers, so the sweep never reads a
// committed position.
// Grab (pinch): vertex k* of each strand near the pick follows the cursor through a critically
// damped spring with weight w; vertices 1..k*-1 get the share (arc / arc_k*)^1.5 of the cursor
// displacement, since DFTL cannot pull toward the root.
//
// Deformation: each hair row (segment) turns rigidly with its chord. Q is the smallest rotation
// from the rest chord to the current chord. The row gets the current endpoints, the frame
// quaternion Q (x) q_rest (uni lanes 0..3; scales and filter variance unchanged), and its SV8
// direction sites turned by Q. With x = x0 bit for bit, Q is the identity and every value is
// bit for bit the rest value.

struct SimParams {
  strands: u32,
  vertices: u32,
  grab_on: u32,
  wind_on: u32,
  h: f32,
  decay: f32,
  drag: f32,
  bending: f32,
  style_root: f32,
  style_tip: f32,
  style_range: f32,   // metres
  stiff_k: f32,       // grab spring K (1/s^2)
  correction: f32,    // DFTL velocity correction c
  metres: f32,        // scene units per metre
  time: f32,
  gust: f32,
  delta: vec4f,       // xyz: cursor displacement (scene units)
  wind: vec4f,        // xyz: wind velocity (scene units / s)
  sdf_origin: vec4f,  // xyz origin, w = 1 / voxel
  sdf_shape: vec4u,   // nx, ny, nz
  grab_point: vec4f,  // xyz: picked point; w: grab radius (scene units)
};

@group(0) @binding(0) var<uniform> sp: SimParams;
@group(0) @binding(1) var<storage, read> strand_offsets: array<u32>;   // [S + 1]
@group(0) @binding(2) var<storage, read> rest4: array<vec4f>;          // [V] rest xyz, w = arc (m)
@group(0) @binding(3) var<storage, read_write> aux: array<vec4f>;      // [V] rest length, dmin, grab w, grab share
@group(0) @binding(4) var<storage, read_write> grab_base: array<vec4f>; // [V] position at grab start
@group(0) @binding(5) var<storage, read_write> xs: array<vec4f>;       // [V] position
@group(0) @binding(6) var<storage, read_write> vs: array<vec4f>;       // [V] velocity
@group(0) @binding(7) var<storage, read> sdf: array<f32>;              // [nx, ny, nz]
@group(0) @binding(8) var<storage, read_write> stats: array<atomic<u32>>; // [0] max speed^2 bits, [1] max |u|^2 bits, [2] grabbed strands

// Trilinear SDF and its unit gradient (sim.js, HairSim.sample).
struct SdfSample {
  d: f32,
  g: vec3f,
};

fn sdf_at(p: vec3f) -> SdfSample {
  var out: SdfSample;
  let nx = sp.sdf_shape.x;
  let ny = sp.sdf_shape.y;
  let nz = sp.sdf_shape.z;
  let f = (p - sp.sdf_origin.xyz) * sp.sdf_origin.w;
  if (f.x < 0.0 || f.y < 0.0 || f.z < 0.0 || f.x > f32(nx) - 1.001 || f.y > f32(ny) - 1.001
      || f.z > f32(nz) - 1.001) {
    out.d = 1.0e6;
    out.g = vec3f(0.0);
    return out;
  }
  let i = u32(f.x);
  let j = u32(f.y);
  let k = u32(f.z);
  let fx = f.x - f32(i);
  let fy = f.y - f32(j);
  let fz = f.z - f32(k);
  let o = (i * ny + j) * nz + k;
  let sj = nz;
  let si = ny * nz;
  let c000 = sdf[o];
  let c001 = sdf[o + 1u];
  let c010 = sdf[o + sj];
  let c011 = sdf[o + sj + 1u];
  let c100 = sdf[o + si];
  let c101 = sdf[o + si + 1u];
  let c110 = sdf[o + si + sj];
  let c111 = sdf[o + si + sj + 1u];
  let c00 = c000 + (c001 - c000) * fz;
  let c01 = c010 + (c011 - c010) * fz;
  let c10 = c100 + (c101 - c100) * fz;
  let c11 = c110 + (c111 - c110) * fz;
  let c0 = c00 + (c01 - c00) * fy;
  let c1 = c10 + (c11 - c10) * fy;
  let gx = c1 - c0;
  let gy = (1.0 - fx) * (c01 - c00) + fx * (c11 - c10);
  let e0 = (c001 - c000) * (1.0 - fy) + (c011 - c010) * fy;
  let e1 = (c101 - c100) * (1.0 - fy) + (c111 - c110) * fy;
  let gz = e0 * (1.0 - fx) + e1 * fx;
  let g = vec3f(gx, gy, gz);
  let n = length(g);
  out.g = select(vec3f(0.0), g / n, n > 0.0);
  out.d = c0 + (c1 - c0) * fx;
  return out;
}

fn displacement(i: u32) -> vec3f {
  return xs[i].xyz - rest4[i].xyz;
}

// DFTL follow: q at distance len from the leader, along q - leader.
fn follow(leader: vec3f, q: vec3f, rest_dir: vec3f, len: f32) -> vec3f {
  var e = q - leader;
  var n = length(e);
  if (n < 1.0e-12) {
    e = rest_dir;
    n = length(e);
  }
  return leader + e * (len / n);
}

fn atomic_max_f32(slot: u32, value: f32) {
  // Non-negative float32 values order as their bits.
  atomicMax(&stats[slot], bitcast<u32>(max(value, 0.0)));
}

@compute @workgroup_size(64)
fn substep(@builtin(global_invocation_id) gid: vec3u, @builtin(num_workgroups) nwg: vec3u) {
  let s = gid.x + gid.y * nwg.x * 64u;
  if (s >= sp.strands) {
    return;
  }
  let base = strand_offsets[s];
  let n = strand_offsets[s + 1u] - base;
  if (n < 2u) {
    return;
  }
  let h = sp.h;
  let kb = sp.bending;
  let big_k = sp.stiff_k;
  let damp_c = 2.0 * sqrt(big_k);
  let ih = 1.0 / h;
  let ch = sp.correction / h;
  // Root: stays at the trained position.
  xs[base] = vec4f(rest4[base].xyz, 0.0);
  vs[base] = vec4f(0.0);
  // Wind gust of this strand (sim.js).
  var wind = vec3f(0.0);
  if (sp.wind_on != 0u) {
    let fs = f32(s);
    let gust = 0.6 + 0.4 * sin(2.3 * sp.time + 0.0007 * fs) + 0.25 * sin(5.1 * sp.time + 0.0013 * fs);
    wind = sp.wind.xyz * gust;
  }
  // Window of old displacements u_{k-2} .. u_{k+2} (u_0 = 0 at the root).
  var um2 = vec3f(0.0);
  var um1 = vec3f(0.0);
  var u0 = vec3f(0.0);
  var up1 = displacement(base + 1u);
  var up2 = vec3f(0.0);
  if (n > 2u) {
    up2 = displacement(base + 2u);
  }
  var lead = rest4[base].xyz;     // final position of the leader
  var prev_p = lead;              // p of vertex k-1
  var prev_x = lead;              // old x of vertex k-1
  var max_v2 = 0.0;
  var max_u2 = 0.0;
  let last = n - 1u;
  for (var k = 1u; k < n; k = k + 1u) {
    // Shift the window: u0 = u_k.
    um2 = um1;
    um1 = u0;
    u0 = up1;
    up1 = up2;
    if (k + 2u < n) {
      up2 = displacement(base + k + 2u);
    } else {
      up2 = vec3f(0.0);
    }
    let i = base + k;
    let x = xs[i].xyz;
    let v = vs[i].xyz;
    let r4 = rest4[i];
    let ax4 = aux[i];
    // D_j for j = k-1, k, k+1; D_j = 0 outside 1..n-2.
    let dkm1 = select(vec3f(0.0), um2 - 2.0 * um1 + u0, k >= 2u);
    let dk = select(vec3f(0.0), um1 - 2.0 * u0 + up1, k <= n - 2u);
    let dkp1 = select(vec3f(0.0), u0 - 2.0 * up1 + up2, k + 1u <= n - 2u);
    let bend = -dkm1 + 2.0 * dk - dkp1;
    let stiffness = sp.style_tip + (sp.style_root - sp.style_tip) * exp(-r4.w / sp.style_range);
    var a = -stiffness * u0 + kb * bend + sp.drag * (wind - v);
    let w = ax4.z;
    if (sp.grab_on != 0u && w > 0.0) {
      let goal = grab_base[i].xyz + ax4.w * sp.delta.xyz;
      a = a + w * (big_k * (goal - x) - damp_c * v);
    }
    let vel = (v + h * a) * sp.decay;
    let p0 = x + h * vel;
    // DFTL with collision.
    let rest_len = ax4.x;
    let dmin = ax4.y;
    let rest_dir = r4.xyz - rest4[i - 1u].xyz;
    var q = follow(lead, p0, rest_dir, rest_len);
    for (var it = 0u; it < 2u; it = it + 1u) {
      let smp = sdf_at(q);
      if (!(smp.d < dmin)) {
        break;
      }
      q = q + (dmin - smp.d) * smp.g;
      q = follow(lead, q, rest_dir, rest_len);
    }
    let d = q - p0;
    // Commit vertex k-1 (not the root) with the correction from d_k.
    if (k >= 2u) {
      let j = i - 1u;
      let vj = (prev_p - prev_x) * ih - ch * d;
      vs[j] = vec4f(vj, 0.0);
      xs[j] = vec4f(prev_p, 0.0);
      max_v2 = max(max_v2, dot(vj, vj));
      let uj = prev_p - rest4[j].xyz;
      max_u2 = max(max_u2, dot(uj, uj));
    }
    prev_p = q;
    prev_x = x;
    lead = q;
    if (k == last) {
      // The tip: no correction.
      let vt = (q - x) * ih;
      vs[i] = vec4f(vt, 0.0);
      xs[i] = vec4f(q, 0.0);
      max_v2 = max(max_v2, dot(vt, vt));
      let ut = q - r4.xyz;
      max_u2 = max(max_u2, dot(ut, ut));
    }
  }
  atomic_max_f32(0u, max_v2);
  atomic_max_f32(1u, max_u2);
}

// Grab start: for each strand, the nearest link vertex k* within the radius of the pick.
// Writes the grab weight and share of every vertex of the strand (0 when not grabbed).
@compute @workgroup_size(64)
fn grab_begin(@builtin(global_invocation_id) gid: vec3u, @builtin(num_workgroups) nwg: vec3u) {
  let s = gid.x + gid.y * nwg.x * 64u;
  if (s >= sp.strands) {
    return;
  }
  let base = strand_offsets[s];
  let n = strand_offsets[s + 1u] - base;
  let radius = sp.grab_point.w;
  let centre = sp.grab_point.xyz;
  var best = radius;
  var kb = 0u;
  for (var k = 1u; k < n; k = k + 1u) {
    let dd = length(xs[base + k].xyz - centre);
    if (dd < best) {
      best = dd;
      kb = k;
    }
  }
  let sig2 = 0.5 * radius * radius;
  let w0 = exp(-best * best / sig2);
  let arc_star = max(rest4[base + kb].w, 1.0e-9);
  for (var k = 0u; k < n; k = k + 1u) {
    let i = base + k;
    var ax4 = aux[i];
    if (kb > 0u && k >= 1u && k <= kb) {
      ax4.z = w0;
      ax4.w = pow(min(rest4[i].w / arc_star, 1.0), 1.5);
      grab_base[i] = xs[i];
    } else {
      ax4.z = 0.0;
      ax4.w = 0.0;
    }
    aux[i] = ax4;
  }
  if (kb > 0u) {
    atomicAdd(&stats[2], 1u);
  }
}

// Reset: x = x0, v = 0.
@compute @workgroup_size(256)
fn reset_state(@builtin(global_invocation_id) gid: vec3u, @builtin(num_workgroups) nwg: vec3u) {
  let i = gid.x + gid.y * nwg.x * 256u;
  if (i >= sp.vertices) {
    return;
  }
  xs[i] = vec4f(rest4[i].xyz, 0.0);
  vs[i] = vec4f(0.0);
  var ax4 = aux[i];
  ax4.z = 0.0;
  ax4.w = 0.0;
  aux[i] = ax4;
}
