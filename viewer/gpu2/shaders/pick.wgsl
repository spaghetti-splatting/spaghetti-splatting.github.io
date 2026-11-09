struct _o1q {
  _o7z: vec2f,
  _okj: f32,
  _ogj: f32,
  _o7l: u32,
  _oig: u32,
  _oih: u32,
  _oii: u32,
};
@group(0) @binding(0) var<uniform> _oix: _o1q;
@group(0) @binding(1) var<uniform> _o5x: _oo;
@group(0) @binding(2) var<storage, read_write> _ole: array<atomic<u32>, 8>;
@group(0) @binding(3) var<storage, read> _osn: array<vec4f>;
@group(0) @binding(4) var<storage, read> _oa9: array<f32>;
@group(0) @binding(5) var<storage, read> _o3g: array<f32>;
@group(0) @binding(6) var<storage, read> _ofl: array<vec2u>;
fn _oj2(_oed: u32) -> f32 {
  return _o5x._ojs[_oed >> 2u][_oed & 3u];
}
fn _orm(_oed: u32) -> f32 {
  return _o5x._orh[_oed >> 2u][_oed & 3u];
}
fn _ojt(_oi3: vec3f) -> vec3f {
  let _od4 = _oi3.x * _oj2(0u) + _oi3.y * _oj2(4u) + _oi3.z * _oj2(8u) + _oj2(12u);
  let _od5 = _oi3.x * _oj2(1u) + _oi3.y * _oj2(5u) + _oi3.z * _oj2(9u) + _oj2(13u);
  let _od3 = _oi3.x * _oj2(3u) + _oi3.y * _oj2(7u) + _oi3.z * _oj2(11u) + _oj2(15u);
  let _o8v = _oi3.x * _orm(2u) + _oi3.y * _orm(6u) + _oi3.z * _orm(10u) + _orm(14u);
  let w = max(_od3, 1.0e-9);
  let _ojw = ((_od4 / w + 1.0) * f32(_o5x._os6) - 1.0) * 0.5;
  let _ojx = ((_od5 / w + 1.0) * f32(_o5x._ocv) - 1.0) * 0.5;
  return vec3f(_ojw, _ojx, select(-1.0, _o8v, _od3 > 1.0e-6 && _o8v > _o5y()));
}
fn _o5y() -> f32 {
  return 0.01;
}
struct _o1f {
  _ohg: bool,
  _o8v: f32,
  _oj3: vec3f,
};
fn _ord(_od7: u32) -> _o1f {
  var _od0: _o1f;
  let _oi3 = _osn[_od7].xyz;
  let _olx = _ojt(_oi3);
  _od0._ohg = _ofl[_od7].y != 0xffffffffu && _olx.z > 0.0 && distance(_olx.xy, _oix._o7z) <= _oix._okj;
  _od0._o8v = _olx.z;
  _od0._oj3 = _oi3;
  return _od0;
}
fn _olp(r: u32) -> _o1f {
  var _od0: _o1f;
  _od0._ohg = false;
  if (_o3g[r] < _oix._ogj) {
    return _od0;
  }
  let _o9z = 6u * r;
  let a = vec3f(_oa9[_o9z], _oa9[_o9z + 1u], _oa9[_o9z + 2u]);
  let b = vec3f(_oa9[_o9z + 3u], _oa9[_o9z + 4u], _oa9[_o9z + 5u]);
  let _om5 = _ojt(a);
  let _om9 = _ojt(b);
  if (_om5.z <= 0.0 || _om9.z <= 0.0) {
    return _od0;
  }
  let ab = _om9.xy - _om5.xy;
  let _ofb = dot(ab, ab);
  var _oou = 0.0;
  if (_ofb > 1.0e-9) {
    _oou = clamp(dot(_oix._o7z - _om5.xy, ab) / _ofb, 0.0, 1.0);
  }
  let _ojy = _om5.xy + _oou * ab;
  _od0._ohg = distance(_ojy, _oix._o7z) <= _oix._okj;
  _od0._oj3 = a + _oou * (b - a);
  _od0._o8v = _om5.z + _oou * (_om9.z - _om5.z);
  return _od0;
}
fn _odj(_oc1: vec3u, _oh4: vec3u) -> u32 {
  return _oc1.x + _oc1.y * _oh4.x * 256u;
}
@compute @workgroup_size(256)
fn pick_v_depth(@builtin(global_invocation_id) _oc1: vec3u, @builtin(num_workgroups) _oh4: vec3u) {
  let _od7 = _odj(_oc1, _oh4);
  if (_od7 >= _oix._o7l) { return; }
  let _och = _ord(_od7);
  if (_och._ohg) { atomicMin(&_ole[0], bitcast<u32>(_och._o8v)); }
}
@compute @workgroup_size(256)
fn pick_v_index(@builtin(global_invocation_id) _oc1: vec3u, @builtin(num_workgroups) _oh4: vec3u) {
  let _od7 = _odj(_oc1, _oh4);
  if (_od7 >= _oix._o7l) { return; }
  let _och = _ord(_od7);
  if (_och._ohg && bitcast<u32>(_och._o8v) == atomicLoad(&_ole[0])) { atomicMin(&_ole[1], _od7); }
}
@compute @workgroup_size(256)
fn pick_v_point(@builtin(global_invocation_id) _oc1: vec3u, @builtin(num_workgroups) _oh4: vec3u) {
  let _od7 = _odj(_oc1, _oh4);
  if (_od7 >= _oix._o7l || _od7 != atomicLoad(&_ole[1])) { return; }
  let _och = _ord(_od7);
  atomicStore(&_ole[2], bitcast<u32>(_och._oj3.x));
  atomicStore(&_ole[3], bitcast<u32>(_och._oj3.y));
  atomicStore(&_ole[4], bitcast<u32>(_och._oj3.z));
}
@compute @workgroup_size(256)
fn pick_r_depth(@builtin(global_invocation_id) _oc1: vec3u, @builtin(num_workgroups) _oh4: vec3u) {
  let _od7 = _odj(_oc1, _oh4);
  if (_od7 >= _oix._o7l) { return; }
  let _och = _olp(_od7);
  if (_och._ohg) { atomicMin(&_ole[0], bitcast<u32>(_och._o8v)); }
}
@compute @workgroup_size(256)
fn pick_r_index(@builtin(global_invocation_id) _oc1: vec3u, @builtin(num_workgroups) _oh4: vec3u) {
  let _od7 = _odj(_oc1, _oh4);
  if (_od7 >= _oix._o7l) { return; }
  let _och = _olp(_od7);
  if (_och._ohg && bitcast<u32>(_och._o8v) == atomicLoad(&_ole[0])) { atomicMin(&_ole[1], _od7); }
}
@compute @workgroup_size(256)
fn pick_r_point(@builtin(global_invocation_id) _oc1: vec3u, @builtin(num_workgroups) _oh4: vec3u) {
  let _od7 = _odj(_oc1, _oh4);
  if (_od7 >= _oix._o7l || _od7 != atomicLoad(&_ole[1])) { return; }
  let _och = _olp(_od7);
  atomicStore(&_ole[2], bitcast<u32>(_och._oj3.x));
  atomicStore(&_ole[3], bitcast<u32>(_och._oj3.y));
  atomicStore(&_ole[4], bitcast<u32>(_och._oj3.z));
}
