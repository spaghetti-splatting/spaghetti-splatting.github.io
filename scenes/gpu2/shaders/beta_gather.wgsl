struct _o1c {
  _op1: u32,
  _ohy: u32,
  _ohz: u32,
  _oi0: u32,
};
@group(0) @binding(0) var<storage, read> _oe7: array<u32>;
@group(0) @binding(1) var<storage, read> _o39: array<f32>;
@group(0) @binding(2) var<storage, read> _oaf: array<f32>;
@group(0) @binding(3) var<storage, read> _oe9: array<f32>;
@group(0) @binding(4) var<storage, read> _op0: array<i32>;
@group(0) @binding(5) var<storage, read> _o7l: array<u32>;
@group(0) @binding(6) var<storage, read_write> _oix: array<vec4u>;
@group(0) @binding(7) var<uniform> _obi: _o1c;
@compute @workgroup_size(256)
fn beta_gather(@builtin(local_invocation_index) _oex: u32,
               @builtin(workgroup_id) _orb: vec3u,
               @builtin(num_workgroups) _ogm: vec3u) {
  let _oct = _of2(_orb, _ogm) * _o2h + _oex;
  if (_oct >= _o7l[_o1u]) {
    return;
  }
  let _ol1 = _oe7[_oct];
  let _o38 = _o39[_ol1] * _oaf[_ol1];
  var _omp = -1;
  if (_obi._op1 != 0u) {
    _omp = _op0[_ol1];
  }
  _oix[_oct] = vec4u(bitcast<u32>(_o38), bitcast<u32>(_oe9[_ol1]),
                        bitcast<u32>(_omp), 0u);
}
