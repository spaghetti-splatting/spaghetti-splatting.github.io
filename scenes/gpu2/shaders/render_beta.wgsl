struct _o1p {
  _o3b: vec4f,
  _o4m: vec4f,
  ab: vec4f,
  _obj: vec4f,
  _okl: vec4u,
  _okk: vec4f,
  _ohc: vec4f,
  _ohd: vec4f,
  _ohe: vec4f,
};
struct _om {
  _oom: f32,
  _oon: f32,
  _oiz: f32,
  _oj0: f32,
  _o3l: u32,
  _o3f: u32,
  _op1: u32,
  _ohy: u32,
};
@group(0) @binding(0) var<storage, read> _ok4: array<u32>;
@group(0) @binding(1) var<storage, read> _oin: array<u32>;
@group(0) @binding(2) var<storage, read> _oiy: array<_o1p>;
@group(0) @binding(3) var<storage, read> rgb: array<f32>;
@group(0) @binding(4) var<storage, read> _oix: array<vec4u>;
@group(0) @binding(5) var<storage, read> _oow: array<f32>;
@group(0) @binding(6) var<storage, read> _oox: array<f32>;
@group(0) @binding(7) var<storage, read_write> _oh7: array<f32>;
@group(0) @binding(8) var<uniform> _o5o: _oo;
@group(0) @binding(9) var<uniform> _o4r: _om;
const _of: u32 = 256u;
const _o2g: f32 = 0.1;
const _o1g: f32 = 0.0;
const _o5: f32 = 1.0e-30;
const _o8: f32 = 1.0e-4;
const _od: f32 = 0.1;
const _o4: f32 = 1.17549435e-38;
const _oe: f32 = 1.41421356;
const _o9: f32 = 0.707106781;
const _o3: f32 = -3.1215594;
const _o2: f32 = 1.8495809;
const _o14: u32 = 6u;
const _o15: u32 = 8u;
const _o13 = array<f32, 24>(
  -1.0, 0.0, 0.0, 0.0,
  0.8639625, -0.080043316, 0.011840287, -0.00032925335,
  -0.65780294, 0.16117837, -0.025375213, 0.0017560583,
  0.40191287, -0.1712049, 0.028378023, -0.0027375722,
  -0.16230038, 0.09921428, -0.017412446, 0.0016617817,
  0.030476268, -0.023956835, 0.004615334, -0.00040338145);
const _o12 = array<f32, 5>(
  0.9317711, -0.04327248, 0.0059742285, 8.387385e-06, -1.3679006e-05);
const _o11 = array<f32, 5>(
  1.0743953, 0.049604684, -0.005744186, -0.00030108364, 2.7100898e-05);
