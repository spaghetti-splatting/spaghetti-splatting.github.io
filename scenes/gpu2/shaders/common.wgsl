const _o2h: u32 = 256u;
const _o1y: u32 = 0u;
const _o1u: u32 = 1u;
const _o1v: u32 = 2u;
const _o1w: u32 = 3u;
const _o20: u32 = 4u;
const _o1z: u32 = 5u;
const _o1t: u32 = 6u;
const _o1x: u32 = 16u;
fn _of2(_orb: vec3u, _ogm: vec3u) -> u32 {
  return _orb.x + _orb.y * _ogm.x;
}
fn _opl(a: f32, b: f32) -> vec2f {
  let _ol9 = a + b;
  let bb = _ol9 - a;
  let _o9m = (a - (_ol9 - bb)) + (b - bb);
  return vec2f(_ol9, _o9m);
}
fn _on2(a: f32) -> vec2f {
  let _oo5 = 4097.0 * a;
  let _ocg = _oo5 - (_oo5 - a);
  return vec2f(_ocg, a - _ocg);
}
fn _opk(a: f32, b: f32) -> vec2f {
  let _ohm = a * b;
  let _olh = _on2(a);
  let _olm = _on2(b);
  let _o9m = ((_olh.x * _olm.x - _ohm) + _olh.x * _olm.y + _olh.y * _olm.x) + _olh.y * _olm.y;
  return vec2f(_ohm, _o9m);
}
fn _o30(a: f32, b: f32) -> f32 {
  let r = _opl(a, b);
  var _o4n = bitcast<u32>(r.x);
  if (r.y != 0.0 && (_o4n & 1u) == 0u) {
    if ((r.y > 0.0) == (r.x > 0.0)) {
      _o4n = _o4n + 1u;
    } else {
      _o4n = _o4n - 1u;
    }
  }
  return bitcast<f32>(_o4n);
}
fn _oau(a: f32, b: f32, _o4z: f32) -> f32 {
  let _ohm = _opk(a, b);
  let _oo5 = _opl(_o4z, _ohm.y);
  let _oqc = _opl(_ohm.x, _oo5.x);
  let z = _o30(_oo5.y, _oqc.y);
  return _oqc.x + z;
}
fn _odk(x: f32) -> bool {
  return (bitcast<u32>(x) & 0x7fffffffu) > 0x7f800000u;
}
fn _odj(x: f32) -> bool {
  return (bitcast<u32>(x) & 0x7f800000u) != 0x7f800000u;
}
fn _oav(a: f32, b: f32) -> f32 {
  if (_odk(a)) { return b; }
  if (_odk(b)) { return a; }
  return max(a, b);
}
fn _oaw(a: f32, b: f32) -> f32 {
  if (_odk(a)) { return b; }
  if (_odk(b)) { return a; }
  return min(a, b);
}
fn _omg(x: f32) -> bool {
  return (bitcast<u32>(x) & 0x80000000u) != 0u;
}
struct _oo {
  _oqp: array<vec4f, 4>,
  _oj4: array<vec4f, 4>,
  _o5r: vec4f,
  _o3x: vec4f,
  _orc: u32,
  _oce: u32,
  _op7: u32,
  _op8: u32,
  _or2: f32,
  _o4f: f32,
  _oi1: f32,
  _oi2: f32,
  _onu: f32,
  _oag: f32,
  _occ: f32,
  _oc9: f32,
  _ol3: u32,
  _o5t: u32,
  _o8t: u32,
  _ohy: u32,
};
