@group(0) @binding(0) var<storage, read> _oeo: array<u32>;
@group(0) @binding(1) var<storage, read> _opv: array<u32>;
@group(0) @binding(2) var<storage, read> _oa9: array<f32>;
@group(0) @binding(3) var<storage, read> _oom: array<f32>;
@group(0) @binding(4) var<storage, read> _ook: array<f32>;
@group(0) @binding(5) var<storage, read> _ool: array<f32>;
@group(0) @binding(6) var<storage, read> _o7r: array<u32>;
@group(0) @binding(7) var<storage, read_write> rgb: array<f32>;
@group(0) @binding(8) var<uniform> _o5x: _oo;
const _o1z: u32 = 8u;
const _o1x: f32 = 1e-12;
@compute @workgroup_size(256)
fn sv8_color(@builtin(local_invocation_index) _ofg: u32,
             @builtin(workgroup_id) _os5: vec3u,
             @builtin(num_workgroups) _oh4: vec3u) {
  let _omu = _ofj(_os5, _oh4) * _o2o + _ofg;
  if (_omu >= _o7r[_o21]) {
    return;
  }
  if (_o5x._o95 == 0u && _opv[_omu] == 0u) {
    return;
  }
  let _olo = _oeo[_omu];
  let _oi3 = 6u * _olo;
  let _oge = 0.5 * (_oa9[_oi3] + _oa9[_oi3 + 3u]);
  let _ogf = 0.5 * (_oa9[_oi3 + 1u] + _oa9[_oi3 + 4u]);
  let _ogg = 0.5 * (_oa9[_oi3 + 2u] + _oa9[_oi3 + 5u]);
  let _orr = _oge - _o5x._o60.x;
  let _ors = _ogf - _o5x._o60.y;
  let _ort = _ogg - _o5x._o60.z;
  let _orj = sqrt(_orr * _orr + _ors * _ors + _ort * _ort);
  let _ork = 1.0 / _orj;
  let _o9w = _orr * _ork;
  let _o9x = _ors * _ork;
  let _o9y = _ort * _ork;
  var _os2: array<f32, 8>;
  var _og3 = -1.0e30;
  for (var _oed = 0u; _oed < _o1z; _oed = _oed + 1u) {
    let _olx = 3u * (_olo * _o1z + _oed);
    let _oop = _oom[_olx];
    let _oos = _oom[_olx + 1u];
    let _oot = _oom[_olx + 2u];
    let _on6 = sqrt(_oop * _oop + _oos * _oos + _oot * _oot);
    let _on7 = 1.0 / _obd(_on6, _o1x);
    let _oag = _oop * _on7 - _o9w;
    let _oam = _oos * _on7 - _o9x;
    let _oan = _oot * _on7 - _o9y;
    let _ont = _oag * _oag + _oam * _oam + _oan * _oan;
    let distance = sqrt(_ont);
    let _oft = -exp(_ool[_olo * _o1z + _oed]) * distance;
    _os2[_oed] = _oft;
    _og3 = _obd(_og3, _oft);
  }
  var _os3 = 0.0;
  for (var _oed = 0u; _oed < _o1z; _oed = _oed + 1u) {
    let _or7 = exp(_os2[_oed] - _og3);
    _os2[_oed] = _or7;
    _os3 = _os3 + _or7;
  }
  let _odx = 1.0 / _os3;
  var _ob0 = vec3f(0.0);
  for (var _oed = 0u; _oed < _o1z; _oed = _oed + 1u) {
    let w = _os2[_oed] * _odx;
    let _o58 = 3u * (_olo * _o1z + _oed);
    _ob0.x = _ob0.x + w * _ook[_o58];
    _ob0.y = _ob0.y + w * _ook[_o58 + 1u];
    _ob0.z = _ob0.z + w * _ook[_o58 + 2u];
  }
  rgb[3u * _omu] = _obd(_ob0.x + 0.5, 0.0);
  rgb[3u * _omu + 1u] = _obd(_ob0.y + 0.5, 0.0);
  rgb[3u * _omu + 2u] = _obd(_ob0.z + 0.5, 0.0);
}