var<workgroup> _o46: array<u32, 256>;
var<workgroup> _o47: array<vec4f, 256>;
var<workgroup> _o48: array<vec4f, 256>;
var<workgroup> _o41: array<vec2f, 256>;
var<workgroup> _o44: array<vec2f, 256>;
var<workgroup> _o42: array<vec4f, 256>;
var<workgroup> _o49: array<array<f32, 8>, 256>;
var<workgroup> _o45: array<f32, 256>;
var<workgroup> _o4a: array<i32, 256>;
var<workgroup> _o98: atomic<u32>;
var<workgroup> _o97: u32;
var<private> _on8: array<f32, 8>;
var<private> _om8: array<f32, 5>;
fn _oqu(_odw: u32) -> f32 {
  return _o5o._oqp[_odw >> 2u][_odw & 3u];
}
fn _on6(_omp: u32, _obf: f32) {
  _o49[_omp][0] = _obf;
  let _obn = _obf + 1.0;
  let r = inverseSqrt(_obn);
  let z = fma(r, _o3, _o2);
  let _ors = z + z;
  var _oo5: array<f32, 5>;
  _oo5[0] = 1.0;
  _oo5[1] = z;
  for (var _odm = 2u; _odm <= 4u; _odm = _odm + 1u) {
    _oo5[_odm] = fma(_ors, _oo5[_odm - 1u], -_oo5[_odm - 2u]);
  }
  var _o7z: array<f32, 6>;
  for (var _odw = 0u; _odw < _o14; _odw = _odw + 1u) {
    var _o2z = _o13[_odw * 4u];
    for (var _odm = 1u; _odm <= 3u; _odm = _odm + 1u) {
      _o2z = fma(_o13[_odw * 4u + _odm], _oo5[_odm], _o2z);
    }
    _o7z[_odw] = _o2z;
  }
  var g = _o12[0];
  var _obd = _o11[0];
  for (var _odm = 1u; _odm <= 4u; _odm = _odm + 1u) {
    g = fma(_o12[_odm], _oo5[_odm], g);
    _obd = fma(_o11[_odm], _oo5[_odm], _obd);
  }
  let _oaa = r * g;
  let _odc = (_obn * r) * _obd;
  _o49[_omp][1] = _oaa;
  _o49[_omp][2] = _o7z[0];
  var _oir = _odc;
  for (var _odw = 1u; _odw < _o14; _odw = _odw + 1u) {
    _o49[_omp][_odw + 2u] = _o7z[_odw] * _oir;
    _oir = _oir * _odc;
  }
}
fn _of5(_odm: u32) {
  for (var _odw = 0u; _odw < _o15; _odw = _odw + 1u) {
    _on8[_odw] = _o49[_odm][_odw];
  }
  let _obf = _on8[0];
  let _ojs = fma(_obf, -0.3, 0.3);
  let _ojt = fma(_obf, -5.0 / 21.0, 10.0 / 21.0);
  let _oju = fma(_obf, -7.0 / 36.0, 21.0 / 36.0);
  _om8[0] = 1.0;
  _om8[1] = _obf * (-1.0 / 3.0);
  _om8[2] = _om8[1] * _ojs;
  _om8[3] = _om8[2] * _ojt;
  _om8[4] = _om8[3] * _oju;
}
struct _o17 {
  _oqc: f32,
  _ofd: f32,
  _oj7: f32,
  _o78: f32,
  _oqh: f32,
  _om7: bool,
};
fn _o4h(_oqc: f32) -> _o17 {
  let _obf = _on8[0];
  var _o9r: _o17;
  _o9r._oqc = _oqc;
  let _oh1 = _oav(fma(-_oqc, _oqc, 1.0), _o4);
  _o9r._ofd = log2(_oh1);
  _o9r._oj7 = exp2((_obf + 1.0) * _o9r._ofd);
  var _o2z = _on8[1u + _o14];
  for (var _odw = i32(_o14) - 1; _odw >= 0; _odw = _odw - 1) {
    _o2z = fma(_o2z, _oqc, _on8[1 + _odw]);
  }
  _o9r._o78 = _o9r._oj7 * _o2z;
  let _opr = _oqc * _oqc;
  var _ons = _om8[4];
  for (var _og6 = 3; _og6 >= 0; _og6 = _og6 - 1) {
    _ons = fma(_ons, _opr, _om8[_og6]);
  }
  _o9r._om7 = _oqc <= _od;
  _o9r._oqh = select(_on8[1] - _o9r._o78, _ons * _oqc, _o9r._om7);
  return _o9r;
}
fn _o3m(_oef: f32) -> f32 {
  let _obf = _on8[0];
  if (_oef < _o2g) {
    let _o40 = fma(-0.3 * _oef, _oef, 1.0);
    let _oir = exp2(_obf * log2(_o40));
    return fma(5.0 / 9.0, _oir, 4.0 / 9.0);
  } else if (_oef <= _oe) {
    let _oqc = _oef * _o9;
    return _o4h(_oqc)._oqh / _oqc;
  }
  return _oe * _on8[1] / _oef;
}
fn _ond(_ojc: f32, _oej: f32, g: f32) -> f32 {
  let _ohm = _o3m(_oej / g);
  return _ojc * (g * g / _ohm);
}
fn _o4i(_of4: _o17, _ocg: _o17, _oio: bool, _oge: bool) -> f32 {
  let _o4q = _of4._om7 && _ocg._om7;
  let _oac = select(_of4._oqh, _ocg._oqh, _oio);
  let _oad = select(_ocg._oqh, _of4._oqh, _oio);
  let _omq = _oac - _oad;
  let _ool = _of4._o78 - _ocg._o78;
  let _ook = select(-_ool, _ool, _oio);
  let cross = _ocg._oqh + _of4._oqh;
  return select(cross, select(_ook, _omq, _o4q), _oio || _oge);
}
struct _o1a {
  _oe3: bool,
  _ooq: f32,
  _oof: f32,
};
fn _oa0(_odm: u32, _oel: vec4f, _oem: vec4f, _ort: vec4f, _oa1: f32, _oa7: f32,
                     _o9j: f32, _o9k: f32, _o4f: f32, _op1: bool) -> _o1a {
  var fragment = _o1a(false, 0.0, 0.5);
  let _oim = _omg(_oem.w);
  let _o7t = _ort.z;
  let _ok8 = abs(_oem.w);
  let _ok9 = abs(_ort.w);
  let _o9z = _oel.z;
  let _o9x = _oel.w;
  let _o8o = _oem.x;
  let _ope = _oem.y;
  var _oor: f32;
  var _oq2: f32;
  if (_oim) {
    let g = _ok8 + 0.5 * (_ok9 - _ok8);
    let gg = g * g;
    let _o8n = fma(gg, fma(gg, _o8o, _o4f * _ope), _o4f * _o4f);
    let _ojp = _o9j - 0.5 * _oa1;
    let _ojq = _o9k - 0.5 * _oa7;
    let _o33 = _oel.x * _ojp + _oel.y * _ojq;
    let _o34 = _oel.y * _ojp + _oem.z * _ojq;
    let _oa6 = gg * (_ojp * _o33 + _ojq * _o34) + _o4f * (_ojp * _ojp + _ojq * _ojq);
    let _oc2 = fma(gg, _o9z, _o4f * _o9x);
    let _oks = gg * (_oa1 * _o33 + _oa7 * _o34) + _o4f * (_oa1 * _ojp + _oa7 * _ojq);
    let _okt = abs(_oks);
    var _ohl: bool;
    if (2.0 * _okt < _oc2) {
      _ohl = (_oa6 - _o7t * _o8n) * _oc2 > _oks * _oks;
    } else {
      _ohl = _oa6 - _okt + 0.25 * _oc2 > _o7t * _o8n;
    }
    if (_ohl) {
      return fragment;
    }
    _of5(_odm);
    _oq2 = _ond(_ort.x, _ort.y, g);
    let _od8 = inverseSqrt(_o8n);
    let _od5 = _od8 * _od8;
    let _oa5 = _oa6 * _od5;
    let _obz = _oc2 * _od5;
    let _oku = _oks * _od5;
    let _oje = _oav(_oa5, 0.0);
    let _o9d = fma(_oku, _oku, _obz * (0.5 - _oje));
    let _okw = sqrt(_oav(_o9d, 0.0));
    let _o4l = _oku + select(_okw, -_okw, _omg(_oku));
    var _ojw = -1.0;
    var _ojv = 1.0;
    var _ont = _o9d >= 0.0;
    if (_o4l == 0.0) {
      _ont = _ont && _oje < 0.5;
    } else {
      let _ooe = (_oje - 0.5) / _o4l;
      if (_obz > 0.0) {
        let _ood = _o4l / _obz;
        _ojw = _oaw(_ood, _ooe);
        _ojv = _oav(_ood, _ooe);
      } else if (_oku > 0.0) {
        _ojw = _ooe;
      } else {
        _ojv = _ooe;
      }
    }
    let _oky = _oav(_o9d, 0.5 * _o8 * _obz);
    if (!(_oky > 0.0) && (_ojw > -0.5 || _ojv < 0.5)) {
      _ojw = 0.5;
      _ojv = -0.5;
    }
    let _ooh = _oav(_ojw, -0.5);
    let _oog = _oaw(_ojv, 0.5);
    _ont = _ont && _oog > _ooh;
    let _oc5 = select(0.0, 0.5 * (_oog - _ooh), _ont);
    let _oft = 0.5 * (_oog + _ooh);
    let _ogf = 0.774596669;
    let _obf = _on8[0];
    var _opa: array<f32, 3>;
    var _oed: array<f32, 3>;
    for (var _ocq = 0; _ocq < 3; _ocq = _ocq + 1) {
      _opa[_ocq] = fma(_oc5, f32(_ocq - 1) * _ogf, _oft);
      let _ojb = fma(_opa[_ocq], fma(_opa[_ocq], _obz, -2.0 * _oku), _oje);
      let _o40 = fma(-2.0, _ojb, 1.0);
      _oed[_ocq] = select(0.0, exp2(_obf * log2(_o40)), _ont && _o40 > 0.0);
    }
    let _ome = 5.0 / 9.0;
    let _ofx = 8.0 / 9.0;
    let _or9 = fma(_ome, _oed[0] + _oed[2], _ofx * _oed[1]);
    _oor = _oc5 * _or9 * _od8;
    if (_op1) {
      let _og4 = fma(_ome, fma(_opa[0], _oed[0], _opa[2] * _oed[2]), _ofx * _opa[1] * _oed[1]);
      let _ogw = select(0.0, _og4 / _or9, _or9 >= _o5);
      fragment._oof = _oaw(_oav(0.5 + _ogw, 0.0), 1.0);
    }
  } else {
    let _o2m = _oel.x * _o9j + _oel.y * _o9k;
    let _o4g = _o4f * (_oa1 * _o9j + _oa7 * _o9k);
    let _ooi = _oaw(_oav((_o2m + _o4g) * _oem.z, 0.0), 1.0);
    let g = _ok8 + _ooi * (_ok9 - _ok8);
    let gg = g * g;
    let _oc2 = fma(gg, _o9z, _o4f * _o9x);
    let _okf = fma(gg, _o2m, _o4g);
    let _o8n = fma(gg, fma(gg, _o8o, _o4f * _ope), _o4f * _o4f);
    let cross = _o9j * _oa7 - _o9k * _oa1;
    let _o7m = cross * cross;
    let _o7u = _o7t * _oc2;
    if (_o7m > _o7u) {
      return fragment;
    }
    let _okg = _oc2 - _okf;
    let _ogd = _oaw(_okf, _okg);
    if (_ogd < 0.0 && _ogd * _ogd > _o7u * _o8n) {
      return fragment;
    }
    _of5(_odm);
    _oq2 = _ond(_ort.x, _ort.y, g);
    let _od9 = inverseSqrt(_oc2);
    let _ol5 = _od9 * inverseSqrt(_o8n);
    let _od7 = _od9 * _od9;
    let _oa5 = _o7m * _od7;
    let _ops = _okf * _ol5;
    let _opt = _okg * _ol5;
    let a = fma(-2.0, _oa5, 1.0);
    let _oip = a > 0.0;
    let _o2y = select(1.0, a, _oip);
    let _of7 = log2(_o2y);
    let _odb = inverseSqrt(0.5 * _o2y);
    let _o4z = 0.5 * _o2y * _odb;
    let _oqe = _oaw(_oav(-_ops * _odb, -1.0), 1.0);
    let _oqd = _oaw(_oav(_opt * _odb, -1.0), 1.0);
    let _of4 = _o4h(abs(_oqe));
    let _ocg = _o4h(abs(_oqd));
    let _oio = _oqe >= 0.0;
    let _oge = _oqd <= 0.0;
    let _o8a = _o4i(_of4, _ocg, _oio, _oge);
    let _of3 = _oip && _o8a > 0.0;
    let _obf = _on8[0];
    let _o2x = exp2(_obf * _of7);
    if (_op1) {
      let _oef = _oc2 * _ol5;
      let _oaz = _okf * _od7;
      let _o89 = select(0.0, _o8a, _of3);
      let _ob0 = _of3 && _oef * (_o4z * _o89) >= _o5;
      let _o8b = select(1.0, _o89, _ob0);
      let _o8g = _of4._oj7 - _ocg._oj7;
      let _ogw = select(0.0, _o4z * _o8g / (2.0 * (_obf + 1.0) * _oef * _o8b), _ob0);
      fragment._oof = _oaw(_oav(_oaz + _ogw, 0.0), 1.0);
    }
    let _oee = _o4z * _o2x * _o8a;
    _oor = select(0.0, _oee * _od9, _of3);
  }
  fragment._oe3 = true;
  fragment._ooq = _oq2 * _oor;
  return fragment;
}
fn _ooz(_omp: u32, _oh3: vec3f, _okb: vec3f, _opr: f32) -> vec3f {
  let _oa9 = 12u * _omp;
  let _oil = vec3f(_oow[_oa9], _oow[_oa9 + 1u], _oow[_oa9 + 2u]);
  let _oaa = vec3f(_oow[_oa9 + 3u], _oow[_oa9 + 4u], _oow[_oa9 + 5u]);
  let _oab = vec3f(_oow[_oa9 + 6u], _oow[_oa9 + 7u], _oow[_oa9 + 8u]);
  let _okr = _oow[_oa9 + 9u];
  let _ogw = _oh3 - _oil;
  let _ogr = _ogw.x * _oaa.x + _ogw.y * _oaa.y + _ogw.z * _oaa.z;
  let _ogs = _ogw.x * _oab.x + _ogw.y * _oab.y + _ogw.z * _oab.z;
  let _o81 = _okb.x * _oaa.x + _okb.y * _oaa.y + _okb.z * _oaa.z;
  let _o82 = _okb.x * _oab.x + _okb.y * _oab.y + _okb.z * _oab.z;
  let _o37 = _o81 * _o81 + _o82 * _o82;
  var _oqc = 0.5;
  if (_o37 != 0.0 && _odj(_o37) && _odj(_ogr) && _odj(_ogs)) {
    let _oeh = -(_ogr * _o81 + _ogs * _o82) / _o37;
    let _o57 = _ogr + _oeh * _o81;
    let _o5e = _ogs + _oeh * _o82;
    let _ojb = _okr * _okr - (_o57 * _o57 + _o5e * _o5e);
    var _oho = _o57;
    var _ohp = _o5e;
    if (_ojb >= 0.0) {
      let _oc7 = sqrt(_ojb / _o37);
      if (_oeh - _oc7 > 0.0) {
        _oho = _o57 - _oc7 * _o81;
        _ohp = _o5e - _oc7 * _o82;
      } else if (_oeh + _oc7 > 0.0) {
        _oho = _o57 + _oc7 * _o81;
        _ohp = _o5e + _oc7 * _o82;
      }
    }
    if (_odj(_oho) && _odj(_ohp)) {
      _oqc = atan2(_ohp, _oho) * 0.15915494309189535 + 0.5;
    }
  }
  let _o3l = i32(_o4r._o3l);
  let _o3f = i32(_o4r._o3f);
  let x = _opr * f32(_o3l - 1);
  let _ocr = min(i32(floor(x)), _o3l - 2);
  let wx = x - f32(_ocr);
  let y = _oqc * f32(_o3f) - 0.5;
  let _oba = floor(y);
  let _odn = ((i32(_oba) % _o3f) + _o3f) % _o3f;
  let _odo = (_odn + 1) % _o3f;
  let wy = y - _oba;
  let _ooy = array<i32, 4>(_ocr * _o3f + _odn, (_ocr + 1) * _o3f + _odn,
                            _ocr * _o3f + _odo, (_ocr + 1) * _o3f + _odo);
  let _or8 = array<f32, 4>((1.0 - wx) * (1.0 - wy), wx * (1.0 - wy),
                             (1.0 - wx) * wy, wx * wy);
  let _o40 = _omp * 3u * _o4r._o3l * _o4r._o3f;
  var _o71 = vec3f(0.0);
  for (var _o64 = 0u; _o64 < 3u; _o64 = _o64 + 1u) {
    var _oqh = 0.0;
    for (var _odw = 0u; _odw < 4u; _odw = _odw + 1u) {
      _oqh = _oqh + _or8[_odw] * _oox[_o40 + 3u * u32(_ooy[_odw]) + _o64];
    }
    _o71[_o64] = _oqh;
  }
  return _o71;
}
@compute @workgroup_size(16, 16)
fn render_beta(@builtin(local_invocation_id) _of6: vec3u,
               @builtin(local_invocation_index) _oex: u32,
               @builtin(workgroup_id) _orb: vec3u) {
  let _orc = _o5o._orc;
  let _oce = _o5o._oce;
  let _op1 = _o4r._op1 != 0u;
  let _oi9 = vec2u(_orb.x * 16u + _of6.x, _orb.y * 16u + _of6.y);
  let _od3 = _oi9.x < _orc && _oi9.y < _oce;
  let _oid = vec2f(f32(_oi9.x), f32(_oi9.y));
  var _o96 = !_od3;
  let _op3 = _orb.y * _o5o._op7 + _orb.x;
  let _ok3 = _ok4[2u * _op3];
  let _ok2 = _ok4[2u * _op3 + 1u];
  let _ol0 = (_ok2 - _ok3 + _of - 1u) / _of;
  var _opb = i32(_ok2 - _ok3);
  var _opg = 1.0;
  var _o71 = vec3f(0.0);
  var _okd = vec3f(0.0);
  var _okb = vec3f(0.0);
  if (_op1) {
    _okd = _o5o._o5r.xyz;
    let _ogn = (2.0 * _oid.x + 1.0) / f32(_orc) - 1.0;
    let _ogo = (2.0 * _oid.y + 1.0) / f32(_oce) - 1.0;
    let _ol6 = (_ogn - _o4r._oiz) * _o4r._oom;
    let _ol7 = (_ogo - _o4r._oj0) * _o4r._oon;
    let _ol8 = 1.0;
    _okb = vec3f(_oqu(0u) * _ol6 + _oqu(1u) * _ol7 + _oqu(2u) * _ol8,
                _oqu(4u) * _ol6 + _oqu(5u) * _ol7 + _oqu(6u) * _ol8,
                _oqu(8u) * _ol6 + _oqu(9u) * _ol7 + _oqu(10u) * _ol8);
  }
  for (var _ocq = 0u; _ocq < _ol0; _ocq = _ocq + 1u) {
    if (_oex == 0u) {
      atomicStore(&_o98, 0u);
    }
    workgroupBarrier();
    if (_o96) {
      atomicAdd(&_o98, 1u);
    }
    workgroupBarrier();
    if (_oex == 0u) {
      _o97 = atomicLoad(&_o98);
    }
    let _ogk = workgroupUniformLoad(&_o97);
    if (_ogk == _of) {
      break;
    }
    let _oj3 = _ocq * _of + _oex;
    if (_ok3 + _oj3 < _ok2) {
      let _o70 = _oin[_ok3 + _oj3];
      _o46[_oex] = _o70;
      let _okk = _oiy[_o70]._okk;
      _on6(_oex, abs(_okk.x));
      let _o4f = _okk.z;
      _o45[_oex] = _o4f;
      _o4a[_oex] = bitcast<i32>(_oix[_o70].z);
      let _oop = _oiy[_o70]._o3b;
      let ab = _oiy[_o70].ab;
      let _o2k = ab.xy;
      let _o3r = ab.zw;
      let _oa1 = _o3r.x - _o2k.x;
      let _oa7 = _o3r.y - _o2k.y;
      let _o2n = _oop.z * _oa1 - _oop.y * _oa7;
      let _o2o = _oop.x * _oa7 - _oop.y * _oa1;
      let _o9z = _oav(_oa1 * _o2n + _oa7 * _o2o, 0.0);
      let _o9x = _oa1 * _oa1 + _oa7 * _oa7;
      let _o8o = _oav(_oop.x * _oop.z - _oop.y * _oop.y, 0.0);
      let _ope = _oop.x + _oop.z;
      if (_omg(_oop.w)) {
        _o47[_oex] = vec4f(_oop.z, -_oop.y, _o9z, _o9x);
        _o48[_oex] = vec4f(_o8o, _ope, _oop.x, _oop.w);
      } else {
        _o47[_oex] = vec4f(_o2n, _o2o, _o9z, _o9x);
        _o48[_oex] = vec4f(_o8o, _ope, 1.0 / (_o9z + _o4f * _o9x), _oop.w);
      }
      _o41[_oex] = _o2k;
      _o44[_oex] = vec2f(_oa1, _oa7);
      _o42[_oex] = _oiy[_o70]._o4m;
    }
    workgroupBarrier();
    let _o43 = u32(min(i32(_of), _opb));
    for (var _odm = 0u; !_o96 && _odm < _o43; _odm = _odm + 1u) {
      let _o2k = _o41[_odm];
      let _o9m = _o44[_odm];
      let fragment = _oa0(_odm, _o47[_odm], _o48[_odm], _o42[_odm], _o9m.x, _o9m.y,
                                       _oid.x - _o2k.x, _oid.y - _o2k.y, _o45[_odm], _op1);
      if (!fragment._oe3) {
        continue;
      }
      let _o37 = _oaw(1.0 - exp(-fragment._ooq), 0.9999);
      let _oov = _opg * (1.0 - _o37);
      if (_o37 < _o1g) {
        continue;
      }
      let _o5u = 3u * _o46[_odm];
      var _o4z = vec3f(rgb[_o5u], rgb[_o5u + 1u], rgb[_o5u + 2u]);
      if (_op1) {
        let _omp = _o4a[_odm];
        if (_omp >= 0) {
          _o4z = _o4z + _ooz(u32(_omp), _okd, _okb, fragment._oof);
        }
      }
      _o71 = _o71 + _o4z * _o37 * _opg;
      _opg = _oov;
      if (_oov < 0.0001) {
        _o96 = true;
      }
    }
    _opb = _opb - i32(_of);
  }
  if (_od3) {
    let _oii = _orc * _oce;
    let _oia = _orc * _oi9.y + _oi9.x;
    _oh7[_oia] = _o71.x + _opg * _o5o._o3x.x;
    _oh7[_oii + _oia] = _o71.y + _opg * _o5o._o3x.y;
    _oh7[2u * _oii + _oia] = _o71.z + _opg * _o5o._o3x.z;
  }
}
