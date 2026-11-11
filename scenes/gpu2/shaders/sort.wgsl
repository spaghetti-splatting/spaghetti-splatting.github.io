struct _o2e {
  _oo7: u32,
  _ose: u32,
  _ohu: u32,
  _ojm: u32,
};
@group(0) @binding(0) var<storage, read> _o8f: array<u32>;
@group(0) @binding(1) var<storage, read> _o8d: array<u32>;
@group(0) @binding(2) var<storage, read_write> _o8e: array<u32>;
@group(0) @binding(3) var<uniform> _o8g: _o2e;
@group(0) @binding(0) var<storage, read> _oee: array<u32>;
@group(0) @binding(1) var<storage, read> _oef: array<u32>;
@group(0) @binding(2) var<storage, read> _oeg: array<u32>;
@group(0) @binding(3) var<storage, read_write> _oix: array<u32>;
@group(0) @binding(4) var<storage, read_write> _oiy: array<u32>;
@group(0) @binding(5) var<storage, read_write> _oiz: array<u32>;
@group(0) @binding(6) var<storage, read> _o9t: array<u32>;
@group(0) @binding(7) var<storage, read> _onu: array<u32>;
@group(0) @binding(8) var<uniform> _onv: _o2e;
var<workgroup> _o9s: array<atomic<u32>, 16>;
var<workgroup> _om0: array<vec4u, 1024>;
@compute @workgroup_size(256)
fn sort_count(@builtin(local_invocation_index) _ogj: u32,
              @builtin(workgroup_id) _otg: vec3u,
              @builtin(num_workgroups) _oib: vec3u) {
  let _o54 = _ogo(_otg, _oib);
  let _o56 = _o8d[_o29];
  if (_o54 >= _o56) {
    return;
  }
  let _ohv = _o8d[_o24];
  if (_ogj < 16u) {
    atomicStore(&_o9s[_ogj], 0u);
  }
  workgroupBarrier();
  let _oe7 = _o54 * _o2q + _ogj;
  if (_oe7 < _ohv) {
    let _o9r = (_o8f[_oe7] >> _o8g._oo7) & 15u;
    atomicAdd(&_o9s[_o9r], 1u);
  }
  workgroupBarrier();
  if (_ogj < 16u) {
    _o8e[_ogj * _o56 + _o54] = atomicLoad(&_o9s[_ogj]);
  }
}
@compute @workgroup_size(256)
fn sort_scatter(@builtin(local_invocation_index) _ogj: u32,
                @builtin(workgroup_id) _otg: vec3u,
                @builtin(num_workgroups) _oib: vec3u) {
  let _o54 = _ogo(_otg, _oib);
  let _o56 = _onu[_o29];
  if (_o54 >= _o56) {
    return;
  }
  let _ohv = _onu[_o24];
  let _oe7 = _o54 * _o2q + _ogj;
  let _osl = _oe7 < _ohv;
  var _odw = 0u;
  var _ogq = 0u;
  var _osm = 0u;
  var _o9r = 0u;
  var _ogx = vec4u(0u);
  var _ody = vec4u(0u);
  if (_osl) {
    _odw = _oee[_oe7];
    _osm = _oeg[_oe7];
    if (_onv._ohu != 0u || _onv._ose == 0u) {
      _ogq = _oef[_oe7];
    }
    let _oft = select(_ogq, _odw, _onv._ose != 0u);
    _o9r = (_oft >> _onv._oo7) & 15u;
    let _otk = _o9r >> 1u;
    let _og9 = 1u << ((_o9r & 1u) * 16u);
    if (_otk < 4u) {
      _ogx[_otk] = _og9;
    } else {
      _ody[_otk - 4u] = _og9;
    }
  }
  _om0[2u * _ogj] = _ogx;
  _om0[2u * _ogj + 1u] = _ody;
  workgroupBarrier();
  var _oor = 0u;
  for (var _oil = 1u; _oil < _o2q; _oil = _oil << 1u) {
    let _oit = 512u - _oor;
    var _ogy = _om0[_oor + 2u * _ogj];
    var _odz = _om0[_oor + 2u * _ogj + 1u];
    if (_ogj >= _oil) {
      _ogy = _ogy + _om0[_oor + 2u * (_ogj - _oil)];
      _odz = _odz + _om0[_oor + 2u * (_ogj - _oil) + 1u];
    }
    _om0[_oit + 2u * _ogj] = _ogy;
    _om0[_oit + 2u * _ogj + 1u] = _odz;
    _oor = _oit;
    workgroupBarrier();
  }
  if (_osl) {
    let _otk = _o9r >> 1u;
    var _ojl = 0u;
    if (_otk < 4u) {
      _ojl = _om0[_oor + 2u * _ogj][_otk];
    } else {
      _ojl = _om0[_oor + 2u * _ogj + 1u][_otk - 4u];
    }
    let _olz = ((_ojl >> ((_o9r & 1u) * 16u)) & 0xFFFFu) - 1u;
    let _o9i = _o9t[_o9r * _o56 + _o54] + _olz;
    _oix[_o9i] = _odw;
    if (_onv._ohu != 0u) {
      _oiy[_o9i] = _ogq;
    }
    _oiz[_o9i] = _osm;
  }
}
