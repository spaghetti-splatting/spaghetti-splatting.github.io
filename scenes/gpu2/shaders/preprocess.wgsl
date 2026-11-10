struct _o1o {
  _o3b: vec4f,
  _o4m: vec4f,
  ab: vec4f,
  _obk: vec4f,
  _okm: vec4u,
};
@group(0) @binding(0) var<storage, read> _oe8: array<u32>;
@group(0) @binding(1) var<storage, read> _o9x: array<f32>;
@group(0) @binding(2) var<storage, read> _oq5: array<f32>;
@group(0) @binding(3) var<storage, read> _o39: array<f32>;
@group(0) @binding(4) var<storage, read> _oag: array<f32>;
@group(0) @binding(5) var<storage, read> _o7m: array<u32>;
@group(0) @binding(6) var<storage, read_write> _oiz: array<_o1o>;
@group(0) @binding(7) var<storage, read_write> _op7: array<u32>;
@group(0) @binding(8) var<uniform> _o5o: _oo;
@group(0) @binding(0) var<storage, read> _o9j: array<_o1o>;
@group(0) @binding(1) var<storage, read> _o9i: array<u32>;
@group(0) @binding(2) var<storage, read> _o9h: array<u32>;
@group(0) @binding(3) var<storage, read_write> _oec: array<u32>;
@group(0) @binding(4) var<storage, read_write> _oed: array<u32>;
@group(0) @binding(5) var<storage, read_write> _oi5: array<u32>;
@group(0) @binding(6) var<uniform> _o9g: _oo;
const _og: u32 = 16u;
const _oh: u32 = 16u;
const _o2c: f32 = 1e-3;
const _o1h: f32 = 0.0009770396478266127;
const _o16: f32 = 3.929278140e-03;
const _o2g: f32 = 0.1;
const _o2d: f32 = 12.0;
const _o2e: f32 = 2.2567583;
const _o2f: f32 = 0.08945;
const _o21: f32 = 1.7724538509055159;
const _oi: f32 = 0.02;
fn _oqv(_odx: u32) -> f32 {
  return _o5o._oqq[_odx >> 2u][_odx & 3u];
}
fn _oik(_odx: u32) -> f32 {
  return _o5o._oj5[_odx >> 2u][_odx & 3u];
}
fn _oj7(_ohn: vec3f) -> vec4f {
  var _oh7: vec4f;
  for (var r = 0u; r < 4u; r = r + 1u) {
    _oh7[r] = _oav(_ohn.z, _oik(8u + r), _oav(_ohn.x, _oik(r), _ohn.y * _oik(4u + r))) + _oik(12u + r);
  }
  return _oh7;
}
fn _oqr(_ohn: vec3f) -> f32 {
  return _oav(_ohn.z, _oqv(10u), _oav(_ohn.x, _oqv(2u), _ohn.y * _oqv(6u))) + _oqv(14u);
}
fn _ogc(_oqd: f32, size: u32) -> f32 {
  let _ola = f32(size);
  return _oav(_oqd, _ola, _ola - 1.0) * 0.5;
}
fn _ocq(x: f32, y: f32) -> f32 {
  let _o3j = abs(x);
  let _o3o = abs(y);
  let _o4j = max(_o3j, _o3o);
  let _omr = min(_o3j, _o3o);
  if (_omr == 0.0) {
    return _o4j;
  }
  return sqrt(_oav(_o4j, _o4j, _omr * _omr));
}
fn _oak(_ops: f32) -> f32 {
  let z = _ops * _oav(_o2f, _ops * _ops, 1.0);
  return 1.0 / (1.0 + exp(-_o2e * z));
}
struct _o18 {
  _oqi: f32,
  _omp: f32,
};
fn _o9z(_oeg: f32) -> _o18 {
  var _oar: _o18;
  if (!(_oeg < _o2d)) {
    _oar._oqi = 1.0;
    _oar._omp = 0.0;
    return _oar;
  }
  let x = 0.5 * _oeg;
  let _ola = _oak(x);
  _oar._oqi = 2.0 * _ola - 1.0;
  _oar._omp = 2.0 * _o2e * _ola * (1.0 - _ola) * _oav(3.0 * _o2f, x * x, 1.0);
  return _oar;
}
fn _one(_ojd: f32, _oek: f32, g: f32) -> f32 {
  let _oel = _oek / g;
  let _om8 = _oek < _o2g * g;
  var _oq7: f32;
  if (_om8) {
    let _obd = g * g;
    let _opk = _oek * _oek / 12.0;
    let _o8t = _obd - _opk;
    _oq7 = _obd * _obd / _o8t;
  } else if (_oel < _o2d) {
    let x = 0.5 * _oel;
    let _o7o = _oav(_o2f, x * x, 1.0);
    let _oo6 = exp(-_o2e * x * _o7o);
    _oq7 = _oek * g * (1.0 + _oo6) / (_o21 * (1.0 - _oo6));
  } else {
    _oq7 = _oek * g / _o21;
  }
  return _ojd * _oq7;
}
struct _o1f {
  r: mat3x3f,
  _ola: vec3f,
  _oan: f32,
  _ofg: vec3f,
  _ofh: vec3f,
  _o5l: f32,
  _o5m: f32,
  _o5n: f32,
};
fn _oe9(_ol2: u32, _ods: vec3f, _odv: vec3f) -> _o1f {
  var _ob3: _o1f;
  let _ops = 8u * _ol2;
  let w = _oq5[_ops];
  let x = _oq5[_ops + 1u];
  let y = _oq5[_ops + 2u];
  let z = _oq5[_ops + 3u];
  _ob3.r = mat3x3f(
      vec3f(1.0 - 2.0 * (y * y + z * z), 2.0 * (x * y + w * z), 2.0 * (x * z - w * y)),
      vec3f(2.0 * (x * y - w * z), 1.0 - 2.0 * (x * x + z * z), 2.0 * (y * z + w * x)),
      vec3f(2.0 * (x * z + w * y), 2.0 * (y * z - w * x), 1.0 - 2.0 * (x * x + y * y)));
  _ob3._ola = vec3f(_oq5[_ops + 4u], _oq5[_ops + 5u], _oq5[_ops + 6u]);
  _ob3._oan = _oq5[_ops + 7u];
  _ob3._o5l = 0.0;
  _ob3._o5m = 0.0;
  _ob3._o5n = 0.0;
  for (var _odn = 0u; _odn < 3u; _odn = _odn + 1u) {
    let _o70 = _ob3.r[_odn];
    let _oho = _ods.x * _o70.x + _ods.y * _o70.y + _ods.z * _o70.z;
    let _ohp = _odv.x * _o70.x + _odv.y * _o70.y + _odv.z * _o70.z;
    _ob3._ofg[_odn] = _oho * _ob3._ola[_odn];
    _ob3._ofh[_odn] = _ohp * _ob3._ola[_odn];
    _ob3._o5l = _ob3._o5l + _ob3._ofg[_odn] * _ob3._ofg[_odn];
    _ob3._o5m = _ob3._o5m + _ob3._ofg[_odn] * _ob3._ofh[_odn];
    _ob3._o5n = _ob3._o5n + _ob3._ofh[_odn] * _ob3._ofh[_odn];
  }
  return _ob3;
}
struct _o1 {
  _opi: f32,
  _okf: f32,
  _ogi: f32,
  _oir: bool,
  _oft: f32,
  _oa3: bool,
};
fn _o3a(_ob3: _o1f, _ods: vec3f, _odv: vec3f, _okc: vec3f,
                     _oa2: f32, _oa8: f32) -> _o1 {
  var _oaj: _o1;
  let _olb = _ob3._ola.x;
  let _olc = _ob3._ola.y;
  let _old = _ob3._ola.z;
  _oaj._opi = 0.5 * _olb * (_olc + _old);
  let _oh6 = vec3f(_olc * _old, _olb * _old, _olb * _olc);
  var _oov: vec3f;
  var _oep = 0.0;
  for (var _odn = 0u; _odn < 3u; _odn = _odn + 1u) {
    let _o70 = _ob3.r[_odn];
    let _okd = _okc.x * _o70.x + _okc.y * _o70.y + _okc.z * _o70.z;
    _oov[_odn] = _okd * _oh6[_odn];
    _oep = _oaw(_oep, abs(_oov[_odn]));
  }
  let _ode = select(0.0, 1.0 / _oep, _oep > 0.0);
  var _ont = 0.0;
  for (var _odn = 0u; _odn < 3u; _odn = _odn + 1u) {
    let _olr = _oov[_odn] * _ode;
    _ont = _ont + _olr * _olr;
  }
  let _okx = sqrt(_ont);
  _oaj._okf = _oep * _okx;
  let _ogh = vec3f(_ods.y * _odv.z - _ods.z * _odv.y,
                     _ods.z * _odv.x - _ods.x * _odv.z,
                     _ods.x * _odv.y - _ods.y * _odv.x);
  _oaj._ogi = sqrt(_ogh.x * _ogh.x + _ogh.y * _ogh.y + _ogh.z * _ogh.z);
  _oaj._oir = _olb > 0.0 && _olc > 0.0 && _old > 0.0;
  _oaj._oft = 0.0;
  for (var _odn = 0u; _odn < 3u; _odn = _odn + 1u) {
    let _o9r = -_oa8 * _ob3._ofg[_odn] + _oa2 * _ob3._ofh[_odn];
    _oaj._oft = _oaj._oft + _o9r * _o9r;
  }
  _oaj._oa3 = _oa2 == 0.0 && _oa8 == 0.0;
  return _oaj;
}
fn _onb(_oaj: _o1, g: f32, _o7a: vec3f, _ooq: vec3f,
                     _oa2: f32, _oa8: f32) -> f32 {
  let _orv = !_oaj._oa3 && !(_oaj._oft > 0.0);
  let a = _oaj._opi;
  let w = _oaj._okf;
  let _og7 = _oaj._ogi;
  var _oq3: f32;
  if (_orv) {
    _oq3 = 0.0;
  } else {
    let _oky = sqrt(_oaj._oft);
    let _oeg = _oky / (g * _og7 * w);
    if (_oeg < _o2g) {
      let _oeh = _oeg * _oeg;
      let _o80 = 1.0 - _oeh / 12.0;
      _oq3 = a * g * g * _og7 / _o80;
    } else {
      let _oar = _o9z(_oeg);
      _oq3 = a * g * _oky / (_o21 * w * _oar._oqi);
    }
  }
  let _onl = g * g - 1.0;
  let _o51 = _o7a.x + _onl * _ooq.x;
  let _o54 = _o7a.y + _onl * _ooq.y;
  let _o5b = _o7a.z + _onl * _ooq.z;
  let _o8o = _o51 * _o5b - _o54 * _o54;
  let _o31 = _o5b * _oa2 - _o54 * _oa8;
  let _o32 = _o51 * _oa8 - _o54 * _oa2;
  let _oc5 = _oa2 * _o31 + _oa8 * _o32;
  let _oc4 = select(0.0, _oc5, _oc5 > 0.0);
  let _oej = sqrt(_oc4 / _o8o);
  var _oao: f32;
  if (_oej < _o2g) {
    let _oht = 1.0 - _oc4 / (12.0 * _o8o);
    _oao = _oht * inverseSqrt(_o8o);
  } else {
    let _oas = _o9z(_oej);
    _oao = _o21 * _oas._oqi * inverseSqrt(_oc4);
  }
  return _oq3 * _oao;
}
struct _ow {
  _oh0: bool,
  a: vec4f,
  b: vec4f,
};
fn _o6s(_ohv: vec4f, _oi7: vec4f) -> _ow {
  var _okr: _ow;
  _okr._oh0 = false;
  let _o80 = _oi7 - _ohv;
  var _oo7 = 0.0;
  var _oo8 = 1.0;
  var _o6z = array<f32, 5>(_ohv.w - _o2c, _ohv.x + _ohv.w, _ohv.w - _ohv.x,
                           _ohv.y + _ohv.w, _ohv.w - _ohv.y);
  var _o5v = array<f32, 5>(_o80.w, _o80.x + _o80.w, _o80.w - _o80.x, _o80.y + _o80.w, _o80.w - _o80.y);
  var _o7r = false;
  var _o7p = 0.0;
  var _o7q = 1.0;
  for (var _odx = 0u; _odx < 5u; _odx = _odx + 1u) {
    if (_o5v[_odx] == 0.0) {
      if (_o6z[_odx] < 0.0) {
        _o7r = true;
        break;
      }
      continue;
    }
    let _opb = -_o6z[_odx] / _o5v[_odx];
    if (_o5v[_odx] > 0.0) {
      _o7p = _oaw(_o7p, _opb);
    } else {
      _o7q = _oax(_o7q, _opb);
    }
  }
  if (_o7r || _o7p > _o7q) {
    return _okr;
  }
  if (_o5v[0] == 0.0) {
    if (_o6z[0] < 0.0) {
      return _okr;
    }
  } else {
    let _opb = -_o6z[0] / _o5v[0];
    if (_o5v[0] > 0.0) {
      _oo7 = _oaw(_oo7, _opb);
    } else {
      _oo8 = _oax(_oo8, _opb);
    }
  }
  if (_oo7 > _oo8) {
    return _okr;
  }
  for (var _o4z = 0u; _o4z < 4u; _o4z = _o4z + 1u) {
    _okr.a[_o4z] = _oav(_o80[_o4z], _oo7, _ohv[_o4z]);
    _okr.b[_o4z] = _oav(_o80[_o4z], _oo8, _ohv[_o4z]);
  }
  _okr._oh0 = true;
  return _okr;
}
fn _op5(a: vec2f, b: vec2f, _ohu: f32, _ohs: f32, _opp: u32,
                 _ord: u32, _opn: u32, _opo: u32) -> vec3u {
  let _o8z = b - a;
  let _oet = _ocq(_o8z.x, _o8z.y);
  let _omd = _oet < 1e-4;
  let _olj = select(_o8z, vec2f(1.0, 0.0), _omd);
  let _olk = select(_oet, 1.0, _omd);
  let _opz = vec2f(-_olj.y / _olk, _olj.x / _olk);
  let _opy = vec2f(_olj.x / _olk, _olj.y / _olk);
  let _oit = _ohu + _oi;
  let _ohv = _ohs + _oi;
  var _o4z: array<vec2f, 4>;
  _o4z[3] = vec2f(_oav(-_opy.x, _ohv, _oav(_opz.x, _oit, a.x)),
               _oav(-_opy.y, _ohv, _oav(_opz.y, _oit, a.y)));
  _o4z[0] = vec2f(_oav(-_opy.x, _ohv, _oav(-_opz.x, _oit, a.x)),
               _oav(-_opy.y, _ohv, _oav(-_opz.y, _oit, a.y)));
  _o4z[2] = vec2f(_oav(_opy.x, _ohv, _oav(_opz.x, _oit, b.x)),
               _oav(_opy.y, _ohv, _oav(_opz.y, _oit, b.y)));
  _o4z[1] = vec2f(_oav(_opy.x, _ohv, _oav(-_opz.x, _oit, b.x)),
               _oav(_opy.y, _ohv, _oav(-_opz.y, _oit, b.y)));
  let _ors = f32(_opp * _oh);
  let _orr = f32(_opp * _oh + (_oh - 1u));
  var _oro = 3.4e38;
  var _orm = -3.4e38;
  for (var _ocr = 0u; _ocr < 4u; _ocr = _ocr + 1u) {
    let _oho = _o4z[_ocr];
    let _ohp = _o4z[(_ocr + 1u) & 3u];
    if (_oho.y >= _ors && _oho.y <= _orr) {
      _oro = _oax(_oro, _oho.x);
      _orm = _oaw(_orm, _oho.x);
    }
    let _o9l = _ohp.y - _oho.y;
    if (_o9l != 0.0) {
      var _oo6 = (_ors - _oho.y) / _o9l;
      if (_oo6 > 0.0 && _oo6 < 1.0) {
        let x = _oav(_oo6, _ohp.x - _oho.x, _oho.x);
        _oro = _oax(_oro, x);
        _orm = _oaw(_orm, x);
      }
      _oo6 = (_orr - _oho.y) / _o9l;
      if (_oo6 > 0.0 && _oo6 < 1.0) {
        let x = _oav(_oo6, _ohp.x - _oho.x, _oho.x);
        _oro = _oax(_oro, x);
        _orm = _oaw(_orm, x);
      }
    }
  }
  if (!(_orm >= _oro)) {
    return vec3u(0u, 0u, 0u);
  }
  let _or2 = f32(_ord - 1u);
  let _orp = _oax(_oaw(_oro, 0.0), _or2);
  let _orn = _oax(_oaw(_orm, 0.0), _or2);
  let _oo2 = max(i32(_opn), i32(floor(_orp * 0.0625)));
  let _oo3 = min(i32(_opo), i32(floor(_orn * 0.0625)) + 1);
  if (_oo3 > _oo2) {
    return vec3u(u32(_oo2), u32(_oo3), 1u);
  }
  return vec3u(0u, 0u, 0u);
}
@compute @workgroup_size(256)
fn preprocess(@builtin(local_invocation_index) _oey: u32,
              @builtin(workgroup_id) _orc: vec3u,
              @builtin(num_workgroups) _ogn: vec3u) {
  let _ocu = _of3(_orc, _ogn) * _o2h + _oey;
  if (_ocu >= _o7m[_o1u]) {
    return;
  }
  let _omv = _oe8[_ocu];
  _op7[_ocu] = 0u;
  _oiz[_ocu]._obk = vec4f(0.0, 0.0, 0.0, 0.0);
  let _o38 = _o39[_omv] * _oag[_omv];
  let _ogr = 6u * _omv;
  let _ohw = vec3f(_o9x[_ogr], _o9x[_ogr + 1u], _o9x[_ogr + 2u]);
  let _oi8 = vec3f(_o9x[_ogr + 3u], _o9x[_ogr + 4u], _o9x[_ogr + 5u]);
  let _of2 = vec3f((_ohw.x + _oi8.x) * 0.5, (_ohw.y + _oi8.y) * 0.5, (_ohw.z + _oi8.z) * 0.5);
  let _o8k = _oqr(_of2);
  let _o6r = _o6s(_oj7(_ohw), _oj7(_oi8));
  if (!_o6r._oh0) {
    return;
  }
  let _ord = _o5o._ord;
  let _ocf = _o5o._ocf;
  let _o2u = vec2f(_ogc(_o6r.a.x / _o6r.a.w, _ord), _ogc(_o6r.a.y / _o6r.a.w, _ocf));
  let _o3u = vec2f(_ogc(_o6r.b.x / _o6r.b.w, _ord), _ogc(_o6r.b.y / _o6r.b.w, _ocf));
  let _o4f = _o5o._o4f;
  let _o5w = _oj7(_of2);
  var _om2 = _o5w.w > _o2c && _odk(_o5w.w);
  let _oll = select(1.0, _o5w.w, _om2);
  let _odb = 1.0 / (_oll * _oll);
  let _occ = 0.5 * f32(_ord);
  let _oc9 = 0.5 * f32(_ocf);
  let _ods = vec3f(_occ * (_oll * _oik(0u) - _o5w.x * _oik(3u)) * _odb,
                 _occ * (_oll * _oik(4u) - _o5w.x * _oik(7u)) * _odb,
                 _occ * (_oll * _oik(8u) - _o5w.x * _oik(11u)) * _odb);
  let _odv = vec3f(_oc9 * (_oll * _oik(1u) - _o5w.y * _oik(3u)) * _odb,
                 _oc9 * (_oll * _oik(5u) - _o5w.y * _oik(7u)) * _odb,
                 _oc9 * (_oll * _oik(9u) - _o5w.y * _oik(11u)) * _odb);
  let _ofz = vec2f(_ogc(_o5w.x / _oll, _ord),
                           _ogc(_o5w.y / _oll, _ocf));
  let _ob3 = _oe9(_omv, _ods, _odv);
  let _o5g = _ob3._o5l + _ob3._oan * _o9a(_ods, _ods);
  let _o5h = _ob3._o5m + _ob3._oan * _o9a(_ods, _odv);
  let _o5i = _ob3._o5n + _ob3._oan * _o9a(_odv, _odv);
  let _o51 = _o5g + _o4f;
  let _o54 = _o5h;
  let _o5b = _o5i + _o4f;
  let _ok9 = _oll / _o6r.a.w;
  let _oka = _oll / _o6r.b.w;
  let _o8q = _o51 * _o5b - _o54 * _o54;
  _om2 = _om2 && _o8q > 0.0 && _odk(_o8q);
  let _od7 = select(0.0, 1.0 / _o8q, _om2);
  let _o66 = _o3u - _o2u;
  let _o31 = _o5b * _o66.x - _o54 * _o66.y;
  let _o32 = _o51 * _o66.y - _o54 * _o66.x;
  let _oc3 = _o66.x * _o31 + _o66.y * _o32;
  let _oc0 = _oaw(_oc3 * _od7, 0.0);
  let _oeg = sqrt(_oc0);
  let _od8 = select(0.0, 1.0 / _oc3, _oc0 > 1e-8);
  let _oin = !(_oeg > _o2g) || !(_od8 > 0.0);
  let _o5q = _o5o._o5r.xyz;
  let _okb = _of2 - _o5q;
  let _odg = inverseSqrt(_o9a(_okb, _okb));
  let _okc = _okb * _odg;
  let _oaj = _o3a(_ob3, _ods, _odv, _okc, _o66.x, _o66.y);
  let _o7a = vec3f(_o51, _o54, _o5b);
  let _ooq = vec3f(_o5g, _o5h, _o5i);
  let _oks = _oaw(_o38, 0.0);
  let _ojd = _oks * _oaj._opi * _oaj._ogi;
  let _oek = sqrt(_oaj._oft) / (_oaj._ogi * _oaj._okf);
  let _ody = _onb(_oaj, _ok9, _o7a, _ooq, _o66.x, _o66.y);
  let _oe0 = _onb(_oaj, 1.0, _o7a, _ooq, _o66.x, _o66.y);
  let _odz = _onb(_oaj, _oka, _o7a, _ooq, _o66.x, _o66.y);
  let _oi9 = _oks * _oaw(_ody, _oaw(_oe0, _odz));
  let _opv = _one(_ojd, _oek, _ok9);
  let _opx = _one(_ojd, _oek, 1.0);
  let _opw = _one(_ojd, _oek, _oka);
  _om2 = _om2 && _oaj._oir && _odk(_oek)
      && _odk(_opv) && _odk(_opx) && _odk(_opw);
  if (!_om2) {
    return;
  }
  let _o5x = _ofz;
  if (_oi9 < _o1h) {
    return;
  }
  let _o7w = _oaw(log(_oaw(_oi9, _o16) / _o16), 1e-6);
  let _o8z = _o3u - _o2u;
  let _oet = _ocq(_o8z.x, _o8z.y);
  let _omd = _oet < 1e-4;
  let _olj = select(_o8z, vec2f(1.0, 0.0), _omd);
  let _olk = select(_oet, 1.0, _omd);
  let _opz = vec2f(-_olj.y / _olk, _olj.x / _olk);
  let _opy = vec2f(_olj.x / _olk, _olj.y / _olk);
  let _odx = sqrt(_o7w);
  let _obf = _oaw(_ok9, _oka);
  let _onm = _oaw(_obf * _obf - 1.0, 0.0);
  let _o6w = _o51 + _onm * _o5g;
  let _o6x = _o54 + _onm * _o5h;
  let _o6y = _o5b + _onm * _o5i;
  let _oqk = _opz.x * (_o6w * _opz.x + _o6x * _opz.y)
               + _opz.y * (_o6x * _opz.x + _o6y * _opz.y);
  let _oqj = _opy.x * (_o6w * _opy.x + _o6x * _opy.y)
                + _opy.y * (_o6x * _opy.x + _o6y * _opy.y);
  var _ohu = _odx * sqrt(_oaw(_oqk, 1e-8));
  var _ohs: f32;
  if (_oin) {
    _ohs = _odx * sqrt(_oaw(_oqj, 1e-8));
  } else {
    let x = _opz.x * (_o6w * _opy.x + _o6x * _opy.y)
          + _opz.y * (_o6x * _opy.x + _o6y * _opy.y);
    let _o8o = _o6w * _o6y - _o6x * _o6x;
    _ohs = _odx * sqrt(_oaw(_oqj, 1e-8)
        + 2.0 * abs(x) * sqrt(_oaw(_o8o, 0.0)) / _oaw(_oqk, 1e-8));
  }
  let _o8u = _ocq(f32(_ord), f32(_ocf));
  _ohu = _oax(_ohu, _o8u);
  _ohs = _oax(_ohs, _o8u);
  var _ojl: array<vec2f, 4>;
  _ojl[3] = vec2f(_oav(-_opy.x, _ohs, _oav(_opz.x, _ohu, _o2u.x)),
                  _oav(-_opy.y, _ohs, _oav(_opz.y, _ohu, _o2u.y)));
  _ojl[0] = vec2f(_oav(-_opy.x, _ohs, _oav(-_opz.x, _ohu, _o2u.x)),
                  _oav(-_opy.y, _ohs, _oav(-_opz.y, _ohu, _o2u.y)));
  _ojl[2] = vec2f(_oav(_opy.x, _ohs, _oav(_opz.x, _ohu, _o3u.x)),
                  _oav(_opy.y, _ohs, _oav(_opz.y, _ohu, _o3u.y)));
  _ojl[1] = vec2f(_oav(_opy.x, _ohs, _oav(-_opz.x, _ohu, _o3u.x)),
                  _oav(_opy.y, _ohs, _oav(-_opz.y, _ohu, _o3u.y)));
  var _og1 = _ojl[0].x;
  var _ofn = _ojl[0].x;
  var _og3 = _ojl[0].y;
  var _ofp = _ojl[0].y;
  var _ofi = 0.0;
  for (var _ocr = 0u; _ocr < 4u; _ocr = _ocr + 1u) {
    let _o7b = _ojl[_ocr];
    if (!_odk(_o7b.x) || !_odk(_o7b.y)) {
      return;
    }
    _og1 = _oax(_og1, _o7b.x);
    _ofn = _oaw(_ofn, _o7b.x);
    _og3 = _oax(_og3, _o7b.y);
    _ofp = _oaw(_ofp, _o7b.y);
    _ofi = _oaw(_ofi, _ocq(_o7b.x - _o5x.x, _o7b.y - _o5x.y));
  }
  let _orb = f32(_ord - 1u);
  let _ocg = f32(_ocf - 1u);
  let _og2 = _oax(_oaw(_og1 - _oi, 0.0), _orb);
  let _ofo = _oax(_oaw(_ofn + _oi, 0.0), _orb);
  let _og4 = _oax(_oaw(_og3 - _oi, 0.0), _ocg);
  let _ofq = _oax(_oaw(_ofp + _oi, 0.0), _ocg);
  let _obx = i32(_o5o._op8);
  let _oby = i32(_o5o._op9);
  let _opn = max(0, min(_obx, i32(floor(_og2 * 0.0625))));
  let _opq = max(0, min(_oby, i32(floor(_og4 * 0.0625))));
  let _opo = max(0, min(_obx, i32(floor(_ofo * 0.0625)) + 1));
  let _opr = max(0, min(_oby, i32(floor(_ofq * 0.0625)) + 1));
  if (_opn >= _opo || _opq >= _opr) {
    return;
  }
  let _ok0 = f32(max(_ord, _ocf));
  let _ofj = max(1, i32(ceil(_oax(_ofi, _ok0))));
  var _oix: _o1o;
  _oix._o3b = vec4f(_o5g, _o5h, _o5i, select(_ok9, -abs(_ok9), _oin));
  _oix._o4m = vec4f(_ojd, _oek, _o7w, _oka);
  _oix.ab = vec4f(_o2u, _o3u);
  _oix._obk = vec4f(_ohu, _ohs, _o8k, f32(_ofj));
  _oix._okm = vec4u(u32(_opn), u32(_opq), u32(_opo), u32(_opr));
  _oiz[_ocu] = _oix;
  var _oga = 0u;
  for (var _opp = u32(_opq); _opp < u32(_opr); _opp = _opp + 1u) {
    let _omy = _op5(_o2u, _o3u, _ohu, _ohs, _opp, _ord, u32(_opn), u32(_opo));
    if (_omy.z != 0u) {
      _oga = _oga + (_omy.y - _omy.x);
    }
  }
  _op7[_ocu] = _oga;
}
fn _o9a(x: vec3f, y: vec3f) -> f32 {
  return x.x * y.x + x.y * y.y + x.z * y.z;
}
@compute @workgroup_size(256)
fn duplicate_keys(@builtin(local_invocation_index) _oey: u32,
                  @builtin(workgroup_id) _orc: vec3u,
                  @builtin(num_workgroups) _ogn: vec3u) {
  let _ocu = _of3(_orc, _ogn) * _o2h + _oey;
  if (_ocu >= _o9h[_o1u]) {
    return;
  }
  let _oix = _o9j[_ocu];
  if (!(_oix._obk.w > 0.0)) {
    return;
  }
  var off = 0u;
  if (_ocu > 0u) {
    off = _o9i[_ocu - 1u];
  }
  let _o2u = _oix.ab.xy;
  let _o3u = _oix.ab.zw;
  let _o8l = bitcast<u32>(_oix._obk.z);
  let _o5t = _o9g._o5t;
  for (var y = _oix._okm.y; y < _oix._okm.w; y = y + 1u) {
    let _omy = _op5(_o2u, _o3u, _oix._obk.x, _oix._obk.y, y,
                             _o9g._ord, _oix._okm.x, _oix._okm.z);
    if (_omy.z == 0u) {
      continue;
    }
    for (var x = _omy.x; x < _omy.y; x = x + 1u) {
      if (off < _o5t) {
        _oec[off] = y * _o9g._op8 + x;
        _oed[off] = _o8l;
        _oi5[off] = _ocu;
      }
      off = off + 1u;
    }
  }
}
