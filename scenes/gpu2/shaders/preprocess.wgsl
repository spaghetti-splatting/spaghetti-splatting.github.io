struct _o1o {
  _o3b: vec4f,
  _o4m: vec4f,
  ab: vec4f,
  _obj: vec4f,
  _okl: vec4u,
};
@group(0) @binding(0) var<storage, read> _oe7: array<u32>;
@group(0) @binding(1) var<storage, read> _o9w: array<f32>;
@group(0) @binding(2) var<storage, read> _oq4: array<f32>;
@group(0) @binding(3) var<storage, read> _o39: array<f32>;
@group(0) @binding(4) var<storage, read> _oaf: array<f32>;
@group(0) @binding(5) var<storage, read> _o7l: array<u32>;
@group(0) @binding(6) var<storage, read_write> _oiy: array<_o1o>;
@group(0) @binding(7) var<storage, read_write> _op6: array<u32>;
@group(0) @binding(8) var<uniform> _o5o: _oo;
@group(0) @binding(0) var<storage, read> _o9i: array<_o1o>;
@group(0) @binding(1) var<storage, read> _o9h: array<u32>;
@group(0) @binding(2) var<storage, read> _o9g: array<u32>;
@group(0) @binding(3) var<storage, read_write> _oeb: array<u32>;
@group(0) @binding(4) var<storage, read_write> _oec: array<u32>;
@group(0) @binding(5) var<storage, read_write> _oi4: array<u32>;
@group(0) @binding(6) var<uniform> _o9f: _oo;
const _og: u32 = 16u;
const _oh: u32 = 16u;
const _o2c: f32 = 1e-3;
const _o1h: f32 = 0.0009770396478266127;
const _o16: f32 = 3.929278140e-03;
const _o2g: f32 = 0.1;
const _o2d: f32 = 12.0;
const _o2e: f32 = 2.2567583;
const _o2f: f32 = 0.08945;
const _o21: f32 = 1.7724538509055159;
const _oi: f32 = 0.02;
fn _oqu(_odw: u32) -> f32 {
  return _o5o._oqp[_odw >> 2u][_odw & 3u];
}
fn _oij(_odw: u32) -> f32 {
  return _o5o._oj4[_odw >> 2u][_odw & 3u];
}
fn _oj6(_ohm: vec3f) -> vec4f {
  var _oh6: vec4f;
  for (var r = 0u; r < 4u; r = r + 1u) {
    _oh6[r] = _oau(_ohm.z, _oij(8u + r), _oau(_ohm.x, _oij(r), _ohm.y * _oij(4u + r))) + _oij(12u + r);
  }
  return _oh6;
}
fn _oqq(_ohm: vec3f) -> f32 {
  return _oau(_ohm.z, _oqu(10u), _oau(_ohm.x, _oqu(2u), _ohm.y * _oqu(6u))) + _oqu(14u);
}
fn _ogb(_oqc: f32, size: u32) -> f32 {
  let _ol9 = f32(size);
  return _oau(_oqc, _ol9, _ol9 - 1.0) * 0.5;
}
fn _ocp(x: f32, y: f32) -> f32 {
  let _o3j = abs(x);
  let _o3o = abs(y);
  let _o4j = max(_o3j, _o3o);
  let _omq = min(_o3j, _o3o);
  if (_omq == 0.0) {
    return _o4j;
  }
  return sqrt(_oau(_o4j, _o4j, _omq * _omq));
}
fn _oaj(_opr: f32) -> f32 {
  let z = _opr * _oau(_o2f, _opr * _opr, 1.0);
  return 1.0 / (1.0 + exp(-_o2e * z));
}
struct _o18 {
  _oqh: f32,
  _omo: f32,
};
fn _o9y(_oef: f32) -> _o18 {
  var _oaq: _o18;
  if (!(_oef < _o2d)) {
    _oaq._oqh = 1.0;
    _oaq._omo = 0.0;
    return _oaq;
  }
  let x = 0.5 * _oef;
  let _ol9 = _oaj(x);
  _oaq._oqh = 2.0 * _ol9 - 1.0;
  _oaq._omo = 2.0 * _o2e * _ol9 * (1.0 - _ol9) * _oau(3.0 * _o2f, x * x, 1.0);
  return _oaq;
}
fn _ond(_ojc: f32, _oej: f32, g: f32) -> f32 {
  let _oek = _oej / g;
  let _om7 = _oej < _o2g * g;
  var _oq6: f32;
  if (_om7) {
    let _obc = g * g;
    let _opj = _oej * _oej / 12.0;
    let _o8s = _obc - _opj;
    _oq6 = _obc * _obc / _o8s;
  } else if (_oek < _o2d) {
    let x = 0.5 * _oek;
    let _o7n = _oau(_o2f, x * x, 1.0);
    let _oo5 = exp(-_o2e * x * _o7n);
    _oq6 = _oej * g * (1.0 + _oo5) / (_o21 * (1.0 - _oo5));
  } else {
    _oq6 = _oej * g / _o21;
  }
  return _ojc * _oq6;
}
struct _o1f {
  r: mat3x3f,
  _ol9: vec3f,
  _oam: f32,
  _off: vec3f,
  _ofg: vec3f,
  _o5l: f32,
  _o5m: f32,
  _o5n: f32,
};
fn _oe8(_ol1: u32, _odr: vec3f, _odu: vec3f) -> _o1f {
  var _ob2: _o1f;
  let _opr = 8u * _ol1;
  let w = _oq4[_opr];
  let x = _oq4[_opr + 1u];
  let y = _oq4[_opr + 2u];
  let z = _oq4[_opr + 3u];
  _ob2.r = mat3x3f(
      vec3f(1.0 - 2.0 * (y * y + z * z), 2.0 * (x * y + w * z), 2.0 * (x * z - w * y)),
      vec3f(2.0 * (x * y - w * z), 1.0 - 2.0 * (x * x + z * z), 2.0 * (y * z + w * x)),
      vec3f(2.0 * (x * z + w * y), 2.0 * (y * z - w * x), 1.0 - 2.0 * (x * x + y * y)));
  _ob2._ol9 = vec3f(_oq4[_opr + 4u], _oq4[_opr + 5u], _oq4[_opr + 6u]);
  _ob2._oam = _oq4[_opr + 7u];
  _ob2._o5l = 0.0;
  _ob2._o5m = 0.0;
  _ob2._o5n = 0.0;
  for (var _odm = 0u; _odm < 3u; _odm = _odm + 1u) {
    let _o6z = _ob2.r[_odm];
    let _ohn = _odr.x * _o6z.x + _odr.y * _o6z.y + _odr.z * _o6z.z;
    let _oho = _odu.x * _o6z.x + _odu.y * _o6z.y + _odu.z * _o6z.z;
    _ob2._off[_odm] = _ohn * _ob2._ol9[_odm];
    _ob2._ofg[_odm] = _oho * _ob2._ol9[_odm];
    _ob2._o5l = _ob2._o5l + _ob2._off[_odm] * _ob2._off[_odm];
    _ob2._o5m = _ob2._o5m + _ob2._off[_odm] * _ob2._ofg[_odm];
    _ob2._o5n = _ob2._o5n + _ob2._ofg[_odm] * _ob2._ofg[_odm];
  }
  return _ob2;
}
struct _o1 {
  _oph: f32,
  _oke: f32,
  _ogh: f32,
  _oiq: bool,
  _ofs: f32,
  _oa2: bool,
};
fn _o3a(_ob2: _o1f, _odr: vec3f, _odu: vec3f, _okb: vec3f,
                     _oa1: f32, _oa7: f32) -> _o1 {
  var _oai: _o1;
  let _ola = _ob2._ol9.x;
  let _olb = _ob2._ol9.y;
  let _olc = _ob2._ol9.z;
  _oai._oph = 0.5 * _ola * (_olb + _olc);
  let _oh5 = vec3f(_olb * _olc, _ola * _olc, _ola * _olb);
  var _oou: vec3f;
  var _oeo = 0.0;
  for (var _odm = 0u; _odm < 3u; _odm = _odm + 1u) {
    let _o6z = _ob2.r[_odm];
    let _okc = _okb.x * _o6z.x + _okb.y * _o6z.y + _okb.z * _o6z.z;
    _oou[_odm] = _okc * _oh5[_odm];
    _oeo = _oav(_oeo, abs(_oou[_odm]));
  }
  let _odd = select(0.0, 1.0 / _oeo, _oeo > 0.0);
  var _ons = 0.0;
  for (var _odm = 0u; _odm < 3u; _odm = _odm + 1u) {
    let _olq = _oou[_odm] * _odd;
    _ons = _ons + _olq * _olq;
  }
  let _okw = sqrt(_ons);
  _oai._oke = _oeo * _okw;
  let _ogg = vec3f(_odr.y * _odu.z - _odr.z * _odu.y,
                     _odr.z * _odu.x - _odr.x * _odu.z,
                     _odr.x * _odu.y - _odr.y * _odu.x);
  _oai._ogh = sqrt(_ogg.x * _ogg.x + _ogg.y * _ogg.y + _ogg.z * _ogg.z);
  _oai._oiq = _ola > 0.0 && _olb > 0.0 && _olc > 0.0;
  _oai._ofs = 0.0;
  for (var _odm = 0u; _odm < 3u; _odm = _odm + 1u) {
    let _o9q = -_oa7 * _ob2._off[_odm] + _oa1 * _ob2._ofg[_odm];
    _oai._ofs = _oai._ofs + _o9q * _o9q;
  }
  _oai._oa2 = _oa1 == 0.0 && _oa7 == 0.0;
  return _oai;
}
fn _ona(_oai: _o1, g: f32, _o79: vec3f, _oop: vec3f,
                     _oa1: f32, _oa7: f32) -> f32 {
  let _oru = !_oai._oa2 && !(_oai._ofs > 0.0);
  let a = _oai._oph;
  let w = _oai._oke;
  let _og6 = _oai._ogh;
  var _oq2: f32;
  if (_oru) {
    _oq2 = 0.0;
  } else {
    let _okx = sqrt(_oai._ofs);
    let _oef = _okx / (g * _og6 * w);
    if (_oef < _o2g) {
      let _oeg = _oef * _oef;
      let _o7z = 1.0 - _oeg / 12.0;
      _oq2 = a * g * g * _og6 / _o7z;
    } else {
      let _oaq = _o9y(_oef);
      _oq2 = a * g * _okx / (_o21 * w * _oaq._oqh);
    }
  }
  let _onk = g * g - 1.0;
  let _o51 = _o79.x + _onk * _oop.x;
  let _o54 = _o79.y + _onk * _oop.y;
  let _o5b = _o79.z + _onk * _oop.z;
  let _o8n = _o51 * _o5b - _o54 * _o54;
  let _o31 = _o5b * _oa1 - _o54 * _oa7;
  let _o32 = _o51 * _oa7 - _o54 * _oa1;
  let _oc4 = _oa1 * _o31 + _oa7 * _o32;
  let _oc3 = select(0.0, _oc4, _oc4 > 0.0);
  let _oei = sqrt(_oc3 / _o8n);
  var _oan: f32;
  if (_oei < _o2g) {
    let _ohs = 1.0 - _oc3 / (12.0 * _o8n);
    _oan = _ohs * inverseSqrt(_o8n);
  } else {
    let _oar = _o9y(_oei);
    _oan = _o21 * _oar._oqh * inverseSqrt(_oc3);
  }
  return _oq2 * _oan;
}
struct _ow {
  _ogz: bool,
  a: vec4f,
  b: vec4f,
};
fn _o6r(_ohu: vec4f, _oi6: vec4f) -> _ow {
  var _okq: _ow;
  _okq._ogz = false;
  let _o7z = _oi6 - _ohu;
  var _oo6 = 0.0;
  var _oo7 = 1.0;
  var _o6y = array<f32, 5>(_ohu.w - _o2c, _ohu.x + _ohu.w, _ohu.w - _ohu.x,
                           _ohu.y + _ohu.w, _ohu.w - _ohu.y);
  var _o5v = array<f32, 5>(_o7z.w, _o7z.x + _o7z.w, _o7z.w - _o7z.x, _o7z.y + _o7z.w, _o7z.w - _o7z.y);
  var _o7q = false;
  var _o7o = 0.0;
  var _o7p = 1.0;
  for (var _odw = 0u; _odw < 5u; _odw = _odw + 1u) {
    if (_o5v[_odw] == 0.0) {
      if (_o6y[_odw] < 0.0) {
        _o7q = true;
        break;
      }
      continue;
    }
    let _opa = -_o6y[_odw] / _o5v[_odw];
    if (_o5v[_odw] > 0.0) {
      _o7o = _oav(_o7o, _opa);
    } else {
      _o7p = _oaw(_o7p, _opa);
    }
  }
  if (_o7q || _o7o > _o7p) {
    return _okq;
  }
  if (_o5v[0] == 0.0) {
    if (_o6y[0] < 0.0) {
      return _okq;
    }
  } else {
    let _opa = -_o6y[0] / _o5v[0];
    if (_o5v[0] > 0.0) {
      _oo6 = _oav(_oo6, _opa);
    } else {
      _oo7 = _oaw(_oo7, _opa);
    }
  }
  if (_oo6 > _oo7) {
    return _okq;
  }
  for (var _o4z = 0u; _o4z < 4u; _o4z = _o4z + 1u) {
    _okq.a[_o4z] = _oau(_o7z[_o4z], _oo6, _ohu[_o4z]);
    _okq.b[_o4z] = _oau(_o7z[_o4z], _oo7, _ohu[_o4z]);
  }
  _okq._ogz = true;
  return _okq;
}
fn _op4(a: vec2f, b: vec2f, _oht: f32, _ohr: f32, _opo: u32,
                 _orc: u32, _opm: u32, _opn: u32) -> vec3u {
  let _o8y = b - a;
  let _oes = _ocp(_o8y.x, _o8y.y);
  let _omc = _oes < 1e-4;
  let _oli = select(_o8y, vec2f(1.0, 0.0), _omc);
  let _olj = select(_oes, 1.0, _omc);
  let _opy = vec2f(-_oli.y / _olj, _oli.x / _olj);
  let _opx = vec2f(_oli.x / _olj, _oli.y / _olj);
  let _ois = _oht + _oi;
  let _ohu = _ohr + _oi;
  var _o4z: array<vec2f, 4>;
  _o4z[3] = vec2f(_oau(-_opx.x, _ohu, _oau(_opy.x, _ois, a.x)),
               _oau(-_opx.y, _ohu, _oau(_opy.y, _ois, a.y)));
  _o4z[0] = vec2f(_oau(-_opx.x, _ohu, _oau(-_opy.x, _ois, a.x)),
               _oau(-_opx.y, _ohu, _oau(-_opy.y, _ois, a.y)));
  _o4z[2] = vec2f(_oau(_opx.x, _ohu, _oau(_opy.x, _ois, b.x)),
               _oau(_opx.y, _ohu, _oau(_opy.y, _ois, b.y)));
  _o4z[1] = vec2f(_oau(_opx.x, _ohu, _oau(-_opy.x, _ois, b.x)),
               _oau(_opx.y, _ohu, _oau(-_opy.y, _ois, b.y)));
  let _orr = f32(_opo * _oh);
  let _orq = f32(_opo * _oh + (_oh - 1u));
  var _orn = 3.4e38;
  var _orl = -3.4e38;
  for (var _ocq = 0u; _ocq < 4u; _ocq = _ocq + 1u) {
    let _ohn = _o4z[_ocq];
    let _oho = _o4z[(_ocq + 1u) & 3u];
    if (_ohn.y >= _orr && _ohn.y <= _orq) {
      _orn = _oaw(_orn, _ohn.x);
      _orl = _oav(_orl, _ohn.x);
    }
    let _o9k = _oho.y - _ohn.y;
    if (_o9k != 0.0) {
      var _oo5 = (_orr - _ohn.y) / _o9k;
      if (_oo5 > 0.0 && _oo5 < 1.0) {
        let x = _oau(_oo5, _oho.x - _ohn.x, _ohn.x);
        _orn = _oaw(_orn, x);
        _orl = _oav(_orl, x);
      }
      _oo5 = (_orq - _ohn.y) / _o9k;
      if (_oo5 > 0.0 && _oo5 < 1.0) {
        let x = _oau(_oo5, _oho.x - _ohn.x, _ohn.x);
        _orn = _oaw(_orn, x);
        _orl = _oav(_orl, x);
      }
    }
  }
  if (!(_orl >= _orn)) {
    return vec3u(0u, 0u, 0u);
  }
  let _or1 = f32(_orc - 1u);
  let _oro = _oaw(_oav(_orn, 0.0), _or1);
  let _orm = _oaw(_oav(_orl, 0.0), _or1);
  let _oo1 = max(i32(_opm), i32(floor(_oro * 0.0625)));
  let _oo2 = min(i32(_opn), i32(floor(_orm * 0.0625)) + 1);
  if (_oo2 > _oo1) {
    return vec3u(u32(_oo1), u32(_oo2), 1u);
  }
  return vec3u(0u, 0u, 0u);
}
@compute @workgroup_size(256)
fn preprocess(@builtin(local_invocation_index) _oex: u32,
              @builtin(workgroup_id) _orb: vec3u,
              @builtin(num_workgroups) _ogm: vec3u) {
  let _oct = _of2(_orb, _ogm) * _o2h + _oex;
  if (_oct >= _o7l[_o1u]) {
    return;
  }
  let _omu = _oe7[_oct];
  _op6[_oct] = 0u;
  _oiy[_oct]._obj = vec4f(0.0, 0.0, 0.0, 0.0);
  let _o38 = _o39[_omu] * _oaf[_omu];
  let _ogq = 6u * _omu;
  let _ohv = vec3f(_o9w[_ogq], _o9w[_ogq + 1u], _o9w[_ogq + 2u]);
  let _oi7 = vec3f(_o9w[_ogq + 3u], _o9w[_ogq + 4u], _o9w[_ogq + 5u]);
  let _of1 = vec3f((_ohv.x + _oi7.x) * 0.5, (_ohv.y + _oi7.y) * 0.5, (_ohv.z + _oi7.z) * 0.5);
  let _o8j = _oqq(_of1);
  let _o6q = _o6r(_oj6(_ohv), _oj6(_oi7));
  if (!_o6q._ogz) {
    return;
  }
  let _orc = _o5o._orc;
  let _oce = _o5o._oce;
  let _o2u = vec2f(_ogb(_o6q.a.x / _o6q.a.w, _orc), _ogb(_o6q.a.y / _o6q.a.w, _oce));
  let _o3u = vec2f(_ogb(_o6q.b.x / _o6q.b.w, _orc), _ogb(_o6q.b.y / _o6q.b.w, _oce));
  let _o4f = _o5o._o4f;
  let _o5w = _oj6(_of1);
  var _om1 = _o5w.w > _o2c && _odj(_o5w.w);
  let _olk = select(1.0, _o5w.w, _om1);
  let _oda = 1.0 / (_olk * _olk);
  let _ocb = 0.5 * f32(_orc);
  let _oc8 = 0.5 * f32(_oce);
  let _odr = vec3f(_ocb * (_olk * _oij(0u) - _o5w.x * _oij(3u)) * _oda,
                 _ocb * (_olk * _oij(4u) - _o5w.x * _oij(7u)) * _oda,
                 _ocb * (_olk * _oij(8u) - _o5w.x * _oij(11u)) * _oda);
  let _odu = vec3f(_oc8 * (_olk * _oij(1u) - _o5w.y * _oij(3u)) * _oda,
                 _oc8 * (_olk * _oij(5u) - _o5w.y * _oij(7u)) * _oda,
                 _oc8 * (_olk * _oij(9u) - _o5w.y * _oij(11u)) * _oda);
  let _ofy = vec2f(_ogb(_o5w.x / _olk, _orc),
                           _ogb(_o5w.y / _olk, _oce));
  let _ob2 = _oe8(_omu, _odr, _odu);
  let _o5g = _ob2._o5l + _ob2._oam * _o99(_odr, _odr);
  let _o5h = _ob2._o5m + _ob2._oam * _o99(_odr, _odu);
  let _o5i = _ob2._o5n + _ob2._oam * _o99(_odu, _odu);
  let _o51 = _o5g + _o4f;
  let _o54 = _o5h;
  let _o5b = _o5i + _o4f;
  let _ok8 = _olk / _o6q.a.w;
  let _ok9 = _olk / _o6q.b.w;
  let _o8p = _o51 * _o5b - _o54 * _o54;
  _om1 = _om1 && _o8p > 0.0 && _odj(_o8p);
  let _od6 = select(0.0, 1.0 / _o8p, _om1);
  let _o66 = _o3u - _o2u;
  let _o31 = _o5b * _o66.x - _o54 * _o66.y;
  let _o32 = _o51 * _o66.y - _o54 * _o66.x;
  let _oc2 = _o66.x * _o31 + _o66.y * _o32;
  let _obz = _oav(_oc2 * _od6, 0.0);
  let _oef = sqrt(_obz);
  let _od7 = select(0.0, 1.0 / _oc2, _obz > 1e-8);
  let _oim = !(_oef > _o2g) || !(_od7 > 0.0);
  let _o5q = _o5o._o5r.xyz;
  let _oka = _of1 - _o5q;
  let _odf = inverseSqrt(_o99(_oka, _oka));
  let _okb = _oka * _odf;
  let _oai = _o3a(_ob2, _odr, _odu, _okb, _o66.x, _o66.y);
  let _o79 = vec3f(_o51, _o54, _o5b);
  let _oop = vec3f(_o5g, _o5h, _o5i);
  let _okr = _oav(_o38, 0.0);
  let _ojc = _okr * _oai._oph * _oai._ogh;
  let _oej = sqrt(_oai._ofs) / (_oai._ogh * _oai._oke);
  let _odx = _ona(_oai, _ok8, _o79, _oop, _o66.x, _o66.y);
  let _odz = _ona(_oai, 1.0, _o79, _oop, _o66.x, _o66.y);
  let _ody = _ona(_oai, _ok9, _o79, _oop, _o66.x, _o66.y);
  let _oi8 = _okr * _oav(_odx, _oav(_odz, _ody));
  let _opu = _ond(_ojc, _oej, _ok8);
  let _opw = _ond(_ojc, _oej, 1.0);
  let _opv = _ond(_ojc, _oej, _ok9);
  _om1 = _om1 && _oai._oiq && _odj(_oej)
      && _odj(_opu) && _odj(_opw) && _odj(_opv);
  if (!_om1) {
    return;
  }
  let _o5x = _ofy;
  if (_oi8 < _o1h) {
    return;
  }
  let _o7v = _oav(log(_oav(_oi8, _o16) / _o16), 1e-6);
  let _o8y = _o3u - _o2u;
  let _oes = _ocp(_o8y.x, _o8y.y);
  let _omc = _oes < 1e-4;
  let _oli = select(_o8y, vec2f(1.0, 0.0), _omc);
  let _olj = select(_oes, 1.0, _omc);
  let _opy = vec2f(-_oli.y / _olj, _oli.x / _olj);
  let _opx = vec2f(_oli.x / _olj, _oli.y / _olj);
  let _odw = sqrt(_o7v);
  let _obe = _oav(_ok8, _ok9);
  let _onl = _oav(_obe * _obe - 1.0, 0.0);
  let _o6v = _o51 + _onl * _o5g;
  let _o6w = _o54 + _onl * _o5h;
  let _o6x = _o5b + _onl * _o5i;
  let _oqj = _opy.x * (_o6v * _opy.x + _o6w * _opy.y)
               + _opy.y * (_o6w * _opy.x + _o6x * _opy.y);
  let _oqi = _opx.x * (_o6v * _opx.x + _o6w * _opx.y)
                + _opx.y * (_o6w * _opx.x + _o6x * _opx.y);
  var _oht = _odw * sqrt(_oav(_oqj, 1e-8));
  var _ohr: f32;
  if (_oim) {
    _ohr = _odw * sqrt(_oav(_oqi, 1e-8));
  } else {
    let x = _opy.x * (_o6v * _opx.x + _o6w * _opx.y)
          + _opy.y * (_o6w * _opx.x + _o6x * _opx.y);
    let _o8n = _o6v * _o6x - _o6w * _o6w;
    _ohr = _odw * sqrt(_oav(_oqi, 1e-8)
        + 2.0 * abs(x) * sqrt(_oav(_o8n, 0.0)) / _oav(_oqj, 1e-8));
  }
  let _o8t = _ocp(f32(_orc), f32(_oce));
  _oht = _oaw(_oht, _o8t);
  _ohr = _oaw(_ohr, _o8t);
  var _ojk: array<vec2f, 4>;
  _ojk[3] = vec2f(_oau(-_opx.x, _ohr, _oau(_opy.x, _oht, _o2u.x)),
                  _oau(-_opx.y, _ohr, _oau(_opy.y, _oht, _o2u.y)));
  _ojk[0] = vec2f(_oau(-_opx.x, _ohr, _oau(-_opy.x, _oht, _o2u.x)),
                  _oau(-_opx.y, _ohr, _oau(-_opy.y, _oht, _o2u.y)));
  _ojk[2] = vec2f(_oau(_opx.x, _ohr, _oau(_opy.x, _oht, _o3u.x)),
                  _oau(_opx.y, _ohr, _oau(_opy.y, _oht, _o3u.y)));
  _ojk[1] = vec2f(_oau(_opx.x, _ohr, _oau(-_opy.x, _oht, _o3u.x)),
                  _oau(_opx.y, _ohr, _oau(-_opy.y, _oht, _o3u.y)));
  var _og0 = _ojk[0].x;
  var _ofm = _ojk[0].x;
  var _og2 = _ojk[0].y;
  var _ofo = _ojk[0].y;
  var _ofh = 0.0;
  for (var _ocq = 0u; _ocq < 4u; _ocq = _ocq + 1u) {
    let _o7a = _ojk[_ocq];
    if (!_odj(_o7a.x) || !_odj(_o7a.y)) {
      return;
    }
    _og0 = _oaw(_og0, _o7a.x);
    _ofm = _oav(_ofm, _o7a.x);
    _og2 = _oaw(_og2, _o7a.y);
    _ofo = _oav(_ofo, _o7a.y);
    _ofh = _oav(_ofh, _ocp(_o7a.x - _o5x.x, _o7a.y - _o5x.y));
  }
  let _ora = f32(_orc - 1u);
  let _ocf = f32(_oce - 1u);
  let _og1 = _oaw(_oav(_og0 - _oi, 0.0), _ora);
  let _ofn = _oaw(_oav(_ofm + _oi, 0.0), _ora);
  let _og3 = _oaw(_oav(_og2 - _oi, 0.0), _ocf);
  let _ofp = _oaw(_oav(_ofo + _oi, 0.0), _ocf);
  let _obw = i32(_o5o._op7);
  let _obx = i32(_o5o._op8);
  let _opm = max(0, min(_obw, i32(floor(_og1 * 0.0625))));
  let _opp = max(0, min(_obx, i32(floor(_og3 * 0.0625))));
  let _opn = max(0, min(_obw, i32(floor(_ofn * 0.0625)) + 1));
  let _opq = max(0, min(_obx, i32(floor(_ofp * 0.0625)) + 1));
  if (_opm >= _opn || _opp >= _opq) {
    return;
  }
  let _ojz = f32(max(_orc, _oce));
  let _ofi = max(1, i32(ceil(_oaw(_ofh, _ojz))));
  var _oiw: _o1o;
  _oiw._o3b = vec4f(_o5g, _o5h, _o5i, select(_ok8, -abs(_ok8), _oim));
  _oiw._o4m = vec4f(_ojc, _oej, _o7v, _ok9);
  _oiw.ab = vec4f(_o2u, _o3u);
  _oiw._obj = vec4f(_oht, _ohr, _o8j, f32(_ofi));
  _oiw._okl = vec4u(u32(_opm), u32(_opp), u32(_opn), u32(_opq));
  _oiy[_oct] = _oiw;
  var _og9 = 0u;
  for (var _opo = u32(_opp); _opo < u32(_opq); _opo = _opo + 1u) {
    let _omx = _op4(_o2u, _o3u, _oht, _ohr, _opo, _orc, u32(_opm), u32(_opn));
    if (_omx.z != 0u) {
      _og9 = _og9 + (_omx.y - _omx.x);
    }
  }
  _op6[_oct] = _og9;
}
fn _o99(x: vec3f, y: vec3f) -> f32 {
  return x.x * y.x + x.y * y.y + x.z * y.z;
}
@compute @workgroup_size(256)
fn duplicate_keys(@builtin(local_invocation_index) _oex: u32,
                  @builtin(workgroup_id) _orb: vec3u,
                  @builtin(num_workgroups) _ogm: vec3u) {
  let _oct = _of2(_orb, _ogm) * _o2h + _oex;
  if (_oct >= _o9g[_o1u]) {
    return;
  }
  let _oiw = _o9i[_oct];
  if (!(_oiw._obj.w > 0.0)) {
    return;
  }
  var off = 0u;
  if (_oct > 0u) {
    off = _o9h[_oct - 1u];
  }
  let _o2u = _oiw.ab.xy;
  let _o3u = _oiw.ab.zw;
  let _o8k = bitcast<u32>(_oiw._obj.z);
  let _o5t = _o9f._o5t;
  for (var y = _oiw._okl.y; y < _oiw._okl.w; y = y + 1u) {
    let _omx = _op4(_o2u, _o3u, _oiw._obj.x, _oiw._obj.y, y,
                             _o9f._orc, _oiw._okl.x, _oiw._okl.z);
    if (_omx.z == 0u) {
      continue;
    }
    for (var x = _omx.x; x < _omx.y; x = x + 1u) {
      if (off < _o5t) {
        _oeb[off] = y * _o9f._op7 + x;
        _oec[off] = _o8k;
        _oi4[off] = _oct;
      }
      off = off + 1u;
    }
  }
}
