struct _o1v {
  _o3i: vec4f,
  _o4u: vec4f,
  ab: vec4f,
  _obz: vec4f,
  _ol9: vec4u,
  _ol7: vec4f,
  _oht: vec4f,
  _ohu: vec4f,
  _ohv: vec4f,
};
@group(0) @binding(0) var<storage, read> _oeo: array<u32>;
@group(0) @binding(1) var<storage, read> _oa9: array<f32>;
@group(0) @binding(2) var<storage, read> _oqt: array<f32>;
@group(0) @binding(3) var<storage, read> _ojl: array<vec4u>;
@group(0) @binding(4) var<storage, read> _o7r: array<u32>;
@group(0) @binding(5) var<storage, read_write> _ojm: array<_o1v>;
@group(0) @binding(6) var<storage, read_write> _opv: array<u32>;
@group(0) @binding(7) var<uniform> _o5x: _oo;
@group(0) @binding(0) var<storage, read> _o9v: array<_o1v>;
@group(0) @binding(1) var<storage, read> _o9u: array<u32>;
@group(0) @binding(2) var<storage, read> _o9t: array<u32>;
@group(0) @binding(3) var<storage, read_write> _oes: array<u32>;
@group(0) @binding(4) var<storage, read_write> _oet: array<u32>;
@group(0) @binding(5) var<storage, read_write> _oim: array<u32>;
@group(0) @binding(6) var<uniform> _o9s: _oo;
const _oh: u32 = 16u;
const _oi: u32 = 16u;
const _o2j: f32 = 1e-3;
const _o14: f32 = 3.929278140e-03;
const _o2n: f32 = 0.1;
const _oj: f32 = 0.02;
const _oe: f32 = 0.1;
const _o5: f32 = 1.17549435e-38;
const _of: f32 = 1.41421356;
const _oa: f32 = 0.707106781;
const _o8: f32 = 0.2;
const _o7: f32 = 12.5;
const _od: f32 = 0.01;
const _ob: f32 = 1.3;
const _o4: f32 = -3.1215594;
const _o3: f32 = 1.8495809;
const _oc: f32 = 1.44269504;
const _o2i = array<f32, 63>(
  -1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
  0.86907756, -0.08104082, 0.012049758, -0.00021792683, 2.1956479e-05, -1.45608055e-05, -2.4834957e-05,
  -0.70016533, 0.17784852, -0.029768402, 0.0013841696, -0.0002165212, 0.00020030937, 0.000181285,
  0.538863, -0.25318372, 0.051725097, -0.0043851244, 0.00028628978, -0.0007355512, -0.0004591238,
  -0.39315897, 0.28637674, -0.07442167, 0.010118952, -3.2378295e-05, 0.0011633757, 0.000537747,
  0.25465247, -0.25353765, 0.08320036, -0.016473958, 0.00047484812, -0.00091163174, -0.00032065576,
  -0.12885943, 0.15803069, -0.06287364, 0.016344883, -0.0015109606, 0.00043000313, 0.00010007449,
  0.04232212, -0.059212293, 0.027284678, -0.008595316, 0.0013526595, -0.00018219583, -1.2701726e-05,
  -0.006454065, 0.00980119, -0.005036595, 0.0018203161, -0.0003864131, 5.108729e-05, -1.2723773e-06);
const _o2h = array<f32, 7>(
  0.9317711, -0.04327248, 0.0059742252, 8.372514e-06, -1.3490912e-05, 1.0639736e-06, 1.9153707e-07);
const _o2g = array<f32, 7>(
  1.0743952, 0.049604684, -0.0057441797, -0.0003010808, 2.6747155e-05, 7.308961e-07, -3.6029135e-07);
