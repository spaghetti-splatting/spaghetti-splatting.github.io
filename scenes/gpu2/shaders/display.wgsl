struct _o12 {
  _oth: u32,
  _odt: u32,
  _ojn: u32,
  _ojo: u32,
};
@group(0) @binding(0) var<storage, read> _oec: array<f32>;
@group(0) @binding(1) var<uniform> _o9w: _o12;
@vertex
fn display_vertex(@builtin(vertex_index) _oei: u32) -> @builtin(position) vec4f {
  let x = f32((_oei << 1u) & 2u) * 2.0 - 1.0;
  let y = f32(_oei & 2u) * 2.0 - 1.0;
  return vec4f(x, y, 0.0, 1.0);
}
@fragment
fn display_fragment(@builtin(position) position: vec4f) -> @location(0) vec4f {
  let x = min(u32(position.x), _o9w._oth - 1u);
  let y = min(u32(position.y), _o9w._odt - 1u);
  let _ok8 = _o9w._oth * _o9w._odt;
  let _ojz = y * _o9w._oth + x;
  let rgb = vec3f(_oec[_ojz], _oec[_ok8 + _ojz], _oec[2u * _ok8 + _ojz]);
  return vec4f(clamp(rgb, vec3f(0.0), vec3f(1.0)), 1.0);
}
