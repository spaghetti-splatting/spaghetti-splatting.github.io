struct _o24 {
  _onk: u32,
  _oqo: u32,
  _obq: u32,
  _orf: u32,
  _oc0: f32,
  _o8f: f32,
  _o9d: f32,
  _o4d: f32,
  _onr: f32,
  _ons: f32,
  _onq: f32,
  _onh: f32,
  _o7e: f32,
  _ofs: f32,
  _opa: f32,
  _obw: f32,
  _o8h: vec4f,
  _ore: vec4f,
  _om5: vec4f,
  _om6: vec4u,
  _obr: vec4f,
};
@group(0) @binding(0) var<uniform> _omx: _o24;
@group(0) @binding(1) var<storage, read> _onj: array<u32>;
@group(0) @binding(2) var<storage, read> _oko: array<vec4f>;
@group(0) @binding(3) var<storage, read_write> _o3h: array<vec4f>;
@group(0) @binding(4) var<storage, read_write> _obp: array<vec4f>;
@group(0) @binding(5) var<storage, read_write> _orq: array<vec4f>;
@group(0) @binding(6) var<storage, read_write> _oqw: array<vec4f>;
@group(0) @binding(7) var<storage, read> _om3: array<f32>;
@group(0) @binding(8) var<storage, read_write> _ong: array<atomic<u32>>;
struct _o23 {
  _o80: f32,
  g: vec3f,
};
fn _om4(_ohn: vec3f) -> _o23 {
  var _oh7: _o23;
  let _ogo = _omx._om6.x;
  let _ogp = _omx._om6.y;
  let _ogq = _omx._om6.z;
  let _oaa = (_ohn - _omx._om5.xyz) * _omx._om5.w;
  if (_oaa.x < 0.0 || _oaa.y < 0.0 || _oaa.z < 0.0 || _oaa.x > f32(_ogo) - 1.001 || _oaa.y > f32(_ogp) - 1.001
      || _oaa.z > f32(_ogq) - 1.001) {
    _oh7._o80 = 1.0e6;
    _oh7.g = vec3f(0.0);
    return _oh7;
  }
  let _ocr = u32(_oaa.x);
  let _odn = u32(_oaa.y);
  let _odx = u32(_oaa.z);
  let _oba = _oaa.x - f32(_ocr);
  let _obb = _oaa.y - f32(_odn);
  let _obc = _oaa.z - f32(_odx);
  let _ogr = (_ocr * _ogp + _odn) * _ogq + _odx;
  let _omo = _ogq;
  let _ome = _ogp * _ogq;
  let _o52 = _om3[_ogr];
  let _o53 = _om3[_ogr + 1u];
  let _o55 = _om3[_ogr + _omo];
  let _o56 = _om3[_ogr + _omo + 1u];
  let _o59 = _om3[_ogr + _ome];
  let _o5a = _om3[_ogr + _ome + 1u];
  let _o5c = _om3[_ogr + _ome + _omo];
  let _o5d = _om3[_ogr + _ome + _omo + 1u];
  let _o51 = _o52 + (_o53 - _o52) * _obc;
  let _o54 = _o55 + (_o56 - _o55) * _obc;
  let _o58 = _o59 + (_o5a - _o59) * _obc;
  let _o5b = _o5c + (_o5d - _o5c) * _obc;
  let _o50 = _o51 + (_o54 - _o51) * _obb;
  let _o57 = _o58 + (_o5b - _o58) * _obb;
  let _obx = _o57 - _o50;
  let _oby = (1.0 - _oba) * (_o54 - _o51) + _oba * (_o5b - _o58);
  let _o9o = (_o53 - _o52) * (1.0 - _obb) + (_o56 - _o55) * _obb;
  let _o9p = (_o5a - _o59) * (1.0 - _obb) + (_o5d - _o5c) * _obb;
  let _obz = _o9o * (1.0 - _oba) + _o9p * _oba;
  let g = vec3f(_obx, _oby, _obz);
  let _og7 = length(g);
  _oh7.g = select(vec3f(0.0), g / _og7, _og7 > 0.0);
  _oh7._o80 = _o50 + (_o57 - _o50) * _oba;
  return _oh7;
}
fn _o90(_ocr: u32) -> vec3f {
  return _orq[_ocr].xyz - _oko[_ocr].xyz;
}
fn _oaz(_oes: vec3f, _ojc: vec3f, _okp: vec3f, _oet: f32) -> vec3f {
  var _o9n = _ojc - _oes;
  var _og7 = length(_o9n);
  if (_og7 < 1.0e-12) {
    _o9n = _okp;
    _og7 = length(_o9n);
  }
  return _oes + _o9n * (_oet / _og7);
}
fn _o3g(_omq: u32, _oqi: f32) {
  atomicMax(&_ong[_omq], bitcast<u32>(max(_oqi, 0.0)));
}
@compute @workgroup_size(64)
fn substep(@builtin(global_invocation_id) _obm: vec3u, @builtin(num_workgroups) _ogn: vec3u) {
  let _ola = _obm.x + _obm.y * _ogn.x * 64u;
  if (_ola >= _omx._onk) {
    return;
  }
  let _o40 = _onj[_ola];
  let _og7 = _onj[_ola + 1u] - _o40;
  if (_og7 < 2u) {
    return;
  }
  let _oc0 = _omx._oc0;
  let _oe3 = _omx._o4d;
  let _o4k = _omx._onh;
  let _o8d = 2.0 * sqrt(_o4k);
  let _ocv = 1.0 / _oc0;
  let _o64 = _omx._o7e / _oc0;
  _orq[_o40] = vec4f(_oko[_o40].xyz, 0.0);
  _oqw[_o40] = vec4f(0.0);
  var _ore = vec3f(0.0);
  if (_omx._orf != 0u) {
    let _ob9 = f32(_ola);
    let _obw = 0.6 + 0.4 * sin(2.3 * _omx._opa + 0.0007 * _ob9) + 0.25 * sin(5.1 * _omx._opa + 0.0013 * _ob9);
    _ore = _omx._ore.xyz * _obw;
  }
  var _oq2 = vec3f(0.0);
  var _oq1 = vec3f(0.0);
  var _opt = vec3f(0.0);
  var _oq8 = _o90(_o40 + 1u);
  var _oq9 = vec3f(0.0);
  if (_og7 > 2u) {
    _oq9 = _o90(_o40 + 2u);
  }
  var _oer = _oko[_o40].xyz;
  var _oiu = _oer;
  var _oiv = _oer;
  var _ofm = 0.0;
  var _ofl = 0.0;
  let _oeq = _og7 - 1u;
  for (var _odx = 1u; _odx < _og7; _odx = _odx + 1u) {
    _oq2 = _oq1;
    _oq1 = _opt;
    _opt = _oq8;
    _oq8 = _oq9;
    if (_odx + 2u < _og7) {
      _oq9 = _o90(_o40 + _odx + 2u);
    } else {
      _oq9 = vec3f(0.0);
    }
    let _ocr = _o40 + _odx;
    let x = _orq[_ocr].xyz;
    let _oqd = _oqw[_ocr].xyz;
    let _ojv = _oko[_ocr];
    let _o3k = _o3h[_ocr];
    let _o94 = select(vec3f(0.0), _oq2 - 2.0 * _oq1 + _opt, _odx >= 2u);
    let _o93 = select(vec3f(0.0), _oq1 - 2.0 * _opt + _oq8, _odx <= _og7 - 2u);
    let _o95 = select(vec3f(0.0), _opt - 2.0 * _oq8 + _oq9, _odx + 1u <= _og7 - 2u);
    let _o4c = -_o94 + 2.0 * _o93 - _o95;
    let _oni = _omx._ons + (_omx._onr - _omx._ons) * exp(-_ojv.w / _omx._onq);
    var a = -_oni * _opt + _oe3 * _o4c + _omx._o9d * (_ore - _oqd);
    let w = _o3k.z;
    if (_omx._obq != 0u && w > 0.0) {
      let _obn = _obp[_ocr].xyz + _o3k.w * _omx._o8h.xyz;
      a = a + w * (_o4k * (_obn - x) - _o8d * _oqd);
    }
    let _oqm = (_oqd + _oc0 * a) * _omx._o8f;
    let _oho = x + _oc0 * _oqm;
    let _okq = _o3k.x;
    let _o96 = _o3k.y;
    let _okp = _ojv.xyz - _oko[_ocr - 1u].xyz;
    var _ojc = _oaz(_oer, _oho, _okp, _okq);
    for (var _odm = 0u; _odm < 2u; _odm = _odm + 1u) {
      let _oms = _om4(_ojc);
      if (!(_oms._o80 < _o96)) {
        break;
      }
      _ojc = _ojc + (_o96 - _oms._o80) * _oms.g;
      _ojc = _oaz(_oer, _ojc, _okp, _okq);
    }
    let _o80 = _ojc - _oho;
    if (_odx >= 2u) {
      let _odn = _ocr - 1u;
      let _oqu = (_oiu - _oiv) * _ocv - _o64 * _o80;
      _oqw[_odn] = vec4f(_oqu, 0.0);
      _orq[_odn] = vec4f(_oiu, 0.0);
      _ofm = max(_ofm, dot(_oqu, _oqu));
      let _oq0 = _oiu - _oko[_odn].xyz;
      _ofl = max(_ofl, dot(_oq0, _oq0));
    }
    _oiu = _ojc;
    _oiv = x;
    _oer = _ojc;
    if (_odx == _oeq) {
      let _oqx = (_ojc - x) * _ocv;
      _oqw[_ocr] = vec4f(_oqx, 0.0);
      _orq[_ocr] = vec4f(_ojc, 0.0);
      _ofm = max(_ofm, dot(_oqx, _oqx));
      let _oqc = _ojc - _ojv.xyz;
      _ofl = max(_ofl, dot(_oqc, _oqc));
    }
  }
  _o3g(0u, _ofm);
  _o3g(1u, _ofl);
}
@compute @workgroup_size(64)
fn grab_begin(@builtin(global_invocation_id) _obm: vec3u, @builtin(num_workgroups) _ogn: vec3u) {
  let _ola = _obm.x + _obm.y * _ogn.x * 64u;
  if (_ola >= _omx._onk) {
    return;
  }
  let _o40 = _onj[_ola];
  let _og7 = _onj[_ola + 1u] - _o40;
  let _ojz = _omx._obr.w;
  let _o61 = _omx._obr.xyz;
  var _o4e = _ojz;
  var _oe3 = 0u;
  for (var _odx = 1u; _odx < _og7; _odx = _odx + 1u) {
    let _o8e = length(_orq[_o40 + _odx].xyz - _o61);
    if (_o8e < _o4e) {
      _o4e = _o8e;
      _oe3 = _odx;
    }
  }
  let _omg = 0.5 * _ojz * _ojz;
  let _or1 = exp(-_o4e * _o4e / _omg);
  let _o3c = max(_oko[_o40 + _oe3].w, 1.0e-9);
  for (var _odx = 0u; _odx < _og7; _odx = _odx + 1u) {
    let _ocr = _o40 + _odx;
    var _o3k = _o3h[_ocr];
    if (_oe3 > 0u && _odx >= 1u && _odx <= _oe3) {
      _o3k.z = _or1;
      _o3k.w = pow(min(_oko[_ocr].w / _o3c, 1.0), 1.5);
      _obp[_ocr] = _orq[_ocr];
    } else {
      _o3k.z = 0.0;
      _o3k.w = 0.0;
    }
    _o3h[_ocr] = _o3k;
  }
  if (_oe3 > 0u) {
    atomicAdd(&_ong[2], 1u);
  }
}
@compute @workgroup_size(256)
fn reset_state(@builtin(global_invocation_id) _obm: vec3u, @builtin(num_workgroups) _ogn: vec3u) {
  let _ocr = _obm.x + _obm.y * _ogn.x * 256u;
  if (_ocr >= _omx._oqo) {
    return;
  }
  _orq[_ocr] = vec4f(_oko[_ocr].xyz, 0.0);
  _oqw[_ocr] = vec4f(0.0);
  var _o3k = _o3h[_ocr];
  _o3k.z = 0.0;
  _o3k.w = 0.0;
  _o3h[_ocr] = _o3k;
}
