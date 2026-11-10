struct _o1o {
  _o3b: vec4f,
  _o4m: vec4f,
  ab: vec4f,
  _obj: vec4f,
  _okl: vec4u,
};
@group(0) @binding(0) var<storage, read> _ok4: array<u32>;
@group(0) @binding(1) var<storage, read> _oin: array<u32>;
@group(0) @binding(2) var<storage, read> _oiy: array<_o1o>;
@group(0) @binding(3) var<storage, read> rgb: array<f32>;
@group(0) @binding(4) var<storage, read_write> _oh7: array<f32>;
@group(0) @binding(5) var<uniform> _o5o: _oo;
const _of: u32 = 256u;
const _o2g: f32 = 0.1;
const _o2d: f32 = 12.0;
const _o2e: f32 = 2.2567583;
const _o2f: f32 = 0.08945;
const _o21: f32 = 1.7724538509055159;
const _o1d: f32 = 0.88622692545275801;
const _o1g: f32 = 0.0;
var<workgroup> _o46: array<u32, 256>;
var<workgroup> _o47: array<vec4f, 256>;
var<workgroup> _o48: array<vec4f, 256>;
var<workgroup> _o41: array<vec2f, 256>;
var<workgroup> _o44: array<vec2f, 256>;
var<workgroup> _o42: array<vec4f, 256>;
var<workgroup> _o98: atomic<u32>;
var<workgroup> _o97: u32;
fn _oaj(_opr: f32) -> f32 {
  let z = _opr * fma(_o2f, _opr * _opr, 1.0);
  return 1.0 / (1.0 + exp(-_o2e * z));
}
fn _ond(_ojc: f32, _oej: f32, g: f32) -> f32 {
  let _oek = _oej / g;
  var _oq6: f32;
  if (_oej < _o2g * g) {
    let _obc = g * g;
    let _opj = _oej * _oej / 12.0;
    let _o8s = _obc - _opj;
    _oq6 = _obc * _obc / _o8s;
  } else if (_oek < _o2d) {
    let x = 0.5 * _oek;
    let _o7n = fma(_o2f, x * x, 1.0);
    let _oo5 = exp(-_o2e * x * _o7n);
    _oq6 = _oej * g * (1.0 + _oo5) / (_o21 * (1.0 - _oo5));
  } else {
    _oq6 = _oej * g / _o21;
  }
  return _ojc * _oq6;
}
struct _o1a {
  _oe3: bool,
  _ooq: f32,
};
fn _oa0(_oel: vec4f, _oem: vec4f, _ort: vec4f, _oa1: f32, _oa7: f32,
                     _o9j: f32, _o9k: f32, _o4f: f32) -> _o1a {
  var fragment = _o1a(false, 0.0);
  let _oim = _omg(_oem.w);
  let _o7t = _ort.z;
  let _ok8 = abs(_oem.w);
  let _ok9 = abs(_ort.w);
  let _o9z = _oel.z;
  let _o9x = _oel.w;
  let _o8o = _oem.x;
  let _ope = _oem.y;
  var _oor: f32;
  var g: f32;
  if (_oim) {
    g = _ok8 + 0.5 * (_ok9 - _ok8);
    let gg = g * g;
    let _o8n = fma(gg, fma(gg, _o8o, _o4f * _ope), _o4f * _o4f);
    let _ojp = _o9j - 0.5 * _oa1;
    let _ojq = _o9k - 0.5 * _oa7;
    let _o33 = _oel.x * _ojp + _oel.y * _ojq;
    let _o34 = _oel.y * _ojp + _oem.z * _ojq;
    let _oa6 = gg * (_ojp * _o33 + _ojq * _o34) + _o4f * (_ojp * _ojp + _ojq * _ojq);
    if (_oa6 > _o7t * _o8n) {
      return fragment;
    }
    let _od8 = inverseSqrt(_o8n);
    let _od5 = _od8 * _od8;
    let _oa5 = _oa6 * _od5;
    let _obz = fma(gg, _o9z, _o4f * _o9x) * _od5;
    let _oku = (gg * (_oa1 * _o33 + _oa7 * _o34) + _o4f * (_oa1 * _ojp + _oa7 * _ojq)) * _od5;
    let _oi8 = 1.0 - _obz / 12.0;
    let _om9 = _oi8 + _oku * _oku / 6.0;
    let _oa4 = exp(-_oav(_oa5, 0.0));
    _oor = _oa4 * _om9 * _od8;
  } else {
    let _o2m = _oel.x * _o9j + _oel.y * _o9k;
    let _o4g = _o4f * (_oa1 * _o9j + _oa7 * _o9k);
    let _ooi = _oaw(_oav((_o2m + _o4g) * _oem.z, 0.0), 1.0);
    g = _ok8 + _ooi * (_ok9 - _ok8);
    let gg = g * g;
    let _oc2 = fma(gg, _o9z, _o4f * _o9x);
    let _okf = fma(gg, _o2m, _o4g);
    let _o8n = fma(gg, fma(gg, _o8o, _o4f * _ope), _o4f * _o4f);
    let cross = _o9j * _oa7 - _o9k * _oa1;
    let _o7m = cross * cross;
    let _o7u = _o7t * _oc2;
    if (_o7m > _o7u) {
      return fragment;
    }
    let _okg = _oc2 - _okf;
    let _ogd = _oaw(_okf, _okg);
    if (_ogd < 0.0 && _ogd * _ogd > _o7u * _o8n) {
      return fragment;
    }
    let _od9 = inverseSqrt(_oc2);
    let _ol5 = _od9 * inverseSqrt(_o8n);
    let _od7 = _od9 * _od9;
    let _oa5 = _o7m * _od7;
    let _ops = _okf * _ol5;
    let _opt = _okg * _ol5;
    let _ola = _oaj(_ops);
    let _olb = _oaj(_opt);
    let _o4s = 2.0 * (_ola + _olb - 1.0);
    let _oa4 = exp(-_oa5);
    _oor = select(0.0, _oa4 * _o4s * _o1d * _od9, _o4s > 0.0);
  }
  fragment._oe3 = true;
  fragment._ooq = _ond(_ort.x, _ort.y, g) * _oor;
  return fragment;
}
@compute @workgroup_size(16, 16)
fn render(@builtin(local_invocation_id) _of6: vec3u,
          @builtin(local_invocation_index) _oex: u32,
          @builtin(workgroup_id) _orb: vec3u) {
  let _orc = _o5o._orc;
  let _oce = _o5o._oce;
  let _o4f = _o5o._o4f;
  let _oi9 = vec2u(_orb.x * 16u + _of6.x, _orb.y * 16u + _of6.y);
  let _od3 = _oi9.x < _orc && _oi9.y < _oce;
  let _oid = vec2f(f32(_oi9.x), f32(_oi9.y));
  var _o96 = !_od3;
  let _op3 = _orb.y * _o5o._op7 + _orb.x;
  let _ok3 = _ok4[2u * _op3];
  let _ok2 = _ok4[2u * _op3 + 1u];
  let _ol0 = (_ok2 - _ok3 + _of - 1u) / _of;
  var _opb = i32(_ok2 - _ok3);
  var _opg = 1.0;
  var _o71 = vec3f(0.0);
  for (var _ocq = 0u; _ocq < _ol0; _ocq = _ocq + 1u) {
    if (_oex == 0u) {
      atomicStore(&_o98, 0u);
    }
    workgroupBarrier();
    if (_o96) {
      atomicAdd(&_o98, 1u);
    }
    workgroupBarrier();
    if (_oex == 0u) {
      _o97 = atomicLoad(&_o98);
    }
    let _ogk = workgroupUniformLoad(&_o97);
    if (_ogk == _of) {
      break;
    }
    let _oj3 = _ocq * _of + _oex;
    if (_ok3 + _oj3 < _ok2) {
      let _o70 = _oin[_ok3 + _oj3];
      _o46[_oex] = _o70;
      let _oop = _oiy[_o70]._o3b;
      let ab = _oiy[_o70].ab;
      let _o2k = ab.xy;
      let _o3r = ab.zw;
      let _oa1 = _o3r.x - _o2k.x;
      let _oa7 = _o3r.y - _o2k.y;
      let _o2n = _oop.z * _oa1 - _oop.y * _oa7;
      let _o2o = _oop.x * _oa7 - _oop.y * _oa1;
      let _o9z = _oav(_oa1 * _o2n + _oa7 * _o2o, 0.0);
      let _o9x = _oa1 * _oa1 + _oa7 * _oa7;
      let _o8o = _oav(_oop.x * _oop.z - _oop.y * _oop.y, 0.0);
      let _ope = _oop.x + _oop.z;
      if (_omg(_oop.w)) {
        _o47[_oex] = vec4f(_oop.z, -_oop.y, _o9z, _o9x);
        _o48[_oex] = vec4f(_o8o, _ope, _oop.x, _oop.w);
      } else {
        _o47[_oex] = vec4f(_o2n, _o2o, _o9z, _o9x);
        _o48[_oex] = vec4f(_o8o, _ope, 1.0 / (_o9z + _o4f * _o9x), _oop.w);
      }
      _o41[_oex] = _o2k;
      _o44[_oex] = vec2f(_oa1, _oa7);
      _o42[_oex] = _oiy[_o70]._o4m;
    }
    workgroupBarrier();
    let _o43 = u32(min(i32(_of), _opb));
    for (var _odm = 0u; !_o96 && _odm < _o43; _odm = _odm + 1u) {
      let _o2k = _o41[_odm];
      let _o9m = _o44[_odm];
      let fragment = _oa0(_o47[_odm], _o48[_odm], _o42[_odm], _o9m.x, _o9m.y,
                                       _oid.x - _o2k.x, _oid.y - _o2k.y, _o4f);
      if (!fragment._oe3) {
        continue;
      }
      let _o37 = _oaw(1.0 - exp(-fragment._ooq), 0.9999);
      let _oov = _opg * (1.0 - _o37);
      if (_o37 < _o1g) {
        continue;
      }
      let _o4z = 3u * _o46[_odm];
      _o71 = _o71 + vec3f(rgb[_o4z], rgb[_o4z + 1u], rgb[_o4z + 2u]) * _o37 * _opg;
      _opg = _oov;
      if (_oov < 0.0001) {
        _o96 = true;
      }
    }
    _opb = _opb - i32(_of);
  }
  if (_od3) {
    let _oii = _orc * _oce;
    let _oia = _orc * _oi9.y + _oi9.x;
    _oh7[_oia] = _o71.x + _opg * _o5o._o3x.x;
    _oh7[_oii + _oia] = _o71.y + _opg * _o5o._o3x.y;
    _oh7[2u * _oii + _oia] = _o71.z + _opg * _o5o._o3x.z;
  }
}
