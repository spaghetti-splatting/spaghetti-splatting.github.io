struct _o1c {
  _opp: u32,
  _oig: u32,
  _oih: u32,
  _oii: u32,
};
@group(0) @binding(0) var<storage, read> _oeo: array<u32>;
@group(0) @binding(1) var<storage, read> _o3g: array<f32>;
@group(0) @binding(2) var<storage, read> _oau: array<f32>;
@group(0) @binding(3) var<storage, read> _oeq: array<f32>;
@group(0) @binding(4) var<storage, read> _opo: array<i32>;
@group(0) @binding(5) var<storage, read> _o7r: array<u32>;
@group(0) @binding(6) var<storage, read_write> _ojl: array<vec4u>;
@group(0) @binding(7) var<uniform> _oby: _o1c;
@compute @workgroup_size(256)
fn beta_gather(@builtin(local_invocation_index) _ofg: u32,
               @builtin(workgroup_id) _os5: vec3u,
               @builtin(num_workgroups) _oh4: vec3u) {
  let _odb = _ofj(_os5, _oh4) * _o2o + _ofg;
  if (_odb >= _o7r[_o21]) {
    return;
  }
  let _olo = _oeo[_odb];
  let _o3f = _o3g[_olo] * _oau[_olo];
  var _ond = -1;
  if (_oby._opp != 0u) {
    _ond = _opo[_olo];
  }
  _ojl[_odb] = vec4u(bitcast<u32>(_o3f), bitcast<u32>(_oeq[_olo]),
                        bitcast<u32>(_ond), 0u);
}
