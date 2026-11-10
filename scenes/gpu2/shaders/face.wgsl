@group(0) @binding(0) var<storage, read> _o9w: array<f32>;
@group(0) @binding(1) var<storage, read> _oq4: array<f32>;
@group(0) @binding(2) var<storage, read> _old: array<f32>;
@group(0) @binding(3) var<storage, read> _oae: array<u32>;
@group(0) @binding(4) var<storage, read> _oe7: array<u32>;
@group(0) @binding(5) var<storage, read> _o7l: array<u32>;
@group(0) @binding(6) var<storage, read_write> _oaf: array<f32>;
@group(0) @binding(7) var<uniform> _o5o: _oo;
const _o0: f32 = 1e-3;
const _o19: f32 = 1e-12;
fn _oij(_odw: u32) -> f32 {
  return _o5o._oj4[_odw >> 2u][_odw & 3u];
}
@compute @workgroup_size(256)
fn face_factor_pass(@builtin(local_invocation_index) _oex: u32,
                    @builtin(workgroup_id) _orb: vec3u,
                    @builtin(num_workgroups) _ogm: vec3u) {
  let _od1 = _of2(_orb, _ogm) * _o2h + _oex;
  var _ol1 = _od1;
  if (_o5o._o8t != 0u) {
    if (_od1 >= _o5o._ol3) {
      return;
    }
  } else {
    if (_od1 >= _o7l[_o1u]) {
      return;
    }
    _ol1 = _oe7[_od1];
  }
  if (_oae[_ol1] == 0u) {
    return;
  }
  let _ohm = 6u * _ol1;
  let _o7w = _o9w[_ohm];
  let _o7x = _o9w[_ohm + 1u];
  let _o7y = _o9w[_ohm + 2u];
  let _ocn = _o7w * _oij(0u) + _o7x * _oij(4u) + _o7y * _oij(8u) + _oij(12u);
  let _oco = _o7w * _oij(1u) + _o7x * _oij(5u) + _o7y * _oij(9u) + _oij(13u);
  let _ocm = _o7w * _oij(3u) + _o7x * _oij(7u) + _o7y * _oij(11u) + _oij(15u);
  let _oe5 = _ocm > _o0 && _odj(_ocm) && _ocn + _ocm >= 0.0
      && _ocm - _ocn >= 0.0 && _oco + _ocm >= 0.0 && _ocm - _oco >= 0.0;
  if (!_oe5) {
    _oaf[_ol1] = 1.0;
    return;
  }
  let _opr = 8u * _ol1;
  let _ojo = _oq4[_opr];
  let _ojp = _oq4[_opr + 1u];
  let _ojq = _oq4[_opr + 2u];
  let _ojr = _oq4[_opr + 3u];
  let _ol9 = vec3f(_oq4[_opr + 4u], _oq4[_opr + 5u], _oq4[_opr + 6u]);
  let r = mat3x3f(
      vec3f(1.0 - 2.0 * (_ojq * _ojq + _ojr * _ojr), 2.0 * (_ojp * _ojq + _ojo * _ojr), 2.0 * (_ojp * _ojr - _ojo * _ojq)),
      vec3f(2.0 * (_ojp * _ojq - _ojo * _ojr), 1.0 - 2.0 * (_ojp * _ojp + _ojr * _ojr), 2.0 * (_ojq * _ojr + _ojo * _ojp)),
      vec3f(2.0 * (_ojp * _ojr + _ojo * _ojq), 2.0 * (_ojq * _ojr - _ojo * _ojp), 1.0 - 2.0 * (_ojp * _ojp + _ojq * _ojq)));
  let _odh = 1.0 / (_ocm * _ocm);
  let _odr = _o5o._occ * (_ocm * vec3f(_oij(0u), _oij(4u), _oij(8u))
      - _ocn * vec3f(_oij(3u), _oij(7u), _oij(11u))) * _odh;
  let _odu = _o5o._oc9 * (_ocm * vec3f(_oij(1u), _oij(5u), _oij(9u))
      - _oco * vec3f(_oij(3u), _oij(7u), _oij(11u))) * _odh;
  let _off = vec3f(dot(_odr, r[0]), dot(_odr, r[1]), dot(_odr, r[2])) * _ol9;
  let _ofg = vec3f(dot(_odu, r[0]), dot(_odu, r[1]), dot(_odu, r[2])) * _ol9;
  var _o51 = dot(_off, _off) + _o5o._oag;
  var _o54 = dot(_off, _ofg);
  var _o5b = dot(_ofg, _ofg) + _o5o._oag;
  let _ori = _old[_ol1] * _old[_ol1];
  _o51 = _o51 + _ori * dot(_odr, _odr);
  _o54 = _o54 + _ori * dot(_odr, _odu);
  _o5b = _o5b + _ori * dot(_odu, _odu);
  let _o3d = 0.5 * _ol9.x * (_ol9.y + _ol9.z);
  let _ogg = length(cross(_odr, _odu));
  let _odw = _o3d * _ogg / sqrt(_o51 * _o5b - _o54 * _o54);
  var _o67 = _odw;
  if (!_odk(_odw)) {
    _o67 = max(_odw, _o19);
  }
  _oaf[_ol1] = 1.0 / _o67;
}
