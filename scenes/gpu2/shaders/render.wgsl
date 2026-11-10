struct _o1q {
  _o3f: vec4f,
  _o4r: vec4f,
  ab: vec4f,
  _oc2: vec4f,
  _olb: vec4u,
};
@group(0) @binding(0) var<storage, read> _oku: array<u32>;
@group(0) @binding(1) var<storage, read> _ojd: array<u32>;
@group(0) @binding(2) var<storage, read> _ojo: array<_o1q>;
@group(0) @binding(3) var<storage, read> rgb: array<f32>;
@group(0) @binding(4) var<storage, read_write> _ohx: array<f32>;
@group(0) @binding(5) var<uniform> _o5v: _oo;
const _of: u32 = 256u;
const _o2i: f32 = 0.1;
const _o2f: f32 = 12.0;
const _o2g: f32 = 2.2567583;
const _o2h: f32 = 0.08945;
const _o23: f32 = 1.7724538509055159;
const _o1f: f32 = 0.88622692545275801;
const _o1i: f32 = 0.0;
var<workgroup> _o4b: array<u32, 256>;
var<workgroup> _o4c: array<vec4f, 256>;
var<workgroup> _o4d: array<vec4f, 256>;
var<workgroup> _o46: array<vec2f, 256>;
var<workgroup> _o49: array<vec2f, 256>;
var<workgroup> _o47: array<vec4f, 256>;
var<workgroup> _o9q: atomic<u32>;
var<workgroup> _o9p: u32;
fn _ob1(_oqm: f32) -> f32 {
  let z = _oqm * fma(_o2h, _oqm * _oqm, 1.0);
  return 1.0 / (1.0 + exp(-_o2g * z));
}
fn _oo6(_ok2: f32, _of7: f32, g: f32) -> f32 {
  let _of8 = _of7 / g;
  var _or1: f32;
  if (_of7 < _o2i * g) {
    let _obv = g * g;
    let _oqe = _of7 * _of7 / 12.0;
    let _o9a = _obv - _oqe;
    _or1 = _obv * _obv / _o9a;
  } else if (_of8 < _o2f) {
    let x = 0.5 * _of8;
    let _o85 = fma(_o2h, x * x, 1.0);
    let _ooz = exp(-_o2g * x * _o85);
    _or1 = _of7 * g * (1.0 + _ooz) / (_o23 * (1.0 - _ooz));
  } else {
    _or1 = _of7 * g / _o23;
  }
  return _ok2 * _or1;
}
struct _o1c {
  _oer: bool,
  _opk: f32,
};
fn _oai(_of9: vec4f, _ofa: vec4f, _osq: vec4f, _oaj: f32, _oap: f32,
                     _oa1: f32, _oa2: f32, _o4k: f32) -> _o1c {
  var fragment = _o1c(false, 0.0);
  let _ojc = _on8(_ofa.w);
  let _o8b = _osq.z;
  let _oky = abs(_ofa.w);
  let _okz = abs(_osq.w);
  let _oah = _of9.z;
  let _oaf = _of9.w;
  let _o96 = _ofa.x;
  let _oq9 = _ofa.y;
  var _opl: f32;
  var g: f32;
  if (_ojc) {
    g = _oky + 0.5 * (_okz - _oky);
    let gg = g * g;
    let _o95 = fma(gg, fma(gg, _o96, _o4k * _oq9), _o4k * _o4k);
    let _okf = _oa1 - 0.5 * _oaj;
    let _okg = _oa2 - 0.5 * _oap;
    let _o35 = _of9.x * _okf + _of9.y * _okg;
    let _o36 = _of9.y * _okf + _ofa.z * _okg;
    let _oao = gg * (_okf * _o35 + _okg * _o36) + _o4k * (_okf * _okf + _okg * _okg);
    if (_oao > _o8b * _o95) {
      return fragment;
    }
    let _odu = inverseSqrt(_o95);
    let _odr = _odu * _odu;
    let _oan = _oao * _odr;
    let _oci = fma(gg, _oah, _o4k * _oaf) * _odr;
    let _olk = (gg * (_oaj * _o35 + _oap * _o36) + _o4k * (_oaj * _okf + _oap * _okg)) * _odr;
    let _oiy = 1.0 - _oci / 12.0;
    let _on0 = _oiy + _olk * _olk / 6.0;
    let _oam = exp(-_obe(_oan, 0.0));
    _opl = _oam * _on0 * _odu;
  } else {
    let _o2o = _of9.x * _oa1 + _of9.y * _oa2;
    let _o4l = _o4k * (_oaj * _oa1 + _oap * _oa2);
    let _opc = _obf(_obe((_o2o + _o4l) * _ofa.z, 0.0), 1.0);
    g = _oky + _opc * (_okz - _oky);
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
    let _odv = inverseSqrt(_ocl);
    let _olv = _odv * inverseSqrt(_o95);
    let _odt = _odv * _odv;
    let _oan = _o84 * _odt;
    let _oqn = _ol5 * _olv;
    let _oqo = _ol6 * _olv;
    let _om0 = _ob1(_oqn);
    let _om1 = _ob1(_oqo);
    let _o4y = 2.0 * (_om0 + _om1 - 1.0);
    let _oam = exp(-_oan);
    _opl = select(0.0, _oam * _o4y * _o1f * _odv, _o4y > 0.0);
  }
  fragment._oer = true;
  fragment._opk = _oo6(_osq.x, _osq.y, g) * _opl;
  return fragment;
}
@compute @workgroup_size(16, 16)
fn render(@builtin(local_invocation_id) _ofu: vec3u,
          @builtin(local_invocation_index) _ofl: u32,
          @builtin(workgroup_id) _os6: vec3u) {
  let _os7 = _o5v._os7;
  let _ocy = _o5v._ocy;
  let _o4k = _o5v._o4k;
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
      let fragment = _oai(_o4c[_oe8], _o4d[_oe8], _o47[_oe8], _oa4.x, _oa4.y,
                                       _oj3.x - _o2m.x, _oj3.y - _o2m.y, _o4k);
      if (!fragment._oer) {
        continue;
      }
      let _o3b = _obf(1.0 - exp(-fragment._opk), 0.9999);
      let _opp = _oqb * (1.0 - _o3b);
      if (_o3b < _o1i) {
        continue;
      }
      let _o56 = 3u * _o4b[_oe8];
      _o7j = _o7j + vec3f(rgb[_o56], rgb[_o56 + 1u], rgb[_o56 + 2u]) * _o3b * _oqb;
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
