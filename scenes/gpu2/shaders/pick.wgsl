struct _o1n {
  _o8a: vec2f,
  _oko: f32,
  _ogo: f32,
  _o7y: u32,
  _oio: u32,
  _oip: u32,
  _oiq: u32,
};
@group(0) @binding(0) var<uniform> _oj4: _o1n;
@group(0) @binding(1) var<uniform> _o5v: _oo;
@group(0) @binding(2) var<storage, read_write> _olg: array<atomic<u32>, 8>;
@group(0) @binding(3) var<storage, read> _osl: array<vec4f>;
@group(0) @binding(4) var<storage, read> _oae: array<f32>;
@group(0) @binding(5) var<storage, read> _o3d: array<f32>;
fn _oj9(_oei: u32) -> f32 {
  return _o5v._oju[_oei >> 2u][_oei & 3u];
}
fn _orp(_oei: u32) -> f32 {
  return _o5v._ork[_oei >> 2u][_oei & 3u];
}
fn _ojv(_oic: vec3f) -> vec3f {
  let _od9 = _oic.x * _oj9(0u) + _oic.y * _oj9(4u) + _oic.z * _oj9(8u) + _oj9(12u);
  let _oda = _oic.x * _oj9(1u) + _oic.y * _oj9(5u) + _oic.z * _oj9(9u) + _oj9(13u);
  let _od8 = _oic.x * _oj9(3u) + _oic.y * _oj9(7u) + _oic.z * _oj9(11u) + _oj9(15u);
  let _o91 = _oic.x * _orp(2u) + _oic.y * _orp(6u) + _oic.z * _orp(10u) + _orp(14u);
  let w = max(_od8, 1.0e-9);
  let _ojz = ((_od9 / w + 1.0) * f32(_o5v._os7) - 1.0) * 0.5;
  let _ok0 = ((_oda / w + 1.0) * f32(_o5v._ocy) - 1.0) * 0.5;
  return vec3f(_ojz, _ok0, select(-1.0, _o91, _od8 > 1.0e-6 && _o91 > _o5w()));
}
fn _o5w() -> f32 {
  return 0.01;
}
struct _o1g {
  _ohp: bool,
  _o91: f32,
  _oja: vec3f,
};
fn _orh(_odc: u32) -> _o1g {
  var _od5: _o1g;
  let _oic = _osl[_odc].xyz;
  let _olz = _ojv(_oic);
  _od5._ohp = _olz.z > 0.0 && distance(_olz.xy, _oj4._o8a) <= _oj4._oko;
  _od5._o91 = _olz.z;
  _od5._oja = _oic;
  return _od5;
}
fn _ols(r: u32) -> _o1g {
  var _od5: _o1g;
  _od5._ohp = false;
  if (_o3d[r] < _oj4._ogo) {
    return _od5;
  }
  let _oa4 = 6u * r;
  let a = vec3f(_oae[_oa4], _oae[_oa4 + 1u], _oae[_oa4 + 2u]);
  let b = vec3f(_oae[_oa4 + 3u], _oae[_oa4 + 4u], _oae[_oa4 + 5u]);
  let _om7 = _ojv(a);
  let _omc = _ojv(b);
  if (_om7.z <= 0.0 || _omc.z <= 0.0) {
    return _od5;
  }
  let ab = _omc.xy - _om7.xy;
  let _ofh = dot(ab, ab);
  var _ooz = 0.0;
  if (_ofh > 1.0e-9) {
    _ooz = clamp(dot(_oj4._o8a - _om7.xy, ab) / _ofh, 0.0, 1.0);
  }
  let _ok1 = _om7.xy + _ooz * ab;
  _od5._ohp = distance(_ok1, _oj4._o8a) <= _oj4._oko;
  _od5._oja = a + _ooz * (b - a);
  _od5._o91 = _om7.z + _ooz * (_omc.z - _om7.z);
  return _od5;
}
fn _odo(_oc4: vec3u, _ohc: vec3u) -> u32 {
  return _oc4.x + _oc4.y * _ohc.x * 256u;
}
@compute @workgroup_size(256)
fn pick_v_depth(@builtin(global_invocation_id) _oc4: vec3u, @builtin(num_workgroups) _ohc: vec3u) {
  let _odc = _odo(_oc4, _ohc);
  if (_odc >= _oj4._o7y) { return; }
  let _oci = _orh(_odc);
  if (_oci._ohp) { atomicMin(&_olg[0], bitcast<u32>(_oci._o91)); }
}
@compute @workgroup_size(256)
fn pick_v_index(@builtin(global_invocation_id) _oc4: vec3u, @builtin(num_workgroups) _ohc: vec3u) {
  let _odc = _odo(_oc4, _ohc);
  if (_odc >= _oj4._o7y) { return; }
  let _oci = _orh(_odc);
  if (_oci._ohp && bitcast<u32>(_oci._o91) == atomicLoad(&_olg[0])) { atomicMin(&_olg[1], _odc); }
}
@compute @workgroup_size(256)
fn pick_v_point(@builtin(global_invocation_id) _oc4: vec3u, @builtin(num_workgroups) _ohc: vec3u) {
  let _odc = _odo(_oc4, _ohc);
  if (_odc >= _oj4._o7y || _odc != atomicLoad(&_olg[1])) { return; }
  let _oci = _orh(_odc);
  atomicStore(&_olg[2], bitcast<u32>(_oci._oja.x));
  atomicStore(&_olg[3], bitcast<u32>(_oci._oja.y));
  atomicStore(&_olg[4], bitcast<u32>(_oci._oja.z));
}
@compute @workgroup_size(256)
fn pick_r_depth(@builtin(global_invocation_id) _oc4: vec3u, @builtin(num_workgroups) _ohc: vec3u) {
  let _odc = _odo(_oc4, _ohc);
  if (_odc >= _oj4._o7y) { return; }
  let _oci = _ols(_odc);
  if (_oci._ohp) { atomicMin(&_olg[0], bitcast<u32>(_oci._o91)); }
}
@compute @workgroup_size(256)
fn pick_r_index(@builtin(global_invocation_id) _oc4: vec3u, @builtin(num_workgroups) _ohc: vec3u) {
  let _odc = _odo(_oc4, _ohc);
  if (_odc >= _oj4._o7y) { return; }
  let _oci = _ols(_odc);
  if (_oci._ohp && bitcast<u32>(_oci._o91) == atomicLoad(&_olg[0])) { atomicMin(&_olg[1], _odc); }
}
@compute @workgroup_size(256)
fn pick_r_point(@builtin(global_invocation_id) _oc4: vec3u, @builtin(num_workgroups) _ohc: vec3u) {
  let _odc = _odo(_oc4, _ohc);
  if (_odc >= _oj4._o7y || _odc != atomicLoad(&_olg[1])) { return; }
  let _oci = _ols(_odc);
  atomicStore(&_olg[2], bitcast<u32>(_oci._oja.x));
  atomicStore(&_olg[3], bitcast<u32>(_oci._oja.y));
  atomicStore(&_olg[4], bitcast<u32>(_oci._oja.z));
}