var<private> _ony: array<f32, 11>;
var<private> _omw: array<f32, 5>;
fn _orm(_oed: u32) -> f32 {
  return _o5x._orh[_oed >> 2u][_oed & 3u];
}
fn _oj2(_oed: u32) -> f32 {
  return _o5x._ojs[_oed >> 2u][_oed & 3u];
}
fn _o9n(x: vec3f, y: vec3f) -> f32 {
  return x.x * y.x + x.y * y.y + x.z * y.z;
}
fn _oju(_oi3: vec3f) -> vec4f {
  var _ohn: vec4f;
  for (var r = 0u; r < 4u; r = r + 1u) {
    _ohn[r] = _obc(_oi3.z, _oj2(8u + r), _obc(_oi3.x, _oj2(r), _oi3.y * _oj2(4u + r))) + _oj2(12u + r);
  }
  return _ohn;
}
fn _ori(_oi3: vec3f) -> f32 {
  return _obc(_oi3.z, _orm(10u), _obc(_oi3.x, _orm(2u), _oi3.y * _orm(6u))) + _orm(14u);
}
fn _ogu(_or2: f32, size: u32) -> f32 {
  let _olx = f32(size);
  return _obc(_or2, _olx, _olx - 1.0) * 0.5;
}
fn _od6(x: f32, y: f32) -> f32 {
  let _o3r = abs(x);
  let _o3x = abs(y);
  let _o4r = max(_o3r, _o3x);
  let _one = min(_o3r, _o3x);
  if (_one == 0.0) {
    return _o4r;
  }
  return sqrt(_obc(_o4r, _o4r, _one * _one));
}
struct _o1i {
  r: mat3x3f,
  _olx: vec3f,
  _ob2: f32,
  _ofz: vec3f,
  _og0: vec3f,
  _o5u: f32,
  _o5v: f32,
  _o5w: f32,
};
fn _oep(_olo: u32, _oe8: vec3f, _oeb: vec3f) -> _o1i {
  var _obj: _o1i;
  let _oqg = 8u * _olo;
  let w = _oqt[_oqg];
  let x = _oqt[_oqg + 1u];
  let y = _oqt[_oqg + 2u];
  let z = _oqt[_oqg + 3u];
  _obj.r = mat3x3f(
      vec3f(1.0 - 2.0 * (y * y + z * z), 2.0 * (x * y + w * z), 2.0 * (x * z - w * y)),
      vec3f(2.0 * (x * y - w * z), 1.0 - 2.0 * (x * x + z * z), 2.0 * (y * z + w * x)),
      vec3f(2.0 * (x * z + w * y), 2.0 * (y * z - w * x), 1.0 - 2.0 * (x * x + y * y)));
  _obj._olx = vec3f(_oqt[_oqg + 4u], _oqt[_oqg + 5u], _oqt[_oqg + 6u]);
  _obj._ob2 = _oqt[_oqg + 7u];
  _obj._o5u = 0.0;
  _obj._o5v = 0.0;
  _obj._o5w = 0.0;
  for (var _oe3 = 0u; _oe3 < 3u; _oe3 = _oe3 + 1u) {
    let _o70 = _obj.r[_oe3];
    let _oi4 = _oe8.x * _o70.x + _oe8.y * _o70.y + _oe8.z * _o70.z;
    let _oi5 = _oeb.x * _o70.x + _oeb.y * _o70.y + _oeb.z * _o70.z;
    _obj._ofz[_oe3] = _oi4 * _obj._olx[_oe3];
    _obj._og0[_oe3] = _oi5 * _obj._olx[_oe3];
    _obj._o5u = _obj._o5u + _obj._ofz[_oe3] * _obj._ofz[_oe3];
    _obj._o5v = _obj._o5v + _obj._ofz[_oe3] * _obj._og0[_oe3];
    _obj._o5w = _obj._o5w + _obj._og0[_oe3] * _obj._og0[_oe3];
  }
  return _obj;
}
struct _o2 {
  _oq7: f32,
  _okz: f32,
  _ogz: f32,
  _ojd: bool,
  _ogc: f32,
  _oah: bool,
};
fn _o3h(_obj: _o1i, _oe8: vec3f, _oeb: vec3f, _okw: vec3f,
                     _oag: f32, _oam: f32) -> _o2 {
  var _oaw: _o2;
  let _oly = _obj._olx.x;
  let _olz = _obj._olx.y;
  let _om0 = _obj._olx.z;
  _oaw._oq7 = 0.5 * _oly * (_olz + _om0);
  let _ohm = vec3f(_olz * _om0, _oly * _om0, _oly * _olz);
  var _opi: vec3f;
  var _of6 = 0.0;
  for (var _oe3 = 0u; _oe3 < 3u; _oe3 = _oe3 + 1u) {
    let _o70 = _obj.r[_oe3];
    let _okx = _okw.x * _o70.x + _okw.y * _o70.y + _okw.z * _o70.z;
    _opi[_oe3] = _okx * _ohm[_oe3];
    _of6 = _obd(_of6, abs(_opi[_oe3]));
  }
  let _odu = select(0.0, 1.0 / _of6, _of6 > 0.0);
  var _ooh = 0.0;
  for (var _oe3 = 0u; _oe3 < 3u; _oe3 = _oe3 + 1u) {
    let _ome = _opi[_oe3] * _odu;
    _ooh = _ooh + _ome * _ome;
  }
  let _olj = sqrt(_ooh);
  _oaw._okz = _of6 * _olj;
  let _ogy = vec3f(_oe8.y * _oeb.z - _oe8.z * _oeb.y,
                     _oe8.z * _oeb.x - _oe8.x * _oeb.z,
                     _oe8.x * _oeb.y - _oe8.y * _oeb.x);
  _oaw._ogz = sqrt(_ogy.x * _ogy.x + _ogy.y * _ogy.y + _ogy.z * _ogy.z);
  _oaw._ojd = _oly > 0.0 && _olz > 0.0 && _om0 > 0.0;
  _oaw._ogc = 0.0;
  for (var _oe3 = 0u; _oe3 < 3u; _oe3 = _oe3 + 1u) {
    let _oa4 = -_oam * _obj._ofz[_oe3] + _oag * _obj._og0[_oe3];
    _oaw._ogc = _oaw._ogc + _oa4 * _oa4;
  }
  _oaw._oah = _oag == 0.0 && _oam == 0.0;
  return _oaw;
}
fn _ob1(_obv: f32) {
  let _okd = _obc(_obv, -0.3, 0.3);
  let _oke = _obc(_obv, -5.0 / 21.0, 10.0 / 21.0);
  let _okf = _obc(_obv, -7.0 / 36.0, 21.0 / 36.0);
  _omw[0] = 1.0;
  _omw[1] = _obv * (-1.0 / 3.0);
  _omw[2] = _omw[1] * _okd;
  _omw[3] = _omw[2] * _oke;
  _omw[4] = _omw[3] * _okf;
}
struct _oq {
  _oow: f32, _oox: f32, _ooy: f32, _ooz: f32, _op0: f32, _op1: f32,
};
fn _o6h(_o2p: f32, _o2q: f32, _o2r: f32, _o2s: f32, _o2w: f32, _o2x: f32, _o2y: f32, _oou: _oq) -> f32 {
  var _o36 = _o2p;
  _o36 = _obc(_o2q, _oou._oow, _o36);
  _o36 = _obc(_o2r, _oou._oox, _o36);
  _o36 = _obc(_o2s, _oou._ooy, _o36);
  _o36 = _obc(_o2w, _oou._ooz, _o36);
  _o36 = _obc(_o2x, _oou._op0, _o36);
  _o36 = _obc(_o2y, _oou._op1, _o36);
  return _o36;
}
fn _onx(_obv: f32) {
  _ony[0] = _obv;
  let _oc3 = _obv + 1.0;
  let r = inverseSqrt(_oc3);
  let z = _obc(r, _o4, _o3);
  let _osq = z + z;
  var _oou: _oq;
  _oou._oow = z;
  _oou._oox = _obc(_osq, _oou._oow, -1.0);
  _oou._ooy = _obc(_osq, _oou._oox, -_oou._oow);
  _oou._ooz = _obc(_osq, _oou._ooy, -_oou._oox);
  _oou._op0 = _obc(_osq, _oou._ooz, -_oou._ooy);
  _oou._op1 = _obc(_osq, _oou._op0, -_oou._ooz);
  let _o8a = _o6h(_o2i[0], _o2i[1], _o2i[2], _o2i[3], _o2i[4], _o2i[5], _o2i[6], _oou);
  let _o8b = _o6h(_o2i[7], _o2i[8], _o2i[9], _o2i[10], _o2i[11], _o2i[12], _o2i[13], _oou);
  let _o8c = _o6h(_o2i[14], _o2i[15], _o2i[16], _o2i[17], _o2i[18], _o2i[19], _o2i[20], _oou);
  let _o8d = _o6h(_o2i[21], _o2i[22], _o2i[23], _o2i[24], _o2i[25], _o2i[26], _o2i[27], _oou);
  let _o8e = _o6h(_o2i[28], _o2i[29], _o2i[30], _o2i[31], _o2i[32], _o2i[33], _o2i[34], _oou);
  let _o8f = _o6h(_o2i[35], _o2i[36], _o2i[37], _o2i[38], _o2i[39], _o2i[40], _o2i[41], _oou);
  let _o8g = _o6h(_o2i[42], _o2i[43], _o2i[44], _o2i[45], _o2i[46], _o2i[47], _o2i[48], _oou);
  let _o8h = _o6h(_o2i[49], _o2i[50], _o2i[51], _o2i[52], _o2i[53], _o2i[54], _o2i[55], _oou);
  let _o8i = _o6h(_o2i[56], _o2i[57], _o2i[58], _o2i[59], _o2i[60], _o2i[61], _o2i[62], _oou);
  let g = _o6h(_o2h[0], _o2h[1], _o2h[2], _o2h[3], _o2h[4],
                _o2h[5], _o2h[6], _oou);
  let _obt = _o6h(_o2g[0], _o2g[1], _o2g[2],
                        _o2g[3], _o2g[4], _o2g[5],
                        _o2g[6], _oou);
  let _oap = r * g;
  let _odt = (_oc3 * r) * _obt;
  _ony[1] = _oap;
  _ony[2] = _o8a;
  var _oje = _odt;
  _ony[3] = _o8b * _oje;
  _oje = _oje * _odt;
  _ony[4] = _o8c * _oje;
  _oje = _oje * _odt;
  _ony[5] = _o8d * _oje;
  _oje = _oje * _odt;
  _ony[6] = _o8e * _oje;
  _oje = _oje * _odt;
  _ony[7] = _o8f * _oje;
  _oje = _oje * _odt;
  _ony[8] = _o8g * _oje;
  _oje = _oje * _odt;
  _ony[9] = _o8h * _oje;
  _oje = _oje * _odt;
  _ony[10] = _o8i * _oje;
  _oje = _oje * _odt;
}
struct _o15 {
  _or7: f32,
};
fn _o4p(_or2: f32) -> _o15 {
  let _obv = _ony[0];
  let _ohj = _obd(_obc(-_or2, _or2, 1.0), _o5);
  let _ofx = log2(_ohj);
  let _ojv = exp2((_obv + 1.0) * _ofx);
  var _o36 = _ony[10];
  _o36 = _obc(_o36, _or2, _ony[9]);
  _o36 = _obc(_o36, _or2, _ony[8]);
  _o36 = _obc(_o36, _or2, _ony[7]);
  _o36 = _obc(_o36, _or2, _ony[6]);
  _o36 = _obc(_o36, _or2, _ony[5]);
  _o36 = _obc(_o36, _or2, _ony[4]);
  _o36 = _obc(_o36, _or2, _ony[3]);
  _o36 = _obc(_o36, _or2, _ony[2]);
  _o36 = _obc(_o36, _or2, _ony[1]);
  let _o79 = _ojv * _o36;
  let _oqg = _or2 * _or2;
  var _ooh = _omw[4];
  _ooh = _obc(_ooh, _oqg, _omw[3]);
  _ooh = _obc(_ooh, _oqg, _omw[2]);
  _ooh = _obc(_ooh, _oqg, _omw[1]);
  _ooh = _obc(_ooh, _oqg, _omw[0]);
  var _oa5: _o15;
  _oa5._or7 = select(_ony[1] - _o79, _ooh * _or2, _or2 <= _oe);
  return _oa5;
}
const _ol: u32 = 0u;
const _ok: u32 = 1u;
const _om: u32 = 2u;
struct _o1p {
  _o52: u32,
  _oa8: f32,
  _oi3: f32,
};
fn _o3v(_oex: f32) -> _o1p {
  var _oiq: _o1p;
  _oiq._oa8 = 0.0;
  let _obv = _ony[0];
  if (_oex < _o2n) {
    _oiq._o52 = _ol;
    let _o49 = _obc(-0.3 * _oex, _oex, 1.0);
    let _oje = exp2(_obv * log2(_o49));
    _oiq._oi3 = _obc(5.0 / 9.0, _oje, 4.0 / 9.0);
  } else if (_oex <= _of) {
    _oiq._o52 = _ok;
    let _or2 = _oex * _oa;
    _oiq._oa8 = _o4p(_or2)._or7;
    _oiq._oi3 = _oiq._oa8 / _or2;
  } else {
    _oiq._o52 = _om;
    _oiq._oi3 = _of * _ony[1] / _oex;
  }
  return _oiq;
}
fn _oqs(_of1: f32, g: f32) -> f32 {
  let _oiq = _o3v(_of1 / g);
  return g * g / _oiq._oi3;
}
fn _oo4(a: f32, _ogq: f32, w: f32, g: f32, _olk: f32,
                           _oex: f32) -> f32 {
  let _oiq = _o3v(_oex);
  if (_oiq._o52 == _ol) {
    return a * g * g * _ogq / _oiq._oi3;
  }
  let _oao = select(_ony[1], _oiq._oa8, _oiq._o52 == _ok);
  return a * g * _olk / (_of * w * _oao);
}
fn _oo2(_oci: f32, _o8y: f32, _oex: f32) -> f32 {
  let _obv = _ony[0];
  if (_oex < _o2n) {
    let _o49 = _obc(-0.3, _oci / _o8y, 1.0);
    let _oje = exp2(_obv * log2(_o49));
    return _obc(5.0 / 9.0, _oje, 4.0 / 9.0) * inverseSqrt(_o8y);
  }
  let _oiq = _o3v(_oex);
  let _oao = select(_ony[1], _oiq._oa8, _oiq._o52 == _ok);
  return _of * _oao * inverseSqrt(_oci);
}
fn _oo1(_oaw: _o2, g: f32, _o7a: vec3f,
                          _ope: vec3f, _oag: f32, _oam: f32) -> f32 {
  let _oss = !_oaw._oah && !(_oaw._ogc > 0.0);
  let a = _oaw._oq7;
  let w = _oaw._okz;
  let _ogq = _oaw._ogz;
  var _oqr = 0.0;
  if (!_oss) {
    let _olk = sqrt(_oaw._ogc);
    let _oex = _olk / (g * _ogq * w);
    _oqr = _oo4(a, _ogq, w, g, _olk, _oex);
  }
  let _oo9 = g * g - 1.0;
  let _o5a = _o7a.x + _oo9 * _ope.x;
  let _o5d = _o7a.y + _oo9 * _ope.y;
  let _o5k = _o7a.z + _oo9 * _ope.z;
  let _o8y = _o5a * _o5k - _o5d * _o5d;
  let _o38 = _o5k * _oag - _o5d * _oam;
  let _o39 = _o5a * _oam - _o5d * _oag;
  let _ock = _oag * _o38 + _oam * _o39;
  let _ocj = select(0.0, _ock, _ock > 0.0);
  let _of0 = sqrt(_ocj / _o8y);
  let _ob3 = _oo2(_ocj, _o8y, _of0);
  return _oqr * _ob3;
}
struct _or {
  _ohg: bool,
  a: vec4f,
  b: vec4f,
};
fn _o6r(_oic: vec4f, _oio: vec4f) -> _or {
  var _ole: _or;
  _ole._ohg = false;
  let _o89 = _oio - _oic;
  let _oh1 = _oic.w - _o2j;
  let _o8u = _o89.w;
  var _oov = 0.0;
  var _oow = 1.0;
  if (_o8u == 0.0) {
    if (_oh1 < 0.0) {
      return _ole;
    }
  } else {
    let _opz = -_oh1 / _o8u;
    if (_o8u > 0.0) {
      _oov = _obd(_oov, _opz);
    } else {
      _oow = _obe(_oow, _opz);
    }
  }
  if (_oov > _oow) {
    return _ole;
  }
  for (var _o58 = 0u; _o58 < 4u; _o58 = _o58 + 1u) {
    _ole.a[_o58] = _obc(_o89[_o58], _oov, _oic[_o58]);
    _ole.b[_o58] = _obc(_o89[_o58], _oow, _oic[_o58]);
  }
  _ole._ohg = true;
  return _ole;
}
const _o2d: u32 = 1u;
const _o2e: u32 = 2u;
const _o2f: u32 = 4u;
struct _o1n {
  _orf: vec2f,
  _or5: vec2f,
  _ora: vec2f,
  _os0: f32,
  _os1: f32,
  _oeh: f32,
  _oej: f32,
  _ofy: f32,
  _obb: u32,
};
fn _ohy(_oi3: _o1v) -> _o1n {
  var _oh8: _o1n;
  _oh8._orf = _oi3._oht.xy;
  _oh8._or5 = _oi3._oht.zw;
  _oh8._ora = _oi3._ohu.xy;
  _oh8._os0 = _oi3._ohu.z;
  _oh8._os1 = _oi3._ohu.w;
  _oh8._oeh = _oi3._ohv.x;
  _oh8._oej = _oi3._ohv.y;
  _oh8._ofy = _oi3._ohv.z;
  _oh8._obb = bitcast<u32>(_oi3._ohv.w);
  return _oh8;
}
struct _o1w {
  _oi4: vec2f,
  _oi5: vec2f,
  _oi6: vec2f,
  _oi7: vec2f,
};
struct _ou {
  _ogd: _o1w,
  _oa6: _o1w,
  _oa7: _o1w,
};
fn _o3d(_oi3: vec2f, a: vec2f, _o9z: vec2f) -> f32 {
  return _obc(_oi3.y - a.y, _o9z.y, (_oi3.x - a.x) * _o9z.x);
}
fn _oi1(a: vec2f, _o9z: vec2f, _oi4: vec2f, _oi5: vec2f, _ofz: vec2f, _og0: vec2f) -> _o1w {
  let _ooo = _o3d(_oi4, a, _o9z) > _o3d(_oi5, a, _o9z);
  let _oon = _o3d(_ofz, a, _o9z) > _o3d(_og0, a, _o9z);
  return _o1w(select(_oi4, _oi5, _ooo), select(_oi5, _oi4, _ooo),
              select(_og0, _ofz, _oon), select(_ofz, _og0, _oon));
}
fn _ohe(a: vec2f, _olx: f32, _or2: vec2f) -> vec2f {
  return vec2f(_obc(_olx, _or2.x, a.x), _obc(_olx, _or2.y, a.y));
}
fn _ohw(a: vec2f, b: vec2f, _oi8: f32, _oh8: _o1n) -> _ou {
  let _o9z = b - a;
  let _ofa = _od6(_o9z.x, _o9z.y);
  let _on0 = _ofa < 1e-4;
  let _om6 = select(_o9z, vec2f(1.0, 0.0), _on0);
  let _om7 = select(_ofa, 1.0, _on0);
  let _ogq = vec2f(-_om6.y / _om7, _om6.x / _om7);
  let _oqg = vec2f(_om6.x / _om7, _om6.y / _om7);
  let _o32 = _ohe(a, -_oh8._os0, _oh8._orf);
  let _o33 = _ohe(a, _oh8._os0, _oh8._orf);
  let _o44 = _ohe(b, -_oh8._os1, _oh8._orf);
  let _o45 = _ohe(b, _oh8._os1, _oh8._orf);
  var _o30: vec2f;
  var _o2z: vec2f;
  var _o42: vec2f;
  var _o41: vec2f;
  if ((_oh8._obb & _o2e) != 0u) {
    let _o2p = _ohe(a, -_oi8, _oqg);
    _o30 = _ohe(_o2p, _oh8._os0, _ogq);
    _o2z = _ohe(_o2p, -_oh8._os0, _ogq);
  } else {
    let _o2p = _ohe(a, -_oh8._oeh, _o9z);
    _o30 = _ohe(_o2p, _oh8._os0, _oh8._or5);
    _o2z = _ohe(_o2p, -_oh8._os0, _oh8._or5);
  }
  if ((_oh8._obb & _o2f) != 0u) {
    let _o3z = _ohe(b, _oi8, _oqg);
    _o42 = _ohe(_o3z, _oh8._os1, _ogq);
    _o41 = _ohe(_o3z, -_oh8._os1, _ogq);
  } else {
    let _o3z = _ohe(b, _oh8._oej, _o9z);
    _o42 = _ohe(_o3z, _oh8._os1, _oh8._ora);
    _o41 = _ohe(_o3z, -_oh8._os1, _oh8._ora);
  }
  return _ou(_o1w(_o32, _o44, _o45, _o33),
                 _oi1(a, _o9z, _o33, _o30, _o32, _o2z),
                 _oi1(a, _o9z, _o45, _o42, _o44, _o41));
}
fn _o47(_oi4: vec2f, _oi5: vec2f, _osp: f32, _oso: f32, _okl: vec2f) -> vec2f {
  var _osl = _okl.x;
  var _osj = _okl.y;
  if (_oi4.y >= _osp && _oi4.y <= _oso) {
    _osl = _obe(_osl, _oi4.x);
    _osj = _obd(_osj, _oi4.x);
  }
  if (_obd(_oi4.y, _oi5.y) < _osp || _obe(_oi4.y, _oi5.y) > _oso) {
    return vec2f(_osl, _osj);
  }
  let _o9x = _oi5.y - _oi4.y;
  if (_o9x != 0.0) {
    let _op8 = _obe(_obd((_osp - _oi4.y) / _o9x, 0.0), 1.0);
    let _oph = _obe(_obd((_oso - _oi4.y) / _o9x, 0.0), 1.0);
    let _osh = _obc(_op8, _oi5.x - _oi4.x, _oi4.x);
    let _osi = _obc(_oph, _oi5.x - _oi4.x, _oi4.x);
    _osl = _obe(_osl, _obe(_osh, _osi));
    _osj = _obd(_osj, _obd(_osh, _osi));
  } else {
    _osl = _obe(_osl, _obe(_oi4.x, _oi5.x));
    _osj = _obd(_osj, _obd(_oi4.x, _oi5.x));
  }
  return vec2f(_osl, _osj);
}
fn _o48(_ojy: _o1w, _osp: f32, _oso: f32, _okl: vec2f) -> vec2f {
  var r = _o47(_ojy._oi4, _ojy._oi5, _osp, _oso, _okl);
  r = _o47(_ojy._oi5, _ojy._oi6, _osp, _oso, r);
  r = _o47(_ojy._oi6, _ojy._oi7, _osp, _oso, r);
  return _o47(_ojy._oi7, _ojy._oi4, _osp, _oso, r);
}
fn _ohc(_oi4: vec2f, _oi5: vec2f, _osp: f32, _oso: f32, _okl: vec2f) -> vec2f {
  var _osl = _okl.x;
  var _osj = _okl.y;
  if (_oi4.y >= _osp && _oi4.y <= _oso) {
    _osl = _obe(_osl, _oi4.x);
    _osj = _obd(_osj, _oi4.x);
  }
  let _o9x = _oi5.y - _oi4.y;
  if (_o9x != 0.0) {
    let _oov = (_osp - _oi4.y) / _o9x;
    if (_oov > 0.0 && _oov < 1.0) {
      let x = _obc(_oov, _oi5.x - _oi4.x, _oi4.x);
      _osl = _obe(_osl, x);
      _osj = _obd(_osj, x);
    }
    let _oow = (_oso - _oi4.y) / _o9x;
    if (_oow > 0.0 && _oow < 1.0) {
      let x = _obc(_oow, _oi5.x - _oi4.x, _oi4.x);
      _osl = _obe(_osl, x);
      _osj = _obd(_osj, x);
    }
  }
  return vec2f(_osl, _osj);
}
fn _ohb(a: vec2f, b: vec2f, _oia: f32, _oi8: f32) -> _o1w {
  let _o9a = b - a;
  let _ofa = _od6(_o9a.x, _o9a.y);
  let _on0 = _ofa < 1e-4;
  let _om6 = select(_o9a, vec2f(1.0, 0.0), _on0);
  let _om7 = select(_ofa, 1.0, _on0);
  let _oqn = vec2f(-_om6.y / _om7, _om6.x / _om7);
  let _oqm = vec2f(_om6.x / _om7, _om6.y / _om7);
  let _ojf = _oia + _oj;
  let _oic = _oi8 + _oj;
  let _o5o = vec2f(_obc(-_oqm.x, _oic, _obc(_oqn.x, _ojf, a.x)),
                 _obc(-_oqm.y, _oic, _obc(_oqn.y, _ojf, a.y)));
  let _o59 = vec2f(_obc(-_oqm.x, _oic, _obc(-_oqn.x, _ojf, a.x)),
                 _obc(-_oqm.y, _oic, _obc(-_oqn.y, _ojf, a.y)));
  let _o5n = vec2f(_obc(_oqm.x, _oic, _obc(_oqn.x, _ojf, b.x)),
                 _obc(_oqm.y, _oic, _obc(_oqn.y, _ojf, b.y)));
  let _o5g = vec2f(_obc(_oqm.x, _oic, _obc(-_oqn.x, _ojf, b.x)),
                 _obc(_oqm.y, _oic, _obc(-_oqn.y, _ojf, b.y)));
  return _o1w(_o59, _o5g, _o5n, _o5o);
}
fn _onm(_okl: vec2f, _os6: u32, _oqb: i32, _oqc: i32, _ofy: f32) -> vec3u {
  let _orv = f32(_os6 - 1u);
  let _osm = _obe(_obd(_okl.x - _ofy, 0.0), _orv);
  let _osk = _obe(_obd(_okl.y + _ofy, 0.0), _orv);
  let _ooq = max(_oqb, i32(floor(_osm * 0.0625)));
  let _oor = min(_oqc, i32(floor(_osk * 0.0625)) + 1);
  let _ohg = _okl.y >= _okl.x && _oor > _ooq;
  return select(vec3u(0u), vec3u(u32(_ooq), u32(_oor), 1u), _ohg);
}
fn _opu(_ols: _o1w, _oh8: _o1n, _o58: _ou, _oqd: u32, _os6: u32,
                         _oqb: u32, _oqc: u32) -> vec3u {
  let _osp = f32(_oqd * _oi);
  let _oso = f32(_oqd * _oi + (_oi - 1u));
  var r = _ohc(_ols._oi4, _ols._oi5, _osp, _oso, vec2f(3.4e38, -3.4e38));
  r = _ohc(_ols._oi5, _ols._oi6, _osp, _oso, r);
  r = _ohc(_ols._oi6, _ols._oi7, _osp, _oso, r);
  r = _ohc(_ols._oi7, _ols._oi4, _osp, _oso, r);
  let _ol9 = _onm(r, _os6, i32(_oqb), i32(_oqc), 0.0);
  let _ohi = _osp - _oh8._ofy;
  let _ohf = _oso + _oh8._ofy;
  var _ojy = _o48(_o58._ogd, _ohi, _ohf, vec2f(3.4e38, -3.4e38));
  _ojy = _o48(_o58._oa6, _ohi, _ohf, _ojy);
  _ojy = _o48(_o58._oa7, _ohi, _ohf, _ojy);
  let _oi0 = _onm(_ojy, _os6, i32(_ol9.x), i32(_ol9.y), _oh8._ofy);
  let _or0 = _ol9.z == 0u || (_oh8._obb & _o2d) != 0u;
  return select(_oi0, _ol9, _or0);
}
fn _ojq(a: f32, b: f32, _o58: f32, _o89: f32) -> f32 {
  let _oi3 = _oq9(a, b);
  let _ojy = _oq9(_o58, _o89);
  let _olx = _oqa(_oi3.x, -_ojy.x);
  let _ofu = (_oi3.y - _ojy.y) + _olx.y;
  return _olx.x + _ofu;
}
fn _ohz(_oi3: vec2f, a: vec2f, _o9z: vec2f, _oa2: f32) -> f32 {
  let _o9w = _oi3.x - a.x;
  let _o9x = _oi3.y - a.y;
  let _oou = _obe(_obd((_o9w * _o9z.x + _o9x * _o9z.y) / _oa2, 0.0), 1.0);
  return _od6(_o9w - _oou * _o9z.x, _o9x - _oou * _o9z.y);
}
fn _ob5(_or2: vec2f) -> bool {
  return _odz(_or2.x) && _odz(_or2.y);
}
struct _o1o {
  w: f32,
  _or2: vec2f,
  _oei: f32,
};
fn _ohx(g: f32, _om2: f32, _o5s: vec2f, _ogq: vec2f, _o8z: f32, _oq4: f32, _o4n: f32,
               _oed: f32, _oev: f32) -> _o1o {
  let gg = g * g;
  let _om4 = gg * _om2 + _o4n;
  let _o92 = gg * gg * _o8z + gg * _o4n * _oq4 + _o4n * _o4n;
  var _oa5: _o1o;
  _oa5.w = _oed * sqrt(_om4);
  _oa5._or2 = vec2f((gg * _o5s.x + _o4n * _ogq.x) / _om4, (gg * _o5s.y + _o4n * _ogq.y) / _om4);
  _oa5._oei = _oed * sqrt(_o92 / _om4) / _oev;
  return _oa5;
}
fn _ood(g: f32, _oae: f32, _oab: f32, _o8z: f32, _oq4: f32, _o4n: f32,
                       _o81: f32) -> bool {
  let gg = g * g;
  let _oci = _obc(gg, _oae, _o4n * _oab);
  let _o8y = _obc(gg, _obc(gg, _o8z, _o4n * _oq4), _o4n * _o4n);
  let _o82 = _o81 * _oci;
  let _ojp = _o82 * _o8y;
  return !_odz(_ojp) || _ojp > 1e37;
}
fn _o7h(_oi3: vec2f, a: vec2f, _o9z: vec2f, _oa2: f32, _ol3: vec2f) -> vec2f {
  let _ob4 = _ol3.y != 0.0 && _ob5(_oi3);
  return vec2f(_obd(_ol3.x, _ohz(_oi3, a, _o9z, _oa2)), select(0.0, 1.0, _ob4));
}
fn _ok4(_ojy: _o1w, a: vec2f, _o9z: vec2f, _oa2: f32, _ol3: vec2f) -> vec2f {
  var r = _o7h(_ojy._oi4, a, _o9z, _oa2, _ol3);
  r = _o7h(_ojy._oi5, a, _o9z, _oa2, r);
  r = _o7h(_ojy._oi6, a, _o9z, _oa2, r);
  return _o7h(_ojy._oi7, a, _o9z, _oa2, r);
}
fn _o53(_o5o: vec3f, _o5t: vec3f, _okt: f32, _oku: f32, _oj5: bool,
                      _o81: f32, a: vec2f, b: vec2f, _ogq: vec2f, _oi8: f32,
                      _o4n: f32, _os6: u32, _ocv: u32) -> _o1n {
  var _oh8: _o1n;
  _oh8._orf = vec2f(0.0);
  _oh8._or5 = vec2f(0.0);
  _oh8._ora = vec2f(0.0);
  _oh8._os0 = 0.0;
  _oh8._os1 = 0.0;
  _oh8._oeh = 0.0;
  _oh8._oej = 0.0;
  _oh8._ofy = 0.0;
  _oh8._obb = _o2d;
  if (_oj5) {
    return _oh8;
  }
  let _o9z = b - a;
  let _oa2 = _o9z.x * _o9z.x + _o9z.y * _o9z.y;
  let _oev = sqrt(_oa2);
  let _oed = sqrt(_o81);
  let _o8z = _obd(_ojq(_o5o.x, _o5o.z, _o5o.y, _o5o.y), 0.0);
  let _oq4 = _o5o.x + _o5o.z;
  let _o6f = vec2f(_o5t.x * _ogq.x + _o5t.y * _ogq.y, _o5t.y * _ogq.x + _o5t.z * _ogq.y);
  let _om3 = _ogq.x * _o6f.x + _ogq.y * _o6f.y;
  _oh8._orf = vec2f(_o6f.x / _om3, _o6f.y / _om3);
  let _o5s = vec2f(_o5o.x * _ogq.x + _o5o.y * _ogq.y, _o5o.y * _ogq.x + _o5o.z * _ogq.y);
  let _om2 = _ogq.x * _o5s.x + _ogq.y * _o5s.y;
  let _oa6 = _ohx(_okt, _om2, _o5s, _ogq, _o8z, _oq4, _o4n, _oed, _oev);
  let _oa7 = _ohx(_oku, _om2, _o5s, _ogq, _o8z, _oq4, _o4n, _oed, _oev);
  _oh8._os0 = _oa6.w;
  _oh8._os1 = _oa7.w;
  _oh8._or5 = _oa6._or2;
  _oh8._ora = _oa7._or2;
  _oh8._oeh = _oa6._oei;
  _oh8._oej = _oa7._oei;
  let _obu = _obd(_okt, _oku);
  let _oc0 = _obu * _obu;
  let _oq5 = _oc0 * _oq4 + 2.0 * _o4n;
  let _o91 = _oc0 * _oc0 * _o8z + _oc0 * _o4n * _oq4 + _o4n * _o4n;
  let _oqg = 5.9604644775390625e-8;
  let r = 16.0 * _oqg * _oq5 * _oq5 / _o91;
  let _o8q = _obd(_obd(abs(a.x), abs(a.y)), _obd(abs(b.x), abs(b.y)))
         + f32(_os6) + f32(_ocv);
  let _o8s = !(_o91 > 0.0) || !_odz(_o91) || (_o4n == 0.0 && _o8z == 0.0);
  let _o2u = _o5o.z * _o9z.x - _o5o.y * _o9z.y;
  let _o2v = _o5o.x * _o9z.y - _o5o.y * _o9z.x;
  let _oae = _obd(_o9z.x * _o2u + _o9z.y * _o2v, 0.0);
  let _oab = _o9z.x * _o9z.x + _o9z.y * _o9z.y;
  let _ol5 = _obd(_o5o.x * _o5o.z - _o5o.y * _o5o.y, 0.0);
  let _ol6 = _o5o.x + _o5o.z;
  var _obb = 0u;
  if (_ood(_okt, _oae, _oab, _ol5, _ol6, _o4n, _o81)) {
    _obb = _obb | _o2e;
  }
  if (_ood(_okt + (_oku - _okt), _oae, _oab, _ol5, _ol6, _o4n, _o81)) {
    _obb = _obb | _o2f;
  }
  _oh8._obb = _obb;
  let _o58 = _ohw(a, b, _oi8, _oh8);
  var _ol3 = _ok4(_o58._ogd, a, _o9z, _oa2, vec2f(0.0, 1.0));
  _ol3 = _ok4(_o58._oa6, a, _o9z, _oa2, _ol3);
  _ol3 = _ok4(_o58._oa7, a, _o9z, _oa2, _ol3);
  var _ob4 = _ol3.y != 0.0;
  let _o4t = _ol3.x;
  _oh8._ofy = r * _o4t + 0.02 + 4.0 * _oqg * _o8q;
  let _oob = (_obb & _o2e) != 0u;
  let _ooc = (_obb & _o2f) != 0u;
  _ob4 = _ob4 && _ob5(_oh8._orf) && _odz(_oh8._os0) && _odz(_oh8._os1)
      && (_oob || (_ob5(_oh8._or5) && _odz(_oh8._oeh)))
      && (_ooc || (_ob5(_oh8._ora) && _odz(_oh8._oej)))
      && _odz(_o4t) && _odz(r) && _odz(_oh8._ofy);
  if (_o8s || !_ob4) {
    _oh8._obb = _o2d;
  }
  return _oh8;
}
@compute @workgroup_size(256)
fn preprocess_beta(@builtin(local_invocation_index) _ofg: u32,
                   @builtin(workgroup_id) _os5: vec3u,
                   @builtin(num_workgroups) _oh4: vec3u) {
  let _odb = _ofj(_os5, _oh4) * _o2o + _ofg;
  if (_odb >= _o7r[_o21]) {
    return;
  }
  let _oni = _oeo[_odb];
  _opv[_odb] = 0u;
  _ojm[_odb]._obz = vec4f(0.0, 0.0, 0.0, 0.0);
  let _o3p = _ojl[_odb];
  let _o3f = bitcast<f32>(_o3p.x);
  let _omy = bitcast<f32>(_o3p.y);
  let _oh8 = 6u * _oni;
  let _oid = vec3f(_oa9[_oh8], _oa9[_oh8 + 1u], _oa9[_oh8 + 2u]);
  let _oip = vec3f(_oa9[_oh8 + 3u], _oa9[_oh8 + 4u], _oa9[_oh8 + 5u]);
  let _ofi = vec3f((_oid.x + _oip.x) * 0.5, (_oid.y + _oip.y) * 0.5, (_oid.z + _oip.z) * 0.5);
  let _o8v = _ori(_ofi);
  if (_o8v < _od) {
    return;
  }
  let _o6o = _o6r(_oju(_oid), _oju(_oip));
  if (!_o6o._ohg) {
    return;
  }
  let _os6 = _o5x._os6;
  let _ocv = _o5x._ocv;
  let _o31 = vec2f(_ogu(_o6o.a.x / _o6o.a.w, _os6), _ogu(_o6o.a.y / _o6o.a.w, _ocv));
  let _o43 = vec2f(_ogu(_o6o.b.x / _o6o.b.w, _os6), _ogu(_o6o.b.y / _o6o.b.w, _ocv));
  let _ob2 = _o5x._o4n;
  let _o68 = _oju(_ofi);
  var _omp = _o68.w > _o2j && _odz(_o68.w);
  let _om8 = select(1.0, _o68.w, _omp);
  let _odr = 1.0 / (_om8 * _om8);
  let _ofh = _ob * _om8;
  let _o6m = _obe(_obd(_o68.x, -_ofh), _ofh);
  let _o6n = _obe(_obd(_o68.y, -_ofh), _ofh);
  let _oe6 = _o6m != _o68.x || _o6n != _o68.y;
  let _ocq = 0.5 * f32(_os6);
  let _ocn = 0.5 * f32(_ocv);
  let _oe8 = vec3f(_ocq * (_om8 * _oj2(0u) - _o6m * _oj2(3u)) * _odr,
                 _ocq * (_om8 * _oj2(4u) - _o6m * _oj2(7u)) * _odr,
                 _ocq * (_om8 * _oj2(8u) - _o6m * _oj2(11u)) * _odr);
  let _oeb = vec3f(_ocn * (_om8 * _oj2(1u) - _o6n * _oj2(3u)) * _odr,
                 _ocn * (_om8 * _oj2(5u) - _o6n * _oj2(7u)) * _odr,
                 _ocn * (_om8 * _oj2(9u) - _o6n * _oj2(11u)) * _odr);
  let _ogi = vec2f(_ogu(_o68.x / _om8, _os6),
                           _ogu(_o68.y / _om8, _ocv));
  let _obj = _oep(_oni, _oe8, _oeb);
  let _obx = 4.0 * exp2(_omy * _oc);
  let _obw = !(_obx >= _o8 && _obx <= _o7);
  let _obv = _obe(_obd(_obx, _o8), _o7);
  let _oe9 = _obj._ob2 * _o9n(_oe8, _oe8);
  let _oea = _obj._ob2 * _o9n(_oe8, _oeb);
  let _oec = _obj._ob2 * _o9n(_oeb, _oeb);
  let _o5p = _obj._o5u + _oe9;
  let _o5q = _obj._o5v + _oea;
  let _o5r = _obj._o5w + _oec;
  let _oiv = _ob2;
  let _o5a = _o5p + _oiv;
  let _o5d = _o5q;
  let _o5k = _o5r + _oiv;
  _onx(_obv);
  _ob1(_obv);
  let _ol7 = vec4f(select(_obv, -_obv, _obw), _obv, _oiv, 0.0);
  let _okt = _om8 / _o6o.a.w;
  let _oku = _om8 / _o6o.b.w;
  let _o90 = _o5a * _o5k - _o5d * _o5d;
  _omp = _omp && _o90 > 0.0 && _odz(_o90);
  let _odn = select(0.0, 1.0 / _o90, _omp);
  let _o6j = _o43 - _o31;
  let _o38 = _o5k * _o6j.x - _o5d * _o6j.y;
  let _o39 = _o5a * _o6j.y - _o5d * _o6j.x;
  let _oci = _o6j.x * _o38 + _o6j.y * _o39;
  let _och = _obd(_oci * _odn, 0.0);
  let _oex = sqrt(_och);
  let _odo = select(0.0, 1.0 / _oci, _och > 1e-8);
  let _oj5 = !(_oex > _o2n) || !(_odo > 0.0);
  let _o5z = _o5x._o60.xyz;
  let _okv = _ofi - _o5z;
  let _odw = inverseSqrt(_o9n(_okv, _okv));
  var _okw = _okv * _odw;
  if (_oe6) {
    let _oh0 = vec3f(_oe8.y * _oeb.z - _oe8.z * _oeb.y,
                    _oe8.z * _oeb.x - _oe8.x * _oeb.z,
                    _oe8.x * _oeb.y - _oe8.y * _oeb.x);
    let _odv = inverseSqrt(_o9n(_oh0, _oh0));
    _okw = _oh0 * _odv;
  }
  let _oaw = _o3h(_obj, _oe8, _oeb, _okw, _o6j.x, _o6j.y);
  let _o7a = vec3f(_o5a, _o5d, _o5k);
  let _ope = vec3f(_o5p, _o5q, _o5r);
  let _olf = _obd(_o3f, 0.0);
  let _ojz = _olf * _oaw._oq7 * _oaw._ogz;
  let _of1 = sqrt(_oaw._ogc) / (_oaw._ogz * _oaw._okz);
  _omp = _omp && (_oaw._oah || _oaw._ogc > 0.0);
  let _oee = _oo1(_oaw, _okt, _o7a, _ope, _o6j.x, _o6j.y);
  let _oeg = _oo1(_oaw, 1.0, _o7a, _ope, _o6j.x, _o6j.y);
  let _oef = _oo1(_oaw, _oku, _o7a, _ope, _o6j.x, _o6j.y);
  let _oiq = _olf * _obd(_oee, _obd(_oeg, _oef));
  let _oqj = _ojz * _oqs(_of1, _okt);
  let _oql = _ojz * _oqs(_of1, 1.0);
  let _oqk = _ojz * _oqs(_of1, _oku);
  _omp = _omp && _oaw._ojd && _odz(_of1)
      && _odz(_oqj) && _odz(_oql) && _odz(_oqk);
  if (!_omp) {
    return;
  }
  let _o69 = _ogi;
  let _oks = _o14 / _obd(_oiq, _o14);
  let _o83 = _obd(0.5 * (1.0 - exp2(log2(_oks) / _obv)), 1e-6);
  let _o9a = _o43 - _o31;
  let _ofa = _od6(_o9a.x, _o9a.y);
  let _on0 = _ofa < 1e-4;
  let _om6 = select(_o9a, vec2f(1.0, 0.0), _on0);
  let _om7 = select(_ofa, 1.0, _on0);
  let _oqn = vec2f(-_om6.y / _om7, _om6.x / _om7);
  let _oqm = vec2f(_om6.x / _om7, _om6.y / _om7);
  let _oed = sqrt(_o83);
  let _obu = _obd(_okt, _oku);
  let _ooa = _obd(_obu * _obu - 1.0, 0.0);
  let _o6w = _o5a + _ooa * _o5p;
  let _o6x = _o5d + _ooa * _o5q;
  let _o6y = _o5k + _ooa * _o5r;
  let _or9 = _oqn.x * (_o6w * _oqn.x + _o6x * _oqn.y)
               + _oqn.y * (_o6x * _oqn.x + _o6y * _oqn.y);
  let _or8 = _oqm.x * (_o6w * _oqm.x + _o6x * _oqm.y)
                + _oqm.y * (_o6x * _oqm.x + _o6y * _oqm.y);
  var _oia = _oed * sqrt(_obd(_or9, 1e-8));
  var _oi8: f32;
  if (_oj5) {
    _oi8 = _oed * sqrt(_obd(_or8, 1e-8));
  } else {
    let x = _oqn.x * (_o6w * _oqm.x + _o6x * _oqm.y)
          + _oqn.y * (_o6x * _oqm.x + _o6y * _oqm.y);
    let _o8y = _o6w * _o6y - _o6x * _o6x;
    _oi8 = _oed * sqrt(_obd(_or8, 1e-8)
        + 2.0 * abs(x) * sqrt(_obd(_o8y, 0.0)) / _obd(_or9, 1e-8));
  }
  let _o95 = _od6(f32(_os6), f32(_ocv));
  let _o61 = _o95 + _od6(_o69.x - 0.5 * f32(_os6 - 1u), _o69.y - 0.5 * f32(_ocv - 1u));
  _oia = _obe(_oia, _o61);
  _oi8 = _obe(_oi8, _o61);
  var _ok3: array<vec2f, 4>;
  _ok3[3] = vec2f(_obc(-_oqm.x, _oi8, _obc(_oqn.x, _oia, _o31.x)),
                  _obc(-_oqm.y, _oi8, _obc(_oqn.y, _oia, _o31.y)));
  _ok3[0] = vec2f(_obc(-_oqm.x, _oi8, _obc(-_oqn.x, _oia, _o31.x)),
                  _obc(-_oqm.y, _oi8, _obc(-_oqn.y, _oia, _o31.y)));
  _ok3[2] = vec2f(_obc(_oqm.x, _oi8, _obc(_oqn.x, _oia, _o43.x)),
                  _obc(_oqm.y, _oi8, _obc(_oqn.y, _oia, _o43.y)));
  _ok3[1] = vec2f(_obc(_oqm.x, _oi8, _obc(-_oqn.x, _oia, _o43.x)),
                  _obc(_oqm.y, _oi8, _obc(-_oqn.y, _oia, _o43.y)));
  var _ogk = _ok3[0].x;
  var _og6 = _ok3[0].x;
  var _ogm = _ok3[0].y;
  var _og8 = _ok3[0].y;
  var _og1 = 0.0;
  for (var _od7 = 0u; _od7 < 4u; _od7 = _od7 + 1u) {
    let _o7f = _ok3[_od7];
    if (!_odz(_o7f.x) || !_odz(_o7f.y)) {
      return;
    }
    _ogk = _obe(_ogk, _o7f.x);
    _og6 = _obd(_og6, _o7f.x);
    _ogm = _obe(_ogm, _o7f.y);
    _og8 = _obd(_og8, _o7f.y);
    _og1 = _obd(_og1, _od6(_o7f.x - _o69.x, _o7f.y - _o69.y));
  }
  let _os4 = f32(_os6 - 1u);
  let _ocw = f32(_ocv - 1u);
  if (_og6 + _oj < 0.0 || _ogk - _oj > _os4
      || _og8 + _oj < 0.0 || _ogm - _oj > _ocw) {
    return;
  }
  let _ogl = _obe(_obd(_ogk - _oj, 0.0), _os4);
  let _og7 = _obe(_obd(_og6 + _oj, 0.0), _os4);
  let _ogn = _obe(_obd(_ogm - _oj, 0.0), _ocw);
  let _og9 = _obe(_obd(_og8 + _oj, 0.0), _ocw);
  let _oce = i32(_o5x._opw);
  let _ocf = i32(_o5x._opx);
  let _oqb = max(0, min(_oce, i32(floor(_ogl * 0.0625))));
  let _oqe = max(0, min(_ocf, i32(floor(_ogn * 0.0625))));
  let _oqc = max(0, min(_oce, i32(floor(_og7 * 0.0625)) + 1));
  let _oqf = max(0, min(_ocf, i32(floor(_og9 * 0.0625)) + 1));
  if (_oqb >= _oqc || _oqe >= _oqf) {
    return;
  }
  let _okk = f32(max(_os6, _ocv));
  let _og2 = max(1, i32(ceil(_obe(_og1, _okk))));
  let _ohs = _o53(_ope, _o7a, _okt, _oku, _oj5, _o83,
                                   _o31, _o43, _oqn, _oi8, _ol7.z, _os6, _ocv);
  var _ojk: _o1v;
  _ojk._o3i = vec4f(_o5p, _o5q, _o5r, select(_okt, -abs(_okt), _oj5));
  _ojk._o4u = vec4f(_ojz, _of1, _o83, _oku);
  _ojk.ab = vec4f(_o31, _o43);
  _ojk._obz = vec4f(_oia, _oi8, _o8v, f32(_og2));
  _ojk._ol9 = vec4u(u32(_oqb), u32(_oqe), u32(_oqc), u32(_oqf));
  _ojk._ol7 = _ol7;
  _ojk._oht = vec4f(_ohs._orf, _ohs._or5);
  _ojk._ohu = vec4f(_ohs._ora, _ohs._os0, _ohs._os1);
  _ojk._ohv = vec4f(_ohs._oeh, _ohs._oej, _ohs._ofy, bitcast<f32>(_ohs._obb));
  _ojm[_odb] = _ojk;
  let _o7j = _ohw(_o31, _o43, _oi8, _ohs);
  let _ola = _ohb(_o31, _o43, _oia, _oi8);
  var _ogt = 0u;
  for (var _oqd = u32(_oqe); _oqd < u32(_oqf); _oqd = _oqd + 1u) {
    let _onl = _opu(_ola, _ohs, _o7j, _oqd, _os6,
                                     u32(_oqb), u32(_oqc));
    if (_onl.z != 0u) {
      _ogt = _ogt + (_onl.y - _onl.x);
    }
  }
  _opv[_odb] = _ogt;
}
@compute @workgroup_size(256)
fn duplicate_keys_beta(@builtin(local_invocation_index) _ofg: u32,
                       @builtin(workgroup_id) _os5: vec3u,
                       @builtin(num_workgroups) _oh4: vec3u) {
  let _odb = _ofj(_os5, _oh4) * _o2o + _ofg;
  if (_odb >= _o9t[_o21]) {
    return;
  }
  let _ojk = _o9v[_odb];
  if (!(_ojk._obz.w > 0.0)) {
    return;
  }
  var off = 0u;
  if (_odb > 0u) {
    off = _o9u[_odb - 1u];
  }
  let _o31 = _ojk.ab.xy;
  let _o43 = _ojk.ab.zw;
  let _ohs = _ohy(_ojk);
  let _o7j = _ohw(_o31, _o43, _ojk._obz.y, _ohs);
  let _ola = _ohb(_o31, _o43, _ojk._obz.x, _ojk._obz.y);
  let _o8w = bitcast<u32>(_ojk._obz.z);
  let _o62 = _o9s._o62;
  for (var y = _ojk._ol9.y; y < _ojk._ol9.w; y = y + 1u) {
    let _onl = _opu(_ola, _ohs, _o7j, y,
                                     _o9s._os6, _ojk._ol9.x, _ojk._ol9.z);
    if (_onl.z == 0u) {
      continue;
    }
    for (var x = _onl.x; x < _onl.y; x = x + 1u) {
      if (off < _o62) {
        _oes[off] = y * _o9s._opw + x;
        _oet[off] = _o8w;
        _oim[off] = _odb;
      }
      off = off + 1u;
    }
  }
}
