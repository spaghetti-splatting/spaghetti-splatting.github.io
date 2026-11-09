struct _o1u {
  _o3i: vec4f,
  _o4u: vec4f,
  ab: vec4f,
  _obz: vec4f,
  _ol9: vec4u,
};
@group(0) @binding(0) var<storage, read> _oeo: array<u32>;
@group(0) @binding(1) var<storage, read> _oa9: array<f32>;
@group(0) @binding(2) var<storage, read> _oqt: array<f32>;
@group(0) @binding(3) var<storage, read> _o3g: array<f32>;
@group(0) @binding(4) var<storage, read> _oau: array<f32>;
@group(0) @binding(5) var<storage, read> _o7r: array<u32>;
@group(0) @binding(6) var<storage, read_write> _ojm: array<_o1u>;
@group(0) @binding(7) var<storage, read_write> _opv: array<u32>;
@group(0) @binding(8) var<uniform> _o5x: _oo;
@group(0) @binding(0) var<storage, read> _o9v: array<_o1u>;
@group(0) @binding(1) var<storage, read> _o9u: array<u32>;
@group(0) @binding(2) var<storage, read> _o9t: array<u32>;
@group(0) @binding(3) var<storage, read_write> _oes: array<u32>;
@group(0) @binding(4) var<storage, read_write> _oet: array<u32>;
@group(0) @binding(5) var<storage, read_write> _oim: array<u32>;
@group(0) @binding(6) var<uniform> _o9s: _oo;
const _oh: u32 = 16u;
const _oi: u32 = 16u;
const _o2j: f32 = 1e-3;
const _o1k: f32 = 0.0009770396478266127;
const _o14: f32 = 3.929278140e-03;
const _o2n: f32 = 0.1;
const _o2k: f32 = 12.0;
const _o2l: f32 = 2.2567583;
const _o2m: f32 = 0.08945;
const _o28: f32 = 1.7724538509055159;
const _oj: f32 = 0.02;
fn _orm(_oed: u32) -> f32 {
  return _o5x._orh[_oed >> 2u][_oed & 3u];
}
fn _oj2(_oed: u32) -> f32 {
  return _o5x._ojs[_oed >> 2u][_oed & 3u];
}
fn _oju(_oi3: vec3f) -> vec4f {
  var _ohn: vec4f;
  for (var r = 0u; r < 4u; r = r + 1u) {
    _ohn[r] = _obc(_oi3.z, _oj2(8u + r), _obc(_oi3.x, _oj2(r), _oi3.y * _oj2(4u + r))) + _oj2(12u + r);
  }
  return _ohn;
}
fn _ori(_oi3: vec3f) -> f32 {
  return _obc(_oi3.z, _orm(10u), _obc(_oi3.x, _orm(2u), _oi3.y * _orm(6u))) + _orm(14u);
}
fn _ogu(_or2: f32, size: u32) -> f32 {
  let _olx = f32(size);
  return _obc(_or2, _olx, _olx - 1.0) * 0.5;
}
fn _od6(x: f32, y: f32) -> f32 {
  let _o3r = abs(x);
  let _o3x = abs(y);
  let _o4r = max(_o3r, _o3x);
  let _one = min(_o3r, _o3x);
  if (_one == 0.0) {
    return _o4r;
  }
  return sqrt(_obc(_o4r, _o4r, _one * _one));
}
fn _oax(_oqg: f32) -> f32 {
  let z = _oqg * _obc(_o2m, _oqg * _oqg, 1.0);
  return 1.0 / (1.0 + exp(-_o2l * z));
}
struct _o16 {
  _or7: f32,
  _onc: f32,
};
fn _oad(_oex: f32) -> _o16 {
  var _ob7: _o16;
  if (!(_oex < _o2k)) {
    _ob7._or7 = 1.0;
    _ob7._onc = 0.0;
    return _ob7;
  }
  let x = 0.5 * _oex;
  let _olx = _oax(x);
  _ob7._or7 = 2.0 * _olx - 1.0;
  _ob7._onc = 2.0 * _o2l * _olx * (1.0 - _olx) * _obc(3.0 * _o2m, x * x, 1.0);
  return _ob7;
}
fn _oo3(_ojz: f32, _of1: f32, g: f32) -> f32 {
  let _of2 = _of1 / g;
  let _omv = _of1 < _o2n * g;
  var _oqv: f32;
  if (_omv) {
    let _obs = g * g;
    let _oq8 = _of1 * _of1 / 12.0;
    let _o94 = _obs - _oq8;
    _oqv = _obs * _obs / _o94;
  } else if (_of2 < _o2k) {
    let x = 0.5 * _of2;
    let _o7u = _obc(_o2m, x * x, 1.0);
    let _oou = exp(-_o2l * x * _o7u);
    _oqv = _of1 * g * (1.0 + _oou) / (_o28 * (1.0 - _oou));
  } else {
    _oqv = _of1 * g / _o28;
  }
  return _ojz * _oqv;
}
struct _o1i {
  r: mat3x3f,
  _olx: vec3f,
  _ob2: f32,
  _ofz: vec3f,
  _og0: vec3f,
  _o5u: f32,
  _o5v: f32,
  _o5w: f32,
};
fn _oep(_olo: u32, _oe8: vec3f, _oeb: vec3f) -> _o1i {
  var _obj: _o1i;
  let _oqg = 8u * _olo;
  let w = _oqt[_oqg];
  let x = _oqt[_oqg + 1u];
  let y = _oqt[_oqg + 2u];
  let z = _oqt[_oqg + 3u];
  _obj.r = mat3x3f(
      vec3f(1.0 - 2.0 * (y * y + z * z), 2.0 * (x * y + w * z), 2.0 * (x * z - w * y)),
      vec3f(2.0 * (x * y - w * z), 1.0 - 2.0 * (x * x + z * z), 2.0 * (y * z + w * x)),
      vec3f(2.0 * (x * z + w * y), 2.0 * (y * z - w * x), 1.0 - 2.0 * (x * x + y * y)));
  _obj._olx = vec3f(_oqt[_oqg + 4u], _oqt[_oqg + 5u], _oqt[_oqg + 6u]);
  _obj._ob2 = _oqt[_oqg + 7u];
  _obj._o5u = 0.0;
  _obj._o5v = 0.0;
  _obj._o5w = 0.0;
  for (var _oe3 = 0u; _oe3 < 3u; _oe3 = _oe3 + 1u) {
    let _o70 = _obj.r[_oe3];
    let _oi4 = _oe8.x * _o70.x + _oe8.y * _o70.y + _oe8.z * _o70.z;
    let _oi5 = _oeb.x * _o70.x + _oeb.y * _o70.y + _oeb.z * _o70.z;
    _obj._ofz[_oe3] = _oi4 * _obj._olx[_oe3];
    _obj._og0[_oe3] = _oi5 * _obj._olx[_oe3];
    _obj._o5u = _obj._o5u + _obj._ofz[_oe3] * _obj._ofz[_oe3];
    _obj._o5v = _obj._o5v + _obj._ofz[_oe3] * _obj._og0[_oe3];
    _obj._o5w = _obj._o5w + _obj._og0[_oe3] * _obj._og0[_oe3];
  }
  return _obj;
}
struct _o2 {
  _oq7: f32,
  _okz: f32,
  _ogz: f32,
  _ojd: bool,
  _ogc: f32,
  _oah: bool,
};
fn _o3h(_obj: _o1i, _oe8: vec3f, _oeb: vec3f, _okw: vec3f,
                     _oag: f32, _oam: f32) -> _o2 {
  var _oaw: _o2;
  let _oly = _obj._olx.x;
  let _olz = _obj._olx.y;
  let _om0 = _obj._olx.z;
  _oaw._oq7 = 0.5 * _oly * (_olz + _om0);
  let _ohm = vec3f(_olz * _om0, _oly * _om0, _oly * _olz);
  var _opi: vec3f;
  var _of6 = 0.0;
  for (var _oe3 = 0u; _oe3 < 3u; _oe3 = _oe3 + 1u) {
    let _o70 = _obj.r[_oe3];
    let _okx = _okw.x * _o70.x + _okw.y * _o70.y + _okw.z * _o70.z;
    _opi[_oe3] = _okx * _ohm[_oe3];
    _of6 = _obd(_of6, abs(_opi[_oe3]));
  }
  let _odu = select(0.0, 1.0 / _of6, _of6 > 0.0);
  var _ooh = 0.0;
  for (var _oe3 = 0u; _oe3 < 3u; _oe3 = _oe3 + 1u) {
    let _ome = _opi[_oe3] * _odu;
    _ooh = _ooh + _ome * _ome;
  }
  let _olj = sqrt(_ooh);
  _oaw._okz = _of6 * _olj;
  let _ogy = vec3f(_oe8.y * _oeb.z - _oe8.z * _oeb.y,
                     _oe8.z * _oeb.x - _oe8.x * _oeb.z,
                     _oe8.x * _oeb.y - _oe8.y * _oeb.x);
  _oaw._ogz = sqrt(_ogy.x * _ogy.x + _ogy.y * _ogy.y + _ogy.z * _ogy.z);
  _oaw._ojd = _oly > 0.0 && _olz > 0.0 && _om0 > 0.0;
  _oaw._ogc = 0.0;
  for (var _oe3 = 0u; _oe3 < 3u; _oe3 = _oe3 + 1u) {
    let _oa4 = -_oam * _obj._ofz[_oe3] + _oag * _obj._og0[_oe3];
    _oaw._ogc = _oaw._ogc + _oa4 * _oa4;
  }
  _oaw._oah = _oag == 0.0 && _oam == 0.0;
  return _oaw;
}
fn _oo0(_oaw: _o2, g: f32, _o7a: vec3f, _ope: vec3f,
                     _oag: f32, _oam: f32) -> f32 {
  let _oss = !_oaw._oah && !(_oaw._ogc > 0.0);
  let a = _oaw._oq7;
  let w = _oaw._okz;
  let _ogq = _oaw._ogz;
  var _oqr: f32;
  if (_oss) {
    _oqr = 0.0;
  } else {
    let _olk = sqrt(_oaw._ogc);
    let _oex = _olk / (g * _ogq * w);
    if (_oex < _o2n) {
      let _oey = _oex * _oex;
      let _o89 = 1.0 - _oey / 12.0;
      _oqr = a * g * g * _ogq / _o89;
    } else {
      let _ob7 = _oad(_oex);
      _oqr = a * g * _olk / (_o28 * w * _ob7._or7);
    }
  }
  let _oo9 = g * g - 1.0;
  let _o5a = _o7a.x + _oo9 * _ope.x;
  let _o5d = _o7a.y + _oo9 * _ope.y;
  let _o5k = _o7a.z + _oo9 * _ope.z;
  let _o8y = _o5a * _o5k - _o5d * _o5d;
  let _o38 = _o5k * _oag - _o5d * _oam;
  let _o39 = _o5a * _oam - _o5d * _oag;
  let _ock = _oag * _o38 + _oam * _o39;
  let _ocj = select(0.0, _ock, _ock > 0.0);
  let _of0 = sqrt(_ocj / _o8y);
  var _ob3: f32;
  if (_of0 < _o2n) {
    let _oi9 = 1.0 - _ocj / (12.0 * _o8y);
    _ob3 = _oi9 * inverseSqrt(_o8y);
  } else {
    let _ob8 = _oad(_of0);
    _ob3 = _o28 * _ob8._or7 * inverseSqrt(_ocj);
  }
  return _oqr * _ob3;
}
struct _or {
  _ohg: bool,
  a: vec4f,
  b: vec4f,
};
fn _o6p(_oic: vec4f, _oio: vec4f) -> _or {
  var _ole: _or;
  _ole._ohg = false;
  let _o89 = _oio - _oic;
  var _oov = 0.0;
  var _oow = 1.0;
  var _o6z = array<f32, 5>(_oic.w - _o2j, _oic.x + _oic.w, _oic.w - _oic.x,
                           _oic.y + _oic.w, _oic.w - _oic.y);
  var _o65 = array<f32, 5>(_o89.w, _o89.x + _o89.w, _o89.w - _o89.x, _o89.y + _o89.w, _o89.w - _o89.y);
  var _o7x = false;
  var _o7v = 0.0;
  var _o7w = 1.0;
  for (var _oed = 0u; _oed < 5u; _oed = _oed + 1u) {
    if (_o65[_oed] == 0.0) {
      if (_o6z[_oed] < 0.0) {
        _o7x = true;
        break;
      }
      continue;
    }
    let _opz = -_o6z[_oed] / _o65[_oed];
    if (_o65[_oed] > 0.0) {
      _o7v = _obd(_o7v, _opz);
    } else {
      _o7w = _obe(_o7w, _opz);
    }
  }
  if (_o7x || _o7v > _o7w) {
    return _ole;
  }
  if (_o65[0] == 0.0) {
    if (_o6z[0] < 0.0) {
      return _ole;
    }
  } else {
    let _opz = -_o6z[0] / _o65[0];
    if (_o65[0] > 0.0) {
      _oov = _obd(_oov, _opz);
    } else {
      _oow = _obe(_oow, _opz);
    }
  }
  if (_oov > _oow) {
    return _ole;
  }
  for (var _o58 = 0u; _o58 < 4u; _o58 = _o58 + 1u) {
    _ole.a[_o58] = _obc(_o89[_o58], _oov, _oic[_o58]);
    _ole.b[_o58] = _obc(_o89[_o58], _oow, _oic[_o58]);
  }
  _ole._ohg = true;
  return _ole;
}
fn _opt(a: vec2f, b: vec2f, _oia: f32, _oi8: f32, _oqd: u32,
                 _os6: u32, _oqb: u32, _oqc: u32) -> vec3u {
  let _o9a = b - a;
  let _ofa = _od6(_o9a.x, _o9a.y);
  let _on0 = _ofa < 1e-4;
  let _om6 = select(_o9a, vec2f(1.0, 0.0), _on0);
  let _om7 = select(_ofa, 1.0, _on0);
  let _oqn = vec2f(-_om6.y / _om7, _om6.x / _om7);
  let _oqm = vec2f(_om6.x / _om7, _om6.y / _om7);
  let _ojf = _oia + _oj;
  let _oic = _oi8 + _oj;
  var _o58: array<vec2f, 4>;
  _o58[3] = vec2f(_obc(-_oqm.x, _oic, _obc(_oqn.x, _ojf, a.x)),
               _obc(-_oqm.y, _oic, _obc(_oqn.y, _ojf, a.y)));
  _o58[0] = vec2f(_obc(-_oqm.x, _oic, _obc(-_oqn.x, _ojf, a.x)),
               _obc(-_oqm.y, _oic, _obc(-_oqn.y, _ojf, a.y)));
  _o58[2] = vec2f(_obc(_oqm.x, _oic, _obc(_oqn.x, _ojf, b.x)),
               _obc(_oqm.y, _oic, _obc(_oqn.y, _ojf, b.y)));
  _o58[1] = vec2f(_obc(_oqm.x, _oic, _obc(-_oqn.x, _ojf, b.x)),
               _obc(_oqm.y, _oic, _obc(-_oqn.y, _ojf, b.y)));
  let _osp = f32(_oqd * _oi);
  let _oso = f32(_oqd * _oi + (_oi - 1u));
  var _osl = 3.4e38;
  var _osj = -3.4e38;
  for (var _od7 = 0u; _od7 < 4u; _od7 = _od7 + 1u) {
    let _oi4 = _o58[_od7];
    let _oi5 = _o58[(_od7 + 1u) & 3u];
    if (_oi4.y >= _osp && _oi4.y <= _oso) {
      _osl = _obe(_osl, _oi4.x);
      _osj = _obd(_osj, _oi4.x);
    }
    let _o9x = _oi5.y - _oi4.y;
    if (_o9x != 0.0) {
      var _oou = (_osp - _oi4.y) / _o9x;
      if (_oou > 0.0 && _oou < 1.0) {
        let x = _obc(_oou, _oi5.x - _oi4.x, _oi4.x);
        _osl = _obe(_osl, x);
        _osj = _obd(_osj, x);
      }
      _oou = (_oso - _oi4.y) / _o9x;
      if (_oou > 0.0 && _oou < 1.0) {
        let x = _obc(_oou, _oi5.x - _oi4.x, _oi4.x);
        _osl = _obe(_osl, x);
        _osj = _obd(_osj, x);
      }
    }
  }
  if (!(_osj >= _osl)) {
    return vec3u(0u, 0u, 0u);
  }
  let _orv = f32(_os6 - 1u);
  let _osm = _obe(_obd(_osl, 0.0), _orv);
  let _osk = _obe(_obd(_osj, 0.0), _orv);
  let _ooq = max(i32(_oqb), i32(floor(_osm * 0.0625)));
  let _oor = min(i32(_oqc), i32(floor(_osk * 0.0625)) + 1);
  if (_oor > _ooq) {
    return vec3u(u32(_ooq), u32(_oor), 1u);
  }
  return vec3u(0u, 0u, 0u);
}
@compute @workgroup_size(256)
fn preprocess(@builtin(local_invocation_index) _ofg: u32,
              @builtin(workgroup_id) _os5: vec3u,
              @builtin(num_workgroups) _oh4: vec3u) {
  let _odb = _ofj(_os5, _oh4) * _o2o + _ofg;
  if (_odb >= _o7r[_o21]) {
    return;
  }
  let _oni = _oeo[_odb];
  _opv[_odb] = 0u;
  _ojm[_odb]._obz = vec4f(0.0, 0.0, 0.0, 0.0);
  let _o3f = _o3g[_oni] * _oau[_oni];
  let _oh8 = 6u * _oni;
  let _oid = vec3f(_oa9[_oh8], _oa9[_oh8 + 1u], _oa9[_oh8 + 2u]);
  let _oip = vec3f(_oa9[_oh8 + 3u], _oa9[_oh8 + 4u], _oa9[_oh8 + 5u]);
  let _ofi = vec3f((_oid.x + _oip.x) * 0.5, (_oid.y + _oip.y) * 0.5, (_oid.z + _oip.z) * 0.5);
  let _o8v = _ori(_ofi);
  let _o6o = _o6p(_oju(_oid), _oju(_oip));
  if (!_o6o._ohg) {
    return;
  }
  let _os6 = _o5x._os6;
  let _ocv = _o5x._ocv;
  let _o31 = vec2f(_ogu(_o6o.a.x / _o6o.a.w, _os6), _ogu(_o6o.a.y / _o6o.a.w, _ocv));
  let _o43 = vec2f(_ogu(_o6o.b.x / _o6o.b.w, _os6), _ogu(_o6o.b.y / _o6o.b.w, _ocv));
  let _o4n = _o5x._o4n;
  let _o68 = _oju(_ofi);
  var _omp = _o68.w > _o2j && _odz(_o68.w);
  let _om8 = select(1.0, _o68.w, _omp);
  let _odr = 1.0 / (_om8 * _om8);
  let _ocq = 0.5 * f32(_os6);
  let _ocn = 0.5 * f32(_ocv);
  let _oe8 = vec3f(_ocq * (_om8 * _oj2(0u) - _o68.x * _oj2(3u)) * _odr,
                 _ocq * (_om8 * _oj2(4u) - _o68.x * _oj2(7u)) * _odr,
                 _ocq * (_om8 * _oj2(8u) - _o68.x * _oj2(11u)) * _odr);
  let _oeb = vec3f(_ocn * (_om8 * _oj2(1u) - _o68.y * _oj2(3u)) * _odr,
                 _ocn * (_om8 * _oj2(5u) - _o68.y * _oj2(7u)) * _odr,
                 _ocn * (_om8 * _oj2(9u) - _o68.y * _oj2(11u)) * _odr);
  let _ogi = vec2f(_ogu(_o68.x / _om8, _os6),
                           _ogu(_o68.y / _om8, _ocv));
  let _obj = _oep(_oni, _oe8, _oeb);
  let _o5p = _obj._o5u + _obj._ob2 * _o9n(_oe8, _oe8);
  let _o5q = _obj._o5v + _obj._ob2 * _o9n(_oe8, _oeb);
  let _o5r = _obj._o5w + _obj._ob2 * _o9n(_oeb, _oeb);
  let _o5a = _o5p + _o4n;
  let _o5d = _o5q;
  let _o5k = _o5r + _o4n;
  let _okt = _om8 / _o6o.a.w;
  let _oku = _om8 / _o6o.b.w;
  let _o90 = _o5a * _o5k - _o5d * _o5d;
  _omp = _omp && _o90 > 0.0 && _odz(_o90);
  let _odn = select(0.0, 1.0 / _o90, _omp);
  let _o6j = _o43 - _o31;
  let _o38 = _o5k * _o6j.x - _o5d * _o6j.y;
  let _o39 = _o5a * _o6j.y - _o5d * _o6j.x;
  let _oci = _o6j.x * _o38 + _o6j.y * _o39;
  let _och = _obd(_oci * _odn, 0.0);
  let _oex = sqrt(_och);
  let _odo = select(0.0, 1.0 / _oci, _och > 1e-8);
  let _oj5 = !(_oex > _o2n) || !(_odo > 0.0);
  let _o5z = _o5x._o60.xyz;
  let _okv = _ofi - _o5z;
  let _odw = inverseSqrt(_o9n(_okv, _okv));
  let _okw = _okv * _odw;
  let _oaw = _o3h(_obj, _oe8, _oeb, _okw, _o6j.x, _o6j.y);
  let _o7a = vec3f(_o5a, _o5d, _o5k);
  let _ope = vec3f(_o5p, _o5q, _o5r);
  let _olf = _obd(_o3f, 0.0);
  let _ojz = _olf * _oaw._oq7 * _oaw._ogz;
  let _of1 = sqrt(_oaw._ogc) / (_oaw._ogz * _oaw._okz);
  let _oee = _oo0(_oaw, _okt, _o7a, _ope, _o6j.x, _o6j.y);
  let _oeg = _oo0(_oaw, 1.0, _o7a, _ope, _o6j.x, _o6j.y);
  let _oef = _oo0(_oaw, _oku, _o7a, _ope, _o6j.x, _o6j.y);
  let _oiq = _olf * _obd(_oee, _obd(_oeg, _oef));
  let _oqj = _oo3(_ojz, _of1, _okt);
  let _oql = _oo3(_ojz, _of1, 1.0);
  let _oqk = _oo3(_ojz, _of1, _oku);
  _omp = _omp && _oaw._ojd && _odz(_of1)
      && _odz(_oqj) && _odz(_oql) && _odz(_oqk);
  if (!_omp) {
    return;
  }
  let _o69 = _ogi;
  if (_oiq < _o1k) {
    return;
  }
  let _o83 = _obd(log(_obd(_oiq, _o14) / _o14), 1e-6);
  let _o9a = _o43 - _o31;
  let _ofa = _od6(_o9a.x, _o9a.y);
  let _on0 = _ofa < 1e-4;
  let _om6 = select(_o9a, vec2f(1.0, 0.0), _on0);
  let _om7 = select(_ofa, 1.0, _on0);
  let _oqn = vec2f(-_om6.y / _om7, _om6.x / _om7);
  let _oqm = vec2f(_om6.x / _om7, _om6.y / _om7);
  let _oed = sqrt(_o83);
  let _obu = _obd(_okt, _oku);
  let _ooa = _obd(_obu * _obu - 1.0, 0.0);
  let _o6w = _o5a + _ooa * _o5p;
  let _o6x = _o5d + _ooa * _o5q;
  let _o6y = _o5k + _ooa * _o5r;
  let _or9 = _oqn.x * (_o6w * _oqn.x + _o6x * _oqn.y)
               + _oqn.y * (_o6x * _oqn.x + _o6y * _oqn.y);
  let _or8 = _oqm.x * (_o6w * _oqm.x + _o6x * _oqm.y)
                + _oqm.y * (_o6x * _oqm.x + _o6y * _oqm.y);
  var _oia = _oed * sqrt(_obd(_or9, 1e-8));
  var _oi8: f32;
  if (_oj5) {
    _oi8 = _oed * sqrt(_obd(_or8, 1e-8));
  } else {
    let x = _oqn.x * (_o6w * _oqm.x + _o6x * _oqm.y)
          + _oqn.y * (_o6x * _oqm.x + _o6y * _oqm.y);
    let _o8y = _o6w * _o6y - _o6x * _o6x;
    _oi8 = _oed * sqrt(_obd(_or8, 1e-8)
        + 2.0 * abs(x) * sqrt(_obd(_o8y, 0.0)) / _obd(_or9, 1e-8));
  }
  let _o95 = _od6(f32(_os6), f32(_ocv));
  _oia = _obe(_oia, _o95);
  _oi8 = _obe(_oi8, _o95);
  var _ok3: array<vec2f, 4>;
  _ok3[3] = vec2f(_obc(-_oqm.x, _oi8, _obc(_oqn.x, _oia, _o31.x)),
                  _obc(-_oqm.y, _oi8, _obc(_oqn.y, _oia, _o31.y)));
  _ok3[0] = vec2f(_obc(-_oqm.x, _oi8, _obc(-_oqn.x, _oia, _o31.x)),
                  _obc(-_oqm.y, _oi8, _obc(-_oqn.y, _oia, _o31.y)));
  _ok3[2] = vec2f(_obc(_oqm.x, _oi8, _obc(_oqn.x, _oia, _o43.x)),
                  _obc(_oqm.y, _oi8, _obc(_oqn.y, _oia, _o43.y)));
  _ok3[1] = vec2f(_obc(_oqm.x, _oi8, _obc(-_oqn.x, _oia, _o43.x)),
                  _obc(_oqm.y, _oi8, _obc(-_oqn.y, _oia, _o43.y)));
  var _ogk = _ok3[0].x;
  var _og6 = _ok3[0].x;
  var _ogm = _ok3[0].y;
  var _og8 = _ok3[0].y;
  var _og1 = 0.0;
  for (var _od7 = 0u; _od7 < 4u; _od7 = _od7 + 1u) {
    let _o7f = _ok3[_od7];
    if (!_odz(_o7f.x) || !_odz(_o7f.y)) {
      return;
    }
    _ogk = _obe(_ogk, _o7f.x);
    _og6 = _obd(_og6, _o7f.x);
    _ogm = _obe(_ogm, _o7f.y);
    _og8 = _obd(_og8, _o7f.y);
    _og1 = _obd(_og1, _od6(_o7f.x - _o69.x, _o7f.y - _o69.y));
  }
  let _os4 = f32(_os6 - 1u);
  let _ocw = f32(_ocv - 1u);
  let _ogl = _obe(_obd(_ogk - _oj, 0.0), _os4);
  let _og7 = _obe(_obd(_og6 + _oj, 0.0), _os4);
  let _ogn = _obe(_obd(_ogm - _oj, 0.0), _ocw);
  let _og9 = _obe(_obd(_og8 + _oj, 0.0), _ocw);
  let _oce = i32(_o5x._opw);
  let _ocf = i32(_o5x._opx);
  let _oqb = max(0, min(_oce, i32(floor(_ogl * 0.0625))));
  let _oqe = max(0, min(_ocf, i32(floor(_ogn * 0.0625))));
  let _oqc = max(0, min(_oce, i32(floor(_og7 * 0.0625)) + 1));
  let _oqf = max(0, min(_ocf, i32(floor(_og9 * 0.0625)) + 1));
  if (_oqb >= _oqc || _oqe >= _oqf) {
    return;
  }
  let _okk = f32(max(_os6, _ocv));
  let _og2 = max(1, i32(ceil(_obe(_og1, _okk))));
  var _ojk: _o1u;
  _ojk._o3i = vec4f(_o5p, _o5q, _o5r, select(_okt, -abs(_okt), _oj5));
  _ojk._o4u = vec4f(_ojz, _of1, _o83, _oku);
  _ojk.ab = vec4f(_o31, _o43);
  _ojk._obz = vec4f(_oia, _oi8, _o8v, f32(_og2));
  _ojk._ol9 = vec4u(u32(_oqb), u32(_oqe), u32(_oqc), u32(_oqf));
  _ojm[_odb] = _ojk;
  var _ogt = 0u;
  for (var _oqd = u32(_oqe); _oqd < u32(_oqf); _oqd = _oqd + 1u) {
    let _onl = _opt(_o31, _o43, _oia, _oi8, _oqd, _os6, u32(_oqb), u32(_oqc));
    if (_onl.z != 0u) {
      _ogt = _ogt + (_onl.y - _onl.x);
    }
  }
  _opv[_odb] = _ogt;
}
fn _o9n(x: vec3f, y: vec3f) -> f32 {
  return x.x * y.x + x.y * y.y + x.z * y.z;
}
@compute @workgroup_size(256)
fn duplicate_keys(@builtin(local_invocation_index) _ofg: u32,
                  @builtin(workgroup_id) _os5: vec3u,
                  @builtin(num_workgroups) _oh4: vec3u) {
  let _odb = _ofj(_os5, _oh4) * _o2o + _ofg;
  if (_odb >= _o9t[_o21]) {
    return;
  }
  let _ojk = _o9v[_odb];
  if (!(_ojk._obz.w > 0.0)) {
    return;
  }
  var off = 0u;
  if (_odb > 0u) {
    off = _o9u[_odb - 1u];
  }
  let _o31 = _ojk.ab.xy;
  let _o43 = _ojk.ab.zw;
  let _o8w = bitcast<u32>(_ojk._obz.z);
  let _o62 = _o9s._o62;
  for (var y = _ojk._ol9.y; y < _ojk._ol9.w; y = y + 1u) {
    let _onl = _opt(_o31, _o43, _ojk._obz.x, _ojk._obz.y, y,
                             _o9s._os6, _ojk._ol9.x, _ojk._ol9.z);
    if (_onl.z == 0u) {
      continue;
    }
    for (var x = _onl.x; x < _onl.y; x = x + 1u) {
      if (off < _o62) {
        _oes[off] = y * _o9s._opw + x;
        _oet[off] = _o8w;
        _oim[off] = _odb;
      }
      off = off + 1u;
    }
  }
}
