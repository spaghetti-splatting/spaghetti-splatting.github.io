struct _o1o {
  _o3b: vec4f,
  _o4m: vec4f,
  ab: vec4f,
  _obk: vec4f,
  _okm: vec4u,
};
@group(0) @binding(0) var<storage, read> _ok5: array<u32>;
@group(0) @binding(1) var<storage, read> _oio: array<u32>;
@group(0) @binding(2) var<storage, read> _oiz: array<_o1o>;
@group(0) @binding(3) var<storage, read> rgb: array<f32>;
@group(0) @binding(4) var<storage, read_write> _oh8: array<f32>;
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
var<workgroup> _o99: atomic<u32>;
var<workgroup> _o98: u32;
fn _oak(_ops: f32) -> f32 {
  let z = _ops * fma(_o2f, _ops * _ops, 1.0);
  return 1.0 / (1.0 + exp(-_o2e * z));
}
fn _one(_ojd: f32, _oek: f32, g: f32) -> f32 {
  let _oel = _oek / g;
  var _oq7: f32;
  if (_oek < _o2g * g) {
    let _obd = g * g;
    let _opk = _oek * _oek / 12.0;
    let _o8t = _obd - _opk;
    _oq7 = _obd * _obd / _o8t;
  } else if (_oel < _o2d) {
    let x = 0.5 * _oel;
    let _o7o = fma(_o2f, x * x, 1.0);
    let _oo6 = exp(-_o2e * x * _o7o);
    _oq7 = _oek * g * (1.0 + _oo6) / (_o21 * (1.0 - _oo6));
  } else {
    _oq7 = _oek * g / _o21;
  }
  return _ojd * _oq7;
}
struct _o1a {
  _oe4: bool,
  _oor: f32,
};
fn _oa1(_oem: vec4f, _oen: vec4f, _oru: vec4f, _oa2: f32, _oa8: f32,
                     _o9k: f32, _o9l: f32, _o4f: f32) -> _o1a {
  var fragment = _o1a(false, 0.0);
  let _oin = _omh(_oen.w);
  let _o7u = _oru.z;
  let _ok9 = abs(_oen.w);
  let _oka = abs(_oru.w);
  let _oa0 = _oem.z;
  let _o9y = _oem.w;
  let _o8p = _oen.x;
  let _opf = _oen.y;
  var _oos: f32;
  var g: f32;
  if (_oin) {
    g = _ok9 + 0.5 * (_oka - _ok9);
    let gg = g * g;
    let _o8o = fma(gg, fma(gg, _o8p, _o4f * _opf), _o4f * _o4f);
    let _ojq = _o9k - 0.5 * _oa2;
    let _ojr = _o9l - 0.5 * _oa8;
    let _o33 = _oem.x * _ojq + _oem.y * _ojr;
    let _o34 = _oem.y * _ojq + _oen.z * _ojr;
    let _oa7 = gg * (_ojq * _o33 + _ojr * _o34) + _o4f * (_ojq * _ojq + _ojr * _ojr);
    if (_oa7 > _o7u * _o8o) {
      return fragment;
    }
    let _od9 = inverseSqrt(_o8o);
    let _od6 = _od9 * _od9;
    let _oa6 = _oa7 * _od6;
    let _oc0 = fma(gg, _oa0, _o4f * _o9y) * _od6;
    let _okv = (gg * (_oa2 * _o33 + _oa8 * _o34) + _o4f * (_oa2 * _ojq + _oa8 * _ojr)) * _od6;
    let _oi9 = 1.0 - _oc0 / 12.0;
    let _oma = _oi9 + _okv * _okv / 6.0;
    let _oa5 = exp(-_oaw(_oa6, 0.0));
    _oos = _oa5 * _oma * _od9;
  } else {
    let _o2m = _oem.x * _o9k + _oem.y * _o9l;
    let _o4g = _o4f * (_oa2 * _o9k + _oa8 * _o9l);
    let _ooj = _oax(_oaw((_o2m + _o4g) * _oen.z, 0.0), 1.0);
    g = _ok9 + _ooj * (_oka - _ok9);
    let gg = g * g;
    let _oc3 = fma(gg, _oa0, _o4f * _o9y);
    let _okg = fma(gg, _o2m, _o4g);
    let _o8o = fma(gg, fma(gg, _o8p, _o4f * _opf), _o4f * _o4f);
    let cross = _o9k * _oa8 - _o9l * _oa2;
    let _o7n = cross * cross;
    let _o7v = _o7u * _oc3;
    if (_o7n > _o7v) {
      return fragment;
    }
    let _okh = _oc3 - _okg;
    let _oge = _oax(_okg, _okh);
    if (_oge < 0.0 && _oge * _oge > _o7v * _o8o) {
      return fragment;
    }
    let _oda = inverseSqrt(_oc3);
    let _ol6 = _oda * inverseSqrt(_o8o);
    let _od8 = _oda * _oda;
    let _oa6 = _o7n * _od8;
    let _opt = _okg * _ol6;
    let _opu = _okh * _ol6;
    let _olb = _oak(_opt);
    let _olc = _oak(_opu);
    let _o4s = 2.0 * (_olb + _olc - 1.0);
    let _oa5 = exp(-_oa6);
    _oos = select(0.0, _oa5 * _o4s * _o1d * _oda, _o4s > 0.0);
  }
  fragment._oe4 = true;
  fragment._oor = _one(_oru.x, _oru.y, g) * _oos;
  return fragment;
}
@compute @workgroup_size(16, 16)
fn render(@builtin(local_invocation_id) _of7: vec3u,
          @builtin(local_invocation_index) _oey: u32,
          @builtin(workgroup_id) _orc: vec3u) {
  let _ord = _o5o._ord;
  let _ocf = _o5o._ocf;
  let _o4f = _o5o._o4f;
  let _oia = vec2u(_orc.x * 16u + _of7.x, _orc.y * 16u + _of7.y);
  let _od4 = _oia.x < _ord && _oia.y < _ocf;
  let _oie = vec2f(f32(_oia.x), f32(_oia.y));
  var _o97 = !_od4;
  let _op4 = _orc.y * _o5o._op8 + _orc.x;
  let _ok4 = _ok5[2u * _op4];
  let _ok3 = _ok5[2u * _op4 + 1u];
  let _ol1 = (_ok3 - _ok4 + _of - 1u) / _of;
  var _opc = i32(_ok3 - _ok4);
  var _oph = 1.0;
  var _o72 = vec3f(0.0);
  for (var _ocr = 0u; _ocr < _ol1; _ocr = _ocr + 1u) {
    if (_oey == 0u) {
      atomicStore(&_o99, 0u);
    }
    workgroupBarrier();
    if (_o97) {
      atomicAdd(&_o99, 1u);
    }
    workgroupBarrier();
    if (_oey == 0u) {
      _o98 = atomicLoad(&_o99);
    }
    let _ogl = workgroupUniformLoad(&_o98);
    if (_ogl == _of) {
      break;
    }
    let _oj4 = _ocr * _of + _oey;
    if (_ok4 + _oj4 < _ok3) {
      let _o71 = _oio[_ok4 + _oj4];
      _o46[_oey] = _o71;
      let _ooq = _oiz[_o71]._o3b;
      let ab = _oiz[_o71].ab;
      let _o2k = ab.xy;
      let _o3r = ab.zw;
      let _oa2 = _o3r.x - _o2k.x;
      let _oa8 = _o3r.y - _o2k.y;
      let _o2n = _ooq.z * _oa2 - _ooq.y * _oa8;
      let _o2o = _ooq.x * _oa8 - _ooq.y * _oa2;
      let _oa0 = _oaw(_oa2 * _o2n + _oa8 * _o2o, 0.0);
      let _o9y = _oa2 * _oa2 + _oa8 * _oa8;
      let _o8p = _oaw(_ooq.x * _ooq.z - _ooq.y * _ooq.y, 0.0);
      let _opf = _ooq.x + _ooq.z;
      if (_omh(_ooq.w)) {
        _o47[_oey] = vec4f(_ooq.z, -_ooq.y, _oa0, _o9y);
        _o48[_oey] = vec4f(_o8p, _opf, _ooq.x, _ooq.w);
      } else {
        _o47[_oey] = vec4f(_o2n, _o2o, _oa0, _o9y);
        _o48[_oey] = vec4f(_o8p, _opf, 1.0 / (_oa0 + _o4f * _o9y), _ooq.w);
      }
      _o41[_oey] = _o2k;
      _o44[_oey] = vec2f(_oa2, _oa8);
      _o42[_oey] = _oiz[_o71]._o4m;
    }
    workgroupBarrier();
    let _o43 = u32(min(i32(_of), _opc));
    for (var _odn = 0u; !_o97 && _odn < _o43; _odn = _odn + 1u) {
      let _o2k = _o41[_odn];
      let _o9n = _o44[_odn];
      let fragment = _oa1(_o47[_odn], _o48[_odn], _o42[_odn], _o9n.x, _o9n.y,
                                       _oie.x - _o2k.x, _oie.y - _o2k.y, _o4f);
      if (!fragment._oe4) {
        continue;
      }
      let _o37 = _oax(1.0 - exp(-fragment._oor), 0.9999);
      let _oow = _oph * (1.0 - _o37);
      if (_o37 < _o1g) {
        continue;
      }
      let _o4z = 3u * _o46[_odn];
      _o72 = _o72 + vec3f(rgb[_o4z], rgb[_o4z + 1u], rgb[_o4z + 2u]) * _o37 * _oph;
      _oph = _oow;
      if (_oow < 0.0001) {
        _o97 = true;
      }
    }
    _opc = _opc - i32(_of);
  }
  if (_od4) {
    let _oij = _ord * _ocf;
    let _oib = _ord * _oia.y + _oia.x;
    _oh8[_oib] = _o72.x + _oph * _o5o._o3x.x;
    _oh8[_oij + _oib] = _o72.y + _oph * _o5o._o3x.y;
    _oh8[2u * _oij + _oib] = _o72.z + _oph * _o5o._o3x.z;
  }
}
