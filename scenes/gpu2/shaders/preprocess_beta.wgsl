struct _o1y {
  _o3p: vec4f,
  _o52: vec4f,
  ab: vec4f,
  _ocw: vec4f,
  _omg: vec4u,
  _omf: vec4f,
  _oj1: vec4f,
  _oj2: vec4f,
  _oj3: vec4f,
};
@group(0) @binding(0) var<storage, read> _ofq: array<u32>;
@group(0) @binding(1) var<storage, read> _oau: array<f32>;
@group(0) @binding(2) var<storage, read> _os9: array<f32>;
@group(0) @binding(3) var<storage, read> _okn: array<vec4u>;
@group(0) @binding(4) var<storage, read> _o8h: array<u32>;
@group(0) @binding(5) var<storage, read_write> _oko: array<_o1y>;
@group(0) @binding(6) var<storage, read_write> _ora: array<u32>;
@group(0) @binding(7) var<uniform> _o69: _oo;
@group(0) @binding(0) var<storage, read> _oaf: array<_o1y>;
@group(0) @binding(1) var<storage, read> _oae: array<u32>;
@group(0) @binding(2) var<storage, read> _oad: array<u32>;
@group(0) @binding(3) var<storage, read_write> _ofu: array<u32>;
@group(0) @binding(4) var<storage, read_write> _ofv: array<u32>;
@group(0) @binding(5) var<storage, read_write> _ojt: array<u32>;
@group(0) @binding(6) var<uniform> _oac: _oo;
const _og: u32 = 16u;
const _oh: u32 = 16u;
const _o2l: f32 = 1e-3;
const _o18: f32 = 3.929278140e-03;
const _o2p: f32 = 0.1;
const _oi: f32 = 0.02;
const _od: f32 = 0.1;
const _o4: f32 = 1.17549435e-38;
const _oe: f32 = 1.41421356;
const _o9: f32 = 0.707106781;
const _o7: f32 = 0.2;
const _o6: f32 = 12.5;
const _oc: f32 = 0.01;
const _oa: f32 = 1.3;
const _o3: f32 = -3.1215594;
const _o2: f32 = 1.8495809;
const _ob: f32 = 1.44269504;
const _o2k = array<f32, 63>(
  -1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
  0.86907756, -0.08104082, 0.012049758, -0.00021792683, 2.1956479e-05, -1.45608055e-05, -2.4834957e-05,
  -0.70016533, 0.17784852, -0.029768402, 0.0013841696, -0.0002165212, 0.00020030937, 0.000181285,
  0.538863, -0.25318372, 0.051725097, -0.0043851244, 0.00028628978, -0.0007355512, -0.0004591238,
  -0.39315897, 0.28637674, -0.07442167, 0.010118952, -3.2378295e-05, 0.0011633757, 0.000537747,
  0.25465247, -0.25353765, 0.08320036, -0.016473958, 0.00047484812, -0.00091163174, -0.00032065576,
  -0.12885943, 0.15803069, -0.06287364, 0.016344883, -0.0015109606, 0.00043000313, 0.00010007449,
  0.04232212, -0.059212293, 0.027284678, -0.008595316, 0.0013526595, -0.00018219583, -1.2701726e-05,
  -0.006454065, 0.00980119, -0.005036595, 0.0018203161, -0.0003864131, 5.108729e-05, -1.2723773e-06);
const _o2j = array<f32, 7>(
  0.9317711, -0.04327248, 0.0059742252, 8.372514e-06, -1.3490912e-05, 1.0639736e-06, 1.9153707e-07);
const _o2i = array<f32, 7>(
  1.0743952, 0.049604684, -0.0057441797, -0.0003010808, 2.6747155e-05, 7.308961e-07, -3.6029135e-07);
