const _o2h: u32 = 256u;
const _o1y: u32 = 0u;
const _o1u: u32 = 1u;
const _o1v: u32 = 2u;
const _o1w: u32 = 3u;
const _o20: u32 = 4u;
const _o1z: u32 = 5u;
const _o1t: u32 = 6u;
const _o1x: u32 = 16u;
fn _of3(_orc: vec3u, _ogn: vec3u) -> u32 {
  return _orc.x + _orc.y * _ogn.x;
}
fn _opm(a: f32, b: f32) -> vec2f {
  let _ola = a + b;
  let bb = _ola - a;
  let _o9n = (a - (_ola - bb)) + (b - bb);
  return vec2f(_ola, _o9n);
}
fn _on3(a: f32) -> vec2f {
  let _oo6 = 4097.0 * a;
  let _och = _oo6 - (_oo6 - a);
  return vec2f(_och, a - _och);
}
fn _opl(a: f32, b: f32) -> vec2f {
  let _ohn = a * b;
  let _oli = _on3(a);
  let _oln = _on3(b);
  let _o9n = ((_oli.x * _oln.x - _ohn) + _oli.x * _oln.y + _oli.y * _oln.x) + _oli.y * _oln.y;
  return vec2f(_ohn, _o9n);
}
fn _o30(a: f32, b: f32) -> f32 {
  let r = _opm(a, b);
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
fn _oav(a: f32, b: f32, _o4z: f32) -> f32 {
  let _ohn = _opl(a, b);
  let _oo6 = _opm(_o4z, _ohn.y);
  let _oqd = _opm(_ohn.x, _oo6.x);
  let z = _o30(_oo6.y, _oqd.y);
  return _oqd.x + z;
}
fn _odl(x: f32) -> bool {
  return (bitcast<u32>(x) & 0x7fffffffu) > 0x7f800000u;
}
fn _odk(x: f32) -> bool {
  return (bitcast<u32>(x) & 0x7f800000u) != 0x7f800000u;
}
fn _oaw(a: f32, b: f32) -> f32 {
  if (_odl(a)) { return b; }
  if (_odl(b)) { return a; }
  return max(a, b);
}
fn _oax(a: f32, b: f32) -> f32 {
  if (_odl(a)) { return b; }
  if (_odl(b)) { return a; }
  return min(a, b);
}
fn _omh(x: f32) -> bool {
  return (bitcast<u32>(x) & 0x80000000u) != 0u;
}
struct _oo {
  _oqq: array<vec4f, 4>,
  _oj5: array<vec4f, 4>,
  _o5r: vec4f,
  _o3x: vec4f,
  _ord: u32,
  _ocf: u32,
  _op8: u32,
  _op9: u32,
  _or3: f32,
  _o4f: f32,
  _oi2: f32,
  _oi3: f32,
  _onv: f32,
  _oah: f32,
  _ocd: f32,
  _oca: f32,
  _ol4: u32,
  _o5t: u32,
  _o8u: u32,
  _ohz: u32,
};
