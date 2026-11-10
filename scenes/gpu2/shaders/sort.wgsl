struct _o27 {
  _on2: u32,
  _or4: u32,
  _ogv: u32,
  _oin: u32,
};
@group(0) @binding(0) var<storage, read> _o81: array<u32>;
@group(0) @binding(1) var<storage, read> _o7z: array<u32>;
@group(0) @binding(2) var<storage, read_write> _o80: array<u32>;
@group(0) @binding(3) var<uniform> _o82: _o27;
@group(0) @binding(0) var<storage, read> _odj: array<u32>;
@group(0) @binding(1) var<storage, read> _odk: array<u32>;
@group(0) @binding(2) var<storage, read> _odl: array<u32>;
@group(0) @binding(3) var<storage, read_write> _ohy: array<u32>;
@group(0) @binding(4) var<storage, read_write> _ohz: array<u32>;
@group(0) @binding(5) var<storage, read_write> _oi0: array<u32>;
@group(0) @binding(6) var<storage, read> _o9f: array<u32>;
@group(0) @binding(7) var<storage, read> _omp: array<u32>;
@group(0) @binding(8) var<uniform> _omq: _o27;
var<workgroup> _o9e: array<atomic<u32>, 16>;
var<workgroup> _okw: array<vec4u, 1024>;
@compute @workgroup_size(256)
fn sort_count(@builtin(local_invocation_index) _ofl: u32,
              @builtin(workgroup_id) _os6: vec3u,
              @builtin(num_workgroups) _ohc: vec3u) {
  let _o4t = _ofq(_os6, _ohc);
  let _o4v = _o7z[_o22];
  if (_o4t >= _o4v) {
    return;
  }
  let _ogw = _o7z[_o1x];
  if (_ofl < 16u) {
    atomicStore(&_o9e[_ofl], 0u);
  }
  workgroupBarrier();
  let _odc = _o4t * _o2j + _ofl;
  if (_odc < _ogw) {
    let _o9d = (_o81[_odc] >> _o82._on2) & 15u;
    atomicAdd(&_o9e[_o9d], 1u);
  }
  workgroupBarrier();
  if (_ofl < 16u) {
    _o80[_ofl * _o4v + _o4t] = atomicLoad(&_o9e[_ofl]);
  }
}
@compute @workgroup_size(256)
fn sort_scatter(@builtin(local_invocation_index) _ofl: u32,
                @builtin(workgroup_id) _os6: vec3u,
                @builtin(num_workgroups) _ohc: vec3u) {
  let _o4t = _ofq(_os6, _ohc);
  let _o4v = _omp[_o22];
  if (_o4t >= _o4v) {
    return;
  }
  let _ogw = _omp[_o1x];
  let _odc = _o4t * _o2j + _ofl;
  let _orb = _odc < _ogw;
  var _od1 = 0u;
  var _ofs = 0u;
  var _orc = 0u;
  var _o9d = 0u;
  var _ofz = vec4u(0u);
  var _od3 = vec4u(0u);
  if (_orb) {
    _od1 = _odj[_odc];
    _orc = _odl[_odc];
    if (_omq._ogv != 0u || _omq._or4 == 0u) {
      _ofs = _odk[_odc];
    }
    let _oey = select(_ofs, _od1, _omq._or4 != 0u);
    _o9d = (_oey >> _omq._on2) & 15u;
    let _osa = _o9d >> 1u;
    let _ofb = 1u << ((_o9d & 1u) * 16u);
    if (_osa < 4u) {
      _ofz[_osa] = _ofb;
    } else {
      _od3[_osa - 4u] = _ofb;
    }
  }
  _okw[2u * _ofl] = _ofz;
  _okw[2u * _ofl + 1u] = _od3;
  workgroupBarrier();
  var _onm = 0u;
  for (var _ohm = 1u; _ohm < _o2j; _ohm = _ohm << 1u) {
    let _ohu = 512u - _onm;
    var _og0 = _okw[_onm + 2u * _ofl];
    var _od4 = _okw[_onm + 2u * _ofl + 1u];
    if (_ofl >= _ohm) {
      _og0 = _og0 + _okw[_onm + 2u * (_ofl - _ohm)];
      _od4 = _od4 + _okw[_onm + 2u * (_ofl - _ohm) + 1u];
    }
    _okw[_ohu + 2u * _ofl] = _og0;
    _okw[_ohu + 2u * _ofl + 1u] = _od4;
    _onm = _ohu;
    workgroupBarrier();
  }
  if (_orb) {
    let _osa = _o9d >> 1u;
    var _oim = 0u;
    if (_osa < 4u) {
      _oim = _okw[_onm + 2u * _ofl][_osa];
    } else {
      _oim = _okw[_onm + 2u * _ofl + 1u][_osa - 4u];
    }
    let _okv = ((_oim >> ((_o9d & 1u) * 16u)) & 0xFFFFu) - 1u;
    let _o94 = _o9f[_o9d * _o4v + _o4t] + _okv;
    _ohy[_o94] = _od1;
    if (_omq._ogv != 0u) {
      _ohz[_o94] = _ofs;
    }
    _oi0[_o94] = _orc;
  }
}
