const _o2j: u32 = 256u;
const _o20: u32 = 0u;
const _o1w: u32 = 1u;
const _o1x: u32 = 2u;
const _o1y: u32 = 3u;
const _o22: u32 = 4u;
const _o21: u32 = 5u;
const _o1v: u32 = 6u;
const _o1z: u32 = 16u;
fn _ofq(_os6: vec3u, _ohc: vec3u) -> u32 {
  return _os6.x + _os6.y * _ohc.x;
}
fn _oqg(a: f32, b: f32) -> vec2f {
  let _olz = a + b;
  let bb = _olz - a;
  let _oa4 = (a - (_olz - bb)) + (b - bb);
  return vec2f(_olz, _oa4);
}
fn _onv(a: f32) -> vec2f {
  let _ooz = 4097.0 * a;
  let _od1 = _ooz - (_ooz - a);
  return vec2f(_od1, a - _od1);
}
fn _oqf(a: f32, b: f32) -> vec2f {
  let _oic = a * b;
  let _om7 = _onv(a);
  let _omc = _onv(b);
  let _oa4 = ((_om7.x * _omc.x - _oic) + _om7.x * _omc.y + _om7.y * _omc.x) + _om7.y * _omc.y;
  return vec2f(_oic, _oa4);
}
fn _o32(a: f32, b: f32) -> f32 {
  let r = _oqg(a, b);
  var _o4s = bitcast<u32>(r.x);
  if (r.y != 0.0 && (_o4s & 1u) == 0u) {
    if ((r.y > 0.0) == (r.x > 0.0)) {
      _o4s = _o4s + 1u;
    } else {
      _o4s = _o4s - 1u;
    }
  }
  return bitcast<f32>(_o4s);
}
fn _obd(a: f32, b: f32, _o56: f32) -> f32 {
  let _oic = _oqf(a, b);
  let _ooz = _oqg(_o56, _oic.y);
  let _or7 = _oqg(_oic.x, _ooz.x);
  let z = _o32(_ooz.y, _or7.y);
  return _or7.x + z;
}
fn _oe6(x: f32) -> bool {
  return (bitcast<u32>(x) & 0x7fffffffu) > 0x7f800000u;
}
fn _oe5(x: f32) -> bool {
  return (bitcast<u32>(x) & 0x7f800000u) != 0x7f800000u;
}
fn _obe(a: f32, b: f32) -> f32 {
  if (_oe6(a)) { return b; }
  if (_oe6(b)) { return a; }
  return max(a, b);
}
fn _obf(a: f32, b: f32) -> f32 {
  if (_oe6(a)) { return b; }
  if (_oe6(b)) { return a; }
  return min(a, b);
}
fn _on8(x: f32) -> bool {
  return (bitcast<u32>(x) & 0x80000000u) != 0u;
}
struct _oo {
  _ork: array<vec4f, 4>,
  _oju: array<vec4f, 4>,
  _o5y: vec4f,
  _o41: vec4f,
  _os7: u32,
  _ocy: u32,
  _oq1: u32,
  _oq2: u32,
  _orx: f32,
  _o4k: f32,
  _oir: f32,
  _ois: f32,
  _ooo: f32,
  _oay: f32,
  _ocw: f32,
  _oct: f32,
  _olt: u32,
  _o60: u32,
  _o9b: u32,
  _oio: u32,
};
