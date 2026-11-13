// P10: the display. A full-screen triangle copies the float32 RGB buffer
// [3, H, W] of P9 to the canvas (bgra8unorm). The pass clamps each value to
// [0, 1] and makes no sRGB conversion, so the canvas holds the values of the
// CUDA PNG.

struct DisplayParams {
  width: u32,
  height: u32,
  pad0: u32,
  pad1: u32,
};

@group(0) @binding(0) var<storage, read> image: array<f32>;
@group(0) @binding(1) var<uniform> display: DisplayParams;

@vertex
fn display_vertex(@builtin(vertex_index) index: u32) -> @builtin(position) vec4f {
  let x = f32((index << 1u) & 2u) * 2.0 - 1.0;
  let y = f32(index & 2u) * 2.0 - 1.0;
  return vec4f(x, y, 0.0, 1.0);
}

@fragment
fn display_fragment(@builtin(position) position: vec4f) -> @location(0) vec4f {
  let x = min(u32(position.x), display.width - 1u);
  let y = min(u32(position.y), display.height - 1u);
  let plane = display.width * display.height;
  let pix = y * display.width + x;
  let rgb = vec3f(image[pix], image[plane + pix], image[2u * plane + pix]);
  return vec4f(clamp(rgb, vec3f(0.0), vec3f(1.0)), 1.0);
}
