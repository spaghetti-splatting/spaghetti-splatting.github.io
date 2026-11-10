@group(0) @binding(0) var<storage, read> _oae: array<f32>;
@group(0) @binding(1) var<storage, read> _oqz: array<f32>;
@group(0) @binding(2) var<storage, read> _om3: array<f32>;
@group(0) @binding(3) var<storage, read> _oaw: array<u32>;
@group(0) @binding(4) var<storage, read> _oev: array<u32>;
@group(0) @binding(5) var<storage, read> _o83: array<u32>;
@group(0) @binding(6) var<storage, read_write> _oax: array<f32>;
@group(0) @binding(7) var<uniform> _o5v: _oo;
const _o0: f32 = 1e-3;
const _o1b: f32 = 1e-12;
fn _oj9(_oei: u32) -> f32 {
  return _o5v._oju[_oei >> 2u][_oei & 3u];
}
@compute @workgroup_size(256)
fn face_factor_pass(@builtin(local_invocation_index) _ofl: u32,
                    @builtin(workgroup_id) _os6: vec3u,
                    @builtin(num_workgroups) _ohc: vec3u) {
  let _odn = _ofq(_os6, _ohc) * _o2j + _ofl;
  var _olr = _odn;
  if (_o5v._o9b != 0u) {
    if (_odn >= _o5v._olt) {
      return;
    }
  } else {
    if (_odn >= _o83[_o1w]) {
      return;
    }
    _olr = _oev[_odn];
  }
  if (_oaw[_olr] == 0u) {
    return;
  }
  let _oic = 6u * _olr;
  let _o8e = _oae[_oic];
  let _o8f = _oae[_oic + 1u];
  let _o8g = _oae[_oic + 2u];
  let _od9 = _o8e * _oj9(0u) + _o8f * _oj9(4u) + _o8g * _oj9(8u) + _oj9(12u);
  let _oda = _o8e * _oj9(1u) + _o8f * _oj9(5u) + _o8g * _oj9(9u) + _oj9(13u);
  let _od8 = _o8e * _oj9(3u) + _o8f * _oj9(7u) + _o8g * _oj9(11u) + _oj9(15u);
  let _oet = _od8 > _o0 && _oe5(_od8) && _od9 + _od8 >= 0.0
      && _od8 - _od9 >= 0.0 && _oda + _od8 >= 0.0 && _od8 - _oda >= 0.0;
  if (!_oet) {
    _oax[_olr] = 1.0;
    return;
  }
  let _oqm = 8u * _olr;
  let _oke = _oqz[_oqm];
  let _okf = _oqz[_oqm + 1u];
  let _okg = _oqz[_oqm + 2u];
  let _okh = _oqz[_oqm + 3u];
  let _olz = vec3f(_oqz[_oqm + 4u], _oqz[_oqm + 5u], _oqz[_oqm + 6u]);
  let r = mat3x3f(
      vec3f(1.0 - 2.0 * (_okg * _okg + _okh * _okh), 2.0 * (_okf * _okg + _oke * _okh), 2.0 * (_okf * _okh - _oke * _okg)),
      vec3f(2.0 * (_okf * _okg - _oke * _okh), 1.0 - 2.0 * (_okf * _okf + _okh * _okh), 2.0 * (_okg * _okh + _oke * _okf)),
      vec3f(2.0 * (_okf * _okh + _oke * _okg), 2.0 * (_okg * _okh - _oke * _okf), 1.0 - 2.0 * (_okf * _okf + _okg * _okg)));
  let _oe3 = 1.0 / (_od8 * _od8);
  let _oed = _o5v._ocw * (_od8 * vec3f(_oj9(0u), _oj9(4u), _oj9(8u))
      - _od9 * vec3f(_oj9(3u), _oj9(7u), _oj9(11u))) * _oe3;
  let _oeg = _o5v._oct * (_od8 * vec3f(_oj9(1u), _oj9(5u), _oj9(9u))
      - _oda * vec3f(_oj9(3u), _oj9(7u), _oj9(11u))) * _oe3;
  let _og3 = vec3f(dot(_oed, r[0]), dot(_oed, r[1]), dot(_oed, r[2])) * _olz;
  let _og4 = vec3f(dot(_oeg, r[0]), dot(_oeg, r[1]), dot(_oeg, r[2])) * _olz;
  var _o58 = dot(_og3, _og3) + _o5v._oay;
  var _o5b = dot(_og3, _og4);
  var _o5i = dot(_og4, _og4) + _o5v._oay;
  let _ose = _om3[_olr] * _om3[_olr];
  _o58 = _o58 + _ose * dot(_oed, _oed);
  _o5b = _o5b + _ose * dot(_oed, _oeg);
  _o5i = _o5i + _ose * dot(_oeg, _oeg);
  let _o3h = 0.5 * _olz.x * (_olz.y + _olz.z);
  let _oh6 = length(cross(_oed, _oeg));
  let _oei = _o3h * _oh6 / sqrt(_o58 * _o5i - _o5b * _o5b);
  var _o6e = _oei;
  if (!_oe6(_oei)) {
    _o6e = max(_oei, _o1b);
  }
  _oax[_olr] = 1.0 / _o6e;
}
