struct _o1c {
  _op2: u32,
  _ohz: u32,
  _oi0: u32,
  _oi1: u32,
};
@group(0) @binding(0) var<storage, read> _oe8: array<u32>;
@group(0) @binding(1) var<storage, read> _o39: array<f32>;
@group(0) @binding(2) var<storage, read> _oag: array<f32>;
@group(0) @binding(3) var<storage, read> _oea: array<f32>;
@group(0) @binding(4) var<storage, read> _op1: array<i32>;
@group(0) @binding(5) var<storage, read> _o7m: array<u32>;
@group(0) @binding(6) var<storage, read_write> _oiy: array<vec4u>;
@group(0) @binding(7) var<uniform> _obj: _o1c;
@compute @workgroup_size(256)
fn beta_gather(@builtin(local_invocation_index) _oey: u32,
               @builtin(workgroup_id) _orc: vec3u,
               @builtin(num_workgroups) _ogn: vec3u) {
  let _ocu = _of3(_orc, _ogn) * _o2h + _oey;
  if (_ocu >= _o7m[_o1u]) {
    return;
  }
  let _ol2 = _oe8[_ocu];
  let _o38 = _o39[_ol2] * _oag[_ol2];
  var _omq = -1;
  if (_obj._op2 != 0u) {
    _omq = _op1[_ol2];
  }
  _oiy[_ocu] = vec4u(bitcast<u32>(_o38), bitcast<u32>(_oea[_ol2]),
                        bitcast<u32>(_omq), 0u);
}
