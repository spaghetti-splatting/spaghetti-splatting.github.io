const _o2q: u32 = 256u;
const _o27: u32 = 0u;
const _o23: u32 = 1u;
const _o24: u32 = 2u;
const _o25: u32 = 3u;
const _o29: u32 = 4u;
const _o28: u32 = 5u;
const _o22: u32 = 6u;
const _o26: u32 = 16u;
fn _ogo(_otg: vec3u, _oib: vec3u) -> u32 {
  return _otg.x + _otg.y * _oib.x;
}
fn _orq(a: f32, b: f32) -> vec2f {
  let _on4 = a + b;
  let bb = _on4 - a;
  let _oaj = (a - (_on4 - bb)) + (b - bb);
  return vec2f(_on4, _oaj);
}
fn _op0(a: f32) -> vec2f {
  let _oq8 = 4097.0 * a;
  let _odw = _oq8 - (_oq8 - a);
  return vec2f(_odw, a - _odw);
}
fn _orp(a: f32, b: f32) -> vec2f {
  let _ojb = a * b;
  let _onc = _op0(a);
  let _onh = _op0(b);
  let _oaj = ((_onc.x * _onh.x - _ojb) + _onc.x * _onh.y + _onc.y * _onh.x) + _onc.y * _onh.y;
  return vec2f(_ojb, _oaj);
}
fn _o39(a: f32, b: f32) -> f32 {
  let r = _orq(a, b);
  var _o53 = bitcast<u32>(r.x);
  if (r.y != 0.0 && (_o53 & 1u) == 0u) {
    if ((r.y > 0.0) == (r.x > 0.0)) {
      _o53 = _o53 + 1u;
    } else {
      _o53 = _o53 - 1u;
    }
  }
  return bitcast<f32>(_o53);
}
fn _obt(a: f32, b: f32, _o5j: f32) -> f32 {
  let _ojb = _orp(a, b);
  let _oq8 = _orq(_o5j, _ojb.y);
  let _osh = _orq(_ojb.x, _oq8.x);
  let z = _o39(_oq8.y, _osh.y);
  return _osh.x + z;
}
fn _of1(x: f32) -> bool {
  return (bitcast<u32>(x) & 0x7fffffffu) > 0x7f800000u;
}
fn _of0(x: f32) -> bool {
  return (bitcast<u32>(x) & 0x7f800000u) != 0x7f800000u;
}
fn _obu(a: f32, b: f32) -> f32 {
  if (_of1(a)) { return b; }
  if (_of1(b)) { return a; }
  return max(a, b);
}
fn _obv(a: f32, b: f32) -> f32 {
  if (_of1(a)) { return b; }
  if (_of1(b)) { return a; }
  return min(a, b);
}
fn _ood(x: f32) -> bool {
  return (bitcast<u32>(x) & 0x80000000u) != 0u;
}
struct _oo {
  _osu: array<vec4f, 4>,
  _oku: array<vec4f, 4>,
  _o6c: vec4f,
  _o4c: vec4f,
  _oth: u32,
  _odt: u32,
  _orb: u32,
  _orc: u32,
  _ot7: f32,
  _o4v: f32,
  _ojq: f32,
  _ojr: f32,
  _opx: f32,
  _obe: f32,
  _odr: f32,
  _odo: f32,
  _omy: u32,
  _o6e: u32,
  _o9p: u32,
  _ojn: u32,
};
