struct _o2c {
  _omz: u32,
  _oqz: u32,
  _ogp: u32,
  _oif: u32,
};
@group(0) @binding(0) var<storage, read> _o7p: array<u32>;
@group(0) @binding(1) var<storage, read> _o7m: array<u32>;
@group(0) @binding(2) var<storage, read_write> _o7o: array<u32>;
@group(0) @binding(3) var<uniform> _o7q: _o2c;
@group(0) @binding(0) var<storage, read> _ode: array<u32>;
@group(0) @binding(1) var<storage, read> _odf: array<u32>;
@group(0) @binding(2) var<storage, read> _odg: array<u32>;
@group(0) @binding(3) var<storage, read_write> _ohp: array<u32>;
@group(0) @binding(4) var<storage, read_write> _ohq: array<u32>;
@group(0) @binding(5) var<storage, read_write> _ohr: array<u32>;
@group(0) @binding(6) var<storage, read> _o98: array<u32>;
@group(0) @binding(7) var<storage, read> _omm: array<u32>;
@group(0) @binding(8) var<uniform> _omn: _o2c;
var<workgroup> _o97: array<atomic<u32>, 16>;
var<workgroup> _okr: array<vec4u, 1024>;
@compute @workgroup_size(256)
fn sort_count(@builtin(local_invocation_index) _ofg: u32,
              @builtin(workgroup_id) _os5: vec3u,
              @builtin(num_workgroups) _oh4: vec3u) {
  let _o4w = _ofj(_os5, _oh4);
  let _o4x = _o7m[_o27];
  if (_o4w >= _o4x) {
    return;
  }
  let _ogq = _o7m[_o22];
  if (_ofg < 16u) {
    atomicStore(&_o97[_ofg], 0u);
  }
  workgroupBarrier();
  let _od7 = _o4w * _o2o + _ofg;
  if (_od7 < _ogq) {
    let _o96 = (_o7p[_od7] >> _o7q._omz) & 15u;
    atomicAdd(&_o97[_o96], 1u);
  }
  workgroupBarrier();
  if (_ofg < 16u) {
    _o7o[_ofg * _o4x + _o4w] = atomicLoad(&_o97[_ofg]);
  }
}
@compute @workgroup_size(256)
fn sort_scatter(@builtin(local_invocation_index) _ofg: u32,
                @builtin(workgroup_id) _os5: vec3u,
                @builtin(num_workgroups) _oh4: vec3u) {
  let _o4w = _ofj(_os5, _oh4);
  let _o4x = _omm[_o27];
  if (_o4w >= _o4x) {
    return;
  }
  let _ogq = _omm[_o22];
  let _od7 = _o4w * _o2o + _ofg;
  let _or6 = _od7 < _ogq;
  var _ocx = 0u;
  var _ofo = 0u;
  var _or7 = 0u;
  var _o96 = 0u;
  var _ofv = vec4u(0u);
  var _ocy = vec4u(0u);
  if (_or6) {
    _ocx = _ode[_od7];
    _or7 = _odg[_od7];
    if (_omn._ogp != 0u || _omn._oqz == 0u) {
      _ofo = _odf[_od7];
    }
    let _oer = select(_ofo, _ocx, _omn._oqz != 0u);
    _o96 = (_oer >> _omn._omz) & 15u;
    let _os9 = _o96 >> 1u;
    let _of5 = 1u << ((_o96 & 1u) * 16u);
    if (_os9 < 4u) {
      _ofv[_os9] = _of5;
    } else {
      _ocy[_os9 - 4u] = _of5;
    }
  }
  _okr[2u * _ofg] = _ofv;
  _okr[2u * _ofg + 1u] = _ocy;
  workgroupBarrier();
  var _onh = 0u;
  for (var _ohd = 1u; _ohd < _o2o; _ohd = _ohd << 1u) {
    let _ohl = 512u - _onh;
    var _ofw = _okr[_onh + 2u * _ofg];
    var _ocz = _okr[_onh + 2u * _ofg + 1u];
    if (_ofg >= _ohd) {
      _ofw = _ofw + _okr[_onh + 2u * (_ofg - _ohd)];
      _ocz = _ocz + _okr[_onh + 2u * (_ofg - _ohd) + 1u];
    }
    _okr[_ohl + 2u * _ofg] = _ofw;
    _okr[_ohl + 2u * _ofg + 1u] = _ocz;
    _onh = _ohl;
    workgroupBarrier();
  }
  if (_or6) {
    let _os9 = _o96 >> 1u;
    var _oie = 0u;
    if (_os9 < 4u) {
      _oie = _okr[_onh + 2u * _ofg][_os9];
    } else {
      _oie = _okr[_onh + 2u * _ofg + 1u][_os9 - 4u];
    }
    let _okq = ((_oie >> ((_o96 & 1u) * 16u)) & 0xFFFFu) - 1u;
    let _o8x = _o98[_o96 * _o4x + _o4w] + _okq;
    _ohp[_o8x] = _ocx;
    if (_omn._ogp != 0u) {
      _ohq[_o8x] = _ofo;
    }
    _ohr[_o8x] = _or7;
  }
}
