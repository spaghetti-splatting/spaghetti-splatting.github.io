struct _o1r {
  _onj: u32,
  _ofe: u32,
  _o3m: u32,
  _off: u32,
};
struct _o29 {
  _ona: u32,
  _oai: u32,
  _ocs: u32,
  _oif: u32,
};
struct _os {
  _olq: u32,
  _oig: u32,
  _oih: u32,
  _oii: u32,
};
@group(0) @binding(0) var<storage, read> _omh: array<u32>;
@group(0) @binding(1) var<storage, read_write> _omi: array<u32>;
@group(0) @binding(2) var<storage, read_write> _omk: array<u32>;
@group(0) @binding(3) var<storage, read> _omg: array<u32>;
@group(0) @binding(4) var<uniform> _omj: _o29;
@group(0) @binding(5) var<storage, read> _oml: array<u32>;
@group(0) @binding(0) var<storage, read_write> _oiz: array<u32>;
@group(0) @binding(1) var<storage, read_write> _oiy: array<u32>;
@group(0) @binding(2) var<uniform> _oj0: _o1r;
@group(0) @binding(0) var<storage, read> _o75: array<u32>;
@group(0) @binding(1) var<storage, read> _o76: array<u32>;
@group(0) @binding(2) var<storage, read_write> _o78: array<u32>;
@group(0) @binding(3) var<storage, read_write> _o74: array<u32>;
@group(0) @binding(4) var<uniform> _o77: _os;
var<workgroup> _omf: array<u32, 512>;
fn _oc9(_occ: u32) -> vec3u {
  if (_occ <= 65535u) {
    return vec3u(_occ, 1u, 1u);
  }
  return vec3u(32768u, (_occ + 32767u) / 32768u, 1u);
}
@compute @workgroup_size(1)
fn scan_plan() {
  var _ogq = _oiz[_oj0._onj];
  for (var _ofd = 0u; _ofd < _oj0._off; _ofd = _ofd + 1u) {
    _oiz[_oj0._ofe + _ofd] = _ogq;
    let _o4x = (_ogq + _o2o - 1u) / _o2o;
    let _oc8 = _oc9(_o4x);
    let _o49 = _oj0._o3m + 3u * _ofd;
    _oiy[_o49] = _oc8.x;
    _oiy[_o49 + 1u] = _oc8.y;
    _oiy[_o49 + 2u] = _oc8.z;
    _ogq = _o4x;
  }
}
fn _osa(_ofg: u32, _or7: u32) -> u32 {
  _omf[_ofg] = _or7;
  workgroupBarrier();
  var _onh = 0u;
  for (var _ohd = 1u; _ohd < _o2o; _ohd = _ohd << 1u) {
    let _ohl = _o2o - _onh;
    var _ooh = _omf[_onh + _ofg];
    if (_ofg >= _ohd) {
      _ooh = _ooh + _omf[_onh + _ofg - _ohd];
    }
    _omf[_ohl + _ofg] = _ooh;
    _onh = _ohl;
    workgroupBarrier();
  }
  return _omf[_onh + _ofg];
}
@compute @workgroup_size(256)
fn scan_up(@builtin(local_invocation_index) _ofg: u32,
           @builtin(workgroup_id) _os5: vec3u,
           @builtin(num_workgroups) _oh4: vec3u) {
  let _o4w = _ofj(_os5, _oh4);
  let _ogq = _omg[_omj._ona];
  let _o4x = (_ogq + _o2o - 1u) / _o2o;
  if (_o4w >= _o4x) {
    return;
  }
  let _od7 = _o4w * _o2o + _ofg;
  var _or7 = 0u;
  if (_od7 < _ogq) {
    _or7 = _omh[_od7];
  }
  let _odh = _osa(_ofg, _or7);
  if (_od7 < _ogq) {
    _omi[_od7] = _odh;
  }
  if (_ofg == _o2o - 1u) {
    _omk[_o4w] = _odh;
  }
}
@compute @workgroup_size(256)
fn scan_down(@builtin(local_invocation_index) _ofg: u32,
             @builtin(workgroup_id) _os5: vec3u,
             @builtin(num_workgroups) _oh4: vec3u) {
  let _o4w = _ofj(_os5, _oh4);
  let _ogq = _omg[_omj._ona];
  let _od7 = _o4w * _o2o + _ofg;
  if (_od7 >= _ogq) {
    return;
  }
  var _or7 = _omi[_od7];
  if (_omj._ocs != 0u && _o4w > 0u) {
    _or7 = _or7 + _oml[_o4w - 1u];
  }
  if (_omj._oai != 0u) {
    _or7 = _or7 - _omh[_od7];
  }
  _omi[_od7] = _or7;
}
@compute @workgroup_size(256)
fn compact_scatter(@builtin(local_invocation_index) _ofg: u32,
                   @builtin(workgroup_id) _os5: vec3u,
                   @builtin(num_workgroups) _oh4: vec3u) {
  let _od7 = _ofj(_os5, _oh4) * _o2o + _ofg;
  let _ogq = _o77._olq;
  if (_od7 >= _ogq) {
    return;
  }
  let _oba = _o75[_od7];
  if (_oba != 0u) {
    _o78[_o76[_od7]] = _od7;
  }
  if (_od7 == _ogq - 1u) {
    let _oq3 = _o76[_od7] + _oba;
    if (_oq3 == 0u) {
      _o78[0] = 0u;
      _o74[_o21] = 1u;
    } else {
      _o74[_o21] = _oq3;
    }
  }
}
