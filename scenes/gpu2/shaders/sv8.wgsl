@group(0) @binding(0) var<storage, read> _oe7: array<u32>;
@group(0) @binding(1) var<storage, read> _op6: array<u32>;
@group(0) @binding(2) var<storage, read> _o9w: array<f32>;
@group(0) @binding(3) var<storage, read> _onx: array<f32>;
@group(0) @binding(4) var<storage, read> _onv: array<f32>;
@group(0) @binding(5) var<storage, read> _onw: array<f32>;
@group(0) @binding(6) var<storage, read> _o7l: array<u32>;
@group(0) @binding(7) var<storage, read_write> rgb: array<f32>;
@group(0) @binding(8) var<uniform> _o5o: _oo;
const _o1s: u32 = 8u;
const _o1r: f32 = 1e-12;
@compute @workgroup_size(256)
fn sv8_color(@builtin(local_invocation_index) _oex: u32,
             @builtin(workgroup_id) _orb: vec3u,
             @builtin(num_workgroups) _ogm: vec3u) {
  let _om6 = _of2(_orb, _ogm) * _o2h + _oex;
  if (_om6 >= _o7l[_o1u]) {
    return;
  }
  if (_o5o._o8t == 0u && _op6[_om6] == 0u) {
    return;
  }
  let _ol1 = _oe7[_om6];
  let _ohm = 6u * _ol1;
  let _ofu = 0.5 * (_o9w[_ohm] + _o9w[_ohm + 3u]);
  let _ofv = 0.5 * (_o9w[_ohm + 1u] + _o9w[_ohm + 4u]);
  let _ofw = 0.5 * (_o9w[_ohm + 2u] + _o9w[_ohm + 5u]);
  let _oqx = _ofu - _o5o._o5r.x;
  let _oqy = _ofv - _o5o._o5r.y;
  let _oqz = _ofw - _o5o._o5r.z;
  let _oqr = sqrt(_oqx * _oqx + _oqy * _oqy + _oqz * _oqz);
  let _oqs = 1.0 / _oqr;
  let _o9j = _oqx * _oqs;
  let _o9k = _oqy * _oqs;
  let _o9l = _oqz * _oqs;
  var _or8: array<f32, 8>;
  var _ofj = -1.0e30;
  for (var _odw = 0u; _odw < _o1s; _odw = _odw + 1u) {
    let _ol9 = 3u * (_ol1 * _o1s + _odw);
    let _oo0 = _onx[_ol9];
    let _oo3 = _onx[_ol9 + 1u];
    let _oo4 = _onx[_ol9 + 2u];
    let _omi = sqrt(_oo0 * _oo0 + _oo3 * _oo3 + _oo4 * _oo4);
    let _omj = 1.0 / _oav(_omi, _o1r);
    let _oa1 = _oo0 * _omj - _o9j;
    let _oa7 = _oo3 * _omj - _o9k;
    let _oa8 = _oo4 * _omj - _o9l;
    let _on3 = _oa1 * _oa1 + _oa7 * _oa7 + _oa8 * _oa8;
    let distance = sqrt(_on3);
    let _of9 = -exp(_onw[_ol1 * _o1s + _odw]) * distance;
    _or8[_odw] = _of9;
    _ofj = _oav(_ofj, _of9);
  }
  var _or9 = 0.0;
  for (var _odw = 0u; _odw < _o1s; _odw = _odw + 1u) {
    let _oqh = exp(_or8[_odw] - _ofj);
    _or8[_odw] = _oqh;
    _or9 = _or9 + _oqh;
  }
  let _odg = 1.0 / _or9;
  var _oak = vec3f(0.0);
  for (var _odw = 0u; _odw < _o1s; _odw = _odw + 1u) {
    let w = _or8[_odw] * _odg;
    let _o4z = 3u * (_ol1 * _o1s + _odw);
    _oak.x = _oak.x + w * _onv[_o4z];
    _oak.y = _oak.y + w * _onv[_o4z + 1u];
    _oak.z = _oak.z + w * _onv[_o4z + 2u];
  }
  rgb[3u * _om6] = _oav(_oak.x + 0.5, 0.0);
  rgb[3u * _om6 + 1u] = _oav(_oak.y + 0.5, 0.0);
  rgb[3u * _om6 + 2u] = _oav(_oak.z + 0.5, 0.0);
}
