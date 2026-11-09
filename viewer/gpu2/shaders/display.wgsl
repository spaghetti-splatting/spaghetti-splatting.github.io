struct _oy {
  _os6: u32,
  _ocv: u32,
  _oig: u32,
  _oih: u32,
};
@group(0) @binding(0) var<storage, read> _odd: array<f32>;
@group(0) @binding(1) var<uniform> _o9d: _oy;
@vertex
fn display_vertex(@builtin(vertex_index) _odi: u32) -> @builtin(position) vec4f {
  let x = f32((_odi << 1u) & 2u) * 2.0 - 1.0;
  let y = f32(_odi & 2u) * 2.0 - 1.0;
  return vec4f(x, y, 0.0, 1.0);
}
@fragment
fn display_fragment(@builtin(position) position: vec4f) -> @location(0) vec4f {
  let x = min(u32(position.x), _o9d._os6 - 1u);
  let y = min(u32(position.y), _o9d._ocv - 1u);
  let _oj1 = _o9d._os6 * _o9d._ocv;
  let _oit = y * _o9d._os6 + x;
  let rgb = vec3f(_odd[_oit], _odd[_oj1 + _oit], _odd[2u * _oj1 + _oit]);
  return vec4f(clamp(rgb, vec3f(0.0), vec3f(1.0)), 1.0);
}
