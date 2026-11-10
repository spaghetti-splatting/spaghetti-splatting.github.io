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
@group(0) @binding(0) var<storage, read> _oe7: array<u32>;
@group(0) @binding(1) var<storage, read> _o9w: array<f32>;
@group(0) @binding(2) var<storage, read> _oq4: array<f32>;
@group(0) @binding(3) var<storage, read> _oix: array<vec4u>;
@group(0) @binding(4) var<storage, read> _o7l: array<u32>;
@group(0) @binding(5) var<storage, read_write> _oiy: array<_o1p>;
@group(0) @binding(6) var<storage, read_write> _op6: array<u32>;
@group(0) @binding(7) var<uniform> _o5o: _oo;
@group(0) @binding(0) var<storage, read> _o9i: array<_o1p>;
@group(0) @binding(1) var<storage, read> _o9h: array<u32>;
@group(0) @binding(2) var<storage, read> _o9g: array<u32>;
@group(0) @binding(3) var<storage, read_write> _oeb: array<u32>;
@group(0) @binding(4) var<storage, read_write> _oec: array<u32>;
@group(0) @binding(5) var<storage, read_write> _oi4: array<u32>;
@group(0) @binding(6) var<uniform> _o9f: _oo;
const _og: u32 = 16u;
const _oh: u32 = 16u;
const _o2c: f32 = 1e-3;
const _o16: f32 = 3.929278140e-03;
const _o2g: f32 = 0.1;
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
const _o2b = array<f32, 63>(
  -1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
  0.86907756, -0.08104082, 0.012049758, -0.00021792683, 2.1956479e-05, -1.45608055e-05, -2.4834957e-05,
  -0.70016533, 0.17784852, -0.029768402, 0.0013841696, -0.0002165212, 0.00020030937, 0.000181285,
  0.538863, -0.25318372, 0.051725097, -0.0043851244, 0.00028628978, -0.0007355512, -0.0004591238,
  -0.39315897, 0.28637674, -0.07442167, 0.010118952, -3.2378295e-05, 0.0011633757, 0.000537747,
  0.25465247, -0.25353765, 0.08320036, -0.016473958, 0.00047484812, -0.00091163174, -0.00032065576,
  -0.12885943, 0.15803069, -0.06287364, 0.016344883, -0.0015109606, 0.00043000313, 0.00010007449,
  0.04232212, -0.059212293, 0.027284678, -0.008595316, 0.0013526595, -0.00018219583, -1.2701726e-05,
  -0.006454065, 0.00980119, -0.005036595, 0.0018203161, -0.0003864131, 5.108729e-05, -1.2723773e-06);
const _o2a = array<f32, 7>(
  0.9317711, -0.04327248, 0.0059742252, 8.372514e-06, -1.3490912e-05, 1.0639736e-06, 1.9153707e-07);
const _o29 = array<f32, 7>(
  1.0743952, 0.049604684, -0.0057441797, -0.0003010808, 2.6747155e-05, 7.308961e-07, -3.6029135e-07);
