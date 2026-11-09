const _o1l: u32 = 0xffffffffu;
const _o18: u32 = 1u;
const _o1: u32 = 2u;
const _o1m: f32 = -1.0e30;
const _o1y: f32 = 1.0e-3;
struct _o2b {
  _oo8: u32,
  _ore: u32,
  _oc6: u32,
  _os8: u32,
  _och: f32,
  _o8r: f32,
  _o9p: f32,
  _o4l: f32,
  _oof: f32,
  _oog: f32,
  _ooe: f32,
  _oo6: f32,
  _o7k: f32,
  _ogb: f32,
  _opy: f32,
  _ocd: f32,
  _o8t: vec4f,
  _os7: vec4f,
  _oms: vec4f,
  _omt: vec4u,
  _oc7: vec4f,
  _ol8: u32,
  _o62: u32,
  _olq: u32,
  _oig: u32,
  _oqw: vec4f,
  _ois: vec4f,
  cut: vec4f,
};
struct _ow {
  _oq2: atomic<i32>,
  _o7b: atomic<u32>,
  _o84: atomic<u32>,
  _o85: atomic<u32>,
  _o8o: array<u32>,
};
struct _ot {
  _oq2: i32,
  _o7b: u32,
  _o84: u32,
  _o85: u32,
  _o8o: array<u32>,
};
struct _ov {
  _o58: array<vec4f, 12>,
  _ofo: vec4f,
  _ocx: vec4f,
};
@group(0) @binding(0) var<uniform> _onk: _o2b;
@group(0) @binding(1) var<storage, read_write> _ol8: array<vec4u>;
@group(0) @binding(2) var<storage, read_write> _olb: array<vec4f>;
@group(0) @binding(3) var<storage, read_write> _o3p: array<vec4f>;
@group(0) @binding(4) var<storage, read_write> _oc5: array<vec4f>;
@group(0) @binding(5) var<storage, read_write> _osn: array<vec4f>;
@group(0) @binding(6) var<storage, read_write> _oro: array<vec4f>;
@group(0) @binding(7) var<storage, read> _omq: array<f32>;
@group(0) @binding(8) var<storage, read_write> _oo5: array<atomic<u32>>;
@group(0) @binding(9) var<storage, read_write> _ofl: array<vec2u>;
@group(0) @binding(10) var<storage, read_write> _o80: _ow;
@group(0) @binding(11) var<uniform> _o63: _ov;
@group(0) @binding(12) var<storage, read_write> _o3g: array<f32>;
@group(0) @binding(13) var<storage, read_write> _oqt: array<f32>;
@group(0) @binding(14) var<storage, read> _o7c: _ot;
@group(0) @binding(15) var<storage, read_write> _o7d: array<u32>;
@group(0) @binding(16) var<uniform> _o7e: vec4u;
struct _o2a {
  _o89: f32,
  g: vec3f,
};
fn _omr(_oi3: vec3f) -> _o2a {
  var _ohn: _o2a;
  let _oh5 = _onk._omt.x;
  let _oh6 = _onk._omt.y;
  let _oh7 = _onk._omt.z;
  let _oao = (_oi3 - _onk._oms.xyz) * _onk._oms.w;
  if (_oao.x < 0.0 || _oao.y < 0.0 || _oao.z < 0.0 || _oao.x > f32(_oh5) - 1.001 || _oao.y > f32(_oh6) - 1.001
      || _oao.z > f32(_oh7) - 1.001) {
    _ohn._o89 = 1.0e6;
    _ohn.g = vec3f(0.0);
    return _ohn;
  }
  let _od7 = u32(_oao.x);
  let _oe3 = u32(_oao.y);
  let _oed = u32(_oao.z);
  let _obp = _oao.x - f32(_od7);
  let _obq = _oao.y - f32(_oe3);
  let _obr = _oao.z - f32(_oed);
  let _oh8 = (_od7 * _oh6 + _oe3) * _oh7 + _oed;
  let _onb = _oh7;
  let _on1 = _oh6 * _oh7;
  let _o5b = _omq[_oh8];
  let _o5c = _omq[_oh8 + 1u];
  let _o5e = _omq[_oh8 + _onb];
  let _o5f = _omq[_oh8 + _onb + 1u];
  let _o5i = _omq[_oh8 + _on1];
  let _o5j = _omq[_oh8 + _on1 + 1u];
  let _o5l = _omq[_oh8 + _on1 + _onb];
  let _o5m = _omq[_oh8 + _on1 + _onb + 1u];
  let _o5a = _o5b + (_o5c - _o5b) * _obr;
  let _o5d = _o5e + (_o5f - _o5e) * _obr;
  let _o5h = _o5i + (_o5j - _o5i) * _obr;
  let _o5k = _o5l + (_o5m - _o5l) * _obr;
  let _o59 = _o5a + (_o5d - _o5a) * _obq;
  let _o5g = _o5h + (_o5k - _o5h) * _obq;
  let _oce = _o5g - _o59;
  let _ocf = (1.0 - _obp) * (_o5d - _o5a) + _obp * (_o5k - _o5h);
  let _oa0 = (_o5c - _o5b) * (1.0 - _obq) + (_o5f - _o5e) * _obq;
  let _oa1 = (_o5j - _o5i) * (1.0 - _obq) + (_o5m - _o5l) * _obq;
  let _ocg = _oa0 * (1.0 - _obp) + _oa1 * _obp;
  let g = vec3f(_oce, _ocf, _ocg);
  let _ogq = length(g);
  _ohn.g = select(vec3f(0.0), g / _ogq, _ogq > 0.0);
  _ohn._o89 = _o59 + (_o5g - _o59) * _obp;
  return _ohn;
}
fn _odb(_ol4: vec4u, _oe3: u32) -> u32 {
  if (_oe3 == 0u) {
    return _ol4.x;
  }
  if (_oe3 == 1u) {
    return _ol4.y;
  }
  return _ol4.z + _oe3 - 2u;
}
fn _o9c(_od7: u32) -> vec3f {
  return _osn[_od7].xyz - _oj9(_olb[_od7].xyz);
}
fn _obf(_of9: vec3f, _ojy: vec3f, _olc: vec3f, _ofa: f32) -> vec3f {
  var _o9z = _ojy - _of9;
  var _ogq = length(_o9z);
  if (_ogq < 1.0e-12) {
    _o9z = _olc;
    _ogq = length(_o9z);
  }
  return _of9 + _o9z * (_ofa / _ogq);
}
fn _o3o(_ond: u32, _or7: f32) {
  atomicMax(&_oo5[_ond], bitcast<u32>(max(_or7, 0.0)));
}
@compute @workgroup_size(64)
fn substep(@builtin(global_invocation_id) _oc1: vec3u, @builtin(num_workgroups) _oh4: vec3u) {
  let _olx = _oc1.x + _oc1.y * _oh4.x * 64u;
  if (_olx >= _onk._ol8) {
    return;
  }
  let _ol4 = _ol8[_olx];
  let _obb = _ol4.w >> 16u;
  if ((_obb & _o1) == 0u) {
    return;
  }
  let _ogq = _ol4.w & 0xffffu;
  if (_ogq < 2u) {
    return;
  }
  let _oir = (_obb & _o18) != 0u;
  let _och = _onk._och;
  let _oej = _onk._o4l;
  let _o4s = _onk._oo6;
  let _o8n = 2.0 * sqrt(_o4s);
  let _odc = 1.0 / _och;
  let _o6g = _onk._o7k / _och;
  var _os7 = vec3f(0.0);
  if (_onk._os8 != 0u) {
    let _obo = f32(_olx);
    let _ocd = 0.6 + 0.4 * sin(2.3 * _onk._opy + 0.0007 * _obo) + 0.25 * sin(5.1 * _onk._opy + 0.0013 * _obo);
    _os7 = _onk._os7.xyz * _ocd;
  }
  let _od8 = _odb(_ol4, 0u);
  var _of8: vec3f;
  var _ojh: vec3f;
  var _oji: vec3f;
  if (_oir) {
    atomicAdd(&_oo5[3], 1u);
    let x = _osn[_od8].xyz;
    let _or2 = _oro[_od8].xyz;
    let a = _onk._ois.xyz + _onk._o9p * (_os7 - _or2);
    let _orb = (_or2 + _och * a) * _onk._o8r;
    var _ojy = x + _och * _orb;
    let _o9h = _o3p[_od8].y;
    for (var _oe1 = 0u; _oe1 < 2u; _oe1 = _oe1 + 1u) {
      let _onf = _omr(_oja(_ojy));
      if (!(_onf._o89 < _o9h)) {
        break;
      }
      _ojy = _ojy + (_o9h - _onf._o89) * _oj8(_onf.g);
    }
    _of8 = _ojy;
    _ojh = _ojy;
    _oji = x;
  } else {
    _osn[_od8] = vec4f(_oj9(_olb[_od8].xyz), 0.0);
    _oro[_od8] = vec4f(0.0);
    _of8 = _oj9(_olb[_od8].xyz);
    _ojh = _of8;
    _oji = _of8;
  }
  var _oqq = vec3f(0.0);
  var _oqp = vec3f(0.0);
  var _oqh = vec3f(0.0);
  var _oqx = vec3f(0.0);
  var _oqy = vec3f(0.0);
  if (!_oir) {
    _oqx = _o9c(_odb(_ol4, 1u));
    if (_ogq > 2u) {
      _oqy = _o9c(_odb(_ol4, 2u));
    }
  }
  var _og5 = 0.0;
  var _og4 = 0.0;
  let _of7 = _ogq - 1u;
  for (var _oed = 1u; _oed < _ogq; _oed = _oed + 1u) {
    let _od7 = _odb(_ol4, _oed);
    let x = _osn[_od7].xyz;
    let _or2 = _oro[_od7].xyz;
    let _okf = _olb[_od7];
    let _o3s = _o3p[_od7];
    var a: vec3f;
    if (_oir) {
      a = _onk._ois.xyz + _onk._o9p * (_os7 - _or2);
    } else {
      _oqq = _oqp;
      _oqp = _oqh;
      _oqh = _oqx;
      _oqx = _oqy;
      if (_oed + 2u < _ogq) {
        _oqy = _o9c(_odb(_ol4, _oed + 2u));
      } else {
        _oqy = vec3f(0.0);
      }
      let _o9f = select(vec3f(0.0), _oqq - 2.0 * _oqp + _oqh, _oed >= 2u);
      let _o9e = select(vec3f(0.0), _oqp - 2.0 * _oqh + _oqx, _oed <= _ogq - 2u);
      let _o9g = select(vec3f(0.0), _oqh - 2.0 * _oqx + _oqy, _oed + 1u <= _ogq - 2u);
      let _o4k = -_o9f + 2.0 * _o9e - _o9g;
      let _oo7 = _onk._oog + (_onk._oof - _onk._oog) * exp(-_okf.w / _onk._ooe);
      a = -_oo7 * _oqh + _oej * _o4k + _onk._o9p * (_os7 - _or2);
      if (_oj7._oda == 0u) {
        a = a + _oj7._oc4.xyz;
      }
      let w = _o3s.z;
      if (_onk._oc6 != 0u && w > 0.0) {
        let _oc2 = _oc5[_od7].xyz + _o3s.w * _onk._o8t.xyz;
        a = a + w * (_o4s * (_oc2 - x) - _o8n * _or2);
      }
    }
    let _orb = (_or2 + _och * a) * _onk._o8r;
    let _oi4 = x + _och * _orb;
    let _old = _o3s.x;
    let _o9h = _o3s.y;
    let _olc = _oj8(_okf.xyz - _olb[_odb(_ol4, _oed - 1u)].xyz);
    var _ojy = _obf(_of8, _oi4, _olc, _old);
    for (var _oe1 = 0u; _oe1 < 2u; _oe1 = _oe1 + 1u) {
      let _onf = _omr(_oja(_ojy));
      if (!(_onf._o89 < _o9h)) {
        break;
      }
      _ojy = _ojy + (_o9h - _onf._o89) * _oj8(_onf.g);
      _ojy = _obf(_of8, _ojy, _olc, _old);
    }
    let _o89 = _ojy - _oi4;
    if (_oed >= 2u || _oir) {
      let _oe3 = _odb(_ol4, _oed - 1u);
      let _orl = (_ojh - _oji) * _odc - _o6g * _o89;
      _oro[_oe3] = vec4f(_orl, 0.0);
      _osn[_oe3] = vec4f(_ojh, 0.0);
      if (!_oir) {
        _og5 = max(_og5, dot(_orl, _orl));
        let _oqo = _ojh - _oj9(_olb[_oe3].xyz);
        _og4 = max(_og4, dot(_oqo, _oqo));
      }
    }
    _ojh = _ojy;
    _oji = x;
    _of8 = _ojy;
    if (_oed == _of7) {
      let _orq = (_ojy - x) * _odc;
      _oro[_od7] = vec4f(_orq, 0.0);
      _osn[_od7] = vec4f(_ojy, 0.0);
      if (!_oir) {
        _og5 = max(_og5, dot(_orq, _orq));
        let _or1 = _ojy - _oj9(_okf.xyz);
        _og4 = max(_og4, dot(_or1, _or1));
      }
    }
  }
  if (!_oir) {
    _o3o(0u, _og5);
    _o3o(1u, _og4);
  }
}
@compute @workgroup_size(64)
fn grab_begin(@builtin(global_invocation_id) _oc1: vec3u, @builtin(num_workgroups) _oh4: vec3u) {
  let _olx = _oc1.x + _oc1.y * _oh4.x * 64u;
  if (_olx >= _onk._oo8) {
    return;
  }
  let _ol4 = _ol8[_olx];
  let _ogq = _ol4.w & 0xffffu;
  let _okj = _onk._oc7.w;
  let _o6d = _onk._oc7.xyz;
  var _o4m = _okj;
  var _oej = 0u;
  for (var _oed = 1u; _oed < _ogq; _oed = _oed + 1u) {
    let _o8q = length(_osn[_odb(_ol4, _oed)].xyz - _o6d);
    if (_o8q < _o4m) {
      _o4m = _o8q;
      _oej = _oed;
    }
  }
  let _on3 = 0.5 * _okj * _okj;
  let _oru = exp(-_o4m * _o4m / _on3);
  let _o3k = max(_olb[_odb(_ol4, _oej)].w, 1.0e-9);
  for (var _oed = 0u; _oed < _ogq; _oed = _oed + 1u) {
    let _od7 = _odb(_ol4, _oed);
    var _o3s = _o3p[_od7];
    if (_oej > 0u && _oed >= 1u && _oed <= _oej) {
      _o3s.z = _oru;
      _o3s.w = pow(min(_olb[_od7].w / _o3k, 1.0), 1.5);
      _oc5[_od7] = _osn[_od7];
    } else {
      _o3s.z = 0.0;
      _o3s.w = 0.0;
    }
    _o3p[_od7] = _o3s;
  }
  if (_oej > 0u) {
    atomicAdd(&_oo5[2], 1u);
  }
}
@compute @workgroup_size(256)
fn reset_state(@builtin(global_invocation_id) _oc1: vec3u, @builtin(num_workgroups) _oh4: vec3u) {
  let _od7 = _oc1.x + _oc1.y * _oh4.x * 256u;
  if (_od7 >= _onk._ore) {
    return;
  }
  _osn[_od7] = vec4f(_oj9(_olb[_od7].xyz), 0.0);
  _oro[_od7] = vec4f(0.0);
  var _o3s = _o3p[_od7];
  _o3s.z = 0.0;
  _o3s.w = 0.0;
  _o3p[_od7] = _o3s;
}
fn _oct(_oa3: vec3f, _oib: vec3f) -> bool {
  let _o9z = _oja(_oa3);
  let _oi3 = _oja(_oib);
  let _onl = _oi3 - _o9z;
  let _ofa = length(_onl);
  if (!(_ofa > 0.0)) {
    return false;
  }
  let _o9a = _onl / _ofa;
  let _oaz = (_o9z - _onk._oms.xyz) * _onk._oms.w;
  let _oay = _o9a * _onk._oms.w;
  let _ocx = vec3f(f32(_onk._omt.x), f32(_onk._omt.y), f32(_onk._omt.z)) - vec3f(1.001 + _o1y);
  var _oly = 0.0;
  var _olz = _ofa;
  for (var _o58 = 0u; _o58 < 3u; _o58 = _o58 + 1u) {
    if (_oay[_o58] == 0.0) {
      if (_oaz[_o58] < _o1y || _oaz[_o58] > _ocx[_o58]) {
        return false;
      }
    } else {
      let _op8 = (_o1y - _oaz[_o58]) / _oay[_o58];
      let _oph = (_ocx[_o58] - _oaz[_o58]) / _oay[_o58];
      _oly = max(_oly, min(_op8, _oph));
      _olz = min(_olz, max(_op8, _oph));
    }
  }
  if (!(_oly <= _olz)) {
    return false;
  }
  let _od1 = _onk.cut.x;
  var _olx = _oly;
  for (var _oe2 = 0u; _oe2 < 256u; _oe2 = _oe2 + 1u) {
    if (_olx > _olz) {
      return false;
    }
    let _o89 = _omr(_o9z + _olx * _o9a)._o89;
    if (_o89 < 0.0 && _olx < _ofa - _od1) {
      return true;
    }
    _olx = _olx + max(_o89, _od1);
  }
  return false;
}
fn _ofc(a: vec3f, b: vec3f, _oou: f32) -> vec3f {
  return a + _oou * (b - a);
}
fn _omo(_osh: vec3f, _osi: vec3f) -> f32 {
  let _o9z = _o63._o58[0].xyz;
  let _o8a = _o63._o58[1].xyz;
  let _o8b = _o63._o58[2].xyz;
  let _ofy = _o63._o58[3].xyz;
  let _oh8 = _o63._o58[4].xyz;
  let _oq1 = _onk.cut.z;
  let _o8m = dot(_osh - _oh8, _ofy);
  let _o8p = dot(_osi - _oh8, _ofy);
  if (!((_o8m < -_oq1 && _o8p > _oq1) || (_o8m > _oq1 && _o8p < -_oq1))) {
    return -1.0;
  }
  let _oou = _o8m / (_o8m - _o8p);
  let _oi3 = _ofc(_osh, _osi, _oou);
  let _ojy = _oi3 - _o9z;
  if (dot(cross(_o8a, _ojy), _ofy) < 0.0 || dot(cross(_ojy, _o8b), _ofy) < 0.0 || !(dot(_ojy, _o8a + _o8b) > 0.0)) {
    return -1.0;
  }
  if (_oct(_o9z, _oi3)) {
    return -1.0;
  }
  return _oou;
}
fn _o6q(_od7: u32) -> vec3f {
  let _oao = 3u * _od7;
  return vec3f(_o63._o58[_oao >> 2u][_oao & 3u], _o63._o58[(_oao + 1u) >> 2u][(_oao + 1u) & 3u],
               _o63._o58[(_oao + 2u) >> 2u][(_oao + 2u) & 3u]);
}
fn _o6s(_osh: vec3f, _osi: vec3f) -> f32 {
  if (any(min(_osh, _osi) > _o63._ocx.xyz) || any(max(_osh, _osi) < _o63._ofo.xyz)) {
    return -1.0;
  }
  let r = _o63._ofo.w;
  let _okd = r * r;
  let _o89 = _osi - _osh;
  let _o2r = dot(_o89, _o89);
  var _o4m = 2.0;
  for (var _od7 = 0u; _od7 < 16u; _od7 = _od7 + 1u) {
    let _ojy = _osh - _o6q(_od7);
    let _o51 = dot(_o89, _ojy);
    let _o7s = dot(_ojy, _ojy) - _okd;
    if (_o7s <= 0.0) {
      _o4m = 0.0;
    } else if (_o51 < 0.0) {
      let x = cross(_o89, _ojy);
      let _o9b = _o2r * _okd - dot(x, x);
      if (_o9b >= 0.0) {
        let _opr = _o7s / (sqrt(_o9b) - _o51);
        if (_opr <= 1.0) {
          _o4m = min(_o4m, _opr);
        }
      }
    }
  }
  return select(-1.0, _o4m, _o4m <= 1.0);
}
fn _opb() -> i32 {
  let _oed = atomicSub(&_o80._oq2, 1);
  if (_oed <= 0) {
    atomicAdd(&_o80._oq2, 1);
    return -1;
  }
  return i32(_o80._o8o[u32(_oed - 1)]);
}
fn _o9i(_olr: vec3f) -> f32 {
  let _o89 = _omr(_olr)._o89;
  if (_o89 < 0.0) {
    return _o1m;
  }
  return min(_onk.cut.x, _o89);
}
fn _o7n(_o58: u32) {
  _o80._o8o[3u * _onk._o62 + _o58] = bitcast<u32>(_onk._opy);
  atomicAdd(&_o80._o84, 1u);
  atomicAdd(&_o80._o85, 1u);
}
fn _ons(_olx: u32, _ol4: vec4u, _ogq: u32, _oe3: u32, _oou: f32) {
  let _o6k = _opb();
  if (_o6k < 0) {
    return;
  }
  let _o58 = u32(_o6k);
  let a = _odb(_ol4, _oe3 - 1u);
  let b = _odb(_ol4, _oe3);
  let r = _ofl[b].x;
  let _o3t = _o3p[b];
  let _oew = _o3t.x;
  let _oki = _olb[a];
  let _ol0 = _olb[b];
  let _oi3 = _ofc(_osn[a].xyz, _osn[b].xyz, _oou);
  let _orn = _ofc(_oro[a].xyz, _oro[b].xyz, _oou);
  let _olr = _ofc(_oki.xyz, _ol0.xyz, _oou);
  let _o3j = _oki.w + _oou * (_ol0.w - _oki.w);
  let _o9j = _o9i(_olr);
  let _ok0 = _onk._ore + 2u * _o58;
  let bb = _ok0 + 1u;
  let _o9z = _onk._olq + _o58;
  _osn[_ok0] = vec4f(_oi3, 0.0);
  _oro[_ok0] = vec4f(_orn, 0.0);
  _olb[_ok0] = vec4f(_olr, _o3j);
  _o3p[_ok0] = vec4f(0.0, _o9j, 0.0, 0.0);
  _ofl[_ok0] = vec2u(_o1l, _o1l);
  _osn[bb] = _osn[b];
  _oro[bb] = _oro[b];
  _olb[bb] = _ol0;
  _o3p[bb] = vec4f(_oew * (1.0 - _oou), _o3t.y, 0.0, 0.0);
  _ofl[bb] = vec2u(_o9z, _ok0);
  if (_oe3 + 1u <= _ogq - 1u) {
    _ofl[_odb(_ol4, _oe3 + 1u)].y = bb;
  }
  _osn[b] = vec4f(_oi3, 0.0);
  _oro[b] = vec4f(_orn, 0.0);
  _olb[b] = vec4f(_olr, _o3j);
  _o3p[b] = vec4f(_oew * _oou, _o9j, _o3t.z, _o3t.w);
  var _onz = 0u;
  if (_oe3 + 1u <= _ogq - 1u) {
    _onz = _odb(_ol4, _oe3 + 1u);
  }
  _ol8[_onk._oo8 + _o58] = vec4u(_ok0, bb, _onz, (_ogq - _oe3 + 1u) | ((_o18 | _o1) << 16u));
  _ol8[_olx].w = (_oe3 + 1u) | (_ol4.w & 0xffff0000u);
  let _oed = atomicAdd(&_o80._o7b, 1u);
  _o80._o8o[_onk._o62 + 2u * _oed] = r;
  _o80._o8o[_onk._o62 + 2u * _oed + 1u] = _o9z;
  _o7n(_o58);
}
fn _orc(_olx: u32, _ol4: vec4u, _ogq: u32, _oe7: u32) {
  let _o6k = _opb();
  if (_o6k < 0) {
    return;
  }
  let _o58 = u32(_o6k);
  let _or2 = _odb(_ol4, _oe7 - 1u);
  let w = _odb(_ol4, _oe7);
  let _ok0 = _onk._ore + 2u * _o58;
  _osn[_ok0] = _osn[_or2];
  _oro[_ok0] = _oro[_or2];
  _olb[_ok0] = _olb[_or2];
  _o3p[_ok0] = vec4f(0.0, _o3p[_or2].y, 0.0, 0.0);
  _ofl[_ok0] = vec2u(_o1l, _o1l);
  _ofl[w].y = _ok0;
  var _onz = 0u;
  if (_oe7 + 1u <= _ogq - 1u) {
    _onz = _odb(_ol4, _oe7 + 1u);
  }
  _ol8[_onk._oo8 + _o58] = vec4u(_ok0, w, _onz, (_ogq - _oe7 + 1u) | ((_o18 | _o1) << 16u));
  _ol8[_olx].w = _oe7 | (_ol4.w & 0xffff0000u);
  _o7n(_o58);
}
@compute @workgroup_size(64)
fn cut(@builtin(global_invocation_id) _oc1: vec3u, @builtin(num_workgroups) _oh4: vec3u) {
  let _olx = _oc1.x + _oc1.y * _oh4.x * 64u;
  if (_olx >= _onk._oo8) {
    return;
  }
  let _ol4 = _ol8[_olx];
  let _obb = _ol4.w >> 16u;
  if ((_obb & _o1) == 0u || (_obb & _o18) != 0u) {
    return;
  }
  let _ogq = _ol4.w & 0xffffu;
  let _o6v = _o63._ocx.w > 0.5;
  let _ofn = _onk.cut.y;
  for (var _oe3 = 1u; _oe3 < _ogq; _oe3 = _oe3 + 1u) {
    let _osh = _osn[_odb(_ol4, _oe3 - 1u)].xyz;
    let _osi = _osn[_odb(_ol4, _oe3)].xyz;
    var _oou: f32;
    if (_o6v) {
      _oou = _o6s(_osh, _osi);
    } else {
      _oou = _omo(_osh, _osi);
    }
    if (_oou < 0.0) {
      continue;
    }
    let _oev = length(_osi - _osh);
    var _oe7 = 0u;
    if (_oou >= 1.0 || (_oou > 0.5 && (1.0 - _oou) * _oev < _ofn)) {
      _oe7 = _oe3 + 1u;
    } else if (_oou <= 0.5 && _oou * _oev < _ofn) {
      _oe7 = _oe3;
    }
    if (_oe7 == 0u) {
      _ons(_olx, _ol4, _ogq, _oe3, _oou);
    } else if (_oe7 >= 2u && _oe7 <= _ogq - 1u) {
      _orc(_olx, _ol4, _ogq, _oe7);
    }
    return;
  }
}
@compute @workgroup_size(64)
fn copy_rows(@builtin(global_invocation_id) _oc1: vec3u, @builtin(num_workgroups) _oh4: vec3u) {
  let _od7 = _oc1.x + _oc1.y * _oh4.x * 64u;
  if (_od7 >= _o7c._o7b) {
    return;
  }
  let w = _o7e.x;
  let _o61 = _o7e.y;
  let _onu = _o7c._o8o[_o61 + 2u * _od7];
  let _o9r = _o7c._o8o[_o61 + 2u * _od7 + 1u];
  for (var _oed = 0u; _oed < w; _oed = _oed + 1u) {
    _o7d[_o9r * w + _oed] = _o7d[_onu * w + _oed];
  }
}
@compute @workgroup_size(64)
fn remove_pieces(@builtin(global_invocation_id) _oc1: vec3u, @builtin(num_workgroups) _oh4: vec3u) {
  let _o58 = _oc1.x + _oc1.y * _oh4.x * 64u;
  if (_o58 >= _onk._o62) {
    return;
  }
  let r = _onk._oo8 + _o58;
  let _ol4 = _ol8[r];
  if (((_ol4.w >> 16u) & _o1) == 0u) {
    return;
  }
  let _ogq = _ol4.w & 0xffffu;
  let _oqw = _onk._oqw.xyz;
  var _oq2 = -3.0e38;
  var _ob4 = true;
  for (var _oe3 = 0u; _oe3 < _ogq; _oe3 = _oe3 + 1u) {
    let x = _osn[_odb(_ol4, _oe3)].xyz;
    _ob4 = _ob4 && _odz(x.x) && _odz(x.y) && _odz(x.z);
    _oq2 = max(_oq2, dot(x, _oqw));
  }
  let _o3c = _onk._opy - bitcast<f32>(_o80._o8o[3u * _onk._o62 + _o58]);
  if (!(_oq2 < _onk._oqw.w || _o3c >= _onk.cut.w - 1.0e-9 || !_ob4)) {
    return;
  }
  for (var _oe3 = 0u; _oe3 < _ogq; _oe3 = _oe3 + 1u) {
    let _or2 = _odb(_ol4, _oe3);
    let g = _ofl[_or2].x;
    if (g != _o1l) {
      _o3g[g] = 0.0;
      _oqt[8u * g + 4u] = 0.0;
    }
    _ofl[_or2].y = _o1l;
  }
  _ol8[r].w = _ogq;
  let _ond = atomicAdd(&_o80._oq2, 1);
  _o80._o8o[u32(_ond)] = _o58;
}
