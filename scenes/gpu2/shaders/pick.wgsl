struct _o1l {
  _o7t: vec2f,
  _ojz: f32,
  _og0: f32,
  _o7h: u32,
  _ohz: u32,
  _oi0: u32,
  _oi1: u32,
};
@group(0) @binding(0) var<uniform> _oif: _o1l;
@group(0) @binding(1) var<uniform> _o5o: _oo;
@group(0) @binding(2) var<storage, read_write> _okr: array<atomic<u32>, 8>;
@group(0) @binding(3) var<storage, read> _orq: array<vec4f>;
@group(0) @binding(4) var<storage, read> _o9x: array<f32>;
@group(0) @binding(5) var<storage, read> _o39: array<f32>;
fn _oik(_odx: u32) -> f32 {
  return _o5o._oj5[_odx >> 2u][_odx & 3u];
}
fn _oqv(_odx: u32) -> f32 {
  return _o5o._oqq[_odx >> 2u][_odx & 3u];
}
fn _oj6(_ohn: vec3f) -> vec3f {
  let _oco = _ohn.x * _oik(0u) + _ohn.y * _oik(4u) + _ohn.z * _oik(8u) + _oik(12u);
  let _ocp = _ohn.x * _oik(1u) + _ohn.y * _oik(5u) + _ohn.z * _oik(9u) + _oik(13u);
  let _ocn = _ohn.x * _oik(3u) + _ohn.y * _oik(7u) + _ohn.z * _oik(11u) + _oik(15u);
  let _o8k = _ohn.x * _oqv(2u) + _ohn.y * _oqv(6u) + _ohn.z * _oqv(10u) + _oqv(14u);
  let w = max(_ocn, 1.0e-9);
  let _oja = ((_oco / w + 1.0) * f32(_o5o._ord) - 1.0) * 0.5;
  let _ojb = ((_ocp / w + 1.0) * f32(_o5o._ocf) - 1.0) * 0.5;
  return vec3f(_oja, _ojb, select(-1.0, _o8k, _ocn > 1.0e-6 && _o8k > _o5p()));
}
fn _o5p() -> f32 {
  return 0.01;
}
struct _o1e {
  _oh0: bool,
  _o8k: f32,
  _oil: vec3f,
};
fn _oqn(_ocr: u32) -> _o1e {
  var _ocl: _o1e;
  let _ohn = _orq[_ocr].xyz;
  let _ola = _oj6(_ohn);
  _ocl._oh0 = _ola.z > 0.0 && distance(_ola.xy, _oif._o7t) <= _oif._ojz;
  _ocl._o8k = _ola.z;
  _ocl._oil = _ohn;
  return _ocl;
}
fn _ol3(r: u32) -> _o1e {
  var _ocl: _o1e;
  _ocl._oh0 = false;
  if (_o39[r] < _oif._og0) {
    return _ocl;
  }
  let _o9n = 6u * r;
  let a = vec3f(_o9x[_o9n], _o9x[_o9n + 1u], _o9x[_o9n + 2u]);
  let b = vec3f(_o9x[_o9n + 3u], _o9x[_o9n + 4u], _o9x[_o9n + 5u]);
  let _oli = _oj6(a);
  let _oln = _oj6(b);
  if (_oli.z <= 0.0 || _oln.z <= 0.0) {
    return _ocl;
  }
  let ab = _oln.xy - _oli.xy;
  let _oeu = dot(ab, ab);
  var _oo6 = 0.0;
  if (_oeu > 1.0e-9) {
    _oo6 = clamp(dot(_oif._o7t - _oli.xy, ab) / _oeu, 0.0, 1.0);
  }
  let _ojc = _oli.xy + _oo6 * ab;
  _ocl._oh0 = distance(_ojc, _oif._o7t) <= _oif._ojz;
  _ocl._oil = a + _oo6 * (b - a);
  _ocl._o8k = _oli.z + _oo6 * (_oln.z - _oli.z);
  return _ocl;
}
fn _od3(_obm: vec3u, _ogn: vec3u) -> u32 {
  return _obm.x + _obm.y * _ogn.x * 256u;
}
@compute @workgroup_size(256)
fn pick_v_depth(@builtin(global_invocation_id) _obm: vec3u, @builtin(num_workgroups) _ogn: vec3u) {
  let _ocr = _od3(_obm, _ogn);
  if (_ocr >= _oif._o7h) { return; }
  let _oc0 = _oqn(_ocr);
  if (_oc0._oh0) { atomicMin(&_okr[0], bitcast<u32>(_oc0._o8k)); }
}
@compute @workgroup_size(256)
fn pick_v_index(@builtin(global_invocation_id) _obm: vec3u, @builtin(num_workgroups) _ogn: vec3u) {
  let _ocr = _od3(_obm, _ogn);
  if (_ocr >= _oif._o7h) { return; }
  let _oc0 = _oqn(_ocr);
  if (_oc0._oh0 && bitcast<u32>(_oc0._o8k) == atomicLoad(&_okr[0])) { atomicMin(&_okr[1], _ocr); }
}
@compute @workgroup_size(256)
fn pick_v_point(@builtin(global_invocation_id) _obm: vec3u, @builtin(num_workgroups) _ogn: vec3u) {
  let _ocr = _od3(_obm, _ogn);
  if (_ocr >= _oif._o7h || _ocr != atomicLoad(&_okr[1])) { return; }
  let _oc0 = _oqn(_ocr);
  atomicStore(&_okr[2], bitcast<u32>(_oc0._oil.x));
  atomicStore(&_okr[3], bitcast<u32>(_oc0._oil.y));
  atomicStore(&_okr[4], bitcast<u32>(_oc0._oil.z));
}
@compute @workgroup_size(256)
fn pick_r_depth(@builtin(global_invocation_id) _obm: vec3u, @builtin(num_workgroups) _ogn: vec3u) {
  let _ocr = _od3(_obm, _ogn);
  if (_ocr >= _oif._o7h) { return; }
  let _oc0 = _ol3(_ocr);
  if (_oc0._oh0) { atomicMin(&_okr[0], bitcast<u32>(_oc0._o8k)); }
}
@compute @workgroup_size(256)
fn pick_r_index(@builtin(global_invocation_id) _obm: vec3u, @builtin(num_workgroups) _ogn: vec3u) {
  let _ocr = _od3(_obm, _ogn);
  if (_ocr >= _oif._o7h) { return; }
  let _oc0 = _ol3(_ocr);
  if (_oc0._oh0 && bitcast<u32>(_oc0._o8k) == atomicLoad(&_okr[0])) { atomicMin(&_okr[1], _ocr); }
}
@compute @workgroup_size(256)
fn pick_r_point(@builtin(global_invocation_id) _obm: vec3u, @builtin(num_workgroups) _ogn: vec3u) {
  let _ocr = _od3(_obm, _ogn);
  if (_ocr >= _oif._o7h || _ocr != atomicLoad(&_okr[1])) { return; }
  let _oc0 = _ol3(_ocr);
  atomicStore(&_okr[2], bitcast<u32>(_oc0._oil.x));
  atomicStore(&_okr[3], bitcast<u32>(_oc0._oil.y));
  atomicStore(&_okr[4], bitcast<u32>(_oc0._oil.z));
}
