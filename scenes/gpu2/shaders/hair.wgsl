struct _o24 {
  _onj: u32,
  _oqn: u32,
  _obp: u32,
  _ore: u32,
  _obz: f32,
  _o8e: f32,
  _o9c: f32,
  _o4d: f32,
  _onq: f32,
  _onr: f32,
  _onp: f32,
  _ong: f32,
  _o7d: f32,
  _ofr: f32,
  _op9: f32,
  _obv: f32,
  _o8g: vec4f,
  _ord: vec4f,
  _om4: vec4f,
  _om5: vec4u,
  _obq: vec4f,
};
@group(0) @binding(0) var<uniform> _omw: _o24;
@group(0) @binding(1) var<storage, read> _oni: array<u32>;
@group(0) @binding(2) var<storage, read> _okn: array<vec4f>;
@group(0) @binding(3) var<storage, read_write> _o3h: array<vec4f>;
@group(0) @binding(4) var<storage, read_write> _obo: array<vec4f>;
@group(0) @binding(5) var<storage, read_write> _orp: array<vec4f>;
@group(0) @binding(6) var<storage, read_write> _oqv: array<vec4f>;
@group(0) @binding(7) var<storage, read> _om2: array<f32>;
@group(0) @binding(8) var<storage, read_write> _onf: array<atomic<u32>>;
struct _o23 {
  _o7z: f32,
  g: vec3f,
};
fn _om3(_ohm: vec3f) -> _o23 {
  var _oh6: _o23;
  let _ogn = _omw._om5.x;
  let _ogo = _omw._om5.y;
  let _ogp = _omw._om5.z;
  let _oa9 = (_ohm - _omw._om4.xyz) * _omw._om4.w;
  if (_oa9.x < 0.0 || _oa9.y < 0.0 || _oa9.z < 0.0 || _oa9.x > f32(_ogn) - 1.001 || _oa9.y > f32(_ogo) - 1.001
      || _oa9.z > f32(_ogp) - 1.001) {
    _oh6._o7z = 1.0e6;
    _oh6.g = vec3f(0.0);
    return _oh6;
  }
  let _ocq = u32(_oa9.x);
  let _odm = u32(_oa9.y);
  let _odw = u32(_oa9.z);
  let _ob9 = _oa9.x - f32(_ocq);
  let _oba = _oa9.y - f32(_odm);
  let _obb = _oa9.z - f32(_odw);
  let _ogq = (_ocq * _ogo + _odm) * _ogp + _odw;
  let _omn = _ogp;
  let _omd = _ogo * _ogp;
  let _o52 = _om2[_ogq];
  let _o53 = _om2[_ogq + 1u];
  let _o55 = _om2[_ogq + _omn];
  let _o56 = _om2[_ogq + _omn + 1u];
  let _o59 = _om2[_ogq + _omd];
  let _o5a = _om2[_ogq + _omd + 1u];
  let _o5c = _om2[_ogq + _omd + _omn];
  let _o5d = _om2[_ogq + _omd + _omn + 1u];
  let _o51 = _o52 + (_o53 - _o52) * _obb;
  let _o54 = _o55 + (_o56 - _o55) * _obb;
  let _o58 = _o59 + (_o5a - _o59) * _obb;
  let _o5b = _o5c + (_o5d - _o5c) * _obb;
  let _o50 = _o51 + (_o54 - _o51) * _oba;
  let _o57 = _o58 + (_o5b - _o58) * _oba;
  let _obw = _o57 - _o50;
  let _obx = (1.0 - _ob9) * (_o54 - _o51) + _ob9 * (_o5b - _o58);
  let _o9n = (_o53 - _o52) * (1.0 - _oba) + (_o56 - _o55) * _oba;
  let _o9o = (_o5a - _o59) * (1.0 - _oba) + (_o5d - _o5c) * _oba;
  let _oby = _o9n * (1.0 - _ob9) + _o9o * _ob9;
  let g = vec3f(_obw, _obx, _oby);
  let _og6 = length(g);
  _oh6.g = select(vec3f(0.0), g / _og6, _og6 > 0.0);
  _oh6._o7z = _o50 + (_o57 - _o50) * _ob9;
  return _oh6;
}
fn _o8z(_ocq: u32) -> vec3f {
  return _orp[_ocq].xyz - _okn[_ocq].xyz;
}
fn _oay(_oer: vec3f, _ojb: vec3f, _oko: vec3f, _oes: f32) -> vec3f {
  var _o9m = _ojb - _oer;
  var _og6 = length(_o9m);
  if (_og6 < 1.0e-12) {
    _o9m = _oko;
    _og6 = length(_o9m);
  }
  return _oer + _o9m * (_oes / _og6);
}
fn _o3g(_omp: u32, _oqh: f32) {
  atomicMax(&_onf[_omp], bitcast<u32>(max(_oqh, 0.0)));
}
@compute @workgroup_size(64)
fn substep(@builtin(global_invocation_id) _obl: vec3u, @builtin(num_workgroups) _ogm: vec3u) {
  let _ol9 = _obl.x + _obl.y * _ogm.x * 64u;
  if (_ol9 >= _omw._onj) {
    return;
  }
  let _o40 = _oni[_ol9];
  let _og6 = _oni[_ol9 + 1u] - _o40;
  if (_og6 < 2u) {
    return;
  }
  let _obz = _omw._obz;
  let _oe2 = _omw._o4d;
  let _o4k = _omw._ong;
  let _o8c = 2.0 * sqrt(_o4k);
  let _ocu = 1.0 / _obz;
  let _o64 = _omw._o7d / _obz;
  _orp[_o40] = vec4f(_okn[_o40].xyz, 0.0);
  _oqv[_o40] = vec4f(0.0);
  var _ord = vec3f(0.0);
  if (_omw._ore != 0u) {
    let _ob8 = f32(_ol9);
    let _obv = 0.6 + 0.4 * sin(2.3 * _omw._op9 + 0.0007 * _ob8) + 0.25 * sin(5.1 * _omw._op9 + 0.0013 * _ob8);
    _ord = _omw._ord.xyz * _obv;
  }
  var _oq1 = vec3f(0.0);
  var _oq0 = vec3f(0.0);
  var _ops = vec3f(0.0);
  var _oq7 = _o8z(_o40 + 1u);
  var _oq8 = vec3f(0.0);
  if (_og6 > 2u) {
    _oq8 = _o8z(_o40 + 2u);
  }
  var _oeq = _okn[_o40].xyz;
  var _oit = _oeq;
  var _oiu = _oeq;
  var _ofl = 0.0;
  var _ofk = 0.0;
  let _oep = _og6 - 1u;
  for (var _odw = 1u; _odw < _og6; _odw = _odw + 1u) {
    _oq1 = _oq0;
    _oq0 = _ops;
    _ops = _oq7;
    _oq7 = _oq8;
    if (_odw + 2u < _og6) {
      _oq8 = _o8z(_o40 + _odw + 2u);
    } else {
      _oq8 = vec3f(0.0);
    }
    let _ocq = _o40 + _odw;
    let x = _orp[_ocq].xyz;
    let _oqc = _oqv[_ocq].xyz;
    let _oju = _okn[_ocq];
    let _o3k = _o3h[_ocq];
    let _o93 = select(vec3f(0.0), _oq1 - 2.0 * _oq0 + _ops, _odw >= 2u);
    let _o92 = select(vec3f(0.0), _oq0 - 2.0 * _ops + _oq7, _odw <= _og6 - 2u);
    let _o94 = select(vec3f(0.0), _ops - 2.0 * _oq7 + _oq8, _odw + 1u <= _og6 - 2u);
    let _o4c = -_o93 + 2.0 * _o92 - _o94;
    let _onh = _omw._onr + (_omw._onq - _omw._onr) * exp(-_oju.w / _omw._onp);
    var a = -_onh * _ops + _oe2 * _o4c + _omw._o9c * (_ord - _oqc);
    let w = _o3k.z;
    if (_omw._obp != 0u && w > 0.0) {
      let _obm = _obo[_ocq].xyz + _o3k.w * _omw._o8g.xyz;
      a = a + w * (_o4k * (_obm - x) - _o8c * _oqc);
    }
    let _oql = (_oqc + _obz * a) * _omw._o8e;
    let _ohn = x + _obz * _oql;
    let _okp = _o3k.x;
    let _o95 = _o3k.y;
    let _oko = _oju.xyz - _okn[_ocq - 1u].xyz;
    var _ojb = _oay(_oeq, _ohn, _oko, _okp);
    for (var _odl = 0u; _odl < 2u; _odl = _odl + 1u) {
      let _omr = _om3(_ojb);
      if (!(_omr._o7z < _o95)) {
        break;
      }
      _ojb = _ojb + (_o95 - _omr._o7z) * _omr.g;
      _ojb = _oay(_oeq, _ojb, _oko, _okp);
    }
    let _o7z = _ojb - _ohn;
    if (_odw >= 2u) {
      let _odm = _ocq - 1u;
      let _oqt = (_oit - _oiu) * _ocu - _o64 * _o7z;
      _oqv[_odm] = vec4f(_oqt, 0.0);
      _orp[_odm] = vec4f(_oit, 0.0);
      _ofl = max(_ofl, dot(_oqt, _oqt));
      let _opz = _oit - _okn[_odm].xyz;
      _ofk = max(_ofk, dot(_opz, _opz));
    }
    _oit = _ojb;
    _oiu = x;
    _oeq = _ojb;
    if (_odw == _oep) {
      let _oqw = (_ojb - x) * _ocu;
      _oqv[_ocq] = vec4f(_oqw, 0.0);
      _orp[_ocq] = vec4f(_ojb, 0.0);
      _ofl = max(_ofl, dot(_oqw, _oqw));
      let _oqb = _ojb - _oju.xyz;
      _ofk = max(_ofk, dot(_oqb, _oqb));
    }
  }
  _o3g(0u, _ofl);
  _o3g(1u, _ofk);
}
@compute @workgroup_size(64)
fn grab_begin(@builtin(global_invocation_id) _obl: vec3u, @builtin(num_workgroups) _ogm: vec3u) {
  let _ol9 = _obl.x + _obl.y * _ogm.x * 64u;
  if (_ol9 >= _omw._onj) {
    return;
  }
  let _o40 = _oni[_ol9];
  let _og6 = _oni[_ol9 + 1u] - _o40;
  let _ojy = _omw._obq.w;
  let _o61 = _omw._obq.xyz;
  var _o4e = _ojy;
  var _oe2 = 0u;
  for (var _odw = 1u; _odw < _og6; _odw = _odw + 1u) {
    let _o8d = length(_orp[_o40 + _odw].xyz - _o61);
    if (_o8d < _o4e) {
      _o4e = _o8d;
      _oe2 = _odw;
    }
  }
  let _omf = 0.5 * _ojy * _ojy;
  let _or0 = exp(-_o4e * _o4e / _omf);
  let _o3c = max(_okn[_o40 + _oe2].w, 1.0e-9);
  for (var _odw = 0u; _odw < _og6; _odw = _odw + 1u) {
    let _ocq = _o40 + _odw;
    var _o3k = _o3h[_ocq];
    if (_oe2 > 0u && _odw >= 1u && _odw <= _oe2) {
      _o3k.z = _or0;
      _o3k.w = pow(min(_okn[_ocq].w / _o3c, 1.0), 1.5);
      _obo[_ocq] = _orp[_ocq];
    } else {
      _o3k.z = 0.0;
      _o3k.w = 0.0;
    }
    _o3h[_ocq] = _o3k;
  }
  if (_oe2 > 0u) {
    atomicAdd(&_onf[2], 1u);
  }
}
@compute @workgroup_size(256)
fn reset_state(@builtin(global_invocation_id) _obl: vec3u, @builtin(num_workgroups) _ogm: vec3u) {
  let _ocq = _obl.x + _obl.y * _ogm.x * 256u;
  if (_ocq >= _omw._oqn) {
    return;
  }
  _orp[_ocq] = vec4f(_okn[_ocq].xyz, 0.0);
  _oqv[_ocq] = vec4f(0.0);
  var _o3k = _o3h[_ocq];
  _o3k.z = 0.0;
  _o3k.w = 0.0;
  _o3h[_ocq] = _o3k;
}
