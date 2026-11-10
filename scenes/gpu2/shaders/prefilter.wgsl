@group(0) @binding(0) var<storage, read> _o9x: array<f32>;
@group(0) @binding(1) var<storage, read> _of9: array<f32>;
@group(0) @binding(2) var<storage, read_write> _oe5: array<u32>;
@group(0) @binding(3) var<uniform> _o5o: _oo;
fn _oik(_odx: u32) -> f32 {
  return _o5o._oj5[_odx >> 2u][_odx & 3u];
}
@compute @workgroup_size(256)
fn prefilter(@builtin(local_invocation_index) _oey: u32,
             @builtin(workgroup_id) _orc: vec3u,
             @builtin(num_workgroups) _ogn: vec3u) {
  let _od2 = _of3(_orc, _ogn) * _o2h + _oey;
  if (_od2 >= _o5o._ol4) {
    return;
  }
  let _ohn = 6u * _od2;
  let _o3j = _o9x[_ohn];
  let _o3o = _o9x[_ohn + 1u];
  let _o3p = _o9x[_ohn + 2u];
  let _o4w = _o9x[_ohn + 3u];
  let _o4x = _o9x[_ohn + 4u];
  let _o4y = _o9x[_ohn + 5u];
  let _o5y = 0.5 * (_o3j + _o4w);
  let _o5z = 0.5 * (_o3o + _o4x);
  let _o60 = 0.5 * (_o3p + _o4y);
  let _on0 = _o4w - _o3j;
  let _on1 = _o4x - _o3o;
  let _on2 = _o4y - _o3p;
  let _ocb = 0.5 * sqrt(_oav(_on2, _on2,
      _oav(_on0, _on0, _on1 * _on1)));
  let _ola = 3u * _od2;
  let _olo = exp(_of9[_ola]);
  let _olp = exp(_of9[_ola + 1u]);
  let _olq = exp(_of9[_ola + 2u]);
  var _ofr = _olo;
  _ofr = select(_olp, _ofr, _ofr >= _olp);
  _ofr = select(_olq, _ofr, _ofr >= _olq);
  let _ojz = _oav(_ofr, _o5o._onv, _ocb);
  var _od5 = true;
  var _oap = _odk(_o5y) && _odk(_o5z) && _odk(_o60)
      && _odk(_ocb) && _odk(_olo) && _odk(_olp)
      && _odk(_olq) && _odk(_ojz);
  for (var _omf = 0u; _omf < 4u; _omf = _omf + 1u) {
    let _o73 = select(1u, 0u, _omf < 2u);
    let sign = select(1.0, -1.0, (_omf & 1u) != 0u);
    let _ohy = select(_o5o._oi3, _o5o._oi2, _omf < 2u);
    let _ogo = _oav(_oik(3u), _ohy, sign * _oik(_o73));
    let _ogp = _oav(_oik(7u), _ohy, sign * _oik(4u + _o73));
    let _ogq = _oav(_oik(11u), _ohy, sign * _oik(8u + _o73));
    let _ogm = _oav(_oik(15u), _ohy, sign * _oik(12u + _o73));
    let _omi = _oav(_o60, _ogq,
        _oav(_o5y, _ogo, _o5z * _ogp)) + _ogm;
    let _onu = _ojz * sqrt(_oav(_ogq, _ogq, _oav(_ogo, _ogo, _ogp * _ogp)));
    let _ol0 = 1.0e-6 * _oaw(1.0, abs(_omi) + _onu);
    _oap = _oap && _odk(_omi) && _odk(_onu);
    _od5 = _od5
        && _omi + _onu >= -_ol0;
  }
  let _or4 = _oik(3u);
  let _or5 = _oik(7u);
  let _or6 = _oik(11u);
  let _o6u = _oav(_o60, _or6, _oav(_o5y, _or4, _o5z * _or5)) + _oik(15u);
  let _o6v = _ojz * sqrt(_oav(_or6, _or6, _oav(_or4, _or4, _or5 * _or5)));
  _oap = _oap && _odk(_o6u) && _odk(_o6v);
  let _op3 = _oav(_oaw(1.0, abs(_o6u) + _o6v), 1.0e-6, 1.0e-3);
  let _o62 = _o6u - _o6v > _op3;
  _oe5[_od2] = select(0u, 1u, !_oap || !_o62 || _od5);
}
