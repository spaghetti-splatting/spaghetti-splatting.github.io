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
@group(0) @binding(0) var<storage, read> _oe8: array<u32>;
@group(0) @binding(1) var<storage, read> _o9x: array<f32>;
@group(0) @binding(2) var<storage, read> _oq5: array<f32>;
@group(0) @binding(3) var<storage, read> _oiy: array<vec4u>;
@group(0) @binding(4) var<storage, read> _o7m: array<u32>;
@group(0) @binding(5) var<storage, read_write> _oiz: array<_o1p>;
@group(0) @binding(6) var<storage, read_write> _op7: array<u32>;
@group(0) @binding(7) var<uniform> _o5o: _oo;
@group(0) @binding(0) var<storage, read> _o9j: array<_o1p>;
@group(0) @binding(1) var<storage, read> _o9i: array<u32>;
@group(0) @binding(2) var<storage, read> _o9h: array<u32>;
@group(0) @binding(3) var<storage, read_write> _oec: array<u32>;
@group(0) @binding(4) var<storage, read_write> _oed: array<u32>;
@group(0) @binding(5) var<storage, read_write> _oi5: array<u32>;
@group(0) @binding(6) var<uniform> _o9g: _oo;
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
var<private> _on9: array<f32, 11>;
var<private> _om9: array<f32, 5>;
fn _oqv(_odx: u32) -> f32 {
  return _o5o._oqq[_odx >> 2u][_odx & 3u];
}
fn _oik(_odx: u32) -> f32 {
  return _o5o._oj5[_odx >> 2u][_odx & 3u];
}
fn _o9a(x: vec3f, y: vec3f) -> f32 {
  return x.x * y.x + x.y * y.y + x.z * y.z;
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
fn _oam(_obg: f32) {
  let _ojt = _oav(_obg, -0.3, 0.3);
  let _oju = _oav(_obg, -5.0 / 21.0, 10.0 / 21.0);
  let _ojv = _oav(_obg, -7.0 / 36.0, 21.0 / 36.0);
  _om9[0] = 1.0;
  _om9[1] = _obg * (-1.0 / 3.0);
  _om9[2] = _om9[1] * _ojt;
  _om9[3] = _om9[2] * _oju;
  _om9[4] = _om9[3] * _ojv;
}
struct _op {
  _oo8: f32, _oo9: f32, _ooa: f32, _oob: f32, _ooc: f32, _ood: f32,
};
fn _o65(_o2i: f32, _o2j: f32, _o2k: f32, _o2l: f32, _o2p: f32, _o2q: f32, _o2r: f32, _oo6: _op) -> f32 {
  var _o2z = _o2i;
  _o2z = _oav(_o2j, _oo6._oo8, _o2z);
  _o2z = _oav(_o2k, _oo6._oo9, _o2z);
  _o2z = _oav(_o2l, _oo6._ooa, _o2z);
  _o2z = _oav(_o2p, _oo6._oob, _o2z);
  _o2z = _oav(_o2q, _oo6._ooc, _o2z);
  _o2z = _oav(_o2r, _oo6._ood, _o2z);
  return _o2z;
}
fn _on8(_obg: f32) {
  _on9[0] = _obg;
  let _obo = _obg + 1.0;
  let r = inverseSqrt(_obo);
  let z = _oav(r, _o3, _o2);
  let _ort = z + z;
  var _oo6: _op;
  _oo6._oo8 = z;
  _oo6._oo9 = _oav(_ort, _oo6._oo8, -1.0);
  _oo6._ooa = _oav(_ort, _oo6._oo9, -_oo6._oo8);
  _oo6._oob = _oav(_ort, _oo6._ooa, -_oo6._oo9);
  _oo6._ooc = _oav(_ort, _oo6._oob, -_oo6._ooa);
  _oo6._ood = _oav(_ort, _oo6._ooc, -_oo6._oob);
  let _o81 = _o65(_o2b[0], _o2b[1], _o2b[2], _o2b[3], _o2b[4], _o2b[5], _o2b[6], _oo6);
  let _o82 = _o65(_o2b[7], _o2b[8], _o2b[9], _o2b[10], _o2b[11], _o2b[12], _o2b[13], _oo6);
  let _o83 = _o65(_o2b[14], _o2b[15], _o2b[16], _o2b[17], _o2b[18], _o2b[19], _o2b[20], _oo6);
  let _o84 = _o65(_o2b[21], _o2b[22], _o2b[23], _o2b[24], _o2b[25], _o2b[26], _o2b[27], _oo6);
  let _o85 = _o65(_o2b[28], _o2b[29], _o2b[30], _o2b[31], _o2b[32], _o2b[33], _o2b[34], _oo6);
  let _o86 = _o65(_o2b[35], _o2b[36], _o2b[37], _o2b[38], _o2b[39], _o2b[40], _o2b[41], _oo6);
  let _o87 = _o65(_o2b[42], _o2b[43], _o2b[44], _o2b[45], _o2b[46], _o2b[47], _o2b[48], _oo6);
  let _o88 = _o65(_o2b[49], _o2b[50], _o2b[51], _o2b[52], _o2b[53], _o2b[54], _o2b[55], _oo6);
  let _o89 = _o65(_o2b[56], _o2b[57], _o2b[58], _o2b[59], _o2b[60], _o2b[61], _o2b[62], _oo6);
  let g = _o65(_o2a[0], _o2a[1], _o2a[2], _o2a[3], _o2a[4],
                _o2a[5], _o2a[6], _oo6);
  let _obe = _o65(_o29[0], _o29[1], _o29[2],
                        _o29[3], _o29[4], _o29[5],
                        _o29[6], _oo6);
  let _oab = r * g;
  let _odd = (_obo * r) * _obe;
  _on9[1] = _oab;
  _on9[2] = _o81;
  var _ois = _odd;
  _on9[3] = _o82 * _ois;
  _ois = _ois * _odd;
  _on9[4] = _o83 * _ois;
  _ois = _ois * _odd;
  _on9[5] = _o84 * _ois;
  _ois = _ois * _odd;
  _on9[6] = _o85 * _ois;
  _ois = _ois * _odd;
  _on9[7] = _o86 * _ois;
  _ois = _ois * _odd;
  _on9[8] = _o87 * _ois;
  _ois = _ois * _odd;
  _on9[9] = _o88 * _ois;
  _ois = _ois * _odd;
  _on9[10] = _o89 * _ois;
  _ois = _ois * _odd;
}
struct _o17 {
  _oqi: f32,
};
fn _o4h(_oqd: f32) -> _o17 {
  let _obg = _on9[0];
  let _oh2 = _oaw(_oav(-_oqd, _oqd, 1.0), _o4);
  let _ofe = log2(_oh2);
  let _oj8 = exp2((_obg + 1.0) * _ofe);
  var _o2z = _on9[10];
  _o2z = _oav(_o2z, _oqd, _on9[9]);
  _o2z = _oav(_o2z, _oqd, _on9[8]);
  _o2z = _oav(_o2z, _oqd, _on9[7]);
  _o2z = _oav(_o2z, _oqd, _on9[6]);
  _o2z = _oav(_o2z, _oqd, _on9[5]);
  _o2z = _oav(_o2z, _oqd, _on9[4]);
  _o2z = _oav(_o2z, _oqd, _on9[3]);
  _o2z = _oav(_o2z, _oqd, _on9[2]);
  _o2z = _oav(_o2z, _oqd, _on9[1]);
  let _o79 = _oj8 * _o2z;
  let _ops = _oqd * _oqd;
  var _ont = _om9[4];
  _ont = _oav(_ont, _ops, _om9[3]);
  _ont = _oav(_ont, _ops, _om9[2]);
  _ont = _oav(_ont, _ops, _om9[1]);
  _ont = _oav(_ont, _ops, _om9[0]);
  var _o9s: _o17;
  _o9s._oqi = select(_on9[1] - _o79, _ont * _oqd, _oqd <= _od);
  return _o9s;
}
const _ok: u32 = 0u;
const _oj: u32 = 1u;
const _ol: u32 = 2u;
struct _o1k {
  _o4t: u32,
  _o9w: f32,
  _ohn: f32,
};
fn _o3m(_oeg: f32) -> _o1k {
  var _oi9: _o1k;
  _oi9._o9w = 0.0;
  let _obg = _on9[0];
  if (_oeg < _o2g) {
    _oi9._o4t = _ok;
    let _o40 = _oav(-0.3 * _oeg, _oeg, 1.0);
    let _ois = exp2(_obg * log2(_o40));
    _oi9._ohn = _oav(5.0 / 9.0, _ois, 4.0 / 9.0);
  } else if (_oeg <= _oe) {
    _oi9._o4t = _oj;
    let _oqd = _oeg * _o9;
    _oi9._o9w = _o4h(_oqd)._oqi;
    _oi9._ohn = _oi9._o9w / _oqd;
  } else {
    _oi9._o4t = _ol;
    _oi9._ohn = _oe * _on9[1] / _oeg;
  }
  return _oi9;
}
fn _oq4(_oek: f32, g: f32) -> f32 {
  let _oi9 = _o3m(_oek / g);
  return g * g / _oi9._ohn;
}
fn _onf(a: f32, _og7: f32, w: f32, g: f32, _oky: f32,
                           _oeg: f32) -> f32 {
  let _oi9 = _o3m(_oeg);
  if (_oi9._o4t == _ok) {
    return a * g * g * _og7 / _oi9._ohn;
  }
  let _oaa = select(_on9[1], _oi9._o9w, _oi9._o4t == _oj);
  return a * g * _oky / (_oe * w * _oaa);
}
fn _ond(_oc3: f32, _o8o: f32, _oeg: f32) -> f32 {
  let _obg = _on9[0];
  if (_oeg < _o2g) {
    let _o40 = _oav(-0.3, _oc3 / _o8o, 1.0);
    let _ois = exp2(_obg * log2(_o40));
    return _oav(5.0 / 9.0, _ois, 4.0 / 9.0) * inverseSqrt(_o8o);
  }
  let _oi9 = _o3m(_oeg);
  let _oaa = select(_on9[1], _oi9._o9w, _oi9._o4t == _oj);
  return _oe * _oaa * inverseSqrt(_oc3);
}
fn _onc(_oaj: _o1, g: f32, _o7a: vec3f,
                          _ooq: vec3f, _oa2: f32, _oa8: f32) -> f32 {
  let _orv = !_oaj._oa3 && !(_oaj._oft > 0.0);
  let a = _oaj._opi;
  let w = _oaj._okf;
  let _og7 = _oaj._ogi;
  var _oq3 = 0.0;
  if (!_orv) {
    let _oky = sqrt(_oaj._oft);
    let _oeg = _oky / (g * _og7 * w);
    _oq3 = _onf(a, _og7, w, g, _oky, _oeg);
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
  let _oao = _ond(_oc4, _o8o, _oej);
  return _oq3 * _oao;
}
struct _ow {
  _oh0: bool,
  a: vec4f,
  b: vec4f,
};
fn _o6t(_ohv: vec4f, _oi7: vec4f) -> _ow {
  var _okr: _ow;
  _okr._oh0 = false;
  let _o80 = _oi7 - _ohv;
  let _ogk = _ohv.w - _o2c;
  let _o8i = _o80.w;
  var _oo7 = 0.0;
  var _oo8 = 1.0;
  if (_o8i == 0.0) {
    if (_ogk < 0.0) {
      return _okr;
    }
  } else {
    let _opb = -_ogk / _o8i;
    if (_o8i > 0.0) {
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
const _o26: u32 = 1u;
const _o27: u32 = 2u;
const _o28: u32 = 4u;
struct _o1i {
  _oqp: vec2f,
  _oqg: vec2f,
  _oql: vec2f,
  _or7: f32,
  _or8: f32,
  _oe1: f32,
  _oe3: f32,
  _off: f32,
  _oau: u32,
};
fn _ohi(_ohn: _o1p) -> _o1i {
  var _ogr: _o1i;
  _ogr._oqp = _ohn._ohd.xy;
  _ogr._oqg = _ohn._ohd.zw;
  _ogr._oql = _ohn._ohe.xy;
  _ogr._or7 = _ohn._ohe.z;
  _ogr._or8 = _ohn._ohe.w;
  _ogr._oe1 = _ohn._ohf.x;
  _ogr._oe3 = _ohn._ohf.y;
  _ogr._off = _ohn._ohf.z;
  _ogr._oau = bitcast<u32>(_ohn._ohf.w);
  return _ogr;
}
struct _o1q {
  _oho: vec2f,
  _ohp: vec2f,
  _ohq: vec2f,
  _ohr: vec2f,
};
struct _oy {
  _ofu: _o1q,
  _o9u: _o1q,
  _o9v: _o1q,
};
fn _o36(_ohn: vec2f, a: vec2f, _o9n: vec2f) -> f32 {
  return _oav(_ohn.y - a.y, _o9n.y, (_ohn.x - a.x) * _o9n.x);
}
fn _ohl(a: vec2f, _o9n: vec2f, _oho: vec2f, _ohp: vec2f, _ofg: vec2f, _ofh: vec2f) -> _o1q {
  let _oo0 = _o36(_oho, a, _o9n) > _o36(_ohp, a, _o9n);
  let _onz = _o36(_ofg, a, _o9n) > _o36(_ofh, a, _o9n);
  return _o1q(select(_oho, _ohp, _oo0), select(_ohp, _oho, _oo0),
              select(_ofh, _ofg, _onz), select(_ofg, _ofh, _onz));
}
fn _ogy(a: vec2f, _ola: f32, _oqd: vec2f) -> vec2f {
  return vec2f(_oav(_ola, _oqd.x, a.x), _oav(_ola, _oqd.y, a.y));
}
fn _ohg(a: vec2f, b: vec2f, _ohs: f32, _ogr: _o1i) -> _oy {
  let _o9n = b - a;
  let _oet = _ocq(_o9n.x, _o9n.y);
  let _omd = _oet < 1e-4;
  let _olj = select(_o9n, vec2f(1.0, 0.0), _omd);
  let _olk = select(_oet, 1.0, _omd);
  let _og7 = vec2f(-_olj.y / _olk, _olj.x / _olk);
  let _ops = vec2f(_olj.x / _olk, _olj.y / _olk);
  let _o2v = _ogy(a, -_ogr._or7, _ogr._oqp);
  let _o2w = _ogy(a, _ogr._or7, _ogr._oqp);
  let _o3v = _ogy(b, -_ogr._or8, _ogr._oqp);
  let _o3w = _ogy(b, _ogr._or8, _ogr._oqp);
  var _o2t: vec2f;
  var _o2s: vec2f;
  var _o3t: vec2f;
  var _o3s: vec2f;
  if ((_ogr._oau & _o27) != 0u) {
    let _o2i = _ogy(a, -_ohs, _ops);
    _o2t = _ogy(_o2i, _ogr._or7, _og7);
    _o2s = _ogy(_o2i, -_ogr._or7, _og7);
  } else {
    let _o2i = _ogy(a, -_ogr._oe1, _o9n);
    _o2t = _ogy(_o2i, _ogr._or7, _ogr._oqg);
    _o2s = _ogy(_o2i, -_ogr._or7, _ogr._oqg);
  }
  if ((_ogr._oau & _o28) != 0u) {
    let _o3q = _ogy(b, _ohs, _ops);
    _o3t = _ogy(_o3q, _ogr._or8, _og7);
    _o3s = _ogy(_o3q, -_ogr._or8, _og7);
  } else {
    let _o3q = _ogy(b, _ogr._oe3, _o9n);
    _o3t = _ogy(_o3q, _ogr._or8, _ogr._oql);
    _o3s = _ogy(_o3q, -_ogr._or8, _ogr._oql);
  }
  return _oy(_o1q(_o2v, _o3v, _o3w, _o2w),
                 _ohl(a, _o9n, _o2w, _o2t, _o2v, _o2s),
                 _ohl(a, _o9n, _o3w, _o3t, _o3v, _o3s));
}
fn _o3y(_oho: vec2f, _ohp: vec2f, _ors: f32, _orr: f32, _ok1: vec2f) -> vec2f {
  var _oro = _ok1.x;
  var _orm = _ok1.y;
  if (_oho.y >= _ors && _oho.y <= _orr) {
    _oro = _oax(_oro, _oho.x);
    _orm = _oaw(_orm, _oho.x);
  }
  if (_oaw(_oho.y, _ohp.y) < _ors || _oax(_oho.y, _ohp.y) > _orr) {
    return vec2f(_oro, _orm);
  }
  let _o9l = _ohp.y - _oho.y;
  if (_o9l != 0.0) {
    let _ook = _oax(_oaw((_ors - _oho.y) / _o9l, 0.0), 1.0);
    let _oot = _oax(_oaw((_orr - _oho.y) / _o9l, 0.0), 1.0);
    let _ork = _oav(_ook, _ohp.x - _oho.x, _oho.x);
    let _orl = _oav(_oot, _ohp.x - _oho.x, _oho.x);
    _oro = _oax(_oro, _oax(_ork, _orl));
    _orm = _oaw(_orm, _oaw(_ork, _orl));
  } else {
    _oro = _oax(_oro, _oax(_oho.x, _ohp.x));
    _orm = _oaw(_orm, _oaw(_oho.x, _ohp.x));
  }
  return vec2f(_oro, _orm);
}
fn _o3z(_ojc: _o1q, _ors: f32, _orr: f32, _ok1: vec2f) -> vec2f {
  var r = _o3y(_ojc._oho, _ojc._ohp, _ors, _orr, _ok1);
  r = _o3y(_ojc._ohp, _ojc._ohq, _ors, _orr, r);
  r = _o3y(_ojc._ohq, _ojc._ohr, _ors, _orr, r);
  return _o3y(_ojc._ohr, _ojc._oho, _ors, _orr, r);
}
fn _ogv(_oho: vec2f, _ohp: vec2f, _ors: f32, _orr: f32, _ok1: vec2f) -> vec2f {
  var _oro = _ok1.x;
  var _orm = _ok1.y;
  if (_oho.y >= _ors && _oho.y <= _orr) {
    _oro = _oax(_oro, _oho.x);
    _orm = _oaw(_orm, _oho.x);
  }
  let _o9l = _ohp.y - _oho.y;
  if (_o9l != 0.0) {
    let _oo7 = (_ors - _oho.y) / _o9l;
    if (_oo7 > 0.0 && _oo7 < 1.0) {
      let x = _oav(_oo7, _ohp.x - _oho.x, _oho.x);
      _oro = _oax(_oro, x);
      _orm = _oaw(_orm, x);
    }
    let _oo8 = (_orr - _oho.y) / _o9l;
    if (_oo8 > 0.0 && _oo8 < 1.0) {
      let x = _oav(_oo8, _ohp.x - _oho.x, _oho.x);
      _oro = _oax(_oro, x);
      _orm = _oaw(_orm, x);
    }
  }
  return vec2f(_oro, _orm);
}
fn _ogu(a: vec2f, b: vec2f, _ohu: f32, _ohs: f32) -> _o1q {
  let _o8z = b - a;
  let _oet = _ocq(_o8z.x, _o8z.y);
  let _omd = _oet < 1e-4;
  let _olj = select(_o8z, vec2f(1.0, 0.0), _omd);
  let _olk = select(_oet, 1.0, _omd);
  let _opz = vec2f(-_olj.y / _olk, _olj.x / _olk);
  let _opy = vec2f(_olj.x / _olk, _olj.y / _olk);
  let _oit = _ohu + _oi;
  let _ohv = _ohs + _oi;
  let _o5f = vec2f(_oav(-_opy.x, _ohv, _oav(_opz.x, _oit, a.x)),
                 _oav(-_opy.y, _ohv, _oav(_opz.y, _oit, a.y)));
  let _o50 = vec2f(_oav(-_opy.x, _ohv, _oav(-_opz.x, _oit, a.x)),
                 _oav(-_opy.y, _ohv, _oav(-_opz.y, _oit, a.y)));
  let _o5e = vec2f(_oav(_opy.x, _ohv, _oav(_opz.x, _oit, b.x)),
                 _oav(_opy.y, _ohv, _oav(_opz.y, _oit, b.y)));
  let _o57 = vec2f(_oav(_opy.x, _ohv, _oav(-_opz.x, _oit, b.x)),
                 _oav(_opy.y, _ohv, _oav(-_opz.y, _oit, b.y)));
  return _o1q(_o50, _o57, _o5e, _o5f);
}
fn _omz(_ok1: vec2f, _ord: u32, _opn: i32, _opo: i32, _off: f32) -> vec3u {
  let _or2 = f32(_ord - 1u);
  let _orp = _oax(_oaw(_ok1.x - _off, 0.0), _or2);
  let _orn = _oax(_oaw(_ok1.y + _off, 0.0), _or2);
  let _oo2 = max(_opn, i32(floor(_orp * 0.0625)));
  let _oo3 = min(_opo, i32(floor(_orn * 0.0625)) + 1);
  let _oh0 = _ok1.y >= _ok1.x && _oo3 > _oo2;
  return select(vec3u(0u), vec3u(u32(_oo2), u32(_oo3), 1u), _oh0);
}
fn _op6(_ol5: _o1q, _ogr: _o1i, _o4z: _oy, _opp: u32, _ord: u32,
                         _opn: u32, _opo: u32) -> vec3u {
  let _ors = f32(_opp * _oh);
  let _orr = f32(_opp * _oh + (_oh - 1u));
  var r = _ogv(_ol5._oho, _ol5._ohp, _ors, _orr, vec2f(3.4e38, -3.4e38));
  r = _ogv(_ol5._ohp, _ol5._ohq, _ors, _orr, r);
  r = _ogv(_ol5._ohq, _ol5._ohr, _ors, _orr, r);
  r = _ogv(_ol5._ohr, _ol5._oho, _ors, _orr, r);
  let _okm = _omz(r, _ord, i32(_opn), i32(_opo), 0.0);
  let _oh1 = _ors - _ogr._off;
  let _ogz = _orr + _ogr._off;
  var _ojc = _o3z(_o4z._ofu, _oh1, _ogz, vec2f(3.4e38, -3.4e38));
  _ojc = _o3z(_o4z._o9u, _oh1, _ogz, _ojc);
  _ojc = _o3z(_o4z._o9v, _oh1, _ogz, _ojc);
  let _ohk = _omz(_ojc, _ord, i32(_okm.x), i32(_okm.y), _ogr._off);
  let _oqb = _okm.z == 0u || (_ogr._oau & _o26) != 0u;
  return select(_ohk, _okm, _oqb);
}
fn _oj3(a: f32, b: f32, _o4z: f32, _o80: f32) -> f32 {
  let _ohn = _opl(a, b);
  let _ojc = _opl(_o4z, _o80);
  let _ola = _opm(_ohn.x, -_ojc.x);
  let _ofb = (_ohn.y - _ojc.y) + _ola.y;
  return _ola.x + _ofb;
}
fn _ohj(_ohn: vec2f, a: vec2f, _o9n: vec2f, _o9q: f32) -> f32 {
  let _o9k = _ohn.x - a.x;
  let _o9l = _ohn.y - a.y;
  let _oo6 = _oax(_oaw((_o9k * _o9n.x + _o9l * _o9n.y) / _o9q, 0.0), 1.0);
  return _ocq(_o9k - _oo6 * _o9n.x, _o9l - _oo6 * _o9n.y);
}
fn _oaq(_oqd: vec2f) -> bool {
  return _odk(_oqd.x) && _odk(_oqd.y);
}
struct _o1j {
  w: f32,
  _oqd: vec2f,
  _oe2: f32,
};
fn _ohh(g: f32, _olf: f32, _o5j: vec2f, _og7: vec2f, _o8p: f32, _opf: f32, _o4f: f32,
               _odx: f32, _oef: f32) -> _o1j {
  let gg = g * g;
  let _olh = gg * _olf + _o4f;
  let _o8s = gg * gg * _o8p + gg * _o4f * _opf + _o4f * _o4f;
  var _o9s: _o1j;
  _o9s.w = _odx * sqrt(_olh);
  _o9s._oqd = vec2f((gg * _o5j.x + _o4f * _og7.x) / _olh, (gg * _o5j.y + _o4f * _og7.y) / _olh);
  _o9s._oe2 = _odx * sqrt(_o8s / _olh) / _oef;
  return _o9s;
}
fn _onp(g: f32, _oa0: f32, _o9y: f32, _o8p: f32, _opf: f32, _o4f: f32,
                       _o7u: f32) -> bool {
  let gg = g * g;
  let _oc3 = _oav(gg, _oa0, _o4f * _o9y);
  let _o8o = _oav(gg, _oav(gg, _o8p, _o4f * _opf), _o4f * _o4f);
  let _o7v = _o7u * _oc3;
  let _oj2 = _o7v * _o8o;
  return !_odk(_oj2) || _oj2 > 1e37;
}
fn _o7c(_ohn: vec2f, a: vec2f, _o9n: vec2f, _o9q: f32, _oki: vec2f) -> vec2f {
  let _oap = _oki.y != 0.0 && _oaq(_ohn);
  return vec2f(_oaw(_oki.x, _ohj(_ohn, a, _o9n, _o9q)), select(0.0, 1.0, _oap));
}
fn _ojm(_ojc: _o1q, a: vec2f, _o9n: vec2f, _o9q: f32, _oki: vec2f) -> vec2f {
  var r = _o7c(_ojc._oho, a, _o9n, _o9q, _oki);
  r = _o7c(_ojc._ohp, a, _o9n, _o9q, r);
  r = _o7c(_ojc._ohq, a, _o9n, _o9q, r);
  return _o7c(_ojc._ohr, a, _o9n, _o9q, r);
}
fn _o4u(_o5f: vec3f, _o5k: vec3f, _ok9: f32, _oka: f32, _oin: bool,
                      _o7u: f32, a: vec2f, b: vec2f, _og7: vec2f, _ohs: f32,
                      _o4f: f32, _ord: u32, _ocf: u32) -> _o1i {
  var _ogr: _o1i;
  _ogr._oqp = vec2f(0.0);
  _ogr._oqg = vec2f(0.0);
  _ogr._oql = vec2f(0.0);
  _ogr._or7 = 0.0;
  _ogr._or8 = 0.0;
  _ogr._oe1 = 0.0;
  _ogr._oe3 = 0.0;
  _ogr._off = 0.0;
  _ogr._oau = _o26;
  if (_oin) {
    return _ogr;
  }
  let _o9n = b - a;
  let _o9q = _o9n.x * _o9n.x + _o9n.y * _o9n.y;
  let _oef = sqrt(_o9q);
  let _odx = sqrt(_o7u);
  let _o8p = _oaw(_oj3(_o5f.x, _o5f.z, _o5f.y, _o5f.y), 0.0);
  let _opf = _o5f.x + _o5f.z;
  let _o63 = vec2f(_o5k.x * _og7.x + _o5k.y * _og7.y, _o5k.y * _og7.x + _o5k.z * _og7.y);
  let _olg = _og7.x * _o63.x + _og7.y * _o63.y;
  _ogr._oqp = vec2f(_o63.x / _olg, _o63.y / _olg);
  let _o5j = vec2f(_o5f.x * _og7.x + _o5f.y * _og7.y, _o5f.y * _og7.x + _o5f.z * _og7.y);
  let _olf = _og7.x * _o5j.x + _og7.y * _o5j.y;
  let _o9u = _ohh(_ok9, _olf, _o5j, _og7, _o8p, _opf, _o4f, _odx, _oef);
  let _o9v = _ohh(_oka, _olf, _o5j, _og7, _o8p, _opf, _o4f, _odx, _oef);
  _ogr._or7 = _o9u.w;
  _ogr._or8 = _o9v.w;
  _ogr._oqg = _o9u._oqd;
  _ogr._oql = _o9v._oqd;
  _ogr._oe1 = _o9u._oe2;
  _ogr._oe3 = _o9v._oe2;
  let _obf = _oaw(_ok9, _oka);
  let _obl = _obf * _obf;
  let _opg = _obl * _opf + 2.0 * _o4f;
  let _o8r = _obl * _obl * _o8p + _obl * _o4f * _opf + _o4f * _o4f;
  let _ops = 5.9604644775390625e-8;
  let r = 16.0 * _ops * _opg * _opg / _o8r;
  let _o8e = _oaw(_oaw(abs(a.x), abs(a.y)), _oaw(abs(b.x), abs(b.y)))
         + f32(_ord) + f32(_ocf);
  let _o8g = !(_o8r > 0.0) || !_odk(_o8r) || (_o4f == 0.0 && _o8p == 0.0);
  let _o2n = _o5f.z * _o9n.x - _o5f.y * _o9n.y;
  let _o2o = _o5f.x * _o9n.y - _o5f.y * _o9n.x;
  let _oa0 = _oaw(_o9n.x * _o2n + _o9n.y * _o2o, 0.0);
  let _o9y = _o9n.x * _o9n.x + _o9n.y * _o9n.y;
  let _okj = _oaw(_o5f.x * _o5f.z - _o5f.y * _o5f.y, 0.0);
  let _okk = _o5f.x + _o5f.z;
  var _oau = 0u;
  if (_onp(_ok9, _oa0, _o9y, _okj, _okk, _o4f, _o7u)) {
    _oau = _oau | _o27;
  }
  if (_onp(_ok9 + (_oka - _ok9), _oa0, _o9y, _okj, _okk, _o4f, _o7u)) {
    _oau = _oau | _o28;
  }
  _ogr._oau = _oau;
  let _o4z = _ohg(a, b, _ohs, _ogr);
  var _oki = _ojm(_o4z._ofu, a, _o9n, _o9q, vec2f(0.0, 1.0));
  _oki = _ojm(_o4z._o9u, a, _o9n, _o9q, _oki);
  _oki = _ojm(_o4z._o9v, a, _o9n, _o9q, _oki);
  var _oap = _oki.y != 0.0;
  let _o4l = _oki.x;
  _ogr._off = r * _o4l + 0.02 + 4.0 * _ops * _o8e;
  let _onn = (_oau & _o27) != 0u;
  let _ono = (_oau & _o28) != 0u;
  _oap = _oap && _oaq(_ogr._oqp) && _odk(_ogr._or7) && _odk(_ogr._or8)
      && (_onn || (_oaq(_ogr._oqg) && _odk(_ogr._oe1)))
      && (_ono || (_oaq(_ogr._oql) && _odk(_ogr._oe3)))
      && _odk(_o4l) && _odk(r) && _odk(_ogr._off);
  if (_o8g || !_oap) {
    _ogr._oau = _o26;
  }
  return _ogr;
}
@compute @workgroup_size(256)
fn preprocess_beta(@builtin(local_invocation_index) _oey: u32,
                   @builtin(workgroup_id) _orc: vec3u,
                   @builtin(num_workgroups) _ogn: vec3u) {
  let _ocu = _of3(_orc, _ogn) * _o2h + _oey;
  if (_ocu >= _o7m[_o1u]) {
    return;
  }
  let _omv = _oe8[_ocu];
  _op7[_ocu] = 0u;
  _oiz[_ocu]._obk = vec4f(0.0, 0.0, 0.0, 0.0);
  let _o3h = _oiy[_ocu];
  let _o38 = bitcast<f32>(_o3h.x);
  let _omb = bitcast<f32>(_o3h.y);
  let _ogr = 6u * _omv;
  let _ohw = vec3f(_o9x[_ogr], _o9x[_ogr + 1u], _o9x[_ogr + 2u]);
  let _oi8 = vec3f(_o9x[_ogr + 3u], _o9x[_ogr + 4u], _o9x[_ogr + 5u]);
  let _of2 = vec3f((_ohw.x + _oi8.x) * 0.5, (_ohw.y + _oi8.y) * 0.5, (_ohw.z + _oi8.z) * 0.5);
  let _o8k = _oqr(_of2);
  if (_o8k < _oc) {
    return;
  }
  let _o6r = _o6t(_oj7(_ohw), _oj7(_oi8));
  if (!_o6r._oh0) {
    return;
  }
  let _ord = _o5o._ord;
  let _ocf = _o5o._ocf;
  let _o2u = vec2f(_ogc(_o6r.a.x / _o6r.a.w, _ord), _ogc(_o6r.a.y / _o6r.a.w, _ocf));
  let _o3u = vec2f(_ogc(_o6r.b.x / _o6r.b.w, _ord), _ogc(_o6r.b.y / _o6r.b.w, _ocf));
  let _oan = _o5o._o4f;
  let _o5w = _oj7(_of2);
  var _om2 = _o5w.w > _o2c && _odk(_o5w.w);
  let _oll = select(1.0, _o5w.w, _om2);
  let _odb = 1.0 / (_oll * _oll);
  let _of1 = _oa * _oll;
  let _o68 = _oax(_oaw(_o5w.x, -_of1), _of1);
  let _o69 = _oax(_oaw(_o5w.y, -_of1), _of1);
  let _odq = _o68 != _o5w.x || _o69 != _o5w.y;
  let _occ = 0.5 * f32(_ord);
  let _oc9 = 0.5 * f32(_ocf);
  let _ods = vec3f(_occ * (_oll * _oik(0u) - _o68 * _oik(3u)) * _odb,
                 _occ * (_oll * _oik(4u) - _o68 * _oik(7u)) * _odb,
                 _occ * (_oll * _oik(8u) - _o68 * _oik(11u)) * _odb);
  let _odv = vec3f(_oc9 * (_oll * _oik(1u) - _o69 * _oik(3u)) * _odb,
                 _oc9 * (_oll * _oik(5u) - _o69 * _oik(7u)) * _odb,
                 _oc9 * (_oll * _oik(9u) - _o69 * _oik(11u)) * _odb);
  let _ofz = vec2f(_ogc(_o5w.x / _oll, _ord),
                           _ogc(_o5w.y / _oll, _ocf));
  let _ob3 = _oe9(_omv, _ods, _odv);
  let _obi = 4.0 * exp2(_omb * _ob);
  let _obh = !(_obi >= _o7 && _obi <= _o6);
  let _obg = _oax(_oaw(_obi, _o7), _o6);
  let _odt = _ob3._oan * _o9a(_ods, _ods);
  let _odu = _ob3._oan * _o9a(_ods, _odv);
  let _odw = _ob3._oan * _o9a(_odv, _odv);
  let _o5g = _ob3._o5l + _odt;
  let _o5h = _ob3._o5m + _odu;
  let _o5i = _ob3._o5n + _odw;
  let _oic = _oan;
  let _o51 = _o5g + _oic;
  let _o54 = _o5h;
  let _o5b = _o5i + _oic;
  _on8(_obg);
  _oam(_obg);
  let _okl = vec4f(select(_obg, -_obg, _obh), _obg, _oic, 0.0);
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
  var _okc = _okb * _odg;
  if (_odq) {
    let _ogj = vec3f(_ods.y * _odv.z - _ods.z * _odv.y,
                    _ods.z * _odv.x - _ods.x * _odv.z,
                    _ods.x * _odv.y - _ods.y * _odv.x);
    let _odf = inverseSqrt(_o9a(_ogj, _ogj));
    _okc = _ogj * _odf;
  }
  let _oaj = _o3a(_ob3, _ods, _odv, _okc, _o66.x, _o66.y);
  let _o7a = vec3f(_o51, _o54, _o5b);
  let _ooq = vec3f(_o5g, _o5h, _o5i);
  let _oks = _oaw(_o38, 0.0);
  let _ojd = _oks * _oaj._opi * _oaj._ogi;
  let _oek = sqrt(_oaj._oft) / (_oaj._ogi * _oaj._okf);
  _om2 = _om2 && (_oaj._oa3 || _oaj._oft > 0.0);
  let _ody = _onc(_oaj, _ok9, _o7a, _ooq, _o66.x, _o66.y);
  let _oe0 = _onc(_oaj, 1.0, _o7a, _ooq, _o66.x, _o66.y);
  let _odz = _onc(_oaj, _oka, _o7a, _ooq, _o66.x, _o66.y);
  let _oi9 = _oks * _oaw(_ody, _oaw(_oe0, _odz));
  let _opv = _ojd * _oq4(_oek, _ok9);
  let _opx = _ojd * _oq4(_oek, 1.0);
  let _opw = _ojd * _oq4(_oek, _oka);
  _om2 = _om2 && _oaj._oir && _odk(_oek)
      && _odk(_opv) && _odk(_opx) && _odk(_opw);
  if (!_om2) {
    return;
  }
  let _o5x = _ofz;
  let _ok8 = _o16 / _oaw(_oi9, _o16);
  let _o7w = _oaw(0.5 * (1.0 - exp2(log2(_ok8) / _obg)), 1e-6);
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
  let _o5s = _o8u + _ocq(_o5x.x - 0.5 * f32(_ord - 1u), _o5x.y - 0.5 * f32(_ocf - 1u));
  _ohu = _oax(_ohu, _o5s);
  _ohs = _oax(_ohs, _o5s);
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
  if (_ofn + _oi < 0.0 || _og1 - _oi > _orb
      || _ofp + _oi < 0.0 || _og3 - _oi > _ocg) {
    return;
  }
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
  let _ohc = _o4u(_ooq, _o7a, _ok9, _oka, _oin, _o7w,
                                   _o2u, _o3u, _opz, _ohs, _okl.z, _ord, _ocf);
  var _oix: _o1p;
  _oix._o3b = vec4f(_o5g, _o5h, _o5i, select(_ok9, -abs(_ok9), _oin));
  _oix._o4m = vec4f(_ojd, _oek, _o7w, _oka);
  _oix.ab = vec4f(_o2u, _o3u);
  _oix._obk = vec4f(_ohu, _ohs, _o8k, f32(_ofj));
  _oix._okm = vec4u(u32(_opn), u32(_opq), u32(_opo), u32(_opr));
  _oix._okl = _okl;
  _oix._ohd = vec4f(_ohc._oqp, _ohc._oqg);
  _oix._ohe = vec4f(_ohc._oql, _ohc._or7, _ohc._or8);
  _oix._ohf = vec4f(_ohc._oe1, _ohc._oe3, _ohc._off, bitcast<f32>(_ohc._oau));
  _oiz[_ocu] = _oix;
  let _o7d = _ohg(_o2u, _o3u, _ohs, _ohc);
  let _okn = _ogu(_o2u, _o3u, _ohu, _ohs);
  var _oga = 0u;
  for (var _opp = u32(_opq); _opp < u32(_opr); _opp = _opp + 1u) {
    let _omy = _op6(_okn, _ohc, _o7d, _opp, _ord,
                                     u32(_opn), u32(_opo));
    if (_omy.z != 0u) {
      _oga = _oga + (_omy.y - _omy.x);
    }
  }
  _op7[_ocu] = _oga;
}
@compute @workgroup_size(256)
fn duplicate_keys_beta(@builtin(local_invocation_index) _oey: u32,
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
  let _ohc = _ohi(_oix);
  let _o7d = _ohg(_o2u, _o3u, _oix._obk.y, _ohc);
  let _okn = _ogu(_o2u, _o3u, _oix._obk.x, _oix._obk.y);
  let _o8l = bitcast<u32>(_oix._obk.z);
  let _o5t = _o9g._o5t;
  for (var y = _oix._okm.y; y < _oix._okm.w; y = y + 1u) {
    let _omy = _op6(_okn, _ohc, _o7d, y,
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
