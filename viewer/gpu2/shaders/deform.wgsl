struct _ox {
  _ore: u32,
  _oig: u32,
  _oih: u32,
  _oii: u32,
};
@group(0) @binding(0) var<uniform> _o9o: _ox;
@group(0) @binding(1) var<storage, read> _ofl: array<vec2u>;
@group(0) @binding(2) var<storage, read> _osn: array<vec4f>;
@group(0) @binding(3) var<storage, read> _olb: array<vec4f>;
@group(0) @binding(4) var<storage, read> _oqu: array<f32>;
@group(0) @binding(5) var<storage, read_write> _oqt: array<f32>;
@group(0) @binding(6) var<storage, read> _on9: array<f32>;
@group(0) @binding(7) var<storage, read_write> _on8: array<f32>;
@group(0) @binding(8) var<storage, read_write> _oa9: array<f32>;
fn _ok5(a: vec4f, b: vec4f) -> vec4f {
  let _o3q = a.yzw;
  let _o54 = b.yzw;
  let _or2 = a.x * _o54 + b.x * _o3q + cross(_o3q, _o54);
  return vec4f(a.x * b.x - dot(_o3q, _o54), _or2);
}
fn _ok6(_ojy: vec4f, _olx: vec3f) -> vec3f {
  let _oou = 2.0 * cross(_ojy.yzw, _olx);
  return _olx + _ojy.x * _oou + cross(_ojy.yzw, _oou);
}
@compute @workgroup_size(256)
fn deform(@builtin(global_invocation_id) _oc1: vec3u, @builtin(num_workgroups) _oh4: vec3u) {
  let _od7 = _oc1.x + _oc1.y * _oh4.x * 256u;
  if (_od7 >= _o9o._ore) {
    return;
  }
  let _ofk = _ofl[_od7];
  let _olo = _ofk.x;
  let _ojg = _ofk.y;
  if (_olo == 0xffffffffu || _ojg == 0xffffffffu) {
    return;
  }
  let a = _osn[_ojg].xyz;
  let b = _osn[_od7].xyz;
  let ra = _olb[_ojg].xyz;
  let rb = _olb[_od7].xyz;
  let _o58 = b - a;
  let _o59 = rb - ra;
  let _o9z = 6u * _olo;
  _oa9[_o9z] = a.x;
  _oa9[_o9z + 1u] = a.y;
  _oa9[_o9z + 2u] = a.z;
  _oa9[_o9z + 3u] = b.x;
  _oa9[_o9z + 4u] = b.y;
  _oa9[_o9z + 5u] = b.z;
  let _oqg = 8u * _olo;
  let _onv = 24u * _olo;
  if (_oj7._oda != 0u && all(_o58 == _o59)) {
    for (var _oed = 0u; _oed < 4u; _oed = _oed + 1u) {
      _oqt[_oqg + _oed] = _oqu[_oqg + _oed];
    }
    for (var _oed = 0u; _oed < 24u; _oed = _oed + 1u) {
      _on8[_onv + _oed] = _on9[_onv + _oed];
    }
    return;
  }
  let _ogr = normalize(_oj8(_o59));
  let _ogs = normalize(_o58);
  let _o89 = dot(_ogr, _ogs);
  var _ojy: vec4f;
  if (_o89 < -0.999999) {
    var _o3w = cross(_ogr, vec3f(1.0, 0.0, 0.0));
    if (dot(_o3w, _o3w) < 1.0e-6) {
      _o3w = cross(_ogr, vec3f(0.0, 1.0, 0.0));
    }
    _ojy = vec4f(0.0, normalize(_o3w));
  } else {
    _ojy = normalize(vec4f(1.0 + _o89, cross(_ogr, _ogs)));
  }
  if (_oj7._oda == 0u) {
    _ojy = _ok5(_ojy, _oj7._ojy);
  }
  let _ok2 = vec4f(_oqu[_oqg], _oqu[_oqg + 1u], _oqu[_oqg + 2u], _oqu[_oqg + 3u]);
  let _ok1 = normalize(_ok5(_ojy, _ok2));
  _oqt[_oqg] = _ok1.x;
  _oqt[_oqg + 1u] = _ok1.y;
  _oqt[_oqg + 2u] = _ok1.z;
  _oqt[_oqg + 3u] = _ok1.w;
  for (var _oed = 0u; _oed < 8u; _oed = _oed + 1u) {
    let _oh8 = _onv + 3u * _oed;
    let _olx = _ok6(_ojy, vec3f(_on9[_oh8], _on9[_oh8 + 1u], _on9[_oh8 + 2u]));
    _on8[_oh8] = _olx.x;
    _on8[_oh8 + 1u] = _olx.y;
    _on8[_oh8 + 2u] = _olx.z;
  }
}
