struct _o1n {
  _on5: vec2u,
  _o9f: vec2u,
};
@group(0) @binding(0) var<storage, read> _ocw: array<f32>;
@group(0) @binding(1) var<uniform> _oit: _o1n;
@vertex
fn present_vertex(@builtin(vertex_index) _od2: u32) -> @builtin(position) vec4f {
  let x = f32((_od2 << 1u) & 2u) * 2.0 - 1.0;
  let y = f32(_od2 & 2u) * 2.0 - 1.0;
  return vec4f(x, y, 0.0, 1.0);
}
fn _ooz(x: u32, y: u32) -> vec3f {
  let _oij = _oit._on5.x * _oit._on5.y;
  let _oia = y * _oit._on5.x + x;
  return vec3f(_ocw[_oia], _ocw[_oij + _oia], _ocw[2u * _oij + _oia]);
}
@fragment
fn present_fragment(@builtin(position) position: vec4f) -> @location(0) vec4f {
  var rgb: vec3f;
  if (all(_oit._on5 == _oit._o9f)) {
    rgb = _ooz(min(u32(position.x), _oit._on5.x - 1u), min(u32(position.y), _oit._on5.y - 1u));
  } else {
    let _ola = vec2f(_oit._on5) / vec2f(_oit._o9f);
    let _ohn = max(position.xy * _ola - 0.5, vec2f(0.0));
    let _ocr = vec2u(_ohn);
    let _oaa = _ohn - vec2f(_ocr);
    let _oct = min(_ocr + 1u, _oit._on5 - 1u);
    let _ocs = min(_ocr, _oit._on5 - 1u);
    let a = mix(_ooz(_ocs.x, _ocs.y), _ooz(_oct.x, _ocs.y), _oaa.x);
    let b = mix(_ooz(_ocs.x, _oct.y), _ooz(_oct.x, _oct.y), _oaa.x);
    rgb = mix(a, b, _oaa.y);
  }
  return vec4f(clamp(rgb, vec3f(0.0), vec3f(1.0)), 1.0);
}
