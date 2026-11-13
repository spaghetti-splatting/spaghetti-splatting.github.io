// P4: the SV8 colour of one kept row at the segment midpoint, a port of
// evalVisibleSVoronoiReference8MidpointKernel (svoronoi_eval.cu 222-305).
// The kernel evaluates the rows that reach a tile (tiles_touched > 0). With
// cam.diag = 1 it evaluates every kept row, which fills the diagnostic
// diag_sv_rgb.f32. The render reads the colour of a row with tiles alone.

@group(0) @binding(0) var<storage, read> kept_rows: array<u32>;   // [K]
@group(0) @binding(1) var<storage, read> tiles: array<u32>;       // [K]
@group(0) @binding(2) var<storage, read> endpoints: array<f32>;   // [N, 2, 3]
@group(0) @binding(3) var<storage, read> sv_sites: array<f32>;    // [N, 8, 3]
@group(0) @binding(4) var<storage, read> sv_colors: array<f32>;   // [N, 8, 3]
@group(0) @binding(5) var<storage, read> sv_log_tau: array<f32>;  // [N, 8]
@group(0) @binding(6) var<storage, read> counts: array<u32>;
@group(0) @binding(7) var<storage, read_write> rgb: array<f32>;   // [K, 3]
@group(0) @binding(8) var<uniform> cam: Camera;

const SITES: u32 = 8u;
const REFERENCE_EPSILON: f32 = 1e-12;

@compute @workgroup_size(256)
fn sv8_color(@builtin(local_invocation_index) lid: u32,
             @builtin(workgroup_id) wid: vec3u,
             @builtin(num_workgroups) nwg: vec3u) {
  let segment = linear_group(wid, nwg) * WORKGROUP_SIZE + lid;
  if (segment >= counts[SLOT_KEPT]) {
    return;
  }
  if (cam.diag == 0u && tiles[segment] == 0u) {
    return;
  }
  let row = kept_rows[segment];
  let p = 6u * row;
  // Torch adds the two endpoints, then scales the sum by one half.
  let mid_x = 0.5 * (endpoints[p] + endpoints[p + 3u]);
  let mid_y = 0.5 * (endpoints[p + 1u] + endpoints[p + 4u]);
  let mid_z = 0.5 * (endpoints[p + 2u] + endpoints[p + 5u]);
  let vx = mid_x - cam.campos.x;
  let vy = mid_y - cam.campos.y;
  let vz = mid_z - cam.campos.z;
  let view_length = sqrt(vx * vx + vy * vy + vz * vz);
  let view_scale = 1.0 / view_length;
  let dx = vx * view_scale;
  let dy = vy * view_scale;
  let dz = vz * view_scale;

  var weight: array<f32, 8>;
  var max_logit = -1.0e30;
  for (var k = 0u; k < SITES; k = k + 1u) {
    let s = 3u * (row * SITES + k);
    let sx = sv_sites[s];
    let sy = sv_sites[s + 1u];
    let sz = sv_sites[s + 2u];
    let site_length = sqrt(sx * sx + sy * sy + sz * sz);
    let site_scale = 1.0 / fmaxf(site_length, REFERENCE_EPSILON);
    let ex = sx * site_scale - dx;
    let ey = sy * site_scale - dy;
    let ez = sz * site_scale - dz;
    let squared_distance = ex * ex + ey * ey + ez * ez;
    let distance = sqrt(squared_distance);
    let logit = -exp(sv_log_tau[row * SITES + k]) * distance;
    weight[k] = logit;
    max_logit = fmaxf(max_logit, logit);
  }
  var weight_sum = 0.0;
  for (var k = 0u; k < SITES; k = k + 1u) {
    let value = exp(weight[k] - max_logit);
    weight[k] = value;
    weight_sum = weight_sum + value;
  }
  let inverse_sum = 1.0 / weight_sum;
  var feature = vec3f(0.0);
  for (var k = 0u; k < SITES; k = k + 1u) {
    let w = weight[k] * inverse_sum;
    let c = 3u * (row * SITES + k);
    feature.x = feature.x + w * sv_colors[c];
    feature.y = feature.y + w * sv_colors[c + 1u];
    feature.z = feature.z + w * sv_colors[c + 2u];
  }
  rgb[3u * segment] = fmaxf(feature.x + 0.5, 0.0);
  rgb[3u * segment + 1u] = fmaxf(feature.y + 0.5, 0.0);
  rgb[3u * segment + 2u] = fmaxf(feature.z + 0.5, 0.0);
}
