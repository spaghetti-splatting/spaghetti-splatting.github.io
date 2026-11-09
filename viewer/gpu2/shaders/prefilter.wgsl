@group(0) @binding(0) var<storage, read> _oa9: array<f32>;
@group(0) @binding(1) var<storage, read> _ofs: array<f32>;
@group(0) @binding(2) var<storage, read_write> _oel: array<u32>;
@group(0) @binding(3) var<uniform> _o5x: _oo;
fn _oj2(_oed: u32) -> f32 {
  return _o5x._ojs[_oed >> 2u][_oed & 3u];
}
@compute @workgroup_size(256)
fn prefilter(@builtin(local_invocation_index) _ofg: u32,
             @builtin(workgroup_id) _os5: vec3u,
             @builtin(num_workgroups) _oh4: vec3u) {
  let _odi = _ofj(_os5, _oh4) * _o2o + _ofg;
  if (_odi >= _o5x._olq) {
    return;
  }
  let _oi3 = 6u * _odi;
  let _o3r = _oa9[_oi3];
  let _o3x = _oa9[_oi3 + 1u];
  let _o3y = _oa9[_oi3 + 2u];
  let _o55 = _oa9[_oi3 + 3u];
  let _o56 = _oa9[_oi3 + 4u];
  let _o57 = _oa9[_oi3 + 5u];
  let _o6a = 0.5 * (_o3r + _o55);
  let _o6b = 0.5 * (_o3x + _o56);
  let _o6c = 0.5 * (_o3y + _o57);
  let _onn = _o55 - _o3r;
  let _ono = _o56 - _o3x;
  let _onp = _o57 - _o3y;
  let _ocp = 0.5 * sqrt(_obc(_onp, _onp,
      _obc(_onn, _onn, _ono * _ono)));
  let _olx = 3u * _odi;
  let _omb = exp(_ofs[_olx]);
  let _omc = exp(_ofs[_olx + 1u]);
  let _omd = exp(_ofs[_olx + 2u]);
  var _oga = _omb;
  _oga = select(_omc, _oga, _oga >= _omc);
  _oga = select(_omd, _oga, _oga >= _omd);
  let _okj = _obc(_oga, _o5x._ooj, _ocp);
  var _odl = true;
  var _ob4 = _odz(_o6a) && _odz(_o6b) && _odz(_o6c)
      && _odz(_ocp) && _odz(_omb) && _odz(_omc)
      && _odz(_omd) && _odz(_okj);
  for (var _on2 = 0u; _on2 < 4u; _on2 = _on2 + 1u) {
    let _o73 = select(1u, 0u, _on2 < 2u);
    let sign = select(1.0, -1.0, (_on2 & 1u) != 0u);
    let _oif = select(_o5x._oik, _o5x._oij, _on2 < 2u);
    let _oh5 = _obc(_oj2(3u), _oif, sign * _oj2(_o73));
    let _oh6 = _obc(_oj2(7u), _oif, sign * _oj2(4u + _o73));
    let _oh7 = _obc(_oj2(11u), _oif, sign * _oj2(8u + _o73));
    let _oh3 = _obc(_oj2(15u), _oif, sign * _oj2(12u + _o73));
    let _on5 = _obc(_o6c, _oh7,
        _obc(_o6a, _oh5, _o6b * _oh6)) + _oh3;
    let _ooi = _okj * sqrt(_obc(_oh7, _oh7, _obc(_oh5, _oh5, _oh6 * _oh6)));
    let _olm = 1.0e-6 * _obd(1.0, abs(_on5) + _ooi);
    _ob4 = _ob4 && _odz(_on5) && _odz(_ooi);
    _odl = _odl
        && _on5 + _ooi >= -_olm;
  }
  let _orx = _oj2(3u);
  let _ory = _oj2(7u);
  let _orz = _oj2(11u);
  let _o6t = _obc(_o6c, _orz, _obc(_o6a, _orx, _o6b * _ory)) + _oj2(15u);
  let _o6u = _okj * sqrt(_obc(_orz, _orz, _obc(_orx, _orx, _ory * _ory)));
  _ob4 = _ob4 && _odz(_o6t) && _odz(_o6u);
  let _opq = _obc(_obd(1.0, abs(_o6t) + _o6u), 1.0e-6, 1.0e-3);
  let _o6e = _o6t - _o6u > _opq;
  _oel[_odi] = select(0u, 1u, !_ob4 || !_o6e || _odl);
}
