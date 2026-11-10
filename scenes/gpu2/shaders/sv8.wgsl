@group(0) @binding(0) var<storage, read> _oe8: array<u32>;
@group(0) @binding(1) var<storage, read> _op7: array<u32>;
@group(0) @binding(2) var<storage, read> _o9x: array<f32>;
@group(0) @binding(3) var<storage, read> _ony: array<f32>;
@group(0) @binding(4) var<storage, read> _onw: array<f32>;
@group(0) @binding(5) var<storage, read> _onx: array<f32>;
@group(0) @binding(6) var<storage, read> _o7m: array<u32>;
@group(0) @binding(7) var<storage, read_write> rgb: array<f32>;
@group(0) @binding(8) var<uniform> _o5o: _oo;
const _o1s: u32 = 8u;
const _o1r: f32 = 1e-12;
@compute @workgroup_size(256)
fn sv8_color(@builtin(local_invocation_index) _oey: u32,
             @builtin(workgroup_id) _orc: vec3u,
             @builtin(num_workgroups) _ogn: vec3u) {
  let _om7 = _of3(_orc, _ogn) * _o2h + _oey;
  if (_om7 >= _o7m[_o1u]) {
    return;
  }
  if (_o5o._o8u == 0u && _op7[_om7] == 0u) {
    return;
  }
  let _ol2 = _oe8[_om7];
  let _ohn = 6u * _ol2;
  let _ofv = 0.5 * (_o9x[_ohn] + _o9x[_ohn + 3u]);
  let _ofw = 0.5 * (_o9x[_ohn + 1u] + _o9x[_ohn + 4u]);
  let _ofx = 0.5 * (_o9x[_ohn + 2u] + _o9x[_ohn + 5u]);
  let _oqy = _ofv - _o5o._o5r.x;
  let _oqz = _ofw - _o5o._o5r.y;
  let _or0 = _ofx - _o5o._o5r.z;
  let _oqs = sqrt(_oqy * _oqy + _oqz * _oqz + _or0 * _or0);
  let _oqt = 1.0 / _oqs;
  let _o9k = _oqy * _oqt;
  let _o9l = _oqz * _oqt;
  let _o9m = _or0 * _oqt;
  var _or9: array<f32, 8>;
  var _ofk = -1.0e30;
  for (var _odx = 0u; _odx < _o1s; _odx = _odx + 1u) {
    let _ola = 3u * (_ol2 * _o1s + _odx);
    let _oo1 = _ony[_ola];
    let _oo4 = _ony[_ola + 1u];
    let _oo5 = _ony[_ola + 2u];
    let _omj = sqrt(_oo1 * _oo1 + _oo4 * _oo4 + _oo5 * _oo5);
    let _omk = 1.0 / _oaw(_omj, _o1r);
    let _oa2 = _oo1 * _omk - _o9k;
    let _oa8 = _oo4 * _omk - _o9l;
    let _oa9 = _oo5 * _omk - _o9m;
    let _on4 = _oa2 * _oa2 + _oa8 * _oa8 + _oa9 * _oa9;
    let distance = sqrt(_on4);
    let _ofa = -exp(_onx[_ol2 * _o1s + _odx]) * distance;
    _or9[_odx] = _ofa;
    _ofk = _oaw(_ofk, _ofa);
  }
  var _ora = 0.0;
  for (var _odx = 0u; _odx < _o1s; _odx = _odx + 1u) {
    let _oqi = exp(_or9[_odx] - _ofk);
    _or9[_odx] = _oqi;
    _ora = _ora + _oqi;
  }
  let _odh = 1.0 / _ora;
  var _oal = vec3f(0.0);
  for (var _odx = 0u; _odx < _o1s; _odx = _odx + 1u) {
    let w = _or9[_odx] * _odh;
    let _o4z = 3u * (_ol2 * _o1s + _odx);
    _oal.x = _oal.x + w * _onw[_o4z];
    _oal.y = _oal.y + w * _onw[_o4z + 1u];
    _oal.z = _oal.z + w * _onw[_o4z + 2u];
  }
  rgb[3u * _om7] = _oaw(_oal.x + 0.5, 0.0);
  rgb[3u * _om7 + 1u] = _oaw(_oal.y + 0.5, 0.0);
  rgb[3u * _om7 + 2u] = _oaw(_oal.z + 0.5, 0.0);
}
