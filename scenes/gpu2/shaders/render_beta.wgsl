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
struct _om {
  _opg: f32,
  _oph: f32,
  _ojp: f32,
  _ojq: f32,
  _o3p: u32,
  _o3j: u32,
  _opv: u32,
  _oio: u32,
};
@group(0) @binding(0) var<storage, read> _oku: array<u32>;
@group(0) @binding(1) var<storage, read> _ojd: array<u32>;
@group(0) @binding(2) var<storage, read> _ojo: array<_o1r>;
@group(0) @binding(3) var<storage, read> rgb: array<f32>;
@group(0) @binding(4) var<storage, read> _ojn: array<vec4u>;
@group(0) @binding(5) var<storage, read> _opq: array<f32>;
@group(0) @binding(6) var<storage, read> _opr: array<f32>;
@group(0) @binding(7) var<storage, read_write> _ohx: array<f32>;
@group(0) @binding(8) var<uniform> _o5v: _oo;
@group(0) @binding(9) var<uniform> _o4x: _om;
const _of: u32 = 256u;
const _o2i: f32 = 0.1;
const _o1i: f32 = 0.0;
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
var<workgroup> _o4b: array<u32, 256>;
var<workgroup> _o4c: array<vec4f, 256>;
var<workgroup> _o4d: array<vec4f, 256>;
var<workgroup> _o46: array<vec2f, 256>;
var<workgroup> _o49: array<vec2f, 256>;
var<workgroup> _o47: array<vec4f, 256>;
var<workgroup> _o4e: array<array<f32, 8>, 256>;
var<workgroup> _o4a: array<f32, 256>;
var<workgroup> _o4f: array<i32, 256>;
var<workgroup> _o9q: atomic<u32>;
var<workgroup> _o9p: u32;
var<private> _oo1: array<f32, 8>;
var<private> _omz: array<f32, 5>;
fn _orp(_oei: u32) -> f32 {
  return _o5v._ork[_oei >> 2u][_oei & 3u];
}
fn _onz(_oni: u32, _oby: f32) {
  _o4e[_oni][0] = _oby;
  let _oc6 = _oby + 1.0;
  let r = inverseSqrt(_oc6);
  let z = fma(r, _o3, _o2);
  let _osp = z + z;
  var _ooz: array<f32, 5>;
  _ooz[0] = 1.0;
  _ooz[1] = z;
  for (var _oe8 = 2u; _oe8 <= 4u; _oe8 = _oe8 + 1u) {
    _ooz[_oe8] = fma(_osp, _ooz[_oe8 - 1u], -_ooz[_oe8 - 2u]);
  }
  var _o8h: array<f32, 6>;
  for (var _oei = 0u; _oei < _o16; _oei = _oei + 1u) {
    var _o31 = _o15[_oei * 4u];
    for (var _oe8 = 1u; _oe8 <= 3u; _oe8 = _oe8 + 1u) {
      _o31 = fma(_o15[_oei * 4u + _oe8], _ooz[_oe8], _o31);
    }
    _o8h[_oei] = _o31;
  }
  var g = _o14[0];
  var _obw = _o13[0];
  for (var _oe8 = 1u; _oe8 <= 4u; _oe8 = _oe8 + 1u) {
    g = fma(_o14[_oe8], _ooz[_oe8], g);
    _obw = fma(_o13[_oe8], _ooz[_oe8], _obw);
  }
  let _oas = r * g;
  let _ody = (_oc6 * r) * _obw;
  _o4e[_oni][1] = _oas;
  _o4e[_oni][2] = _o8h[0];
  var _ojh = _ody;
  for (var _oei = 1u; _oei < _o16; _oei = _oei + 1u) {
    _o4e[_oni][_oei + 2u] = _o8h[_oei] * _ojh;
    _ojh = _ojh * _ody;
  }
}
fn _oft(_oe8: u32) {
  for (var _oei = 0u; _oei < _o17; _oei = _oei + 1u) {
    _oo1[_oei] = _o4e[_oe8][_oei];
  }
  let _oby = _oo1[0];
  let _oki = fma(_oby, -0.3, 0.3);
  let _okj = fma(_oby, -5.0 / 21.0, 10.0 / 21.0);
  let _okk = fma(_oby, -7.0 / 36.0, 21.0 / 36.0);
  _omz[0] = 1.0;
  _omz[1] = _oby * (-1.0 / 3.0);
  _omz[2] = _omz[1] * _oki;
  _omz[3] = _omz[2] * _okj;
  _omz[4] = _omz[3] * _okk;
}
struct _o19 {
  _or7: f32,
  _og1: f32,
  _ojx: f32,
  _o7q: f32,
  _orc: f32,
  _omy: bool,
};
fn _o4m(_or7: f32) -> _o19 {
  let _oby = _oo1[0];
  var _oa9: _o19;
  _oa9._or7 = _or7;
  let _ohr = _obe(fma(-_or7, _or7, 1.0), _o4);
  _oa9._og1 = log2(_ohr);
  _oa9._ojx = exp2((_oby + 1.0) * _oa9._og1);
  var _o31 = _oo1[1u + _o16];
  for (var _oei = i32(_o16) - 1; _oei >= 0; _oei = _oei - 1) {
    _o31 = fma(_o31, _or7, _oo1[1 + _oei]);
  }
  _oa9._o7q = _oa9._ojx * _o31;
  let _oqm = _or7 * _or7;
  var _oom = _omz[4];
  for (var _ogw = 3; _ogw >= 0; _ogw = _ogw - 1) {
    _oom = fma(_oom, _oqm, _omz[_ogw]);
  }
  _oa9._omy = _or7 <= _od;
  _oa9._orc = select(_oo1[1] - _oa9._o7q, _oom * _or7, _oa9._omy);
  return _oa9;
}
fn _o3q(_of3: f32) -> f32 {
  let _oby = _oo1[0];
  if (_of3 < _o2i) {
    let _o45 = fma(-0.3 * _of3, _of3, 1.0);
    let _ojh = exp2(_oby * log2(_o45));
    return fma(5.0 / 9.0, _ojh, 4.0 / 9.0);
  } else if (_of3 <= _oe) {
    let _or7 = _of3 * _o9;
    return _o4m(_or7)._orc / _or7;
  }
  return _oe * _oo1[1] / _of3;
}
fn _oo6(_ok2: f32, _of7: f32, g: f32) -> f32 {
  let _oic = _o3q(_of7 / g);
  return _ok2 * (g * g / _oic);
}
fn _o4n(_ofs: _o19, _od1: _o19, _oje: bool, _oh4: bool) -> f32 {
  let _o4w = _ofs._omy && _od1._omy;
  let _oau = select(_ofs._orc, _od1._orc, _oje);
  let _oav = select(_od1._orc, _ofs._orc, _oje);
  let _onj = _oau - _oav;
  let _opf = _ofs._o7q - _od1._o7q;
  let _ope = select(-_opf, _opf, _oje);
  let cross = _od1._orc + _ofs._orc;
  return select(cross, select(_ope, _onj, _o4w), _oje || _oh4);
}
struct _o1c {
  _oer: bool,
  _opk: f32,
  _op9: f32,
};
fn _oai(_oe8: u32, _of9: vec4f, _ofa: vec4f, _osq: vec4f, _oaj: f32, _oap: f32,
                     _oa1: f32, _oa2: f32, _o4k: f32, _opv: bool) -> _o1c {
  var fragment = _o1c(false, 0.0, 0.5);
  let _ojc = _on8(_ofa.w);
  let _o8b = _osq.z;
  let _oky = abs(_ofa.w);
  let _okz = abs(_osq.w);
  let _oah = _of9.z;
  let _oaf = _of9.w;
  let _o96 = _ofa.x;
  let _oq9 = _ofa.y;
  var _opl: f32;
  var _oqx: f32;
  if (_ojc) {
    let g = _oky + 0.5 * (_okz - _oky);
    let gg = g * g;
    let _o95 = fma(gg, fma(gg, _o96, _o4k * _oq9), _o4k * _o4k);
    let _okf = _oa1 - 0.5 * _oaj;
    let _okg = _oa2 - 0.5 * _oap;
    let _o35 = _of9.x * _okf + _of9.y * _okg;
    let _o36 = _of9.y * _okf + _ofa.z * _okg;
    let _oao = gg * (_okf * _o35 + _okg * _o36) + _o4k * (_okf * _okf + _okg * _okg);
    let _ocl = fma(gg, _oah, _o4k * _oaf);
    let _oli = gg * (_oaj * _o35 + _oap * _o36) + _o4k * (_oaj * _okf + _oap * _okg);
    let _olj = abs(_oli);
    var _oib: bool;
    if (2.0 * _olj < _ocl) {
      _oib = (_oao - _o8b * _o95) * _ocl > _oli * _oli;
    } else {
      _oib = _oao - _olj + 0.25 * _ocl > _o8b * _o95;
    }
    if (_oib) {
      return fragment;
    }
    _oft(_oe8);
    _oqx = _oo6(_osq.x, _osq.y, g);
    let _odu = inverseSqrt(_o95);
    let _odr = _odu * _odu;
    let _oan = _oao * _odr;
    let _oci = _ocl * _odr;
    let _olk = _oli * _odr;
    let _ok4 = _obe(_oan, 0.0);
    let _o9v = fma(_olk, _olk, _oci * (0.5 - _ok4));
    let _olm = sqrt(_obe(_o9v, 0.0));
    let _o4q = _olk + select(_olm, -_olm, _on8(_olk));
    var _okm = -1.0;
    var _okl = 1.0;
    var _oon = _o9v >= 0.0;
    if (_o4q == 0.0) {
      _oon = _oon && _ok4 < 0.5;
    } else {
      let _op8 = (_ok4 - 0.5) / _o4q;
      if (_oci > 0.0) {
        let _op7 = _o4q / _oci;
        _okm = _obf(_op7, _op8);
        _okl = _obe(_op7, _op8);
      } else if (_olk > 0.0) {
        _okm = _op8;
      } else {
        _okl = _op8;
      }
    }
    let _olo = _obe(_o9v, 0.5 * _o8 * _oci);
    if (!(_olo > 0.0) && (_okm > -0.5 || _okl < 0.5)) {
      _okm = 0.5;
      _okl = -0.5;
    }
    let _opb = _obe(_okm, -0.5);
    let _opa = _obf(_okl, 0.5);
    _oon = _oon && _opa > _opb;
    let _ocp = select(0.0, 0.5 * (_opa - _opb), _oon);
    let _ogi = 0.5 * (_opa + _opb);
    let _oh5 = 0.774596669;
    let _oby = _oo1[0];
    var _oq5: array<f32, 3>;
    var _of1: array<f32, 3>;
    for (var _odc = 0; _odc < 3; _odc = _odc + 1) {
      _oq5[_odc] = fma(_ocp, f32(_odc - 1) * _oh5, _ogi);
      let _ok1 = fma(_oq5[_odc], fma(_oq5[_odc], _oci, -2.0 * _olk), _ok4);
      let _o45 = fma(-2.0, _ok1, 1.0);
      _of1[_odc] = select(0.0, exp2(_oby * log2(_o45)), _oon && _o45 > 0.0);
    }
    let _on5 = 5.0 / 9.0;
    let _ogm = 8.0 / 9.0;
    let _os4 = fma(_on5, _of1[0] + _of1[2], _ogm * _of1[1]);
    _opl = _ocp * _os4 * _odu;
    if (_opv) {
      let _ogu = fma(_on5, fma(_oq5[0], _of1[0], _oq5[2] * _of1[2]), _ogm * _oq5[1] * _of1[1]);
      let _ohm = select(0.0, _ogu / _os4, _os4 >= _o5);
      fragment._op9 = _obf(_obe(0.5 + _ohm, 0.0), 1.0);
    }
  } else {
    let _o2o = _of9.x * _oa1 + _of9.y * _oa2;
    let _o4l = _o4k * (_oaj * _oa1 + _oap * _oa2);
    let _opc = _obf(_obe((_o2o + _o4l) * _ofa.z, 0.0), 1.0);
    let g = _oky + _opc * (_okz - _oky);
    let gg = g * g;
    let _ocl = fma(gg, _oah, _o4k * _oaf);
    let _ol5 = fma(gg, _o2o, _o4l);
    let _o95 = fma(gg, fma(gg, _o96, _o4k * _oq9), _o4k * _o4k);
    let cross = _oa1 * _oap - _oa2 * _oaj;
    let _o84 = cross * cross;
    let _o8c = _o8b * _ocl;
    if (_o84 > _o8c) {
      return fragment;
    }
    let _ol6 = _ocl - _ol5;
    let _oh3 = _obf(_ol5, _ol6);
    if (_oh3 < 0.0 && _oh3 * _oh3 > _o8c * _o95) {
      return fragment;
    }
    _oft(_oe8);
    _oqx = _oo6(_osq.x, _osq.y, g);
    let _odv = inverseSqrt(_ocl);
    let _olv = _odv * inverseSqrt(_o95);
    let _odt = _odv * _odv;
    let _oan = _o84 * _odt;
    let _oqn = _ol5 * _olv;
    let _oqo = _ol6 * _olv;
    let a = fma(-2.0, _oan, 1.0);
    let _ojf = a > 0.0;
    let _o30 = select(1.0, a, _ojf);
    let _ofv = log2(_o30);
    let _odx = inverseSqrt(0.5 * _o30);
    let _o56 = 0.5 * _o30 * _odx;
    let _or9 = _obf(_obe(-_oqn * _odx, -1.0), 1.0);
    let _or8 = _obf(_obe(_oqo * _odx, -1.0), 1.0);
    let _ofs = _o4m(abs(_or9));
    let _od1 = _o4m(abs(_or8));
    let _oje = _or9 >= 0.0;
    let _oh4 = _or8 <= 0.0;
    let _o8s = _o4n(_ofs, _od1, _oje, _oh4);
    let _ofr = _ojf && _o8s > 0.0;
    let _oby = _oo1[0];
    let _o2z = exp2(_oby * _ofv);
    if (_opv) {
      let _of3 = _ocl * _olv;
      let _obi = _ol5 * _odt;
      let _o8r = select(0.0, _o8s, _ofr);
      let _obj = _ofr && _of3 * (_o56 * _o8r) >= _o5;
      let _o8t = select(1.0, _o8r, _obj);
      let _o8y = _ofs._ojx - _od1._ojx;
      let _ohm = select(0.0, _o56 * _o8y / (2.0 * (_oby + 1.0) * _of3 * _o8t), _obj);
      fragment._op9 = _obf(_obe(_obi + _ohm, 0.0), 1.0);
    }
    let _of2 = _o56 * _o2z * _o8s;
    _opl = select(0.0, _of2 * _odv, _ofr);
  }
  fragment._oer = true;
  fragment._opk = _oqx * _opl;
  return fragment;
}
fn _opt(_oni: u32, _oht: vec3f, _ol1: vec3f, _oqm: f32) -> vec3f {
  let _oar = 12u * _oni;
  let _ojb = vec3f(_opq[_oar], _opq[_oar + 1u], _opq[_oar + 2u]);
  let _oas = vec3f(_opq[_oar + 3u], _opq[_oar + 4u], _opq[_oar + 5u]);
  let _oat = vec3f(_opq[_oar + 6u], _opq[_oar + 7u], _opq[_oar + 8u]);
  let _olh = _opq[_oar + 9u];
  let _ohm = _oht - _ojb;
  let _ohh = _ohm.x * _oas.x + _ohm.y * _oas.y + _ohm.z * _oas.z;
  let _ohi = _ohm.x * _oat.x + _ohm.y * _oat.y + _ohm.z * _oat.z;
  let _o8j = _ol1.x * _oas.x + _ol1.y * _oas.y + _ol1.z * _oas.z;
  let _o8k = _ol1.x * _oat.x + _ol1.y * _oat.y + _ol1.z * _oat.z;
  let _o3b = _o8j * _o8j + _o8k * _o8k;
  var _or7 = 0.5;
  if (_o3b != 0.0 && _oe5(_o3b) && _oe5(_ohh) && _oe5(_ohi)) {
    let _of5 = -(_ohh * _o8j + _ohi * _o8k) / _o3b;
    let _o5e = _ohh + _of5 * _o8j;
    let _o5l = _ohi + _of5 * _o8k;
    let _ok1 = _olh * _olh - (_o5e * _o5e + _o5l * _o5l);
    var _oie = _o5e;
    var _oif = _o5l;
    if (_ok1 >= 0.0) {
      let _ocr = sqrt(_ok1 / _o3b);
      if (_of5 - _ocr > 0.0) {
        _oie = _o5e - _ocr * _o8j;
        _oif = _o5l - _ocr * _o8k;
      } else if (_of5 + _ocr > 0.0) {
        _oie = _o5e + _ocr * _o8j;
        _oif = _o5l + _ocr * _o8k;
      }
    }
    if (_oe5(_oie) && _oe5(_oif)) {
      _or7 = atan2(_oif, _oie) * 0.15915494309189535 + 0.5;
    }
  }
  let _o3p = i32(_o4x._o3p);
  let _o3j = i32(_o4x._o3j);
  let x = _oqm * f32(_o3p - 1);
  let _odd = min(i32(floor(x)), _o3p - 2);
  let wx = x - f32(_odd);
  let y = _or7 * f32(_o3j) - 0.5;
  let _obt = floor(y);
  let _oe9 = ((i32(_obt) % _o3j) + _o3j) % _o3j;
  let _oea = (_oe9 + 1) % _o3j;
  let wy = y - _obt;
  let _ops = array<i32, 4>(_odd * _o3j + _oe9, (_odd + 1) * _o3j + _oe9,
                            _odd * _o3j + _oea, (_odd + 1) * _o3j + _oea);
  let _os3 = array<f32, 4>((1.0 - wx) * (1.0 - wy), wx * (1.0 - wy),
                             (1.0 - wx) * wy, wx * wy);
  let _o45 = _oni * 3u * _o4x._o3p * _o4x._o3j;
  var _o7j = vec3f(0.0);
  for (var _o6b = 0u; _o6b < 3u; _o6b = _o6b + 1u) {
    var _orc = 0.0;
    for (var _oei = 0u; _oei < 4u; _oei = _oei + 1u) {
      _orc = _orc + _os3[_oei] * _opr[_o45 + 3u * u32(_ops[_oei]) + _o6b];
    }
    _o7j[_o6b] = _orc;
  }
  return _o7j;
}
@compute @workgroup_size(16, 16)
fn render_beta(@builtin(local_invocation_id) _ofu: vec3u,
               @builtin(local_invocation_index) _ofl: u32,
               @builtin(workgroup_id) _os6: vec3u) {
  let _os7 = _o5v._os7;
  let _ocy = _o5v._ocy;
  let _opv = _o4x._opv != 0u;
  let _oiz = vec2u(_os6.x * 16u + _ofu.x, _os6.y * 16u + _ofu.y);
  let _odp = _oiz.x < _os7 && _oiz.y < _ocy;
  let _oj3 = vec2f(f32(_oiz.x), f32(_oiz.y));
  var _o9o = !_odp;
  let _opx = _os6.y * _o5v._oq1 + _os6.x;
  let _okt = _oku[2u * _opx];
  let _oks = _oku[2u * _opx + 1u];
  let _olq = (_oks - _okt + _of - 1u) / _of;
  var _oq6 = i32(_oks - _okt);
  var _oqb = 1.0;
  var _o7j = vec3f(0.0);
  var _ol3 = vec3f(0.0);
  var _ol1 = vec3f(0.0);
  if (_opv) {
    _ol3 = _o5v._o5y.xyz;
    let _ohd = (2.0 * _oj3.x + 1.0) / f32(_os7) - 1.0;
    let _ohe = (2.0 * _oj3.y + 1.0) / f32(_ocy) - 1.0;
    let _olw = (_ohd - _o4x._ojp) * _o4x._opg;
    let _olx = (_ohe - _o4x._ojq) * _o4x._oph;
    let _oly = 1.0;
    _ol1 = vec3f(_orp(0u) * _olw + _orp(1u) * _olx + _orp(2u) * _oly,
                _orp(4u) * _olw + _orp(5u) * _olx + _orp(6u) * _oly,
                _orp(8u) * _olw + _orp(9u) * _olx + _orp(10u) * _oly);
  }
  for (var _odc = 0u; _odc < _olq; _odc = _odc + 1u) {
    if (_ofl == 0u) {
      atomicStore(&_o9q, 0u);
    }
    workgroupBarrier();
    if (_o9o) {
      atomicAdd(&_o9q, 1u);
    }
    workgroupBarrier();
    if (_ofl == 0u) {
      _o9p = atomicLoad(&_o9q);
    }
    let _oha = workgroupUniformLoad(&_o9p);
    if (_oha == _of) {
      break;
    }
    let _ojt = _odc * _of + _ofl;
    if (_okt + _ojt < _oks) {
      let _o7i = _ojd[_okt + _ojt];
      _o4b[_ofl] = _o7i;
      let _ola = _ojo[_o7i]._ola;
      _onz(_ofl, abs(_ola.x));
      let _o4k = _ola.z;
      _o4a[_ofl] = _o4k;
      _o4f[_ofl] = bitcast<i32>(_ojn[_o7i].z);
      let _opj = _ojo[_o7i]._o3f;
      let ab = _ojo[_o7i].ab;
      let _o2m = ab.xy;
      let _o3v = ab.zw;
      let _oaj = _o3v.x - _o2m.x;
      let _oap = _o3v.y - _o2m.y;
      let _o2p = _opj.z * _oaj - _opj.y * _oap;
      let _o2q = _opj.x * _oap - _opj.y * _oaj;
      let _oah = _obe(_oaj * _o2p + _oap * _o2q, 0.0);
      let _oaf = _oaj * _oaj + _oap * _oap;
      let _o96 = _obe(_opj.x * _opj.z - _opj.y * _opj.y, 0.0);
      let _oq9 = _opj.x + _opj.z;
      if (_on8(_opj.w)) {
        _o4c[_ofl] = vec4f(_opj.z, -_opj.y, _oah, _oaf);
        _o4d[_ofl] = vec4f(_o96, _oq9, _opj.x, _opj.w);
      } else {
        _o4c[_ofl] = vec4f(_o2p, _o2q, _oah, _oaf);
        _o4d[_ofl] = vec4f(_o96, _oq9, 1.0 / (_oah + _o4k * _oaf), _opj.w);
      }
      _o46[_ofl] = _o2m;
      _o49[_ofl] = vec2f(_oaj, _oap);
      _o47[_ofl] = _ojo[_o7i]._o4r;
    }
    workgroupBarrier();
    let _o48 = u32(min(i32(_of), _oq6));
    for (var _oe8 = 0u; !_o9o && _oe8 < _o48; _oe8 = _oe8 + 1u) {
      let _o2m = _o46[_oe8];
      let _oa4 = _o49[_oe8];
      let fragment = _oai(_oe8, _o4c[_oe8], _o4d[_oe8], _o47[_oe8], _oa4.x, _oa4.y,
                                       _oj3.x - _o2m.x, _oj3.y - _o2m.y, _o4a[_oe8], _opv);
      if (!fragment._oer) {
        continue;
      }
      let _o3b = _obf(1.0 - exp(-fragment._opk), 0.9999);
      let _opp = _oqb * (1.0 - _o3b);
      if (_o3b < _o1i) {
        continue;
      }
      let _o61 = 3u * _o4b[_oe8];
      var _o56 = vec3f(rgb[_o61], rgb[_o61 + 1u], rgb[_o61 + 2u]);
      if (_opv) {
        let _oni = _o4f[_oe8];
        if (_oni >= 0) {
          _o56 = _o56 + _opt(u32(_oni), _ol3, _ol1, fragment._op9);
        }
      }
      _o7j = _o7j + _o56 * _o3b * _oqb;
      _oqb = _opp;
      if (_opp < 0.0001) {
        _o9o = true;
      }
    }
    _oq6 = _oq6 - i32(_of);
  }
  if (_odp) {
    let _oj8 = _os7 * _ocy;
    let _oj0 = _os7 * _oiz.y + _oiz.x;
    _ohx[_oj0] = _o7j.x + _oqb * _o5v._o41.x;
    _ohx[_oj8 + _oj0] = _o7j.y + _oqb * _o5v._o41.y;
    _ohx[2u * _oj8 + _oj0] = _o7j.z + _oqb * _o5v._o41.z;
  }
}
