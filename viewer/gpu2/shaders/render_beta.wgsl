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
struct _on {
  _opc: f32,
  _opd: f32,
  _ojn: f32,
  _ojo: f32,
  _o3u: u32,
  _o3n: u32,
  _opp: u32,
  _oig: u32,
};
@group(0) @binding(0) var<storage, read> _okp: array<u32>;
@group(0) @binding(1) var<storage, read> _oj6: array<u32>;
@group(0) @binding(2) var<storage, read> _ojm: array<_o1v>;
@group(0) @binding(3) var<storage, read> rgb: array<f32>;
@group(0) @binding(4) var<storage, read> _ojl: array<vec4u>;
@group(0) @binding(5) var<storage, read> _opk: array<f32>;
@group(0) @binding(6) var<storage, read> _opl: array<f32>;
@group(0) @binding(7) var<storage, read_write> _oho: array<f32>;
@group(0) @binding(8) var<uniform> _o5x: _oo;
@group(0) @binding(9) var<uniform> _o4z: _on;
const _og: u32 = 256u;
const _o2n: f32 = 0.1;
const _o1j: f32 = 0.0;
const _o6: f32 = 1.0e-30;
const _o9: f32 = 1.0e-4;
const _oe: f32 = 0.1;
const _o5: f32 = 1.17549435e-38;
const _of: f32 = 1.41421356;
const _oa: f32 = 0.707106781;
const _o4: f32 = -3.1215594;
const _o3: f32 = 1.8495809;
const _o12: u32 = 6u;
const _o13: u32 = 8u;
const _o11 = array<f32, 24>(
  -1.0, 0.0, 0.0, 0.0,
  0.8639625, -0.080043316, 0.011840287, -0.00032925335,
  -0.65780294, 0.16117837, -0.025375213, 0.0017560583,
  0.40191287, -0.1712049, 0.028378023, -0.0027375722,
  -0.16230038, 0.09921428, -0.017412446, 0.0016617817,
  0.030476268, -0.023956835, 0.004615334, -0.00040338145);
const _o10 = array<f32, 5>(
  0.9317711, -0.04327248, 0.0059742285, 8.387385e-06, -1.3679006e-05);
const _oz = array<f32, 5>(
  1.0743953, 0.049604684, -0.005744186, -0.00030108364, 2.7100898e-05);
