struct _o1e {
  _o7l: u32,
  _oig: u32,
  _oih: u32,
  _oii: u32,
};
@group(0) @binding(0) var<uniform> _od2: _o1e;
@group(0) @binding(1) var<storage, read> _ocu: array<u32>;
@group(0) @binding(2) var<storage, read> _oaa: array<f32>;
@group(0) @binding(3) var<storage, read> _oqu: array<f32>;
@group(0) @binding(4) var<storage, read_write> _oqt: array<f32>;
@group(0) @binding(5) var<storage, read> _on9: array<f32>;
@group(0) @binding(6) var<storage, read_write> _on8: array<f32>;
@group(0) @binding(7) var<storage, read_write> _oa9: array<f32>;
fn _ok5(a: vec4f, b: vec4f) -> vec4f {
  let _o3q = a.yzw;
  let _o54 = b.yzw;
  let _or2 = a.x * _o54 + b.x * _o3q + cross(_o3q, _o54);
  return vec4f(a.x * b.x - dot(_o3q, _o54), _or2);
}
@compute @workgroup_size(256)
fn head_rigid(@builtin(global_invocation_id) _oc1: vec3u, @builtin(num_workgroups) _oh4: vec3u) {
  let _oe3 = _oc1.x + _oc1.y * _oh4.x * 256u;
  if (_oe3 >= _od2._o7l) {
    return;
  }
  let _omu = _ocu[_oe3];
  let _o9z = 6u * _omu;
  let _oac = 6u * _oe3;
  let _oqg = 8u * _omu;
  let _onv = 24u * _omu;
  if (_oj7._oda != 0u) {
    for (var _oed = 0u; _oed < 6u; _oed = _oed + 1u) {
      _oa9[_o9z + _oed] = _oaa[_oac + _oed];
    }
    for (var _oed = 0u; _oed < 4u; _oed = _oed + 1u) {
      _oqt[_oqg + _oed] = _oqu[_oqg + _oed];
    }
    for (var _oed = 0u; _oed < 24u; _oed = _oed + 1u) {
      _on8[_onv + _oed] = _on9[_onv + _oed];
    }
    return;
  }
  let a = _oj9(vec3f(_oaa[_oac], _oaa[_oac + 1u], _oaa[_oac + 2u]));
  let b = _oj9(vec3f(_oaa[_oac + 3u], _oaa[_oac + 4u], _oaa[_oac + 5u]));
  _oa9[_o9z] = a.x;
  _oa9[_o9z + 1u] = a.y;
  _oa9[_o9z + 2u] = a.z;
  _oa9[_o9z + 3u] = b.x;
  _oa9[_o9z + 4u] = b.y;
  _oa9[_o9z + 5u] = b.z;
  let _ok2 = vec4f(_oqu[_oqg], _oqu[_oqg + 1u], _oqu[_oqg + 2u], _oqu[_oqg + 3u]);
  let _ok1 = normalize(_ok5(_oj7._ojy, _ok2));
  _oqt[_oqg] = _ok1.x;
  _oqt[_oqg + 1u] = _ok1.y;
  _oqt[_oqg + 2u] = _ok1.z;
  _oqt[_oqg + 3u] = _ok1.w;
  for (var _oed = 0u; _oed < 8u; _oed = _oed + 1u) {
    let _oh8 = _onv + 3u * _oed;
    let _olx = _oj8(vec3f(_on9[_oh8], _on9[_oh8 + 1u], _on9[_oh8 + 2u]));
    _on8[_oh8] = _olx.x;
    _on8[_oh8 + 1u] = _olx.y;
    _on8[_oh8 + 2u] = _olx.z;
  }
}
