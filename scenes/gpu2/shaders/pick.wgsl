struct _o1u {
  _o8o: vec2f,
  _ols: f32,
  _ohn: f32,
  _o8c: u32,
  _ojn: u32,
  _ojo: u32,
  _ojp: u32,
};
@group(0) @binding(0) var<uniform> _ok4: _o1u;
@group(0) @binding(1) var<uniform> _o69: _oo;
@group(0) @binding(2) var<storage, read_write> _oml: array<atomic<u32>, 8>;
@group(0) @binding(3) var<storage, read> _otv: array<vec4f>;
@group(0) @binding(4) var<storage, read> _oau: array<f32>;
@group(0) @binding(5) var<storage, read> _o3l: array<f32>;
fn _ok9(_ofd: u32) -> f32 {
  return _o69._oku[_ofd >> 2u][_ofd & 3u];
}
fn _osz(_ofd: u32) -> f32 {
  return _o69._osu[_ofd >> 2u][_ofd & 3u];
}
fn _okv(_ojb: vec3f) -> vec3f {
  let _oe4 = _ojb.x * _ok9(0u) + _ojb.y * _ok9(4u) + _ojb.z * _ok9(8u) + _ok9(12u);
  let _oe5 = _ojb.x * _ok9(1u) + _ojb.y * _ok9(5u) + _ojb.z * _ok9(9u) + _ok9(13u);
  let _oe3 = _ojb.x * _ok9(3u) + _ojb.y * _ok9(7u) + _ojb.z * _ok9(11u) + _ok9(15u);
  let _o9f = _ojb.x * _osz(2u) + _ojb.y * _osz(6u) + _ojb.z * _osz(10u) + _osz(14u);
  let w = max(_oe3, 1.0e-9);
  let _okz = ((_oe4 / w + 1.0) * f32(_o69._oth) - 1.0) * 0.5;
  let _ol0 = ((_oe5 / w + 1.0) * f32(_o69._odt) - 1.0) * 0.5;
  return vec3f(_okz, _ol0, select(-1.0, _o9f, _oe3 > 1.0e-6 && _o9f > _o6a()));
}
fn _o6a() -> f32 {
  return 0.01;
}
struct _o1l {
  _oio: bool,
  _o9f: f32,
  _oka: vec3f,
};
fn _osr(_oe7: u32) -> _o1l {
  var _oe0: _o1l;
  let _ojb = _otv[_oe7].xyz;
  let _on4 = _okv(_ojb);
  _oe0._oio = _on4.z > 0.0 && distance(_on4.xy, _ok4._o8o) <= _ok4._ols;
  _oe0._o9f = _on4.z;
  _oe0._oka = _ojb;
  return _oe0;
}
fn _omx(r: u32) -> _o1l {
  var _oe0: _o1l;
  _oe0._oio = false;
  if (_o3l[r] < _ok4._ohn) {
    return _oe0;
  }
  let _oaj = 6u * r;
  let a = vec3f(_oau[_oaj], _oau[_oaj + 1u], _oau[_oaj + 2u]);
  let b = vec3f(_oau[_oaj + 3u], _oau[_oaj + 4u], _oau[_oaj + 5u]);
  let _onc = _okv(a);
  let _onh = _okv(b);
  if (_onc.z <= 0.0 || _onh.z <= 0.0) {
    return _oe0;
  }
  let ab = _onh.xy - _onc.xy;
  let _ogf = dot(ab, ab);
  var _oq8 = 0.0;
  if (_ogf > 1.0e-9) {
    _oq8 = clamp(dot(_ok4._o8o - _onc.xy, ab) / _ogf, 0.0, 1.0);
  }
  let _ol1 = _onc.xy + _oq8 * ab;
  _oe0._oio = distance(_ol1, _ok4._o8o) <= _ok4._ols;
  _oe0._oka = a + _oq8 * (b - a);
  _oe0._o9f = _onc.z + _oq8 * (_onh.z - _onc.z);
  return _oe0;
}
fn _oej(_ocy: vec3u, _oib: vec3u) -> u32 {
  return _ocy.x + _ocy.y * _oib.x * 256u;
}
@compute @workgroup_size(256)
fn pick_v_depth(@builtin(global_invocation_id) _ocy: vec3u, @builtin(num_workgroups) _oib: vec3u) {
  let _oe7 = _oej(_ocy, _oib);
  if (_oe7 >= _ok4._o8c) { return; }
  let _odd = _osr(_oe7);
  if (_odd._oio) { atomicMin(&_oml[0], bitcast<u32>(_odd._o9f)); }
}
@compute @workgroup_size(256)
fn pick_v_index(@builtin(global_invocation_id) _ocy: vec3u, @builtin(num_workgroups) _oib: vec3u) {
  let _oe7 = _oej(_ocy, _oib);
  if (_oe7 >= _ok4._o8c) { return; }
  let _odd = _osr(_oe7);
  if (_odd._oio && bitcast<u32>(_odd._o9f) == atomicLoad(&_oml[0])) { atomicMin(&_oml[1], _oe7); }
}
@compute @workgroup_size(256)
fn pick_v_point(@builtin(global_invocation_id) _ocy: vec3u, @builtin(num_workgroups) _oib: vec3u) {
  let _oe7 = _oej(_ocy, _oib);
  if (_oe7 >= _ok4._o8c || _oe7 != atomicLoad(&_oml[1])) { return; }
  let _odd = _osr(_oe7);
  atomicStore(&_oml[2], bitcast<u32>(_odd._oka.x));
  atomicStore(&_oml[3], bitcast<u32>(_odd._oka.y));
  atomicStore(&_oml[4], bitcast<u32>(_odd._oka.z));
}
@compute @workgroup_size(256)
fn pick_r_depth(@builtin(global_invocation_id) _ocy: vec3u, @builtin(num_workgroups) _oib: vec3u) {
  let _oe7 = _oej(_ocy, _oib);
  if (_oe7 >= _ok4._o8c) { return; }
  let _odd = _omx(_oe7);
  if (_odd._oio) { atomicMin(&_oml[0], bitcast<u32>(_odd._o9f)); }
}
@compute @workgroup_size(256)
fn pick_r_index(@builtin(global_invocation_id) _ocy: vec3u, @builtin(num_workgroups) _oib: vec3u) {
  let _oe7 = _oej(_ocy, _oib);
  if (_oe7 >= _ok4._o8c) { return; }
  let _odd = _omx(_oe7);
  if (_odd._oio && bitcast<u32>(_odd._o9f) == atomicLoad(&_oml[0])) { atomicMin(&_oml[1], _oe7); }
}
@compute @workgroup_size(256)
fn pick_r_point(@builtin(global_invocation_id) _ocy: vec3u, @builtin(num_workgroups) _oib: vec3u) {
  let _oe7 = _oej(_ocy, _oib);
  if (_oe7 >= _ok4._o8c || _oe7 != atomicLoad(&_oml[1])) { return; }
  let _odd = _omx(_oe7);
  atomicStore(&_oml[2], bitcast<u32>(_odd._oka.x));
  atomicStore(&_oml[3], bitcast<u32>(_odd._oka.y));
  atomicStore(&_oml[4], bitcast<u32>(_odd._oka.z));
}
