struct _o11 {
  _oss: u32,
  _ojn: u32,
  _ojo: u32,
  _ojp: u32,
};
@group(0) @binding(0) var<uniform> _oa7: _o11;
@group(0) @binding(1) var<storage, read> _omy: array<u32>;
@group(0) @binding(2) var<storage, read> _otv: array<vec4f>;
@group(0) @binding(3) var<storage, read> _omi: array<vec4f>;
@group(0) @binding(4) var<storage, read> _osa: array<f32>;
@group(0) @binding(5) var<storage, read_write> _os9: array<f32>;
@group(0) @binding(6) var<storage, read> _ooi: array<f32>;
@group(0) @binding(7) var<storage, read_write> _ooh: array<f32>;
@group(0) @binding(8) var<storage, read_write> _oau: array<f32>;
fn _olf(a: vec4f, b: vec4f) -> vec4f {
  let _o3x = a.yzw;
  let _o5f = b.yzw;
  let _osh = a.x * _o5f + b.x * _o3x + cross(_o3x, _o5f);
  return vec4f(a.x * b.x - dot(_o3x, _o5f), _osh);
}
fn _olg(_ol1: vec4f, _on4: vec3f) -> vec3f {
  let _oq8 = 2.0 * cross(_ol1.yzw, _on4);
  return _on4 + _ol1.x * _oq8 + cross(_ol1.yzw, _oq8);
}
@compute @workgroup_size(256)
fn deform(@builtin(global_invocation_id) _ocy: vec3u, @builtin(num_workgroups) _oib: vec3u) {
  let _oe7 = _ocy.x + _ocy.y * _oib.x * 256u;
  if (_oe7 >= _oa7._oss) {
    return;
  }
  let _omw = _omy[_oe7];
  if (_omw == 0xffffffffu) {
    return;
  }
  let a = _otv[_oe7 - 1u].xyz;
  let b = _otv[_oe7].xyz;
  let ra = _omi[_oe7 - 1u].xyz;
  let rb = _omi[_oe7].xyz;
  let _o5j = b - a;
  let _o5k = rb - ra;
  let _oaj = 6u * _omw;
  _oau[_oaj] = a.x;
  _oau[_oaj + 1u] = a.y;
  _oau[_oaj + 2u] = a.z;
  _oau[_oaj + 3u] = b.x;
  _oau[_oaj + 4u] = b.y;
  _oau[_oaj + 5u] = b.z;
  let _orw = 8u * _omw;
  let _op4 = 24u * _omw;
  if (all(_o5j == _o5k)) {
    for (var _ofd = 0u; _ofd < 4u; _ofd = _ofd + 1u) {
      _os9[_orw + _ofd] = _osa[_orw + _ofd];
    }
    for (var _ofd = 0u; _ofd < 24u; _ofd = _ofd + 1u) {
      _ooh[_op4 + _ofd] = _ooi[_op4 + _ofd];
    }
    return;
  }
  let _ohw = normalize(_o5k);
  let _ohx = normalize(_o5j);
  let _o8v = dot(_ohw, _ohx);
  var _ol1: vec4f;
  if (_o8v < -0.999999) {
    var _o42 = cross(_ohw, vec3f(1.0, 0.0, 0.0));
    if (dot(_o42, _o42) < 1.0e-6) {
      _o42 = cross(_ohw, vec3f(0.0, 1.0, 0.0));
    }
    _ol1 = vec4f(0.0, normalize(_o42));
  } else {
    _ol1 = normalize(vec4f(1.0 + _o8v, cross(_ohw, _ohx)));
  }
  let _ol7 = vec4f(_osa[_orw], _osa[_orw + 1u], _osa[_orw + 2u], _osa[_orw + 3u]);
  let _ol6 = normalize(_olf(_ol1, _ol7));
  _os9[_orw] = _ol6.x;
  _os9[_orw + 1u] = _ol6.y;
  _os9[_orw + 2u] = _ol6.z;
  _os9[_orw + 3u] = _ol6.w;
  for (var _ofd = 0u; _ofd < 8u; _ofd = _ofd + 1u) {
    let _oif = _op4 + 3u * _ofd;
    let _on4 = _olg(_ol1, vec3f(_ooi[_oif], _ooi[_oif + 1u], _ooi[_oif + 2u]));
    _ooh[_oif] = _on4.x;
    _ooh[_oif + 1u] = _on4.y;
    _ooh[_oif + 2u] = _on4.z;
  }
}
