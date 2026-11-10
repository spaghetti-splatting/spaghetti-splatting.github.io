struct _o11 {
  _ori: u32,
  _oio: u32,
  _oip: u32,
  _oiq: u32,
};
@group(0) @binding(0) var<uniform> _o9t: _o11;
@group(0) @binding(1) var<storage, read> _olt: array<u32>;
@group(0) @binding(2) var<storage, read> _osl: array<vec4f>;
@group(0) @binding(3) var<storage, read> _old: array<vec4f>;
@group(0) @binding(4) var<storage, read> _or0: array<f32>;
@group(0) @binding(5) var<storage, read_write> _oqz: array<f32>;
@group(0) @binding(6) var<storage, read> _ond: array<f32>;
@group(0) @binding(7) var<storage, read_write> _onc: array<f32>;
@group(0) @binding(8) var<storage, read_write> _oae: array<f32>;
fn _okc(a: vec4f, b: vec4f) -> vec4f {
  let _o3m = a.yzw;
  let _o52 = b.yzw;
  let _or7 = a.x * _o52 + b.x * _o3m + cross(_o3m, _o52);
  return vec4f(a.x * b.x - dot(_o3m, _o52), _or7);
}
fn _okd(_ok1: vec4f, _olz: vec3f) -> vec3f {
  let _ooz = 2.0 * cross(_ok1.yzw, _olz);
  return _olz + _ok1.x * _ooz + cross(_ok1.yzw, _ooz);
}
@compute @workgroup_size(256)
fn deform(@builtin(global_invocation_id) _oc4: vec3u, @builtin(num_workgroups) _ohc: vec3u) {
  let _odc = _oc4.x + _oc4.y * _ohc.x * 256u;
  if (_odc >= _o9t._ori) {
    return;
  }
  let _olr = _olt[_odc];
  if (_olr == 0xffffffffu) {
    return;
  }
  let a = _osl[_odc - 1u].xyz;
  let b = _osl[_odc].xyz;
  let ra = _old[_odc - 1u].xyz;
  let rb = _old[_odc].xyz;
  let _o56 = b - a;
  let _o57 = rb - ra;
  let _oa4 = 6u * _olr;
  _oae[_oa4] = a.x;
  _oae[_oa4 + 1u] = a.y;
  _oae[_oa4 + 2u] = a.z;
  _oae[_oa4 + 3u] = b.x;
  _oae[_oa4 + 4u] = b.y;
  _oae[_oa4 + 5u] = b.z;
  let _oqm = 8u * _olr;
  let _ony = 24u * _olr;
  if (all(_o56 == _o57)) {
    for (var _oei = 0u; _oei < 4u; _oei = _oei + 1u) {
      _oqz[_oqm + _oei] = _or0[_oqm + _oei];
    }
    for (var _oei = 0u; _oei < 24u; _oei = _oei + 1u) {
      _onc[_ony + _oei] = _ond[_ony + _oei];
    }
    return;
  }
  let _ogx = normalize(_o57);
  let _ogy = normalize(_o56);
  let _o8h = dot(_ogx, _ogy);
  var _ok1: vec4f;
  if (_o8h < -0.999999) {
    var _o3r = cross(_ogx, vec3f(1.0, 0.0, 0.0));
    if (dot(_o3r, _o3r) < 1.0e-6) {
      _o3r = cross(_ogx, vec3f(0.0, 1.0, 0.0));
    }
    _ok1 = vec4f(0.0, normalize(_o3r));
  } else {
    _ok1 = normalize(vec4f(1.0 + _o8h, cross(_ogx, _ogy)));
  }
  let _ok6 = vec4f(_or0[_oqm], _or0[_oqm + 1u], _or0[_oqm + 2u], _or0[_oqm + 3u]);
  let _ok5 = normalize(_okc(_ok1, _ok6));
  _oqz[_oqm] = _ok5.x;
  _oqz[_oqm + 1u] = _ok5.y;
  _oqz[_oqm + 2u] = _ok5.z;
  _oqz[_oqm + 3u] = _ok5.w;
  for (var _oei = 0u; _oei < 8u; _oei = _oei + 1u) {
    let _ohg = _ony + 3u * _oei;
    let _olz = _okd(_ok1, vec3f(_ond[_ohg], _ond[_ohg + 1u], _ond[_ohg + 2u]));
    _onc[_ohg] = _olz.x;
    _onc[_ohg + 1u] = _olz.y;
    _onc[_ohg + 2u] = _olz.z;
  }
}
