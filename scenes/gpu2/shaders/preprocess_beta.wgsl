struct _o1r {
  _o3f: vec4f,
  _o4r: vec4f,
  ab: vec4f,
  _oc2: vec4f,
  _olb: vec4u,
  _ola: vec4f,
  _oi2: vec4f,
  _oi3: vec4f,
  _oi4: vec4f,
};
@group(0) @binding(0) var<storage, read> _oev: array<u32>;
@group(0) @binding(1) var<storage, read> _oae: array<f32>;
@group(0) @binding(2) var<storage, read> _oqz: array<f32>;
@group(0) @binding(3) var<storage, read> _ojn: array<vec4u>;
@group(0) @binding(4) var<storage, read> _o83: array<u32>;
@group(0) @binding(5) var<storage, read_write> _ojo: array<_o1r>;
@group(0) @binding(6) var<storage, read_write> _oq0: array<u32>;
@group(0) @binding(7) var<uniform> _o5v: _oo;
@group(0) @binding(0) var<storage, read> _oa0: array<_o1r>;
@group(0) @binding(1) var<storage, read> _o9z: array<u32>;
@group(0) @binding(2) var<storage, read> _o9y: array<u32>;
@group(0) @binding(3) var<storage, read_write> _oez: array<u32>;
@group(0) @binding(4) var<storage, read_write> _of0: array<u32>;
@group(0) @binding(5) var<storage, read_write> _oiu: array<u32>;
@group(0) @binding(6) var<uniform> _o9x: _oo;
const _og: u32 = 16u;
const _oh: u32 = 16u;
const _o2e: f32 = 1e-3;
const _o18: f32 = 3.929278140e-03;
const _o2i: f32 = 0.1;
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
const _o2d = array<f32, 63>(
  -1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
  0.86907756, -0.08104082, 0.012049758, -0.00021792683, 2.1956479e-05, -1.45608055e-05, -2.4834957e-05,
  -0.70016533, 0.17784852, -0.029768402, 0.0013841696, -0.0002165212, 0.00020030937, 0.000181285,
  0.538863, -0.25318372, 0.051725097, -0.0043851244, 0.00028628978, -0.0007355512, -0.0004591238,
  -0.39315897, 0.28637674, -0.07442167, 0.010118952, -3.2378295e-05, 0.0011633757, 0.000537747,
  0.25465247, -0.25353765, 0.08320036, -0.016473958, 0.00047484812, -0.00091163174, -0.00032065576,
  -0.12885943, 0.15803069, -0.06287364, 0.016344883, -0.0015109606, 0.00043000313, 0.00010007449,
  0.04232212, -0.059212293, 0.027284678, -0.008595316, 0.0013526595, -0.00018219583, -1.2701726e-05,
  -0.006454065, 0.00980119, -0.005036595, 0.0018203161, -0.0003864131, 5.108729e-05, -1.2723773e-06);
const _o2c = array<f32, 7>(
  0.9317711, -0.04327248, 0.0059742252, 8.372514e-06, -1.3490912e-05, 1.0639736e-06, 1.9153707e-07);
const _o2b = array<f32, 7>(
  1.0743952, 0.049604684, -0.0057441797, -0.0003010808, 2.6747155e-05, 7.308961e-07, -3.6029135e-07);
