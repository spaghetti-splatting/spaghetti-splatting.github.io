struct _o1v {
  _oot: u32,
  _ogh: u32,
  _o3t: u32,
  _ogi: u32,
};
struct _o2b {
  _ooj: u32,
  _ob1: u32,
  _ods: u32,
  _ojm: u32,
};
struct _oz {
  _omy: u32,
  _ojn: u32,
  _ojo: u32,
  _ojp: u32,
};
@group(0) @binding(0) var<storage, read> _onp: array<u32>;
@group(0) @binding(1) var<storage, read_write> _onq: array<u32>;
@group(0) @binding(2) var<storage, read_write> _ons: array<u32>;
@group(0) @binding(3) var<storage, read> _ono: array<u32>;
@group(0) @binding(4) var<uniform> _onr: _o2b;
@group(0) @binding(5) var<storage, read> _ont: array<u32>;
@group(0) @binding(0) var<storage, read_write> _ok6: array<u32>;
@group(0) @binding(1) var<storage, read_write> _ok5: array<u32>;
@group(0) @binding(2) var<uniform> _ok7: _o1v;
@group(0) @binding(0) var<storage, read> _o80: array<u32>;
@group(0) @binding(1) var<storage, read> _o81: array<u32>;
@group(0) @binding(2) var<storage, read_write> _o83: array<u32>;
@group(0) @binding(3) var<storage, read_write> _o7z: array<u32>;
@group(0) @binding(4) var<uniform> _o82: _oz;
var<workgroup> _onn: array<u32, 512>;
fn _od6(_od8: u32) -> vec3u {
  if (_od8 <= 65535u) {
    return vec3u(_od8, 1u, 1u);
  }
  return vec3u(32768u, (_od8 + 32767u) / 32768u, 1u);
}
@compute @workgroup_size(1)
fn scan_plan() {
  var _ohv = _ok6[_ok7._oot];
  for (var _ogg = 0u; _ogg < _ok7._ogi; _ogg = _ogg + 1u) {
    _ok6[_ok7._ogh + _ogg] = _ohv;
    let _o56 = (_ohv + _o2q - 1u) / _o2q;
    let _od5 = _od6(_o56);
    let _o4g = _ok7._o3t + 3u * _ogg;
    _ok5[_o4g] = _od5.x;
    _ok5[_o4g + 1u] = _od5.y;
    _ok5[_o4g + 2u] = _od5.z;
    _ohv = _o56;
  }
}
fn _otl(_ogj: u32, _osm: u32) -> u32 {
  _onn[_ogj] = _osm;
  workgroupBarrier();
  var _oor = 0u;
  for (var _oil = 1u; _oil < _o2q; _oil = _oil << 1u) {
    let _oit = _o2q - _oor;
    var _opv = _onn[_oor + _ogj];
    if (_ogj >= _oil) {
      _opv = _opv + _onn[_oor + _ogj - _oil];
    }
    _onn[_oit + _ogj] = _opv;
    _oor = _oit;
    workgroupBarrier();
  }
  return _onn[_oor + _ogj];
}
@compute @workgroup_size(256)
fn scan_up(@builtin(local_invocation_index) _ogj: u32,
           @builtin(workgroup_id) _otg: vec3u,
           @builtin(num_workgroups) _oib: vec3u) {
  let _o54 = _ogo(_otg, _oib);
  let _ohv = _ono[_onr._ooj];
  let _o56 = (_ohv + _o2q - 1u) / _o2q;
  if (_o54 >= _o56) {
    return;
  }
  let _oe7 = _o54 * _o2q + _ogj;
  var _osm = 0u;
  if (_oe7 < _ohv) {
    _osm = _onp[_oe7];
  }
  let _oeh = _otl(_ogj, _osm);
  if (_oe7 < _ohv) {
    _onq[_oe7] = _oeh;
  }
  if (_ogj == _o2q - 1u) {
    _ons[_o54] = _oeh;
  }
}
@compute @workgroup_size(256)
fn scan_down(@builtin(local_invocation_index) _ogj: u32,
             @builtin(workgroup_id) _otg: vec3u,
             @builtin(num_workgroups) _oib: vec3u) {
  let _o54 = _ogo(_otg, _oib);
  let _ohv = _ono[_onr._ooj];
  let _oe7 = _o54 * _o2q + _ogj;
  if (_oe7 >= _ohv) {
    return;
  }
  var _osm = _onq[_oe7];
  if (_onr._ods != 0u && _o54 > 0u) {
    _osm = _osm + _ont[_o54 - 1u];
  }
  if (_onr._ob1 != 0u) {
    _osm = _osm - _onp[_oe7];
  }
  _onq[_oe7] = _osm;
}
@compute @workgroup_size(256)
fn compact_scatter(@builtin(local_invocation_index) _ogj: u32,
                   @builtin(workgroup_id) _otg: vec3u,
                   @builtin(num_workgroups) _oib: vec3u) {
  let _oe7 = _ogo(_otg, _oib) * _o2q + _ogj;
  let _ohv = _o82._omy;
  if (_oe7 >= _ohv) {
    return;
  }
  let _obr = _o80[_oe7];
  if (_obr != 0u) {
    _o83[_o81[_oe7]] = _oe7;
  }
  if (_oe7 == _ohv - 1u) {
    let _ori = _o81[_oe7] + _obr;
    if (_ori == 0u) {
      _o83[0] = 0u;
      _o7z[_o23] = 1u;
    } else {
      _o7z[_o23] = _ori;
    }
  }
}
