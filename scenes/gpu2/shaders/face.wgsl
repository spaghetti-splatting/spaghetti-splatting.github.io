@group(0) @binding(0) var<storage, read> _o9x: array<f32>;
@group(0) @binding(1) var<storage, read> _oq5: array<f32>;
@group(0) @binding(2) var<storage, read> _ole: array<f32>;
@group(0) @binding(3) var<storage, read> _oaf: array<u32>;
@group(0) @binding(4) var<storage, read> _oe8: array<u32>;
@group(0) @binding(5) var<storage, read> _o7m: array<u32>;
@group(0) @binding(6) var<storage, read_write> _oag: array<f32>;
@group(0) @binding(7) var<uniform> _o5o: _oo;
const _o0: f32 = 1e-3;
const _o19: f32 = 1e-12;
fn _oik(_odx: u32) -> f32 {
  return _o5o._oj5[_odx >> 2u][_odx & 3u];
}
@compute @workgroup_size(256)
fn face_factor_pass(@builtin(local_invocation_index) _oey: u32,
                    @builtin(workgroup_id) _orc: vec3u,
                    @builtin(num_workgroups) _ogn: vec3u) {
  let _od2 = _of3(_orc, _ogn) * _o2h + _oey;
  var _ol2 = _od2;
  if (_o5o._o8u != 0u) {
    if (_od2 >= _o5o._ol4) {
      return;
    }
  } else {
    if (_od2 >= _o7m[_o1u]) {
      return;
    }
    _ol2 = _oe8[_od2];
  }
  if (_oaf[_ol2] == 0u) {
    return;
  }
  let _ohn = 6u * _ol2;
  let _o7x = _o9x[_ohn];
  let _o7y = _o9x[_ohn + 1u];
  let _o7z = _o9x[_ohn + 2u];
  let _oco = _o7x * _oik(0u) + _o7y * _oik(4u) + _o7z * _oik(8u) + _oik(12u);
  let _ocp = _o7x * _oik(1u) + _o7y * _oik(5u) + _o7z * _oik(9u) + _oik(13u);
  let _ocn = _o7x * _oik(3u) + _o7y * _oik(7u) + _o7z * _oik(11u) + _oik(15u);
  let _oe6 = _ocn > _o0 && _odk(_ocn) && _oco + _ocn >= 0.0
      && _ocn - _oco >= 0.0 && _ocp + _ocn >= 0.0 && _ocn - _ocp >= 0.0;
  if (!_oe6) {
    _oag[_ol2] = 1.0;
    return;
  }
  let _ops = 8u * _ol2;
  let _ojp = _oq5[_ops];
  let _ojq = _oq5[_ops + 1u];
  let _ojr = _oq5[_ops + 2u];
  let _ojs = _oq5[_ops + 3u];
  let _ola = vec3f(_oq5[_ops + 4u], _oq5[_ops + 5u], _oq5[_ops + 6u]);
  let r = mat3x3f(
      vec3f(1.0 - 2.0 * (_ojr * _ojr + _ojs * _ojs), 2.0 * (_ojq * _ojr + _ojp * _ojs), 2.0 * (_ojq * _ojs - _ojp * _ojr)),
      vec3f(2.0 * (_ojq * _ojr - _ojp * _ojs), 1.0 - 2.0 * (_ojq * _ojq + _ojs * _ojs), 2.0 * (_ojr * _ojs + _ojp * _ojq)),
      vec3f(2.0 * (_ojq * _ojs + _ojp * _ojr), 2.0 * (_ojr * _ojs - _ojp * _ojq), 1.0 - 2.0 * (_ojq * _ojq + _ojr * _ojr)));
  let _odi = 1.0 / (_ocn * _ocn);
  let _ods = _o5o._ocd * (_ocn * vec3f(_oik(0u), _oik(4u), _oik(8u))
      - _oco * vec3f(_oik(3u), _oik(7u), _oik(11u))) * _odi;
  let _odv = _o5o._oca * (_ocn * vec3f(_oik(1u), _oik(5u), _oik(9u))
      - _ocp * vec3f(_oik(3u), _oik(7u), _oik(11u))) * _odi;
  let _ofg = vec3f(dot(_ods, r[0]), dot(_ods, r[1]), dot(_ods, r[2])) * _ola;
  let _ofh = vec3f(dot(_odv, r[0]), dot(_odv, r[1]), dot(_odv, r[2])) * _ola;
  var _o51 = dot(_ofg, _ofg) + _o5o._oah;
  var _o54 = dot(_ofg, _ofh);
  var _o5b = dot(_ofh, _ofh) + _o5o._oah;
  let _orj = _ole[_ol2] * _ole[_ol2];
  _o51 = _o51 + _orj * dot(_ods, _ods);
  _o54 = _o54 + _orj * dot(_ods, _odv);
  _o5b = _o5b + _orj * dot(_odv, _odv);
  let _o3d = 0.5 * _ola.x * (_ola.y + _ola.z);
  let _ogh = length(cross(_ods, _odv));
  let _odx = _o3d * _ogh / sqrt(_o51 * _o5b - _o54 * _o54);
  var _o67 = _odx;
  if (!_odl(_odx)) {
    _o67 = max(_odx, _o19);
  }
  _oag[_ol2] = 1.0 / _o67;
}
