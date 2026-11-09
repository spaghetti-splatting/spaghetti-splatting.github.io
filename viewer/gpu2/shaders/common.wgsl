const _o2o: u32 = 256u;
const _o25: u32 = 0u;
const _o21: u32 = 1u;
const _o22: u32 = 2u;
const _o23: u32 = 3u;
const _o27: u32 = 4u;
const _o26: u32 = 5u;
const _o20: u32 = 6u;
const _o24: u32 = 16u;
fn _ofj(_os5: vec3u, _oh4: vec3u) -> u32 {
  return _os5.x + _os5.y * _oh4.x;
}
fn _oqa(a: f32, b: f32) -> vec2f {
  let _olx = a + b;
  let bb = _olx - a;
  let _o9z = (a - (_olx - bb)) + (b - bb);
  return vec2f(_olx, _o9z);
}
fn _onr(a: f32) -> vec2f {
  let _oou = 4097.0 * a;
  let _ocx = _oou - (_oou - a);
  return vec2f(_ocx, a - _ocx);
}
fn _oq9(a: f32, b: f32) -> vec2f {
  let _oi3 = a * b;
  let _om5 = _onr(a);
  let _om9 = _onr(b);
  let _o9z = ((_om5.x * _om9.x - _oi3) + _om5.x * _om9.y + _om5.y * _om9.x) + _om5.y * _om9.y;
  return vec2f(_oi3, _o9z);
}
fn _o37(a: f32, b: f32) -> f32 {
  let r = _oqa(a, b);
  var _o4v = bitcast<u32>(r.x);
  if (r.y != 0.0 && (_o4v & 1u) == 0u) {
    if ((r.y > 0.0) == (r.x > 0.0)) {
      _o4v = _o4v + 1u;
    } else {
      _o4v = _o4v - 1u;
    }
  }
  return bitcast<f32>(_o4v);
}
fn _obc(a: f32, b: f32, _o58: f32) -> f32 {
  let _oi3 = _oq9(a, b);
  let _oou = _oqa(_o58, _oi3.y);
  let _or2 = _oqa(_oi3.x, _oou.x);
  let z = _o37(_oou.y, _or2.y);
  return _or2.x + z;
}
fn _oe0(x: f32) -> bool {
  return (bitcast<u32>(x) & 0x7fffffffu) > 0x7f800000u;
}
fn _odz(x: f32) -> bool {
  return (bitcast<u32>(x) & 0x7f800000u) != 0x7f800000u;
}
fn _obd(a: f32, b: f32) -> f32 {
  if (_oe0(a)) { return b; }
  if (_oe0(b)) { return a; }
  return max(a, b);
}
fn _obe(a: f32, b: f32) -> f32 {
  if (_oe0(a)) { return b; }
  if (_oe0(b)) { return a; }
  return min(a, b);
}
fn _on4(x: f32) -> bool {
  return (bitcast<u32>(x) & 0x80000000u) != 0u;
}
struct _oo {
  _orh: array<vec4f, 4>,
  _ojs: array<vec4f, 4>,
  _o60: vec4f,
  _o46: vec4f,
  _os6: u32,
  _ocv: u32,
  _opw: u32,
  _opx: u32,
  _orw: f32,
  _o4n: f32,
  _oij: f32,
  _oik: f32,
  _ooj: f32,
  _oav: f32,
  _ocr: f32,
  _oco: f32,
  _olq: u32,
  _o62: u32,
  _o95: u32,
  _oig: u32,
};
