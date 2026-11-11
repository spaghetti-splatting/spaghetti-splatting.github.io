struct _o1x {
  _o3p: vec4f,
  _o52: vec4f,
  ab: vec4f,
  _ocw: vec4f,
  _omg: vec4u,
};
@group(0) @binding(0) var<storage, read> _ofq: array<u32>;
@group(0) @binding(1) var<storage, read> _oau: array<f32>;
@group(0) @binding(2) var<storage, read> _os9: array<f32>;
@group(0) @binding(3) var<storage, read> _o3l: array<f32>;
@group(0) @binding(4) var<storage, read> _obd: array<f32>;
@group(0) @binding(5) var<storage, read> _o8h: array<u32>;
@group(0) @binding(6) var<storage, read_write> _oko: array<_o1x>;
@group(0) @binding(7) var<storage, read_write> _ora: array<u32>;
@group(0) @binding(8) var<uniform> _o69: _oo;
@group(0) @binding(0) var<storage, read> _oaf: array<_o1x>;
@group(0) @binding(1) var<storage, read> _oae: array<u32>;
@group(0) @binding(2) var<storage, read> _oad: array<u32>;
@group(0) @binding(3) var<storage, read_write> _ofu: array<u32>;
@group(0) @binding(4) var<storage, read_write> _ofv: array<u32>;
@group(0) @binding(5) var<storage, read_write> _ojt: array<u32>;
@group(0) @binding(6) var<uniform> _oac: _oo;
const _og: u32 = 16u;
const _oh: u32 = 16u;
const _o2l: f32 = 1e-3;
const _o1p: f32 = 0.0009770396478266127;
const _o18: f32 = 3.929278140e-03;
const _o2p: f32 = 0.1;
const _o2m: f32 = 12.0;
const _o2n: f32 = 2.2567583;
const _o2o: f32 = 0.08945;
const _o2a: f32 = 1.7724538509055159;
const _oi: f32 = 0.02;
fn _osz(_ofd: u32) -> f32 {
  return _o69._osu[_ofd >> 2u][_ofd & 3u];
}
fn _ok9(_ofd: u32) -> f32 {
  return _o69._oku[_ofd >> 2u][_ofd & 3u];
}
fn _okw(_ojb: vec3f) -> vec4f {
  var _oiv: vec4f;
  for (var r = 0u; r < 4u; r = r + 1u) {
    _oiv[r] = _obt(_ojb.z, _ok9(8u + r), _obt(_ojb.x, _ok9(r), _ojb.y * _ok9(4u + r))) + _ok9(12u + r);
  }
  return _oiv;
}
fn _osv(_ojb: vec3f) -> f32 {
  return _obt(_ojb.z, _osz(10u), _obt(_ojb.x, _osz(2u), _ojb.y * _osz(6u))) + _osz(14u);
}
fn _oi0(_osh: f32, size: u32) -> f32 {
  let _on4 = f32(size);
  return _obt(_osh, _on4, _on4 - 1.0) * 0.5;
}
fn _oe6(x: f32, y: f32) -> f32 {
  let _o3y = abs(x);
  let _o43 = abs(y);
  let _o4z = max(_o3y, _o43);
  let _ooo = min(_o3y, _o43);
  if (_ooo == 0.0) {
    return _o4z;
  }
  return sqrt(_obt(_o4z, _o4z, _ooo * _ooo));
}
fn _obh(_orw: f32) -> f32 {
  let z = _orw * _obt(_o2o, _orw * _orw, 1.0);
  return 1.0 / (1.0 + exp(-_o2n * z));
}
struct _o1a {
  _osm: f32,
  _oom: f32,
};
fn _oaw(_og1: f32) -> _o1a {
  var _obo: _o1a;
  if (!(_og1 < _o2m)) {
    _obo._osm = 1.0;
    _obo._oom = 0.0;
    return _obo;
  }
  let x = 0.5 * _og1;
  let _on4 = _obh(x);
  _obo._osm = 2.0 * _on4 - 1.0;
  _obo._oom = 2.0 * _o2n * _on4 * (1.0 - _on4) * _obt(3.0 * _o2o, x * x, 1.0);
  return _obo;
}
fn _opc(_ol2: f32, _og5: f32, g: f32) -> f32 {
  let _og6 = _og5 / g;
  let _oo3 = _og5 < _o2p * g;
  var _osb: f32;
  if (_oo3) {
    let _oco = g * g;
    let _oro = _og5 * _og5 / 12.0;
    let _o9o = _oco - _oro;
    _osb = _oco * _oco / _o9o;
  } else if (_og6 < _o2m) {
    let x = 0.5 * _og6;
    let _o8j = _obt(_o2o, x * x, 1.0);
    let _oq8 = exp(-_o2n * x * _o8j);
    _osb = _og5 * g * (1.0 + _oq8) / (_o2a * (1.0 - _oq8));
  } else {
    _osb = _og5 * g / _o2a;
  }
  return _ol2 * _osb;
}
struct _o1m {
  r: mat3x3f,
  _on4: vec3f,
  _obk: f32,
  _oh2: vec3f,
  _oh3: vec3f,
  _o65: f32,
  _o66: f32,
  _o67: f32,
};
fn _ofr(_omw: u32, _of8: vec3f, _ofb: vec3f) -> _o1m {
  var _oc3: _o1m;
  let _orw = 8u * _omw;
  let w = _os9[_orw];
  let x = _os9[_orw + 1u];
  let y = _os9[_orw + 2u];
  let z = _os9[_orw + 3u];
  _oc3.r = mat3x3f(
      vec3f(1.0 - 2.0 * (y * y + z * z), 2.0 * (x * y + w * z), 2.0 * (x * z - w * y)),
      vec3f(2.0 * (x * y - w * z), 1.0 - 2.0 * (x * x + z * z), 2.0 * (y * z + w * x)),
      vec3f(2.0 * (x * z + w * y), 2.0 * (y * z - w * x), 1.0 - 2.0 * (x * x + y * y)));
  _oc3._on4 = vec3f(_os9[_orw + 4u], _os9[_orw + 5u], _os9[_orw + 6u]);
  _oc3._obk = _os9[_orw + 7u];
  _oc3._o65 = 0.0;
  _oc3._o66 = 0.0;
  _oc3._o67 = 0.0;
  for (var _of3 = 0u; _of3 < 3u; _of3 = _of3 + 1u) {
    let _o7v = _oc3.r[_of3];
    let _ojc = _of8.x * _o7v.x + _of8.y * _o7v.y + _of8.z * _o7v.z;
    let _ojd = _ofb.x * _o7v.x + _ofb.y * _o7v.y + _ofb.z * _o7v.z;
    _oc3._oh2[_of3] = _ojc * _oc3._on4[_of3];
    _oc3._oh3[_of3] = _ojd * _oc3._on4[_of3];
    _oc3._o65 = _oc3._o65 + _oc3._oh2[_of3] * _oc3._oh2[_of3];
    _oc3._o66 = _oc3._o66 + _oc3._oh2[_of3] * _oc3._oh3[_of3];
    _oc3._o67 = _oc3._o67 + _oc3._oh3[_of3] * _oc3._oh3[_of3];
  }
  return _oc3;
}
struct _o1 {
  _orm: f32,
  _om8: f32,
  _oi6: f32,
  _okg: bool,
  _ohg: f32,
  _ob0: bool,
};
fn _o3m(_oc3: _o1m, _of8: vec3f, _ofb: vec3f, _om5: vec3f,
                     _oaz: f32, _ob5: f32) -> _o1 {
  var _obg: _o1;
  let _on5 = _oc3._on4.x;
  let _on6 = _oc3._on4.y;
  let _on7 = _oc3._on4.z;
  _obg._orm = 0.5 * _on5 * (_on6 + _on7);
  let _oiu = vec3f(_on6 * _on7, _on5 * _on7, _on5 * _on6);
  var _oqx: vec3f;
  var _oga = 0.0;
  for (var _of3 = 0u; _of3 < 3u; _of3 = _of3 + 1u) {
    let _o7v = _oc3.r[_of3];
    let _om6 = _om5.x * _o7v.x + _om5.y * _o7v.y + _om5.z * _o7v.z;
    _oqx[_of3] = _om6 * _oiu[_of3];
    _oga = _obu(_oga, abs(_oqx[_of3]));
  }
  let _oeu = select(0.0, 1.0 / _oga, _oga > 0.0);
  var _opv = 0.0;
  for (var _of3 = 0u; _of3 < 3u; _of3 = _of3 + 1u) {
    let _onm = _oqx[_of3] * _oeu;
    _opv = _opv + _onm * _onm;
  }
  let _omr = sqrt(_opv);
  _obg._om8 = _oga * _omr;
  let _oi5 = vec3f(_of8.y * _ofb.z - _of8.z * _ofb.y,
                     _of8.z * _ofb.x - _of8.x * _ofb.z,
                     _of8.x * _ofb.y - _of8.y * _ofb.x);
  _obg._oi6 = sqrt(_oi5.x * _oi5.x + _oi5.y * _oi5.y + _oi5.z * _oi5.z);
  _obg._okg = _on5 > 0.0 && _on6 > 0.0 && _on7 > 0.0;
  _obg._ohg = 0.0;
  for (var _of3 = 0u; _of3 < 3u; _of3 = _of3 + 1u) {
    let _oan = -_ob5 * _oc3._oh2[_of3] + _oaz * _oc3._oh3[_of3];
    _obg._ohg = _obg._ohg + _oan * _oan;
  }
  _obg._ob0 = _oaz == 0.0 && _ob5 == 0.0;
  return _obg;
}
fn _op9(_obg: _o1, g: f32, _o85: vec3f, _oqs: vec3f,
                     _oaz: f32, _ob5: f32) -> f32 {
  let _ou1 = !_obg._ob0 && !(_obg._ohg > 0.0);
  let a = _obg._orm;
  let w = _obg._om8;
  let _ohv = _obg._oi6;
  var _os7: f32;
  if (_ou1) {
    _os7 = 0.0;
  } else {
    let _oms = sqrt(_obg._ohg);
    let _og1 = _oms / (g * _ohv * w);
    if (_og1 < _o2p) {
      let _og2 = _og1 * _og1;
      let _o8v = 1.0 - _og2 / 12.0;
      _os7 = a * g * g * _ohv / _o8v;
    } else {
      let _obo = _oaw(_og1);
      _os7 = a * g * _oms / (_o2a * w * _obo._osm);
    }
  }
  let _opm = g * g - 1.0;
  let _o5l = _o85.x + _opm * _oqs.x;
  let _o5o = _o85.y + _opm * _oqs.y;
  let _o5v = _o85.z + _opm * _oqs.z;
  let _o9j = _o5l * _o5v - _o5o * _o5o;
  let _o3a = _o5v * _oaz - _o5o * _ob5;
  let _o3b = _o5l * _ob5 - _o5o * _oaz;
  let _odi = _oaz * _o3a + _ob5 * _o3b;
  let _odh = select(0.0, _odi, _odi > 0.0);
  let _og4 = sqrt(_odh / _o9j);
  var _obl: f32;
  if (_og4 < _o2p) {
    let _ojh = 1.0 - _odh / (12.0 * _o9j);
    _obl = _ojh * inverseSqrt(_o9j);
  } else {
    let _obp = _oaw(_og4);
    _obl = _o2a * _obp._osm * inverseSqrt(_odh);
  }
  return _os7 * _obl;
}
struct _oy {
  _oio: bool,
  a: vec4f,
  b: vec4f,
};
fn _o7n(_ojj: vec4f, _ojv: vec4f) -> _oy {
  var _oml: _oy;
  _oml._oio = false;
  let _o8v = _ojv - _ojj;
  var _oq9 = 0.0;
  var _oqa = 1.0;
  var _o7u = array<f32, 5>(_ojj.w - _o2l, _ojj.x + _ojj.w, _ojj.w - _ojj.x,
                           _ojj.y + _ojj.w, _ojj.w - _ojj.y);
  var _o6g = array<f32, 5>(_o8v.w, _o8v.x + _o8v.w, _o8v.w - _o8v.x, _o8v.y + _o8v.w, _o8v.w - _o8v.y);
  var _o8m = false;
  var _o8k = 0.0;
  var _o8l = 1.0;
  for (var _ofd = 0u; _ofd < 5u; _ofd = _ofd + 1u) {
    if (_o6g[_ofd] == 0.0) {
      if (_o7u[_ofd] < 0.0) {
        _o8m = true;
        break;
      }
      continue;
    }
    let _orf = -_o7u[_ofd] / _o6g[_ofd];
    if (_o6g[_ofd] > 0.0) {
      _o8k = _obu(_o8k, _orf);
    } else {
      _o8l = _obv(_o8l, _orf);
    }
  }
  if (_o8m || _o8k > _o8l) {
    return _oml;
  }
  if (_o6g[0] == 0.0) {
    if (_o7u[0] < 0.0) {
      return _oml;
    }
  } else {
    let _orf = -_o7u[0] / _o6g[0];
    if (_o6g[0] > 0.0) {
      _oq9 = _obu(_oq9, _orf);
    } else {
      _oqa = _obv(_oqa, _orf);
    }
  }
  if (_oq9 > _oqa) {
    return _oml;
  }
  for (var _o5j = 0u; _o5j < 4u; _o5j = _o5j + 1u) {
    _oml.a[_o5j] = _obt(_o8v[_o5j], _oq9, _ojj[_o5j]);
    _oml.b[_o5j] = _obt(_o8v[_o5j], _oqa, _ojj[_o5j]);
  }
  _oml._oio = true;
  return _oml;
}
fn _or8(a: vec2f, b: vec2f, _oji: f32, _ojg: f32, _ort: u32,
                 _oth: u32, _orr: u32, _ors: u32) -> vec3u {
  let _o9u = b - a;
  let _oge = _oe6(_o9u.x, _o9u.y);
  let _oo8 = _oge < 1e-4;
  let _ond = select(_o9u, vec2f(1.0, 0.0), _oo8);
  let _one = select(_oge, 1.0, _oo8);
  let _os3 = vec2f(-_ond.y / _one, _ond.x / _one);
  let _os2 = vec2f(_ond.x / _one, _ond.y / _one);
  let _oki = _oji + _oi;
  let _ojj = _ojg + _oi;
  var _o5j: array<vec2f, 4>;
  _o5j[3] = vec2f(_obt(-_os2.x, _ojj, _obt(_os3.x, _oki, a.x)),
               _obt(-_os2.y, _ojj, _obt(_os3.y, _oki, a.y)));
  _o5j[0] = vec2f(_obt(-_os2.x, _ojj, _obt(-_os3.x, _oki, a.x)),
               _obt(-_os2.y, _ojj, _obt(-_os3.y, _oki, a.y)));
  _o5j[2] = vec2f(_obt(_os2.x, _ojj, _obt(_os3.x, _oki, b.x)),
               _obt(_os2.y, _ojj, _obt(_os3.y, _oki, b.y)));
  _o5j[1] = vec2f(_obt(_os2.x, _ojj, _obt(-_os3.x, _oki, b.x)),
               _obt(_os2.y, _ojj, _obt(-_os3.y, _oki, b.y)));
  let _otx = f32(_ort * _oh);
  let _otw = f32(_ort * _oh + (_oh - 1u));
  var _ott = 3.4e38;
  var _otr = -3.4e38;
  for (var _oe7 = 0u; _oe7 < 4u; _oe7 = _oe7 + 1u) {
    let _ojc = _o5j[_oe7];
    let _ojd = _o5j[(_oe7 + 1u) & 3u];
    if (_ojc.y >= _otx && _ojc.y <= _otw) {
      _ott = _obv(_ott, _ojc.x);
      _otr = _obu(_otr, _ojc.x);
    }
    let _oah = _ojd.y - _ojc.y;
    if (_oah != 0.0) {
      var _oq8 = (_otx - _ojc.y) / _oah;
      if (_oq8 > 0.0 && _oq8 < 1.0) {
        let x = _obt(_oq8, _ojd.x - _ojc.x, _ojc.x);
        _ott = _obv(_ott, x);
        _otr = _obu(_otr, x);
      }
      _oq8 = (_otw - _ojc.y) / _oah;
      if (_oq8 > 0.0 && _oq8 < 1.0) {
        let x = _obt(_oq8, _ojd.x - _ojc.x, _ojc.x);
        _ott = _obv(_ott, x);
        _otr = _obu(_otr, x);
      }
    }
  }
  if (!(_otr >= _ott)) {
    return vec3u(0u, 0u, 0u);
  }
  let _ot6 = f32(_oth - 1u);
  let _otu = _obv(_obu(_ott, 0.0), _ot6);
  let _ots = _obv(_obu(_otr, 0.0), _ot6);
  let _oq4 = max(i32(_orr), i32(floor(_otu * 0.0625)));
  let _oq5 = min(i32(_ors), i32(floor(_ots * 0.0625)) + 1);
  if (_oq5 > _oq4) {
    return vec3u(u32(_oq4), u32(_oq5), 1u);
  }
  return vec3u(0u, 0u, 0u);
}
@compute @workgroup_size(256)
fn preprocess(@builtin(local_invocation_index) _ogj: u32,
              @builtin(workgroup_id) _otg: vec3u,
              @builtin(num_workgroups) _oib: vec3u) {
  let _oea = _ogo(_otg, _oib) * _o2q + _ogj;
  if (_oea >= _o8h[_o23]) {
    return;
  }
  let _oos = _ofq[_oea];
  _ora[_oea] = 0u;
  _oko[_oea]._ocw = vec4f(0.0, 0.0, 0.0, 0.0);
  let _o3k = _o3l[_oos] * _obd[_oos];
  let _oif = 6u * _oos;
  let _ojk = vec3f(_oau[_oif], _oau[_oif + 1u], _oau[_oif + 2u]);
  let _ojw = vec3f(_oau[_oif + 3u], _oau[_oif + 4u], _oau[_oif + 5u]);
  let _ogn = vec3f((_ojk.x + _ojw.x) * 0.5, (_ojk.y + _ojw.y) * 0.5, (_ojk.z + _ojw.z) * 0.5);
  let _o9f = _osv(_ogn);
  let _o7m = _o7n(_okw(_ojk), _okw(_ojw));
  if (!_o7m._oio) {
    return;
  }
  let _oth = _o69._oth;
  let _odt = _o69._odt;
  let _o33 = vec2f(_oi0(_o7m.a.x / _o7m.a.w, _oth), _oi0(_o7m.a.y / _o7m.a.w, _odt));
  let _o49 = vec2f(_oi0(_o7m.b.x / _o7m.b.w, _oth), _oi0(_o7m.b.y / _o7m.b.w, _odt));
  let _o4v = _o69._o4v;
  let _o6h = _okw(_ogn);
  var _onx = _o6h.w > _o2l && _of0(_o6h.w);
  let _onf = select(1.0, _o6h.w, _onx);
  let _oer = 1.0 / (_onf * _onf);
  let _odq = 0.5 * f32(_oth);
  let _odn = 0.5 * f32(_odt);
  let _of8 = vec3f(_odq * (_onf * _ok9(0u) - _o6h.x * _ok9(3u)) * _oer,
                 _odq * (_onf * _ok9(4u) - _o6h.x * _ok9(7u)) * _oer,
                 _odq * (_onf * _ok9(8u) - _o6h.x * _ok9(11u)) * _oer);
  let _ofb = vec3f(_odn * (_onf * _ok9(1u) - _o6h.y * _ok9(3u)) * _oer,
                 _odn * (_onf * _ok9(5u) - _o6h.y * _ok9(7u)) * _oer,
                 _odn * (_onf * _ok9(9u) - _o6h.y * _ok9(11u)) * _oer);
  let _ohm = vec2f(_oi0(_o6h.x / _onf, _oth),
                           _oi0(_o6h.y / _onf, _odt));
  let _oc3 = _ofr(_oos, _of8, _ofb);
  let _o60 = _oc3._o65 + _oc3._obk * _oa5(_of8, _of8);
  let _o61 = _oc3._o66 + _oc3._obk * _oa5(_of8, _ofb);
  let _o62 = _oc3._o67 + _oc3._obk * _oa5(_ofb, _ofb);
  let _o5l = _o60 + _o4v;
  let _o5o = _o61;
  let _o5v = _o62 + _o4v;
  let _om2 = _onf / _o7m.a.w;
  let _om3 = _onf / _o7m.b.w;
  let _o9l = _o5l * _o5v - _o5o * _o5o;
  _onx = _onx && _o9l > 0.0 && _of0(_o9l);
  let _oen = select(0.0, 1.0 / _o9l, _onx);
  let _o6r = _o49 - _o33;
  let _o3a = _o5v * _o6r.x - _o5o * _o6r.y;
  let _o3b = _o5l * _o6r.y - _o5o * _o6r.x;
  let _odg = _o6r.x * _o3a + _o6r.y * _o3b;
  let _odd = _obu(_odg * _oen, 0.0);
  let _og1 = sqrt(_odd);
  let _oeo = select(0.0, 1.0 / _odg, _odd > 1e-8);
  let _okc = !(_og1 > _o2p) || !(_oeo > 0.0);
  let _o6b = _o69._o6c.xyz;
  let _om4 = _ogn - _o6b;
  let _oew = inverseSqrt(_oa5(_om4, _om4));
  let _om5 = _om4 * _oew;
  let _obg = _o3m(_oc3, _of8, _ofb, _om5, _o6r.x, _o6r.y);
  let _o85 = vec3f(_o5l, _o5o, _o5v);
  let _oqs = vec3f(_o60, _o61, _o62);
  let _omm = _obu(_o3k, 0.0);
  let _ol2 = _omm * _obg._orm * _obg._oi6;
  let _og5 = sqrt(_obg._ohg) / (_obg._oi6 * _obg._om8);
  let _ofg = _op9(_obg, _om2, _o85, _oqs, _o6r.x, _o6r.y);
  let _ofi = _op9(_obg, 1.0, _o85, _oqs, _o6r.x, _o6r.y);
  let _ofh = _op9(_obg, _om3, _o85, _oqs, _o6r.x, _o6r.y);
  let _ojx = _omm * _obu(_ofg, _obu(_ofi, _ofh));
  let _orz = _opc(_ol2, _og5, _om2);
  let _os1 = _opc(_ol2, _og5, 1.0);
  let _os0 = _opc(_ol2, _og5, _om3);
  _onx = _onx && _obg._okg && _of0(_og5)
      && _of0(_orz) && _of0(_os1) && _of0(_os0);
  if (!_onx) {
    return;
  }
  let _o6i = _ohm;
  if (_ojx < _o1p) {
    return;
  }
  let _o8r = _obu(log(_obu(_ojx, _o18) / _o18), 1e-6);
  let _o9u = _o49 - _o33;
  let _oge = _oe6(_o9u.x, _o9u.y);
  let _oo8 = _oge < 1e-4;
  let _ond = select(_o9u, vec2f(1.0, 0.0), _oo8);
  let _one = select(_oge, 1.0, _oo8);
  let _os3 = vec2f(-_ond.y / _one, _ond.x / _one);
  let _os2 = vec2f(_ond.x / _one, _ond.y / _one);
  let _ofd = sqrt(_o8r);
  let _ocq = _obu(_om2, _om3);
  let _opn = _obu(_ocq * _ocq - 1.0, 0.0);
  let _o7r = _o5l + _opn * _o60;
  let _o7s = _o5o + _opn * _o61;
  let _o7t = _o5v + _opn * _o62;
  let _oso = _os3.x * (_o7r * _os3.x + _o7s * _os3.y)
               + _os3.y * (_o7s * _os3.x + _o7t * _os3.y);
  let _osn = _os2.x * (_o7r * _os2.x + _o7s * _os2.y)
                + _os2.y * (_o7s * _os2.x + _o7t * _os2.y);
  var _oji = _ofd * sqrt(_obu(_oso, 1e-8));
  var _ojg: f32;
  if (_okc) {
    _ojg = _ofd * sqrt(_obu(_osn, 1e-8));
  } else {
    let x = _os3.x * (_o7r * _os2.x + _o7s * _os2.y)
          + _os3.y * (_o7s * _os2.x + _o7t * _os2.y);
    let _o9j = _o7r * _o7t - _o7s * _o7s;
    _ojg = _ofd * sqrt(_obu(_osn, 1e-8)
        + 2.0 * abs(x) * sqrt(_obu(_o9j, 0.0)) / _obu(_oso, 1e-8));
  }
  let _o9p = _oe6(f32(_oth), f32(_odt));
  _oji = _obv(_oji, _o9p);
  _ojg = _obv(_ojg, _o9p);
  var _old: array<vec2f, 4>;
  _old[3] = vec2f(_obt(-_os2.x, _ojg, _obt(_os3.x, _oji, _o33.x)),
                  _obt(-_os2.y, _ojg, _obt(_os3.y, _oji, _o33.y)));
  _old[0] = vec2f(_obt(-_os2.x, _ojg, _obt(-_os3.x, _oji, _o33.x)),
                  _obt(-_os2.y, _ojg, _obt(-_os3.y, _oji, _o33.y)));
  _old[2] = vec2f(_obt(_os2.x, _ojg, _obt(_os3.x, _oji, _o49.x)),
                  _obt(_os2.y, _ojg, _obt(_os3.y, _oji, _o49.y)));
  _old[1] = vec2f(_obt(_os2.x, _ojg, _obt(-_os3.x, _oji, _o49.x)),
                  _obt(_os2.y, _ojg, _obt(-_os3.y, _oji, _o49.y)));
  var _ohp = _old[0].x;
  var _oha = _old[0].x;
  var _ohr = _old[0].y;
  var _ohc = _old[0].y;
  var _oh4 = 0.0;
  for (var _oe7 = 0u; _oe7 < 4u; _oe7 = _oe7 + 1u) {
    let _o86 = _old[_oe7];
    if (!_of0(_o86.x) || !_of0(_o86.y)) {
      return;
    }
    _ohp = _obv(_ohp, _o86.x);
    _oha = _obu(_oha, _o86.x);
    _ohr = _obv(_ohr, _o86.y);
    _ohc = _obu(_ohc, _o86.y);
    _oh4 = _obu(_oh4, _oe6(_o86.x - _o6i.x, _o86.y - _o6i.y));
  }
  let _otf = f32(_oth - 1u);
  let _odv = f32(_odt - 1u);
  let _ohq = _obv(_obu(_ohp - _oi, 0.0), _otf);
  let _ohb = _obv(_obu(_oha + _oi, 0.0), _otf);
  let _ohs = _obv(_obu(_ohr - _oi, 0.0), _odv);
  let _ohd = _obv(_obu(_ohc + _oi, 0.0), _odv);
  let _oda = i32(_o69._orb);
  let _odb = i32(_o69._orc);
  let _orr = max(0, min(_oda, i32(floor(_ohq * 0.0625))));
  let _oru = max(0, min(_odb, i32(floor(_ohs * 0.0625))));
  let _ors = max(0, min(_oda, i32(floor(_ohb * 0.0625)) + 1));
  let _orv = max(0, min(_odb, i32(floor(_ohd * 0.0625)) + 1));
  if (_orr >= _ors || _oru >= _orv) {
    return;
  }
  let _olt = f32(max(_oth, _odt));
  let _oh5 = max(1, i32(ceil(_obv(_oh4, _olt))));
  var _okm: _o1x;
  _okm._o3p = vec4f(_o60, _o61, _o62, select(_om2, -abs(_om2), _okc));
  _okm._o52 = vec4f(_ol2, _og5, _o8r, _om3);
  _okm.ab = vec4f(_o33, _o49);
  _okm._ocw = vec4f(_oji, _ojg, _o9f, f32(_oh5));
  _okm._omg = vec4u(u32(_orr), u32(_oru), u32(_ors), u32(_orv));
  _oko[_oea] = _okm;
  var _ohy = 0u;
  for (var _ort = u32(_oru); _ort < u32(_orv); _ort = _ort + 1u) {
    let _oov = _or8(_o33, _o49, _oji, _ojg, _ort, _oth, u32(_orr), u32(_ors));
    if (_oov.z != 0u) {
      _ohy = _ohy + (_oov.y - _oov.x);
    }
  }
  _ora[_oea] = _ohy;
}
fn _oa5(x: vec3f, y: vec3f) -> f32 {
  return x.x * y.x + x.y * y.y + x.z * y.z;
}
@compute @workgroup_size(256)
fn duplicate_keys(@builtin(local_invocation_index) _ogj: u32,
                  @builtin(workgroup_id) _otg: vec3u,
                  @builtin(num_workgroups) _oib: vec3u) {
  let _oea = _ogo(_otg, _oib) * _o2q + _ogj;
  if (_oea >= _oad[_o23]) {
    return;
  }
  let _okm = _oaf[_oea];
  if (!(_okm._ocw.w > 0.0)) {
    return;
  }
  var off = 0u;
  if (_oea > 0u) {
    off = _oae[_oea - 1u];
  }
  let _o33 = _okm.ab.xy;
  let _o49 = _okm.ab.zw;
  let _o9g = bitcast<u32>(_okm._ocw.z);
  let _o6e = _oac._o6e;
  for (var y = _okm._omg.y; y < _okm._omg.w; y = y + 1u) {
    let _oov = _or8(_o33, _o49, _okm._ocw.x, _okm._ocw.y, y,
                             _oac._oth, _okm._omg.x, _okm._omg.z);
    if (_oov.z == 0u) {
      continue;
    }
    for (var x = _oov.x; x < _oov.y; x = x + 1u) {
      if (off < _o6e) {
        _ofu[off] = y * _oac._orb + x;
        _ofv[off] = _o9g;
        _ojt[off] = _oea;
      }
      off = off + 1u;
    }
  }
}
