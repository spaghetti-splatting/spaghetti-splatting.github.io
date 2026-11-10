struct _o26 {
  _ood: u32,
  _ori: u32,
  _oc8: u32,
  _os9: u32,
  _oci: f32,
  _o8w: f32,
  _o9u: f32,
  _o4i: f32,
  _ook: f32,
  _ool: f32,
  _ooj: f32,
  _oo9: f32,
  _o7v: f32,
  _ogg: f32,
  _oq3: f32,
  _oce: f32,
  _o8y: vec4f,
  _os8: vec4f,
  _omv: vec4f,
  _omw: vec4u,
  _oc9: vec4f,
};
@group(0) @binding(0) var<uniform> _onp: _o26;
@group(0) @binding(1) var<storage, read> _ooc: array<u32>;
@group(0) @binding(2) var<storage, read> _old: array<vec4f>;
@group(0) @binding(3) var<storage, read_write> _o3l: array<vec4f>;
@group(0) @binding(4) var<storage, read_write> _oc7: array<vec4f>;
@group(0) @binding(5) var<storage, read_write> _osl: array<vec4f>;
@group(0) @binding(6) var<storage, read_write> _orq: array<vec4f>;
@group(0) @binding(7) var<storage, read> _omt: array<f32>;
@group(0) @binding(8) var<storage, read_write> _oo8: array<atomic<u32>>;
struct _o25 {
  _o8h: f32,
  g: vec3f,
};
fn _omu(_oic: vec3f) -> _o25 {
  var _ohw: _o25;
  let _ohd = _onp._omw.x;
  let _ohe = _onp._omw.y;
  let _ohf = _onp._omw.z;
  let _oar = (_oic - _onp._omv.xyz) * _onp._omv.w;
  if (_oar.x < 0.0 || _oar.y < 0.0 || _oar.z < 0.0 || _oar.x > f32(_ohd) - 1.001 || _oar.y > f32(_ohe) - 1.001
      || _oar.z > f32(_ohf) - 1.001) {
    _ohw._o8h = 1.0e6;
    _ohw.g = vec3f(0.0);
    return _ohw;
  }
  let _odc = u32(_oar.x);
  let _oe8 = u32(_oar.y);
  let _oei = u32(_oar.z);
  let _obs = _oar.x - f32(_odc);
  let _obt = _oar.y - f32(_oe8);
  let _obu = _oar.z - f32(_oei);
  let _ohg = (_odc * _ohe + _oe8) * _ohf + _oei;
  let _onf = _ohf;
  let _on4 = _ohe * _ohf;
  let _o59 = _omt[_ohg];
  let _o5a = _omt[_ohg + 1u];
  let _o5c = _omt[_ohg + _onf];
  let _o5d = _omt[_ohg + _onf + 1u];
  let _o5g = _omt[_ohg + _on4];
  let _o5h = _omt[_ohg + _on4 + 1u];
  let _o5j = _omt[_ohg + _on4 + _onf];
  let _o5k = _omt[_ohg + _on4 + _onf + 1u];
  let _o58 = _o59 + (_o5a - _o59) * _obu;
  let _o5b = _o5c + (_o5d - _o5c) * _obu;
  let _o5f = _o5g + (_o5h - _o5g) * _obu;
  let _o5i = _o5j + (_o5k - _o5j) * _obu;
  let _o57 = _o58 + (_o5b - _o58) * _obt;
  let _o5e = _o5f + (_o5i - _o5f) * _obt;
  let _ocf = _o5e - _o57;
  let _ocg = (1.0 - _obs) * (_o5b - _o58) + _obs * (_o5i - _o5f);
  let _oa5 = (_o5a - _o59) * (1.0 - _obt) + (_o5d - _o5c) * _obt;
  let _oa6 = (_o5h - _o5g) * (1.0 - _obt) + (_o5k - _o5j) * _obt;
  let _och = _oa5 * (1.0 - _obs) + _oa6 * _obs;
  let g = vec3f(_ocf, _ocg, _och);
  let _ogw = length(g);
  _ohw.g = select(vec3f(0.0), g / _ogw, _ogw > 0.0);
  _ohw._o8h = _o57 + (_o5e - _o57) * _obs;
  return _ohw;
}
fn _o9h(_odc: u32) -> vec3f {
  return _osl[_odc].xyz - _old[_odc].xyz;
}
fn _obh(_off: vec3f, _ok1: vec3f, _ole: vec3f, _ofg: f32) -> vec3f {
  var _oa4 = _ok1 - _off;
  var _ogw = length(_oa4);
  if (_ogw < 1.0e-12) {
    _oa4 = _ole;
    _ogw = length(_oa4);
  }
  return _off + _oa4 * (_ofg / _ogw);
}
fn _o3k(_oni: u32, _orc: f32) {
  atomicMax(&_oo8[_oni], bitcast<u32>(max(_orc, 0.0)));
}
@compute @workgroup_size(64)
fn substep(@builtin(global_invocation_id) _oc4: vec3u, @builtin(num_workgroups) _ohc: vec3u) {
  let _olz = _oc4.x + _oc4.y * _ohc.x * 64u;
  if (_olz >= _onp._ood) {
    return;
  }
  let _o45 = _ooc[_olz];
  let _ogw = _ooc[_olz + 1u] - _o45;
  if (_ogw < 2u) {
    return;
  }
  let _oci = _onp._oci;
  let _oeq = _onp._o4i;
  let _o4p = _onp._oo9;
  let _o8u = 2.0 * sqrt(_o4p);
  let _odg = 1.0 / _oci;
  let _o6b = _onp._o7v / _oci;
  _osl[_o45] = vec4f(_old[_o45].xyz, 0.0);
  _orq[_o45] = vec4f(0.0);
  var _os8 = vec3f(0.0);
  if (_onp._os9 != 0u) {
    let _obr = f32(_olz);
    let _oce = 0.6 + 0.4 * sin(2.3 * _onp._oq3 + 0.0007 * _obr) + 0.25 * sin(5.1 * _onp._oq3 + 0.0013 * _obr);
    _os8 = _onp._os8.xyz * _oce;
  }
  var _oqw = vec3f(0.0);
  var _oqv = vec3f(0.0);
  var _oqn = vec3f(0.0);
  var _or2 = _o9h(_o45 + 1u);
  var _or3 = vec3f(0.0);
  if (_ogw > 2u) {
    _or3 = _o9h(_o45 + 2u);
  }
  var _ofe = _old[_o45].xyz;
  var _ojj = _ofe;
  var _ojk = _ofe;
  var _oga = 0.0;
  var _og9 = 0.0;
  let _ofd = _ogw - 1u;
  for (var _oei = 1u; _oei < _ogw; _oei = _oei + 1u) {
    _oqw = _oqv;
    _oqv = _oqn;
    _oqn = _or2;
    _or2 = _or3;
    if (_oei + 2u < _ogw) {
      _or3 = _o9h(_o45 + _oei + 2u);
    } else {
      _or3 = vec3f(0.0);
    }
    let _odc = _o45 + _oei;
    let x = _osl[_odc].xyz;
    let _or7 = _orq[_odc].xyz;
    let _okk = _old[_odc];
    let _o3o = _o3l[_odc];
    let _o9l = select(vec3f(0.0), _oqw - 2.0 * _oqv + _oqn, _oei >= 2u);
    let _o9k = select(vec3f(0.0), _oqv - 2.0 * _oqn + _or2, _oei <= _ogw - 2u);
    let _o9m = select(vec3f(0.0), _oqn - 2.0 * _or2 + _or3, _oei + 1u <= _ogw - 2u);
    let _o4h = -_o9l + 2.0 * _o9k - _o9m;
    let _ooa = _onp._ool + (_onp._ook - _onp._ool) * exp(-_okk.w / _onp._ooj);
    var a = -_ooa * _oqn + _oeq * _o4h + _onp._o9u * (_os8 - _or7);
    let w = _o3o.z;
    if (_onp._oc8 != 0u && w > 0.0) {
      let _oc5 = _oc7[_odc].xyz + _o3o.w * _onp._o8y.xyz;
      a = a + w * (_o4p * (_oc5 - x) - _o8u * _or7);
    }
    let _org = (_or7 + _oci * a) * _onp._o8w;
    let _oid = x + _oci * _org;
    let _olf = _o3o.x;
    let _o9n = _o3o.y;
    let _ole = _okk.xyz - _old[_odc - 1u].xyz;
    var _ok1 = _obh(_ofe, _oid, _ole, _olf);
    for (var _oe7 = 0u; _oe7 < 2u; _oe7 = _oe7 + 1u) {
      let _onk = _omu(_ok1);
      if (!(_onk._o8h < _o9n)) {
        break;
      }
      _ok1 = _ok1 + (_o9n - _onk._o8h) * _onk.g;
      _ok1 = _obh(_ofe, _ok1, _ole, _olf);
    }
    let _o8h = _ok1 - _oid;
    if (_oei >= 2u) {
      let _oe8 = _odc - 1u;
      let _oro = (_ojj - _ojk) * _odg - _o6b * _o8h;
      _orq[_oe8] = vec4f(_oro, 0.0);
      _osl[_oe8] = vec4f(_ojj, 0.0);
      _oga = max(_oga, dot(_oro, _oro));
      let _oqu = _ojj - _old[_oe8].xyz;
      _og9 = max(_og9, dot(_oqu, _oqu));
    }
    _ojj = _ok1;
    _ojk = x;
    _ofe = _ok1;
    if (_oei == _ofd) {
      let _orr = (_ok1 - x) * _odg;
      _orq[_odc] = vec4f(_orr, 0.0);
      _osl[_odc] = vec4f(_ok1, 0.0);
      _oga = max(_oga, dot(_orr, _orr));
      let _or6 = _ok1 - _okk.xyz;
      _og9 = max(_og9, dot(_or6, _or6));
    }
  }
  _o3k(0u, _oga);
  _o3k(1u, _og9);
}
@compute @workgroup_size(64)
fn grab_begin(@builtin(global_invocation_id) _oc4: vec3u, @builtin(num_workgroups) _ohc: vec3u) {
  let _olz = _oc4.x + _oc4.y * _ohc.x * 64u;
  if (_olz >= _onp._ood) {
    return;
  }
  let _o45 = _ooc[_olz];
  let _ogw = _ooc[_olz + 1u] - _o45;
  let _oko = _onp._oc9.w;
  let _o68 = _onp._oc9.xyz;
  var _o4j = _oko;
  var _oeq = 0u;
  for (var _oei = 1u; _oei < _ogw; _oei = _oei + 1u) {
    let _o8v = length(_osl[_o45 + _oei].xyz - _o68);
    if (_o8v < _o4j) {
      _o4j = _o8v;
      _oeq = _oei;
    }
  }
  let _on7 = 0.5 * _oko * _oko;
  let _orv = exp(-_o4j * _o4j / _on7);
  let _o3g = max(_old[_o45 + _oeq].w, 1.0e-9);
  for (var _oei = 0u; _oei < _ogw; _oei = _oei + 1u) {
    let _odc = _o45 + _oei;
    var _o3o = _o3l[_odc];
    if (_oeq > 0u && _oei >= 1u && _oei <= _oeq) {
      _o3o.z = _orv;
      _o3o.w = pow(min(_old[_odc].w / _o3g, 1.0), 1.5);
      _oc7[_odc] = _osl[_odc];
    } else {
      _o3o.z = 0.0;
      _o3o.w = 0.0;
    }
    _o3l[_odc] = _o3o;
  }
  if (_oeq > 0u) {
    atomicAdd(&_oo8[2], 1u);
  }
}
@compute @workgroup_size(256)
fn reset_state(@builtin(global_invocation_id) _oc4: vec3u, @builtin(num_workgroups) _ohc: vec3u) {
  let _odc = _oc4.x + _oc4.y * _ohc.x * 256u;
  if (_odc >= _onp._ori) {
    return;
  }
  _osl[_odc] = vec4f(_old[_odc].xyz, 0.0);
  _orq[_odc] = vec4f(0.0);
  var _o3o = _o3l[_odc];
  _o3o.z = 0.0;
  _o3o.w = 0.0;
  _o3l[_odc] = _o3o;
}