var<private> _op7: array<f32, 11>;
var<private> _oo4: array<f32, 5>;
fn _osz(_ofd: u32) -> f32 {
  return _o69._osu[_ofd >> 2u][_ofd & 3u];
}
fn _ok9(_ofd: u32) -> f32 {
  return _o69._oku[_ofd >> 2u][_ofd & 3u];
}
fn _oa5(x: vec3f, y: vec3f) -> f32 {
  return x.x * y.x + x.y * y.y + x.z * y.z;
}
fn _okw(_ojb: vec3f) -> vec4f {
  var _oiv: vec4f;
  for (var r = 0u; r < 4u; r = r + 1u) {
    _oiv[r] = _obt(_ojb.z, _ok9(8u + r), _obt(_ojb.x, _ok9(r), _ojb.y * _ok9(4u + r))) + _ok9(12u + r);
  }
  return _oiv;
}
fn _osv(_ojb: vec3f) -> f32 {
  return _obt(_ojb.z, _osz(10u), _obt(_ojb.x, _osz(2u), _ojb.y * _osz(6u))) + _osz(14u);
}
fn _oi0(_osh: f32, size: u32) -> f32 {
  let _on4 = f32(size);
  return _obt(_osh, _on4, _on4 - 1.0) * 0.5;
}
fn _oe6(x: f32, y: f32) -> f32 {
  let _o3y = abs(x);
  let _o43 = abs(y);
  let _o4z = max(_o3y, _o43);
  let _ooo = min(_o3y, _o43);
  if (_ooo == 0.0) {
    return _o4z;
  }
  return sqrt(_obt(_o4z, _o4z, _ooo * _ooo));
}
struct _o1m {
  r: mat3x3f,
  _on4: vec3f,
  _obk: f32,
  _oh2: vec3f,
  _oh3: vec3f,
  _o65: f32,
  _o66: f32,
  _o67: f32,
};
fn _ofr(_omw: u32, _of8: vec3f, _ofb: vec3f) -> _o1m {
  var _oc3: _o1m;
  let _orw = 8u * _omw;
  let w = _os9[_orw];
  let x = _os9[_orw + 1u];
  let y = _os9[_orw + 2u];
  let z = _os9[_orw + 3u];
  _oc3.r = mat3x3f(
      vec3f(1.0 - 2.0 * (y * y + z * z), 2.0 * (x * y + w * z), 2.0 * (x * z - w * y)),
      vec3f(2.0 * (x * y - w * z), 1.0 - 2.0 * (x * x + z * z), 2.0 * (y * z + w * x)),
      vec3f(2.0 * (x * z + w * y), 2.0 * (y * z - w * x), 1.0 - 2.0 * (x * x + y * y)));
  _oc3._on4 = vec3f(_os9[_orw + 4u], _os9[_orw + 5u], _os9[_orw + 6u]);
  _oc3._obk = _os9[_orw + 7u];
  _oc3._o65 = 0.0;
  _oc3._o66 = 0.0;
  _oc3._o67 = 0.0;
  for (var _of3 = 0u; _of3 < 3u; _of3 = _of3 + 1u) {
    let _o7v = _oc3.r[_of3];
    let _ojc = _of8.x * _o7v.x + _of8.y * _o7v.y + _of8.z * _o7v.z;
    let _ojd = _ofb.x * _o7v.x + _ofb.y * _o7v.y + _ofb.z * _o7v.z;
    _oc3._oh2[_of3] = _ojc * _oc3._on4[_of3];
    _oc3._oh3[_of3] = _ojd * _oc3._on4[_of3];
    _oc3._o65 = _oc3._o65 + _oc3._oh2[_of3] * _oc3._oh2[_of3];
    _oc3._o66 = _oc3._o66 + _oc3._oh2[_of3] * _oc3._oh3[_of3];
    _oc3._o67 = _oc3._o67 + _oc3._oh3[_of3] * _oc3._oh3[_of3];
  }
  return _oc3;
}
struct _o1 {
  _orm: f32,
  _om8: f32,
  _oi6: f32,
  _okg: bool,
  _ohg: f32,
  _ob0: bool,
};
fn _o3m(_oc3: _o1m, _of8: vec3f, _ofb: vec3f, _om5: vec3f,
                     _oaz: f32, _ob5: f32) -> _o1 {
  var _obg: _o1;
  let _on5 = _oc3._on4.x;
  let _on6 = _oc3._on4.y;
  let _on7 = _oc3._on4.z;
  _obg._orm = 0.5 * _on5 * (_on6 + _on7);
  let _oiu = vec3f(_on6 * _on7, _on5 * _on7, _on5 * _on6);
  var _oqx: vec3f;
  var _oga = 0.0;
  for (var _of3 = 0u; _of3 < 3u; _of3 = _of3 + 1u) {
    let _o7v = _oc3.r[_of3];
    let _om6 = _om5.x * _o7v.x + _om5.y * _o7v.y + _om5.z * _o7v.z;
    _oqx[_of3] = _om6 * _oiu[_of3];
    _oga = _obu(_oga, abs(_oqx[_of3]));
  }
  let _oeu = select(0.0, 1.0 / _oga, _oga > 0.0);
  var _opv = 0.0;
  for (var _of3 = 0u; _of3 < 3u; _of3 = _of3 + 1u) {
    let _onm = _oqx[_of3] * _oeu;
    _opv = _opv + _onm * _onm;
  }
  let _omr = sqrt(_opv);
  _obg._om8 = _oga * _omr;
  let _oi5 = vec3f(_of8.y * _ofb.z - _of8.z * _ofb.y,
                     _of8.z * _ofb.x - _of8.x * _ofb.z,
                     _of8.x * _ofb.y - _of8.y * _ofb.x);
  _obg._oi6 = sqrt(_oi5.x * _oi5.x + _oi5.y * _oi5.y + _oi5.z * _oi5.z);
  _obg._okg = _on5 > 0.0 && _on6 > 0.0 && _on7 > 0.0;
  _obg._ohg = 0.0;
  for (var _of3 = 0u; _of3 < 3u; _of3 = _of3 + 1u) {
    let _oan = -_ob5 * _oc3._oh2[_of3] + _oaz * _oc3._oh3[_of3];
    _obg._ohg = _obg._ohg + _oan * _oan;
  }
  _obg._ob0 = _oaz == 0.0 && _ob5 == 0.0;
  return _obg;
}
fn _obj(_ocs: f32) {
  let _oll = _obt(_ocs, -0.3, 0.3);
  let _olm = _obt(_ocs, -5.0 / 21.0, 10.0 / 21.0);
  let _oln = _obt(_ocs, -7.0 / 36.0, 21.0 / 36.0);
  _oo4[0] = 1.0;
  _oo4[1] = _ocs * (-1.0 / 3.0);
  _oo4[2] = _oo4[1] * _oll;
  _oo4[3] = _oo4[2] * _olm;
  _oo4[4] = _oo4[3] * _oln;
}
struct _op {
  _oqa: f32, _oqb: f32, _oqc: f32, _oqd: f32, _oqe: f32, _oqf: f32,
};
fn _o6q(_o2r: f32, _o2s: f32, _o2t: f32, _o2u: f32, _o2y: f32, _o2z: f32, _o30: f32, _oq8: _op) -> f32 {
  var _o38 = _o2r;
  _o38 = _obt(_o2s, _oq8._oqa, _o38);
  _o38 = _obt(_o2t, _oq8._oqb, _o38);
  _o38 = _obt(_o2u, _oq8._oqc, _o38);
  _o38 = _obt(_o2y, _oq8._oqd, _o38);
  _o38 = _obt(_o2z, _oq8._oqe, _o38);
  _o38 = _obt(_o30, _oq8._oqf, _o38);
  return _o38;
}
fn _op6(_ocs: f32) {
  _op7[0] = _ocs;
  let _od0 = _ocs + 1.0;
  let r = inverseSqrt(_od0);
  let z = _obt(r, _o3, _o2);
  let _otz = z + z;
  var _oq8: _op;
  _oq8._oqa = z;
  _oq8._oqb = _obt(_otz, _oq8._oqa, -1.0);
  _oq8._oqc = _obt(_otz, _oq8._oqb, -_oq8._oqa);
  _oq8._oqd = _obt(_otz, _oq8._oqc, -_oq8._oqb);
  _oq8._oqe = _obt(_otz, _oq8._oqd, -_oq8._oqc);
  _oq8._oqf = _obt(_otz, _oq8._oqe, -_oq8._oqd);
  let _o8w = _o6q(_o2k[0], _o2k[1], _o2k[2], _o2k[3], _o2k[4], _o2k[5], _o2k[6], _oq8);
  let _o8x = _o6q(_o2k[7], _o2k[8], _o2k[9], _o2k[10], _o2k[11], _o2k[12], _o2k[13], _oq8);
  let _o8y = _o6q(_o2k[14], _o2k[15], _o2k[16], _o2k[17], _o2k[18], _o2k[19], _o2k[20], _oq8);
  let _o8z = _o6q(_o2k[21], _o2k[22], _o2k[23], _o2k[24], _o2k[25], _o2k[26], _o2k[27], _oq8);
  let _o90 = _o6q(_o2k[28], _o2k[29], _o2k[30], _o2k[31], _o2k[32], _o2k[33], _o2k[34], _oq8);
  let _o91 = _o6q(_o2k[35], _o2k[36], _o2k[37], _o2k[38], _o2k[39], _o2k[40], _o2k[41], _oq8);
  let _o92 = _o6q(_o2k[42], _o2k[43], _o2k[44], _o2k[45], _o2k[46], _o2k[47], _o2k[48], _oq8);
  let _o93 = _o6q(_o2k[49], _o2k[50], _o2k[51], _o2k[52], _o2k[53], _o2k[54], _o2k[55], _oq8);
  let _o94 = _o6q(_o2k[56], _o2k[57], _o2k[58], _o2k[59], _o2k[60], _o2k[61], _o2k[62], _oq8);
  let g = _o6q(_o2j[0], _o2j[1], _o2j[2], _o2j[3], _o2j[4],
                _o2j[5], _o2j[6], _oq8);
  let _ocp = _o6q(_o2i[0], _o2i[1], _o2i[2],
                        _o2i[3], _o2i[4], _o2i[5],
                        _o2i[6], _oq8);
  let _ob8 = r * g;
  let _oet = (_od0 * r) * _ocp;
  _op7[1] = _ob8;
  _op7[2] = _o8w;
  var _okh = _oet;
  _op7[3] = _o8x * _okh;
  _okh = _okh * _oet;
  _op7[4] = _o8y * _okh;
  _okh = _okh * _oet;
  _op7[5] = _o8z * _okh;
  _okh = _okh * _oet;
  _op7[6] = _o90 * _okh;
  _okh = _okh * _oet;
  _op7[7] = _o91 * _okh;
  _okh = _okh * _oet;
  _op7[8] = _o92 * _okh;
  _okh = _okh * _oet;
  _op7[9] = _o93 * _okh;
  _okh = _okh * _oet;
  _op7[10] = _o94 * _okh;
  _okh = _okh * _oet;
}
struct _o19 {
  _osm: f32,
};
fn _o4x(_osh: f32) -> _o19 {
  let _ocs = _op7[0];
  let _oiq = _obu(_obt(-_osh, _osh, 1.0), _o4);
  let _oh0 = log2(_oiq);
  let _okx = exp2((_ocs + 1.0) * _oh0);
  var _o38 = _op7[10];
  _o38 = _obt(_o38, _osh, _op7[9]);
  _o38 = _obt(_o38, _osh, _op7[8]);
  _o38 = _obt(_o38, _osh, _op7[7]);
  _o38 = _obt(_o38, _osh, _op7[6]);
  _o38 = _obt(_o38, _osh, _op7[5]);
  _o38 = _obt(_o38, _osh, _op7[4]);
  _o38 = _obt(_o38, _osh, _op7[3]);
  _o38 = _obt(_o38, _osh, _op7[2]);
  _o38 = _obt(_o38, _osh, _op7[1]);
  let _o84 = _okx * _o38;
  let _orw = _osh * _osh;
  var _opv = _oo4[4];
  _opv = _obt(_opv, _orw, _oo4[3]);
  _opv = _obt(_opv, _orw, _oo4[2]);
  _opv = _obt(_opv, _orw, _oo4[1]);
  _opv = _obt(_opv, _orw, _oo4[0]);
  var _oap: _o19;
  _oap._osm = select(_op7[1] - _o84, _opv * _osh, _osh <= _od);
  return _oap;
}
const _ok: u32 = 0u;
const _oj: u32 = 1u;
const _ol: u32 = 2u;
struct _o1t {
  _o5c: u32,
  _oat: f32,
  _ojb: f32,
};
fn _o41(_og1: f32) -> _o1t {
  var _ojx: _o1t;
  _ojx._oat = 0.0;
  let _ocs = _op7[0];
  if (_og1 < _o2p) {
    _ojx._o5c = _ok;
    let _o4g = _obt(-0.3 * _og1, _og1, 1.0);
    let _okh = exp2(_ocs * log2(_o4g));
    _ojx._ojb = _obt(5.0 / 9.0, _okh, 4.0 / 9.0);
  } else if (_og1 <= _oe) {
    _ojx._o5c = _oj;
    let _osh = _og1 * _o9;
    _ojx._oat = _o4x(_osh)._osm;
    _ojx._ojb = _ojx._oat / _osh;
  } else {
    _ojx._o5c = _ol;
    _ojx._ojb = _oe * _op7[1] / _og1;
  }
  return _ojx;
}
fn _os8(_og5: f32, g: f32) -> f32 {
  let _ojx = _o41(_og5 / g);
  return g * g / _ojx._ojb;
}
fn _opd(a: f32, _ohv: f32, w: f32, g: f32, _oms: f32,
                           _og1: f32) -> f32 {
  let _ojx = _o41(_og1);
  if (_ojx._o5c == _ok) {
    return a * g * g * _ohv / _ojx._ojb;
  }
  let _ob7 = select(_op7[1], _ojx._oat, _ojx._o5c == _oj);
  return a * g * _oms / (_oe * w * _ob7);
}
fn _opb(_odg: f32, _o9j: f32, _og1: f32) -> f32 {
  let _ocs = _op7[0];
  if (_og1 < _o2p) {
    let _o4g = _obt(-0.3, _odg / _o9j, 1.0);
    let _okh = exp2(_ocs * log2(_o4g));
    return _obt(5.0 / 9.0, _okh, 4.0 / 9.0) * inverseSqrt(_o9j);
  }
  let _ojx = _o41(_og1);
  let _ob7 = select(_op7[1], _ojx._oat, _ojx._o5c == _oj);
  return _oe * _ob7 * inverseSqrt(_odg);
}
fn _opa(_obg: _o1, g: f32, _o85: vec3f,
                          _oqs: vec3f, _oaz: f32, _ob5: f32) -> f32 {
  let _ou1 = !_obg._ob0 && !(_obg._ohg > 0.0);
  let a = _obg._orm;
  let w = _obg._om8;
  let _ohv = _obg._oi6;
  var _os7 = 0.0;
  if (!_ou1) {
    let _oms = sqrt(_obg._ohg);
    let _og1 = _oms / (g * _ohv * w);
    _os7 = _opd(a, _ohv, w, g, _oms, _og1);
  }
  let _opm = g * g - 1.0;
  let _o5l = _o85.x + _opm * _oqs.x;
  let _o5o = _o85.y + _opm * _oqs.y;
  let _o5v = _o85.z + _opm * _oqs.z;
  let _o9j = _o5l * _o5v - _o5o * _o5o;
  let _o3a = _o5v * _oaz - _o5o * _ob5;
  let _o3b = _o5l * _ob5 - _o5o * _oaz;
  let _odi = _oaz * _o3a + _ob5 * _o3b;
  let _odh = select(0.0, _odi, _odi > 0.0);
  let _og4 = sqrt(_odh / _o9j);
  let _obl = _opb(_odh, _o9j, _og4);
  return _os7 * _obl;
}
struct _oy {
  _oio: bool,
  a: vec4f,
  b: vec4f,
};
fn _o7o(_ojj: vec4f, _ojv: vec4f) -> _oy {
  var _oml: _oy;
  _oml._oio = false;
  let _o8v = _ojv - _ojj;
  let _oi8 = _ojj.w - _o2l;
  let _o9d = _o8v.w;
  var _oq9 = 0.0;
  var _oqa = 1.0;
  if (_o9d == 0.0) {
    if (_oi8 < 0.0) {
      return _oml;
    }
  } else {
    let _orf = -_oi8 / _o9d;
    if (_o9d > 0.0) {
      _oq9 = _obu(_oq9, _orf);
    } else {
      _oqa = _obv(_oqa, _orf);
    }
  }
  if (_oq9 > _oqa) {
    return _oml;
  }
  for (var _o5j = 0u; _o5j < 4u; _o5j = _o5j + 1u) {
    _oml.a[_o5j] = _obt(_o8v[_o5j], _oq9, _ojj[_o5j]);
    _oml.b[_o5j] = _obt(_o8v[_o5j], _oqa, _ojj[_o5j]);
  }
  _oml._oio = true;
  return _oml;
}
const _o2f: u32 = 1u;
const _o2g: u32 = 2u;
const _o2h: u32 = 4u;
struct _o1q {
  _ost: vec2f,
  _osk: vec2f,
  _osp: vec2f,
  _otb: f32,
  _otc: f32,
  _ofj: f32,
  _ofl: f32,
  _oh1: f32,
  _obs: u32,
};
fn _oj6(_ojb: _o1y) -> _o1q {
  var _oif: _o1q;
  _oif._ost = _ojb._oj1.xy;
  _oif._osk = _ojb._oj1.zw;
  _oif._osp = _ojb._oj2.xy;
  _oif._otb = _ojb._oj2.z;
  _oif._otc = _ojb._oj2.w;
  _oif._ofj = _ojb._oj3.x;
  _oif._ofl = _ojb._oj3.y;
  _oif._oh1 = _ojb._oj3.z;
  _oif._obs = bitcast<u32>(_ojb._oj3.w);
  return _oif;
}
struct _o1z {
  _ojc: vec2f,
  _ojd: vec2f,
  _oje: vec2f,
  _ojf: vec2f,
};
struct _o10 {
  _ohh: _o1z,
  _oar: _o1z,
  _oas: _o1z,
};
fn _o3i(_ojb: vec2f, a: vec2f, _oaj: vec2f) -> f32 {
  return _obt(_ojb.y - a.y, _oaj.y, (_ojb.x - a.x) * _oaj.x);
}
fn _oj9(a: vec2f, _oaj: vec2f, _ojc: vec2f, _ojd: vec2f, _oh2: vec2f, _oh3: vec2f) -> _o1z {
  let _oq2 = _o3i(_ojc, a, _oaj) > _o3i(_ojd, a, _oaj);
  let _oq1 = _o3i(_oh2, a, _oaj) > _o3i(_oh3, a, _oaj);
  return _o1z(select(_ojc, _ojd, _oq2), select(_ojd, _ojc, _oq2),
              select(_oh3, _oh2, _oq1), select(_oh2, _oh3, _oq1));
}
fn _oim(a: vec2f, _on4: f32, _osh: vec2f) -> vec2f {
  return vec2f(_obt(_on4, _osh.x, a.x), _obt(_on4, _osh.y, a.y));
}
fn _oj4(a: vec2f, b: vec2f, _ojg: f32, _oif: _o1q) -> _o10 {
  let _oaj = b - a;
  let _oge = _oe6(_oaj.x, _oaj.y);
  let _oo8 = _oge < 1e-4;
  let _ond = select(_oaj, vec2f(1.0, 0.0), _oo8);
  let _one = select(_oge, 1.0, _oo8);
  let _ohv = vec2f(-_ond.y / _one, _ond.x / _one);
  let _orw = vec2f(_ond.x / _one, _ond.y / _one);
  let _o34 = _oim(a, -_oif._otb, _oif._ost);
  let _o35 = _oim(a, _oif._otb, _oif._ost);
  let _o4a = _oim(b, -_oif._otc, _oif._ost);
  let _o4b = _oim(b, _oif._otc, _oif._ost);
  var _o32: vec2f;
  var _o31: vec2f;
  var _o48: vec2f;
  var _o47: vec2f;
  if ((_oif._obs & _o2g) != 0u) {
    let _o2r = _oim(a, -_ojg, _orw);
    _o32 = _oim(_o2r, _oif._otb, _ohv);
    _o31 = _oim(_o2r, -_oif._otb, _ohv);
  } else {
    let _o2r = _oim(a, -_oif._ofj, _oaj);
    _o32 = _oim(_o2r, _oif._otb, _oif._osk);
    _o31 = _oim(_o2r, -_oif._otb, _oif._osk);
  }
  if ((_oif._obs & _o2h) != 0u) {
    let _o45 = _oim(b, _ojg, _orw);
    _o48 = _oim(_o45, _oif._otc, _ohv);
    _o47 = _oim(_o45, -_oif._otc, _ohv);
  } else {
    let _o45 = _oim(b, _oif._ofl, _oaj);
    _o48 = _oim(_o45, _oif._otc, _oif._osp);
    _o47 = _oim(_o45, -_oif._otc, _oif._osp);
  }
  return _o10(_o1z(_o34, _o4a, _o4b, _o35),
                 _oj9(a, _oaj, _o35, _o32, _o34, _o31),
                 _oj9(a, _oaj, _o4b, _o48, _o4a, _o47));
}
fn _o4e(_ojc: vec2f, _ojd: vec2f, _otx: f32, _otw: f32, _olu: vec2f) -> vec2f {
  var _ott = _olu.x;
  var _otr = _olu.y;
  if (_ojc.y >= _otx && _ojc.y <= _otw) {
    _ott = _obv(_ott, _ojc.x);
    _otr = _obu(_otr, _ojc.x);
  }
  if (_obu(_ojc.y, _ojd.y) < _otx || _obv(_ojc.y, _ojd.y) > _otw) {
    return vec2f(_ott, _otr);
  }
  let _oah = _ojd.y - _ojc.y;
  if (_oah != 0.0) {
    let _oqm = _obv(_obu((_otx - _ojc.y) / _oah, 0.0), 1.0);
    let _oqv = _obv(_obu((_otw - _ojc.y) / _oah, 0.0), 1.0);
    let _otp = _obt(_oqm, _ojd.x - _ojc.x, _ojc.x);
    let _otq = _obt(_oqv, _ojd.x - _ojc.x, _ojc.x);
    _ott = _obv(_ott, _obv(_otp, _otq));
    _otr = _obu(_otr, _obu(_otp, _otq));
  } else {
    _ott = _obv(_ott, _obv(_ojc.x, _ojd.x));
    _otr = _obu(_otr, _obu(_ojc.x, _ojd.x));
  }
  return vec2f(_ott, _otr);
}
fn _o4f(_ol1: _o1z, _otx: f32, _otw: f32, _olu: vec2f) -> vec2f {
  var r = _o4e(_ol1._ojc, _ol1._ojd, _otx, _otw, _olu);
  r = _o4e(_ol1._ojd, _ol1._oje, _otx, _otw, r);
  r = _o4e(_ol1._oje, _ol1._ojf, _otx, _otw, r);
  return _o4e(_ol1._ojf, _ol1._ojc, _otx, _otw, r);
}
fn _oij(_ojc: vec2f, _ojd: vec2f, _otx: f32, _otw: f32, _olu: vec2f) -> vec2f {
  var _ott = _olu.x;
  var _otr = _olu.y;
  if (_ojc.y >= _otx && _ojc.y <= _otw) {
    _ott = _obv(_ott, _ojc.x);
    _otr = _obu(_otr, _ojc.x);
  }
  let _oah = _ojd.y - _ojc.y;
  if (_oah != 0.0) {
    let _oq9 = (_otx - _ojc.y) / _oah;
    if (_oq9 > 0.0 && _oq9 < 1.0) {
      let x = _obt(_oq9, _ojd.x - _ojc.x, _ojc.x);
      _ott = _obv(_ott, x);
      _otr = _obu(_otr, x);
    }
    let _oqa = (_otw - _ojc.y) / _oah;
    if (_oqa > 0.0 && _oqa < 1.0) {
      let x = _obt(_oqa, _ojd.x - _ojc.x, _ojc.x);
      _ott = _obv(_ott, x);
      _otr = _obu(_otr, x);
    }
  }
  return vec2f(_ott, _otr);
}
fn _oii(a: vec2f, b: vec2f, _oji: f32, _ojg: f32) -> _o1z {
  let _o9u = b - a;
  let _oge = _oe6(_o9u.x, _o9u.y);
  let _oo8 = _oge < 1e-4;
  let _ond = select(_o9u, vec2f(1.0, 0.0), _oo8);
  let _one = select(_oge, 1.0, _oo8);
  let _os3 = vec2f(-_ond.y / _one, _ond.x / _one);
  let _os2 = vec2f(_ond.x / _one, _ond.y / _one);
  let _oki = _oji + _oi;
  let _ojj = _ojg + _oi;
  let _o5z = vec2f(_obt(-_os2.x, _ojj, _obt(_os3.x, _oki, a.x)),
                 _obt(-_os2.y, _ojj, _obt(_os3.y, _oki, a.y)));
  let _o5k = vec2f(_obt(-_os2.x, _ojj, _obt(-_os3.x, _oki, a.x)),
                 _obt(-_os2.y, _ojj, _obt(-_os3.y, _oki, a.y)));
  let _o5y = vec2f(_obt(_os2.x, _ojj, _obt(_os3.x, _oki, b.x)),
                 _obt(_os2.y, _ojj, _obt(_os3.y, _oki, b.y)));
  let _o5r = vec2f(_obt(_os2.x, _ojj, _obt(-_os3.x, _oki, b.x)),
                 _obt(_os2.y, _ojj, _obt(-_os3.y, _oki, b.y)));
  return _o1z(_o5k, _o5r, _o5y, _o5z);
}
fn _oow(_olu: vec2f, _oth: u32, _orr: i32, _ors: i32, _oh1: f32) -> vec3u {
  let _ot6 = f32(_oth - 1u);
  let _otu = _obv(_obu(_olu.x - _oh1, 0.0), _ot6);
  let _ots = _obv(_obu(_olu.y + _oh1, 0.0), _ot6);
  let _oq4 = max(_orr, i32(floor(_otu * 0.0625)));
  let _oq5 = min(_ors, i32(floor(_ots * 0.0625)) + 1);
  let _oio = _olu.y >= _olu.x && _oq5 > _oq4;
  return select(vec3u(0u), vec3u(u32(_oq4), u32(_oq5), 1u), _oio);
}
fn _or9(_omz: _o1z, _oif: _o1q, _o5j: _o10, _ort: u32, _oth: u32,
                         _orr: u32, _ors: u32) -> vec3u {
  let _otx = f32(_ort * _oh);
  let _otw = f32(_ort * _oh + (_oh - 1u));
  var r = _oij(_omz._ojc, _omz._ojd, _otx, _otw, vec2f(3.4e38, -3.4e38));
  r = _oij(_omz._ojd, _omz._oje, _otx, _otw, r);
  r = _oij(_omz._oje, _omz._ojf, _otx, _otw, r);
  r = _oij(_omz._ojf, _omz._ojc, _otx, _otw, r);
  let _omg = _oow(r, _oth, i32(_orr), i32(_ors), 0.0);
  let _oip = _otx - _oif._oh1;
  let _oin = _otw + _oif._oh1;
  var _ol1 = _o4f(_o5j._ohh, _oip, _oin, vec2f(3.4e38, -3.4e38));
  _ol1 = _o4f(_o5j._oar, _oip, _oin, _ol1);
  _ol1 = _o4f(_o5j._oas, _oip, _oin, _ol1);
  let _oj8 = _oow(_ol1, _oth, i32(_omg.x), i32(_omg.y), _oif._oh1);
  let _osf = _omg.z == 0u || (_oif._obs & _o2f) != 0u;
  return select(_oj8, _omg, _osf);
}
fn _oks(a: f32, b: f32, _o5j: f32, _o8v: f32) -> f32 {
  let _ojb = _orp(a, b);
  let _ol1 = _orp(_o5j, _o8v);
  let _on4 = _orq(_ojb.x, -_ol1.x);
  let _ogw = (_ojb.y - _ol1.y) + _on4.y;
  return _on4.x + _ogw;
}
fn _oj7(_ojb: vec2f, a: vec2f, _oaj: vec2f, _oam: f32) -> f32 {
  let _oag = _ojb.x - a.x;
  let _oah = _ojb.y - a.y;
  let _oq8 = _obv(_obu((_oag * _oaj.x + _oah * _oaj.y) / _oam, 0.0), 1.0);
  return _oe6(_oag - _oq8 * _oaj.x, _oah - _oq8 * _oaj.y);
}
fn _obn(_osh: vec2f) -> bool {
  return _of0(_osh.x) && _of0(_osh.y);
}
struct _o1r {
  w: f32,
  _osh: vec2f,
  _ofk: f32,
};
fn _oj5(g: f32, _on9: f32, _o63: vec2f, _ohv: vec2f, _o9k: f32, _orj: f32, _o4v: f32,
               _ofd: f32, _og0: f32) -> _o1r {
  let gg = g * g;
  let _onb = gg * _on9 + _o4v;
  let _o9n = gg * gg * _o9k + gg * _o4v * _orj + _o4v * _o4v;
  var _oap: _o1r;
  _oap.w = _ofd * sqrt(_onb);
  _oap._osh = vec2f((gg * _o63.x + _o4v * _ohv.x) / _onb, (gg * _o63.y + _o4v * _ohv.y) / _onb);
  _oap._ofk = _ofd * sqrt(_o9n / _onb) / _og0;
  return _oap;
}
fn _opq(g: f32, _oax: f32, _oav: f32, _o9k: f32, _orj: f32, _o4v: f32,
                       _o8p: f32) -> bool {
  let gg = g * g;
  let _odg = _obt(gg, _oax, _o4v * _oav);
  let _o9j = _obt(gg, _obt(gg, _o9k, _o4v * _orj), _o4v * _o4v);
  let _o8q = _o8p * _odg;
  let _okr = _o8q * _o9j;
  return !_of0(_okr) || _okr > 1e37;
}
fn _o87(_ojb: vec2f, a: vec2f, _oaj: vec2f, _oam: f32, _omc: vec2f) -> vec2f {
  let _obm = _omc.y != 0.0 && _obn(_ojb);
  return vec2f(_obu(_omc.x, _oj7(_ojb, a, _oaj, _oam)), select(0.0, 1.0, _obm));
}
fn _ole(_ol1: _o1z, a: vec2f, _oaj: vec2f, _oam: f32, _omc: vec2f) -> vec2f {
  var r = _o87(_ol1._ojc, a, _oaj, _oam, _omc);
  r = _o87(_ol1._ojd, a, _oaj, _oam, r);
  r = _o87(_ol1._oje, a, _oaj, _oam, r);
  return _o87(_ol1._ojf, a, _oaj, _oam, r);
}
fn _o5e(_o5z: vec3f, _o64: vec3f, _om2: f32, _om3: f32, _okc: bool,
                      _o8p: f32, a: vec2f, b: vec2f, _ohv: vec2f, _ojg: f32,
                      _o4v: f32, _oth: u32, _odt: u32) -> _o1q {
  var _oif: _o1q;
  _oif._ost = vec2f(0.0);
  _oif._osk = vec2f(0.0);
  _oif._osp = vec2f(0.0);
  _oif._otb = 0.0;
  _oif._otc = 0.0;
  _oif._ofj = 0.0;
  _oif._ofl = 0.0;
  _oif._oh1 = 0.0;
  _oif._obs = _o2f;
  if (_okc) {
    return _oif;
  }
  let _oaj = b - a;
  let _oam = _oaj.x * _oaj.x + _oaj.y * _oaj.y;
  let _og0 = sqrt(_oam);
  let _ofd = sqrt(_o8p);
  let _o9k = _obu(_oks(_o5z.x, _o5z.z, _o5z.y, _o5z.y), 0.0);
  let _orj = _o5z.x + _o5z.z;
  let _o6o = vec2f(_o64.x * _ohv.x + _o64.y * _ohv.y, _o64.y * _ohv.x + _o64.z * _ohv.y);
  let _ona = _ohv.x * _o6o.x + _ohv.y * _o6o.y;
  _oif._ost = vec2f(_o6o.x / _ona, _o6o.y / _ona);
  let _o63 = vec2f(_o5z.x * _ohv.x + _o5z.y * _ohv.y, _o5z.y * _ohv.x + _o5z.z * _ohv.y);
  let _on9 = _ohv.x * _o63.x + _ohv.y * _o63.y;
  let _oar = _oj5(_om2, _on9, _o63, _ohv, _o9k, _orj, _o4v, _ofd, _og0);
  let _oas = _oj5(_om3, _on9, _o63, _ohv, _o9k, _orj, _o4v, _ofd, _og0);
  _oif._otb = _oar.w;
  _oif._otc = _oas.w;
  _oif._osk = _oar._osh;
  _oif._osp = _oas._osh;
  _oif._ofj = _oar._ofk;
  _oif._ofl = _oas._ofk;
  let _ocq = _obu(_om2, _om3);
  let _ocx = _ocq * _ocq;
  let _ork = _ocx * _orj + 2.0 * _o4v;
  let _o9m = _ocx * _ocx * _o9k + _ocx * _o4v * _orj + _o4v * _o4v;
  let _orw = 5.9604644775390625e-8;
  let r = 16.0 * _orw * _ork * _ork / _o9m;
  let _o99 = _obu(_obu(abs(a.x), abs(a.y)), _obu(abs(b.x), abs(b.y)))
         + f32(_oth) + f32(_odt);
  let _o9b = !(_o9m > 0.0) || !_of0(_o9m) || (_o4v == 0.0 && _o9k == 0.0);
  let _o2w = _o5z.z * _oaj.x - _o5z.y * _oaj.y;
  let _o2x = _o5z.x * _oaj.y - _o5z.y * _oaj.x;
  let _oax = _obu(_oaj.x * _o2w + _oaj.y * _o2x, 0.0);
  let _oav = _oaj.x * _oaj.x + _oaj.y * _oaj.y;
  let _omd = _obu(_o5z.x * _o5z.z - _o5z.y * _o5z.y, 0.0);
  let _ome = _o5z.x + _o5z.z;
  var _obs = 0u;
  if (_opq(_om2, _oax, _oav, _omd, _ome, _o4v, _o8p)) {
    _obs = _obs | _o2g;
  }
  if (_opq(_om2 + (_om3 - _om2), _oax, _oav, _omd, _ome, _o4v, _o8p)) {
    _obs = _obs | _o2h;
  }
  _oif._obs = _obs;
  let _o5j = _oj4(a, b, _ojg, _oif);
  var _omc = _ole(_o5j._ohh, a, _oaj, _oam, vec2f(0.0, 1.0));
  _omc = _ole(_o5j._oar, a, _oaj, _oam, _omc);
  _omc = _ole(_o5j._oas, a, _oaj, _oam, _omc);
  var _obm = _omc.y != 0.0;
  let _o51 = _omc.x;
  _oif._oh1 = r * _o51 + 0.02 + 4.0 * _orw * _o99;
  let _opo = (_obs & _o2g) != 0u;
  let _opp = (_obs & _o2h) != 0u;
  _obm = _obm && _obn(_oif._ost) && _of0(_oif._otb) && _of0(_oif._otc)
      && (_opo || (_obn(_oif._osk) && _of0(_oif._ofj)))
      && (_opp || (_obn(_oif._osp) && _of0(_oif._ofl)))
      && _of0(_o51) && _of0(r) && _of0(_oif._oh1);
  if (_o9b || !_obm) {
    _oif._obs = _o2f;
  }
  return _oif;
}
@compute @workgroup_size(256)
fn preprocess_beta(@builtin(local_invocation_index) _ogj: u32,
                   @builtin(workgroup_id) _otg: vec3u,
                   @builtin(num_workgroups) _oib: vec3u) {
  let _oea = _ogo(_otg, _oib) * _o2q + _ogj;
  if (_oea >= _o8h[_o23]) {
    return;
  }
  let _oos = _ofq[_oea];
  _ora[_oea] = 0u;
  _oko[_oea]._ocw = vec4f(0.0, 0.0, 0.0, 0.0);
  let _o3w = _okn[_oea];
  let _o3k = bitcast<f32>(_o3w.x);
  let _oo6 = bitcast<f32>(_o3w.y);
  let _oif = 6u * _oos;
  let _ojk = vec3f(_oau[_oif], _oau[_oif + 1u], _oau[_oif + 2u]);
  let _ojw = vec3f(_oau[_oif + 3u], _oau[_oif + 4u], _oau[_oif + 5u]);
  let _ogn = vec3f((_ojk.x + _ojw.x) * 0.5, (_ojk.y + _ojw.y) * 0.5, (_ojk.z + _ojw.z) * 0.5);
  let _o9f = _osv(_ogn);
  if (_o9f < _oc) {
    return;
  }
  let _o7m = _o7o(_okw(_ojk), _okw(_ojw));
  if (!_o7m._oio) {
    return;
  }
  let _oth = _o69._oth;
  let _odt = _o69._odt;
  let _o33 = vec2f(_oi0(_o7m.a.x / _o7m.a.w, _oth), _oi0(_o7m.a.y / _o7m.a.w, _odt));
  let _o49 = vec2f(_oi0(_o7m.b.x / _o7m.b.w, _oth), _oi0(_o7m.b.y / _o7m.b.w, _odt));
  let _obk = _o69._o4v;
  let _o6h = _okw(_ogn);
  var _onx = _o6h.w > _o2l && _of0(_o6h.w);
  let _onf = select(1.0, _o6h.w, _onx);
  let _oer = 1.0 / (_onf * _onf);
  let _ogm = _oa * _onf;
  let _o6t = _obv(_obu(_o6h.x, -_ogm), _ogm);
  let _o6u = _obv(_obu(_o6h.y, -_ogm), _ogm);
  let _of6 = _o6t != _o6h.x || _o6u != _o6h.y;
  let _odq = 0.5 * f32(_oth);
  let _odn = 0.5 * f32(_odt);
  let _of8 = vec3f(_odq * (_onf * _ok9(0u) - _o6t * _ok9(3u)) * _oer,
                 _odq * (_onf * _ok9(4u) - _o6t * _ok9(7u)) * _oer,
                 _odq * (_onf * _ok9(8u) - _o6t * _ok9(11u)) * _oer);
  let _ofb = vec3f(_odn * (_onf * _ok9(1u) - _o6u * _ok9(3u)) * _oer,
                 _odn * (_onf * _ok9(5u) - _o6u * _ok9(7u)) * _oer,
                 _odn * (_onf * _ok9(9u) - _o6u * _ok9(11u)) * _oer);
  let _ohm = vec2f(_oi0(_o6h.x / _onf, _oth),
                           _oi0(_o6h.y / _onf, _odt));
  let _oc3 = _ofr(_oos, _of8, _ofb);
  let _ocu = 4.0 * exp2(_oo6 * _ob);
  let _oct = !(_ocu >= _o7 && _ocu <= _o6);
  let _ocs = _obv(_obu(_ocu, _o7), _o6);
  let _of9 = _oc3._obk * _oa5(_of8, _of8);
  let _ofa = _oc3._obk * _oa5(_of8, _ofb);
  let _ofc = _oc3._obk * _oa5(_ofb, _ofb);
  let _o60 = _oc3._o65 + _of9;
  let _o61 = _oc3._o66 + _ofa;
  let _o62 = _oc3._o67 + _ofc;
  let _ok1 = _obk;
  let _o5l = _o60 + _ok1;
  let _o5o = _o61;
  let _o5v = _o62 + _ok1;
  _op6(_ocs);
  _obj(_ocs);
  let _omf = vec4f(select(_ocs, -_ocs, _oct), _ocs, _ok1, 0.0);
  let _om2 = _onf / _o7m.a.w;
  let _om3 = _onf / _o7m.b.w;
  let _o9l = _o5l * _o5v - _o5o * _o5o;
  _onx = _onx && _o9l > 0.0 && _of0(_o9l);
  let _oen = select(0.0, 1.0 / _o9l, _onx);
  let _o6r = _o49 - _o33;
  let _o3a = _o5v * _o6r.x - _o5o * _o6r.y;
  let _o3b = _o5l * _o6r.y - _o5o * _o6r.x;
  let _odg = _o6r.x * _o3a + _o6r.y * _o3b;
  let _odd = _obu(_odg * _oen, 0.0);
  let _og1 = sqrt(_odd);
  let _oeo = select(0.0, 1.0 / _odg, _odd > 1e-8);
  let _okc = !(_og1 > _o2p) || !(_oeo > 0.0);
  let _o6b = _o69._o6c.xyz;
  let _om4 = _ogn - _o6b;
  let _oew = inverseSqrt(_oa5(_om4, _om4));
  var _om5 = _om4 * _oew;
  if (_of6) {
    let _oi7 = vec3f(_of8.y * _ofb.z - _of8.z * _ofb.y,
                    _of8.z * _ofb.x - _of8.x * _ofb.z,
                    _of8.x * _ofb.y - _of8.y * _ofb.x);
    let _oev = inverseSqrt(_oa5(_oi7, _oi7));
    _om5 = _oi7 * _oev;
  }
  let _obg = _o3m(_oc3, _of8, _ofb, _om5, _o6r.x, _o6r.y);
  let _o85 = vec3f(_o5l, _o5o, _o5v);
  let _oqs = vec3f(_o60, _o61, _o62);
  let _omm = _obu(_o3k, 0.0);
  let _ol2 = _omm * _obg._orm * _obg._oi6;
  let _og5 = sqrt(_obg._ohg) / (_obg._oi6 * _obg._om8);
  _onx = _onx && (_obg._ob0 || _obg._ohg > 0.0);
  let _ofg = _opa(_obg, _om2, _o85, _oqs, _o6r.x, _o6r.y);
  let _ofi = _opa(_obg, 1.0, _o85, _oqs, _o6r.x, _o6r.y);
  let _ofh = _opa(_obg, _om3, _o85, _oqs, _o6r.x, _o6r.y);
  let _ojx = _omm * _obu(_ofg, _obu(_ofi, _ofh));
  let _orz = _ol2 * _os8(_og5, _om2);
  let _os1 = _ol2 * _os8(_og5, 1.0);
  let _os0 = _ol2 * _os8(_og5, _om3);
  _onx = _onx && _obg._okg && _of0(_og5)
      && _of0(_orz) && _of0(_os1) && _of0(_os0);
  if (!_onx) {
    return;
  }
  let _o6i = _ohm;
  let _om1 = _o18 / _obu(_ojx, _o18);
  let _o8r = _obu(0.5 * (1.0 - exp2(log2(_om1) / _ocs)), 1e-6);
  let _o9u = _o49 - _o33;
  let _oge = _oe6(_o9u.x, _o9u.y);
  let _oo8 = _oge < 1e-4;
  let _ond = select(_o9u, vec2f(1.0, 0.0), _oo8);
  let _one = select(_oge, 1.0, _oo8);
  let _os3 = vec2f(-_ond.y / _one, _ond.x / _one);
  let _os2 = vec2f(_ond.x / _one, _ond.y / _one);
  let _ofd = sqrt(_o8r);
  let _ocq = _obu(_om2, _om3);
  let _opn = _obu(_ocq * _ocq - 1.0, 0.0);
  let _o7r = _o5l + _opn * _o60;
  let _o7s = _o5o + _opn * _o61;
  let _o7t = _o5v + _opn * _o62;
  let _oso = _os3.x * (_o7r * _os3.x + _o7s * _os3.y)
               + _os3.y * (_o7s * _os3.x + _o7t * _os3.y);
  let _osn = _os2.x * (_o7r * _os2.x + _o7s * _os2.y)
                + _os2.y * (_o7s * _os2.x + _o7t * _os2.y);
  var _oji = _ofd * sqrt(_obu(_oso, 1e-8));
  var _ojg: f32;
  if (_okc) {
    _ojg = _ofd * sqrt(_obu(_osn, 1e-8));
  } else {
    let x = _os3.x * (_o7r * _os2.x + _o7s * _os2.y)
          + _os3.y * (_o7s * _os2.x + _o7t * _os2.y);
    let _o9j = _o7r * _o7t - _o7s * _o7s;
    _ojg = _ofd * sqrt(_obu(_osn, 1e-8)
        + 2.0 * abs(x) * sqrt(_obu(_o9j, 0.0)) / _obu(_oso, 1e-8));
  }
  let _o9p = _oe6(f32(_oth), f32(_odt));
  let _o6d = _o9p + _oe6(_o6i.x - 0.5 * f32(_oth - 1u), _o6i.y - 0.5 * f32(_odt - 1u));
  _oji = _obv(_oji, _o6d);
  _ojg = _obv(_ojg, _o6d);
  var _old: array<vec2f, 4>;
  _old[3] = vec2f(_obt(-_os2.x, _ojg, _obt(_os3.x, _oji, _o33.x)),
                  _obt(-_os2.y, _ojg, _obt(_os3.y, _oji, _o33.y)));
  _old[0] = vec2f(_obt(-_os2.x, _ojg, _obt(-_os3.x, _oji, _o33.x)),
                  _obt(-_os2.y, _ojg, _obt(-_os3.y, _oji, _o33.y)));
  _old[2] = vec2f(_obt(_os2.x, _ojg, _obt(_os3.x, _oji, _o49.x)),
                  _obt(_os2.y, _ojg, _obt(_os3.y, _oji, _o49.y)));
  _old[1] = vec2f(_obt(_os2.x, _ojg, _obt(-_os3.x, _oji, _o49.x)),
                  _obt(_os2.y, _ojg, _obt(-_os3.y, _oji, _o49.y)));
  var _ohp = _old[0].x;
  var _oha = _old[0].x;
  var _ohr = _old[0].y;
  var _ohc = _old[0].y;
  var _oh4 = 0.0;
  for (var _oe7 = 0u; _oe7 < 4u; _oe7 = _oe7 + 1u) {
    let _o86 = _old[_oe7];
    if (!_of0(_o86.x) || !_of0(_o86.y)) {
      return;
    }
    _ohp = _obv(_ohp, _o86.x);
    _oha = _obu(_oha, _o86.x);
    _ohr = _obv(_ohr, _o86.y);
    _ohc = _obu(_ohc, _o86.y);
    _oh4 = _obu(_oh4, _oe6(_o86.x - _o6i.x, _o86.y - _o6i.y));
  }
  let _otf = f32(_oth - 1u);
  let _odv = f32(_odt - 1u);
  if (_oha + _oi < 0.0 || _ohp - _oi > _otf
      || _ohc + _oi < 0.0 || _ohr - _oi > _odv) {
    return;
  }
  let _ohq = _obv(_obu(_ohp - _oi, 0.0), _otf);
  let _ohb = _obv(_obu(_oha + _oi, 0.0), _otf);
  let _ohs = _obv(_obu(_ohr - _oi, 0.0), _odv);
  let _ohd = _obv(_obu(_ohc + _oi, 0.0), _odv);
  let _oda = i32(_o69._orb);
  let _odb = i32(_o69._orc);
  let _orr = max(0, min(_oda, i32(floor(_ohq * 0.0625))));
  let _oru = max(0, min(_odb, i32(floor(_ohs * 0.0625))));
  let _ors = max(0, min(_oda, i32(floor(_ohb * 0.0625)) + 1));
  let _orv = max(0, min(_odb, i32(floor(_ohd * 0.0625)) + 1));
  if (_orr >= _ors || _oru >= _orv) {
    return;
  }
  let _olt = f32(max(_oth, _odt));
  let _oh5 = max(1, i32(ceil(_obv(_oh4, _olt))));
  let _oj0 = _o5e(_oqs, _o85, _om2, _om3, _okc, _o8r,
                                   _o33, _o49, _os3, _ojg, _omf.z, _oth, _odt);
  var _okm: _o1y;
  _okm._o3p = vec4f(_o60, _o61, _o62, select(_om2, -abs(_om2), _okc));
  _okm._o52 = vec4f(_ol2, _og5, _o8r, _om3);
  _okm.ab = vec4f(_o33, _o49);
  _okm._ocw = vec4f(_oji, _ojg, _o9f, f32(_oh5));
  _okm._omg = vec4u(u32(_orr), u32(_oru), u32(_ors), u32(_orv));
  _okm._omf = _omf;
  _okm._oj1 = vec4f(_oj0._ost, _oj0._osk);
  _okm._oj2 = vec4f(_oj0._osp, _oj0._otb, _oj0._otc);
  _okm._oj3 = vec4f(_oj0._ofj, _oj0._ofl, _oj0._oh1, bitcast<f32>(_oj0._obs));
  _oko[_oea] = _okm;
  let _o88 = _oj4(_o33, _o49, _ojg, _oj0);
  let _omh = _oii(_o33, _o49, _oji, _ojg);
  var _ohy = 0u;
  for (var _ort = u32(_oru); _ort < u32(_orv); _ort = _ort + 1u) {
    let _oov = _or9(_omh, _oj0, _o88, _ort, _oth,
                                     u32(_orr), u32(_ors));
    if (_oov.z != 0u) {
      _ohy = _ohy + (_oov.y - _oov.x);
    }
  }
  _ora[_oea] = _ohy;
}
@compute @workgroup_size(256)
fn duplicate_keys_beta(@builtin(local_invocation_index) _ogj: u32,
                       @builtin(workgroup_id) _otg: vec3u,
                       @builtin(num_workgroups) _oib: vec3u) {
  let _oea = _ogo(_otg, _oib) * _o2q + _ogj;
  if (_oea >= _oad[_o23]) {
    return;
  }
  let _okm = _oaf[_oea];
  if (!(_okm._ocw.w > 0.0)) {
    return;
  }
  var off = 0u;
  if (_oea > 0u) {
    off = _oae[_oea - 1u];
  }
  let _o33 = _okm.ab.xy;
  let _o49 = _okm.ab.zw;
  let _oj0 = _oj6(_okm);
  let _o88 = _oj4(_o33, _o49, _okm._ocw.y, _oj0);
  let _omh = _oii(_o33, _o49, _okm._ocw.x, _okm._ocw.y);
  let _o9g = bitcast<u32>(_okm._ocw.z);
  let _o6e = _oac._o6e;
  for (var y = _okm._omg.y; y < _okm._omg.w; y = y + 1u) {
    let _oov = _or9(_omh, _oj0, _o88, y,
                                     _oac._oth, _okm._omg.x, _okm._omg.z);
    if (_oov.z == 0u) {
      continue;
    }
    for (var x = _oov.x; x < _oov.y; x = x + 1u) {
      if (off < _o6e) {
        _ofu[off] = y * _oac._orb + x;
        _ofv[off] = _o9g;
        _ojt[off] = _oea;
      }
      off = off + 1u;
    }
  }
}
