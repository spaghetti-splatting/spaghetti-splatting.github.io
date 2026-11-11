@group(0) @binding(0) var<storage, read> _oau: array<f32>;
@group(0) @binding(1) var<storage, read> _ogu: array<f32>;
@group(0) @binding(2) var<storage, read_write> _ofn: array<u32>;
@group(0) @binding(3) var<uniform> _o69: _oo;
fn _ok9(_ofd: u32) -> f32 {
  return _o69._oku[_ofd >> 2u][_ofd & 3u];
}
@compute @workgroup_size(256)
fn prefilter(@builtin(local_invocation_index) _ogj: u32,
             @builtin(workgroup_id) _otg: vec3u,
             @builtin(num_workgroups) _oib: vec3u) {
  let _oei = _ogo(_otg, _oib) * _o2q + _ogj;
  if (_oei >= _o69._omy) {
    return;
  }
  let _ojb = 6u * _oei;
  let _o3y = _oau[_ojb];
  let _o43 = _oau[_ojb + 1u];
  let _o44 = _oau[_ojb + 2u];
  let _o5g = _oau[_ojb + 3u];
  let _o5h = _oau[_ojb + 4u];
  let _o5i = _oau[_ojb + 5u];
  let _o6j = 0.5 * (_o3y + _o5g);
  let _o6k = 0.5 * (_o43 + _o5h);
  let _o6l = 0.5 * (_o44 + _o5i);
  let _oox = _o5g - _o3y;
  let _ooy = _o5h - _o43;
  let _ooz = _o5i - _o44;
  let _odp = 0.5 * sqrt(_obt(_ooz, _ooz,
      _obt(_oox, _oox, _ooy * _ooy)));
  let _on4 = 3u * _oei;
  let _onj = exp(_ogu[_on4]);
  let _onk = exp(_ogu[_on4 + 1u]);
  let _onl = exp(_ogu[_on4 + 2u]);
  var _ohe = _onj;
  _ohe = select(_onk, _ohe, _ohe >= _onk);
  _ohe = select(_onl, _ohe, _ohe >= _onl);
  let _ols = _obt(_ohe, _o69._opx, _odp);
  var _oel = true;
  var _obm = _of0(_o6j) && _of0(_o6k) && _of0(_o6l)
      && _of0(_odp) && _of0(_onj) && _of0(_onk)
      && _of0(_onl) && _of0(_ols);
  for (var _ooa = 0u; _ooa < 4u; _ooa = _ooa + 1u) {
    let _o7y = select(1u, 0u, _ooa < 2u);
    let sign = select(1.0, -1.0, (_ooa & 1u) != 0u);
    let _ojm = select(_o69._ojr, _o69._ojq, _ooa < 2u);
    let _oic = _obt(_ok9(3u), _ojm, sign * _ok9(_o7y));
    let _oid = _obt(_ok9(7u), _ojm, sign * _ok9(4u + _o7y));
    let _oie = _obt(_ok9(11u), _ojm, sign * _ok9(8u + _o7y));
    let _oia = _obt(_ok9(15u), _ojm, sign * _ok9(12u + _o7y));
    let _ooe = _obt(_o6l, _oie,
        _obt(_o6j, _oic, _o6k * _oid)) + _oia;
    let _opw = _ols * sqrt(_obt(_oie, _oie, _obt(_oic, _oic, _oid * _oid)));
    let _omu = 1.0e-6 * _obu(1.0, abs(_ooe) + _opw);
    _obm = _obm && _of0(_ooe) && _of0(_opw);
    _oel = _oel
        && _ooe + _opw >= -_omu;
  }
  let _ot8 = _ok9(3u);
  let _ot9 = _ok9(7u);
  let _ota = _ok9(11u);
  let _o7p = _obt(_o6l, _ota, _obt(_o6j, _ot8, _o6k * _ot9)) + _ok9(15u);
  let _o7q = _ols * sqrt(_obt(_ota, _ota, _obt(_ot8, _ot8, _ot9 * _ot9)));
  _obm = _obm && _of0(_o7p) && _of0(_o7q);
  let _or6 = _obt(_obu(1.0, abs(_o7p) + _o7q), 1.0e-6, 1.0e-3);
  let _o6n = _o7p - _o7q > _or6;
  _ofn[_oei] = select(0u, 1u, !_obm || !_o6n || _oel);
}
