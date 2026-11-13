// P0: the visibility prefilter of one row, a port of
// fusedPointReferenceVisibilityKernel (cuda_rasterizer/symmetric_congruence.cu)
// with VISIBILITY_PREFILTER_SCALE and VISIBILITY_PREFILTER_PIXEL_PAD.
// fma_exact stands where the sm_89 SASS of that kernel has an FFMA, so the
// sums round as in CUDA. expf becomes exp and sqrtf becomes sqrt (plan,
// section 4.2).

@group(0) @binding(0) var<storage, read> endpoints: array<f32>;      // [N, 2, 3]
@group(0) @binding(1) var<storage, read> log_scales: array<f32>;     // [N, 3]
@group(0) @binding(2) var<storage, read_write> keep_flags: array<u32>; // [N]
@group(0) @binding(3) var<uniform> cam: Camera;

fn pm(k: u32) -> f32 {
  return cam.proj[k >> 2u][k & 3u];
}

@compute @workgroup_size(256)
fn prefilter(@builtin(local_invocation_index) lid: u32,
             @builtin(workgroup_id) wid: vec3u,
             @builtin(num_workgroups) nwg: vec3u) {
  let index = linear_group(wid, nwg) * WORKGROUP_SIZE + lid;
  if (index >= cam.rows) {
    return;
  }
  let p = 6u * index;
  let ax = endpoints[p];
  let ay = endpoints[p + 1u];
  let az = endpoints[p + 2u];
  let bx = endpoints[p + 3u];
  let by = endpoints[p + 4u];
  let bz = endpoints[p + 5u];
  let center_x = 0.5 * (ax + bx);
  let center_y = 0.5 * (ay + by);
  let center_z = 0.5 * (az + bz);

  // The bounding sphere holds both rendered vertices.
  let span_x = bx - ax;
  let span_y = by - ay;
  let span_z = bz - az;
  let half_length = 0.5 * sqrt(fma_exact(span_z, span_z,
      fma_exact(span_x, span_x, span_y * span_y)));

  let s = 3u * index;
  let scale_x = exp(log_scales[s]);
  let scale_y = exp(log_scales[s + 1u]);
  let scale_z = exp(log_scales[s + 2u]);
  var maximum_scale = scale_x;
  maximum_scale = select(scale_y, maximum_scale, maximum_scale >= scale_y);
  maximum_scale = select(scale_z, maximum_scale, maximum_scale >= scale_z);
  let radius = fma_exact(maximum_scale, cam.support_scale, half_length);

  var inside_side_planes = true;
  var finite = is_finite(center_x) && is_finite(center_y) && is_finite(center_z)
      && is_finite(half_length) && is_finite(scale_x) && is_finite(scale_y)
      && is_finite(scale_z) && is_finite(radius);
  for (var side = 0u; side < 4u; side = side + 1u) {
    let column = select(1u, 0u, side < 2u);
    let sign = select(1.0, -1.0, (side & 1u) != 0u);
    let pad = select(cam.pad_y, cam.pad_x, side < 2u);
    let nx = fma_exact(pm(3u), pad, sign * pm(column));
    let ny = fma_exact(pm(7u), pad, sign * pm(4u + column));
    let nz = fma_exact(pm(11u), pad, sign * pm(8u + column));
    let nw = fma_exact(pm(15u), pad, sign * pm(12u + column));
    let signed_distance = fma_exact(center_z, nz,
        fma_exact(center_x, nx, center_y * ny)) + nw;
    let support = radius * sqrt(fma_exact(nz, nz, fma_exact(nx, nx, ny * ny)));
    let roundoff_pad = 1.0e-6 * fmaxf(1.0, abs(signed_distance) + support);
    finite = finite && is_finite(signed_distance) && is_finite(support);
    inside_side_planes = inside_side_planes
        && signed_distance + support >= -roundoff_pad;
  }

  let w_x = pm(3u);
  let w_y = pm(7u);
  let w_z = pm(11u);
  let clip_w = fma_exact(center_z, w_z, fma_exact(center_x, w_x, center_y * w_y)) + pm(15u);
  let clip_w_support = radius * sqrt(fma_exact(w_z, w_z, fma_exact(w_x, w_x, w_y * w_y)));
  finite = finite && is_finite(clip_w) && is_finite(clip_w_support);
  // 1e-3 + 1e-6 max(1, |w| + support) is one FFMA in the SASS.
  let threshold = fma_exact(fmaxf(1.0, abs(clip_w) + clip_w_support), 1.0e-6, 1.0e-3);
  let certain_positive_w = clip_w - clip_w_support > threshold;
  keep_flags[index] = select(0u, 1u, !finite || !certain_positive_w || inside_side_planes);
}