var<private> _on8: array<f32, 11>;
var<private> _om8: array<f32, 5>;
fn _oqu(_odw: u32) -> f32 {
  return _o5o._oqp[_odw >> 2u][_odw & 3u];
}
fn _oij(_odw: u32) -> f32 {
  return _o5o._oj4[_odw >> 2u][_odw & 3u];
}
fn _o99(x: vec3f, y: vec3f) -> f32 {
  return x.x * y.x + x.y * y.y + x.z * y.z;
}
fn _oj6(_ohm: vec3f) -> vec4f {
  var _oh6: vec4f;
  for (var r = 0u; r < 4u; r = r + 1u) {
    _oh6[r] = _oau(_ohm.z, _oij(8u + r), _oau(_ohm.x, _oij(r), _ohm.y * _oij(4u + r))) + _oij(12u + r);
  }
  return _oh6;
}
fn _oqq(_ohm: vec3f) -> f32 {
  return _oau(_ohm.z, _oqu(10u), _oau(_ohm.x, _oqu(2u), _ohm.y * _oqu(6u))) + _oqu(14u);
}
fn _ogb(_oqc: f32, size: u32) -> f32 {
  let _ol9 = f32(size);
  return _oau(_oqc, _ol9, _ol9 - 1.0) * 0.5;
}
fn _ocp(x: f32, y: f32) -> f32 {
  let _o3j = abs(x);
  let _o3o = abs(y);
  let _o4j = max(_o3j, _o3o);
  let _omq = min(_o3j, _o3o);
  if (_omq == 0.0) {
    return _o4j;
  }
  return sqrt(_oau(_o4j, _o4j, _omq * _omq));
}
struct _o1f {
  r: mat3x3f,
  _ol9: vec3f,
  _oam: f32,
  _off: vec3f,
  _ofg: vec3f,
  _o5l: f32,
  _o5m: f32,
  _o5n: f32,
};
fn _oe8(_ol1: u32, _odr: vec3f, _odu: vec3f) -> _o1f {
  var _ob2: _o1f;
  let _opr = 8u * _ol1;
  let w = _oq4[_opr];
  let x = _oq4[_opr + 1u];
  let y = _oq4[_opr + 2u];
  let z = _oq4[_opr + 3u];
  _ob2.r = mat3x3f(
      vec3f(1.0 - 2.0 * (y * y + z * z), 2.0 * (x * y + w * z), 2.0 * (x * z - w * y)),
      vec3f(2.0 * (x * y - w * z), 1.0 - 2.0 * (x * x + z * z), 2.0 * (y * z + w * x)),
      vec3f(2.0 * (x * z + w * y), 2.0 * (y * z - w * x), 1.0 - 2.0 * (x * x + y * y)));
  _ob2._ol9 = vec3f(_oq4[_opr + 4u], _oq4[_opr + 5u], _oq4[_opr + 6u]);
  _ob2._oam = _oq4[_opr + 7u];
  _ob2._o5l = 0.0;
  _ob2._o5m = 0.0;
  _ob2._o5n = 0.0;
  for (var _odm = 0u; _odm < 3u; _odm = _odm + 1u) {
    let _o6z = _ob2.r[_odm];
    let _ohn = _odr.x * _o6z.x + _odr.y * _o6z.y + _odr.z * _o6z.z;
    let _oho = _odu.x * _o6z.x + _odu.y * _o6z.y + _odu.z * _o6z.z;
    _ob2._off[_odm] = _ohn * _ob2._ol9[_odm];
    _ob2._ofg[_odm] = _oho * _ob2._ol9[_odm];
    _ob2._o5l = _ob2._o5l + _ob2._off[_odm] * _ob2._off[_odm];
    _ob2._o5m = _ob2._o5m + _ob2._off[_odm] * _ob2._ofg[_odm];
    _ob2._o5n = _ob2._o5n + _ob2._ofg[_odm] * _ob2._ofg[_odm];
  }
  return _ob2;
}
struct _o1 {
  _oph: f32,
  _oke: f32,
  _ogh: f32,
  _oiq: bool,
  _ofs: f32,
  _oa2: bool,
};
fn _o3a(_ob2: _o1f, _odr: vec3f, _odu: vec3f, _okb: vec3f,
                     _oa1: f32, _oa7: f32) -> _o1 {
  var _oai: _o1;
  let _ola = _ob2._ol9.x;
  let _olb = _ob2._ol9.y;
  let _olc = _ob2._ol9.z;
  _oai._oph = 0.5 * _ola * (_olb + _olc);
  let _oh5 = vec3f(_olb * _olc, _ola * _olc, _ola * _olb);
  var _oou: vec3f;
  var _oeo = 0.0;
  for (var _odm = 0u; _odm < 3u; _odm = _odm + 1u) {
    let _o6z = _ob2.r[_odm];
    let _okc = _okb.x * _o6z.x + _okb.y * _o6z.y + _okb.z * _o6z.z;
    _oou[_odm] = _okc * _oh5[_odm];
    _oeo = _oav(_oeo, abs(_oou[_odm]));
  }
  let _odd = select(0.0, 1.0 / _oeo, _oeo > 0.0);
  var _ons = 0.0;
  for (var _odm = 0u; _odm < 3u; _odm = _odm + 1u) {
    let _olq = _oou[_odm] * _odd;
    _ons = _ons + _olq * _olq;
  }
  let _okw = sqrt(_ons);
  _oai._oke = _oeo * _okw;
  let _ogg = vec3f(_odr.y * _odu.z - _odr.z * _odu.y,
                     _odr.z * _odu.x - _odr.x * _odu.z,
                     _odr.x * _odu.y - _odr.y * _odu.x);
  _oai._ogh = sqrt(_ogg.x * _ogg.x + _ogg.y * _ogg.y + _ogg.z * _ogg.z);
  _oai._oiq = _ola > 0.0 && _olb > 0.0 && _olc > 0.0;
  _oai._ofs = 0.0;
  for (var _odm = 0u; _odm < 3u; _odm = _odm + 1u) {
    let _o9q = -_oa7 * _ob2._off[_odm] + _oa1 * _ob2._ofg[_odm];
    _oai._ofs = _oai._ofs + _o9q * _o9q;
  }
  _oai._oa2 = _oa1 == 0.0 && _oa7 == 0.0;
  return _oai;
}
fn _oal(_obf: f32) {
  let _ojs = _oau(_obf, -0.3, 0.3);
  let _ojt = _oau(_obf, -5.0 / 21.0, 10.0 / 21.0);
  let _oju = _oau(_obf, -7.0 / 36.0, 21.0 / 36.0);
  _om8[0] = 1.0;
  _om8[1] = _obf * (-1.0 / 3.0);
  _om8[2] = _om8[1] * _ojs;
  _om8[3] = _om8[2] * _ojt;
  _om8[4] = _om8[3] * _oju;
}
struct _op {
  _oo7: f32, _oo8: f32, _oo9: f32, _ooa: f32, _oob: f32, _ooc: f32,
};
fn _o65(_o2i: f32, _o2j: f32, _o2k: f32, _o2l: f32, _o2p: f32, _o2q: f32, _o2r: f32, _oo5: _op) -> f32 {
  var _o2z = _o2i;
  _o2z = _oau(_o2j, _oo5._oo7, _o2z);
  _o2z = _oau(_o2k, _oo5._oo8, _o2z);
  _o2z = _oau(_o2l, _oo5._oo9, _o2z);
  _o2z = _oau(_o2p, _oo5._ooa, _o2z);
  _o2z = _oau(_o2q, _oo5._oob, _o2z);
  _o2z = _oau(_o2r, _oo5._ooc, _o2z);
  return _o2z;
}
fn _on7(_obf: f32) {
  _on8[0] = _obf;
  let _obn = _obf + 1.0;
  let r = inverseSqrt(_obn);
  let z = _oau(r, _o3, _o2);
  let _ors = z + z;
  var _oo5: _op;
  _oo5._oo7 = z;
  _oo5._oo8 = _oau(_ors, _oo5._oo7, -1.0);
  _oo5._oo9 = _oau(_ors, _oo5._oo8, -_oo5._oo7);
  _oo5._ooa = _oau(_ors, _oo5._oo9, -_oo5._oo8);
  _oo5._oob = _oau(_ors, _oo5._ooa, -_oo5._oo9);
  _oo5._ooc = _oau(_ors, _oo5._oob, -_oo5._ooa);
  let _o80 = _o65(_o2b[0], _o2b[1], _o2b[2], _o2b[3], _o2b[4], _o2b[5], _o2b[6], _oo5);
  let _o81 = _o65(_o2b[7], _o2b[8], _o2b[9], _o2b[10], _o2b[11], _o2b[12], _o2b[13], _oo5);
  let _o82 = _o65(_o2b[14], _o2b[15], _o2b[16], _o2b[17], _o2b[18], _o2b[19], _o2b[20], _oo5);
  let _o83 = _o65(_o2b[21], _o2b[22], _o2b[23], _o2b[24], _o2b[25], _o2b[26], _o2b[27], _oo5);
  let _o84 = _o65(_o2b[28], _o2b[29], _o2b[30], _o2b[31], _o2b[32], _o2b[33], _o2b[34], _oo5);
  let _o85 = _o65(_o2b[35], _o2b[36], _o2b[37], _o2b[38], _o2b[39], _o2b[40], _o2b[41], _oo5);
  let _o86 = _o65(_o2b[42], _o2b[43], _o2b[44], _o2b[45], _o2b[46], _o2b[47], _o2b[48], _oo5);
  let _o87 = _o65(_o2b[49], _o2b[50], _o2b[51], _o2b[52], _o2b[53], _o2b[54], _o2b[55], _oo5);
  let _o88 = _o65(_o2b[56], _o2b[57], _o2b[58], _o2b[59], _o2b[60], _o2b[61], _o2b[62], _oo5);
  let g = _o65(_o2a[0], _o2a[1], _o2a[2], _o2a[3], _o2a[4],
                _o2a[5], _o2a[6], _oo5);
  let _obd = _o65(_o29[0], _o29[1], _o29[2],
                        _o29[3], _o29[4], _o29[5],
                        _o29[6], _oo5);
  let _oaa = r * g;
  let _odc = (_obn * r) * _obd;
  _on8[1] = _oaa;
  _on8[2] = _o80;
  var _oir = _odc;
  _on8[3] = _o81 * _oir;
  _oir = _oir * _odc;
  _on8[4] = _o82 * _oir;
  _oir = _oir * _odc;
  _on8[5] = _o83 * _oir;
  _oir = _oir * _odc;
  _on8[6] = _o84 * _oir;
  _oir = _oir * _odc;
  _on8[7] = _o85 * _oir;
  _oir = _oir * _odc;
  _on8[8] = _o86 * _oir;
  _oir = _oir * _odc;
  _on8[9] = _o87 * _oir;
  _oir = _oir * _odc;
  _on8[10] = _o88 * _oir;
  _oir = _oir * _odc;
}
struct _o17 {
  _oqh: f32,
};
fn _o4h(_oqc: f32) -> _o17 {
  let _obf = _on8[0];
  let _oh1 = _oav(_oau(-_oqc, _oqc, 1.0), _o4);
  let _ofd = log2(_oh1);
  let _oj7 = exp2((_obf + 1.0) * _ofd);
  var _o2z = _on8[10];
  _o2z = _oau(_o2z, _oqc, _on8[9]);
  _o2z = _oau(_o2z, _oqc, _on8[8]);
  _o2z = _oau(_o2z, _oqc, _on8[7]);
  _o2z = _oau(_o2z, _oqc, _on8[6]);
  _o2z = _oau(_o2z, _oqc, _on8[5]);
  _o2z = _oau(_o2z, _oqc, _on8[4]);
  _o2z = _oau(_o2z, _oqc, _on8[3]);
  _o2z = _oau(_o2z, _oqc, _on8[2]);
  _o2z = _oau(_o2z, _oqc, _on8[1]);
  let _o78 = _oj7 * _o2z;
  let _opr = _oqc * _oqc;
  var _ons = _om8[4];
  _ons = _oau(_ons, _opr, _om8[3]);
  _ons = _oau(_ons, _opr, _om8[2]);
  _ons = _oau(_ons, _opr, _om8[1]);
  _ons = _oau(_ons, _opr, _om8[0]);
  var _o9r: _o17;
  _o9r._oqh = select(_on8[1] - _o78, _ons * _oqc, _oqc <= _od);
  return _o9r;
}
const _ok: u32 = 0u;
const _oj: u32 = 1u;
const _ol: u32 = 2u;
struct _o1k {
  _o4t: u32,
  _o9v: f32,
  _ohm: f32,
};
fn _o3m(_oef: f32) -> _o1k {
  var _oi8: _o1k;
  _oi8._o9v = 0.0;
  let _obf = _on8[0];
  if (_oef < _o2g) {
    _oi8._o4t = _ok;
    let _o40 = _oau(-0.3 * _oef, _oef, 1.0);
    let _oir = exp2(_obf * log2(_o40));
    _oi8._ohm = _oau(5.0 / 9.0, _oir, 4.0 / 9.0);
  } else if (_oef <= _oe) {
    _oi8._o4t = _oj;
    let _oqc = _oef * _o9;
    _oi8._o9v = _o4h(_oqc)._oqh;
    _oi8._ohm = _oi8._o9v / _oqc;
  } else {
    _oi8._o4t = _ol;
    _oi8._ohm = _oe * _on8[1] / _oef;
  }
  return _oi8;
}
fn _oq3(_oej: f32, g: f32) -> f32 {
  let _oi8 = _o3m(_oej / g);
  return g * g / _oi8._ohm;
}
fn _one(a: f32, _og6: f32, w: f32, g: f32, _okx: f32,
                           _oef: f32) -> f32 {
  let _oi8 = _o3m(_oef);
  if (_oi8._o4t == _ok) {
    return a * g * g * _og6 / _oi8._ohm;
  }
  let _oa9 = select(_on8[1], _oi8._o9v, _oi8._o4t == _oj);
  return a * g * _okx / (_oe * w * _oa9);
}
fn _onc(_oc2: f32, _o8n: f32, _oef: f32) -> f32 {
  let _obf = _on8[0];
  if (_oef < _o2g) {
    let _o40 = _oau(-0.3, _oc2 / _o8n, 1.0);
    let _oir = exp2(_obf * log2(_o40));
    return _oau(5.0 / 9.0, _oir, 4.0 / 9.0) * inverseSqrt(_o8n);
  }
  let _oi8 = _o3m(_oef);
  let _oa9 = select(_on8[1], _oi8._o9v, _oi8._o4t == _oj);
  return _oe * _oa9 * inverseSqrt(_oc2);
}
fn _onb(_oai: _o1, g: f32, _o79: vec3f,
                          _oop: vec3f, _oa1: f32, _oa7: f32) -> f32 {
  let _oru = !_oai._oa2 && !(_oai._ofs > 0.0);
  let a = _oai._oph;
  let w = _oai._oke;
  let _og6 = _oai._ogh;
  var _oq2 = 0.0;
  if (!_oru) {
    let _okx = sqrt(_oai._ofs);
    let _oef = _okx / (g * _og6 * w);
    _oq2 = _one(a, _og6, w, g, _okx, _oef);
  }
  let _onk = g * g - 1.0;
  let _o51 = _o79.x + _onk * _oop.x;
  let _o54 = _o79.y + _onk * _oop.y;
  let _o5b = _o79.z + _onk * _oop.z;
  let _o8n = _o51 * _o5b - _o54 * _o54;
  let _o31 = _o5b * _oa1 - _o54 * _oa7;
  let _o32 = _o51 * _oa7 - _o54 * _oa1;
  let _oc4 = _oa1 * _o31 + _oa7 * _o32;
  let _oc3 = select(0.0, _oc4, _oc4 > 0.0);
  let _oei = sqrt(_oc3 / _o8n);
  let _oan = _onc(_oc3, _o8n, _oei);
  return _oq2 * _oan;
}
struct _ow {
  _ogz: bool,
  a: vec4f,
  b: vec4f,
};
fn _o6s(_ohu: vec4f, _oi6: vec4f) -> _ow {
  var _okq: _ow;
  _okq._ogz = false;
  let _o7z = _oi6 - _ohu;
  let _ogj = _ohu.w - _o2c;
  let _o8h = _o7z.w;
  var _oo6 = 0.0;
  var _oo7 = 1.0;
  if (_o8h == 0.0) {
    if (_ogj < 0.0) {
      return _okq;
    }
  } else {
    let _opa = -_ogj / _o8h;
    if (_o8h > 0.0) {
      _oo6 = _oav(_oo6, _opa);
    } else {
      _oo7 = _oaw(_oo7, _opa);
    }
  }
  if (_oo6 > _oo7) {
    return _okq;
  }
  for (var _o4z = 0u; _o4z < 4u; _o4z = _o4z + 1u) {
    _okq.a[_o4z] = _oau(_o7z[_o4z], _oo6, _ohu[_o4z]);
    _okq.b[_o4z] = _oau(_o7z[_o4z], _oo7, _ohu[_o4z]);
  }
  _okq._ogz = true;
  return _okq;
}
const _o26: u32 = 1u;
const _o27: u32 = 2u;
const _o28: u32 = 4u;
struct _o1i {
  _oqo: vec2f,
  _oqf: vec2f,
  _oqk: vec2f,
  _or6: f32,
  _or7: f32,
  _oe0: f32,
  _oe2: f32,
  _ofe: f32,
  _oat: u32,
};
fn _ohh(_ohm: _o1p) -> _o1i {
  var _ogq: _o1i;
  _ogq._oqo = _ohm._ohc.xy;
  _ogq._oqf = _ohm._ohc.zw;
  _ogq._oqk = _ohm._ohd.xy;
  _ogq._or6 = _ohm._ohd.z;
  _ogq._or7 = _ohm._ohd.w;
  _ogq._oe0 = _ohm._ohe.x;
  _ogq._oe2 = _ohm._ohe.y;
  _ogq._ofe = _ohm._ohe.z;
  _ogq._oat = bitcast<u32>(_ohm._ohe.w);
  return _ogq;
}
struct _o1q {
  _ohn: vec2f,
  _oho: vec2f,
  _ohp: vec2f,
  _ohq: vec2f,
};
struct _oy {
  _oft: _o1q,
  _o9t: _o1q,
  _o9u: _o1q,
};
fn _o36(_ohm: vec2f, a: vec2f, _o9m: vec2f) -> f32 {
  return _oau(_ohm.y - a.y, _o9m.y, (_ohm.x - a.x) * _o9m.x);
}
fn _ohk(a: vec2f, _o9m: vec2f, _ohn: vec2f, _oho: vec2f, _off: vec2f, _ofg: vec2f) -> _o1q {
  let _onz = _o36(_ohn, a, _o9m) > _o36(_oho, a, _o9m);
  let _ony = _o36(_off, a, _o9m) > _o36(_ofg, a, _o9m);
  return _o1q(select(_ohn, _oho, _onz), select(_oho, _ohn, _onz),
              select(_ofg, _off, _ony), select(_off, _ofg, _ony));
}
fn _ogx(a: vec2f, _ol9: f32, _oqc: vec2f) -> vec2f {
  return vec2f(_oau(_ol9, _oqc.x, a.x), _oau(_ol9, _oqc.y, a.y));
}
fn _ohf(a: vec2f, b: vec2f, _ohr: f32, _ogq: _o1i) -> _oy {
  let _o9m = b - a;
  let _oes = _ocp(_o9m.x, _o9m.y);
  let _omc = _oes < 1e-4;
  let _oli = select(_o9m, vec2f(1.0, 0.0), _omc);
  let _olj = select(_oes, 1.0, _omc);
  let _og6 = vec2f(-_oli.y / _olj, _oli.x / _olj);
  let _opr = vec2f(_oli.x / _olj, _oli.y / _olj);
  let _o2v = _ogx(a, -_ogq._or6, _ogq._oqo);
  let _o2w = _ogx(a, _ogq._or6, _ogq._oqo);
  let _o3v = _ogx(b, -_ogq._or7, _ogq._oqo);
  let _o3w = _ogx(b, _ogq._or7, _ogq._oqo);
  var _o2t: vec2f;
  var _o2s: vec2f;
  var _o3t: vec2f;
  var _o3s: vec2f;
  if ((_ogq._oat & _o27) != 0u) {
    let _o2i = _ogx(a, -_ohr, _opr);
    _o2t = _ogx(_o2i, _ogq._or6, _og6);
    _o2s = _ogx(_o2i, -_ogq._or6, _og6);
  } else {
    let _o2i = _ogx(a, -_ogq._oe0, _o9m);
    _o2t = _ogx(_o2i, _ogq._or6, _ogq._oqf);
    _o2s = _ogx(_o2i, -_ogq._or6, _ogq._oqf);
  }
  if ((_ogq._oat & _o28) != 0u) {
    let _o3q = _ogx(b, _ohr, _opr);
    _o3t = _ogx(_o3q, _ogq._or7, _og6);
    _o3s = _ogx(_o3q, -_ogq._or7, _og6);
  } else {
    let _o3q = _ogx(b, _ogq._oe2, _o9m);
    _o3t = _ogx(_o3q, _ogq._or7, _ogq._oqk);
    _o3s = _ogx(_o3q, -_ogq._or7, _ogq._oqk);
  }
  return _oy(_o1q(_o2v, _o3v, _o3w, _o2w),
                 _ohk(a, _o9m, _o2w, _o2t, _o2v, _o2s),
                 _ohk(a, _o9m, _o3w, _o3t, _o3v, _o3s));
}
fn _o3y(_ohn: vec2f, _oho: vec2f, _orr: f32, _orq: f32, _ok0: vec2f) -> vec2f {
  var _orn = _ok0.x;
  var _orl = _ok0.y;
  if (_ohn.y >= _orr && _ohn.y <= _orq) {
    _orn = _oaw(_orn, _ohn.x);
    _orl = _oav(_orl, _ohn.x);
  }
  if (_oav(_ohn.y, _oho.y) < _orr || _oaw(_ohn.y, _oho.y) > _orq) {
    return vec2f(_orn, _orl);
  }
  let _o9k = _oho.y - _ohn.y;
  if (_o9k != 0.0) {
    let _ooj = _oaw(_oav((_orr - _ohn.y) / _o9k, 0.0), 1.0);
    let _oos = _oaw(_oav((_orq - _ohn.y) / _o9k, 0.0), 1.0);
    let _orj = _oau(_ooj, _oho.x - _ohn.x, _ohn.x);
    let _ork = _oau(_oos, _oho.x - _ohn.x, _ohn.x);
    _orn = _oaw(_orn, _oaw(_orj, _ork));
    _orl = _oav(_orl, _oav(_orj, _ork));
  } else {
    _orn = _oaw(_orn, _oaw(_ohn.x, _oho.x));
    _orl = _oav(_orl, _oav(_ohn.x, _oho.x));
  }
  return vec2f(_orn, _orl);
}
fn _o3z(_ojb: _o1q, _orr: f32, _orq: f32, _ok0: vec2f) -> vec2f {
  var r = _o3y(_ojb._ohn, _ojb._oho, _orr, _orq, _ok0);
  r = _o3y(_ojb._oho, _ojb._ohp, _orr, _orq, r);
  r = _o3y(_ojb._ohp, _ojb._ohq, _orr, _orq, r);
  return _o3y(_ojb._ohq, _ojb._ohn, _orr, _orq, r);
}
fn _ogu(_ohn: vec2f, _oho: vec2f, _orr: f32, _orq: f32, _ok0: vec2f) -> vec2f {
  var _orn = _ok0.x;
  var _orl = _ok0.y;
  if (_ohn.y >= _orr && _ohn.y <= _orq) {
    _orn = _oaw(_orn, _ohn.x);
    _orl = _oav(_orl, _ohn.x);
  }
  let _o9k = _oho.y - _ohn.y;
  if (_o9k != 0.0) {
    let _oo6 = (_orr - _ohn.y) / _o9k;
    if (_oo6 > 0.0 && _oo6 < 1.0) {
      let x = _oau(_oo6, _oho.x - _ohn.x, _ohn.x);
      _orn = _oaw(_orn, x);
      _orl = _oav(_orl, x);
    }
    let _oo7 = (_orq - _ohn.y) / _o9k;
    if (_oo7 > 0.0 && _oo7 < 1.0) {
      let x = _oau(_oo7, _oho.x - _ohn.x, _ohn.x);
      _orn = _oaw(_orn, x);
      _orl = _oav(_orl, x);
    }
  }
  return vec2f(_orn, _orl);
}
fn _ogt(a: vec2f, b: vec2f, _oht: f32, _ohr: f32) -> _o1q {
  let _o8y = b - a;
  let _oes = _ocp(_o8y.x, _o8y.y);
  let _omc = _oes < 1e-4;
  let _oli = select(_o8y, vec2f(1.0, 0.0), _omc);
  let _olj = select(_oes, 1.0, _omc);
  let _opy = vec2f(-_oli.y / _olj, _oli.x / _olj);
  let _opx = vec2f(_oli.x / _olj, _oli.y / _olj);
  let _ois = _oht + _oi;
  let _ohu = _ohr + _oi;
  let _o5f = vec2f(_oau(-_opx.x, _ohu, _oau(_opy.x, _ois, a.x)),
                 _oau(-_opx.y, _ohu, _oau(_opy.y, _ois, a.y)));
  let _o50 = vec2f(_oau(-_opx.x, _ohu, _oau(-_opy.x, _ois, a.x)),
                 _oau(-_opx.y, _ohu, _oau(-_opy.y, _ois, a.y)));
  let _o5e = vec2f(_oau(_opx.x, _ohu, _oau(_opy.x, _ois, b.x)),
                 _oau(_opx.y, _ohu, _oau(_opy.y, _ois, b.y)));
  let _o57 = vec2f(_oau(_opx.x, _ohu, _oau(-_opy.x, _ois, b.x)),
                 _oau(_opx.y, _ohu, _oau(-_opy.y, _ois, b.y)));
  return _o1q(_o50, _o57, _o5e, _o5f);
}
fn _omy(_ok0: vec2f, _orc: u32, _opm: i32, _opn: i32, _ofe: f32) -> vec3u {
  let _or1 = f32(_orc - 1u);
  let _oro = _oaw(_oav(_ok0.x - _ofe, 0.0), _or1);
  let _orm = _oaw(_oav(_ok0.y + _ofe, 0.0), _or1);
  let _oo1 = max(_opm, i32(floor(_oro * 0.0625)));
  let _oo2 = min(_opn, i32(floor(_orm * 0.0625)) + 1);
  let _ogz = _ok0.y >= _ok0.x && _oo2 > _oo1;
  return select(vec3u(0u), vec3u(u32(_oo1), u32(_oo2), 1u), _ogz);
}
fn _op5(_ol4: _o1q, _ogq: _o1i, _o4z: _oy, _opo: u32, _orc: u32,
                         _opm: u32, _opn: u32) -> vec3u {
  let _orr = f32(_opo * _oh);
  let _orq = f32(_opo * _oh + (_oh - 1u));
  var r = _ogu(_ol4._ohn, _ol4._oho, _orr, _orq, vec2f(3.4e38, -3.4e38));
  r = _ogu(_ol4._oho, _ol4._ohp, _orr, _orq, r);
  r = _ogu(_ol4._ohp, _ol4._ohq, _orr, _orq, r);
  r = _ogu(_ol4._ohq, _ol4._ohn, _orr, _orq, r);
  let _okl = _omy(r, _orc, i32(_opm), i32(_opn), 0.0);
  let _oh0 = _orr - _ogq._ofe;
  let _ogy = _orq + _ogq._ofe;
  var _ojb = _o3z(_o4z._oft, _oh0, _ogy, vec2f(3.4e38, -3.4e38));
  _ojb = _o3z(_o4z._o9t, _oh0, _ogy, _ojb);
  _ojb = _o3z(_o4z._o9u, _oh0, _ogy, _ojb);
  let _ohj = _omy(_ojb, _orc, i32(_okl.x), i32(_okl.y), _ogq._ofe);
  let _oqa = _okl.z == 0u || (_ogq._oat & _o26) != 0u;
  return select(_ohj, _okl, _oqa);
}
fn _oj2(a: f32, b: f32, _o4z: f32, _o7z: f32) -> f32 {
  let _ohm = _opk(a, b);
  let _ojb = _opk(_o4z, _o7z);
  let _ol9 = _opl(_ohm.x, -_ojb.x);
  let _ofa = (_ohm.y - _ojb.y) + _ol9.y;
  return _ol9.x + _ofa;
}
fn _ohi(_ohm: vec2f, a: vec2f, _o9m: vec2f, _o9p: f32) -> f32 {
  let _o9j = _ohm.x - a.x;
  let _o9k = _ohm.y - a.y;
  let _oo5 = _oaw(_oav((_o9j * _o9m.x + _o9k * _o9m.y) / _o9p, 0.0), 1.0);
  return _ocp(_o9j - _oo5 * _o9m.x, _o9k - _oo5 * _o9m.y);
}
fn _oap(_oqc: vec2f) -> bool {
  return _odj(_oqc.x) && _odj(_oqc.y);
}
struct _o1j {
  w: f32,
  _oqc: vec2f,
  _oe1: f32,
};
fn _ohg(g: f32, _ole: f32, _o5j: vec2f, _og6: vec2f, _o8o: f32, _ope: f32, _o4f: f32,
               _odw: f32, _oee: f32) -> _o1j {
  let gg = g * g;
  let _olg = gg * _ole + _o4f;
  let _o8r = gg * gg * _o8o + gg * _o4f * _ope + _o4f * _o4f;
  var _o9r: _o1j;
  _o9r.w = _odw * sqrt(_olg);
  _o9r._oqc = vec2f((gg * _o5j.x + _o4f * _og6.x) / _olg, (gg * _o5j.y + _o4f * _og6.y) / _olg);
  _o9r._oe1 = _odw * sqrt(_o8r / _olg) / _oee;
  return _o9r;
}
fn _ono(g: f32, _o9z: f32, _o9x: f32, _o8o: f32, _ope: f32, _o4f: f32,
                       _o7t: f32) -> bool {
  let gg = g * g;
  let _oc2 = _oau(gg, _o9z, _o4f * _o9x);
  let _o8n = _oau(gg, _oau(gg, _o8o, _o4f * _ope), _o4f * _o4f);
  let _o7u = _o7t * _oc2;
  let _oj1 = _o7u * _o8n;
  return !_odj(_oj1) || _oj1 > 1e37;
}
fn _o7b(_ohm: vec2f, a: vec2f, _o9m: vec2f, _o9p: f32, _okh: vec2f) -> vec2f {
  let _oao = _okh.y != 0.0 && _oap(_ohm);
  return vec2f(_oav(_okh.x, _ohi(_ohm, a, _o9m, _o9p)), select(0.0, 1.0, _oao));
}
fn _ojl(_ojb: _o1q, a: vec2f, _o9m: vec2f, _o9p: f32, _okh: vec2f) -> vec2f {
  var r = _o7b(_ojb._ohn, a, _o9m, _o9p, _okh);
  r = _o7b(_ojb._oho, a, _o9m, _o9p, r);
  r = _o7b(_ojb._ohp, a, _o9m, _o9p, r);
  return _o7b(_ojb._ohq, a, _o9m, _o9p, r);
}
fn _o4u(_o5f: vec3f, _o5k: vec3f, _ok8: f32, _ok9: f32, _oim: bool,
                      _o7t: f32, a: vec2f, b: vec2f, _og6: vec2f, _ohr: f32,
                      _o4f: f32, _orc: u32, _oce: u32) -> _o1i {
  var _ogq: _o1i;
  _ogq._oqo = vec2f(0.0);
  _ogq._oqf = vec2f(0.0);
  _ogq._oqk = vec2f(0.0);
  _ogq._or6 = 0.0;
  _ogq._or7 = 0.0;
  _ogq._oe0 = 0.0;
  _ogq._oe2 = 0.0;
  _ogq._ofe = 0.0;
  _ogq._oat = _o26;
  if (_oim) {
    return _ogq;
  }
  let _o9m = b - a;
  let _o9p = _o9m.x * _o9m.x + _o9m.y * _o9m.y;
  let _oee = sqrt(_o9p);
  let _odw = sqrt(_o7t);
  let _o8o = _oav(_oj2(_o5f.x, _o5f.z, _o5f.y, _o5f.y), 0.0);
  let _ope = _o5f.x + _o5f.z;
  let _o63 = vec2f(_o5k.x * _og6.x + _o5k.y * _og6.y, _o5k.y * _og6.x + _o5k.z * _og6.y);
  let _olf = _og6.x * _o63.x + _og6.y * _o63.y;
  _ogq._oqo = vec2f(_o63.x / _olf, _o63.y / _olf);
  let _o5j = vec2f(_o5f.x * _og6.x + _o5f.y * _og6.y, _o5f.y * _og6.x + _o5f.z * _og6.y);
  let _ole = _og6.x * _o5j.x + _og6.y * _o5j.y;
  let _o9t = _ohg(_ok8, _ole, _o5j, _og6, _o8o, _ope, _o4f, _odw, _oee);
  let _o9u = _ohg(_ok9, _ole, _o5j, _og6, _o8o, _ope, _o4f, _odw, _oee);
  _ogq._or6 = _o9t.w;
  _ogq._or7 = _o9u.w;
  _ogq._oqf = _o9t._oqc;
  _ogq._oqk = _o9u._oqc;
  _ogq._oe0 = _o9t._oe1;
  _ogq._oe2 = _o9u._oe1;
  let _obe = _oav(_ok8, _ok9);
  let _obk = _obe * _obe;
  let _opf = _obk * _ope + 2.0 * _o4f;
  let _o8q = _obk * _obk * _o8o + _obk * _o4f * _ope + _o4f * _o4f;
  let _opr = 5.9604644775390625e-8;
  let r = 16.0 * _opr * _opf * _opf / _o8q;
  let _o8d = _oav(_oav(abs(a.x), abs(a.y)), _oav(abs(b.x), abs(b.y)))
         + f32(_orc) + f32(_oce);
  let _o8f = !(_o8q > 0.0) || !_odj(_o8q) || (_o4f == 0.0 && _o8o == 0.0);
  let _o2n = _o5f.z * _o9m.x - _o5f.y * _o9m.y;
  let _o2o = _o5f.x * _o9m.y - _o5f.y * _o9m.x;
  let _o9z = _oav(_o9m.x * _o2n + _o9m.y * _o2o, 0.0);
  let _o9x = _o9m.x * _o9m.x + _o9m.y * _o9m.y;
  let _oki = _oav(_o5f.x * _o5f.z - _o5f.y * _o5f.y, 0.0);
  let _okj = _o5f.x + _o5f.z;
  var _oat = 0u;
  if (_ono(_ok8, _o9z, _o9x, _oki, _okj, _o4f, _o7t)) {
    _oat = _oat | _o27;
  }
  if (_ono(_ok8 + (_ok9 - _ok8), _o9z, _o9x, _oki, _okj, _o4f, _o7t)) {
    _oat = _oat | _o28;
  }
  _ogq._oat = _oat;
  let _o4z = _ohf(a, b, _ohr, _ogq);
  var _okh = _ojl(_o4z._oft, a, _o9m, _o9p, vec2f(0.0, 1.0));
  _okh = _ojl(_o4z._o9t, a, _o9m, _o9p, _okh);
  _okh = _ojl(_o4z._o9u, a, _o9m, _o9p, _okh);
  var _oao = _okh.y != 0.0;
  let _o4l = _okh.x;
  _ogq._ofe = r * _o4l + 0.02 + 4.0 * _opr * _o8d;
  let _onm = (_oat & _o27) != 0u;
  let _onn = (_oat & _o28) != 0u;
  _oao = _oao && _oap(_ogq._oqo) && _odj(_ogq._or6) && _odj(_ogq._or7)
      && (_onm || (_oap(_ogq._oqf) && _odj(_ogq._oe0)))
      && (_onn || (_oap(_ogq._oqk) && _odj(_ogq._oe2)))
      && _odj(_o4l) && _odj(r) && _odj(_ogq._ofe);
  if (_o8f || !_oao) {
    _ogq._oat = _o26;
  }
  return _ogq;
}
@compute @workgroup_size(256)
fn preprocess_beta(@builtin(local_invocation_index) _oex: u32,
                   @builtin(workgroup_id) _orb: vec3u,
                   @builtin(num_workgroups) _ogm: vec3u) {
  let _oct = _of2(_orb, _ogm) * _o2h + _oex;
  if (_oct >= _o7l[_o1u]) {
    return;
  }
  let _omu = _oe7[_oct];
  _op6[_oct] = 0u;
  _oiy[_oct]._obj = vec4f(0.0, 0.0, 0.0, 0.0);
  let _o3h = _oix[_oct];
  let _o38 = bitcast<f32>(_o3h.x);
  let _oma = bitcast<f32>(_o3h.y);
  let _ogq = 6u * _omu;
  let _ohv = vec3f(_o9w[_ogq], _o9w[_ogq + 1u], _o9w[_ogq + 2u]);
  let _oi7 = vec3f(_o9w[_ogq + 3u], _o9w[_ogq + 4u], _o9w[_ogq + 5u]);
  let _of1 = vec3f((_ohv.x + _oi7.x) * 0.5, (_ohv.y + _oi7.y) * 0.5, (_ohv.z + _oi7.z) * 0.5);
  let _o8j = _oqq(_of1);
  if (_o8j < _oc) {
    return;
  }
  let _o6q = _o6s(_oj6(_ohv), _oj6(_oi7));
  if (!_o6q._ogz) {
    return;
  }
  let _orc = _o5o._orc;
  let _oce = _o5o._oce;
  let _o2u = vec2f(_ogb(_o6q.a.x / _o6q.a.w, _orc), _ogb(_o6q.a.y / _o6q.a.w, _oce));
  let _o3u = vec2f(_ogb(_o6q.b.x / _o6q.b.w, _orc), _ogb(_o6q.b.y / _o6q.b.w, _oce));
  let _oam = _o5o._o4f;
  let _o5w = _oj6(_of1);
  var _om1 = _o5w.w > _o2c && _odj(_o5w.w);
  let _olk = select(1.0, _o5w.w, _om1);
  let _oda = 1.0 / (_olk * _olk);
  let _of0 = _oa * _olk;
  let _o68 = _oaw(_oav(_o5w.x, -_of0), _of0);
  let _o69 = _oaw(_oav(_o5w.y, -_of0), _of0);
  let _odp = _o68 != _o5w.x || _o69 != _o5w.y;
  let _ocb = 0.5 * f32(_orc);
  let _oc8 = 0.5 * f32(_oce);
  let _odr = vec3f(_ocb * (_olk * _oij(0u) - _o68 * _oij(3u)) * _oda,
                 _ocb * (_olk * _oij(4u) - _o68 * _oij(7u)) * _oda,
                 _ocb * (_olk * _oij(8u) - _o68 * _oij(11u)) * _oda);
  let _odu = vec3f(_oc8 * (_olk * _oij(1u) - _o69 * _oij(3u)) * _oda,
                 _oc8 * (_olk * _oij(5u) - _o69 * _oij(7u)) * _oda,
                 _oc8 * (_olk * _oij(9u) - _o69 * _oij(11u)) * _oda);
  let _ofy = vec2f(_ogb(_o5w.x / _olk, _orc),
                           _ogb(_o5w.y / _olk, _oce));
  let _ob2 = _oe8(_omu, _odr, _odu);
  let _obh = 4.0 * exp2(_oma * _ob);
  let _obg = !(_obh >= _o7 && _obh <= _o6);
  let _obf = _oaw(_oav(_obh, _o7), _o6);
  let _ods = _ob2._oam * _o99(_odr, _odr);
  let _odt = _ob2._oam * _o99(_odr, _odu);
  let _odv = _ob2._oam * _o99(_odu, _odu);
  let _o5g = _ob2._o5l + _ods;
  let _o5h = _ob2._o5m + _odt;
  let _o5i = _ob2._o5n + _odv;
  let _oib = _oam;
  let _o51 = _o5g + _oib;
  let _o54 = _o5h;
  let _o5b = _o5i + _oib;
  _on7(_obf);
  _oal(_obf);
  let _okk = vec4f(select(_obf, -_obf, _obg), _obf, _oib, 0.0);
  let _ok8 = _olk / _o6q.a.w;
  let _ok9 = _olk / _o6q.b.w;
  let _o8p = _o51 * _o5b - _o54 * _o54;
  _om1 = _om1 && _o8p > 0.0 && _odj(_o8p);
  let _od6 = select(0.0, 1.0 / _o8p, _om1);
  let _o66 = _o3u - _o2u;
  let _o31 = _o5b * _o66.x - _o54 * _o66.y;
  let _o32 = _o51 * _o66.y - _o54 * _o66.x;
  let _oc2 = _o66.x * _o31 + _o66.y * _o32;
  let _obz = _oav(_oc2 * _od6, 0.0);
  let _oef = sqrt(_obz);
  let _od7 = select(0.0, 1.0 / _oc2, _obz > 1e-8);
  let _oim = !(_oef > _o2g) || !(_od7 > 0.0);
  let _o5q = _o5o._o5r.xyz;
  let _oka = _of1 - _o5q;
  let _odf = inverseSqrt(_o99(_oka, _oka));
  var _okb = _oka * _odf;
  if (_odp) {
    let _ogi = vec3f(_odr.y * _odu.z - _odr.z * _odu.y,
                    _odr.z * _odu.x - _odr.x * _odu.z,
                    _odr.x * _odu.y - _odr.y * _odu.x);
    let _ode = inverseSqrt(_o99(_ogi, _ogi));
    _okb = _ogi * _ode;
  }
  let _oai = _o3a(_ob2, _odr, _odu, _okb, _o66.x, _o66.y);
  let _o79 = vec3f(_o51, _o54, _o5b);
  let _oop = vec3f(_o5g, _o5h, _o5i);
  let _okr = _oav(_o38, 0.0);
  let _ojc = _okr * _oai._oph * _oai._ogh;
  let _oej = sqrt(_oai._ofs) / (_oai._ogh * _oai._oke);
  _om1 = _om1 && (_oai._oa2 || _oai._ofs > 0.0);
  let _odx = _onb(_oai, _ok8, _o79, _oop, _o66.x, _o66.y);
  let _odz = _onb(_oai, 1.0, _o79, _oop, _o66.x, _o66.y);
  let _ody = _onb(_oai, _ok9, _o79, _oop, _o66.x, _o66.y);
  let _oi8 = _okr * _oav(_odx, _oav(_odz, _ody));
  let _opu = _ojc * _oq3(_oej, _ok8);
  let _opw = _ojc * _oq3(_oej, 1.0);
  let _opv = _ojc * _oq3(_oej, _ok9);
  _om1 = _om1 && _oai._oiq && _odj(_oej)
      && _odj(_opu) && _odj(_opw) && _odj(_opv);
  if (!_om1) {
    return;
  }
  let _o5x = _ofy;
  let _ok7 = _o16 / _oav(_oi8, _o16);
  let _o7v = _oav(0.5 * (1.0 - exp2(log2(_ok7) / _obf)), 1e-6);
  let _o8y = _o3u - _o2u;
  let _oes = _ocp(_o8y.x, _o8y.y);
  let _omc = _oes < 1e-4;
  let _oli = select(_o8y, vec2f(1.0, 0.0), _omc);
  let _olj = select(_oes, 1.0, _omc);
  let _opy = vec2f(-_oli.y / _olj, _oli.x / _olj);
  let _opx = vec2f(_oli.x / _olj, _oli.y / _olj);
  let _odw = sqrt(_o7v);
  let _obe = _oav(_ok8, _ok9);
  let _onl = _oav(_obe * _obe - 1.0, 0.0);
  let _o6v = _o51 + _onl * _o5g;
  let _o6w = _o54 + _onl * _o5h;
  let _o6x = _o5b + _onl * _o5i;
  let _oqj = _opy.x * (_o6v * _opy.x + _o6w * _opy.y)
               + _opy.y * (_o6w * _opy.x + _o6x * _opy.y);
  let _oqi = _opx.x * (_o6v * _opx.x + _o6w * _opx.y)
                + _opx.y * (_o6w * _opx.x + _o6x * _opx.y);
  var _oht = _odw * sqrt(_oav(_oqj, 1e-8));
  var _ohr: f32;
  if (_oim) {
    _ohr = _odw * sqrt(_oav(_oqi, 1e-8));
  } else {
    let x = _opy.x * (_o6v * _opx.x + _o6w * _opx.y)
          + _opy.y * (_o6w * _opx.x + _o6x * _opx.y);
    let _o8n = _o6v * _o6x - _o6w * _o6w;
    _ohr = _odw * sqrt(_oav(_oqi, 1e-8)
        + 2.0 * abs(x) * sqrt(_oav(_o8n, 0.0)) / _oav(_oqj, 1e-8));
  }
  let _o8t = _ocp(f32(_orc), f32(_oce));
  let _o5s = _o8t + _ocp(_o5x.x - 0.5 * f32(_orc - 1u), _o5x.y - 0.5 * f32(_oce - 1u));
  _oht = _oaw(_oht, _o5s);
  _ohr = _oaw(_ohr, _o5s);
  var _ojk: array<vec2f, 4>;
  _ojk[3] = vec2f(_oau(-_opx.x, _ohr, _oau(_opy.x, _oht, _o2u.x)),
                  _oau(-_opx.y, _ohr, _oau(_opy.y, _oht, _o2u.y)));
  _ojk[0] = vec2f(_oau(-_opx.x, _ohr, _oau(-_opy.x, _oht, _o2u.x)),
                  _oau(-_opx.y, _ohr, _oau(-_opy.y, _oht, _o2u.y)));
  _ojk[2] = vec2f(_oau(_opx.x, _ohr, _oau(_opy.x, _oht, _o3u.x)),
                  _oau(_opx.y, _ohr, _oau(_opy.y, _oht, _o3u.y)));
  _ojk[1] = vec2f(_oau(_opx.x, _ohr, _oau(-_opy.x, _oht, _o3u.x)),
                  _oau(_opx.y, _ohr, _oau(-_opy.y, _oht, _o3u.y)));
  var _og0 = _ojk[0].x;
  var _ofm = _ojk[0].x;
  var _og2 = _ojk[0].y;
  var _ofo = _ojk[0].y;
  var _ofh = 0.0;
  for (var _ocq = 0u; _ocq < 4u; _ocq = _ocq + 1u) {
    let _o7a = _ojk[_ocq];
    if (!_odj(_o7a.x) || !_odj(_o7a.y)) {
      return;
    }
    _og0 = _oaw(_og0, _o7a.x);
    _ofm = _oav(_ofm, _o7a.x);
    _og2 = _oaw(_og2, _o7a.y);
    _ofo = _oav(_ofo, _o7a.y);
    _ofh = _oav(_ofh, _ocp(_o7a.x - _o5x.x, _o7a.y - _o5x.y));
  }
  let _ora = f32(_orc - 1u);
  let _ocf = f32(_oce - 1u);
  if (_ofm + _oi < 0.0 || _og0 - _oi > _ora
      || _ofo + _oi < 0.0 || _og2 - _oi > _ocf) {
    return;
  }
  let _og1 = _oaw(_oav(_og0 - _oi, 0.0), _ora);
  let _ofn = _oaw(_oav(_ofm + _oi, 0.0), _ora);
  let _og3 = _oaw(_oav(_og2 - _oi, 0.0), _ocf);
  let _ofp = _oaw(_oav(_ofo + _oi, 0.0), _ocf);
  let _obw = i32(_o5o._op7);
  let _obx = i32(_o5o._op8);
  let _opm = max(0, min(_obw, i32(floor(_og1 * 0.0625))));
  let _opp = max(0, min(_obx, i32(floor(_og3 * 0.0625))));
  let _opn = max(0, min(_obw, i32(floor(_ofn * 0.0625)) + 1));
  let _opq = max(0, min(_obx, i32(floor(_ofp * 0.0625)) + 1));
  if (_opm >= _opn || _opp >= _opq) {
    return;
  }
  let _ojz = f32(max(_orc, _oce));
  let _ofi = max(1, i32(ceil(_oaw(_ofh, _ojz))));
  let _ohb = _o4u(_oop, _o79, _ok8, _ok9, _oim, _o7v,
                                   _o2u, _o3u, _opy, _ohr, _okk.z, _orc, _oce);
  var _oiw: _o1p;
  _oiw._o3b = vec4f(_o5g, _o5h, _o5i, select(_ok8, -abs(_ok8), _oim));
  _oiw._o4m = vec4f(_ojc, _oej, _o7v, _ok9);
  _oiw.ab = vec4f(_o2u, _o3u);
  _oiw._obj = vec4f(_oht, _ohr, _o8j, f32(_ofi));
  _oiw._okl = vec4u(u32(_opm), u32(_opp), u32(_opn), u32(_opq));
  _oiw._okk = _okk;
  _oiw._ohc = vec4f(_ohb._oqo, _ohb._oqf);
  _oiw._ohd = vec4f(_ohb._oqk, _ohb._or6, _ohb._or7);
  _oiw._ohe = vec4f(_ohb._oe0, _ohb._oe2, _ohb._ofe, bitcast<f32>(_ohb._oat));
  _oiy[_oct] = _oiw;
  let _o7c = _ohf(_o2u, _o3u, _ohr, _ohb);
  let _okm = _ogt(_o2u, _o3u, _oht, _ohr);
  var _og9 = 0u;
  for (var _opo = u32(_opp); _opo < u32(_opq); _opo = _opo + 1u) {
    let _omx = _op5(_okm, _ohb, _o7c, _opo, _orc,
                                     u32(_opm), u32(_opn));
    if (_omx.z != 0u) {
      _og9 = _og9 + (_omx.y - _omx.x);
    }
  }
  _op6[_oct] = _og9;
}
@compute @workgroup_size(256)
fn duplicate_keys_beta(@builtin(local_invocation_index) _oex: u32,
                       @builtin(workgroup_id) _orb: vec3u,
                       @builtin(num_workgroups) _ogm: vec3u) {
  let _oct = _of2(_orb, _ogm) * _o2h + _oex;
  if (_oct >= _o9g[_o1u]) {
    return;
  }
  let _oiw = _o9i[_oct];
  if (!(_oiw._obj.w > 0.0)) {
    return;
  }
  var off = 0u;
  if (_oct > 0u) {
    off = _o9h[_oct - 1u];
  }
  let _o2u = _oiw.ab.xy;
  let _o3u = _oiw.ab.zw;
  let _ohb = _ohh(_oiw);
  let _o7c = _ohf(_o2u, _o3u, _oiw._obj.y, _ohb);
  let _okm = _ogt(_o2u, _o3u, _oiw._obj.x, _oiw._obj.y);
  let _o8k = bitcast<u32>(_oiw._obj.z);
  let _o5t = _o9f._o5t;
  for (var y = _oiw._okl.y; y < _oiw._okl.w; y = y + 1u) {
    let _omx = _op5(_okm, _ohb, _o7c, y,
                                     _o9f._orc, _oiw._okl.x, _oiw._okl.z);
    if (_omx.z == 0u) {
      continue;
    }
    for (var x = _omx.x; x < _omx.y; x = x + 1u) {
      if (off < _o5t) {
        _oeb[off] = y * _o9f._op7 + x;
        _oec[off] = _o8k;
        _oi4[off] = _oct;
      }
      off = off + 1u;
    }
  }
}
