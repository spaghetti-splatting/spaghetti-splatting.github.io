struct _o1u {
  _o3i: vec4f,
  _o4u: vec4f,
  ab: vec4f,
  _obz: vec4f,
  _ol9: vec4u,
};
@group(0) @binding(0) var<storage, read> _okp: array<u32>;
@group(0) @binding(1) var<storage, read> _oj6: array<u32>;
@group(0) @binding(2) var<storage, read> _ojm: array<_o1u>;
@group(0) @binding(3) var<storage, read> rgb: array<f32>;
@group(0) @binding(4) var<storage, read_write> _oho: array<f32>;
@group(0) @binding(5) var<uniform> _o5x: _oo;
const _og: u32 = 256u;
const _o2n: f32 = 0.1;
const _o2k: f32 = 12.0;
const _o2l: f32 = 2.2567583;
const _o2m: f32 = 0.08945;
const _o28: f32 = 1.7724538509055159;
const _o1d: f32 = 0.88622692545275801;
const _o1j: f32 = 0.0;
var<workgroup> _o4f: array<u32, 256>;
var<workgroup> _o4g: array<vec4f, 256>;
var<workgroup> _o4h: array<vec4f, 256>;
var<workgroup> _o4a: array<vec2f, 256>;
var<workgroup> _o4d: array<vec2f, 256>;
var<workgroup> _o4b: array<vec4f, 256>;
var<workgroup> _o9m: atomic<u32>;
var<workgroup> _o9l: u32;
fn _oax(_oqg: f32) -> f32 {
  let z = _oqg * fma(_o2m, _oqg * _oqg, 1.0);
  return 1.0 / (1.0 + exp(-_o2l * z));
}
fn _oo3(_ojz: f32, _of1: f32, g: f32) -> f32 {
  let _of2 = _of1 / g;
  var _oqv: f32;
  if (_of1 < _o2n * g) {
    let _obs = g * g;
    let _oq8 = _of1 * _of1 / 12.0;
    let _o94 = _obs - _oq8;
    _oqv = _obs * _obs / _o94;
  } else if (_of2 < _o2k) {
    let x = 0.5 * _of2;
    let _o7u = fma(_o2m, x * x, 1.0);
    let _oou = exp(-_o2l * x * _o7u);
    _oqv = _of1 * g * (1.0 + _oou) / (_o28 * (1.0 - _oou));
  } else {
    _oqv = _of1 * g / _o28;
  }
  return _ojz * _oqv;
}
struct _o19 {
  _oek: bool,
  _opf: f32,
};
fn _oaf(_of3: vec4f, _of4: vec4f, _osr: vec4f, _oag: f32, _oam: f32,
                     _o9w: f32, _o9x: f32, _o4n: f32) -> _o19 {
  var fragment = _o19(false, 0.0);
  let _oj5 = _on4(_of4.w);
  let _o81 = _osr.z;
  let _okt = abs(_of4.w);
  let _oku = abs(_osr.w);
  let _oae = _of3.z;
  let _oab = _of3.w;
  let _o8z = _of4.x;
  let _oq4 = _of4.y;
  var _opg: f32;
  var g: f32;
  if (_oj5) {
    g = _okt + 0.5 * (_oku - _okt);
    let gg = g * g;
    let _o8y = fma(gg, fma(gg, _o8z, _o4n * _oq4), _o4n * _o4n);
    let _ok8 = _o9w - 0.5 * _oag;
    let _ok9 = _o9x - 0.5 * _oam;
    let _o3a = _of3.x * _ok8 + _of3.y * _ok9;
    let _o3b = _of3.y * _ok8 + _of4.z * _ok9;
    let _oal = gg * (_ok8 * _o3a + _ok9 * _o3b) + _o4n * (_ok8 * _ok8 + _ok9 * _ok9);
    if (_oal > _o81 * _o8y) {
      return fragment;
    }
    let _odp = inverseSqrt(_o8y);
    let _odm = _odp * _odp;
    let _oak = _oal * _odm;
    let _och = fma(gg, _oae, _o4n * _oab) * _odm;
    let _oli = (gg * (_oag * _o3a + _oam * _o3b) + _o4n * (_oag * _ok8 + _oam * _ok9)) * _odm;
    let _oiq = 1.0 - _och / 12.0;
    let _omx = _oiq + _oli * _oli / 6.0;
    let _oaj = exp(-_obd(_oak, 0.0));
    _opg = _oaj * _omx * _odp;
  } else {
    let _o2t = _of3.x * _o9w + _of3.y * _o9x;
    let _o4o = _o4n * (_oag * _o9w + _oam * _o9x);
    let _op7 = _obe(_obd((_o2t + _o4o) * _of4.z, 0.0), 1.0);
    g = _okt + _op7 * (_oku - _okt);
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
    let _odq = inverseSqrt(_oci);
    let _olt = _odq * inverseSqrt(_o8y);
    let _odo = _odq * _odq;
    let _oak = _o7t * _odo;
    let _oqh = _ol1 * _olt;
    let _oqi = _ol2 * _olt;
    let _oly = _oax(_oqh);
    let _olz = _oax(_oqi);
    let _o50 = 2.0 * (_oly + _olz - 1.0);
    let _oaj = exp(-_oak);
    _opg = select(0.0, _oaj * _o50 * _o1d * _odq, _o50 > 0.0);
  }
  fragment._oek = true;
  fragment._opf = _oo3(_osr.x, _osr.y, g) * _opg;
  return fragment;
}
@compute @workgroup_size(16, 16)
fn render(@builtin(local_invocation_id) _ofq: vec3u,
          @builtin(local_invocation_index) _ofg: u32,
          @builtin(workgroup_id) _os5: vec3u) {
  let _os6 = _o5x._os6;
  let _ocv = _o5x._ocv;
  let _o4n = _o5x._o4n;
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
      let fragment = _oaf(_o4g[_oe3], _o4h[_oe3], _o4b[_oe3], _o9z.x, _o9z.y,
                                       _oiw.x - _o2r.x, _oiw.y - _o2r.y, _o4n);
      if (!fragment._oek) {
        continue;
      }
      let _o3e = _obe(1.0 - exp(-fragment._opf), 0.9999);
      let _opj = _oq6 * (1.0 - _o3e);
      if (_o3e < _o1j) {
        continue;
      }
      let _o58 = 3u * _o4f[_oe3];
      _o72 = _o72 + vec3f(rgb[_o58], rgb[_o58 + 1u], rgb[_o58 + 2u]) * _o3e * _oq6;
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
