// P2b (Beta kernel only): the per-primitive inputs of the Beta preprocess
// and render, gathered once for each kept row, so that each of those passes
// stays at 8 storage buffers or less. For the kept row idx with the source
// row r = kept_rows[idx]:
//   x: the amplitude of the preprocess, amplitude[r] * face_factor[r] (the
//      multiply of preprocess.wgsl; P2 wrote the face factor);
//   y: the shape parameter b of the Beta kernel, kernel_shape[r]
//      (PreprocessPrimitive: shape.kernel_shape[source_idx]);
//   z: the texture slot of the row, texture_slot[r], or -1 without a texture
//      (renderCUDA: texture.slot[rows[j]]);
//   w: 0.
// The words hold the bits of the values (f32 or i32).

struct GatherParams {
  textured: u32,
  pad0: u32,
  pad1: u32,
  pad2: u32,
};

@group(0) @binding(0) var<storage, read> kept_rows: array<u32>;     // [K]
@group(0) @binding(1) var<storage, read> amplitude: array<f32>;     // [N]
@group(0) @binding(2) var<storage, read> face_factor: array<f32>;   // [N]
@group(0) @binding(3) var<storage, read> kernel_shape: array<f32>;  // [N]
@group(0) @binding(4) var<storage, read> texture_slot: array<i32>;  // [N] or a dummy
@group(0) @binding(5) var<storage, read> counts: array<u32>;
@group(0) @binding(6) var<storage, read_write> prim_aux: array<vec4u>; // [K]
@group(0) @binding(7) var<uniform> gather: GatherParams;

@compute @workgroup_size(256)
fn beta_gather(@builtin(local_invocation_index) lid: u32,
               @builtin(workgroup_id) wid: vec3u,
               @builtin(num_workgroups) nwg: vec3u) {
  let idx = linear_group(wid, nwg) * WORKGROUP_SIZE + lid;
  if (idx >= counts[SLOT_KEPT]) {
    return;
  }
  let row = kept_rows[idx];
  let amp = amplitude[row] * face_factor[row];
  var slot = -1;
  if (gather.textured != 0u) {
    slot = texture_slot[row];
  }
  prim_aux[idx] = vec4u(bitcast<u32>(amp), bitcast<u32>(kernel_shape[row]),
                        bitcast<u32>(slot), 0u);
}
