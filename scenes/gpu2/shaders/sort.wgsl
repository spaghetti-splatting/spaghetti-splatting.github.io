struct _o25 {
  _omc: u32,
  _oqa: u32,
  _og6: u32,
  _ohy: u32,
};
@group(0) @binding(0) var<storage, read> _o7k: array<u32>;
@group(0) @binding(1) var<storage, read> _o7i: array<u32>;
@group(0) @binding(2) var<storage, read_write> _o7j: array<u32>;
@group(0) @binding(3) var<uniform> _o7l: _o25;
@group(0) @binding(0) var<storage, read> _ocy: array<u32>;
@group(0) @binding(1) var<storage, read> _ocz: array<u32>;
@group(0) @binding(2) var<storage, read> _od0: array<u32>;
@group(0) @binding(3) var<storage, read_write> _oh9: array<u32>;
@group(0) @binding(4) var<storage, read_write> _oha: array<u32>;
@group(0) @binding(5) var<storage, read_write> _ohb: array<u32>;
@group(0) @binding(6) var<storage, read> _o8y: array<u32>;
@group(0) @binding(7) var<storage, read> _olz: array<u32>;
@group(0) @binding(8) var<uniform> _om0: _o25;
var<workgroup> _o8x: array<atomic<u32>, 16>;
var<workgroup> _ok7: array<vec4u, 1024>;
@compute @workgroup_size(256)
fn sort_count(@builtin(local_invocation_index) _oey: u32,
              @builtin(workgroup_id) _orc: vec3u,
              @builtin(num_workgroups) _ogn: vec3u) {
  let _o4o = _of3(_orc, _ogn);
  let _o4p = _o7i[_o20];
  if (_o4o >= _o4p) {
    return;
  }
  let _og7 = _o7i[_o1v];
  if (_oey < 16u) {
    atomicStore(&_o8x[_oey], 0u);
  }
  workgroupBarrier();
  let _ocr = _o4o * _o2h + _oey;
  if (_ocr < _og7) {
    let _o8w = (_o7k[_ocr] >> _o7l._omc) & 15u;
    atomicAdd(&_o8x[_o8w], 1u);
  }
  workgroupBarrier();
  if (_oey < 16u) {
    _o7j[_oey * _o4p + _o4o] = atomicLoad(&_o8x[_oey]);
  }
}
@compute @workgroup_size(256)
fn sort_scatter(@builtin(local_invocation_index) _oey: u32,
                @builtin(workgroup_id) _orc: vec3u,
                @builtin(num_workgroups) _ogn: vec3u) {
  let _o4o = _of3(_orc, _ogn);
  let _o4p = _olz[_o20];
  if (_o4o >= _o4p) {
    return;
  }
  let _og7 = _olz[_o1v];
  let _ocr = _o4o * _o2h + _oey;
  let _oqh = _ocr < _og7;
  var _och = 0u;
  var _of5 = 0u;
  var _oqi = 0u;
  var _o8w = 0u;
  var _ofc = vec4u(0u);
  var _ocj = vec4u(0u);
  if (_oqh) {
    _och = _ocy[_ocr];
    _oqi = _od0[_ocr];
    if (_om0._og6 != 0u || _om0._oqa == 0u) {
      _of5 = _ocz[_ocr];
    }
    let _oeb = select(_of5, _och, _om0._oqa != 0u);
    _o8w = (_oeb >> _om0._omc) & 15u;
    let _org = _o8w >> 1u;
    let _oeo = 1u << ((_o8w & 1u) * 16u);
    if (_org < 4u) {
      _ofc[_org] = _oeo;
    } else {
      _ocj[_org - 4u] = _oeo;
    }
  }
  _ok7[2u * _oey] = _ofc;
  _ok7[2u * _oey + 1u] = _ocj;
  workgroupBarrier();
  var _omu = 0u;
  for (var _ogx = 1u; _ogx < _o2h; _ogx = _ogx << 1u) {
    let _oh5 = 512u - _omu;
    var _ofd = _ok7[_omu + 2u * _oey];
    var _ock = _ok7[_omu + 2u * _oey + 1u];
    if (_oey >= _ogx) {
      _ofd = _ofd + _ok7[_omu + 2u * (_oey - _ogx)];
      _ock = _ock + _ok7[_omu + 2u * (_oey - _ogx) + 1u];
    }
    _ok7[_oh5 + 2u * _oey] = _ofd;
    _ok7[_oh5 + 2u * _oey + 1u] = _ock;
    _omu = _oh5;
    workgroupBarrier();
  }
  if (_oqh) {
    let _org = _o8w >> 1u;
    var _ohx = 0u;
    if (_org < 4u) {
      _ohx = _ok7[_omu + 2u * _oey][_org];
    } else {
      _ohx = _ok7[_omu + 2u * _oey + 1u][_org - 4u];
    }
    let _ok6 = ((_ohx >> ((_o8w & 1u) * 16u)) & 0xFFFFu) - 1u;
    let _o8n = _o8y[_o8w * _o4p + _o4o] + _ok6;
    _oh9[_o8n] = _och;
    if (_om0._og6 != 0u) {
      _oha[_o8n] = _of5;
    }
    _ohb[_o8n] = _oqi;
  }
}
