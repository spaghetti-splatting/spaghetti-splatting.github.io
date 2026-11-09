@group(0) @binding(0) var<storage, read> _oa9: array<f32>;
@group(0) @binding(1) var<storage, read> _oqt: array<f32>;
@group(0) @binding(2) var<storage, read> _om1: array<f32>;
@group(0) @binding(3) var<storage, read> _oat: array<u32>;
@group(0) @binding(4) var<storage, read> _oeo: array<u32>;
@group(0) @binding(5) var<storage, read> _o7r: array<u32>;
@group(0) @binding(6) var<storage, read_write> _oau: array<f32>;
@group(0) @binding(7) var<uniform> _o5x: _oo;
const _o0: f32 = 1e-3;
const _o17: f32 = 1e-12;
fn _oj2(_oed: u32) -> f32 {
  return _o5x._ojs[_oed >> 2u][_oed & 3u];
}
@compute @workgroup_size(256)
fn face_factor_pass(@builtin(local_invocation_index) _ofg: u32,
                    @builtin(workgroup_id) _os5: vec3u,
                    @builtin(num_workgroups) _oh4: vec3u) {
  let _odi = _ofj(_os5, _oh4) * _o2o + _ofg;
  var _olo = _odi;
  if (_o5x._o95 != 0u) {
    if (_odi >= _o5x._olq) {
      return;
    }
  } else {
    if (_odi >= _o7r[_o21]) {
      return;
    }
    _olo = _oeo[_odi];
  }
  if (_oat[_olo] == 0u) {
    return;
  }
  let _oi3 = 6u * _olo;
  let _o86 = _oa9[_oi3];
  let _o87 = _oa9[_oi3 + 1u];
  let _o88 = _oa9[_oi3 + 2u];
  let _od4 = _o86 * _oj2(0u) + _o87 * _oj2(4u) + _o88 * _oj2(8u) + _oj2(12u);
  let _od5 = _o86 * _oj2(1u) + _o87 * _oj2(5u) + _o88 * _oj2(9u) + _oj2(13u);
  let _od3 = _o86 * _oj2(3u) + _o87 * _oj2(7u) + _o88 * _oj2(11u) + _oj2(15u);
  let _oem = _od3 > _o0 && _odz(_od3) && _od4 + _od3 >= 0.0
      && _od3 - _od4 >= 0.0 && _od5 + _od3 >= 0.0 && _od3 - _od5 >= 0.0;
  if (!_oem) {
    _oau[_olo] = 1.0;
    return;
  }
  let _oqg = 8u * _olo;
  let _ok7 = _oqt[_oqg];
  let _ok8 = _oqt[_oqg + 1u];
  let _ok9 = _oqt[_oqg + 2u];
  let _oka = _oqt[_oqg + 3u];
  let _olx = vec3f(_oqt[_oqg + 4u], _oqt[_oqg + 5u], _oqt[_oqg + 6u]);
  let r = mat3x3f(
      vec3f(1.0 - 2.0 * (_ok9 * _ok9 + _oka * _oka), 2.0 * (_ok8 * _ok9 + _ok7 * _oka), 2.0 * (_ok8 * _oka - _ok7 * _ok9)),
      vec3f(2.0 * (_ok8 * _ok9 - _ok7 * _oka), 1.0 - 2.0 * (_ok8 * _ok8 + _oka * _oka), 2.0 * (_ok9 * _oka + _ok7 * _ok8)),
      vec3f(2.0 * (_ok8 * _oka + _ok7 * _ok9), 2.0 * (_ok9 * _oka - _ok7 * _ok8), 1.0 - 2.0 * (_ok8 * _ok8 + _ok9 * _ok9)));
  let _ody = 1.0 / (_od3 * _od3);
  let _oe8 = _o5x._ocr * (_od3 * vec3f(_oj2(0u), _oj2(4u), _oj2(8u))
      - _od4 * vec3f(_oj2(3u), _oj2(7u), _oj2(11u))) * _ody;
  let _oeb = _o5x._oco * (_od3 * vec3f(_oj2(1u), _oj2(5u), _oj2(9u))
      - _od5 * vec3f(_oj2(3u), _oj2(7u), _oj2(11u))) * _ody;
  let _ofz = vec3f(dot(_oe8, r[0]), dot(_oe8, r[1]), dot(_oe8, r[2])) * _olx;
  let _og0 = vec3f(dot(_oeb, r[0]), dot(_oeb, r[1]), dot(_oeb, r[2])) * _olx;
  var _o5a = dot(_ofz, _ofz) + _o5x._oav;
  var _o5d = dot(_ofz, _og0);
  var _o5k = dot(_og0, _og0) + _o5x._oav;
  let _osb = _om1[_olo] * _om1[_olo];
  _o5a = _o5a + _osb * dot(_oe8, _oe8);
  _o5d = _o5d + _osb * dot(_oe8, _oeb);
  _o5k = _o5k + _osb * dot(_oeb, _oeb);
  let _o3l = 0.5 * _olx.x * (_olx.y + _olx.z);
  let _ogy = length(cross(_oe8, _oeb));
  let _oed = _o3l * _ogy / sqrt(_o5a * _o5k - _o5d * _o5d);
  var _o6l = _oed;
  if (!_oe0(_oed)) {
    _o6l = max(_oed, _o17);
  }
  _oau[_olo] = 1.0 / _o6l;
}
