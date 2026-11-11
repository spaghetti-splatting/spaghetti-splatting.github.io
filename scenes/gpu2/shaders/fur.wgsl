const _o1e = 24u;
const _o1d = 32u;
struct _o1h {
  _oci: u32,
  _omy: u32,
  _opu: u32,
  _ojn: u32,
  _ord: f32,
  _oab: f32,
  _opl: f32,
  _or5: f32,
  _oti: vec4f,
  _op1: vec4f,
  _oiq: vec4f,
  _o42: vec4f,
  _ofd: array<vec4f, 24>,
  _oaj: array<vec4f, 24>,
  _ofz: array<vec4f, 66>,
  _opf: array<vec4f, 64>,
  grab: vec4f,
  _od2: vec4f,
  _o58: vec4f,
  _o57: vec4f,
  _ojy: vec4f,
};
@group(0) @binding(0) var<uniform> _oc1: _o1h;
@group(0) @binding(1) var<storage, read> _ocj: array<u32>;
@group(0) @binding(2) var<storage, read_write> _oca: array<vec4f>;
@group(0) @binding(3) var<storage, read_write> _ock: array<vec4f>;
@group(0) @binding(4) var<storage, read_write> _ocg: array<vec4f>;
@group(0) @binding(5) var<storage, read_write> _oau: array<f32>;
@group(0) @binding(6) var<storage, read_write> _os9: array<f32>;
@group(0) @binding(7) var<storage, read_write> _ooh: array<f32>;
@group(0) @binding(8) var<storage, read> _ocb: array<f32>;
fn _occ(_ocy: vec3u, _oib: vec3u) -> u32 {
  return _ocy.x + _ocy.y * _oib.x * 256u;
}
fn _oce(a: vec4f, b: vec4f) -> vec4f {
  let _o3x = a.yzw;
  let _o5f = b.yzw;
  return vec4f(a.x * b.x - dot(_o3x, _o5f), a.x * _o5f + b.x * _o3x + cross(_o3x, _o5f));
}
fn _ocf(_ol1: vec4f, _on4: vec3f) -> vec3f {
  let _oq8 = 2.0 * cross(_ol1.yzw, _on4);
  return _on4 + _ol1.x * _oq8 + cross(_ol1.yzw, _oq8);
}
fn _och(_o42: vec3f, _o3o: f32, _osh: vec3f) -> vec3f {
  let _o5j = cos(_o3o);
  let _on4 = sin(_o3o);
  return _osh * _o5j + cross(_o42, _osh) * _on4 + _o42 * dot(_o42, _osh) * (1.0 - _o5j);
}
@compute @workgroup_size(256)
fn fur_gather(@builtin(global_invocation_id) _ocy: vec3u, @builtin(num_workgroups) _oib: vec3u) {
  let r = _occ(_ocy, _oib);
  if (r >= _oc1._omy) {
    return;
  }
  let _omw = _ocj[r];
  let _orw = 8u * _omw;
  let _op4 = 24u * _omw;
  let _oaj = 6u * _omw;
  _ocg[9u * r] = vec4f(_os9[_orw], _os9[_orw + 1u], _os9[_orw + 2u], _os9[_orw + 3u]);
  for (var _ofd = 0u; _ofd < 6u; _ofd = _ofd + 1u) {
    let _oif = _op4 + 4u * _ofd;
    _ocg[9u * r + 1u + _ofd] = vec4f(_ooh[_oif], _ooh[_oif + 1u], _ooh[_oif + 2u], _ooh[_oif + 3u]);
  }
  _ocg[9u * r + 7u] = vec4f(_oau[_oaj], _oau[_oaj + 1u], _oau[_oaj + 2u], _oau[_oaj + 3u]);
  _ocg[9u * r + 8u] = vec4f(_oau[_oaj + 4u], _oau[_oaj + 5u], 0.0, 0.0);
}
@compute @workgroup_size(256)
fn fur_prep(@builtin(global_invocation_id) _ocy: vec3u, @builtin(num_workgroups) _oib: vec3u) {
  let _ojb = _occ(_ocy, _oib);
  if (_ojb >= 2u * _oc1._oci) {
    return;
  }
  let r = _ojb / 2u;
  let _of3 = _ojb % 2u;
  let a = _ocg[9u * r + 7u];
  let b = _ocg[9u * r + 8u];
  var x = a.xyz;
  if (_of3 == 1u) {
    x = vec3f(a.w, b.x, b.y);
  }
  let _odd = _ocb[6u * _ojb];
  let _o1n = _ocb[6u * _ojb + 1u];
  let _ohv = normalize(vec3f(_ocb[6u * _ojb + 2u], _ocb[6u * _ojb + 3u], _ocb[6u * _ojb + 4u]));
  let _on4 = clamp(_odd / _o1n, 0.0, 1.0);
  _oca[2u * _ojb] = vec4f(x - _odd * _ohv, _on4 * (6.0 - 4.0 * _on4 + _on4 * _on4) / 3.0);
  _oca[2u * _ojb + 1u] = vec4f(_ohv, _o1n / _oc1._oiq.z);
}
@compute @workgroup_size(256)
fn fur_restore(@builtin(global_invocation_id) _ocy: vec3u, @builtin(num_workgroups) _oib: vec3u) {
  let r = _occ(_ocy, _oib);
  if (r >= _oc1._omy) {
    return;
  }
  let _omw = _ocj[r];
  let _orw = 8u * _omw;
  let _op4 = 24u * _omw;
  let _oaj = 6u * _omw;
  let _ol1 = _ocg[9u * r];
  _os9[_orw] = _ol1.x;
  _os9[_orw + 1u] = _ol1.y;
  _os9[_orw + 2u] = _ol1.z;
  _os9[_orw + 3u] = _ol1.w;
  for (var _ofd = 0u; _ofd < 6u; _ofd = _ofd + 1u) {
    let _oif = _op4 + 4u * _ofd;
    let _on4 = _ocg[9u * r + 1u + _ofd];
    _ooh[_oif] = _on4.x;
    _ooh[_oif + 1u] = _on4.y;
    _ooh[_oif + 2u] = _on4.z;
    _ooh[_oif + 3u] = _on4.w;
  }
  let a = _ocg[9u * r + 7u];
  let b = _ocg[9u * r + 8u];
  _oau[_oaj] = a.x;
  _oau[_oaj + 1u] = a.y;
  _oau[_oaj + 2u] = a.z;
  _oau[_oaj + 3u] = a.w;
  _oau[_oaj + 4u] = b.x;
  _oau[_oaj + 5u] = b.y;
  for (var _ofd = 0u; _ofd < 4u; _ofd = _ofd + 1u) {
    _ock[4u * r + _ofd] = vec4f(0.0);
  }
}
@compute @workgroup_size(256)
fn fur_step(@builtin(global_invocation_id) _ocy: vec3u, @builtin(num_workgroups) _oib: vec3u) {
  let _ojb = _occ(_ocy, _oib);
  if (_ojb >= 2u * _oc1._oci) {
    return;
  }
  let a = _oca[2u * _ojb];
  let b = _oca[2u * _ojb + 1u];
  let _omr = a.xyz;
  let _ohv = b.xyz;
  let _ogz = b.w;
  let _ocr = _oc1._op1.x * _ogz;
  let _o68 = _oc1._op1.y;
  let _ou2 = _oc1._op1.z;
  let w = min(_oc1._oiq.x / _ogz, _oc1._oiq.y);
  var _ol1 = _ock[2u * _ojb].xyz;
  var _ola = _ock[2u * _ojb + 1u].xyz;
  let _oab = _oc1._oab;
  for (var _on4 = 0u; _on4 < _oc1._opu; _on4 = _on4 + 1u) {
    let _oq8 = _oc1._ord + f32(_on4) * _oab;
    var _o1b = _oc1._oti.xyz;
    for (var _oh1 = 0u; _oh1 < _o1e; _oh1 = _oh1 + 1u) {
      let _ofy = _oc1._ofd[_oh1];
      let _oao = _oc1._oaj[_oh1];
      _o1b = _o1b + _oao.xyz * sin(dot(_ofy.xyz, _omr) + _ofy.w - 6.283185307 * _oao.w * _oq8);
    }
    _o1b = _oc1._opl * _o1b;
    let _o1i = _ocr * (_o1b - dot(_o1b, _ohv) * _ohv);
    let g = length(_o1i);
    var _ol5 = vec3f(0.0);
    if (g > 1.0e-9) {
      _ol5 = _o68 * tanh(g / _o68) * _o1i / g;
    }
    let _o1n = _ogz * _oc1._oiq.z;
    if (_oc1._od2.w > 0.5) {
      let _orw = length(_omr - _oc1.grab.xyz) / _oc1.grab.w;
      if (_orw < 1.0) {
        let _ofd = (1.0 - _orw * _orw) * (1.0 - _orw * _orw);
        let _o8v = _oc1._od2.xyz;
        _ol5 = _ol5 + _ofd * (_o8v - dot(_o8v, _ohv) * _ohv) / _o1n;
      }
    }
    let r = _omr - _oc1._ojy.xyz;
    let _o38 = -(cross(_oc1._o57.xyz, r) + cross(_oc1._o58.xyz, cross(_oc1._o58.xyz, r)));
    _ol5 = _ol5 + (_o38 - dot(_o38, _ohv) * _ohv) / (w * w * _o1n);
    let _olc = length(_ol5);
    if (_olc > 1.5707963) {
      _ol5 = _ol5 * (1.5707963 / _olc);
    }
    _ola = _ola + _oab * (w * w * (_ol5 - _ol1) - 2.0 * _ou2 * w * _ola);
    _ol1 = _ol1 + _oab * _ola;
    _ol1 = _ol1 - dot(_ol1, _ohv) * _ohv;
  }
  _ock[2u * _ojb] = vec4f(_ol1, 0.0);
  _ock[2u * _ojb + 1u] = vec4f(_ola, 0.0);
}
fn _ocd(r: u32, _of3: u32, x: vec3f) -> vec3f {
  let a = _oca[4u * r + 2u * _of3];
  let b = _oca[4u * r + 2u * _of3 + 1u];
  if (r < _oc1._oci) {
    let _ol1 = _ock[4u * r + 2u * _of3].xyz;
    let _o3n = length(_ol1);
    if (_o3n < 1.0e-9) {
      return x;
    }
    let _o3y = cross(b.xyz, _ol1 / _o3n);
    let _o3f = length(_o3y);
    if (_o3f < 1.0e-9) {
      return x;
    }
    return a.xyz + _och(_o3y / _o3f, _o3n * a.w, x - a.xyz);
  }
  let _on4 = a.w;
  let _o3q = u32(b.x + 0.5);
  let _ofw = _on4 * f32(_o1d);
  let _ofd = min(u32(_ofw), _o1d - 1u);
  let _oc2 = _ofw - f32(_ofd);
  let _o1s = _oc1._ofz[_o3q * (_o1d + 1u) + _ofd].xyz + _oc2 * _oc1._opf[_o3q * _o1d + _ofd].xyz;
  return _o1s + _och(_oc1._o42.xyz, _oc1._or5 * _on4 * _on4, a.xyz);
}
@compute @workgroup_size(256)
fn fur_apply(@builtin(global_invocation_id) _ocy: vec3u, @builtin(num_workgroups) _oib: vec3u) {
  let r = _occ(_ocy, _oib);
  if (r >= _oc1._omy) {
    return;
  }
  let _omw = _ocj[r];
  let _olq = _ocg[9u * r + 7u];
  let _om9 = _ocg[9u * r + 8u];
  let ra = _olq.xyz;
  let rb = vec3f(_olq.w, _om9.x, _om9.y);
  let _ojj = _ocd(r, 0u, ra);
  let _ojv = _ocd(r, 1u, rb);
  let _oaj = 6u * _omw;
  _oau[_oaj] = _ojj.x;
  _oau[_oaj + 1u] = _ojj.y;
  _oau[_oaj + 2u] = _ojj.z;
  _oau[_oaj + 3u] = _ojv.x;
  _oau[_oaj + 4u] = _ojv.y;
  _oau[_oaj + 5u] = _ojv.z;
  let _ohw = normalize(rb - ra);
  let _ohx = normalize(_ojv - _ojj);
  let _o8v = dot(_ohw, _ohx);
  var _ol1: vec4f;
  if (_o8v < -0.999999) {
    var _o42 = cross(_ohw, vec3f(1.0, 0.0, 0.0));
    if (dot(_o42, _o42) < 1.0e-6) {
      _o42 = cross(_ohw, vec3f(0.0, 1.0, 0.0));
    }
    _ol1 = vec4f(0.0, normalize(_o42));
  } else {
    _ol1 = normalize(vec4f(1.0 + _o8v, cross(_ohw, _ohx)));
  }
  let _orw = 8u * _omw;
  let _ol6 = normalize(_oce(_ol1, _ocg[9u * r]));
  _os9[_orw] = _ol6.x;
  _os9[_orw + 1u] = _ol6.y;
  _os9[_orw + 2u] = _ol6.z;
  _os9[_orw + 3u] = _ol6.w;
  let _op4 = 24u * _omw;
  for (var _ofd = 0u; _ofd < 6u; _ofd = _ofd + 1u) {
    let _osh = _ocg[9u * r + 1u + _ofd];
    let flat = array<f32, 4>(_osh.x, _osh.y, _osh.z, _osh.w);
    for (var _o5j = 0u; _o5j < 4u; _o5j = _o5j + 1u) {
      _ooh[_op4 + 4u * _ofd + _o5j] = flat[_o5j];
    }
  }
  for (var _ofd = 0u; _ofd < 8u; _ofd = _ofd + 1u) {
    let _oif = _op4 + 3u * _ofd;
    let _on4 = _ocf(_ol1, vec3f(_ooh[_oif], _ooh[_oif + 1u], _ooh[_oif + 2u]));
    _ooh[_oif] = _on4.x;
    _ooh[_oif + 1u] = _on4.y;
    _ooh[_oif + 2u] = _on4.z;
  }
}
