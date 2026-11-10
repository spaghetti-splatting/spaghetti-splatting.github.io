struct _o1o {
  _ono: u32,
  _ofj: u32,
  _o3i: u32,
  _ofk: u32,
};
struct _o24 {
  _one: u32,
  _oal: u32,
  _ocx: u32,
  _oin: u32,
};
struct _oz {
  _olt: u32,
  _oio: u32,
  _oip: u32,
  _oiq: u32,
};
@group(0) @binding(0) var<storage, read> _omk: array<u32>;
@group(0) @binding(1) var<storage, read_write> _oml: array<u32>;
@group(0) @binding(2) var<storage, read_write> _omn: array<u32>;
@group(0) @binding(3) var<storage, read> _omj: array<u32>;
@group(0) @binding(4) var<uniform> _omm: _o24;
@group(0) @binding(5) var<storage, read> _omo: array<u32>;
@group(0) @binding(0) var<storage, read_write> _oj6: array<u32>;
@group(0) @binding(1) var<storage, read_write> _oj5: array<u32>;
@group(0) @binding(2) var<uniform> _oj7: _o1o;
@group(0) @binding(0) var<storage, read> _o7m: array<u32>;
@group(0) @binding(1) var<storage, read> _o7n: array<u32>;
@group(0) @binding(2) var<storage, read_write> _o7p: array<u32>;
@group(0) @binding(3) var<storage, read_write> _o7l: array<u32>;
@group(0) @binding(4) var<uniform> _o7o: _oz;
var<workgroup> _omi: array<u32, 512>;
fn _ocb(_ocd: u32) -> vec3u {
  if (_ocd <= 65535u) {
    return vec3u(_ocd, 1u, 1u);
  }
  return vec3u(32768u, (_ocd + 32767u) / 32768u, 1u);
}
@compute @workgroup_size(1)
fn scan_plan() {
  var _ogw = _oj6[_oj7._ono];
  for (var _ofi = 0u; _ofi < _oj7._ofk; _ofi = _ofi + 1u) {
    _oj6[_oj7._ofj + _ofi] = _ogw;
    let _o4v = (_ogw + _o2j - 1u) / _o2j;
    let _oca = _ocb(_o4v);
    let _o45 = _oj7._o3i + 3u * _ofi;
    _oj5[_o45] = _oca.x;
    _oj5[_o45 + 1u] = _oca.y;
    _oj5[_o45 + 2u] = _oca.z;
    _ogw = _o4v;
  }
}
fn _osb(_ofl: u32, _orc: u32) -> u32 {
  _omi[_ofl] = _orc;
  workgroupBarrier();
  var _onm = 0u;
  for (var _ohm = 1u; _ohm < _o2j; _ohm = _ohm << 1u) {
    let _ohu = _o2j - _onm;
    var _oom = _omi[_onm + _ofl];
    if (_ofl >= _ohm) {
      _oom = _oom + _omi[_onm + _ofl - _ohm];
    }
    _omi[_ohu + _ofl] = _oom;
    _onm = _ohu;
    workgroupBarrier();
  }
  return _omi[_onm + _ofl];
}
@compute @workgroup_size(256)
fn scan_up(@builtin(local_invocation_index) _ofl: u32,
           @builtin(workgroup_id) _os6: vec3u,
           @builtin(num_workgroups) _ohc: vec3u) {
  let _o4t = _ofq(_os6, _ohc);
  let _ogw = _omj[_omm._one];
  let _o4v = (_ogw + _o2j - 1u) / _o2j;
  if (_o4t >= _o4v) {
    return;
  }
  let _odc = _o4t * _o2j + _ofl;
  var _orc = 0u;
  if (_odc < _ogw) {
    _orc = _omk[_odc];
  }
  let _odm = _osb(_ofl, _orc);
  if (_odc < _ogw) {
    _oml[_odc] = _odm;
  }
  if (_ofl == _o2j - 1u) {
    _omn[_o4t] = _odm;
  }
}
@compute @workgroup_size(256)
fn scan_down(@builtin(local_invocation_index) _ofl: u32,
             @builtin(workgroup_id) _os6: vec3u,
             @builtin(num_workgroups) _ohc: vec3u) {
  let _o4t = _ofq(_os6, _ohc);
  let _ogw = _omj[_omm._one];
  let _odc = _o4t * _o2j + _ofl;
  if (_odc >= _ogw) {
    return;
  }
  var _orc = _oml[_odc];
  if (_omm._ocx != 0u && _o4t > 0u) {
    _orc = _orc + _omo[_o4t - 1u];
  }
  if (_omm._oal != 0u) {
    _orc = _orc - _omk[_odc];
  }
  _oml[_odc] = _orc;
}
@compute @workgroup_size(256)
fn compact_scatter(@builtin(local_invocation_index) _ofl: u32,
                   @builtin(workgroup_id) _os6: vec3u,
                   @builtin(num_workgroups) _ohc: vec3u) {
  let _odc = _ofq(_os6, _ohc) * _o2j + _ofl;
  let _ogw = _o7o._olt;
  if (_odc >= _ogw) {
    return;
  }
  let _obb = _o7m[_odc];
  if (_obb != 0u) {
    _o7p[_o7n[_odc]] = _odc;
  }
  if (_odc == _ogw - 1u) {
    let _oq8 = _o7n[_odc] + _obb;
    if (_oq8 == 0u) {
      _o7p[0] = 0u;
      _o7l[_o1w] = 1u;
    } else {
      _o7l[_o1w] = _oq8;
    }
  }
}
