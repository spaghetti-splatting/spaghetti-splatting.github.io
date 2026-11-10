struct _o1d {
  _oeu: u32,
  _oit: u32,
  _o60: u32,
  _oin: u32,
};
@group(0) @binding(0) var<storage, read_write> _obn: array<u32>;
@group(0) @binding(1) var<storage, read_write> _obm: array<u32>;
@group(0) @binding(2) var<storage, read> _obo: array<u32>;
@group(0) @binding(3) var<uniform> _obp: _o1d;
@group(0) @binding(0) var<storage, read> _onl: array<u32>;
@group(0) @binding(1) var<storage, read> _okr: array<u32>;
@group(0) @binding(2) var<storage, read_write> _oku: array<u32>;
fn _occ(_ocd: u32) -> vec3u {
  if (_ocd <= 65535u) {
    return vec3u(_ocd, 1u, 1u);
  }
  return vec3u(32768u, (_ocd + 32767u) / 32768u, 1u);
}
@compute @workgroup_size(1)
fn args_after_compaction() {
  let _oet = _obn[_o1w];
  let _oca = _occ((_oet + _o2j - 1u) / _o2j);
  _obm[_obp._oeu] = _oca.x;
  _obm[_obp._oeu + 1u] = _oca.y;
  _obm[_obp._oeu + 2u] = _oca.z;
}
@compute @workgroup_size(1)
fn args_after_scan() {
  let _oet = _obn[_o1w];
  let _ol0 = _obo[_oet - 1u];
  let _oiv = min(_ol0, _obp._o60);
  let _ocd = (_oiv + _o2j - 1u) / _o2j;
  _obn[_o1y] = _ol0;
  _obn[_o1x] = _oiv;
  _obn[_o22] = _ocd;
  _obn[_o21] = 16u * _ocd;
  let _oca = _occ(_ocd);
  _obm[_obp._oit] = _oca.x;
  _obm[_obp._oit + 1u] = _oca.y;
  _obm[_obp._oit + 2u] = _oca.z;
}
@compute @workgroup_size(256)
fn tile_ranges(@builtin(local_invocation_index) _ofl: u32,
               @builtin(workgroup_id) _os6: vec3u,
               @builtin(num_workgroups) _ohc: vec3u) {
  let _odf = _ofq(_os6, _ohc) * _o2j + _ofl;
  let _o7y = _okr[_o1x];
  if (_odf >= _o7y) {
    return;
  }
  let _o89 = _onl[_odf];
  if (_odf == 0u) {
    _oku[2u * _o89] = 0u;
  } else {
    let _ojl = _onl[_odf - 1u];
    if (_o89 != _ojl) {
      _oku[2u * _ojl + 1u] = _odf;
      _oku[2u * _o89] = _odf;
    }
  }
  if (_odf == _o7y - 1u) {
    _oku[2u * _o89 + 1u] = _o7y;
  }
}
