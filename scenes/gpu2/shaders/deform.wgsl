struct _oz {
  _oqo: u32,
  _ohz: u32,
  _oi0: u32,
  _oi1: u32,
};
@group(0) @binding(0) var<uniform> _o9c: _oz;
@group(0) @binding(1) var<storage, read> _ol4: array<u32>;
@group(0) @binding(2) var<storage, read> _orq: array<vec4f>;
@group(0) @binding(3) var<storage, read> _oko: array<vec4f>;
@group(0) @binding(4) var<storage, read> _oq6: array<f32>;
@group(0) @binding(5) var<storage, read_write> _oq5: array<f32>;
@group(0) @binding(6) var<storage, read> _omm: array<f32>;
@group(0) @binding(7) var<storage, read_write> _oml: array<f32>;
@group(0) @binding(8) var<storage, read_write> _o9x: array<f32>;
fn _ojn(a: vec4f, b: vec4f) -> vec4f {
  let _o3i = a.yzw;
  let _o4v = b.yzw;
  let _oqd = a.x * _o4v + b.x * _o3i + cross(_o3i, _o4v);
  return vec4f(a.x * b.x - dot(_o3i, _o4v), _oqd);
}
fn _ojo(_ojc: vec4f, _ola: vec3f) -> vec3f {
  let _oo6 = 2.0 * cross(_ojc.yzw, _ola);
  return _ola + _ojc.x * _oo6 + cross(_ojc.yzw, _oo6);
}
@compute @workgroup_size(256)
fn deform(@builtin(global_invocation_id) _obm: vec3u, @builtin(num_workgroups) _ogn: vec3u) {
  let _ocr = _obm.x + _obm.y * _ogn.x * 256u;
  if (_ocr >= _o9c._oqo) {
    return;
  }
  let _ol2 = _ol4[_ocr];
  if (_ol2 == 0xffffffffu) {
    return;
  }
  let a = _orq[_ocr - 1u].xyz;
  let b = _orq[_ocr].xyz;
  let ra = _oko[_ocr - 1u].xyz;
  let rb = _oko[_ocr].xyz;
  let _o4z = b - a;
  let _o50 = rb - ra;
  let _o9n = 6u * _ol2;
  _o9x[_o9n] = a.x;
  _o9x[_o9n + 1u] = a.y;
  _o9x[_o9n + 2u] = a.z;
  _o9x[_o9n + 3u] = b.x;
  _o9x[_o9n + 4u] = b.y;
  _o9x[_o9n + 5u] = b.z;
  let _ops = 8u * _ol2;
  let _on6 = 24u * _ol2;
  if (all(_o4z == _o50)) {
    for (var _odx = 0u; _odx < 4u; _odx = _odx + 1u) {
      _oq5[_ops + _odx] = _oq6[_ops + _odx];
    }
    for (var _odx = 0u; _odx < 24u; _odx = _odx + 1u) {
      _oml[_on6 + _odx] = _omm[_on6 + _odx];
    }
    return;
  }
  let _og8 = normalize(_o50);
  let _og9 = normalize(_o4z);
  let _o80 = dot(_og8, _og9);
  var _ojc: vec4f;
  if (_o80 < -0.999999) {
    var _o3n = cross(_og8, vec3f(1.0, 0.0, 0.0));
    if (dot(_o3n, _o3n) < 1.0e-6) {
      _o3n = cross(_og8, vec3f(0.0, 1.0, 0.0));
    }
    _ojc = vec4f(0.0, normalize(_o3n));
  } else {
    _ojc = normalize(vec4f(1.0 + _o80, cross(_og8, _og9)));
  }
  let _ojh = vec4f(_oq6[_ops], _oq6[_ops + 1u], _oq6[_ops + 2u], _oq6[_ops + 3u]);
  let _ojg = normalize(_ojn(_ojc, _ojh));
  _oq5[_ops] = _ojg.x;
  _oq5[_ops + 1u] = _ojg.y;
  _oq5[_ops + 2u] = _ojg.z;
  _oq5[_ops + 3u] = _ojg.w;
  for (var _odx = 0u; _odx < 8u; _odx = _odx + 1u) {
    let _ogr = _on6 + 3u * _odx;
    let _ola = _ojo(_ojc, vec3f(_omm[_ogr], _omm[_ogr + 1u], _omm[_ogr + 2u]));
    _oml[_ogr] = _ola.x;
    _oml[_ogr + 1u] = _ola.y;
    _oml[_ogr + 2u] = _ola.z;
  }
}