var<private> _oo1: array<f32, 11>;
var<private> _omz: array<f32, 5>;
fn _orp(_oei: u32) -> f32 {
  return _o5v._ork[_oei >> 2u][_oei & 3u];
}
fn _oj9(_oei: u32) -> f32 {
  return _o5v._oju[_oei >> 2u][_oei & 3u];
}
fn _o9r(x: vec3f, y: vec3f) -> f32 {
  return x.x * y.x + x.y * y.y + x.z * y.z;
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
fn _ob3(_oby: f32) {
  let _oki = _obd(_oby, -0.3, 0.3);
  let _okj = _obd(_oby, -5.0 / 21.0, 10.0 / 21.0);
  let _okk = _obd(_oby, -7.0 / 36.0, 21.0 / 36.0);
  _omz[0] = 1.0;
  _omz[1] = _oby * (-1.0 / 3.0);
  _omz[2] = _omz[1] * _oki;
  _omz[3] = _omz[2] * _okj;
  _omz[4] = _omz[3] * _okk;
}
struct _op {
  _op1: f32, _op2: f32, _op3: f32, _op4: f32, _op5: f32, _op6: f32,
};
fn _o6c(_o2k: f32, _o2l: f32, _o2m: f32, _o2n: f32, _o2r: f32, _o2s: f32, _o2t: f32, _ooz: _op) -> f32 {
  var _o31 = _o2k;
  _o31 = _obd(_o2l, _ooz._op1, _o31);
  _o31 = _obd(_o2m, _ooz._op2, _o31);
  _o31 = _obd(_o2n, _ooz._op3, _o31);
  _o31 = _obd(_o2r, _ooz._op4, _o31);
  _o31 = _obd(_o2s, _ooz._op5, _o31);
  _o31 = _obd(_o2t, _ooz._op6, _o31);
  return _o31;
}
fn _oo0(_oby: f32) {
  _oo1[0] = _oby;
  let _oc6 = _oby + 1.0;
  let r = inverseSqrt(_oc6);
  let z = _obd(r, _o3, _o2);
  let _osp = z + z;
  var _ooz: _op;
  _ooz._op1 = z;
  _ooz._op2 = _obd(_osp, _ooz._op1, -1.0);
  _ooz._op3 = _obd(_osp, _ooz._op2, -_ooz._op1);
  _ooz._op4 = _obd(_osp, _ooz._op3, -_ooz._op2);
  _ooz._op5 = _obd(_osp, _ooz._op4, -_ooz._op3);
  _ooz._op6 = _obd(_osp, _ooz._op5, -_ooz._op4);
  let _o8i = _o6c(_o2d[0], _o2d[1], _o2d[2], _o2d[3], _o2d[4], _o2d[5], _o2d[6], _ooz);
  let _o8j = _o6c(_o2d[7], _o2d[8], _o2d[9], _o2d[10], _o2d[11], _o2d[12], _o2d[13], _ooz);
  let _o8k = _o6c(_o2d[14], _o2d[15], _o2d[16], _o2d[17], _o2d[18], _o2d[19], _o2d[20], _ooz);
  let _o8l = _o6c(_o2d[21], _o2d[22], _o2d[23], _o2d[24], _o2d[25], _o2d[26], _o2d[27], _ooz);
  let _o8m = _o6c(_o2d[28], _o2d[29], _o2d[30], _o2d[31], _o2d[32], _o2d[33], _o2d[34], _ooz);
  let _o8n = _o6c(_o2d[35], _o2d[36], _o2d[37], _o2d[38], _o2d[39], _o2d[40], _o2d[41], _ooz);
  let _o8o = _o6c(_o2d[42], _o2d[43], _o2d[44], _o2d[45], _o2d[46], _o2d[47], _o2d[48], _ooz);
  let _o8p = _o6c(_o2d[49], _o2d[50], _o2d[51], _o2d[52], _o2d[53], _o2d[54], _o2d[55], _ooz);
  let _o8q = _o6c(_o2d[56], _o2d[57], _o2d[58], _o2d[59], _o2d[60], _o2d[61], _o2d[62], _ooz);
  let g = _o6c(_o2c[0], _o2c[1], _o2c[2], _o2c[3], _o2c[4],
                _o2c[5], _o2c[6], _ooz);
  let _obw = _o6c(_o2b[0], _o2b[1], _o2b[2],
                        _o2b[3], _o2b[4], _o2b[5],
                        _o2b[6], _ooz);
  let _oas = r * g;
  let _ody = (_oc6 * r) * _obw;
  _oo1[1] = _oas;
  _oo1[2] = _o8i;
  var _ojh = _ody;
  _oo1[3] = _o8j * _ojh;
  _ojh = _ojh * _ody;
  _oo1[4] = _o8k * _ojh;
  _ojh = _ojh * _ody;
  _oo1[5] = _o8l * _ojh;
  _ojh = _ojh * _ody;
  _oo1[6] = _o8m * _ojh;
  _ojh = _ojh * _ody;
  _oo1[7] = _o8n * _ojh;
  _ojh = _ojh * _ody;
  _oo1[8] = _o8o * _ojh;
  _ojh = _ojh * _ody;
  _oo1[9] = _o8p * _ojh;
  _ojh = _ojh * _ody;
  _oo1[10] = _o8q * _ojh;
  _ojh = _ojh * _ody;
}
struct _o19 {
  _orc: f32,
};
fn _o4m(_or7: f32) -> _o19 {
  let _oby = _oo1[0];
  let _ohr = _obe(_obd(-_or7, _or7, 1.0), _o4);
  let _og1 = log2(_ohr);
  let _ojx = exp2((_oby + 1.0) * _og1);
  var _o31 = _oo1[10];
  _o31 = _obd(_o31, _or7, _oo1[9]);
  _o31 = _obd(_o31, _or7, _oo1[8]);
  _o31 = _obd(_o31, _or7, _oo1[7]);
  _o31 = _obd(_o31, _or7, _oo1[6]);
  _o31 = _obd(_o31, _or7, _oo1[5]);
  _o31 = _obd(_o31, _or7, _oo1[4]);
  _o31 = _obd(_o31, _or7, _oo1[3]);
  _o31 = _obd(_o31, _or7, _oo1[2]);
  _o31 = _obd(_o31, _or7, _oo1[1]);
  let _o7q = _ojx * _o31;
  let _oqm = _or7 * _or7;
  var _oom = _omz[4];
  _oom = _obd(_oom, _oqm, _omz[3]);
  _oom = _obd(_oom, _oqm, _omz[2]);
  _oom = _obd(_oom, _oqm, _omz[1]);
  _oom = _obd(_oom, _oqm, _omz[0]);
  var _oa9: _o19;
  _oa9._orc = select(_oo1[1] - _o7q, _oom * _or7, _or7 <= _od);
  return _oa9;
}
const _ok: u32 = 0u;
const _oj: u32 = 1u;
const _ol: u32 = 2u;
struct _o1m {
  _o4z: u32,
  _oad: f32,
  _oic: f32,
};
fn _o3q(_of3: f32) -> _o1m {
  var _oiy: _o1m;
  _oiy._oad = 0.0;
  let _oby = _oo1[0];
  if (_of3 < _o2i) {
    _oiy._o4z = _ok;
    let _o45 = _obd(-0.3 * _of3, _of3, 1.0);
    let _ojh = exp2(_oby * log2(_o45));
    _oiy._oic = _obd(5.0 / 9.0, _ojh, 4.0 / 9.0);
  } else if (_of3 <= _oe) {
    _oiy._o4z = _oj;
    let _or7 = _of3 * _o9;
    _oiy._oad = _o4m(_or7)._orc;
    _oiy._oic = _oiy._oad / _or7;
  } else {
    _oiy._o4z = _ol;
    _oiy._oic = _oe * _oo1[1] / _of3;
  }
  return _oiy;
}
fn _oqy(_of7: f32, g: f32) -> f32 {
  let _oiy = _o3q(_of7 / g);
  return g * g / _oiy._oic;
}
fn _oo7(a: f32, _ogw: f32, w: f32, g: f32, _oln: f32,
                           _of3: f32) -> f32 {
  let _oiy = _o3q(_of3);
  if (_oiy._o4z == _ok) {
    return a * g * g * _ogw / _oiy._oic;
  }
  let _oar = select(_oo1[1], _oiy._oad, _oiy._o4z == _oj);
  return a * g * _oln / (_oe * w * _oar);
}
fn _oo5(_ocl: f32, _o95: f32, _of3: f32) -> f32 {
  let _oby = _oo1[0];
  if (_of3 < _o2i) {
    let _o45 = _obd(-0.3, _ocl / _o95, 1.0);
    let _ojh = exp2(_oby * log2(_o45));
    return _obd(5.0 / 9.0, _ojh, 4.0 / 9.0) * inverseSqrt(_o95);
  }
  let _oiy = _o3q(_of3);
  let _oar = select(_oo1[1], _oiy._oad, _oiy._o4z == _oj);
  return _oe * _oar * inverseSqrt(_ocl);
}
fn _oo4(_ob0: _o1, g: f32, _o7r: vec3f,
                          _opj: vec3f, _oaj: f32, _oap: f32) -> f32 {
  let _osr = !_ob0._oak && !(_ob0._ogh > 0.0);
  let a = _ob0._oqc;
  let w = _ob0._ol4;
  let _ogw = _ob0._oh7;
  var _oqx = 0.0;
  if (!_osr) {
    let _oln = sqrt(_ob0._ogh);
    let _of3 = _oln / (g * _ogw * w);
    _oqx = _oo7(a, _ogw, w, g, _oln, _of3);
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
  let _ob5 = _oo5(_ocm, _o95, _of6);
  return _oqx * _ob5;
}
struct _oy {
  _ohp: bool,
  a: vec4f,
  b: vec4f,
};
fn _o7a(_oik: vec4f, _oiw: vec4f) -> _oy {
  var _olg: _oy;
  _olg._ohp = false;
  let _o8h = _oiw - _oik;
  let _oh9 = _oik.w - _o2e;
  let _o8z = _o8h.w;
  var _op0 = 0.0;
  var _op1 = 1.0;
  if (_o8z == 0.0) {
    if (_oh9 < 0.0) {
      return _olg;
    }
  } else {
    let _oq5 = -_oh9 / _o8z;
    if (_o8z > 0.0) {
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
const _o28: u32 = 1u;
const _o29: u32 = 2u;
const _o2a: u32 = 4u;
struct _o1k {
  _orj: vec2f,
  _ora: vec2f,
  _orf: vec2f,
  _os1: f32,
  _os2: f32,
  _oeo: f32,
  _oeq: f32,
  _og2: f32,
  _obc: u32,
};
fn _oi7(_oic: _o1r) -> _o1k {
  var _ohg: _o1k;
  _ohg._orj = _oic._oi2.xy;
  _ohg._ora = _oic._oi2.zw;
  _ohg._orf = _oic._oi3.xy;
  _ohg._os1 = _oic._oi3.z;
  _ohg._os2 = _oic._oi3.w;
  _ohg._oeo = _oic._oi4.x;
  _ohg._oeq = _oic._oi4.y;
  _ohg._og2 = _oic._oi4.z;
  _ohg._obc = bitcast<u32>(_oic._oi4.w);
  return _ohg;
}
struct _o1s {
  _oid: vec2f,
  _oie: vec2f,
  _oif: vec2f,
  _oig: vec2f,
};
struct _o10 {
  _ogi: _o1s,
  _oab: _o1s,
  _oac: _o1s,
};
fn _o3a(_oic: vec2f, a: vec2f, _oa4: vec2f) -> f32 {
  return _obd(_oic.y - a.y, _oa4.y, (_oic.x - a.x) * _oa4.x);
}
fn _oia(a: vec2f, _oa4: vec2f, _oid: vec2f, _oie: vec2f, _og3: vec2f, _og4: vec2f) -> _o1s {
  let _oot = _o3a(_oid, a, _oa4) > _o3a(_oie, a, _oa4);
  let _oos = _o3a(_og3, a, _oa4) > _o3a(_og4, a, _oa4);
  return _o1s(select(_oid, _oie, _oot), select(_oie, _oid, _oot),
              select(_og4, _og3, _oos), select(_og3, _og4, _oos));
}
fn _ohn(a: vec2f, _olz: f32, _or7: vec2f) -> vec2f {
  return vec2f(_obd(_olz, _or7.x, a.x), _obd(_olz, _or7.y, a.y));
}
fn _oi5(a: vec2f, b: vec2f, _oih: f32, _ohg: _o1k) -> _o10 {
  let _oa4 = b - a;
  let _ofg = _odb(_oa4.x, _oa4.y);
  let _on3 = _ofg < 1e-4;
  let _om8 = select(_oa4, vec2f(1.0, 0.0), _on3);
  let _om9 = select(_ofg, 1.0, _on3);
  let _ogw = vec2f(-_om8.y / _om9, _om8.x / _om9);
  let _oqm = vec2f(_om8.x / _om9, _om8.y / _om9);
  let _o2x = _ohn(a, -_ohg._os1, _ohg._orj);
  let _o2y = _ohn(a, _ohg._os1, _ohg._orj);
  let _o3z = _ohn(b, -_ohg._os2, _ohg._orj);
  let _o40 = _ohn(b, _ohg._os2, _ohg._orj);
  var _o2v: vec2f;
  var _o2u: vec2f;
  var _o3x: vec2f;
  var _o3w: vec2f;
  if ((_ohg._obc & _o29) != 0u) {
    let _o2k = _ohn(a, -_oih, _oqm);
    _o2v = _ohn(_o2k, _ohg._os1, _ogw);
    _o2u = _ohn(_o2k, -_ohg._os1, _ogw);
  } else {
    let _o2k = _ohn(a, -_ohg._oeo, _oa4);
    _o2v = _ohn(_o2k, _ohg._os1, _ohg._ora);
    _o2u = _ohn(_o2k, -_ohg._os1, _ohg._ora);
  }
  if ((_ohg._obc & _o2a) != 0u) {
    let _o3u = _ohn(b, _oih, _oqm);
    _o3x = _ohn(_o3u, _ohg._os2, _ogw);
    _o3w = _ohn(_o3u, -_ohg._os2, _ogw);
  } else {
    let _o3u = _ohn(b, _ohg._oeq, _oa4);
    _o3x = _ohn(_o3u, _ohg._os2, _ohg._orf);
    _o3w = _ohn(_o3u, -_ohg._os2, _ohg._orf);
  }
  return _o10(_o1s(_o2x, _o3z, _o40, _o2y),
                 _oia(a, _oa4, _o2y, _o2v, _o2x, _o2u),
                 _oia(a, _oa4, _o40, _o3x, _o3z, _o3w));
}
fn _o43(_oid: vec2f, _oie: vec2f, _osn: f32, _osm: f32, _okq: vec2f) -> vec2f {
  var _osj = _okq.x;
  var _osh = _okq.y;
  if (_oid.y >= _osn && _oid.y <= _osm) {
    _osj = _obf(_osj, _oid.x);
    _osh = _obe(_osh, _oid.x);
  }
  if (_obe(_oid.y, _oie.y) < _osn || _obf(_oid.y, _oie.y) > _osm) {
    return vec2f(_osj, _osh);
  }
  let _oa2 = _oie.y - _oid.y;
  if (_oa2 != 0.0) {
    let _opd = _obf(_obe((_osn - _oid.y) / _oa2, 0.0), 1.0);
    let _opm = _obf(_obe((_osm - _oid.y) / _oa2, 0.0), 1.0);
    let _osf = _obd(_opd, _oie.x - _oid.x, _oid.x);
    let _osg = _obd(_opm, _oie.x - _oid.x, _oid.x);
    _osj = _obf(_osj, _obf(_osf, _osg));
    _osh = _obe(_osh, _obe(_osf, _osg));
  } else {
    _osj = _obf(_osj, _obf(_oid.x, _oie.x));
    _osh = _obe(_osh, _obe(_oid.x, _oie.x));
  }
  return vec2f(_osj, _osh);
}
fn _o44(_ok1: _o1s, _osn: f32, _osm: f32, _okq: vec2f) -> vec2f {
  var r = _o43(_ok1._oid, _ok1._oie, _osn, _osm, _okq);
  r = _o43(_ok1._oie, _ok1._oif, _osn, _osm, r);
  r = _o43(_ok1._oif, _ok1._oig, _osn, _osm, r);
  return _o43(_ok1._oig, _ok1._oid, _osn, _osm, r);
}
fn _ohk(_oid: vec2f, _oie: vec2f, _osn: f32, _osm: f32, _okq: vec2f) -> vec2f {
  var _osj = _okq.x;
  var _osh = _okq.y;
  if (_oid.y >= _osn && _oid.y <= _osm) {
    _osj = _obf(_osj, _oid.x);
    _osh = _obe(_osh, _oid.x);
  }
  let _oa2 = _oie.y - _oid.y;
  if (_oa2 != 0.0) {
    let _op0 = (_osn - _oid.y) / _oa2;
    if (_op0 > 0.0 && _op0 < 1.0) {
      let x = _obd(_op0, _oie.x - _oid.x, _oid.x);
      _osj = _obf(_osj, x);
      _osh = _obe(_osh, x);
    }
    let _op1 = (_osm - _oid.y) / _oa2;
    if (_op1 > 0.0 && _op1 < 1.0) {
      let x = _obd(_op1, _oie.x - _oid.x, _oid.x);
      _osj = _obf(_osj, x);
      _osh = _obe(_osh, x);
    }
  }
  return vec2f(_osj, _osh);
}
fn _ohj(a: vec2f, b: vec2f, _oij: f32, _oih: f32) -> _o1s {
  let _o9g = b - a;
  let _ofg = _odb(_o9g.x, _o9g.y);
  let _on3 = _ofg < 1e-4;
  let _om8 = select(_o9g, vec2f(1.0, 0.0), _on3);
  let _om9 = select(_ofg, 1.0, _on3);
  let _oqt = vec2f(-_om8.y / _om9, _om8.x / _om9);
  let _oqs = vec2f(_om8.x / _om9, _om8.y / _om9);
  let _oji = _oij + _oi;
  let _oik = _oih + _oi;
  let _o5m = vec2f(_obd(-_oqs.x, _oik, _obd(_oqt.x, _oji, a.x)),
                 _obd(-_oqs.y, _oik, _obd(_oqt.y, _oji, a.y)));
  let _o57 = vec2f(_obd(-_oqs.x, _oik, _obd(-_oqt.x, _oji, a.x)),
                 _obd(-_oqs.y, _oik, _obd(-_oqt.y, _oji, a.y)));
  let _o5l = vec2f(_obd(_oqs.x, _oik, _obd(_oqt.x, _oji, b.x)),
                 _obd(_oqs.y, _oik, _obd(_oqt.y, _oji, b.y)));
  let _o5e = vec2f(_obd(_oqs.x, _oik, _obd(-_oqt.x, _oji, b.x)),
                 _obd(_oqs.y, _oik, _obd(-_oqt.y, _oji, b.y)));
  return _o1s(_o57, _o5e, _o5l, _o5m);
}
fn _onr(_okq: vec2f, _os7: u32, _oqh: i32, _oqi: i32, _og2: f32) -> vec3u {
  let _orw = f32(_os7 - 1u);
  let _osk = _obf(_obe(_okq.x - _og2, 0.0), _orw);
  let _osi = _obf(_obe(_okq.y + _og2, 0.0), _orw);
  let _oov = max(_oqh, i32(floor(_osk * 0.0625)));
  let _oow = min(_oqi, i32(floor(_osi * 0.0625)) + 1);
  let _ohp = _okq.y >= _okq.x && _oow > _oov;
  return select(vec3u(0u), vec3u(u32(_oov), u32(_oow), 1u), _ohp);
}
fn _opz(_olu: _o1s, _ohg: _o1k, _o56: _o10, _oqj: u32, _os7: u32,
                         _oqh: u32, _oqi: u32) -> vec3u {
  let _osn = f32(_oqj * _oh);
  let _osm = f32(_oqj * _oh + (_oh - 1u));
  var r = _ohk(_olu._oid, _olu._oie, _osn, _osm, vec2f(3.4e38, -3.4e38));
  r = _ohk(_olu._oie, _olu._oif, _osn, _osm, r);
  r = _ohk(_olu._oif, _olu._oig, _osn, _osm, r);
  r = _ohk(_olu._oig, _olu._oid, _osn, _osm, r);
  let _olb = _onr(r, _os7, i32(_oqh), i32(_oqi), 0.0);
  let _ohq = _osn - _ohg._og2;
  let _oho = _osm + _ohg._og2;
  var _ok1 = _o44(_o56._ogi, _ohq, _oho, vec2f(3.4e38, -3.4e38));
  _ok1 = _o44(_o56._oab, _ohq, _oho, _ok1);
  _ok1 = _o44(_o56._oac, _ohq, _oho, _ok1);
  let _oi9 = _onr(_ok1, _os7, i32(_olb.x), i32(_olb.y), _ohg._og2);
  let _or5 = _olb.z == 0u || (_ohg._obc & _o28) != 0u;
  return select(_oi9, _olb, _or5);
}
fn _ojs(a: f32, b: f32, _o56: f32, _o8h: f32) -> f32 {
  let _oic = _oqf(a, b);
  let _ok1 = _oqf(_o56, _o8h);
  let _olz = _oqg(_oic.x, -_ok1.x);
  let _ofy = (_oic.y - _ok1.y) + _olz.y;
  return _olz.x + _ofy;
}
fn _oi8(_oic: vec2f, a: vec2f, _oa4: vec2f, _oa7: f32) -> f32 {
  let _oa1 = _oic.x - a.x;
  let _oa2 = _oic.y - a.y;
  let _ooz = _obf(_obe((_oa1 * _oa4.x + _oa2 * _oa4.y) / _oa7, 0.0), 1.0);
  return _odb(_oa1 - _ooz * _oa4.x, _oa2 - _ooz * _oa4.y);
}
fn _ob7(_or7: vec2f) -> bool {
  return _oe5(_or7.x) && _oe5(_or7.y);
}
struct _o1l {
  w: f32,
  _or7: vec2f,
  _oep: f32,
};
fn _oi6(g: f32, _om4: f32, _o5q: vec2f, _ogw: vec2f, _o96: f32, _oq9: f32, _o4k: f32,
               _oei: f32, _of2: f32) -> _o1l {
  let gg = g * g;
  let _om6 = gg * _om4 + _o4k;
  let _o99 = gg * gg * _o96 + gg * _o4k * _oq9 + _o4k * _o4k;
  var _oa9: _o1l;
  _oa9.w = _oei * sqrt(_om6);
  _oa9._or7 = vec2f((gg * _o5q.x + _o4k * _ogw.x) / _om6, (gg * _o5q.y + _o4k * _ogw.y) / _om6);
  _oa9._oep = _oei * sqrt(_o99 / _om6) / _of2;
  return _oa9;
}
fn _ooi(g: f32, _oah: f32, _oaf: f32, _o96: f32, _oq9: f32, _o4k: f32,
                       _o8b: f32) -> bool {
  let gg = g * g;
  let _ocl = _obd(gg, _oah, _o4k * _oaf);
  let _o95 = _obd(gg, _obd(gg, _o96, _o4k * _oq9), _o4k * _o4k);
  let _o8c = _o8b * _ocl;
  let _ojr = _o8c * _o95;
  return !_oe5(_ojr) || _ojr > 1e37;
}
fn _o7t(_oic: vec2f, a: vec2f, _oa4: vec2f, _oa7: f32, _ol7: vec2f) -> vec2f {
  let _ob6 = _ol7.y != 0.0 && _ob7(_oic);
  return vec2f(_obe(_ol7.x, _oi8(_oic, a, _oa4, _oa7)), select(0.0, 1.0, _ob6));
}
fn _okb(_ok1: _o1s, a: vec2f, _oa4: vec2f, _oa7: f32, _ol7: vec2f) -> vec2f {
  var r = _o7t(_ok1._oid, a, _oa4, _oa7, _ol7);
  r = _o7t(_ok1._oie, a, _oa4, _oa7, r);
  r = _o7t(_ok1._oif, a, _oa4, _oa7, r);
  return _o7t(_ok1._oig, a, _oa4, _oa7, r);
}
fn _o51(_o5m: vec3f, _o5r: vec3f, _oky: f32, _okz: f32, _ojc: bool,
                      _o8b: f32, a: vec2f, b: vec2f, _ogw: vec2f, _oih: f32,
                      _o4k: f32, _os7: u32, _ocy: u32) -> _o1k {
  var _ohg: _o1k;
  _ohg._orj = vec2f(0.0);
  _ohg._ora = vec2f(0.0);
  _ohg._orf = vec2f(0.0);
  _ohg._os1 = 0.0;
  _ohg._os2 = 0.0;
  _ohg._oeo = 0.0;
  _ohg._oeq = 0.0;
  _ohg._og2 = 0.0;
  _ohg._obc = _o28;
  if (_ojc) {
    return _ohg;
  }
  let _oa4 = b - a;
  let _oa7 = _oa4.x * _oa4.x + _oa4.y * _oa4.y;
  let _of2 = sqrt(_oa7);
  let _oei = sqrt(_o8b);
  let _o96 = _obe(_ojs(_o5m.x, _o5m.z, _o5m.y, _o5m.y), 0.0);
  let _oq9 = _o5m.x + _o5m.z;
  let _o6a = vec2f(_o5r.x * _ogw.x + _o5r.y * _ogw.y, _o5r.y * _ogw.x + _o5r.z * _ogw.y);
  let _om5 = _ogw.x * _o6a.x + _ogw.y * _o6a.y;
  _ohg._orj = vec2f(_o6a.x / _om5, _o6a.y / _om5);
  let _o5q = vec2f(_o5m.x * _ogw.x + _o5m.y * _ogw.y, _o5m.y * _ogw.x + _o5m.z * _ogw.y);
  let _om4 = _ogw.x * _o5q.x + _ogw.y * _o5q.y;
  let _oab = _oi6(_oky, _om4, _o5q, _ogw, _o96, _oq9, _o4k, _oei, _of2);
  let _oac = _oi6(_okz, _om4, _o5q, _ogw, _o96, _oq9, _o4k, _oei, _of2);
  _ohg._os1 = _oab.w;
  _ohg._os2 = _oac.w;
  _ohg._ora = _oab._or7;
  _ohg._orf = _oac._or7;
  _ohg._oeo = _oab._oep;
  _ohg._oeq = _oac._oep;
  let _obx = _obe(_oky, _okz);
  let _oc3 = _obx * _obx;
  let _oqa = _oc3 * _oq9 + 2.0 * _o4k;
  let _o98 = _oc3 * _oc3 * _o96 + _oc3 * _o4k * _oq9 + _o4k * _o4k;
  let _oqm = 5.9604644775390625e-8;
  let r = 16.0 * _oqm * _oqa * _oqa / _o98;
  let _o8v = _obe(_obe(abs(a.x), abs(a.y)), _obe(abs(b.x), abs(b.y)))
         + f32(_os7) + f32(_ocy);
  let _o8x = !(_o98 > 0.0) || !_oe5(_o98) || (_o4k == 0.0 && _o96 == 0.0);
  let _o2p = _o5m.z * _oa4.x - _o5m.y * _oa4.y;
  let _o2q = _o5m.x * _oa4.y - _o5m.y * _oa4.x;
  let _oah = _obe(_oa4.x * _o2p + _oa4.y * _o2q, 0.0);
  let _oaf = _oa4.x * _oa4.x + _oa4.y * _oa4.y;
  let _ol8 = _obe(_o5m.x * _o5m.z - _o5m.y * _o5m.y, 0.0);
  let _ol9 = _o5m.x + _o5m.z;
  var _obc = 0u;
  if (_ooi(_oky, _oah, _oaf, _ol8, _ol9, _o4k, _o8b)) {
    _obc = _obc | _o29;
  }
  if (_ooi(_oky + (_okz - _oky), _oah, _oaf, _ol8, _ol9, _o4k, _o8b)) {
    _obc = _obc | _o2a;
  }
  _ohg._obc = _obc;
  let _o56 = _oi5(a, b, _oih, _ohg);
  var _ol7 = _okb(_o56._ogi, a, _oa4, _oa7, vec2f(0.0, 1.0));
  _ol7 = _okb(_o56._oab, a, _oa4, _oa7, _ol7);
  _ol7 = _okb(_o56._oac, a, _oa4, _oa7, _ol7);
  var _ob6 = _ol7.y != 0.0;
  let _o4q = _ol7.x;
  _ohg._og2 = r * _o4q + 0.02 + 4.0 * _oqm * _o8v;
  let _oog = (_obc & _o29) != 0u;
  let _ooh = (_obc & _o2a) != 0u;
  _ob6 = _ob6 && _ob7(_ohg._orj) && _oe5(_ohg._os1) && _oe5(_ohg._os2)
      && (_oog || (_ob7(_ohg._ora) && _oe5(_ohg._oeo)))
      && (_ooh || (_ob7(_ohg._orf) && _oe5(_ohg._oeq)))
      && _oe5(_o4q) && _oe5(r) && _oe5(_ohg._og2);
  if (_o8x || !_ob6) {
    _ohg._obc = _o28;
  }
  return _ohg;
}
@compute @workgroup_size(256)
fn preprocess_beta(@builtin(local_invocation_index) _ofl: u32,
                   @builtin(workgroup_id) _os6: vec3u,
                   @builtin(num_workgroups) _ohc: vec3u) {
  let _odf = _ofq(_os6, _ohc) * _o2j + _ofl;
  if (_odf >= _o83[_o1w]) {
    return;
  }
  let _onn = _oev[_odf];
  _oq0[_odf] = 0u;
  _ojo[_odf]._oc2 = vec4f(0.0, 0.0, 0.0, 0.0);
  let _o3l = _ojn[_odf];
  let _o3c = bitcast<f32>(_o3l.x);
  let _on1 = bitcast<f32>(_o3l.y);
  let _ohg = 6u * _onn;
  let _oil = vec3f(_oae[_ohg], _oae[_ohg + 1u], _oae[_ohg + 2u]);
  let _oix = vec3f(_oae[_ohg + 3u], _oae[_ohg + 4u], _oae[_ohg + 5u]);
  let _ofp = vec3f((_oil.x + _oix.x) * 0.5, (_oil.y + _oix.y) * 0.5, (_oil.z + _oix.z) * 0.5);
  let _o91 = _orl(_ofp);
  if (_o91 < _oc) {
    return;
  }
  let _o78 = _o7a(_ojw(_oil), _ojw(_oix));
  if (!_o78._ohp) {
    return;
  }
  let _os7 = _o5v._os7;
  let _ocy = _o5v._ocy;
  let _o2w = vec2f(_oh1(_o78.a.x / _o78.a.w, _os7), _oh1(_o78.a.y / _o78.a.w, _ocy));
  let _o3y = vec2f(_oh1(_o78.b.x / _o78.b.w, _os7), _oh1(_o78.b.y / _o78.b.w, _ocy));
  let _ob4 = _o5v._o4k;
  let _o63 = _ojw(_ofp);
  var _oms = _o63.w > _o2e && _oe5(_o63.w);
  let _oma = select(1.0, _o63.w, _oms);
  let _odw = 1.0 / (_oma * _oma);
  let _ofo = _oa * _oma;
  let _o6f = _obf(_obe(_o63.x, -_ofo), _ofo);
  let _o6g = _obf(_obe(_o63.y, -_ofo), _ofo);
  let _oeb = _o6f != _o63.x || _o6g != _o63.y;
  let _ocv = 0.5 * f32(_os7);
  let _ocs = 0.5 * f32(_ocy);
  let _oed = vec3f(_ocv * (_oma * _oj9(0u) - _o6f * _oj9(3u)) * _odw,
                 _ocv * (_oma * _oj9(4u) - _o6f * _oj9(7u)) * _odw,
                 _ocv * (_oma * _oj9(8u) - _o6f * _oj9(11u)) * _odw);
  let _oeg = vec3f(_ocs * (_oma * _oj9(1u) - _o6g * _oj9(3u)) * _odw,
                 _ocs * (_oma * _oj9(5u) - _o6g * _oj9(7u)) * _odw,
                 _ocs * (_oma * _oj9(9u) - _o6g * _oj9(11u)) * _odw);
  let _ogn = vec2f(_oh1(_o63.x / _oma, _os7),
                           _oh1(_o63.y / _oma, _ocy));
  let _obl = _oew(_onn, _oed, _oeg);
  let _oc0 = 4.0 * exp2(_on1 * _ob);
  let _obz = !(_oc0 >= _o7 && _oc0 <= _o6);
  let _oby = _obf(_obe(_oc0, _o7), _o6);
  let _oee = _obl._ob4 * _o9r(_oed, _oed);
  let _oef = _obl._ob4 * _o9r(_oed, _oeg);
  let _oeh = _obl._ob4 * _o9r(_oeg, _oeg);
  let _o5n = _obl._o5s + _oee;
  let _o5o = _obl._o5t + _oef;
  let _o5p = _obl._o5u + _oeh;
  let _oj1 = _ob4;
  let _o58 = _o5n + _oj1;
  let _o5b = _o5o;
  let _o5i = _o5p + _oj1;
  _oo0(_oby);
  _ob3(_oby);
  let _ola = vec4f(select(_oby, -_oby, _obz), _oby, _oj1, 0.0);
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
  var _ol1 = _ol0 * _oe1;
  if (_oeb) {
    let _oh8 = vec3f(_oed.y * _oeg.z - _oed.z * _oeg.y,
                    _oed.z * _oeg.x - _oed.x * _oeg.z,
                    _oed.x * _oeg.y - _oed.y * _oeg.x);
    let _oe0 = inverseSqrt(_o9r(_oh8, _oh8));
    _ol1 = _oh8 * _oe0;
  }
  let _ob0 = _o3e(_obl, _oed, _oeg, _ol1, _o6d.x, _o6d.y);
  let _o7r = vec3f(_o58, _o5b, _o5i);
  let _opj = vec3f(_o5n, _o5o, _o5p);
  let _olh = _obe(_o3c, 0.0);
  let _ok2 = _olh * _ob0._oqc * _ob0._oh7;
  let _of7 = sqrt(_ob0._ogh) / (_ob0._oh7 * _ob0._ol4);
  _oms = _oms && (_ob0._oak || _ob0._ogh > 0.0);
  let _oel = _oo4(_ob0, _oky, _o7r, _opj, _o6d.x, _o6d.y);
  let _oen = _oo4(_ob0, 1.0, _o7r, _opj, _o6d.x, _o6d.y);
  let _oem = _oo4(_ob0, _okz, _o7r, _opj, _o6d.x, _o6d.y);
  let _oiy = _olh * _obe(_oel, _obe(_oen, _oem));
  let _oqp = _ok2 * _oqy(_of7, _oky);
  let _oqr = _ok2 * _oqy(_of7, 1.0);
  let _oqq = _ok2 * _oqy(_of7, _okz);
  _oms = _oms && _ob0._ojg && _oe5(_of7)
      && _oe5(_oqp) && _oe5(_oqr) && _oe5(_oqq);
  if (!_oms) {
    return;
  }
  let _o64 = _ogn;
  let _okx = _o18 / _obe(_oiy, _o18);
  let _o8d = _obe(0.5 * (1.0 - exp2(log2(_okx) / _oby)), 1e-6);
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
  let _o5z = _o9b + _odb(_o64.x - 0.5 * f32(_os7 - 1u), _o64.y - 0.5 * f32(_ocy - 1u));
  _oij = _obf(_oij, _o5z);
  _oih = _obf(_oih, _o5z);
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
  if (_ogb + _oi < 0.0 || _ogq - _oi > _os5
      || _ogd + _oi < 0.0 || _ogs - _oi > _od0) {
    return;
  }
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
  let _oi1 = _o51(_opj, _o7r, _oky, _okz, _ojc, _o8d,
                                   _o2w, _o3y, _oqt, _oih, _ola.z, _os7, _ocy);
  var _ojm: _o1r;
  _ojm._o3f = vec4f(_o5n, _o5o, _o5p, select(_oky, -abs(_oky), _ojc));
  _ojm._o4r = vec4f(_ok2, _of7, _o8d, _okz);
  _ojm.ab = vec4f(_o2w, _o3y);
  _ojm._oc2 = vec4f(_oij, _oih, _o91, f32(_og6));
  _ojm._olb = vec4u(u32(_oqh), u32(_oqk), u32(_oqi), u32(_oql));
  _ojm._ola = _ola;
  _ojm._oi2 = vec4f(_oi1._orj, _oi1._ora);
  _ojm._oi3 = vec4f(_oi1._orf, _oi1._os1, _oi1._os2);
  _ojm._oi4 = vec4f(_oi1._oeo, _oi1._oeq, _oi1._og2, bitcast<f32>(_oi1._obc));
  _ojo[_odf] = _ojm;
  let _o7u = _oi5(_o2w, _o3y, _oih, _oi1);
  let _olc = _ohj(_o2w, _o3y, _oij, _oih);
  var _ogz = 0u;
  for (var _oqj = u32(_oqk); _oqj < u32(_oql); _oqj = _oqj + 1u) {
    let _onq = _opz(_olc, _oi1, _o7u, _oqj, _os7,
                                     u32(_oqh), u32(_oqi));
    if (_onq.z != 0u) {
      _ogz = _ogz + (_onq.y - _onq.x);
    }
  }
  _oq0[_odf] = _ogz;
}
@compute @workgroup_size(256)
fn duplicate_keys_beta(@builtin(local_invocation_index) _ofl: u32,
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
  let _oi1 = _oi7(_ojm);
  let _o7u = _oi5(_o2w, _o3y, _ojm._oc2.y, _oi1);
  let _olc = _ohj(_o2w, _o3y, _ojm._oc2.x, _ojm._oc2.y);
  let _o92 = bitcast<u32>(_ojm._oc2.z);
  let _o60 = _o9x._o60;
  for (var y = _ojm._olb.y; y < _ojm._olb.w; y = y + 1u) {
    let _onq = _opz(_olc, _oi1, _o7u, y,
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
