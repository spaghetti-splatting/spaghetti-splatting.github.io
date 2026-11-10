struct _o1q {
  _o3f: vec4f,
  _o4r: vec4f,
  ab: vec4f,
  _oc2: vec4f,
  _olb: vec4u,
};
@group(0) @binding(0) var<storage, read> _oev: array<u32>;
@group(0) @binding(1) var<storage, read> _oae: array<f32>;
@group(0) @binding(2) var<storage, read> _oqz: array<f32>;
@group(0) @binding(3) var<storage, read> _o3d: array<f32>;
@group(0) @binding(4) var<storage, read> _oax: array<f32>;
@group(0) @binding(5) var<storage, read> _o83: array<u32>;
@group(0) @binding(6) var<storage, read_write> _ojo: array<_o1q>;
@group(0) @binding(7) var<storage, read_write> _oq0: array<u32>;
@group(0) @binding(8) var<uniform> _o5v: _oo;
@group(0) @binding(0) var<storage, read> _oa0: array<_o1q>;
@group(0) @binding(1) var<storage, read> _o9z: array<u32>;
@group(0) @binding(2) var<storage, read> _o9y: array<u32>;
@group(0) @binding(3) var<storage, read_write> _oez: array<u32>;
@group(0) @binding(4) var<storage, read_write> _of0: array<u32>;
@group(0) @binding(5) var<storage, read_write> _oiu: array<u32>;
@group(0) @binding(6) var<uniform> _o9x: _oo;
const _og: u32 = 16u;
const _oh: u32 = 16u;
const _o2e: f32 = 1e-3;
const _o1j: f32 = 0.0009770396478266127;
const _o18: f32 = 3.929278140e-03;
const _o2i: f32 = 0.1;
const _o2f: f32 = 12.0;
const _o2g: f32 = 2.2567583;
const _o2h: f32 = 0.08945;
const _o23: f32 = 1.7724538509055159;
const _oi: f32 = 0.02;
fn _orp(_oei: u32) -> f32 {
  return _o5v._ork[_oei >> 2u][_oei & 3u];
}
fn _oj9(_oei: u32) -> f32 {
  return _o5v._oju[_oei >> 2u][_oei & 3u];
}
fn _ojw(_oic: vec3f) -> vec4f {
  var _ohw: vec4f;
  for (var r = 0u; r < 4u; r = r + 1u) {
    _ohw[r] = _obd(_oic.z, _oj9(8u + r), _obd(_oic.x, _oj9(r), _oic.y * _oj9(4u + r))) + _oj9(12u + r);
  }
  return _ohw;
}
fn _orl(_oic: vec3f) -> f32 {
  return _obd(_oic.z, _orp(10u), _obd(_oic.x, _orp(2u), _oic.y * _orp(6u))) + _orp(14u);
}
fn _oh1(_or7: f32, size: u32) -> f32 {
  let _olz = f32(size);
  return _obd(_or7, _olz, _olz - 1.0) * 0.5;
}
fn _odb(x: f32, y: f32) -> f32 {
  let _o3n = abs(x);
  let _o3s = abs(y);
  let _o4o = max(_o3n, _o3s);
  let _onj = min(_o3n, _o3s);
  if (_onj == 0.0) {
    return _o4o;
  }
  return sqrt(_obd(_o4o, _o4o, _onj * _onj));
}
fn _ob1(_oqm: f32) -> f32 {
  let z = _oqm * _obd(_o2h, _oqm * _oqm, 1.0);
  return 1.0 / (1.0 + exp(-_o2g * z));
}
struct _o1a {
  _orc: f32,
  _onh: f32,
};
fn _oag(_of3: f32) -> _o1a {
  var _ob8: _o1a;
  if (!(_of3 < _o2f)) {
    _ob8._orc = 1.0;
    _ob8._onh = 0.0;
    return _ob8;
  }
  let x = 0.5 * _of3;
  let _olz = _ob1(x);
  _ob8._orc = 2.0 * _olz - 1.0;
  _ob8._onh = 2.0 * _o2g * _olz * (1.0 - _olz) * _obd(3.0 * _o2h, x * x, 1.0);
  return _ob8;
}
fn _oo6(_ok2: f32, _of7: f32, g: f32) -> f32 {
  let _of8 = _of7 / g;
  let _omy = _of7 < _o2i * g;
  var _or1: f32;
  if (_omy) {
    let _obv = g * g;
    let _oqe = _of7 * _of7 / 12.0;
    let _o9a = _obv - _oqe;
    _or1 = _obv * _obv / _o9a;
  } else if (_of8 < _o2f) {
    let x = 0.5 * _of8;
    let _o85 = _obd(_o2h, x * x, 1.0);
    let _ooz = exp(-_o2g * x * _o85);
    _or1 = _of7 * g * (1.0 + _ooz) / (_o23 * (1.0 - _ooz));
  } else {
    _or1 = _of7 * g / _o23;
  }
  return _ok2 * _or1;
}
struct _o1h {
  r: mat3x3f,
  _olz: vec3f,
  _ob4: f32,
  _og3: vec3f,
  _og4: vec3f,
  _o5s: f32,
  _o5t: f32,
  _o5u: f32,
};
fn _oew(_olr: u32, _oed: vec3f, _oeg: vec3f) -> _o1h {
  var _obl: _o1h;
  let _oqm = 8u * _olr;
  let w = _oqz[_oqm];
  let x = _oqz[_oqm + 1u];
  let y = _oqz[_oqm + 2u];
  let z = _oqz[_oqm + 3u];
  _obl.r = mat3x3f(
      vec3f(1.0 - 2.0 * (y * y + z * z), 2.0 * (x * y + w * z), 2.0 * (x * z - w * y)),
      vec3f(2.0 * (x * y - w * z), 1.0 - 2.0 * (x * x + z * z), 2.0 * (y * z + w * x)),
      vec3f(2.0 * (x * z + w * y), 2.0 * (y * z - w * x), 1.0 - 2.0 * (x * x + y * y)));
  _obl._olz = vec3f(_oqz[_oqm + 4u], _oqz[_oqm + 5u], _oqz[_oqm + 6u]);
  _obl._ob4 = _oqz[_oqm + 7u];
  _obl._o5s = 0.0;
  _obl._o5t = 0.0;
  _obl._o5u = 0.0;
  for (var _oe8 = 0u; _oe8 < 3u; _oe8 = _oe8 + 1u) {
    let _o7h = _obl.r[_oe8];
    let _oid = _oed.x * _o7h.x + _oed.y * _o7h.y + _oed.z * _o7h.z;
    let _oie = _oeg.x * _o7h.x + _oeg.y * _o7h.y + _oeg.z * _o7h.z;
    _obl._og3[_oe8] = _oid * _obl._olz[_oe8];
    _obl._og4[_oe8] = _oie * _obl._olz[_oe8];
    _obl._o5s = _obl._o5s + _obl._og3[_oe8] * _obl._og3[_oe8];
    _obl._o5t = _obl._o5t + _obl._og3[_oe8] * _obl._og4[_oe8];
    _obl._o5u = _obl._o5u + _obl._og4[_oe8] * _obl._og4[_oe8];
  }
  return _obl;
}
struct _o1 {
  _oqc: f32,
  _ol4: f32,
  _oh7: f32,
  _ojg: bool,
  _ogh: f32,
  _oak: bool,
};
fn _o3e(_obl: _o1h, _oed: vec3f, _oeg: vec3f, _ol1: vec3f,
                     _oaj: f32, _oap: f32) -> _o1 {
  var _ob0: _o1;
  let _om0 = _obl._olz.x;
  let _om1 = _obl._olz.y;
  let _om2 = _obl._olz.z;
  _ob0._oqc = 0.5 * _om0 * (_om1 + _om2);
  let _ohv = vec3f(_om1 * _om2, _om0 * _om2, _om0 * _om1);
  var _opo: vec3f;
  var _ofc = 0.0;
  for (var _oe8 = 0u; _oe8 < 3u; _oe8 = _oe8 + 1u) {
    let _o7h = _obl.r[_oe8];
    let _ol2 = _ol1.x * _o7h.x + _ol1.y * _o7h.y + _ol1.z * _o7h.z;
    _opo[_oe8] = _ol2 * _ohv[_oe8];
    _ofc = _obe(_ofc, abs(_opo[_oe8]));
  }
  let _odz = select(0.0, 1.0 / _ofc, _ofc > 0.0);
  var _oom = 0.0;
  for (var _oe8 = 0u; _oe8 < 3u; _oe8 = _oe8 + 1u) {
    let _omh = _opo[_oe8] * _odz;
    _oom = _oom + _omh * _omh;
  }
  let _olm = sqrt(_oom);
  _ob0._ol4 = _ofc * _olm;
  let _oh6 = vec3f(_oed.y * _oeg.z - _oed.z * _oeg.y,
                     _oed.z * _oeg.x - _oed.x * _oeg.z,
                     _oed.x * _oeg.y - _oed.y * _oeg.x);
  _ob0._oh7 = sqrt(_oh6.x * _oh6.x + _oh6.y * _oh6.y + _oh6.z * _oh6.z);
  _ob0._ojg = _om0 > 0.0 && _om1 > 0.0 && _om2 > 0.0;
  _ob0._ogh = 0.0;
  for (var _oe8 = 0u; _oe8 < 3u; _oe8 = _oe8 + 1u) {
    let _oa8 = -_oap * _obl._og3[_oe8] + _oaj * _obl._og4[_oe8];
    _ob0._ogh = _ob0._ogh + _oa8 * _oa8;
  }
  _ob0._oak = _oaj == 0.0 && _oap == 0.0;
  return _ob0;
}
fn _oo3(_ob0: _o1, g: f32, _o7r: vec3f, _opj: vec3f,
                     _oaj: f32, _oap: f32) -> f32 {
  let _osr = !_ob0._oak && !(_ob0._ogh > 0.0);
  let a = _ob0._oqc;
  let w = _ob0._ol4;
  let _ogw = _ob0._oh7;
  var _oqx: f32;
  if (_osr) {
    _oqx = 0.0;
  } else {
    let _oln = sqrt(_ob0._ogh);
    let _of3 = _oln / (g * _ogw * w);
    if (_of3 < _o2i) {
      let _of4 = _of3 * _of3;
      let _o8h = 1.0 - _of4 / 12.0;
      _oqx = a * g * g * _ogw / _o8h;
    } else {
      let _ob8 = _oag(_of3);
      _oqx = a * g * _oln / (_o23 * w * _ob8._orc);
    }
  }
  let _ooe = g * g - 1.0;
  let _o58 = _o7r.x + _ooe * _opj.x;
  let _o5b = _o7r.y + _ooe * _opj.y;
  let _o5i = _o7r.z + _ooe * _opj.z;
  let _o95 = _o58 * _o5i - _o5b * _o5b;
  let _o33 = _o5i * _oaj - _o5b * _oap;
  let _o34 = _o58 * _oap - _o5b * _oaj;
  let _ocn = _oaj * _o33 + _oap * _o34;
  let _ocm = select(0.0, _ocn, _ocn > 0.0);
  let _of6 = sqrt(_ocm / _o95);
  var _ob5: f32;
  if (_of6 < _o2i) {
    let _oii = 1.0 - _ocm / (12.0 * _o95);
    _ob5 = _oii * inverseSqrt(_o95);
  } else {
    let _ob9 = _oag(_of6);
    _ob5 = _o23 * _ob9._orc * inverseSqrt(_ocm);
  }
  return _oqx * _ob5;
}
struct _oy {
  _ohp: bool,
  a: vec4f,
  b: vec4f,
};
fn _o79(_oik: vec4f, _oiw: vec4f) -> _oy {
  var _olg: _oy;
  _olg._ohp = false;
  let _o8h = _oiw - _oik;
  var _op0 = 0.0;
  var _op1 = 1.0;
  var _o7g = array<f32, 5>(_oik.w - _o2e, _oik.x + _oik.w, _oik.w - _oik.x,
                           _oik.y + _oik.w, _oik.w - _oik.y);
  var _o62 = array<f32, 5>(_o8h.w, _o8h.x + _o8h.w, _o8h.w - _o8h.x, _o8h.y + _o8h.w, _o8h.w - _o8h.y);
  var _o88 = false;
  var _o86 = 0.0;
  var _o87 = 1.0;
  for (var _oei = 0u; _oei < 5u; _oei = _oei + 1u) {
    if (_o62[_oei] == 0.0) {
      if (_o7g[_oei] < 0.0) {
        _o88 = true;
        break;
      }
      continue;
    }
    let _oq5 = -_o7g[_oei] / _o62[_oei];
    if (_o62[_oei] > 0.0) {
      _o86 = _obe(_o86, _oq5);
    } else {
      _o87 = _obf(_o87, _oq5);
    }
  }
  if (_o88 || _o86 > _o87) {
    return _olg;
  }
  if (_o62[0] == 0.0) {
    if (_o7g[0] < 0.0) {
      return _olg;
    }
  } else {
    let _oq5 = -_o7g[0] / _o62[0];
    if (_o62[0] > 0.0) {
      _op0 = _obe(_op0, _oq5);
    } else {
      _op1 = _obf(_op1, _oq5);
    }
  }
  if (_op0 > _op1) {
    return _olg;
  }
  for (var _o56 = 0u; _o56 < 4u; _o56 = _o56 + 1u) {
    _olg.a[_o56] = _obd(_o8h[_o56], _op0, _oik[_o56]);
    _olg.b[_o56] = _obd(_o8h[_o56], _op1, _oik[_o56]);
  }
  _olg._ohp = true;
  return _olg;
}
fn _opy(a: vec2f, b: vec2f, _oij: f32, _oih: f32, _oqj: u32,
                 _os7: u32, _oqh: u32, _oqi: u32) -> vec3u {
  let _o9g = b - a;
  let _ofg = _odb(_o9g.x, _o9g.y);
  let _on3 = _ofg < 1e-4;
  let _om8 = select(_o9g, vec2f(1.0, 0.0), _on3);
  let _om9 = select(_ofg, 1.0, _on3);
  let _oqt = vec2f(-_om8.y / _om9, _om8.x / _om9);
  let _oqs = vec2f(_om8.x / _om9, _om8.y / _om9);
  let _oji = _oij + _oi;
  let _oik = _oih + _oi;
  var _o56: array<vec2f, 4>;
  _o56[3] = vec2f(_obd(-_oqs.x, _oik, _obd(_oqt.x, _oji, a.x)),
               _obd(-_oqs.y, _oik, _obd(_oqt.y, _oji, a.y)));
  _o56[0] = vec2f(_obd(-_oqs.x, _oik, _obd(-_oqt.x, _oji, a.x)),
               _obd(-_oqs.y, _oik, _obd(-_oqt.y, _oji, a.y)));
  _o56[2] = vec2f(_obd(_oqs.x, _oik, _obd(_oqt.x, _oji, b.x)),
               _obd(_oqs.y, _oik, _obd(_oqt.y, _oji, b.y)));
  _o56[1] = vec2f(_obd(_oqs.x, _oik, _obd(-_oqt.x, _oji, b.x)),
               _obd(_oqs.y, _oik, _obd(-_oqt.y, _oji, b.y)));
  let _osn = f32(_oqj * _oh);
  let _osm = f32(_oqj * _oh + (_oh - 1u));
  var _osj = 3.4e38;
  var _osh = -3.4e38;
  for (var _odc = 0u; _odc < 4u; _odc = _odc + 1u) {
    let _oid = _o56[_odc];
    let _oie = _o56[(_odc + 1u) & 3u];
    if (_oid.y >= _osn && _oid.y <= _osm) {
      _osj = _obf(_osj, _oid.x);
      _osh = _obe(_osh, _oid.x);
    }
    let _oa2 = _oie.y - _oid.y;
    if (_oa2 != 0.0) {
      var _ooz = (_osn - _oid.y) / _oa2;
      if (_ooz > 0.0 && _ooz < 1.0) {
        let x = _obd(_ooz, _oie.x - _oid.x, _oid.x);
        _osj = _obf(_osj, x);
        _osh = _obe(_osh, x);
      }
      _ooz = (_osm - _oid.y) / _oa2;
      if (_ooz > 0.0 && _ooz < 1.0) {
        let x = _obd(_ooz, _oie.x - _oid.x, _oid.x);
        _osj = _obf(_osj, x);
        _osh = _obe(_osh, x);
      }
    }
  }
  if (!(_osh >= _osj)) {
    return vec3u(0u, 0u, 0u);
  }
  let _orw = f32(_os7 - 1u);
  let _osk = _obf(_obe(_osj, 0.0), _orw);
  let _osi = _obf(_obe(_osh, 0.0), _orw);
  let _oov = max(i32(_oqh), i32(floor(_osk * 0.0625)));
  let _oow = min(i32(_oqi), i32(floor(_osi * 0.0625)) + 1);
  if (_oow > _oov) {
    return vec3u(u32(_oov), u32(_oow), 1u);
  }
  return vec3u(0u, 0u, 0u);
}
@compute @workgroup_size(256)
fn preprocess(@builtin(local_invocation_index) _ofl: u32,
              @builtin(workgroup_id) _os6: vec3u,
              @builtin(num_workgroups) _ohc: vec3u) {
  let _odf = _ofq(_os6, _ohc) * _o2j + _ofl;
  if (_odf >= _o83[_o1w]) {
    return;
  }
  let _onn = _oev[_odf];
  _oq0[_odf] = 0u;
  _ojo[_odf]._oc2 = vec4f(0.0, 0.0, 0.0, 0.0);
  let _o3c = _o3d[_onn] * _oax[_onn];
  let _ohg = 6u * _onn;
  let _oil = vec3f(_oae[_ohg], _oae[_ohg + 1u], _oae[_ohg + 2u]);
  let _oix = vec3f(_oae[_ohg + 3u], _oae[_ohg + 4u], _oae[_ohg + 5u]);
  let _ofp = vec3f((_oil.x + _oix.x) * 0.5, (_oil.y + _oix.y) * 0.5, (_oil.z + _oix.z) * 0.5);
  let _o91 = _orl(_ofp);
  let _o78 = _o79(_ojw(_oil), _ojw(_oix));
  if (!_o78._ohp) {
    return;
  }
  let _os7 = _o5v._os7;
  let _ocy = _o5v._ocy;
  let _o2w = vec2f(_oh1(_o78.a.x / _o78.a.w, _os7), _oh1(_o78.a.y / _o78.a.w, _ocy));
  let _o3y = vec2f(_oh1(_o78.b.x / _o78.b.w, _os7), _oh1(_o78.b.y / _o78.b.w, _ocy));
  let _o4k = _o5v._o4k;
  let _o63 = _ojw(_ofp);
  var _oms = _o63.w > _o2e && _oe5(_o63.w);
  let _oma = select(1.0, _o63.w, _oms);
  let _odw = 1.0 / (_oma * _oma);
  let _ocv = 0.5 * f32(_os7);
  let _ocs = 0.5 * f32(_ocy);
  let _oed = vec3f(_ocv * (_oma * _oj9(0u) - _o63.x * _oj9(3u)) * _odw,
                 _ocv * (_oma * _oj9(4u) - _o63.x * _oj9(7u)) * _odw,
                 _ocv * (_oma * _oj9(8u) - _o63.x * _oj9(11u)) * _odw);
  let _oeg = vec3f(_ocs * (_oma * _oj9(1u) - _o63.y * _oj9(3u)) * _odw,
                 _ocs * (_oma * _oj9(5u) - _o63.y * _oj9(7u)) * _odw,
                 _ocs * (_oma * _oj9(9u) - _o63.y * _oj9(11u)) * _odw);
  let _ogn = vec2f(_oh1(_o63.x / _oma, _os7),
                           _oh1(_o63.y / _oma, _ocy));
  let _obl = _oew(_onn, _oed, _oeg);
  let _o5n = _obl._o5s + _obl._ob4 * _o9r(_oed, _oed);
  let _o5o = _obl._o5t + _obl._ob4 * _o9r(_oed, _oeg);
  let _o5p = _obl._o5u + _obl._ob4 * _o9r(_oeg, _oeg);
  let _o58 = _o5n + _o4k;
  let _o5b = _o5o;
  let _o5i = _o5p + _o4k;
  let _oky = _oma / _o78.a.w;
  let _okz = _oma / _o78.b.w;
  let _o97 = _o58 * _o5i - _o5b * _o5b;
  _oms = _oms && _o97 > 0.0 && _oe5(_o97);
  let _ods = select(0.0, 1.0 / _o97, _oms);
  let _o6d = _o3y - _o2w;
  let _o33 = _o5i * _o6d.x - _o5b * _o6d.y;
  let _o34 = _o58 * _o6d.y - _o5b * _o6d.x;
  let _ocl = _o6d.x * _o33 + _o6d.y * _o34;
  let _oci = _obe(_ocl * _ods, 0.0);
  let _of3 = sqrt(_oci);
  let _odt = select(0.0, 1.0 / _ocl, _oci > 1e-8);
  let _ojc = !(_of3 > _o2i) || !(_odt > 0.0);
  let _o5x = _o5v._o5y.xyz;
  let _ol0 = _ofp - _o5x;
  let _oe1 = inverseSqrt(_o9r(_ol0, _ol0));
  let _ol1 = _ol0 * _oe1;
  let _ob0 = _o3e(_obl, _oed, _oeg, _ol1, _o6d.x, _o6d.y);
  let _o7r = vec3f(_o58, _o5b, _o5i);
  let _opj = vec3f(_o5n, _o5o, _o5p);
  let _olh = _obe(_o3c, 0.0);
  let _ok2 = _olh * _ob0._oqc * _ob0._oh7;
  let _of7 = sqrt(_ob0._ogh) / (_ob0._oh7 * _ob0._ol4);
  let _oel = _oo3(_ob0, _oky, _o7r, _opj, _o6d.x, _o6d.y);
  let _oen = _oo3(_ob0, 1.0, _o7r, _opj, _o6d.x, _o6d.y);
  let _oem = _oo3(_ob0, _okz, _o7r, _opj, _o6d.x, _o6d.y);
  let _oiy = _olh * _obe(_oel, _obe(_oen, _oem));
  let _oqp = _oo6(_ok2, _of7, _oky);
  let _oqr = _oo6(_ok2, _of7, 1.0);
  let _oqq = _oo6(_ok2, _of7, _okz);
  _oms = _oms && _ob0._ojg && _oe5(_of7)
      && _oe5(_oqp) && _oe5(_oqr) && _oe5(_oqq);
  if (!_oms) {
    return;
  }
  let _o64 = _ogn;
  if (_oiy < _o1j) {
    return;
  }
  let _o8d = _obe(log(_obe(_oiy, _o18) / _o18), 1e-6);
  let _o9g = _o3y - _o2w;
  let _ofg = _odb(_o9g.x, _o9g.y);
  let _on3 = _ofg < 1e-4;
  let _om8 = select(_o9g, vec2f(1.0, 0.0), _on3);
  let _om9 = select(_ofg, 1.0, _on3);
  let _oqt = vec2f(-_om8.y / _om9, _om8.x / _om9);
  let _oqs = vec2f(_om8.x / _om9, _om8.y / _om9);
  let _oei = sqrt(_o8d);
  let _obx = _obe(_oky, _okz);
  let _oof = _obe(_obx * _obx - 1.0, 0.0);
  let _o7d = _o58 + _oof * _o5n;
  let _o7e = _o5b + _oof * _o5o;
  let _o7f = _o5i + _oof * _o5p;
  let _ore = _oqt.x * (_o7d * _oqt.x + _o7e * _oqt.y)
               + _oqt.y * (_o7e * _oqt.x + _o7f * _oqt.y);
  let _ord = _oqs.x * (_o7d * _oqs.x + _o7e * _oqs.y)
                + _oqs.y * (_o7e * _oqs.x + _o7f * _oqs.y);
  var _oij = _oei * sqrt(_obe(_ore, 1e-8));
  var _oih: f32;
  if (_ojc) {
    _oih = _oei * sqrt(_obe(_ord, 1e-8));
  } else {
    let x = _oqt.x * (_o7d * _oqs.x + _o7e * _oqs.y)
          + _oqt.y * (_o7e * _oqs.x + _o7f * _oqs.y);
    let _o95 = _o7d * _o7f - _o7e * _o7e;
    _oih = _oei * sqrt(_obe(_ord, 1e-8)
        + 2.0 * abs(x) * sqrt(_obe(_o95, 0.0)) / _obe(_ore, 1e-8));
  }
  let _o9b = _odb(f32(_os7), f32(_ocy));
  _oij = _obf(_oij, _o9b);
  _oih = _obf(_oih, _o9b);
  var _oka: array<vec2f, 4>;
  _oka[3] = vec2f(_obd(-_oqs.x, _oih, _obd(_oqt.x, _oij, _o2w.x)),
                  _obd(-_oqs.y, _oih, _obd(_oqt.y, _oij, _o2w.y)));
  _oka[0] = vec2f(_obd(-_oqs.x, _oih, _obd(-_oqt.x, _oij, _o2w.x)),
                  _obd(-_oqs.y, _oih, _obd(-_oqt.y, _oij, _o2w.y)));
  _oka[2] = vec2f(_obd(_oqs.x, _oih, _obd(_oqt.x, _oij, _o3y.x)),
                  _obd(_oqs.y, _oih, _obd(_oqt.y, _oij, _o3y.y)));
  _oka[1] = vec2f(_obd(_oqs.x, _oih, _obd(-_oqt.x, _oij, _o3y.x)),
                  _obd(_oqs.y, _oih, _obd(-_oqt.y, _oij, _o3y.y)));
  var _ogq = _oka[0].x;
  var _ogb = _oka[0].x;
  var _ogs = _oka[0].y;
  var _ogd = _oka[0].y;
  var _og5 = 0.0;
  for (var _odc = 0u; _odc < 4u; _odc = _odc + 1u) {
    let _o7s = _oka[_odc];
    if (!_oe5(_o7s.x) || !_oe5(_o7s.y)) {
      return;
    }
    _ogq = _obf(_ogq, _o7s.x);
    _ogb = _obe(_ogb, _o7s.x);
    _ogs = _obf(_ogs, _o7s.y);
    _ogd = _obe(_ogd, _o7s.y);
    _og5 = _obe(_og5, _odb(_o7s.x - _o64.x, _o7s.y - _o64.y));
  }
  let _os5 = f32(_os7 - 1u);
  let _od0 = f32(_ocy - 1u);
  let _ogr = _obf(_obe(_ogq - _oi, 0.0), _os5);
  let _ogc = _obf(_obe(_ogb + _oi, 0.0), _os5);
  let _ogt = _obf(_obe(_ogs - _oi, 0.0), _od0);
  let _oge = _obf(_obe(_ogd + _oi, 0.0), _od0);
  let _ocf = i32(_o5v._oq1);
  let _ocg = i32(_o5v._oq2);
  let _oqh = max(0, min(_ocf, i32(floor(_ogr * 0.0625))));
  let _oqk = max(0, min(_ocg, i32(floor(_ogt * 0.0625))));
  let _oqi = max(0, min(_ocf, i32(floor(_ogc * 0.0625)) + 1));
  let _oql = max(0, min(_ocg, i32(floor(_oge * 0.0625)) + 1));
  if (_oqh >= _oqi || _oqk >= _oql) {
    return;
  }
  let _okp = f32(max(_os7, _ocy));
  let _og6 = max(1, i32(ceil(_obf(_og5, _okp))));
  var _ojm: _o1q;
  _ojm._o3f = vec4f(_o5n, _o5o, _o5p, select(_oky, -abs(_oky), _ojc));
  _ojm._o4r = vec4f(_ok2, _of7, _o8d, _okz);
  _ojm.ab = vec4f(_o2w, _o3y);
  _ojm._oc2 = vec4f(_oij, _oih, _o91, f32(_og6));
  _ojm._olb = vec4u(u32(_oqh), u32(_oqk), u32(_oqi), u32(_oql));
  _ojo[_odf] = _ojm;
  var _ogz = 0u;
  for (var _oqj = u32(_oqk); _oqj < u32(_oql); _oqj = _oqj + 1u) {
    let _onq = _opy(_o2w, _o3y, _oij, _oih, _oqj, _os7, u32(_oqh), u32(_oqi));
    if (_onq.z != 0u) {
      _ogz = _ogz + (_onq.y - _onq.x);
    }
  }
  _oq0[_odf] = _ogz;
}
fn _o9r(x: vec3f, y: vec3f) -> f32 {
  return x.x * y.x + x.y * y.y + x.z * y.z;
}
@compute @workgroup_size(256)
fn duplicate_keys(@builtin(local_invocation_index) _ofl: u32,
                  @builtin(workgroup_id) _os6: vec3u,
                  @builtin(num_workgroups) _ohc: vec3u) {
  let _odf = _ofq(_os6, _ohc) * _o2j + _ofl;
  if (_odf >= _o9y[_o1w]) {
    return;
  }
  let _ojm = _oa0[_odf];
  if (!(_ojm._oc2.w > 0.0)) {
    return;
  }
  var off = 0u;
  if (_odf > 0u) {
    off = _o9z[_odf - 1u];
  }
  let _o2w = _ojm.ab.xy;
  let _o3y = _ojm.ab.zw;
  let _o92 = bitcast<u32>(_ojm._oc2.z);
  let _o60 = _o9x._o60;
  for (var y = _ojm._olb.y; y < _ojm._olb.w; y = y + 1u) {
    let _onq = _opy(_o2w, _o3y, _ojm._oc2.x, _ojm._oc2.y, y,
                             _o9x._os7, _ojm._olb.x, _ojm._olb.z);
    if (_onq.z == 0u) {
      continue;
    }
    for (var x = _onq.x; x < _onq.y; x = x + 1u) {
      if (off < _o60) {
        _oez[off] = y * _o9x._oq1 + x;
        _of0[off] = _o92;
        _oiu[off] = _odf;
      }
      off = off + 1u;
    }
  }
}
