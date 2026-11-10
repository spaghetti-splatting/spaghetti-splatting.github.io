struct _o1p {
  _onx: vec2u,
  _o9w: vec2u,
};
@group(0) @binding(0) var<storage, read> _odh: array<f32>;
@group(0) @binding(1) var<uniform> _oji: _o1p;
@vertex
fn present_vertex(@builtin(vertex_index) _odn: u32) -> @builtin(position) vec4f {
  let x = f32((_odn << 1u) & 2u) * 2.0 - 1.0;
  let y = f32(_odn & 2u) * 2.0 - 1.0;
  return vec4f(x, y, 0.0, 1.0);
}
fn _ops(x: u32, y: u32) -> vec3f {
  let _oj8 = _oji._onx.x * _oji._onx.y;
  let _oiz = y * _oji._onx.x + x;
  return vec3f(_odh[_oiz], _odh[_oj8 + _oiz], _odh[2u * _oj8 + _oiz]);
}
@fragment
fn present_fragment(@builtin(position) position: vec4f) -> @location(0) vec4f {
  var rgb: vec3f;
  if (all(_oji._onx == _oji._o9w)) {
    rgb = _ops(min(u32(position.x), _oji._onx.x - 1u), min(u32(position.y), _oji._onx.y - 1u));
  } else {
    let _olz = vec2f(_oji._onx) / vec2f(_oji._o9w);
    let _oic = max(position.xy * _olz - 0.5, vec2f(0.0));
    let _odc = vec2u(_oic);
    let _oar = _oic - vec2f(_odc);
    let _ode = min(_odc + 1u, _oji._onx - 1u);
    let _odd = min(_odc, _oji._onx - 1u);
    let a = mix(_ops(_odd.x, _odd.y), _ops(_ode.x, _odd.y), _oar.x);
    let b = mix(_ops(_odd.x, _ode.y), _ops(_ode.x, _ode.y), _oar.x);
    rgb = mix(a, b, _oar.y);
  }
  return vec4f(clamp(rgb, vec3f(0.0), vec3f(1.0)), 1.0);
}
