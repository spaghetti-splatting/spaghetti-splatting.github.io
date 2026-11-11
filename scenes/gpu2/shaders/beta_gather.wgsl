struct _o1j {
  _or4: u32,
  _ojn: u32,
  _ojo: u32,
  _ojp: u32,
};
@group(0) @binding(0) var<storage, read> _ofq: array<u32>;
@group(0) @binding(1) var<storage, read> _o3l: array<f32>;
@group(0) @binding(2) var<storage, read> _obd: array<f32>;
@group(0) @binding(3) var<storage, read> _ofs: array<f32>;
@group(0) @binding(4) var<storage, read> _or3: array<i32>;
@group(0) @binding(5) var<storage, read> _o8h: array<u32>;
@group(0) @binding(6) var<storage, read_write> _okn: array<vec4u>;
@group(0) @binding(7) var<uniform> _ocv: _o1j;
@compute @workgroup_size(256)
fn beta_gather(@builtin(local_invocation_index) _ogj: u32,
               @builtin(workgroup_id) _otg: vec3u,
               @builtin(num_workgroups) _oib: vec3u) {
  let _oea = _ogo(_otg, _oib) * _o2q + _ogj;
  if (_oea >= _o8h[_o23]) {
    return;
  }
  let _omw = _ofq[_oea];
  let _o3k = _o3l[_omw] * _obd[_omw];
  var _oon = -1;
  if (_ocv._or4 != 0u) {
    _oon = _or3[_omw];
  }
  _okn[_oea] = vec4u(bitcast<u32>(_o3k), bitcast<u32>(_ofs[_omw]),
                        bitcast<u32>(_oon), 0u);
}
