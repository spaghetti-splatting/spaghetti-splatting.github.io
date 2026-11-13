// Present: the float32 RGB image [3, H, W] of the render pass, scaled to the canvas with
// bilinear filtering. Like display.wgsl it clamps to [0, 1] and makes no sRGB conversion,
// so at scale 1 the canvas holds the values of the CUDA PNG.

struct PresentParams {
  src: vec2u,     // render size
  dst: vec2u,     // canvas size
};

@group(0) @binding(0) var<storage, read> image: array<f32>;
@group(0) @binding(1) var<uniform> pp: PresentParams;

@vertex
fn present_vertex(@builtin(vertex_index) index: u32) -> @builtin(position) vec4f {
  let x = f32((index << 1u) & 2u) * 2.0 - 1.0;
  let y = f32(index & 2u) * 2.0 - 1.0;
  return vec4f(x, y, 0.0, 1.0);
}

fn texel(x: u32, y: u32) -> vec3f {
  let plane = pp.src.x * pp.src.y;
  let pix = y * pp.src.x + x;
  return vec3f(image[pix], image[plane + pix], image[2u * plane + pix]);
}

@fragment
fn present_fragment(@builtin(position) position: vec4f) -> @location(0) vec4f {
  var rgb: vec3f;
  if (all(pp.src == pp.dst)) {
    rgb = texel(min(u32(position.x), pp.src.x - 1u), min(u32(position.y), pp.src.y - 1u));
  } else {
    let s = vec2f(pp.src) / vec2f(pp.dst);
    let p = max(position.xy * s - 0.5, vec2f(0.0));
    let i = vec2u(p);
    let f = p - vec2f(i);
    let i1 = min(i + 1u, pp.src - 1u);
    let i0 = min(i, pp.src - 1u);
    let a = mix(texel(i0.x, i0.y), texel(i1.x, i0.y), f.x);
    let b = mix(texel(i0.x, i1.y), texel(i1.x, i1.y), f.x);
    rgb = mix(a, b, f.y);
  }
  return vec4f(clamp(rgb, vec3f(0.0), vec3f(1.0)), 1.0);
}
