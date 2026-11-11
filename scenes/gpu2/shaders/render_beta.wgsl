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
struct _om {
  _oqp: f32,
  _oqq: f32,
  _okp: f32,
  _okq: f32,
  _o40: u32,
  _o3u: u32,
  _or4: u32,
  _ojn: u32,
};
@group(0) @binding(0) var<storage, read> _oly: array<u32>;
@group(0) @binding(1) var<storage, read> _okd: array<u32>;
@group(0) @binding(2) var<storage, read> _oko: array<_o1y>;
@group(0) @binding(3) var<storage, read> rgb: array<f32>;
@group(0) @binding(4) var<storage, read> _okn: array<vec4u>;
@group(0) @binding(5) var<storage, read> _oqz: array<f32>;
@group(0) @binding(6) var<storage, read> _or0: array<f32>;
@group(0) @binding(7) var<storage, read_write> _oiw: array<f32>;
@group(0) @binding(8) var<uniform> _o69: _oo;
@group(0) @binding(9) var<uniform> _o5a: _om;
const _of: u32 = 256u;
const _o2p: f32 = 0.1;
const _o1o: f32 = 0.0;
const _o5: f32 = 1.0e-30;
const _o8: f32 = 1.0e-4;
const _od: f32 = 0.1;
const _o4: f32 = 1.17549435e-38;
const _oe: f32 = 1.41421356;
const _o9: f32 = 0.707106781;
const _o3: f32 = -3.1215594;
const _o2: f32 = 1.8495809;
const _o16: u32 = 6u;
const _o17: u32 = 8u;
const _o15 = array<f32, 24>(
  -1.0, 0.0, 0.0, 0.0,
  0.8639625, -0.080043316, 0.011840287, -0.00032925335,
  -0.65780294, 0.16117837, -0.025375213, 0.0017560583,
  0.40191287, -0.1712049, 0.028378023, -0.0027375722,
  -0.16230038, 0.09921428, -0.017412446, 0.0016617817,
  0.030476268, -0.023956835, 0.004615334, -0.00040338145);
const _o14 = array<f32, 5>(
  0.9317711, -0.04327248, 0.0059742285, 8.387385e-06, -1.3679006e-05);
const _o13 = array<f32, 5>(
  1.0743953, 0.049604684, -0.005744186, -0.00030108364, 2.7100898e-05);
