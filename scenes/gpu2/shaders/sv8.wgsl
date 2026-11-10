@group(0) @binding(0) var<storage, read> _oev: array<u32>;
@group(0) @binding(1) var<storage, read> _oq0: array<u32>;
@group(0) @binding(2) var<storage, read> _oae: array<f32>;
@group(0) @binding(3) var<storage, read> _oor: array<f32>;
@group(0) @binding(4) var<storage, read> _oop: array<f32>;
@group(0) @binding(5) var<storage, read> _ooq: array<f32>;
@group(0) @binding(6) var<storage, read> _o83: array<u32>;
@group(0) @binding(7) var<storage, read_write> rgb: array<f32>;
@group(0) @binding(8) var<uniform> _o5v: _oo;
const _o1u: u32 = 8u;
const _o1t: f32 = 1e-12;
@compute @workgroup_size(256)
fn sv8_color(@builtin(local_invocation_index) _ofl: u32,
             @builtin(workgroup_id) _os6: vec3u,
             @builtin(num_workgroups) _ohc: vec3u) {
  let _omx = _ofq(_os6, _ohc) * _o2j + _ofl;
  if (_omx >= _o83[_o1w]) {
    return;
  }
  if (_o5v._o9b == 0u && _oq0[_omx] == 0u) {
    return;
  }
  let _olr = _oev[_omx];
  let _oic = 6u * _olr;
  let _ogj = 0.5 * (_oae[_oic] + _oae[_oic + 3u]);
  let _ogk = 0.5 * (_oae[_oic + 1u] + _oae[_oic + 4u]);
  let _ogl = 0.5 * (_oae[_oic + 2u] + _oae[_oic + 5u]);
  let _ors = _ogj - _o5v._o5y.x;
  let _ort = _ogk - _o5v._o5y.y;
  let _oru = _ogl - _o5v._o5y.z;
  let _orm = sqrt(_ors * _ors + _ort * _ort + _oru * _oru);
  let _orn = 1.0 / _orm;
  let _oa1 = _ors * _orn;
  let _oa2 = _ort * _orn;
  let _oa3 = _oru * _orn;
  var _os3: array<f32, 8>;
  var _og8 = -1.0e30;
  for (var _oei = 0u; _oei < _o1u; _oei = _oei + 1u) {
    let _olz = 3u * (_olr * _o1u + _oei);
    let _oou = _oor[_olz];
    let _oox = _oor[_olz + 1u];
    let _ooy = _oor[_olz + 2u];
    let _ona = sqrt(_oou * _oou + _oox * _oox + _ooy * _ooy);
    let _onb = 1.0 / _obe(_ona, _o1t);
    let _oaj = _oou * _onb - _oa1;
    let _oap = _oox * _onb - _oa2;
    let _oaq = _ooy * _onb - _oa3;
    let _onw = _oaj * _oaj + _oap * _oap + _oaq * _oaq;
    let distance = sqrt(_onw);
    let _ofx = -exp(_ooq[_olr * _o1u + _oei]) * distance;
    _os3[_oei] = _ofx;
    _og8 = _obe(_og8, _ofx);
  }
  var _os4 = 0.0;
  for (var _oei = 0u; _oei < _o1u; _oei = _oei + 1u) {
    let _orc = exp(_os3[_oei] - _og8);
    _os3[_oei] = _orc;
    _os4 = _os4 + _orc;
  }
  let _oe2 = 1.0 / _os4;
  var _ob2 = vec3f(0.0);
  for (var _oei = 0u; _oei < _o1u; _oei = _oei + 1u) {
    let w = _os3[_oei] * _oe2;
    let _o56 = 3u * (_olr * _o1u + _oei);
    _ob2.x = _ob2.x + w * _oop[_o56];
    _ob2.y = _ob2.y + w * _oop[_o56 + 1u];
    _ob2.z = _ob2.z + w * _oop[_o56 + 2u];
  }
  rgb[3u * _omx] = _obe(_ob2.x + 0.5, 0.0);
  rgb[3u * _omx + 1u] = _obe(_ob2.y + 0.5, 0.0);
  rgb[3u * _omx + 2u] = _obe(_ob2.z + 0.5, 0.0);
}
