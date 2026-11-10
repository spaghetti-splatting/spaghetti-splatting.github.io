struct _o1l {
  _o7s: vec2f,
  _ojy: f32,
  _ofz: f32,
  _o7g: u32,
  _ohy: u32,
  _ohz: u32,
  _oi0: u32,
};
@group(0) @binding(0) var<uniform> _oie: _o1l;
@group(0) @binding(1) var<uniform> _o5o: _oo;
@group(0) @binding(2) var<storage, read_write> _okq: array<atomic<u32>, 8>;
@group(0) @binding(3) var<storage, read> _orp: array<vec4f>;
@group(0) @binding(4) var<storage, read> _o9w: array<f32>;
@group(0) @binding(5) var<storage, read> _o39: array<f32>;
fn _oij(_odw: u32) -> f32 {
  return _o5o._oj4[_odw >> 2u][_odw & 3u];
}
fn _oqu(_odw: u32) -> f32 {
  return _o5o._oqp[_odw >> 2u][_odw & 3u];
}
fn _oj5(_ohm: vec3f) -> vec3f {
  let _ocn = _ohm.x * _oij(0u) + _ohm.y * _oij(4u) + _ohm.z * _oij(8u) + _oij(12u);
  let _oco = _ohm.x * _oij(1u) + _ohm.y * _oij(5u) + _ohm.z * _oij(9u) + _oij(13u);
  let _ocm = _ohm.x * _oij(3u) + _ohm.y * _oij(7u) + _ohm.z * _oij(11u) + _oij(15u);
  let _o8j = _ohm.x * _oqu(2u) + _ohm.y * _oqu(6u) + _ohm.z * _oqu(10u) + _oqu(14u);
  let w = max(_ocm, 1.0e-9);
  let _oj9 = ((_ocn / w + 1.0) * f32(_o5o._orc) - 1.0) * 0.5;
  let _oja = ((_oco / w + 1.0) * f32(_o5o._oce) - 1.0) * 0.5;
  return vec3f(_oj9, _oja, select(-1.0, _o8j, _ocm > 1.0e-6 && _o8j > _o5p()));
}
fn _o5p() -> f32 {
  return 0.01;
}
struct _o1e {
  _ogz: bool,
  _o8j: f32,
  _oik: vec3f,
};
fn _oqm(_ocq: u32) -> _o1e {
  var _ock: _o1e;
  let _ohm = _orp[_ocq].xyz;
  let _ol9 = _oj5(_ohm);
  _ock._ogz = _ol9.z > 0.0 && distance(_ol9.xy, _oie._o7s) <= _oie._ojy;
  _ock._o8j = _ol9.z;
  _ock._oik = _ohm;
  return _ock;
}
fn _ol2(r: u32) -> _o1e {
  var _ock: _o1e;
  _ock._ogz = false;
  if (_o39[r] < _oie._ofz) {
    return _ock;
  }
  let _o9m = 6u * r;
  let a = vec3f(_o9w[_o9m], _o9w[_o9m + 1u], _o9w[_o9m + 2u]);
  let b = vec3f(_o9w[_o9m + 3u], _o9w[_o9m + 4u], _o9w[_o9m + 5u]);
  let _olh = _oj5(a);
  let _olm = _oj5(b);
  if (_olh.z <= 0.0 || _olm.z <= 0.0) {
    return _ock;
  }
  let ab = _olm.xy - _olh.xy;
  let _oet = dot(ab, ab);
  var _oo5 = 0.0;
  if (_oet > 1.0e-9) {
    _oo5 = clamp(dot(_oie._o7s - _olh.xy, ab) / _oet, 0.0, 1.0);
  }
  let _ojb = _olh.xy + _oo5 * ab;
  _ock._ogz = distance(_ojb, _oie._o7s) <= _oie._ojy;
  _ock._oik = a + _oo5 * (b - a);
  _ock._o8j = _olh.z + _oo5 * (_olm.z - _olh.z);
  return _ock;
}
fn _od2(_obl: vec3u, _ogm: vec3u) -> u32 {
  return _obl.x + _obl.y * _ogm.x * 256u;
}
@compute @workgroup_size(256)
fn pick_v_depth(@builtin(global_invocation_id) _obl: vec3u, @builtin(num_workgroups) _ogm: vec3u) {
  let _ocq = _od2(_obl, _ogm);
  if (_ocq >= _oie._o7g) { return; }
  let _obz = _oqm(_ocq);
  if (_obz._ogz) { atomicMin(&_okq[0], bitcast<u32>(_obz._o8j)); }
}
@compute @workgroup_size(256)
fn pick_v_index(@builtin(global_invocation_id) _obl: vec3u, @builtin(num_workgroups) _ogm: vec3u) {
  let _ocq = _od2(_obl, _ogm);
  if (_ocq >= _oie._o7g) { return; }
  let _obz = _oqm(_ocq);
  if (_obz._ogz && bitcast<u32>(_obz._o8j) == atomicLoad(&_okq[0])) { atomicMin(&_okq[1], _ocq); }
}
@compute @workgroup_size(256)
fn pick_v_point(@builtin(global_invocation_id) _obl: vec3u, @builtin(num_workgroups) _ogm: vec3u) {
  let _ocq = _od2(_obl, _ogm);
  if (_ocq >= _oie._o7g || _ocq != atomicLoad(&_okq[1])) { return; }
  let _obz = _oqm(_ocq);
  atomicStore(&_okq[2], bitcast<u32>(_obz._oik.x));
  atomicStore(&_okq[3], bitcast<u32>(_obz._oik.y));
  atomicStore(&_okq[4], bitcast<u32>(_obz._oik.z));
}
@compute @workgroup_size(256)
fn pick_r_depth(@builtin(global_invocation_id) _obl: vec3u, @builtin(num_workgroups) _ogm: vec3u) {
  let _ocq = _od2(_obl, _ogm);
  if (_ocq >= _oie._o7g) { return; }
  let _obz = _ol2(_ocq);
  if (_obz._ogz) { atomicMin(&_okq[0], bitcast<u32>(_obz._o8j)); }
}
@compute @workgroup_size(256)
fn pick_r_index(@builtin(global_invocation_id) _obl: vec3u, @builtin(num_workgroups) _ogm: vec3u) {
  let _ocq = _od2(_obl, _ogm);
  if (_ocq >= _oie._o7g) { return; }
  let _obz = _ol2(_ocq);
  if (_obz._ogz && bitcast<u32>(_obz._o8j) == atomicLoad(&_okq[0])) { atomicMin(&_okq[1], _ocq); }
}
@compute @workgroup_size(256)
fn pick_r_point(@builtin(global_invocation_id) _obl: vec3u, @builtin(num_workgroups) _ogm: vec3u) {
  let _ocq = _od2(_obl, _ogm);
  if (_ocq >= _oie._o7g || _ocq != atomicLoad(&_okq[1])) { return; }
  let _obz = _ol2(_ocq);
  atomicStore(&_okq[2], bitcast<u32>(_obz._oik.x));
  atomicStore(&_okq[3], bitcast<u32>(_obz._oik.y));
  atomicStore(&_okq[4], bitcast<u32>(_obz._oik.z));
}