var<workgroup> _o4m: array<u32, 256>;
var<workgroup> _o4n: array<vec4f, 256>;
var<workgroup> _o4o: array<vec4f, 256>;
var<workgroup> _o4h: array<vec2f, 256>;
var<workgroup> _o4k: array<vec2f, 256>;
var<workgroup> _o4i: array<vec4f, 256>;
var<workgroup> _o4p: array<array<f32, 8>, 256>;
var<workgroup> _o4l: array<f32, 256>;
var<workgroup> _o4q: array<i32, 256>;
var<workgroup> _oa4: atomic<u32>;
var<workgroup> _oa3: u32;
var<private> _op7: array<f32, 8>;
var<private> _oo4: array<f32, 5>;
fn _osz(_ofd: u32) -> f32 {
  return _o69._osu[_ofd >> 2u][_ofd & 3u];
}
fn _op5(_oon: u32, _ocs: f32) {
  _o4p[_oon][0] = _ocs;
  let _od0 = _ocs + 1.0;
  let r = inverseSqrt(_od0);
  let z = fma(r, _o3, _o2);
  let _otz = z + z;
  var _oq8: array<f32, 5>;
  _oq8[0] = 1.0;
  _oq8[1] = z;
  for (var _of3 = 2u; _of3 <= 4u; _of3 = _of3 + 1u) {
    _oq8[_of3] = fma(_otz, _oq8[_of3 - 1u], -_oq8[_of3 - 2u]);
  }
  var _o8v: array<f32, 6>;
  for (var _ofd = 0u; _ofd < _o16; _ofd = _ofd + 1u) {
    var _o38 = _o15[_ofd * 4u];
    for (var _of3 = 1u; _of3 <= 3u; _of3 = _of3 + 1u) {
      _o38 = fma(_o15[_ofd * 4u + _of3], _oq8[_of3], _o38);
    }
    _o8v[_ofd] = _o38;
  }
  var g = _o14[0];
  var _ocp = _o13[0];
  for (var _of3 = 1u; _of3 <= 4u; _of3 = _of3 + 1u) {
    g = fma(_o14[_of3], _oq8[_of3], g);
    _ocp = fma(_o13[_of3], _oq8[_of3], _ocp);
  }
  let _ob8 = r * g;
  let _oet = (_od0 * r) * _ocp;
  _o4p[_oon][1] = _ob8;
  _o4p[_oon][2] = _o8v[0];
  var _okh = _oet;
  for (var _ofd = 1u; _ofd < _o16; _ofd = _ofd + 1u) {
    _o4p[_oon][_ofd + 2u] = _o8v[_ofd] * _okh;
    _okh = _okh * _oet;
  }
}
fn _ogr(_of3: u32) {
  for (var _ofd = 0u; _ofd < _o17; _ofd = _ofd + 1u) {
    _op7[_ofd] = _o4p[_of3][_ofd];
  }
  let _ocs = _op7[0];
  let _oll = fma(_ocs, -0.3, 0.3);
  let _olm = fma(_ocs, -5.0 / 21.0, 10.0 / 21.0);
  let _oln = fma(_ocs, -7.0 / 36.0, 21.0 / 36.0);
  _oo4[0] = 1.0;
  _oo4[1] = _ocs * (-1.0 / 3.0);
  _oo4[2] = _oo4[1] * _oll;
  _oo4[3] = _oo4[2] * _olm;
  _oo4[4] = _oo4[3] * _oln;
}
struct _o19 {
  _osh: f32,
  _oh0: f32,
  _okx: f32,
  _o84: f32,
  _osm: f32,
  _oo3: bool,
};
fn _o4x(_osh: f32) -> _o19 {
  let _ocs = _op7[0];
  var _oap: _o19;
  _oap._osh = _osh;
  let _oiq = _obu(fma(-_osh, _osh, 1.0), _o4);
  _oap._oh0 = log2(_oiq);
  _oap._okx = exp2((_ocs + 1.0) * _oap._oh0);
  var _o38 = _op7[1u + _o16];
  for (var _ofd = i32(_o16) - 1; _ofd >= 0; _ofd = _ofd - 1) {
    _o38 = fma(_o38, _osh, _op7[1 + _ofd]);
  }
  _oap._o84 = _oap._okx * _o38;
  let _orw = _osh * _osh;
  var _opv = _oo4[4];
  for (var _ohv = 3; _ohv >= 0; _ohv = _ohv - 1) {
    _opv = fma(_opv, _orw, _oo4[_ohv]);
  }
  _oap._oo3 = _osh <= _od;
  _oap._osm = select(_op7[1] - _oap._o84, _opv * _osh, _oap._oo3);
  return _oap;
}
fn _o41(_og1: f32) -> f32 {
  let _ocs = _op7[0];
  if (_og1 < _o2p) {
    let _o4g = fma(-0.3 * _og1, _og1, 1.0);
    let _okh = exp2(_ocs * log2(_o4g));
    return fma(5.0 / 9.0, _okh, 4.0 / 9.0);
  } else if (_og1 <= _oe) {
    let _osh = _og1 * _o9;
    return _o4x(_osh)._osm / _osh;
  }
  return _oe * _op7[1] / _og1;
}
fn _opc(_ol2: f32, _og5: f32, g: f32) -> f32 {
  let _ojb = _o41(_og5 / g);
  return _ol2 * (g * g / _ojb);
}
fn _o4y(_ogq: _o19, _odw: _o19, _oke: bool, _oi3: bool) -> f32 {
  let _o59 = _ogq._oo3 && _odw._oo3;
  let _oba = select(_ogq._osm, _odw._osm, _oke);
  let _obb = select(_odw._osm, _ogq._osm, _oke);
  let _ooo = _oba - _obb;
  let _oqo = _ogq._o84 - _odw._o84;
  let _oqn = select(-_oqo, _oqo, _oke);
  let cross = _odw._osm + _ogq._osm;
  return select(cross, select(_oqn, _ooo, _o59), _oke || _oi3);
}
struct _o1f {
  _ofm: bool,
  _oqt: f32,
  _oqi: f32,
};
fn _oay(_of3: u32, _og7: vec4f, _og8: vec4f, _ou0: vec4f, _oaz: f32, _ob5: f32,
                     _oag: f32, _oah: f32, _o4v: f32, _or4: bool) -> _o1f {
  var fragment = _o1f(false, 0.0, 0.5);
  let _okc = _ood(_og8.w);
  let _o8p = _ou0.z;
  let _om2 = abs(_og8.w);
  let _om3 = abs(_ou0.w);
  let _oax = _og7.z;
  let _oav = _og7.w;
  let _o9k = _og8.x;
  let _orj = _og8.y;
  var _oqu: f32;
  var _os7: f32;
  if (_okc) {
    let g = _om2 + 0.5 * (_om3 - _om2);
    let gg = g * g;
    let _o9j = fma(gg, fma(gg, _o9k, _o4v * _orj), _o4v * _o4v);
    let _oli = _oag - 0.5 * _oaz;
    let _olj = _oah - 0.5 * _ob5;
    let _o3c = _og7.x * _oli + _og7.y * _olj;
    let _o3d = _og7.y * _oli + _og8.z * _olj;
    let _ob4 = gg * (_oli * _o3c + _olj * _o3d) + _o4v * (_oli * _oli + _olj * _olj);
    let _odg = fma(gg, _oax, _o4v * _oav);
    let _omn = gg * (_oaz * _o3c + _ob5 * _o3d) + _o4v * (_oaz * _oli + _ob5 * _olj);
    let _omo = abs(_omn);
    var _oja: bool;
    if (2.0 * _omo < _odg) {
      _oja = (_ob4 - _o8p * _o9j) * _odg > _omn * _omn;
    } else {
      _oja = _ob4 - _omo + 0.25 * _odg > _o8p * _o9j;
    }
    if (_oja) {
      return fragment;
    }
    _ogr(_of3);
    _os7 = _opc(_ou0.x, _ou0.y, g);
    let _oep = inverseSqrt(_o9j);
    let _oem = _oep * _oep;
    let _ob3 = _ob4 * _oem;
    let _odd = _odg * _oem;
    let _omp = _omn * _oem;
    let _ol4 = _obu(_ob3, 0.0);
    let _oa9 = fma(_omp, _omp, _odd * (0.5 - _ol4));
    let _omr = sqrt(_obu(_oa9, 0.0));
    let _o51 = _omp + select(_omr, -_omr, _ood(_omp));
    var _olp = -1.0;
    var _olo = 1.0;
    var _opw = _oa9 >= 0.0;
    if (_o51 == 0.0) {
      _opw = _opw && _ol4 < 0.5;
    } else {
      let _oqh = (_ol4 - 0.5) / _o51;
      if (_odd > 0.0) {
        let _oqg = _o51 / _odd;
        _olp = _obv(_oqg, _oqh);
        _olo = _obu(_oqg, _oqh);
      } else if (_omp > 0.0) {
        _olp = _oqh;
      } else {
        _olo = _oqh;
      }
    }
    let _omt = _obu(_oa9, 0.5 * _o8 * _odd);
    if (!(_omt > 0.0) && (_olp > -0.5 || _olo < 0.5)) {
      _olp = 0.5;
      _olo = -0.5;
    }
    let _oqk = _obu(_olp, -0.5);
    let _oqj = _obv(_olo, 0.5);
    _opw = _opw && _oqj > _oqk;
    let _odk = select(0.0, 0.5 * (_oqj - _oqk), _opw);
    let _ohh = 0.5 * (_oqj + _oqk);
    let _oi4 = 0.774596669;
    let _ocs = _op7[0];
    var _orf: array<f32, 3>;
    var _ofx: array<f32, 3>;
    for (var _oe7 = 0; _oe7 < 3; _oe7 = _oe7 + 1) {
      _orf[_oe7] = fma(_odk, f32(_oe7 - 1) * _oi4, _ohh);
      let _ol1 = fma(_orf[_oe7], fma(_orf[_oe7], _odd, -2.0 * _omp), _ol4);
      let _o4g = fma(-2.0, _ol1, 1.0);
      _ofx[_oe7] = select(0.0, exp2(_ocs * log2(_o4g)), _opw && _o4g > 0.0);
    }
    let _ooa = 5.0 / 9.0;
    let _ohl = 8.0 / 9.0;
    let _ote = fma(_ooa, _ofx[0] + _ofx[2], _ohl * _ofx[1]);
    _oqu = _odk * _ote * _oep;
    if (_or4) {
      let _oht = fma(_ooa, fma(_orf[0], _ofx[0], _orf[2] * _ofx[2]), _ohl * _orf[1] * _ofx[1]);
      let _oil = select(0.0, _oht / _ote, _ote >= _o5);
      fragment._oqi = _obv(_obu(0.5 + _oil, 0.0), 1.0);
    }
  } else {
    let _o2v = _og7.x * _oag + _og7.y * _oah;
    let _o4w = _o4v * (_oaz * _oag + _ob5 * _oah);
    let _oql = _obv(_obu((_o2v + _o4w) * _og8.z, 0.0), 1.0);
    let g = _om2 + _oql * (_om3 - _om2);
    let gg = g * g;
    let _odg = fma(gg, _oax, _o4v * _oav);
    let _oma = fma(gg, _o2v, _o4w);
    let _o9j = fma(gg, fma(gg, _o9k, _o4v * _orj), _o4v * _o4v);
    let cross = _oag * _ob5 - _oah * _oaz;
    let _o8i = cross * cross;
    let _o8q = _o8p * _odg;
    if (_o8i > _o8q) {
      return fragment;
    }
    let _omb = _odg - _oma;
    let _oi2 = _obv(_oma, _omb);
    if (_oi2 < 0.0 && _oi2 * _oi2 > _o8q * _o9j) {
      return fragment;
    }
    _ogr(_of3);
    _os7 = _opc(_ou0.x, _ou0.y, g);
    let _oeq = inverseSqrt(_odg);
    let _on0 = _oeq * inverseSqrt(_o9j);
    let _oeo = _oeq * _oeq;
    let _ob3 = _o8i * _oeo;
    let _orx = _oma * _on0;
    let _ory = _omb * _on0;
    let a = fma(-2.0, _ob3, 1.0);
    let _okf = a > 0.0;
    let _o37 = select(1.0, a, _okf);
    let _ogt = log2(_o37);
    let _oes = inverseSqrt(0.5 * _o37);
    let _o5j = 0.5 * _o37 * _oes;
    let _osj = _obv(_obu(-_orx * _oes, -1.0), 1.0);
    let _osi = _obv(_obu(_ory * _oes, -1.0), 1.0);
    let _ogq = _o4x(abs(_osj));
    let _odw = _o4x(abs(_osi));
    let _oke = _osj >= 0.0;
    let _oi3 = _osi <= 0.0;
    let _o96 = _o4y(_ogq, _odw, _oke, _oi3);
    let _ogp = _okf && _o96 > 0.0;
    let _ocs = _op7[0];
    let _o36 = exp2(_ocs * _ogt);
    if (_or4) {
      let _og1 = _odg * _on0;
      let _oby = _oma * _oeo;
      let _o95 = select(0.0, _o96, _ogp);
      let _obz = _ogp && _og1 * (_o5j * _o95) >= _o5;
      let _o97 = select(1.0, _o95, _obz);
      let _o9c = _ogq._okx - _odw._okx;
      let _oil = select(0.0, _o5j * _o9c / (2.0 * (_ocs + 1.0) * _og1 * _o97), _obz);
      fragment._oqi = _obv(_obu(_oby + _oil, 0.0), 1.0);
    }
    let _og0 = _o5j * _o36 * _o96;
    _oqu = select(0.0, _og0 * _oeq, _ogp);
  }
  fragment._ofm = true;
  fragment._oqt = _os7 * _oqu;
  return fragment;
}
fn _or2(_oon: u32, _ois: vec3f, _om5: vec3f, _orw: f32) -> vec3f {
  let _ob7 = 12u * _oon;
  let _okb = vec3f(_oqz[_ob7], _oqz[_ob7 + 1u], _oqz[_ob7 + 2u]);
  let _ob8 = vec3f(_oqz[_ob7 + 3u], _oqz[_ob7 + 4u], _oqz[_ob7 + 5u]);
  let _ob9 = vec3f(_oqz[_ob7 + 6u], _oqz[_ob7 + 7u], _oqz[_ob7 + 8u]);
  let _omm = _oqz[_ob7 + 9u];
  let _oil = _ois - _okb;
  let _oig = _oil.x * _ob8.x + _oil.y * _ob8.y + _oil.z * _ob8.z;
  let _oih = _oil.x * _ob9.x + _oil.y * _ob9.y + _oil.z * _ob9.z;
  let _o8x = _om5.x * _ob8.x + _om5.y * _ob8.y + _om5.z * _ob8.z;
  let _o8y = _om5.x * _ob9.x + _om5.y * _ob9.y + _om5.z * _ob9.z;
  let _o3j = _o8x * _o8x + _o8y * _o8y;
  var _osh = 0.5;
  if (_o3j != 0.0 && _of0(_o3j) && _of0(_oig) && _of0(_oih)) {
    let _og3 = -(_oig * _o8x + _oih * _o8y) / _o3j;
    let _o5r = _oig + _og3 * _o8x;
    let _o5y = _oih + _og3 * _o8y;
    let _ol1 = _omm * _omm - (_o5r * _o5r + _o5y * _o5y);
    var _ojd = _o5r;
    var _oje = _o5y;
    if (_ol1 >= 0.0) {
      let _odm = sqrt(_ol1 / _o3j);
      if (_og3 - _odm > 0.0) {
        _ojd = _o5r - _odm * _o8x;
        _oje = _o5y - _odm * _o8y;
      } else if (_og3 + _odm > 0.0) {
        _ojd = _o5r + _odm * _o8x;
        _oje = _o5y + _odm * _o8y;
      }
    }
    if (_of0(_ojd) && _of0(_oje)) {
      _osh = atan2(_oje, _ojd) * 0.15915494309189535 + 0.5;
    }
  }
  let _o40 = i32(_o5a._o40);
  let _o3u = i32(_o5a._o3u);
  let x = _orw * f32(_o40 - 1);
  let _oe8 = min(i32(floor(x)), _o40 - 2);
  let wx = x - f32(_oe8);
  let y = _osh * f32(_o3u) - 0.5;
  let _ocm = floor(y);
  let _of4 = ((i32(_ocm) % _o3u) + _o3u) % _o3u;
  let _of5 = (_of4 + 1) % _o3u;
  let wy = y - _ocm;
  let _or1 = array<i32, 4>(_oe8 * _o3u + _of4, (_oe8 + 1) * _o3u + _of4,
                            _oe8 * _o3u + _of5, (_oe8 + 1) * _o3u + _of5);
  let _otd = array<f32, 4>((1.0 - wx) * (1.0 - wy), wx * (1.0 - wy),
                             (1.0 - wx) * wy, wx * wy);
  let _o4g = _oon * 3u * _o5a._o40 * _o5a._o3u;
  var _o7x = vec3f(0.0);
  for (var _o6p = 0u; _o6p < 3u; _o6p = _o6p + 1u) {
    var _osm = 0.0;
    for (var _ofd = 0u; _ofd < 4u; _ofd = _ofd + 1u) {
      _osm = _osm + _otd[_ofd] * _or0[_o4g + 3u * u32(_or1[_ofd]) + _o6p];
    }
    _o7x[_o6p] = _osm;
  }
  return _o7x;
}
@compute @workgroup_size(16, 16)
fn render_beta(@builtin(local_invocation_id) _ogs: vec3u,
               @builtin(local_invocation_index) _ogj: u32,
               @builtin(workgroup_id) _otg: vec3u) {
  let _oth = _o69._oth;
  let _odt = _o69._odt;
  let _or4 = _o5a._or4 != 0u;
  let _ojz = vec2u(_otg.x * 16u + _ogs.x, _otg.y * 16u + _ogs.y);
  let _oek = _ojz.x < _oth && _ojz.y < _odt;
  let _ok3 = vec2f(f32(_ojz.x), f32(_ojz.y));
  var _oa2 = !_oek;
  let _or7 = _otg.y * _o69._orb + _otg.x;
  let _olx = _oly[2u * _or7];
  let _olw = _oly[2u * _or7 + 1u];
  let _omv = (_olw - _olx + _of - 1u) / _of;
  var _org = i32(_olw - _olx);
  var _orl = 1.0;
  var _o7x = vec3f(0.0);
  var _om7 = vec3f(0.0);
  var _om5 = vec3f(0.0);
  if (_or4) {
    _om7 = _o69._o6c.xyz;
    let _oic = (2.0 * _ok3.x + 1.0) / f32(_oth) - 1.0;
    let _oid = (2.0 * _ok3.y + 1.0) / f32(_odt) - 1.0;
    let _on1 = (_oic - _o5a._okp) * _o5a._oqp;
    let _on2 = (_oid - _o5a._okq) * _o5a._oqq;
    let _on3 = 1.0;
    _om5 = vec3f(_osz(0u) * _on1 + _osz(1u) * _on2 + _osz(2u) * _on3,
                _osz(4u) * _on1 + _osz(5u) * _on2 + _osz(6u) * _on3,
                _osz(8u) * _on1 + _osz(9u) * _on2 + _osz(10u) * _on3);
  }
  for (var _oe7 = 0u; _oe7 < _omv; _oe7 = _oe7 + 1u) {
    if (_ogj == 0u) {
      atomicStore(&_oa4, 0u);
    }
    workgroupBarrier();
    if (_oa2) {
      atomicAdd(&_oa4, 1u);
    }
    workgroupBarrier();
    if (_ogj == 0u) {
      _oa3 = atomicLoad(&_oa4);
    }
    let _oi9 = workgroupUniformLoad(&_oa3);
    if (_oi9 == _of) {
      break;
    }
    let _okt = _oe7 * _of + _ogj;
    if (_olx + _okt < _olw) {
      let _o7w = _okd[_olx + _okt];
      _o4m[_ogj] = _o7w;
      let _omf = _oko[_o7w]._omf;
      _op5(_ogj, abs(_omf.x));
      let _o4v = _omf.z;
      _o4l[_ogj] = _o4v;
      _o4q[_ogj] = bitcast<i32>(_okn[_o7w].z);
      let _oqs = _oko[_o7w]._o3p;
      let ab = _oko[_o7w].ab;
      let _o2t = ab.xy;
      let _o46 = ab.zw;
      let _oaz = _o46.x - _o2t.x;
      let _ob5 = _o46.y - _o2t.y;
      let _o2w = _oqs.z * _oaz - _oqs.y * _ob5;
      let _o2x = _oqs.x * _ob5 - _oqs.y * _oaz;
      let _oax = _obu(_oaz * _o2w + _ob5 * _o2x, 0.0);
      let _oav = _oaz * _oaz + _ob5 * _ob5;
      let _o9k = _obu(_oqs.x * _oqs.z - _oqs.y * _oqs.y, 0.0);
      let _orj = _oqs.x + _oqs.z;
      if (_ood(_oqs.w)) {
        _o4n[_ogj] = vec4f(_oqs.z, -_oqs.y, _oax, _oav);
        _o4o[_ogj] = vec4f(_o9k, _orj, _oqs.x, _oqs.w);
      } else {
        _o4n[_ogj] = vec4f(_o2w, _o2x, _oax, _oav);
        _o4o[_ogj] = vec4f(_o9k, _orj, 1.0 / (_oax + _o4v * _oav), _oqs.w);
      }
      _o4h[_ogj] = _o2t;
      _o4k[_ogj] = vec2f(_oaz, _ob5);
      _o4i[_ogj] = _oko[_o7w]._o52;
    }
    workgroupBarrier();
    let _o4j = u32(min(i32(_of), _org));
    for (var _of3 = 0u; !_oa2 && _of3 < _o4j; _of3 = _of3 + 1u) {
      let _o2t = _o4h[_of3];
      let _oaj = _o4k[_of3];
      let fragment = _oay(_of3, _o4n[_of3], _o4o[_of3], _o4i[_of3], _oaj.x, _oaj.y,
                                       _ok3.x - _o2t.x, _ok3.y - _o2t.y, _o4l[_of3], _or4);
      if (!fragment._ofm) {
        continue;
      }
      let _o3j = _obv(1.0 - exp(-fragment._oqt), 0.9999);
      let _oqy = _orl * (1.0 - _o3j);
      if (_o3j < _o1o) {
        continue;
      }
      let _o6f = 3u * _o4m[_of3];
      var _o5j = vec3f(rgb[_o6f], rgb[_o6f + 1u], rgb[_o6f + 2u]);
      if (_or4) {
        let _oon = _o4q[_of3];
        if (_oon >= 0) {
          _o5j = _o5j + _or2(u32(_oon), _om7, _om5, fragment._oqi);
        }
      }
      _o7x = _o7x + _o5j * _o3j * _orl;
      _orl = _oqy;
      if (_oqy < 0.0001) {
        _oa2 = true;
      }
    }
    _org = _org - i32(_of);
  }
  if (_oek) {
    let _ok8 = _oth * _odt;
    let _ok0 = _oth * _ojz.y + _ojz.x;
    _oiw[_ok0] = _o7x.x + _orl * _o69._o4c.x;
    _oiw[_ok8 + _ok0] = _o7x.y + _orl * _o69._o4c.y;
    _oiw[2u * _ok8 + _ok0] = _o7x.z + _orl * _o69._o4c.z;
  }
}
