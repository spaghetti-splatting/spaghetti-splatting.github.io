struct _o10 {
  _orc: u32,
  _oce: u32,
  _ohy: u32,
  _ohz: u32,
};
@group(0) @binding(0) var<storage, read> _ocv: array<f32>;
@group(0) @binding(1) var<uniform> _o90: _o10;
@vertex
fn display_vertex(@builtin(vertex_index) _od1: u32) -> @builtin(position) vec4f {
  let x = f32((_od1 << 1u) & 2u) * 2.0 - 1.0;
  let y = f32(_od1 & 2u) * 2.0 - 1.0;
  return vec4f(x, y, 0.0, 1.0);
}
@fragment
fn display_fragment(@builtin(position) position: vec4f) -> @location(0) vec4f {
  let x = min(u32(position.x), _o90._orc - 1u);
  let y = min(u32(position.y), _o90._oce - 1u);
  let _oii = _o90._orc * _o90._oce;
  let _oi9 = y * _o90._orc + x;
  let rgb = vec3f(_ocv[_oi9], _ocv[_oii + _oi9], _ocv[2u * _oii + _oi9]);
  return vec4f(clamp(rgb, vec3f(0.0), vec3f(1.0)), 1.0);
}
