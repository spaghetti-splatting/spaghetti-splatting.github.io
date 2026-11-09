struct _o1b {
  _ofo: vec4f,
  _o99: vec4u,
  _oma: vec4f,
};
@group(0) @binding(0) var<uniform> _obi: _o1b;
@group(0) @binding(1) var<storage, read> _ol8: array<vec4u>;
@group(0) @binding(2) var<storage, read> _osn: array<vec4f>;
@group(0) @binding(3) var<storage, read_write> _oro: array<vec4f>;
@group(0) @binding(4) var<storage, read_write> _oc8: array<atomic<i32>>;
@group(0) @binding(5) var<storage, read_write> _o6i: array<vec4i>;
@group(0) @binding(6) var<storage, read_write> _oo5: array<atomic<u32>>;
@group(0) @binding(7) var<storage, read_write> _o93: array<f32>;
const _o1g: i32 = 2147483647i;
const _o1h: i32 = -2147483647i - 1i;
const _o18: u32 = 1u;
const _o1: u32 = 2u;
fn _odb(_ol4: vec4u, _oe3: u32) -> u32 {
  if (_oe3 == 0u) {
    return _ol4.x;
  }
  if (_oe3 == 1u) {
    return _ol4.y;
  }
  return _ol4.z + _oe3 - 2u;
}
fn _ob6(_ol4: vec4u) -> u32 {
  let _obb = _ol4.w >> 16u;
  if ((_obb & _o1) == 0u) {
    return _ol4.w & 0xffffu;
  }
  return select(1u, 0u, (_obb & _o18) != 0u);
}
fn _osd(_ohh: i32, _olx: i32) -> bool {
  return (_olx > 0i && _ohh > _o1g - _olx) || (_olx < 0i && _ohh < _o1h - _olx);
}
struct _op {
  _o49: u32,
  _oao: vec3f,
  _odk: bool,
};
fn _o66(x: vec3f) -> _op {
  var _o58: _op;
  _o58._o49 = 0u;
  _o58._oao = vec3f(0.0);
  let g = (_oja(x) - _obi._ofo.xyz) * _obi._ofo.w;
  let _o67 = vec3f(_obi._o99.xyz - vec3u(1u));
  _o58._odk = all(g >= vec3f(0.0)) && all(g < _o67);
  if (!_o58._odk) {
    return _o58;
  }
  let _od8 = vec3u(floor(g));
  _o58._oao = g - vec3f(_od8);
  _o58._o49 = (_od8.x * _obi._o99.y + _od8.y) * _obi._o99.z + _od8.z;
  return _o58;
}
fn _o7g(_o58: _op, _oed: u32) -> u32 {
  let _o9w = (_oed >> 2u) & 1u;
  let _o9x = (_oed >> 1u) & 1u;
  let _o9y = _oed & 1u;
  return _o58._o49 + (_o9w * _obi._o99.y + _o9x) * _obi._o99.z + _o9y;
}
fn _o7i(_o58: _op, _oed: u32) -> f32 {
  let wx = select(1.0 - _o58._oao.x, _o58._oao.x, ((_oed >> 2u) & 1u) != 0u);
  let wy = select(1.0 - _o58._oao.y, _o58._oao.y, ((_oed >> 1u) & 1u) != 0u);
  let wz = select(1.0 - _o58._oao.z, _o58._oao.z, (_oed & 1u) != 0u);
  return wx * wy * wz;
}
fn _ob9(_o58: _op, _oed: u32, _or2: vec3f) -> vec4i {
  let w = _o7i(_o58, _oed);
  let _osf = round(w * _or2 * _obi._oma.y);
  return vec4i(i32(round(w * _obi._oma.x)), i32(_osf.x), i32(_osf.y), i32(_osf.z));
}
fn _onq(_od7: u32) -> vec3f {
  return clamp(_oro[_od7].xyz, vec3f(-_obi._oma.z), vec3f(_obi._oma.z));
}
@compute @workgroup_size(64)
fn friction_splat(@builtin(global_invocation_id) _oc1: vec3u, @builtin(num_workgroups) _oh4: vec3u) {
  let r = _oc1.x + _oc1.y * _oh4.x * 64u;
  if (r >= _obi._o99.w) {
    return;
  }
  let _ol4 = _ol8[r];
  let _ogq = _ol4.w & 0xffffu;
  var _osc = 0u;
  for (var _oe3 = _ob6(_ol4); _oe3 < _ogq; _oe3 = _oe3 + 1u) {
    let _od7 = _odb(_ol4, _oe3);
    let _o58 = _o66(_osn[_od7].xyz);
    if (!_o58._odk) {
      continue;
    }
    let _or2 = _onq(_od7);
    for (var _oed = 0u; _oed < 8u; _oed = _oed + 1u) {
      let _olx = _ob9(_o58, _oed, _or2);
      let _oh8 = 4u * _o7g(_o58, _oed);
      if (_olx.x != 0i && _osd(atomicAdd(&_oc8[_oh8], _olx.x), _olx.x)) {
        _osc = _osc + 1u;
      }
      if (_olx.y != 0i && _osd(atomicAdd(&_oc8[_oh8 + 1u], _olx.y), _olx.y)) {
        _osc = _osc + 1u;
      }
      if (_olx.z != 0i && _osd(atomicAdd(&_oc8[_oh8 + 2u], _olx.z), _olx.z)) {
        _osc = _osc + 1u;
      }
      if (_olx.w != 0i && _osd(atomicAdd(&_oc8[_oh8 + 3u], _olx.w), _olx.w)) {
        _osc = _osc + 1u;
      }
    }
  }
  if (_osc != 0u) {
    atomicAdd(&_oo5[4], _osc);
  }
}
fn _oca(_o58: _op) -> vec3f {
  var _org = vec3f(0.0);
  for (var _oed = 0u; _oed < 8u; _oed = _oed + 1u) {
    let _oh8 = 4u * _o7g(_o58, _oed);
    let _ose = atomicLoad(&_oc8[_oh8]);
    if (_ose > 0i) {
      let _orp = vec3f(f32(atomicLoad(&_oc8[_oh8 + 1u])), f32(atomicLoad(&_oc8[_oh8 + 2u])),
                       f32(atomicLoad(&_oc8[_oh8 + 3u])));
      _org = _org + _o7i(_o58, _oed) * (_orp / f32(_ose));
    }
  }
  return _org * (_obi._oma.x / _obi._oma.y);
}
@compute @workgroup_size(64)
fn friction_gather(@builtin(global_invocation_id) _oc1: vec3u, @builtin(num_workgroups) _oh4: vec3u) {
  let r = _oc1.x + _oc1.y * _oh4.x * 64u;
  if (r >= _obi._o99.w) {
    return;
  }
  let _ol4 = _ol8[r];
  let _ogq = _ol4.w & 0xffffu;
  for (var _oe3 = _ob6(_ol4); _oe3 < _ogq; _oe3 = _oe3 + 1u) {
    let _od7 = _odb(_ol4, _oe3);
    let _o58 = _o66(_osn[_od7].xyz);
    if (!_o58._odk) {
      continue;
    }
    let _org = _oca(_o58);
    let _or2 = _oro[_od7].xyz;
    _oro[_od7] = vec4f(_or2 + _obi._oma.w * (_org - _or2), 0.0);
  }
}
@compute @workgroup_size(64)
fn friction_deviation(@builtin(global_invocation_id) _oc1: vec3u, @builtin(num_workgroups) _oh4: vec3u) {
  let r = _oc1.x + _oc1.y * _oh4.x * 64u;
  if (r >= _obi._o99.w) {
    return;
  }
  let _ol4 = _ol8[r];
  let _ogq = _ol4.w & 0xffffu;
  for (var _oe3 = _ob6(_ol4); _oe3 < _ogq; _oe3 = _oe3 + 1u) {
    let _od7 = _odb(_ol4, _oe3);
    var _o89 = -1.0;
    let _o58 = _o66(_osn[_od7].xyz);
    if (_o58._odk) {
      _o89 = length(_oro[_od7].xyz - _oca(_o58));
    }
    _o93[_od7] = _o89;
  }
}
@compute @workgroup_size(64)
fn friction_check(@builtin(global_invocation_id) _oc1: vec3u, @builtin(num_workgroups) _oh4: vec3u) {
  let r = _oc1.x + _oc1.y * _oh4.x * 64u;
  if (r >= _obi._o99.w) {
    return;
  }
  let _ol4 = _ol8[r];
  let _ogq = _ol4.w & 0xffffu;
  for (var _oe3 = _ob6(_ol4); _oe3 < _ogq; _oe3 = _oe3 + 1u) {
    let _od7 = _odb(_ol4, _oe3);
    var _oq3 = vec4i(0);
    let _o58 = _o66(_osn[_od7].xyz);
    if (_o58._odk) {
      let _or2 = _onq(_od7);
      for (var _oed = 0u; _oed < 8u; _oed = _oed + 1u) {
        _oq3 = _oq3 + _ob9(_o58, _oed, _or2);
      }
    }
    _o6i[_od7] = _oq3;
  }
}
