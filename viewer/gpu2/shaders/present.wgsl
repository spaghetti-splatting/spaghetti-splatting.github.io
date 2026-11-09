struct _o1t {
  _onu: vec2u,
  _o9r: vec2u,
};
@group(0) @binding(0) var<storage, read> _odd: array<f32>;
@group(0) @binding(1) var<uniform> _ojf: _o1t;
@vertex
fn present_vertex(@builtin(vertex_index) _odi: u32) -> @builtin(position) vec4f {
  let x = f32((_odi << 1u) & 2u) * 2.0 - 1.0;
  let y = f32(_odi & 2u) * 2.0 - 1.0;
  return vec4f(x, y, 0.0, 1.0);
}
fn _opm(x: u32, y: u32) -> vec3f {
  let _oj1 = _ojf._onu.x * _ojf._onu.y;
  let _oit = y * _ojf._onu.x + x;
  return vec3f(_odd[_oit], _odd[_oj1 + _oit], _odd[2u * _oj1 + _oit]);
}
@fragment
fn present_fragment(@builtin(position) position: vec4f) -> @location(0) vec4f {
  var rgb: vec3f;
  if (all(_ojf._onu == _ojf._o9r)) {
    rgb = _opm(min(u32(position.x), _ojf._onu.x - 1u), min(u32(position.y), _ojf._onu.y - 1u));
  } else {
    let _olx = vec2f(_ojf._onu) / vec2f(_ojf._o9r);
    let _oi3 = max(position.xy * _olx - 0.5, vec2f(0.0));
    let _od7 = vec2u(_oi3);
    let _oao = _oi3 - vec2f(_od7);
    let _od9 = min(_od7 + 1u, _ojf._onu - 1u);
    let _od8 = min(_od7, _ojf._onu - 1u);
    let a = mix(_opm(_od8.x, _od8.y), _opm(_od9.x, _od8.y), _oao.x);
    let b = mix(_opm(_od8.x, _od9.y), _opm(_od9.x, _od9.y), _oao.x);
    rgb = mix(a, b, _oao.y);
  }
  return vec4f(clamp(rgb, vec3f(0.0), vec3f(1.0)), 1.0);
}
