// Picking under the cursor, in three passes over the candidates:
//   1. the smallest view depth of the candidates within the pixel radius (atomicMin on the bits),
//   2. the smallest index with that depth,
//   3. that candidate writes its 3D point.
// Candidates: hair vertices (pick_v_*) or rows (pick_r_*): the point of the segment nearest to the
// cursor in the image, for rows with amplitude >= the threshold. The camera is the camera of the
// last rendered frame (the Camera uniform of the renderer), so the pick matches the image.
// result: [0] depth bits, [1] index, [2..4] point xyz bits.

struct PickParams {
  cursor: vec2f,      // render pixels
  radius: f32,        // render pixels
  min_amplitude: f32,
  count: u32,
  pad0: u32,
  pad1: u32,
  pad2: u32,
};

@group(0) @binding(0) var<uniform> pk: PickParams;
@group(0) @binding(1) var<uniform> cam: Camera;
@group(0) @binding(2) var<storage, read_write> result: array<atomic<u32>, 8>;
@group(0) @binding(3) var<storage, read> xs: array<vec4f>;        // vertex mode
@group(0) @binding(4) var<storage, read> endpoints: array<f32>;   // row mode
@group(0) @binding(5) var<storage, read> amplitude: array<f32>;   // row mode

fn pm(k: u32) -> f32 {
  return cam.proj[k >> 2u][k & 3u];
}

fn vm(k: u32) -> f32 {
  return cam.view[k >> 2u][k & 3u];
}

// Pixel position (x, y) and view depth (z); z <= 0 when behind the camera.
fn project(p: vec3f) -> vec3f {
  let hx = p.x * pm(0u) + p.y * pm(4u) + p.z * pm(8u) + pm(12u);
  let hy = p.x * pm(1u) + p.y * pm(5u) + p.z * pm(9u) + pm(13u);
  let hw = p.x * pm(3u) + p.y * pm(7u) + p.z * pm(11u) + pm(15u);
  let depth = p.x * vm(2u) + p.y * vm(6u) + p.z * vm(10u) + vm(14u);
  let w = max(hw, 1.0e-9);
  let px = ((hx / w + 1.0) * f32(cam.width) - 1.0) * 0.5;
  let py = ((hy / w + 1.0) * f32(cam.height) - 1.0) * 0.5;
  return vec3f(px, py, select(-1.0, depth, hw > 1.0e-6 && depth > cam_znear()));
}

fn cam_znear() -> f32 {
  return 0.01;
}

struct Hit {
  ok: bool,
  depth: f32,
  point: vec3f,
};

fn vertex_hit(i: u32) -> Hit {
  var hit: Hit;
  let p = xs[i].xyz;
  let s = project(p);
  hit.ok = s.z > 0.0 && distance(s.xy, pk.cursor) <= pk.radius;
  hit.depth = s.z;
  hit.point = p;
  return hit;
}

fn row_hit(r: u32) -> Hit {
  var hit: Hit;
  hit.ok = false;
  if (amplitude[r] < pk.min_amplitude) {
    return hit;
  }
  let e = 6u * r;
  let a = vec3f(endpoints[e], endpoints[e + 1u], endpoints[e + 2u]);
  let b = vec3f(endpoints[e + 3u], endpoints[e + 4u], endpoints[e + 5u]);
  let sa = project(a);
  let sb = project(b);
  if (sa.z <= 0.0 || sb.z <= 0.0) {
    return hit;
  }
  let ab = sb.xy - sa.xy;
  let len2 = dot(ab, ab);
  var t = 0.0;
  if (len2 > 1.0e-9) {
    t = clamp(dot(pk.cursor - sa.xy, ab) / len2, 0.0, 1.0);
  }
  let q = sa.xy + t * ab;
  hit.ok = distance(q, pk.cursor) <= pk.radius;
  hit.point = a + t * (b - a);
  hit.depth = sa.z + t * (sb.z - sa.z);
  return hit;
}

fn index_of(gid: vec3u, nwg: vec3u) -> u32 {
  return gid.x + gid.y * nwg.x * 256u;
}

@compute @workgroup_size(256)
fn pick_v_depth(@builtin(global_invocation_id) gid: vec3u, @builtin(num_workgroups) nwg: vec3u) {
  let i = index_of(gid, nwg);
  if (i >= pk.count) { return; }
  let h = vertex_hit(i);
  if (h.ok) { atomicMin(&result[0], bitcast<u32>(h.depth)); }
}

@compute @workgroup_size(256)
fn pick_v_index(@builtin(global_invocation_id) gid: vec3u, @builtin(num_workgroups) nwg: vec3u) {
  let i = index_of(gid, nwg);
  if (i >= pk.count) { return; }
  let h = vertex_hit(i);
  if (h.ok && bitcast<u32>(h.depth) == atomicLoad(&result[0])) { atomicMin(&result[1], i); }
}

@compute @workgroup_size(256)
fn pick_v_point(@builtin(global_invocation_id) gid: vec3u, @builtin(num_workgroups) nwg: vec3u) {
  let i = index_of(gid, nwg);
  if (i >= pk.count || i != atomicLoad(&result[1])) { return; }
  let h = vertex_hit(i);
  atomicStore(&result[2], bitcast<u32>(h.point.x));
  atomicStore(&result[3], bitcast<u32>(h.point.y));
  atomicStore(&result[4], bitcast<u32>(h.point.z));
}

@compute @workgroup_size(256)
fn pick_r_depth(@builtin(global_invocation_id) gid: vec3u, @builtin(num_workgroups) nwg: vec3u) {
  let i = index_of(gid, nwg);
  if (i >= pk.count) { return; }
  let h = row_hit(i);
  if (h.ok) { atomicMin(&result[0], bitcast<u32>(h.depth)); }
}

@compute @workgroup_size(256)
fn pick_r_index(@builtin(global_invocation_id) gid: vec3u, @builtin(num_workgroups) nwg: vec3u) {
  let i = index_of(gid, nwg);
  if (i >= pk.count) { return; }
  let h = row_hit(i);
  if (h.ok && bitcast<u32>(h.depth) == atomicLoad(&result[0])) { atomicMin(&result[1], i); }
}

@compute @workgroup_size(256)
fn pick_r_point(@builtin(global_invocation_id) gid: vec3u, @builtin(num_workgroups) nwg: vec3u) {
  let i = index_of(gid, nwg);
  if (i >= pk.count || i != atomicLoad(&result[1])) { return; }
  let h = row_hit(i);
  atomicStore(&result[2], bitcast<u32>(h.point.x));
  atomicStore(&result[3], bitcast<u32>(h.point.y));
  atomicStore(&result[4], bitcast<u32>(h.point.z));
}
