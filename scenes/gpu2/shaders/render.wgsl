struct _o1x {
  _o3p: vec4f,
  _o52: vec4f,
  ab: vec4f,
  _ocw: vec4f,
  _omg: vec4u,
};
@group(0) @binding(0) var<storage, read> _oly: array<u32>;
@group(0) @binding(1) var<storage, read> _okd: array<u32>;
@group(0) @binding(2) var<storage, read> _oko: array<_o1x>;
@group(0) @binding(3) var<storage, read> rgb: array<f32>;
@group(0) @binding(4) var<storage, read_write> _oiw: array<f32>;
@group(0) @binding(5) var<uniform> _o69: _oo;
const _of: u32 = 256u;
const _o2p: f32 = 0.1;
const _o2m: f32 = 12.0;
const _o2n: f32 = 2.2567583;
const _o2o: f32 = 0.08945;
const _o2a: f32 = 1.7724538509055159;
const _o1k: f32 = 0.88622692545275801;
const _o1o: f32 = 0.0;
var<workgroup> _o4m: array<u32, 256>;
var<workgroup> _o4n: array<vec4f, 256>;
var<workgroup> _o4o: array<vec4f, 256>;
var<workgroup> _o4h: array<vec2f, 256>;
var<workgroup> _o4k: array<vec2f, 256>;
var<workgroup> _o4i: array<vec4f, 256>;
var<workgroup> _oa4: atomic<u32>;
var<workgroup> _oa3: u32;
fn _obh(_orw: f32) -> f32 {
  let z = _orw * fma(_o2o, _orw * _orw, 1.0);
  return 1.0 / (1.0 + exp(-_o2n * z));
}
fn _opc(_ol2: f32, _og5: f32, g: f32) -> f32 {
  let _og6 = _og5 / g;
  var _osb: f32;
  if (_og5 < _o2p * g) {
    let _oco = g * g;
    let _oro = _og5 * _og5 / 12.0;
    let _o9o = _oco - _oro;
    _osb = _oco * _oco / _o9o;
  } else if (_og6 < _o2m) {
    let x = 0.5 * _og6;
    let _o8j = fma(_o2o, x * x, 1.0);
    let _oq8 = exp(-_o2n * x * _o8j);
    _osb = _og5 * g * (1.0 + _oq8) / (_o2a * (1.0 - _oq8));
  } else {
    _osb = _og5 * g / _o2a;
  }
  return _ol2 * _osb;
}
struct _o1f {
  _ofm: bool,
  _oqt: f32,
};
fn _oay(_og7: vec4f, _og8: vec4f, _ou0: vec4f, _oaz: f32, _ob5: f32,
                     _oag: f32, _oah: f32, _o4v: f32) -> _o1f {
  var fragment = _o1f(false, 0.0);
  let _okc = _ood(_og8.w);
  let _o8p = _ou0.z;
  let _om2 = abs(_og8.w);
  let _om3 = abs(_ou0.w);
  let _oax = _og7.z;
  let _oav = _og7.w;
  let _o9k = _og8.x;
  let _orj = _og8.y;
  var _oqu: f32;
  var g: f32;
  if (_okc) {
    g = _om2 + 0.5 * (_om3 - _om2);
    let gg = g * g;
    let _o9j = fma(gg, fma(gg, _o9k, _o4v * _orj), _o4v * _o4v);
    let _oli = _oag - 0.5 * _oaz;
    let _olj = _oah - 0.5 * _ob5;
    let _o3c = _og7.x * _oli + _og7.y * _olj;
    let _o3d = _og7.y * _oli + _og8.z * _olj;
    let _ob4 = gg * (_oli * _o3c + _olj * _o3d) + _o4v * (_oli * _oli + _olj * _olj);
    if (_ob4 > _o8p * _o9j) {
      return fragment;
    }
    let _oep = inverseSqrt(_o9j);
    let _oem = _oep * _oep;
    let _ob3 = _ob4 * _oem;
    let _odd = fma(gg, _oax, _o4v * _oav) * _oem;
    let _omp = (gg * (_oaz * _o3c + _ob5 * _o3d) + _o4v * (_oaz * _oli + _ob5 * _olj)) * _oem;
    let _ojx = 1.0 - _odd / 12.0;
    let _oo5 = _ojx + _omp * _omp / 6.0;
    let _ob2 = exp(-_obu(_ob3, 0.0));
    _oqu = _ob2 * _oo5 * _oep;
  } else {
    let _o2v = _og7.x * _oag + _og7.y * _oah;
    let _o4w = _o4v * (_oaz * _oag + _ob5 * _oah);
    let _oql = _obv(_obu((_o2v + _o4w) * _og8.z, 0.0), 1.0);
    g = _om2 + _oql * (_om3 - _om2);
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
    let _oeq = inverseSqrt(_odg);
    let _on0 = _oeq * inverseSqrt(_o9j);
    let _oeo = _oeq * _oeq;
    let _ob3 = _o8i * _oeo;
    let _orx = _oma * _on0;
    let _ory = _omb * _on0;
    let _on5 = _obh(_orx);
    let _on6 = _obh(_ory);
    let _o5b = 2.0 * (_on5 + _on6 - 1.0);
    let _ob2 = exp(-_ob3);
    _oqu = select(0.0, _ob2 * _o5b * _o1k * _oeq, _o5b > 0.0);
  }
  fragment._ofm = true;
  fragment._oqt = _opc(_ou0.x, _ou0.y, g) * _oqu;
  return fragment;
}
@compute @workgroup_size(16, 16)
fn render(@builtin(local_invocation_id) _ogs: vec3u,
          @builtin(local_invocation_index) _ogj: u32,
          @builtin(workgroup_id) _otg: vec3u) {
  let _oth = _o69._oth;
  let _odt = _o69._odt;
  let _o4v = _o69._o4v;
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
      let fragment = _oay(_o4n[_of3], _o4o[_of3], _o4i[_of3], _oaj.x, _oaj.y,
                                       _ok3.x - _o2t.x, _ok3.y - _o2t.y, _o4v);
      if (!fragment._ofm) {
        continue;
      }
      let _o3j = _obv(1.0 - exp(-fragment._oqt), 0.9999);
      let _oqy = _orl * (1.0 - _o3j);
      if (_o3j < _o1o) {
        continue;
      }
      let _o5j = 3u * _o4m[_of3];
      _o7x = _o7x + vec3f(rgb[_o5j], rgb[_o5j + 1u], rgb[_o5j + 2u]) * _o3j * _orl;
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
