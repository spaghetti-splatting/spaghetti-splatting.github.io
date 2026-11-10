struct _o1e {
  _opv: u32,
  _oio: u32,
  _oip: u32,
  _oiq: u32,
};
@group(0) @binding(0) var<storage, read> _oev: array<u32>;
@group(0) @binding(1) var<storage, read> _o3d: array<f32>;
@group(0) @binding(2) var<storage, read> _oax: array<f32>;
@group(0) @binding(3) var<storage, read> _oex: array<f32>;
@group(0) @binding(4) var<storage, read> _opu: array<i32>;
@group(0) @binding(5) var<storage, read> _o83: array<u32>;
@group(0) @binding(6) var<storage, read_write> _ojn: array<vec4u>;
@group(0) @binding(7) var<uniform> _oc1: _o1e;
@compute @workgroup_size(256)
fn beta_gather(@builtin(local_invocation_index) _ofl: u32,
               @builtin(workgroup_id) _os6: vec3u,
               @builtin(num_workgroups) _ohc: vec3u) {
  let _odf = _ofq(_os6, _ohc) * _o2j + _ofl;
  if (_odf >= _o83[_o1w]) {
    return;
  }
  let _olr = _oev[_odf];
  let _o3c = _o3d[_olr] * _oax[_olr];
  var _oni = -1;
  if (_oc1._opv != 0u) {
    _oni = _opu[_olr];
  }
  _ojn[_odf] = vec4u(bitcast<u32>(_o3c), bitcast<u32>(_oex[_olr]),
                        bitcast<u32>(_oni), 0u);
}