var<workgroup> _o4f: array<u32, 256>;
var<workgroup> _o4g: array<vec4f, 256>;
var<workgroup> _o4h: array<vec4f, 256>;
var<workgroup> _o4a: array<vec2f, 256>;
var<workgroup> _o4d: array<vec2f, 256>;
var<workgroup> _o4b: array<vec4f, 256>;
var<workgroup> _o4i: array<array<f32, 8>, 256>;
var<workgroup> _o4e: array<f32, 256>;
var<workgroup> _o4j: array<i32, 256>;
var<workgroup> _o9m: atomic<u32>;
var<workgroup> _o9l: u32;
var<private> _ony: array<f32, 8>;
var<private> _omw: array<f32, 5>;
fn _orm(_oed: u32) -> f32 {
  return _o5x._orh[_oed >> 2u][_oed & 3u];
}
fn _onw(_ond: u32, _obv: f32) {
  _o4i[_ond][0] = _obv;
  let _oc3 = _obv + 1.0;
  let r = inverseSqrt(_oc3);
  let z = fma(r, _o4, _o3);
  let _osq = z + z;
  var _oou: array<f32, 5>;
  _oou[0] = 1.0;
  _oou[1] = z;
  for (var _oe3 = 2u; _oe3 <= 4u; _oe3 = _oe3 + 1u) {
    _oou[_oe3] = fma(_osq, _oou[_oe3 - 1u], -_oou[_oe3 - 2u]);
  }
  var _o89: array<f32, 6>;
  for (var _oed = 0u; _oed < _o12; _oed = _oed + 1u) {
    var _o36 = _o11[_oed * 4u];
    for (var _oe3 = 1u; _oe3 <= 3u; _oe3 = _oe3 + 1u) {
      _o36 = fma(_o11[_oed * 4u + _oe3], _oou[_oe3], _o36);
    }
    _o89[_oed] = _o36;
  }
  var g = _o10[0];
  var _obt = _oz[0];
  for (var _oe3 = 1u; _oe3 <= 4u; _oe3 = _oe3 + 1u) {
    g = fma(_o10[_oe3], _oou[_oe3], g);
    _obt = fma(_oz[_oe3], _oou[_oe3], _obt);
  }
  let _oap = r * g;
  let _odt = (_oc3 * r) * _obt;
  _o4i[_ond][1] = _oap;
  _o4i[_ond][2] = _o89[0];
  var _oje = _odt;
  for (var _oed = 1u; _oed < _o12; _oed = _oed + 1u) {
    _o4i[_ond][_oed + 2u] = _o89[_oed] * _oje;
    _oje = _oje * _odt;
  }
}
fn _ofp(_oe3: u32) {
  for (var _oed = 0u; _oed < _o13; _oed = _oed + 1u) {
    _ony[_oed] = _o4i[_oe3][_oed];
  }
  let _obv = _ony[0];
  let _okd = fma(_obv, -0.3, 0.3);
  let _oke = fma(_obv, -5.0 / 21.0, 10.0 / 21.0);
  let _okf = fma(_obv, -7.0 / 36.0, 21.0 / 36.0);
  _omw[0] = 1.0;
  _omw[1] = _obv * (-1.0 / 3.0);
  _omw[2] = _omw[1] * _okd;
  _omw[3] = _omw[2] * _oke;
  _omw[4] = _omw[3] * _okf;
}
struct _o15 {
  _or2: f32,
  _ofx: f32,
  _ojv: f32,
  _o79: f32,
  _or7: f32,
  _omv: bool,
};
fn _o4p(_or2: f32) -> _o15 {
  let _obv = _ony[0];
  var _oa5: _o15;
  _oa5._or2 = _or2;
  let _ohj = _obd(fma(-_or2, _or2, 1.0), _o5);
  _oa5._ofx = log2(_ohj);
  _oa5._ojv = exp2((_obv + 1.0) * _oa5._ofx);
  var _o36 = _ony[1u + _o12];
  for (var _oed = i32(_o12) - 1; _oed >= 0; _oed = _oed - 1) {
    _o36 = fma(_o36, _or2, _ony[1 + _oed]);
  }
  _oa5._o79 = _oa5._ojv * _o36;
  let _oqg = _or2 * _or2;
  var _ooh = _omw[4];
  for (var _ogq = 3; _ogq >= 0; _ogq = _ogq - 1) {
    _ooh = fma(_ooh, _oqg, _omw[_ogq]);
  }
  _oa5._omv = _or2 <= _oe;
  _oa5._or7 = select(_ony[1] - _oa5._o79, _ooh * _or2, _oa5._omv);
  return _oa5;
}
fn _o3v(_oex: f32) -> f32 {
  let _obv = _ony[0];
  if (_oex < _o2n) {
    let _o49 = fma(-0.3 * _oex, _oex, 1.0);
    let _oje = exp2(_obv * log2(_o49));
    return fma(5.0 / 9.0, _oje, 4.0 / 9.0);
  } else if (_oex <= _of) {
    let _or2 = _oex * _oa;
    return _o4p(_or2)._or7 / _or2;
  }
  return _of * _ony[1] / _oex;
}
fn _oo3(_ojz: f32, _of1: f32, g: f32) -> f32 {
  let _oi3 = _o3v(_of1 / g);
  return _ojz * (g * g / _oi3);
}
fn _o4q(_ofo: _o15, _ocx: _o15, _ojb: bool, _ogw: bool) -> f32 {
  let _o4y = _ofo._omv && _ocx._omv;
  let _oar = select(_ofo._or7, _ocx._or7, _ojb);
  let _oas = select(_ocx._or7, _ofo._or7, _ojb);
  let _one = _oar - _oas;
  let _opa = _ofo._o79 - _ocx._o79;
  let _op9 = select(-_opa, _opa, _ojb);
  let cross = _ocx._or7 + _ofo._or7;
  return select(cross, select(_op9, _one, _o4y), _ojb || _ogw);
}
struct _o19 {
  _oek: bool,
  _opf: f32,
  _op4: f32,
};
fn _oaf(_oe3: u32, _of3: vec4f, _of4: vec4f, _osr: vec4f, _oag: f32, _oam: f32,
                     _o9w: f32, _o9x: f32, _o4n: f32, _opp: bool) -> _o19 {
  var fragment = _o19(false, 0.0, 0.5);
  let _oj5 = _on4(_of4.w);
  let _o81 = _osr.z;
  let _okt = abs(_of4.w);
  let _oku = abs(_osr.w);
  let _oae = _of3.z;
  let _oab = _of3.w;
  let _o8z = _of4.x;
  let _oq4 = _of4.y;
  var _opg: f32;
  var _oqr: f32;
  if (_oj5) {
    let g = _okt + 0.5 * (_oku - _okt);
    let gg = g * g;
    let _o8y = fma(gg, fma(gg, _o8z, _o4n * _oq4), _o4n * _o4n);
    let _ok8 = _o9w - 0.5 * _oag;
    let _ok9 = _o9x - 0.5 * _oam;
    let _o3a = _of3.x * _ok8 + _of3.y * _ok9;
    let _o3b = _of3.y * _ok8 + _of4.z * _ok9;
    let _oal = gg * (_ok8 * _o3a + _ok9 * _o3b) + _o4n * (_ok8 * _ok8 + _ok9 * _ok9);
    let _oci = fma(gg, _oae, _o4n * _oab);
    let _olg = gg * (_oag * _o3a + _oam * _o3b) + _o4n * (_oag * _ok8 + _oam * _ok9);
    let _olh = abs(_olg);
    var _oi2: bool;
    if (2.0 * _olh < _oci) {
      _oi2 = (_oal - _o81 * _o8y) * _oci > _olg * _olg;
    } else {
      _oi2 = _oal - _olh + 0.25 * _oci > _o81 * _o8y;
    }
    if (_oi2) {
      return fragment;
    }
    _ofp(_oe3);
    _oqr = _oo3(_osr.x, _osr.y, g);
    let _odp = inverseSqrt(_o8y);
    let _odm = _odp * _odp;
    let _oak = _oal * _odm;
    let _och = _oci * _odm;
    let _oli = _olg * _odm;
    let _ok0 = _obd(_oak, 0.0);
    let _o9q = fma(_oli, _oli, _och * (0.5 - _ok0));
    let _olj = sqrt(_obd(_o9q, 0.0));
    let _o4t = _oli + select(_olj, -_olj, _on4(_oli));
    var _okh = -1.0;
    var _okg = 1.0;
    var _ooi = _o9q >= 0.0;
    if (_o4t == 0.0) {
      _ooi = _ooi && _ok0 < 0.5;
    } else {
      let _op3 = (_ok0 - 0.5) / _o4t;
      if (_och > 0.0) {
        let _op2 = _o4t / _och;
        _okh = _obe(_op2, _op3);
        _okg = _obd(_op2, _op3);
      } else if (_oli > 0.0) {
        _okh = _op3;
      } else {
        _okg = _op3;
      }
    }
    let _oll = _obd(_o9q, 0.5 * _o9 * _och);
    if (!(_oll > 0.0) && (_okh > -0.5 || _okg < 0.5)) {
      _okh = 0.5;
      _okg = -0.5;
    }
    let _op6 = _obd(_okh, -0.5);
    let _op5 = _obe(_okg, 0.5);
    _ooi = _ooi && _op5 > _op6;
    let _ocl = select(0.0, 0.5 * (_op5 - _op6), _ooi);
    let _ogd = 0.5 * (_op5 + _op6);
    let _ogx = 0.774596669;
    let _obv = _ony[0];
    var _opz: array<f32, 3>;
    var _oeu: array<f32, 3>;
    for (var _od7 = 0; _od7 < 3; _od7 = _od7 + 1) {
      _opz[_od7] = fma(_ocl, f32(_od7 - 1) * _ogx, _ogd);
      let _ojy = fma(_opz[_od7], fma(_opz[_od7], _och, -2.0 * _oli), _ok0);
      let _o49 = fma(-2.0, _ojy, 1.0);
      _oeu[_od7] = select(0.0, exp2(_obv * log2(_o49)), _ooi && _o49 > 0.0);
    }
    let _on2 = 5.0 / 9.0;
    let _ogh = 8.0 / 9.0;
    let _os3 = fma(_on2, _oeu[0] + _oeu[2], _ogh * _oeu[1]);
    _opg = _ocl * _os3 * _odp;
    if (_opp) {
      let _ogo = fma(_on2, fma(_opz[0], _oeu[0], _opz[2] * _oeu[2]), _ogh * _opz[1] * _oeu[1]);
      let _ohd = select(0.0, _ogo / _os3, _os3 >= _o6);
      fragment._op4 = _obe(_obd(0.5 + _ohd, 0.0), 1.0);
    }
  } else {
    let _o2t = _of3.x * _o9w + _of3.y * _o9x;
    let _o4o = _o4n * (_oag * _o9w + _oam * _o9x);
    let _op7 = _obe(_obd((_o2t + _o4o) * _of4.z, 0.0), 1.0);
    let g = _okt + _op7 * (_oku - _okt);
    let gg = g * g;
    let _oci = fma(gg, _oae, _o4n * _oab);
    let _ol1 = fma(gg, _o2t, _o4o);
    let _o8y = fma(gg, fma(gg, _o8z, _o4n * _oq4), _o4n * _o4n);
    let cross = _o9w * _oam - _o9x * _oag;
    let _o7t = cross * cross;
    let _o82 = _o81 * _oci;
    if (_o7t > _o82) {
      return fragment;
    }
    let _ol2 = _oci - _ol1;
    let _ogv = _obe(_ol1, _ol2);
    if (_ogv < 0.0 && _ogv * _ogv > _o82 * _o8y) {
      return fragment;
    }
    _ofp(_oe3);
    _oqr = _oo3(_osr.x, _osr.y, g);
    let _odq = inverseSqrt(_oci);
    let _olt = _odq * inverseSqrt(_o8y);
    let _odo = _odq * _odq;
    let _oak = _o7t * _odo;
    let _oqh = _ol1 * _olt;
    let _oqi = _ol2 * _olt;
    let a = fma(-2.0, _oak, 1.0);
    let _ojc = a > 0.0;
    let _o35 = select(1.0, a, _ojc);
    let _ofr = log2(_o35);
    let _ods = inverseSqrt(0.5 * _o35);
    let _o58 = 0.5 * _o35 * _ods;
    let _or4 = _obe(_obd(-_oqh * _ods, -1.0), 1.0);
    let _or3 = _obe(_obd(_oqi * _ods, -1.0), 1.0);
    let _ofo = _o4p(abs(_or4));
    let _ocx = _o4p(abs(_or3));
    let _ojb = _or4 >= 0.0;
    let _ogw = _or3 <= 0.0;
    let _o8k = _o4q(_ofo, _ocx, _ojb, _ogw);
    let _ofm = _ojc && _o8k > 0.0;
    let _obv = _ony[0];
    let _o34 = exp2(_obv * _ofr);
    if (_opp) {
      let _oex = _oci * _olt;
      let _obg = _ol1 * _odo;
      let _o8j = select(0.0, _o8k, _ofm);
      let _obh = _ofm && _oex * (_o58 * _o8j) >= _o6;
      let _o8l = select(1.0, _o8j, _obh);
      let _o8t = _ofo._ojv - _ocx._ojv;
      let _ohd = select(0.0, _o58 * _o8t / (2.0 * (_obv + 1.0) * _oex * _o8l), _obh);
      fragment._op4 = _obe(_obd(_obg + _ohd, 0.0), 1.0);
    }
    let _oev = _o58 * _o34 * _o8k;
    _opg = select(0.0, _oev * _odq, _ofm);
  }
  fragment._oek = true;
  fragment._opf = _oqr * _opg;
  return fragment;
}
fn _opn(_ond: u32, _ohk: vec3f, _okw: vec3f, _oqg: f32) -> vec3f {
  let _oao = 12u * _ond;
  let _oj4 = vec3f(_opk[_oao], _opk[_oao + 1u], _opk[_oao + 2u]);
  let _oap = vec3f(_opk[_oao + 3u], _opk[_oao + 4u], _opk[_oao + 5u]);
  let _oaq = vec3f(_opk[_oao + 6u], _opk[_oao + 7u], _opk[_oao + 8u]);
  let _olf = _opk[_oao + 9u];
  let _ohd = _ohk - _oj4;
  let _oh9 = _ohd.x * _oap.x + _ohd.y * _oap.y + _ohd.z * _oap.z;
  let _oha = _ohd.x * _oaq.x + _ohd.y * _oaq.y + _ohd.z * _oaq.z;
  let _o8b = _okw.x * _oap.x + _okw.y * _oap.y + _okw.z * _oap.z;
  let _o8c = _okw.x * _oaq.x + _okw.y * _oaq.y + _okw.z * _oaq.z;
  let _o3e = _o8b * _o8b + _o8c * _o8c;
  var _or2 = 0.5;
  if (_o3e != 0.0 && _odz(_o3e) && _odz(_oh9) && _odz(_oha)) {
    let _oez = -(_oh9 * _o8b + _oha * _o8c) / _o3e;
    let _o5g = _oh9 + _oez * _o8b;
    let _o5n = _oha + _oez * _o8c;
    let _ojy = _olf * _olf - (_o5g * _o5g + _o5n * _o5n);
    var _oi5 = _o5g;
    var _oi6 = _o5n;
    if (_ojy >= 0.0) {
      let _ocm = sqrt(_ojy / _o3e);
      if (_oez - _ocm > 0.0) {
        _oi5 = _o5g - _ocm * _o8b;
        _oi6 = _o5n - _ocm * _o8c;
      } else if (_oez + _ocm > 0.0) {
        _oi5 = _o5g + _ocm * _o8b;
        _oi6 = _o5n + _ocm * _o8c;
      }
    }
    if (_odz(_oi5) && _odz(_oi6)) {
      _or2 = atan2(_oi6, _oi5) * 0.15915494309189535 + 0.5;
    }
  }
  let _o3u = i32(_o4z._o3u);
  let _o3n = i32(_o4z._o3n);
  let x = _oqg * f32(_o3u - 1);
  let _od8 = min(i32(floor(x)), _o3u - 2);
  let wx = x - f32(_od8);
  let y = _or2 * f32(_o3n) - 0.5;
  let _obq = floor(y);
  let _oe4 = ((i32(_obq) % _o3n) + _o3n) % _o3n;
  let _oe5 = (_oe4 + 1) % _o3n;
  let wy = y - _obq;
  let _opm = array<i32, 4>(_od8 * _o3n + _oe4, (_od8 + 1) * _o3n + _oe4,
                            _od8 * _o3n + _oe5, (_od8 + 1) * _o3n + _oe5);
  let _os2 = array<f32, 4>((1.0 - wx) * (1.0 - wy), wx * (1.0 - wy),
                             (1.0 - wx) * wy, wx * wy);
  let _o49 = _ond * 3u * _o4z._o3u * _o4z._o3n;
  var _o72 = vec3f(0.0);
  for (var _o6g = 0u; _o6g < 3u; _o6g = _o6g + 1u) {
    var _or7 = 0.0;
    for (var _oed = 0u; _oed < 4u; _oed = _oed + 1u) {
      _or7 = _or7 + _os2[_oed] * _opl[_o49 + 3u * u32(_opm[_oed]) + _o6g];
    }
    _o72[_o6g] = _or7;
  }
  return _o72;
}
@compute @workgroup_size(16, 16)
fn render_beta(@builtin(local_invocation_id) _ofq: vec3u,
               @builtin(local_invocation_index) _ofg: u32,
               @builtin(workgroup_id) _os5: vec3u) {
  let _os6 = _o5x._os6;
  let _ocv = _o5x._ocv;
  let _opp = _o4z._opp != 0u;
  let _oit = vec2u(_os5.x * 16u + _ofq.x, _os5.y * 16u + _ofq.y);
  let _odk = _oit.x < _os6 && _oit.y < _ocv;
  let _oiw = vec2f(f32(_oit.x), f32(_oit.y));
  var _o9k = !_odk;
  let _ops = _os5.y * _o5x._opw + _os5.x;
  let _oko = _okp[2u * _ops];
  let _okn = _okp[2u * _ops + 1u];
  let _oln = (_okn - _oko + _og - 1u) / _og;
  var _oq0 = i32(_okn - _oko);
  var _oq6 = 1.0;
  var _o72 = vec3f(0.0);
  var _oky = vec3f(0.0);
  var _okw = vec3f(0.0);
  if (_opp) {
    _oky = _o5x._o60.xyz;
    let _oh5 = (2.0 * _oiw.x + 1.0) / f32(_os6) - 1.0;
    let _oh6 = (2.0 * _oiw.y + 1.0) / f32(_ocv) - 1.0;
    let _olu = (_oh5 - _o4z._ojn) * _o4z._opc;
    let _olv = (_oh6 - _o4z._ojo) * _o4z._opd;
    let _olw = 1.0;
    _okw = vec3f(_orm(0u) * _olu + _orm(1u) * _olv + _orm(2u) * _olw,
                _orm(4u) * _olu + _orm(5u) * _olv + _orm(6u) * _olw,
                _orm(8u) * _olu + _orm(9u) * _olv + _orm(10u) * _olw);
  }
  for (var _od7 = 0u; _od7 < _oln; _od7 = _od7 + 1u) {
    if (_ofg == 0u) {
      atomicStore(&_o9m, 0u);
    }
    workgroupBarrier();
    if (_o9k) {
      atomicAdd(&_o9m, 1u);
    }
    workgroupBarrier();
    if (_ofg == 0u) {
      _o9l = atomicLoad(&_o9m);
    }
    let _oh2 = workgroupUniformLoad(&_o9l);
    if (_oh2 == _og) {
      break;
    }
    let _ojr = _od7 * _og + _ofg;
    if (_oko + _ojr < _okn) {
      let _o71 = _oj6[_oko + _ojr];
      _o4f[_ofg] = _o71;
      let _ol7 = _ojm[_o71]._ol7;
      _onw(_ofg, abs(_ol7.x));
      let _o4n = _ol7.z;
      _o4e[_ofg] = _o4n;
      _o4j[_ofg] = bitcast<i32>(_ojl[_o71].z);
      let _ope = _ojm[_o71]._o3i;
      let ab = _ojm[_o71].ab;
      let _o2r = ab.xy;
      let _o40 = ab.zw;
      let _oag = _o40.x - _o2r.x;
      let _oam = _o40.y - _o2r.y;
      let _o2u = _ope.z * _oag - _ope.y * _oam;
      let _o2v = _ope.x * _oam - _ope.y * _oag;
      let _oae = _obd(_oag * _o2u + _oam * _o2v, 0.0);
      let _oab = _oag * _oag + _oam * _oam;
      let _o8z = _obd(_ope.x * _ope.z - _ope.y * _ope.y, 0.0);
      let _oq4 = _ope.x + _ope.z;
      if (_on4(_ope.w)) {
        _o4g[_ofg] = vec4f(_ope.z, -_ope.y, _oae, _oab);
        _o4h[_ofg] = vec4f(_o8z, _oq4, _ope.x, _ope.w);
      } else {
        _o4g[_ofg] = vec4f(_o2u, _o2v, _oae, _oab);
        _o4h[_ofg] = vec4f(_o8z, _oq4, 1.0 / (_oae + _o4n * _oab), _ope.w);
      }
      _o4a[_ofg] = _o2r;
      _o4d[_ofg] = vec2f(_oag, _oam);
      _o4b[_ofg] = _ojm[_o71]._o4u;
    }
    workgroupBarrier();
    let _o4c = u32(min(i32(_og), _oq0));
    for (var _oe3 = 0u; !_o9k && _oe3 < _o4c; _oe3 = _oe3 + 1u) {
      let _o2r = _o4a[_oe3];
      let _o9z = _o4d[_oe3];
      let fragment = _oaf(_oe3, _o4g[_oe3], _o4h[_oe3], _o4b[_oe3], _o9z.x, _o9z.y,
                                       _oiw.x - _o2r.x, _oiw.y - _o2r.y, _o4e[_oe3], _opp);
      if (!fragment._oek) {
        continue;
      }
      let _o3e = _obe(1.0 - exp(-fragment._opf), 0.9999);
      let _opj = _oq6 * (1.0 - _o3e);
      if (_o3e < _o1j) {
        continue;
      }
      let _o64 = 3u * _o4f[_oe3];
      var _o58 = vec3f(rgb[_o64], rgb[_o64 + 1u], rgb[_o64 + 2u]);
      if (_opp) {
        let _ond = _o4j[_oe3];
        if (_ond >= 0) {
          _o58 = _o58 + _opn(u32(_ond), _oky, _okw, fragment._op4);
        }
      }
      _o72 = _o72 + _o58 * _o3e * _oq6;
      _oq6 = _opj;
      if (_opj < 0.0001) {
        _o9k = true;
      }
    }
    _oq0 = _oq0 - i32(_og);
  }
  if (_odk) {
    let _oj1 = _os6 * _ocv;
    let _oiu = _os6 * _oit.y + _oit.x;
    _oho[_oiu] = _o72.x + _oq6 * _o5x._o46.x;
    _oho[_oj1 + _oiu] = _o72.y + _oq6 * _o5x._o46.y;
    _oho[2u * _oj1 + _oiu] = _o72.z + _oq6 * _o5x._o46.z;
  }
}
