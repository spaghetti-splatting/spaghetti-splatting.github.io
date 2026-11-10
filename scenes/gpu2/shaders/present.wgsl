struct _o1n {
  _on4: vec2u,
  _o9e: vec2u,
};
@group(0) @binding(0) var<storage, read> _ocv: array<f32>;
@group(0) @binding(1) var<uniform> _ois: _o1n;
@vertex
fn present_vertex(@builtin(vertex_index) _od1: u32) -> @builtin(position) vec4f {
  let x = f32((_od1 << 1u) & 2u) * 2.0 - 1.0;
  let y = f32(_od1 & 2u) * 2.0 - 1.0;
  return vec4f(x, y, 0.0, 1.0);
}
fn _ooy(x: u32, y: u32) -> vec3f {
  let _oii = _ois._on4.x * _ois._on4.y;
  let _oi9 = y * _ois._on4.x + x;
  return vec3f(_ocv[_oi9], _ocv[_oii + _oi9], _ocv[2u * _oii + _oi9]);
}
@fragment
fn present_fragment(@builtin(position) position: vec4f) -> @location(0) vec4f {
  var rgb: vec3f;
  if (all(_ois._on4 == _ois._o9e)) {
    rgb = _ooy(min(u32(position.x), _ois._on4.x - 1u), min(u32(position.y), _ois._on4.y - 1u));
  } else {
    let _ol9 = vec2f(_ois._on4) / vec2f(_ois._o9e);
    let _ohm = max(position.xy * _ol9 - 0.5, vec2f(0.0));
    let _ocq = vec2u(_ohm);
    let _oa9 = _ohm - vec2f(_ocq);
    let _ocs = min(_ocq + 1u, _ois._on4 - 1u);
    let _ocr = min(_ocq, _ois._on4 - 1u);
    let a = mix(_ooy(_ocr.x, _ocr.y), _ooy(_ocs.x, _ocr.y), _oa9.x);
    let b = mix(_ooy(_ocr.x, _ocs.y), _ooy(_ocs.x, _ocs.y), _oa9.x);
    rgb = mix(a, b, _oa9.y);
  }
  return vec4f(clamp(rgb, vec3f(0.0), vec3f(1.0)), 1.0);
}
