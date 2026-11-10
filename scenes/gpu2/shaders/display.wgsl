struct _o12 {
  _os7: u32,
  _ocy: u32,
  _oio: u32,
  _oip: u32,
};
@group(0) @binding(0) var<storage, read> _odh: array<f32>;
@group(0) @binding(1) var<uniform> _o9i: _o12;
@vertex
fn display_vertex(@builtin(vertex_index) _odn: u32) -> @builtin(position) vec4f {
  let x = f32((_odn << 1u) & 2u) * 2.0 - 1.0;
  let y = f32(_odn & 2u) * 2.0 - 1.0;
  return vec4f(x, y, 0.0, 1.0);
}
@fragment
fn display_fragment(@builtin(position) position: vec4f) -> @location(0) vec4f {
  let x = min(u32(position.x), _o9i._os7 - 1u);
  let y = min(u32(position.y), _o9i._ocy - 1u);
  let _oj8 = _o9i._os7 * _o9i._ocy;
  let _oiz = y * _o9i._os7 + x;
  let rgb = vec3f(_odh[_oiz], _odh[_oj8 + _oiz], _odh[2u * _oj8 + _oiz]);
  return vec4f(clamp(rgb, vec3f(0.0), vec3f(1.0)), 1.0);
}
