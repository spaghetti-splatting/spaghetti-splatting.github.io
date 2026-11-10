struct _oz {
  _oqn: u32,
  _ohy: u32,
  _ohz: u32,
  _oi0: u32,
};
@group(0) @binding(0) var<uniform> _o9b: _oz;
@group(0) @binding(1) var<storage, read> _ol3: array<u32>;
@group(0) @binding(2) var<storage, read> _orp: array<vec4f>;
@group(0) @binding(3) var<storage, read> _okn: array<vec4f>;
@group(0) @binding(4) var<storage, read> _oq5: array<f32>;
@group(0) @binding(5) var<storage, read_write> _oq4: array<f32>;
@group(0) @binding(6) var<storage, read> _oml: array<f32>;
@group(0) @binding(7) var<storage, read_write> _omk: array<f32>;
@group(0) @binding(8) var<storage, read_write> _o9w: array<f32>;
fn _ojm(a: vec4f, b: vec4f) -> vec4f {
  let _o3i = a.yzw;
  let _o4v = b.yzw;
  let _oqc = a.x * _o4v + b.x * _o3i + cross(_o3i, _o4v);
  return vec4f(a.x * b.x - dot(_o3i, _o4v), _oqc);
}
fn _ojn(_ojb: vec4f, _ol9: vec3f) -> vec3f {
  let _oo5 = 2.0 * cross(_ojb.yzw, _ol9);
  return _ol9 + _ojb.x * _oo5 + cross(_ojb.yzw, _oo5);
}
@compute @workgroup_size(256)
fn deform(@builtin(global_invocation_id) _obl: vec3u, @builtin(num_workgroups) _ogm: vec3u) {
  let _ocq = _obl.x + _obl.y * _ogm.x * 256u;
  if (_ocq >= _o9b._oqn) {
    return;
  }
  let _ol1 = _ol3[_ocq];
  if (_ol1 == 0xffffffffu) {
    return;
  }
  let a = _orp[_ocq - 1u].xyz;
  let b = _orp[_ocq].xyz;
  let ra = _okn[_ocq - 1u].xyz;
  let rb = _okn[_ocq].xyz;
  let _o4z = b - a;
  let _o50 = rb - ra;
  let _o9m = 6u * _ol1;
  _o9w[_o9m] = a.x;
  _o9w[_o9m + 1u] = a.y;
  _o9w[_o9m + 2u] = a.z;
  _o9w[_o9m + 3u] = b.x;
  _o9w[_o9m + 4u] = b.y;
  _o9w[_o9m + 5u] = b.z;
  let _opr = 8u * _ol1;
  let _on5 = 24u * _ol1;
  if (all(_o4z == _o50)) {
    for (var _odw = 0u; _odw < 4u; _odw = _odw + 1u) {
      _oq4[_opr + _odw] = _oq5[_opr + _odw];
    }
    for (var _odw = 0u; _odw < 24u; _odw = _odw + 1u) {
      _omk[_on5 + _odw] = _oml[_on5 + _odw];
    }
    return;
  }
  let _og7 = normalize(_o50);
  let _og8 = normalize(_o4z);
  let _o7z = dot(_og7, _og8);
  var _ojb: vec4f;
  if (_o7z < -0.999999) {
    var _o3n = cross(_og7, vec3f(1.0, 0.0, 0.0));
    if (dot(_o3n, _o3n) < 1.0e-6) {
      _o3n = cross(_og7, vec3f(0.0, 1.0, 0.0));
    }
    _ojb = vec4f(0.0, normalize(_o3n));
  } else {
    _ojb = normalize(vec4f(1.0 + _o7z, cross(_og7, _og8)));
  }
  let _ojg = vec4f(_oq5[_opr], _oq5[_opr + 1u], _oq5[_opr + 2u], _oq5[_opr + 3u]);
  let _ojf = normalize(_ojm(_ojb, _ojg));
  _oq4[_opr] = _ojf.x;
  _oq4[_opr + 1u] = _ojf.y;
  _oq4[_opr + 2u] = _ojf.z;
  _oq4[_opr + 3u] = _ojf.w;
  for (var _odw = 0u; _odw < 8u; _odw = _odw + 1u) {
    let _ogq = _on5 + 3u * _odw;
    let _ol9 = _ojn(_ojb, vec3f(_oml[_ogq], _oml[_ogq + 1u], _oml[_ogq + 2u]));
    _omk[_ogq] = _ol9.x;
    _omk[_ogq + 1u] = _ol9.y;
    _omk[_ogq + 2u] = _ol9.z;
  }
}
