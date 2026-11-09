struct _o1a {
  _oen: u32,
  _oil: u32,
  _o62: u32,
  _oif: u32,
};
@group(0) @binding(0) var<storage, read_write> _obl: array<u32>;
@group(0) @binding(1) var<storage, read_write> _obk: array<u32>;
@group(0) @binding(2) var<storage, read> _obm: array<u32>;
@group(0) @binding(3) var<uniform> _obn: _o1a;
@group(0) @binding(0) var<storage, read> _ong: array<u32>;
@group(0) @binding(1) var<storage, read> _okm: array<u32>;
@group(0) @binding(2) var<storage, read_write> _okp: array<u32>;
fn _ocb(_occ: u32) -> vec3u {
  if (_occ <= 65535u) {
    return vec3u(_occ, 1u, 1u);
  }
  return vec3u(32768u, (_occ + 32767u) / 32768u, 1u);
}
@compute @workgroup_size(1)
fn args_after_compaction() {
  let _oem = _obl[_o21];
  let _oc8 = _ocb((_oem + _o2o - 1u) / _o2o);
  _obk[_obn._oen] = _oc8.x;
  _obk[_obn._oen + 1u] = _oc8.y;
  _obk[_obn._oen + 2u] = _oc8.z;
}
@compute @workgroup_size(1)
fn args_after_scan() {
  let _oem = _obl[_o21];
  let _okv = _obm[_oem - 1u];
  let _oin = min(_okv, _obn._o62);
  let _occ = (_oin + _o2o - 1u) / _o2o;
  _obl[_o23] = _okv;
  _obl[_o22] = _oin;
  _obl[_o27] = _occ;
  _obl[_o26] = 16u * _occ;
  let _oc8 = _ocb(_occ);
  _obk[_obn._oil] = _oc8.x;
  _obk[_obn._oil + 1u] = _oc8.y;
  _obk[_obn._oil + 2u] = _oc8.z;
}
@compute @workgroup_size(256)
fn tile_ranges(@builtin(local_invocation_index) _ofg: u32,
               @builtin(workgroup_id) _os5: vec3u,
               @builtin(num_workgroups) _oh4: vec3u) {
  let _odb = _ofj(_os5, _oh4) * _o2o + _ofg;
  let _o7l = _okm[_o22];
  if (_odb >= _o7l) {
    return;
  }
  let _o7y = _ong[_odb];
  if (_odb == 0u) {
    _okp[2u * _o7y] = 0u;
  } else {
    let _ojj = _ong[_odb - 1u];
    if (_o7y != _ojj) {
      _okp[2u * _ojj + 1u] = _odb;
      _okp[2u * _o7y] = _odb;
    }
  }
  if (_odb == _o7l - 1u) {
    _okp[2u * _o7y + 1u] = _o7l;
  }
}
