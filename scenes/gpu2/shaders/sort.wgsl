struct _o25 {
  _omb: u32,
  _oq9: u32,
  _og5: u32,
  _ohx: u32,
};
@group(0) @binding(0) var<storage, read> _o7j: array<u32>;
@group(0) @binding(1) var<storage, read> _o7h: array<u32>;
@group(0) @binding(2) var<storage, read_write> _o7i: array<u32>;
@group(0) @binding(3) var<uniform> _o7k: _o25;
@group(0) @binding(0) var<storage, read> _ocx: array<u32>;
@group(0) @binding(1) var<storage, read> _ocy: array<u32>;
@group(0) @binding(2) var<storage, read> _ocz: array<u32>;
@group(0) @binding(3) var<storage, read_write> _oh8: array<u32>;
@group(0) @binding(4) var<storage, read_write> _oh9: array<u32>;
@group(0) @binding(5) var<storage, read_write> _oha: array<u32>;
@group(0) @binding(6) var<storage, read> _o8x: array<u32>;
@group(0) @binding(7) var<storage, read> _oly: array<u32>;
@group(0) @binding(8) var<uniform> _olz: _o25;
var<workgroup> _o8w: array<atomic<u32>, 16>;
var<workgroup> _ok6: array<vec4u, 1024>;
@compute @workgroup_size(256)
fn sort_count(@builtin(local_invocation_index) _oex: u32,
              @builtin(workgroup_id) _orb: vec3u,
              @builtin(num_workgroups) _ogm: vec3u) {
  let _o4o = _of2(_orb, _ogm);
  let _o4p = _o7h[_o20];
  if (_o4o >= _o4p) {
    return;
  }
  let _og6 = _o7h[_o1v];
  if (_oex < 16u) {
    atomicStore(&_o8w[_oex], 0u);
  }
  workgroupBarrier();
  let _ocq = _o4o * _o2h + _oex;
  if (_ocq < _og6) {
    let _o8v = (_o7j[_ocq] >> _o7k._omb) & 15u;
    atomicAdd(&_o8w[_o8v], 1u);
  }
  workgroupBarrier();
  if (_oex < 16u) {
    _o7i[_oex * _o4p + _o4o] = atomicLoad(&_o8w[_oex]);
  }
}
@compute @workgroup_size(256)
fn sort_scatter(@builtin(local_invocation_index) _oex: u32,
                @builtin(workgroup_id) _orb: vec3u,
                @builtin(num_workgroups) _ogm: vec3u) {
  let _o4o = _of2(_orb, _ogm);
  let _o4p = _oly[_o20];
  if (_o4o >= _o4p) {
    return;
  }
  let _og6 = _oly[_o1v];
  let _ocq = _o4o * _o2h + _oex;
  let _oqg = _ocq < _og6;
  var _ocg = 0u;
  var _of4 = 0u;
  var _oqh = 0u;
  var _o8v = 0u;
  var _ofb = vec4u(0u);
  var _oci = vec4u(0u);
  if (_oqg) {
    _ocg = _ocx[_ocq];
    _oqh = _ocz[_ocq];
    if (_olz._og5 != 0u || _olz._oq9 == 0u) {
      _of4 = _ocy[_ocq];
    }
    let _oea = select(_of4, _ocg, _olz._oq9 != 0u);
    _o8v = (_oea >> _olz._omb) & 15u;
    let _orf = _o8v >> 1u;
    let _oen = 1u << ((_o8v & 1u) * 16u);
    if (_orf < 4u) {
      _ofb[_orf] = _oen;
    } else {
      _oci[_orf - 4u] = _oen;
    }
  }
  _ok6[2u * _oex] = _ofb;
  _ok6[2u * _oex + 1u] = _oci;
  workgroupBarrier();
  var _omt = 0u;
  for (var _ogw = 1u; _ogw < _o2h; _ogw = _ogw << 1u) {
    let _oh4 = 512u - _omt;
    var _ofc = _ok6[_omt + 2u * _oex];
    var _ocj = _ok6[_omt + 2u * _oex + 1u];
    if (_oex >= _ogw) {
      _ofc = _ofc + _ok6[_omt + 2u * (_oex - _ogw)];
      _ocj = _ocj + _ok6[_omt + 2u * (_oex - _ogw) + 1u];
    }
    _ok6[_oh4 + 2u * _oex] = _ofc;
    _ok6[_oh4 + 2u * _oex + 1u] = _ocj;
    _omt = _oh4;
    workgroupBarrier();
  }
  if (_oqg) {
    let _orf = _o8v >> 1u;
    var _ohw = 0u;
    if (_orf < 4u) {
      _ohw = _ok6[_omt + 2u * _oex][_orf];
    } else {
      _ohw = _ok6[_omt + 2u * _oex + 1u][_orf - 4u];
    }
    let _ok5 = ((_ohw >> ((_o8v & 1u) * 16u)) & 0xFFFFu) - 1u;
    let _o8m = _o8x[_o8v * _o4p + _o4o] + _ok5;
    _oh8[_o8m] = _ocg;
    if (_olz._og5 != 0u) {
      _oh9[_o8m] = _of4;
    }
    _oha[_o8m] = _oqh;
  }
}
