struct _o1b {
  _oe6: u32,
  _oi3: u32,
  _o5t: u32,
  _ohx: u32,
};
@group(0) @binding(0) var<storage, read_write> _ob4: array<u32>;
@group(0) @binding(1) var<storage, read_write> _ob3: array<u32>;
@group(0) @binding(2) var<storage, read> _ob5: array<u32>;
@group(0) @binding(3) var<uniform> _ob6: _o1b;
@group(0) @binding(0) var<storage, read> _oms: array<u32>;
@group(0) @binding(1) var<storage, read> _ok1: array<u32>;
@group(0) @binding(2) var<storage, read_write> _ok4: array<u32>;
fn _obt(_obu: u32) -> vec3u {
  if (_obu <= 65535u) {
    return vec3u(_obu, 1u, 1u);
  }
  return vec3u(32768u, (_obu + 32767u) / 32768u, 1u);
}
@compute @workgroup_size(1)
fn args_after_compaction() {
  let _oe5 = _ob4[_o1u];
  let _obr = _obt((_oe5 + _o2h - 1u) / _o2h);
  _ob3[_ob6._oe6] = _obr.x;
  _ob3[_ob6._oe6 + 1u] = _obr.y;
  _ob3[_ob6._oe6 + 2u] = _obr.z;
}
@compute @workgroup_size(1)
fn args_after_scan() {
  let _oe5 = _ob4[_o1u];
  let _oka = _ob5[_oe5 - 1u];
  let _oi5 = min(_oka, _ob6._o5t);
  let _obu = (_oi5 + _o2h - 1u) / _o2h;
  _ob4[_o1w] = _oka;
  _ob4[_o1v] = _oi5;
  _ob4[_o20] = _obu;
  _ob4[_o1z] = 16u * _obu;
  let _obr = _obt(_obu);
  _ob3[_ob6._oi3] = _obr.x;
  _ob3[_ob6._oi3 + 1u] = _obr.y;
  _ob3[_ob6._oi3 + 2u] = _obr.z;
}
@compute @workgroup_size(256)
fn tile_ranges(@builtin(local_invocation_index) _oex: u32,
               @builtin(workgroup_id) _orb: vec3u,
               @builtin(num_workgroups) _ogm: vec3u) {
  let _oct = _of2(_orb, _ogm) * _o2h + _oex;
  let _o7g = _ok1[_o1v];
  if (_oct >= _o7g) {
    return;
  }
  let _o7r = _oms[_oct];
  if (_oct == 0u) {
    _ok4[2u * _o7r] = 0u;
  } else {
    let _oiv = _oms[_oct - 1u];
    if (_o7r != _oiv) {
      _ok4[2u * _oiv + 1u] = _oct;
      _ok4[2u * _o7r] = _oct;
    }
  }
  if (_oct == _o7g - 1u) {
    _ok4[2u * _o7r + 1u] = _o7g;
  }
}
