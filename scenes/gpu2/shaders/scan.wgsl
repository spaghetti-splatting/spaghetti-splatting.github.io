struct _o1m {
  _omv: u32,
  _oev: u32,
  _o3e: u32,
  _oew: u32,
};
struct _o22 {
  _omm: u32,
  _oa3: u32,
  _ocd: u32,
  _ohx: u32,
};
struct _ox {
  _ol3: u32,
  _ohy: u32,
  _ohz: u32,
  _oi0: u32,
};
@group(0) @binding(0) var<storage, read> _olt: array<u32>;
@group(0) @binding(1) var<storage, read_write> _olu: array<u32>;
@group(0) @binding(2) var<storage, read_write> _olw: array<u32>;
@group(0) @binding(3) var<storage, read> _ols: array<u32>;
@group(0) @binding(4) var<uniform> _olv: _o22;
@group(0) @binding(5) var<storage, read> _olx: array<u32>;
@group(0) @binding(0) var<storage, read_write> _oig: array<u32>;
@group(0) @binding(1) var<storage, read_write> _oif: array<u32>;
@group(0) @binding(2) var<uniform> _oih: _o1m;
@group(0) @binding(0) var<storage, read> _o74: array<u32>;
@group(0) @binding(1) var<storage, read> _o75: array<u32>;
@group(0) @binding(2) var<storage, read_write> _o77: array<u32>;
@group(0) @binding(3) var<storage, read_write> _o73: array<u32>;
@group(0) @binding(4) var<uniform> _o76: _ox;
var<workgroup> _olr: array<u32, 512>;
fn _obs(_obu: u32) -> vec3u {
  if (_obu <= 65535u) {
    return vec3u(_obu, 1u, 1u);
  }
  return vec3u(32768u, (_obu + 32767u) / 32768u, 1u);
}
@compute @workgroup_size(1)
fn scan_plan() {
  var _og6 = _oig[_oih._omv];
  for (var _oeu = 0u; _oeu < _oih._oew; _oeu = _oeu + 1u) {
    _oig[_oih._oev + _oeu] = _og6;
    let _o4p = (_og6 + _o2h - 1u) / _o2h;
    let _obr = _obs(_o4p);
    let _o40 = _oih._o3e + 3u * _oeu;
    _oif[_o40] = _obr.x;
    _oif[_o40 + 1u] = _obr.y;
    _oif[_o40 + 2u] = _obr.z;
    _og6 = _o4p;
  }
}
fn _org(_oex: u32, _oqh: u32) -> u32 {
  _olr[_oex] = _oqh;
  workgroupBarrier();
  var _omt = 0u;
  for (var _ogw = 1u; _ogw < _o2h; _ogw = _ogw << 1u) {
    let _oh4 = _o2h - _omt;
    var _ons = _olr[_omt + _oex];
    if (_oex >= _ogw) {
      _ons = _ons + _olr[_omt + _oex - _ogw];
    }
    _olr[_oh4 + _oex] = _ons;
    _omt = _oh4;
    workgroupBarrier();
  }
  return _olr[_omt + _oex];
}
@compute @workgroup_size(256)
fn scan_up(@builtin(local_invocation_index) _oex: u32,
           @builtin(workgroup_id) _orb: vec3u,
           @builtin(num_workgroups) _ogm: vec3u) {
  let _o4o = _of2(_orb, _ogm);
  let _og6 = _ols[_olv._omm];
  let _o4p = (_og6 + _o2h - 1u) / _o2h;
  if (_o4o >= _o4p) {
    return;
  }
  let _ocq = _o4o * _o2h + _oex;
  var _oqh = 0u;
  if (_ocq < _og6) {
    _oqh = _olt[_ocq];
  }
  let _od0 = _org(_oex, _oqh);
  if (_ocq < _og6) {
    _olu[_ocq] = _od0;
  }
  if (_oex == _o2h - 1u) {
    _olw[_o4o] = _od0;
  }
}
@compute @workgroup_size(256)
fn scan_down(@builtin(local_invocation_index) _oex: u32,
             @builtin(workgroup_id) _orb: vec3u,
             @builtin(num_workgroups) _ogm: vec3u) {
  let _o4o = _of2(_orb, _ogm);
  let _og6 = _ols[_olv._omm];
  let _ocq = _o4o * _o2h + _oex;
  if (_ocq >= _og6) {
    return;
  }
  var _oqh = _olu[_ocq];
  if (_olv._ocd != 0u && _o4o > 0u) {
    _oqh = _oqh + _olx[_o4o - 1u];
  }
  if (_olv._oa3 != 0u) {
    _oqh = _oqh - _olt[_ocq];
  }
  _olu[_ocq] = _oqh;
}
@compute @workgroup_size(256)
fn compact_scatter(@builtin(local_invocation_index) _oex: u32,
                   @builtin(workgroup_id) _orb: vec3u,
                   @builtin(num_workgroups) _ogm: vec3u) {
  let _ocq = _of2(_orb, _ogm) * _o2h + _oex;
  let _og6 = _o76._ol3;
  if (_ocq >= _og6) {
    return;
  }
  let _oas = _o74[_ocq];
  if (_oas != 0u) {
    _o77[_o75[_ocq]] = _ocq;
  }
  if (_ocq == _og6 - 1u) {
    let _opd = _o75[_ocq] + _oas;
    if (_opd == 0u) {
      _o77[0] = 0u;
      _o73[_o1u] = 1u;
    } else {
      _o73[_o1u] = _opd;
    }
  }
}
