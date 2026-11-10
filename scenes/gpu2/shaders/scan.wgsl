struct _o1m {
  _omw: u32,
  _oew: u32,
  _o3e: u32,
  _oex: u32,
};
struct _o22 {
  _omn: u32,
  _oa4: u32,
  _oce: u32,
  _ohy: u32,
};
struct _ox {
  _ol4: u32,
  _ohz: u32,
  _oi0: u32,
  _oi1: u32,
};
@group(0) @binding(0) var<storage, read> _olu: array<u32>;
@group(0) @binding(1) var<storage, read_write> _olv: array<u32>;
@group(0) @binding(2) var<storage, read_write> _olx: array<u32>;
@group(0) @binding(3) var<storage, read> _olt: array<u32>;
@group(0) @binding(4) var<uniform> _olw: _o22;
@group(0) @binding(5) var<storage, read> _oly: array<u32>;
@group(0) @binding(0) var<storage, read_write> _oih: array<u32>;
@group(0) @binding(1) var<storage, read_write> _oig: array<u32>;
@group(0) @binding(2) var<uniform> _oii: _o1m;
@group(0) @binding(0) var<storage, read> _o75: array<u32>;
@group(0) @binding(1) var<storage, read> _o76: array<u32>;
@group(0) @binding(2) var<storage, read_write> _o78: array<u32>;
@group(0) @binding(3) var<storage, read_write> _o74: array<u32>;
@group(0) @binding(4) var<uniform> _o77: _ox;
var<workgroup> _ols: array<u32, 512>;
fn _obt(_obv: u32) -> vec3u {
  if (_obv <= 65535u) {
    return vec3u(_obv, 1u, 1u);
  }
  return vec3u(32768u, (_obv + 32767u) / 32768u, 1u);
}
@compute @workgroup_size(1)
fn scan_plan() {
  var _og7 = _oih[_oii._omw];
  for (var _oev = 0u; _oev < _oii._oex; _oev = _oev + 1u) {
    _oih[_oii._oew + _oev] = _og7;
    let _o4p = (_og7 + _o2h - 1u) / _o2h;
    let _obs = _obt(_o4p);
    let _o40 = _oii._o3e + 3u * _oev;
    _oig[_o40] = _obs.x;
    _oig[_o40 + 1u] = _obs.y;
    _oig[_o40 + 2u] = _obs.z;
    _og7 = _o4p;
  }
}
fn _orh(_oey: u32, _oqi: u32) -> u32 {
  _ols[_oey] = _oqi;
  workgroupBarrier();
  var _omu = 0u;
  for (var _ogx = 1u; _ogx < _o2h; _ogx = _ogx << 1u) {
    let _oh5 = _o2h - _omu;
    var _ont = _ols[_omu + _oey];
    if (_oey >= _ogx) {
      _ont = _ont + _ols[_omu + _oey - _ogx];
    }
    _ols[_oh5 + _oey] = _ont;
    _omu = _oh5;
    workgroupBarrier();
  }
  return _ols[_omu + _oey];
}
@compute @workgroup_size(256)
fn scan_up(@builtin(local_invocation_index) _oey: u32,
           @builtin(workgroup_id) _orc: vec3u,
           @builtin(num_workgroups) _ogn: vec3u) {
  let _o4o = _of3(_orc, _ogn);
  let _og7 = _olt[_olw._omn];
  let _o4p = (_og7 + _o2h - 1u) / _o2h;
  if (_o4o >= _o4p) {
    return;
  }
  let _ocr = _o4o * _o2h + _oey;
  var _oqi = 0u;
  if (_ocr < _og7) {
    _oqi = _olu[_ocr];
  }
  let _od1 = _orh(_oey, _oqi);
  if (_ocr < _og7) {
    _olv[_ocr] = _od1;
  }
  if (_oey == _o2h - 1u) {
    _olx[_o4o] = _od1;
  }
}
@compute @workgroup_size(256)
fn scan_down(@builtin(local_invocation_index) _oey: u32,
             @builtin(workgroup_id) _orc: vec3u,
             @builtin(num_workgroups) _ogn: vec3u) {
  let _o4o = _of3(_orc, _ogn);
  let _og7 = _olt[_olw._omn];
  let _ocr = _o4o * _o2h + _oey;
  if (_ocr >= _og7) {
    return;
  }
  var _oqi = _olv[_ocr];
  if (_olw._oce != 0u && _o4o > 0u) {
    _oqi = _oqi + _oly[_o4o - 1u];
  }
  if (_olw._oa4 != 0u) {
    _oqi = _oqi - _olu[_ocr];
  }
  _olv[_ocr] = _oqi;
}
@compute @workgroup_size(256)
fn compact_scatter(@builtin(local_invocation_index) _oey: u32,
                   @builtin(workgroup_id) _orc: vec3u,
                   @builtin(num_workgroups) _ogn: vec3u) {
  let _ocr = _of3(_orc, _ogn) * _o2h + _oey;
  let _og7 = _o77._ol4;
  if (_ocr >= _og7) {
    return;
  }
  let _oat = _o75[_ocr];
  if (_oat != 0u) {
    _o78[_o76[_ocr]] = _ocr;
  }
  if (_ocr == _og7 - 1u) {
    let _ope = _o76[_ocr] + _oat;
    if (_ope == 0u) {
      _o78[0] = 0u;
      _o74[_o1u] = 1u;
    } else {
      _o74[_o1u] = _ope;
    }
  }
}
