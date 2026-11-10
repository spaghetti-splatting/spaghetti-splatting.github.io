struct _o1b {
  _oe7: u32,
  _oi4: u32,
  _o5t: u32,
  _ohy: u32,
};
@group(0) @binding(0) var<storage, read_write> _ob5: array<u32>;
@group(0) @binding(1) var<storage, read_write> _ob4: array<u32>;
@group(0) @binding(2) var<storage, read> _ob6: array<u32>;
@group(0) @binding(3) var<uniform> _ob7: _o1b;
@group(0) @binding(0) var<storage, read> _omt: array<u32>;
@group(0) @binding(1) var<storage, read> _ok2: array<u32>;
@group(0) @binding(2) var<storage, read_write> _ok5: array<u32>;
fn _obu(_obv: u32) -> vec3u {
  if (_obv <= 65535u) {
    return vec3u(_obv, 1u, 1u);
  }
  return vec3u(32768u, (_obv + 32767u) / 32768u, 1u);
}
@compute @workgroup_size(1)
fn args_after_compaction() {
  let _oe6 = _ob5[_o1u];
  let _obs = _obu((_oe6 + _o2h - 1u) / _o2h);
  _ob4[_ob7._oe7] = _obs.x;
  _ob4[_ob7._oe7 + 1u] = _obs.y;
  _ob4[_ob7._oe7 + 2u] = _obs.z;
}
@compute @workgroup_size(1)
fn args_after_scan() {
  let _oe6 = _ob5[_o1u];
  let _okb = _ob6[_oe6 - 1u];
  let _oi6 = min(_okb, _ob7._o5t);
  let _obv = (_oi6 + _o2h - 1u) / _o2h;
  _ob5[_o1w] = _okb;
  _ob5[_o1v] = _oi6;
  _ob5[_o20] = _obv;
  _ob5[_o1z] = 16u * _obv;
  let _obs = _obu(_obv);
  _ob4[_ob7._oi4] = _obs.x;
  _ob4[_ob7._oi4 + 1u] = _obs.y;
  _ob4[_ob7._oi4 + 2u] = _obs.z;
}
@compute @workgroup_size(256)
fn tile_ranges(@builtin(local_invocation_index) _oey: u32,
               @builtin(workgroup_id) _orc: vec3u,
               @builtin(num_workgroups) _ogn: vec3u) {
  let _ocu = _of3(_orc, _ogn) * _o2h + _oey;
  let _o7h = _ok2[_o1v];
  if (_ocu >= _o7h) {
    return;
  }
  let _o7s = _omt[_ocu];
  if (_ocu == 0u) {
    _ok5[2u * _o7s] = 0u;
  } else {
    let _oiw = _omt[_ocu - 1u];
    if (_o7s != _oiw) {
      _ok5[2u * _oiw + 1u] = _ocu;
      _ok5[2u * _o7s] = _ocu;
    }
  }
  if (_ocu == _o7h - 1u) {
    _ok5[2u * _o7s + 1u] = _o7h;
  }
}
