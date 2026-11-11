struct _o1g {
  _ofp: u32,
  _ojs: u32,
  _o6e: u32,
  _ojm: u32,
};
@group(0) @binding(0) var<storage, read_write> _oc5: array<u32>;
@group(0) @binding(1) var<storage, read_write> _oc4: array<u32>;
@group(0) @binding(2) var<storage, read> _oc6: array<u32>;
@group(0) @binding(3) var<uniform> _oc7: _o1g;
@group(0) @binding(0) var<storage, read> _ooq: array<u32>;
@group(0) @binding(1) var<storage, read> _olv: array<u32>;
@group(0) @binding(2) var<storage, read_write> _oly: array<u32>;
fn _od7(_od8: u32) -> vec3u {
  if (_od8 <= 65535u) {
    return vec3u(_od8, 1u, 1u);
  }
  return vec3u(32768u, (_od8 + 32767u) / 32768u, 1u);
}
@compute @workgroup_size(1)
fn args_after_compaction() {
  let _ofo = _oc5[_o23];
  let _od5 = _od7((_ofo + _o2q - 1u) / _o2q);
  _oc4[_oc7._ofp] = _od5.x;
  _oc4[_oc7._ofp + 1u] = _od5.y;
  _oc4[_oc7._ofp + 2u] = _od5.z;
}
@compute @workgroup_size(1)
fn args_after_scan() {
  let _ofo = _oc5[_o23];
  let _om4 = _oc6[_ofo - 1u];
  let _oju = min(_om4, _oc7._o6e);
  let _od8 = (_oju + _o2q - 1u) / _o2q;
  _oc5[_o25] = _om4;
  _oc5[_o24] = _oju;
  _oc5[_o29] = _od8;
  _oc5[_o28] = 16u * _od8;
  let _od5 = _od7(_od8);
  _oc4[_oc7._ojs] = _od5.x;
  _oc4[_oc7._ojs + 1u] = _od5.y;
  _oc4[_oc7._ojs + 2u] = _od5.z;
}
@compute @workgroup_size(256)
fn tile_ranges(@builtin(local_invocation_index) _ogj: u32,
               @builtin(workgroup_id) _otg: vec3u,
               @builtin(num_workgroups) _oib: vec3u) {
  let _oea = _ogo(_otg, _oib) * _o2q + _ogj;
  let _o8c = _olv[_o24];
  if (_oea >= _o8c) {
    return;
  }
  let _o8n = _ooq[_oea];
  if (_oea == 0u) {
    _oly[2u * _o8n] = 0u;
  } else {
    let _okl = _ooq[_oea - 1u];
    if (_o8n != _okl) {
      _oly[2u * _okl + 1u] = _oea;
      _oly[2u * _o8n] = _oea;
    }
  }
  if (_oea == _o8c - 1u) {
    _oly[2u * _o8n + 1u] = _o8c;
  }
}
