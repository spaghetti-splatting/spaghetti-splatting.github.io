struct _o1w {
  _op3: vec2u,
  _oaa: vec2u,
};
@group(0) @binding(0) var<storage, read> _oec: array<f32>;
@group(0) @binding(1) var<uniform> _oki: _o1w;
@vertex
fn present_vertex(@builtin(vertex_index) _oei: u32) -> @builtin(position) vec4f {
  let x = f32((_oei << 1u) & 2u) * 2.0 - 1.0;
  let y = f32(_oei & 2u) * 2.0 - 1.0;
  return vec4f(x, y, 0.0, 1.0);
}
fn _or1(x: u32, y: u32) -> vec3f {
  let _ok8 = _oki._op3.x * _oki._op3.y;
  let _ojz = y * _oki._op3.x + x;
  return vec3f(_oec[_ojz], _oec[_ok8 + _ojz], _oec[2u * _ok8 + _ojz]);
}
@fragment
fn present_fragment(@builtin(position) position: vec4f) -> @location(0) vec4f {
  var rgb: vec3f;
  if (all(_oki._op3 == _oki._oaa)) {
    rgb = _or1(min(u32(position.x), _oki._op3.x - 1u), min(u32(position.y), _oki._op3.y - 1u));
  } else {
    let _on4 = vec2f(_oki._op3) / vec2f(_oki._oaa);
    let _ojb = max(position.xy * _on4 - 0.5, vec2f(0.0));
    let _oe7 = vec2u(_ojb);
    let _ob7 = _ojb - vec2f(_oe7);
    let _oe9 = min(_oe7 + 1u, _oki._op3 - 1u);
    let _oe8 = min(_oe7, _oki._op3 - 1u);
    let a = mix(_or1(_oe8.x, _oe8.y), _or1(_oe9.x, _oe8.y), _ob7.x);
    let b = mix(_or1(_oe8.x, _oe9.y), _or1(_oe9.x, _oe9.y), _ob7.x);
    rgb = mix(a, b, _ob7.y);
  }
  return vec4f(clamp(rgb, vec3f(0.0), vec3f(1.0)), 1.0);
}
