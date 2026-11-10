@group(0) @binding(0) var<storage, read> _o9w: array<f32>;
@group(0) @binding(1) var<storage, read> _of8: array<f32>;
@group(0) @binding(2) var<storage, read_write> _oe4: array<u32>;
@group(0) @binding(3) var<uniform> _o5o: _oo;
fn _oij(_odw: u32) -> f32 {
  return _o5o._oj4[_odw >> 2u][_odw & 3u];
}
@compute @workgroup_size(256)
fn prefilter(@builtin(local_invocation_index) _oex: u32,
             @builtin(workgroup_id) _orb: vec3u,
             @builtin(num_workgroups) _ogm: vec3u) {
  let _od1 = _of2(_orb, _ogm) * _o2h + _oex;
  if (_od1 >= _o5o._ol3) {
    return;
  }
  let _ohm = 6u * _od1;
  let _o3j = _o9w[_ohm];
  let _o3o = _o9w[_ohm + 1u];
  let _o3p = _o9w[_ohm + 2u];
  let _o4w = _o9w[_ohm + 3u];
  let _o4x = _o9w[_ohm + 4u];
  let _o4y = _o9w[_ohm + 5u];
  let _o5y = 0.5 * (_o3j + _o4w);
  let _o5z = 0.5 * (_o3o + _o4x);
  let _o60 = 0.5 * (_o3p + _o4y);
  let _omz = _o4w - _o3j;
  let _on0 = _o4x - _o3o;
  let _on1 = _o4y - _o3p;
  let _oca = 0.5 * sqrt(_oau(_on1, _on1,
      _oau(_omz, _omz, _on0 * _on0)));
  let _ol9 = 3u * _od1;
  let _oln = exp(_of8[_ol9]);
  let _olo = exp(_of8[_ol9 + 1u]);
  let _olp = exp(_of8[_ol9 + 2u]);
  var _ofq = _oln;
  _ofq = select(_olo, _ofq, _ofq >= _olo);
  _ofq = select(_olp, _ofq, _ofq >= _olp);
  let _ojy = _oau(_ofq, _o5o._onu, _oca);
  var _od4 = true;
  var _oao = _odj(_o5y) && _odj(_o5z) && _odj(_o60)
      && _odj(_oca) && _odj(_oln) && _odj(_olo)
      && _odj(_olp) && _odj(_ojy);
  for (var _ome = 0u; _ome < 4u; _ome = _ome + 1u) {
    let _o72 = select(1u, 0u, _ome < 2u);
    let sign = select(1.0, -1.0, (_ome & 1u) != 0u);
    let _ohx = select(_o5o._oi2, _o5o._oi1, _ome < 2u);
    let _ogn = _oau(_oij(3u), _ohx, sign * _oij(_o72));
    let _ogo = _oau(_oij(7u), _ohx, sign * _oij(4u + _o72));
    let _ogp = _oau(_oij(11u), _ohx, sign * _oij(8u + _o72));
    let _ogl = _oau(_oij(15u), _ohx, sign * _oij(12u + _o72));
    let _omh = _oau(_o60, _ogp,
        _oau(_o5y, _ogn, _o5z * _ogo)) + _ogl;
    let _ont = _ojy * sqrt(_oau(_ogp, _ogp, _oau(_ogn, _ogn, _ogo * _ogo)));
    let _okz = 1.0e-6 * _oav(1.0, abs(_omh) + _ont);
    _oao = _oao && _odj(_omh) && _odj(_ont);
    _od4 = _od4
        && _omh + _ont >= -_okz;
  }
  let _or3 = _oij(3u);
  let _or4 = _oij(7u);
  let _or5 = _oij(11u);
  let _o6t = _oau(_o60, _or5, _oau(_o5y, _or3, _o5z * _or4)) + _oij(15u);
  let _o6u = _ojy * sqrt(_oau(_or5, _or5, _oau(_or3, _or3, _or4 * _or4)));
  _oao = _oao && _odj(_o6t) && _odj(_o6u);
  let _op2 = _oau(_oav(1.0, abs(_o6t) + _o6u), 1.0e-6, 1.0e-3);
  let _o62 = _o6t - _o6u > _op2;
  _oe4[_od1] = select(0u, 1u, !_oao || !_o62 || _od4);
}
