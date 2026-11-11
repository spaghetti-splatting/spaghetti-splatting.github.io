@group(0) @binding(0) var<storage, read> _oau: array<f32>;
@group(0) @binding(1) var<storage, read> _os9: array<f32>;
@group(0) @binding(2) var<storage, read> _on8: array<f32>;
@group(0) @binding(3) var<storage, read> _obc: array<u32>;
@group(0) @binding(4) var<storage, read> _ofq: array<u32>;
@group(0) @binding(5) var<storage, read> _o8h: array<u32>;
@group(0) @binding(6) var<storage, read_write> _obd: array<f32>;
@group(0) @binding(7) var<uniform> _o69: _oo;
const _o0: f32 = 1e-3;
const _o1c: f32 = 1e-12;
fn _ok9(_ofd: u32) -> f32 {
  return _o69._oku[_ofd >> 2u][_ofd & 3u];
}
@compute @workgroup_size(256)
fn face_factor_pass(@builtin(local_invocation_index) _ogj: u32,
                    @builtin(workgroup_id) _otg: vec3u,
                    @builtin(num_workgroups) _oib: vec3u) {
  let _oei = _ogo(_otg, _oib) * _o2q + _ogj;
  var _omw = _oei;
  if (_o69._o9p != 0u) {
    if (_oei >= _o69._omy) {
      return;
    }
  } else {
    if (_oei >= _o8h[_o23]) {
      return;
    }
    _omw = _ofq[_oei];
  }
  if (_obc[_omw] == 0u) {
    return;
  }
  let _ojb = 6u * _omw;
  let _o8s = _oau[_ojb];
  let _o8t = _oau[_ojb + 1u];
  let _o8u = _oau[_ojb + 2u];
  let _oe4 = _o8s * _ok9(0u) + _o8t * _ok9(4u) + _o8u * _ok9(8u) + _ok9(12u);
  let _oe5 = _o8s * _ok9(1u) + _o8t * _ok9(5u) + _o8u * _ok9(9u) + _ok9(13u);
  let _oe3 = _o8s * _ok9(3u) + _o8t * _ok9(7u) + _o8u * _ok9(11u) + _ok9(15u);
  let _ofo = _oe3 > _o0 && _of0(_oe3) && _oe4 + _oe3 >= 0.0
      && _oe3 - _oe4 >= 0.0 && _oe5 + _oe3 >= 0.0 && _oe3 - _oe5 >= 0.0;
  if (!_ofo) {
    _obd[_omw] = 1.0;
    return;
  }
  let _orw = 8u * _omw;
  let _olh = _os9[_orw];
  let _oli = _os9[_orw + 1u];
  let _olj = _os9[_orw + 2u];
  let _olk = _os9[_orw + 3u];
  let _on4 = vec3f(_os9[_orw + 4u], _os9[_orw + 5u], _os9[_orw + 6u]);
  let r = mat3x3f(
      vec3f(1.0 - 2.0 * (_olj * _olj + _olk * _olk), 2.0 * (_oli * _olj + _olh * _olk), 2.0 * (_oli * _olk - _olh * _olj)),
      vec3f(2.0 * (_oli * _olj - _olh * _olk), 1.0 - 2.0 * (_oli * _oli + _olk * _olk), 2.0 * (_olj * _olk + _olh * _oli)),
      vec3f(2.0 * (_oli * _olk + _olh * _olj), 2.0 * (_olj * _olk - _olh * _oli), 1.0 - 2.0 * (_oli * _oli + _olj * _olj)));
  let _oey = 1.0 / (_oe3 * _oe3);
  let _of8 = _o69._odr * (_oe3 * vec3f(_ok9(0u), _ok9(4u), _ok9(8u))
      - _oe4 * vec3f(_ok9(3u), _ok9(7u), _ok9(11u))) * _oey;
  let _ofb = _o69._odo * (_oe3 * vec3f(_ok9(1u), _ok9(5u), _ok9(9u))
      - _oe5 * vec3f(_ok9(3u), _ok9(7u), _ok9(11u))) * _oey;
  let _oh2 = vec3f(dot(_of8, r[0]), dot(_of8, r[1]), dot(_of8, r[2])) * _on4;
  let _oh3 = vec3f(dot(_ofb, r[0]), dot(_ofb, r[1]), dot(_ofb, r[2])) * _on4;
  var _o5l = dot(_oh2, _oh2) + _o69._obe;
  var _o5o = dot(_oh2, _oh3);
  var _o5v = dot(_oh3, _oh3) + _o69._obe;
  let _oto = _on8[_omw] * _on8[_omw];
  _o5l = _o5l + _oto * dot(_of8, _of8);
  _o5o = _o5o + _oto * dot(_of8, _ofb);
  _o5v = _o5v + _oto * dot(_ofb, _ofb);
  let _o3s = 0.5 * _on4.x * (_on4.y + _on4.z);
  let _oi5 = length(cross(_of8, _ofb));
  let _ofd = _o3s * _oi5 / sqrt(_o5l * _o5v - _o5o * _o5o);
  var _o6s = _ofd;
  if (!_of1(_ofd)) {
    _o6s = max(_ofd, _o1c);
  }
  _obd[_omw] = 1.0 / _o6s;
}
