struct _o10 {
  _ord: u32,
  _ocf: u32,
  _ohz: u32,
  _oi0: u32,
};
@group(0) @binding(0) var<storage, read> _ocw: array<f32>;
@group(0) @binding(1) var<uniform> _o91: _o10;
@vertex
fn display_vertex(@builtin(vertex_index) _od2: u32) -> @builtin(position) vec4f {
  let x = f32((_od2 << 1u) & 2u) * 2.0 - 1.0;
  let y = f32(_od2 & 2u) * 2.0 - 1.0;
  return vec4f(x, y, 0.0, 1.0);
}
@fragment
fn display_fragment(@builtin(position) position: vec4f) -> @location(0) vec4f {
  let x = min(u32(position.x), _o91._ord - 1u);
  let y = min(u32(position.y), _o91._ocf - 1u);
  let _oij = _o91._ord * _o91._ocf;
  let _oia = y * _o91._ord + x;
  let rgb = vec3f(_ocw[_oia], _ocw[_oij + _oia], _ocw[2u * _oij + _oia]);
  return vec4f(clamp(rgb, vec3f(0.0), vec3f(1.0)), 1.0);
}
