struct _o1p {
  _o3b: vec4f,
  _o4m: vec4f,
  ab: vec4f,
  _obk: vec4f,
  _okm: vec4u,
  _okl: vec4f,
  _ohd: vec4f,
  _ohe: vec4f,
  _ohf: vec4f,
};
struct _om {
  _oon: f32,
  _ooo: f32,
  _oj0: f32,
  _oj1: f32,
  _o3l: u32,
  _o3f: u32,
  _op2: u32,
  _ohz: u32,
};
@group(0) @binding(0) var<storage, read> _ok5: array<u32>;
@group(0) @binding(1) var<storage, read> _oio: array<u32>;
@group(0) @binding(2) var<storage, read> _oiz: array<_o1p>;
@group(0) @binding(3) var<storage, read> rgb: array<f32>;
@group(0) @binding(4) var<storage, read> _oiy: array<vec4u>;
@group(0) @binding(5) var<storage, read> _oox: array<f32>;
@group(0) @binding(6) var<storage, read> _ooy: array<f32>;
@group(0) @binding(7) var<storage, read_write> _oh8: array<f32>;
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
var<workgroup> _o99: atomic<u32>;
var<workgroup> _o98: u32;
var<private> _on9: array<f32, 8>;
var<private> _om9: array<f32, 5>;
fn _oqv(_odx: u32) -> f32 {
  return _o5o._oqq[_odx >> 2u][_odx & 3u];
}
fn _on7(_omq: u32, _obg: f32) {
  _o49[_omq][0] = _obg;
  let _obo = _obg + 1.0;
  let r = inverseSqrt(_obo);
  let z = fma(r, _o3, _o2);
  let _ort = z + z;
  var _oo6: array<f32, 5>;
  _oo6[0] = 1.0;
  _oo6[1] = z;
  for (var _odn = 2u; _odn <= 4u; _odn = _odn + 1u) {
    _oo6[_odn] = fma(_ort, _oo6[_odn - 1u], -_oo6[_odn - 2u]);
  }
  var _o80: array<f32, 6>;
  for (var _odx = 0u; _odx < _o14; _odx = _odx + 1u) {
    var _o2z = _o13[_odx * 4u];
    for (var _odn = 1u; _odn <= 3u; _odn = _odn + 1u) {
      _o2z = fma(_o13[_odx * 4u + _odn], _oo6[_odn], _o2z);
    }
    _o80[_odx] = _o2z;
  }
  var g = _o12[0];
  var _obe = _o11[0];
  for (var _odn = 1u; _odn <= 4u; _odn = _odn + 1u) {
    g = fma(_o12[_odn], _oo6[_odn], g);
    _obe = fma(_o11[_odn], _oo6[_odn], _obe);
  }
  let _oab = r * g;
  let _odd = (_obo * r) * _obe;
  _o49[_omq][1] = _oab;
  _o49[_omq][2] = _o80[0];
  var _ois = _odd;
  for (var _odx = 1u; _odx < _o14; _odx = _odx + 1u) {
    _o49[_omq][_odx + 2u] = _o80[_odx] * _ois;
    _ois = _ois * _odd;
  }
}
fn _of6(_odn: u32) {
  for (var _odx = 0u; _odx < _o15; _odx = _odx + 1u) {
    _on9[_odx] = _o49[_odn][_odx];
  }
  let _obg = _on9[0];
  let _ojt = fma(_obg, -0.3, 0.3);
  let _oju = fma(_obg, -5.0 / 21.0, 10.0 / 21.0);
  let _ojv = fma(_obg, -7.0 / 36.0, 21.0 / 36.0);
  _om9[0] = 1.0;
  _om9[1] = _obg * (-1.0 / 3.0);
  _om9[2] = _om9[1] * _ojt;
  _om9[3] = _om9[2] * _oju;
  _om9[4] = _om9[3] * _ojv;
}
struct _o17 {
  _oqd: f32,
  _ofe: f32,
  _oj8: f32,
  _o79: f32,
  _oqi: f32,
  _om8: bool,
};
fn _o4h(_oqd: f32) -> _o17 {
  let _obg = _on9[0];
  var _o9s: _o17;
  _o9s._oqd = _oqd;
  let _oh2 = _oaw(fma(-_oqd, _oqd, 1.0), _o4);
  _o9s._ofe = log2(_oh2);
  _o9s._oj8 = exp2((_obg + 1.0) * _o9s._ofe);
  var _o2z = _on9[1u + _o14];
  for (var _odx = i32(_o14) - 1; _odx >= 0; _odx = _odx - 1) {
    _o2z = fma(_o2z, _oqd, _on9[1 + _odx]);
  }
  _o9s._o79 = _o9s._oj8 * _o2z;
  let _ops = _oqd * _oqd;
  var _ont = _om9[4];
  for (var _og7 = 3; _og7 >= 0; _og7 = _og7 - 1) {
    _ont = fma(_ont, _ops, _om9[_og7]);
  }
  _o9s._om8 = _oqd <= _od;
  _o9s._oqi = select(_on9[1] - _o9s._o79, _ont * _oqd, _o9s._om8);
  return _o9s;
}
fn _o3m(_oeg: f32) -> f32 {
  let _obg = _on9[0];
  if (_oeg < _o2g) {
    let _o40 = fma(-0.3 * _oeg, _oeg, 1.0);
    let _ois = exp2(_obg * log2(_o40));
    return fma(5.0 / 9.0, _ois, 4.0 / 9.0);
  } else if (_oeg <= _oe) {
    let _oqd = _oeg * _o9;
    return _o4h(_oqd)._oqi / _oqd;
  }
  return _oe * _on9[1] / _oeg;
}
fn _one(_ojd: f32, _oek: f32, g: f32) -> f32 {
  let _ohn = _o3m(_oek / g);
  return _ojd * (g * g / _ohn);
}
fn _o4i(_of5: _o17, _och: _o17, _oip: bool, _ogf: bool) -> f32 {
  let _o4q = _of5._om8 && _och._om8;
  let _oad = select(_of5._oqi, _och._oqi, _oip);
  let _oae = select(_och._oqi, _of5._oqi, _oip);
  let _omr = _oad - _oae;
  let _oom = _of5._o79 - _och._o79;
  let _ool = select(-_oom, _oom, _oip);
  let cross = _och._oqi + _of5._oqi;
  return select(cross, select(_ool, _omr, _o4q), _oip || _ogf);
}
struct _o1a {
  _oe4: bool,
  _oor: f32,
  _oog: f32,
};
fn _oa1(_odn: u32, _oem: vec4f, _oen: vec4f, _oru: vec4f, _oa2: f32, _oa8: f32,
                     _o9k: f32, _o9l: f32, _o4f: f32, _op2: bool) -> _o1a {
  var fragment = _o1a(false, 0.0, 0.5);
  let _oin = _omh(_oen.w);
  let _o7u = _oru.z;
  let _ok9 = abs(_oen.w);
  let _oka = abs(_oru.w);
  let _oa0 = _oem.z;
  let _o9y = _oem.w;
  let _o8p = _oen.x;
  let _opf = _oen.y;
  var _oos: f32;
  var _oq3: f32;
  if (_oin) {
    let g = _ok9 + 0.5 * (_oka - _ok9);
    let gg = g * g;
    let _o8o = fma(gg, fma(gg, _o8p, _o4f * _opf), _o4f * _o4f);
    let _ojq = _o9k - 0.5 * _oa2;
    let _ojr = _o9l - 0.5 * _oa8;
    let _o33 = _oem.x * _ojq + _oem.y * _ojr;
    let _o34 = _oem.y * _ojq + _oen.z * _ojr;
    let _oa7 = gg * (_ojq * _o33 + _ojr * _o34) + _o4f * (_ojq * _ojq + _ojr * _ojr);
    let _oc3 = fma(gg, _oa0, _o4f * _o9y);
    let _okt = gg * (_oa2 * _o33 + _oa8 * _o34) + _o4f * (_oa2 * _ojq + _oa8 * _ojr);
    let _oku = abs(_okt);
    var _ohm: bool;
    if (2.0 * _oku < _oc3) {
      _ohm = (_oa7 - _o7u * _o8o) * _oc3 > _okt * _okt;
    } else {
      _ohm = _oa7 - _oku + 0.25 * _oc3 > _o7u * _o8o;
    }
    if (_ohm) {
      return fragment;
    }
    _of6(_odn);
    _oq3 = _one(_oru.x, _oru.y, g);
    let _od9 = inverseSqrt(_o8o);
    let _od6 = _od9 * _od9;
    let _oa6 = _oa7 * _od6;
    let _oc0 = _oc3 * _od6;
    let _okv = _okt * _od6;
    let _ojf = _oaw(_oa6, 0.0);
    let _o9e = fma(_okv, _okv, _oc0 * (0.5 - _ojf));
    let _okx = sqrt(_oaw(_o9e, 0.0));
    let _o4l = _okv + select(_okx, -_okx, _omh(_okv));
    var _ojx = -1.0;
    var _ojw = 1.0;
    var _onu = _o9e >= 0.0;
    if (_o4l == 0.0) {
      _onu = _onu && _ojf < 0.5;
    } else {
      let _oof = (_ojf - 0.5) / _o4l;
      if (_oc0 > 0.0) {
        let _ooe = _o4l / _oc0;
        _ojx = _oax(_ooe, _oof);
        _ojw = _oaw(_ooe, _oof);
      } else if (_okv > 0.0) {
        _ojx = _oof;
      } else {
        _ojw = _oof;
      }
    }
    let _okz = _oaw(_o9e, 0.5 * _o8 * _oc0);
    if (!(_okz > 0.0) && (_ojx > -0.5 || _ojw < 0.5)) {
      _ojx = 0.5;
      _ojw = -0.5;
    }
    let _ooi = _oaw(_ojx, -0.5);
    let _ooh = _oax(_ojw, 0.5);
    _onu = _onu && _ooh > _ooi;
    let _oc6 = select(0.0, 0.5 * (_ooh - _ooi), _onu);
    let _ofu = 0.5 * (_ooh + _ooi);
    let _ogg = 0.774596669;
    let _obg = _on9[0];
    var _opb: array<f32, 3>;
    var _oee: array<f32, 3>;
    for (var _ocr = 0; _ocr < 3; _ocr = _ocr + 1) {
      _opb[_ocr] = fma(_oc6, f32(_ocr - 1) * _ogg, _ofu);
      let _ojc = fma(_opb[_ocr], fma(_opb[_ocr], _oc0, -2.0 * _okv), _ojf);
      let _o40 = fma(-2.0, _ojc, 1.0);
      _oee[_ocr] = select(0.0, exp2(_obg * log2(_o40)), _onu && _o40 > 0.0);
    }
    let _omf = 5.0 / 9.0;
    let _ofy = 8.0 / 9.0;
    let _ora = fma(_omf, _oee[0] + _oee[2], _ofy * _oee[1]);
    _oos = _oc6 * _ora * _od9;
    if (_op2) {
      let _og5 = fma(_omf, fma(_opb[0], _oee[0], _opb[2] * _oee[2]), _ofy * _opb[1] * _oee[1]);
      let _ogx = select(0.0, _og5 / _ora, _ora >= _o5);
      fragment._oog = _oax(_oaw(0.5 + _ogx, 0.0), 1.0);
    }
  } else {
    let _o2m = _oem.x * _o9k + _oem.y * _o9l;
    let _o4g = _o4f * (_oa2 * _o9k + _oa8 * _o9l);
    let _ooj = _oax(_oaw((_o2m + _o4g) * _oen.z, 0.0), 1.0);
    let g = _ok9 + _ooj * (_oka - _ok9);
    let gg = g * g;
    let _oc3 = fma(gg, _oa0, _o4f * _o9y);
    let _okg = fma(gg, _o2m, _o4g);
    let _o8o = fma(gg, fma(gg, _o8p, _o4f * _opf), _o4f * _o4f);
    let cross = _o9k * _oa8 - _o9l * _oa2;
    let _o7n = cross * cross;
    let _o7v = _o7u * _oc3;
    if (_o7n > _o7v) {
      return fragment;
    }
    let _okh = _oc3 - _okg;
    let _oge = _oax(_okg, _okh);
    if (_oge < 0.0 && _oge * _oge > _o7v * _o8o) {
      return fragment;
    }
    _of6(_odn);
    _oq3 = _one(_oru.x, _oru.y, g);
    let _oda = inverseSqrt(_oc3);
    let _ol6 = _oda * inverseSqrt(_o8o);
    let _od8 = _oda * _oda;
    let _oa6 = _o7n * _od8;
    let _opt = _okg * _ol6;
    let _opu = _okh * _ol6;
    let a = fma(-2.0, _oa6, 1.0);
    let _oiq = a > 0.0;
    let _o2y = select(1.0, a, _oiq);
    let _of8 = log2(_o2y);
    let _odc = inverseSqrt(0.5 * _o2y);
    let _o4z = 0.5 * _o2y * _odc;
    let _oqf = _oax(_oaw(-_opt * _odc, -1.0), 1.0);
    let _oqe = _oax(_oaw(_opu * _odc, -1.0), 1.0);
    let _of5 = _o4h(abs(_oqf));
    let _och = _o4h(abs(_oqe));
    let _oip = _oqf >= 0.0;
    let _ogf = _oqe <= 0.0;
    let _o8b = _o4i(_of5, _och, _oip, _ogf);
    let _of4 = _oiq && _o8b > 0.0;
    let _obg = _on9[0];
    let _o2x = exp2(_obg * _of8);
    if (_op2) {
      let _oeg = _oc3 * _ol6;
      let _ob0 = _okg * _od8;
      let _o8a = select(0.0, _o8b, _of4);
      let _ob1 = _of4 && _oeg * (_o4z * _o8a) >= _o5;
      let _o8c = select(1.0, _o8a, _ob1);
      let _o8h = _of5._oj8 - _och._oj8;
      let _ogx = select(0.0, _o4z * _o8h / (2.0 * (_obg + 1.0) * _oeg * _o8c), _ob1);
      fragment._oog = _oax(_oaw(_ob0 + _ogx, 0.0), 1.0);
    }
    let _oef = _o4z * _o2x * _o8b;
    _oos = select(0.0, _oef * _oda, _of4);
  }
  fragment._oe4 = true;
  fragment._oor = _oq3 * _oos;
  return fragment;
}
fn _op0(_omq: u32, _oh4: vec3f, _okc: vec3f, _ops: f32) -> vec3f {
  let _oaa = 12u * _omq;
  let _oim = vec3f(_oox[_oaa], _oox[_oaa + 1u], _oox[_oaa + 2u]);
  let _oab = vec3f(_oox[_oaa + 3u], _oox[_oaa + 4u], _oox[_oaa + 5u]);
  let _oac = vec3f(_oox[_oaa + 6u], _oox[_oaa + 7u], _oox[_oaa + 8u]);
  let _oks = _oox[_oaa + 9u];
  let _ogx = _oh4 - _oim;
  let _ogs = _ogx.x * _oab.x + _ogx.y * _oab.y + _ogx.z * _oab.z;
  let _ogt = _ogx.x * _oac.x + _ogx.y * _oac.y + _ogx.z * _oac.z;
  let _o82 = _okc.x * _oab.x + _okc.y * _oab.y + _okc.z * _oab.z;
  let _o83 = _okc.x * _oac.x + _okc.y * _oac.y + _okc.z * _oac.z;
  let _o37 = _o82 * _o82 + _o83 * _o83;
  var _oqd = 0.5;
  if (_o37 != 0.0 && _odk(_o37) && _odk(_ogs) && _odk(_ogt)) {
    let _oei = -(_ogs * _o82 + _ogt * _o83) / _o37;
    let _o57 = _ogs + _oei * _o82;
    let _o5e = _ogt + _oei * _o83;
    let _ojc = _oks * _oks - (_o57 * _o57 + _o5e * _o5e);
    var _ohp = _o57;
    var _ohq = _o5e;
    if (_ojc >= 0.0) {
      let _oc8 = sqrt(_ojc / _o37);
      if (_oei - _oc8 > 0.0) {
        _ohp = _o57 - _oc8 * _o82;
        _ohq = _o5e - _oc8 * _o83;
      } else if (_oei + _oc8 > 0.0) {
        _ohp = _o57 + _oc8 * _o82;
        _ohq = _o5e + _oc8 * _o83;
      }
    }
    if (_odk(_ohp) && _odk(_ohq)) {
      _oqd = atan2(_ohq, _ohp) * 0.15915494309189535 + 0.5;
    }
  }
  let _o3l = i32(_o4r._o3l);
  let _o3f = i32(_o4r._o3f);
  let x = _ops * f32(_o3l - 1);
  let _ocs = min(i32(floor(x)), _o3l - 2);
  let wx = x - f32(_ocs);
  let y = _oqd * f32(_o3f) - 0.5;
  let _obb = floor(y);
  let _odo = ((i32(_obb) % _o3f) + _o3f) % _o3f;
  let _odp = (_odo + 1) % _o3f;
  let wy = y - _obb;
  let _ooz = array<i32, 4>(_ocs * _o3f + _odo, (_ocs + 1) * _o3f + _odo,
                            _ocs * _o3f + _odp, (_ocs + 1) * _o3f + _odp);
  let _or9 = array<f32, 4>((1.0 - wx) * (1.0 - wy), wx * (1.0 - wy),
                             (1.0 - wx) * wy, wx * wy);
  let _o40 = _omq * 3u * _o4r._o3l * _o4r._o3f;
  var _o72 = vec3f(0.0);
  for (var _o64 = 0u; _o64 < 3u; _o64 = _o64 + 1u) {
    var _oqi = 0.0;
    for (var _odx = 0u; _odx < 4u; _odx = _odx + 1u) {
      _oqi = _oqi + _or9[_odx] * _ooy[_o40 + 3u * u32(_ooz[_odx]) + _o64];
    }
    _o72[_o64] = _oqi;
  }
  return _o72;
}
@compute @workgroup_size(16, 16)
fn render_beta(@builtin(local_invocation_id) _of7: vec3u,
               @builtin(local_invocation_index) _oey: u32,
               @builtin(workgroup_id) _orc: vec3u) {
  let _ord = _o5o._ord;
  let _ocf = _o5o._ocf;
  let _op2 = _o4r._op2 != 0u;
  let _oia = vec2u(_orc.x * 16u + _of7.x, _orc.y * 16u + _of7.y);
  let _od4 = _oia.x < _ord && _oia.y < _ocf;
  let _oie = vec2f(f32(_oia.x), f32(_oia.y));
  var _o97 = !_od4;
  let _op4 = _orc.y * _o5o._op8 + _orc.x;
  let _ok4 = _ok5[2u * _op4];
  let _ok3 = _ok5[2u * _op4 + 1u];
  let _ol1 = (_ok3 - _ok4 + _of - 1u) / _of;
  var _opc = i32(_ok3 - _ok4);
  var _oph = 1.0;
  var _o72 = vec3f(0.0);
  var _oke = vec3f(0.0);
  var _okc = vec3f(0.0);
  if (_op2) {
    _oke = _o5o._o5r.xyz;
    let _ogo = (2.0 * _oie.x + 1.0) / f32(_ord) - 1.0;
    let _ogp = (2.0 * _oie.y + 1.0) / f32(_ocf) - 1.0;
    let _ol7 = (_ogo - _o4r._oj0) * _o4r._oon;
    let _ol8 = (_ogp - _o4r._oj1) * _o4r._ooo;
    let _ol9 = 1.0;
    _okc = vec3f(_oqv(0u) * _ol7 + _oqv(1u) * _ol8 + _oqv(2u) * _ol9,
                _oqv(4u) * _ol7 + _oqv(5u) * _ol8 + _oqv(6u) * _ol9,
                _oqv(8u) * _ol7 + _oqv(9u) * _ol8 + _oqv(10u) * _ol9);
  }
  for (var _ocr = 0u; _ocr < _ol1; _ocr = _ocr + 1u) {
    if (_oey == 0u) {
      atomicStore(&_o99, 0u);
    }
    workgroupBarrier();
    if (_o97) {
      atomicAdd(&_o99, 1u);
    }
    workgroupBarrier();
    if (_oey == 0u) {
      _o98 = atomicLoad(&_o99);
    }
    let _ogl = workgroupUniformLoad(&_o98);
    if (_ogl == _of) {
      break;
    }
    let _oj4 = _ocr * _of + _oey;
    if (_ok4 + _oj4 < _ok3) {
      let _o71 = _oio[_ok4 + _oj4];
      _o46[_oey] = _o71;
      let _okl = _oiz[_o71]._okl;
      _on7(_oey, abs(_okl.x));
      let _o4f = _okl.z;
      _o45[_oey] = _o4f;
      _o4a[_oey] = bitcast<i32>(_oiy[_o71].z);
      let _ooq = _oiz[_o71]._o3b;
      let ab = _oiz[_o71].ab;
      let _o2k = ab.xy;
      let _o3r = ab.zw;
      let _oa2 = _o3r.x - _o2k.x;
      let _oa8 = _o3r.y - _o2k.y;
      let _o2n = _ooq.z * _oa2 - _ooq.y * _oa8;
      let _o2o = _ooq.x * _oa8 - _ooq.y * _oa2;
      let _oa0 = _oaw(_oa2 * _o2n + _oa8 * _o2o, 0.0);
      let _o9y = _oa2 * _oa2 + _oa8 * _oa8;
      let _o8p = _oaw(_ooq.x * _ooq.z - _ooq.y * _ooq.y, 0.0);
      let _opf = _ooq.x + _ooq.z;
      if (_omh(_ooq.w)) {
        _o47[_oey] = vec4f(_ooq.z, -_ooq.y, _oa0, _o9y);
        _o48[_oey] = vec4f(_o8p, _opf, _ooq.x, _ooq.w);
      } else {
        _o47[_oey] = vec4f(_o2n, _o2o, _oa0, _o9y);
        _o48[_oey] = vec4f(_o8p, _opf, 1.0 / (_oa0 + _o4f * _o9y), _ooq.w);
      }
      _o41[_oey] = _o2k;
      _o44[_oey] = vec2f(_oa2, _oa8);
      _o42[_oey] = _oiz[_o71]._o4m;
    }
    workgroupBarrier();
    let _o43 = u32(min(i32(_of), _opc));
    for (var _odn = 0u; !_o97 && _odn < _o43; _odn = _odn + 1u) {
      let _o2k = _o41[_odn];
      let _o9n = _o44[_odn];
      let fragment = _oa1(_odn, _o47[_odn], _o48[_odn], _o42[_odn], _o9n.x, _o9n.y,
                                       _oie.x - _o2k.x, _oie.y - _o2k.y, _o45[_odn], _op2);
      if (!fragment._oe4) {
        continue;
      }
      let _o37 = _oax(1.0 - exp(-fragment._oor), 0.9999);
      let _oow = _oph * (1.0 - _o37);
      if (_o37 < _o1g) {
        continue;
      }
      let _o5u = 3u * _o46[_odn];
      var _o4z = vec3f(rgb[_o5u], rgb[_o5u + 1u], rgb[_o5u + 2u]);
      if (_op2) {
        let _omq = _o4a[_odn];
        if (_omq >= 0) {
          _o4z = _o4z + _op0(u32(_omq), _oke, _okc, fragment._oog);
        }
      }
      _o72 = _o72 + _o4z * _o37 * _oph;
      _oph = _oow;
      if (_oow < 0.0001) {
        _o97 = true;
      }
    }
    _opc = _opc - i32(_of);
  }
  if (_od4) {
    let _oij = _ord * _ocf;
    let _oib = _ord * _oia.y + _oia.x;
    _oh8[_oib] = _o72.x + _oph * _o5o._o3x.x;
    _oh8[_oij + _oib] = _o72.y + _oph * _o5o._o3x.y;
    _oh8[2u * _oij + _oib] = _o72.z + _oph * _o5o._o3x.z;
  }
}
