@group(0) @binding(0) var<storage, read> _ofq: array<u32>;
@group(0) @binding(1) var<storage, read> _ora: array<u32>;
@group(0) @binding(2) var<storage, read> _oau: array<f32>;
@group(0) @binding(3) var<storage, read> _oq0: array<f32>;
@group(0) @binding(4) var<storage, read> _opy: array<f32>;
@group(0) @binding(5) var<storage, read> _opz: array<f32>;
@group(0) @binding(6) var<storage, read> _o8h: array<u32>;
@group(0) @binding(7) var<storage, read_write> rgb: array<f32>;
@group(0) @binding(8) var<uniform> _o69: _oo;
const _o21: u32 = 8u;
const _o20: f32 = 1e-12;
@compute @workgroup_size(256)
fn sv8_color(@builtin(local_invocation_index) _ogj: u32,
             @builtin(workgroup_id) _otg: vec3u,
             @builtin(num_workgroups) _oib: vec3u) {
  let _oo2 = _ogo(_otg, _oib) * _o2q + _ogj;
  if (_oo2 >= _o8h[_o23]) {
    return;
  }
  if (_o69._o9p == 0u && _ora[_oo2] == 0u) {
    return;
  }
  let _omw = _ofq[_oo2];
  let _ojb = 6u * _omw;
  let _ohi = 0.5 * (_oau[_ojb] + _oau[_ojb + 3u]);
  let _ohj = 0.5 * (_oau[_ojb + 1u] + _oau[_ojb + 4u]);
  let _ohk = 0.5 * (_oau[_ojb + 2u] + _oau[_ojb + 5u]);
  let _ot2 = _ohi - _o69._o6c.x;
  let _ot3 = _ohj - _o69._o6c.y;
  let _ot4 = _ohk - _o69._o6c.z;
  let _osw = sqrt(_ot2 * _ot2 + _ot3 * _ot3 + _ot4 * _ot4);
  let _osx = 1.0 / _osw;
  let _oag = _ot2 * _osx;
  let _oah = _ot3 * _osx;
  let _oai = _ot4 * _osx;
  var _otd: array<f32, 8>;
  var _oh7 = -1.0e30;
  for (var _ofd = 0u; _ofd < _o21; _ofd = _ofd + 1u) {
    let _on4 = 3u * (_omw * _o21 + _ofd);
    let _oq3 = _oq0[_on4];
    let _oq6 = _oq0[_on4 + 1u];
    let _oq7 = _oq0[_on4 + 2u];
    let _oof = sqrt(_oq3 * _oq3 + _oq6 * _oq6 + _oq7 * _oq7);
    let _oog = 1.0 / _obu(_oof, _o20);
    let _oaz = _oq3 * _oog - _oag;
    let _ob5 = _oq6 * _oog - _oah;
    let _ob6 = _oq7 * _oog - _oai;
    let _op2 = _oaz * _oaz + _ob5 * _ob5 + _ob6 * _ob6;
    let distance = sqrt(_op2);
    let _ogv = -exp(_opz[_omw * _o21 + _ofd]) * distance;
    _otd[_ofd] = _ogv;
    _oh7 = _obu(_oh7, _ogv);
  }
  var _ote = 0.0;
  for (var _ofd = 0u; _ofd < _o21; _ofd = _ofd + 1u) {
    let _osm = exp(_otd[_ofd] - _oh7);
    _otd[_ofd] = _osm;
    _ote = _ote + _osm;
  }
  let _oex = 1.0 / _ote;
  var _obi = vec3f(0.0);
  for (var _ofd = 0u; _ofd < _o21; _ofd = _ofd + 1u) {
    let w = _otd[_ofd] * _oex;
    let _o5j = 3u * (_omw * _o21 + _ofd);
    _obi.x = _obi.x + w * _opy[_o5j];
    _obi.y = _obi.y + w * _opy[_o5j + 1u];
    _obi.z = _obi.z + w * _opy[_o5j + 2u];
  }
  rgb[3u * _oo2] = _obu(_obi.x + 0.5, 0.0);
  rgb[3u * _oo2 + 1u] = _obu(_obi.y + 0.5, 0.0);
  rgb[3u * _oo2 + 2u] = _obu(_obi.z + 0.5, 0.0);
}
