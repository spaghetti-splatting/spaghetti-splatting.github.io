struct _or {
  position: vec4f,
  _o3n: vec4f,
  _ois: vec4f,
};
struct _os {
  _okw: vec4f,
  _o9b: vec4f,
  _ob2: vec4f,
  _o5r: vec4f,
  _oop: vec2f,
  size: vec2f,
  _odr: vec2f,
  _orw: f32,
  _ob3: u32,
  _o3x: vec4f,
  _ojz: f32,
  _olm: f32,
  _ori: f32,
  _ohy: f32,
  _of0: array<_or, 3>,
};
struct _ou {
  _ord: u32,
  _ocf: u32,
  _ob3: u32,
  _ohy: u32,
};
struct _ot {
  _on5: vec2u,
  _o9f: vec2u,
  _ob8: f32,
  _ohz: f32,
  _oi0: f32,
  _oi1: f32,
};
@group(0) @binding(0) var<uniform> _o6a: _os;
@group(0) @binding(1) var<storage, read> _o6k: array<u32>;
@group(0) @binding(2) var<storage, read> _o6b: array<f32>;
@group(0) @binding(3) var<storage, read> _o6j: array<f32>;
@group(0) @binding(9) var<storage, read> _o6h: array<f32>;
@group(0) @binding(4) var _o6i: texture_2d<f32>;
@group(0) @binding(5) var<storage, read_write> _o6n: array<f32>;
@group(0) @binding(6) var<uniform> _o6o: _ou;
@group(0) @binding(7) var<storage, read> _o6d: array<f32>;
@group(0) @binding(8) var<uniform> _o6g: _ot;
const _on: f32 = 3.0e38;
struct _ov {
  @builtin(position) _o6r: vec4f,
  @location(0) @interpolate(linear, sample) _oic: vec2f,
  @location(1) @interpolate(flat) _ofu: vec3f,
  @location(2) @interpolate(flat) _oc7: vec3f,
  @location(3) @interpolate(flat) _o35: vec3f,
  @location(4) @interpolate(flat) _opj: u32,
};
struct _oq {
  @location(0) _o72: vec4f,
  @builtin(frag_depth) _o8k: f32,
};
fn _o6q(_ohn: vec3f) -> vec3f {
  return vec3f(dot(_o6a._okw.xyz, _ohn), dot(_o6a._o9b.xyz, _ohn), dot(_o6a._ob2.xyz, _ohn));
}
fn _o6f(_oqd: vec3f) -> vec2f {
  let _ogb = vec2f(_oqd.x / (_oqd.z * _o6a._oop.x), _oqd.y / (_oqd.z * _o6a._oop.y));
  return (_ogb + 1.0) * 0.5 * _o6a.size;
}
fn _o6m(_o4z: vec3f) -> vec3f {
  let _ofb = _o4z / 12.92;
  let _oci = pow((_o4z + 0.055) / 1.055, vec3f(2.4));
  return select(_oci, _ofb, _o4z <= vec3f(0.04045));
}
fn _o6e(_o4z: vec3f) -> vec3f {
  let _ofb = _o4z * 12.92;
  let _oci = 1.055 * pow(_o4z, vec3f(1.0 / 2.4)) - 0.055;
  return select(_oci, _ofb, _o4z <= vec3f(0.0031308));
}
fn _o6c(x: u32) -> u32 {
  let _ona = x * 747796405u + 2891336453u;
  let _org = ((_ona >> ((_ona >> 28u) + 4u)) ^ _ona) * 277803737u;
  return (_org >> 22u) ^ _org;
}
@vertex
fn clay_vertex(@builtin(vertex_index) vertex: u32,
               @builtin(instance_index) _opj: u32) -> _ov {
  var _oh7: _ov;
  let _o9n = 6u * _o6k[_opj];
  let a = vec3f(_o6b[_o9n], _o6b[_o9n + 1u], _o6b[_o9n + 2u]);
  let b = vec3f(_o6b[_o9n + 3u], _o6b[_o9n + 4u], _o6b[_o9n + 5u]);
  let _ofu = _o6q(0.5 * (a + b) - _o6a._o5r.xyz);
  let _oc7 = _o6q(0.5 * (b - a));
  _oh7._ofu = _ofu;
  _oh7._oc7 = _oc7;
  _oh7._opj = _opj;
  let _o4z = clamp(vec3f(_o6j[3u * _opj], _o6j[3u * _opj + 1u], _o6j[3u * _opj + 2u]),
                vec3f(0.0), vec3f(1.0));
  let g = vec3f((_o4z.x + _o4z.y + _o4z.z) / 3.0);
  _oh7._o35 = _o6m(clamp(g + (_o4z - g) * _o6a._olm, vec3f(0.0), vec3f(1.0)));
  _oh7._oic = vec2f(0.0);
  _oh7._o6r = vec4f(2.0, 2.0, 2.0, 1.0);
  var _oho = _ofu - _oc7;
  var _ohp = _ofu + _oc7;
  let _ogd = _o6a._orw;
  if (max(_oho.z, _ohp.z) < _ogd) {
    return _oh7;
  }
  if (_oho.z < _ogd) {
    _oho = _oho + (_ohp - _oho) * ((_ogd - _oho.z) / (_ohp.z - _oho.z));
  }
  if (_ohp.z < _ogd) {
    _ohp = _ohp + (_oho - _ohp) * ((_ogd - _ohp.z) / (_oho.z - _ohp.z));
  }
  let _ojd = _o6f(_oho);
  let _oje = _o6f(_ohp);
  let _oay = 0.5 * _o6a.size.x / _o6a._oop.x;
  let _ojz = _o6h[_opj];
  let _oc1 = max(1.5 * _ojz * _oay / _oho.z, 0.5) + 0.25;
  let _oc2 = max(1.5 * _ojz * _oay / _ohp.z, 0.5) + 0.25;
  let _o80 = _oje - _ojd;
  let _oet = length(_o80);
  let _ops = select(vec2f(1.0, 0.0), _o80 / _oet, _oet > 1.0e-6);
  let _og7 = vec2f(-_ops.y, _ops.x);
  let _o9t = vertex == 1u || vertex == 4u || vertex == 5u;
  let _omf = select(-1.0, 1.0, vertex == 2u || vertex == 3u || vertex == 5u);
  var _oic = _ojd - _ops * _oc1 + _og7 * (_omf * _oc1);
  if (_o9t) {
    _oic = _oje + _ops * _oc2 + _og7 * (_omf * _oc2);
  }
  _oh7._oic = _oic;
  let _om1 = _oic + _o6a._odr;
  _oh7._o6r = vec4f(2.0 * _om1.x / _o6a.size.x - 1.0, 1.0 - 2.0 * _om1.y / _o6a.size.y, 0.5, 1.0);
  return _oh7;
}
fn _o6l(_ogr: vec3f, _o8z: vec3f, center: vec3f, r: f32) -> f32 {
  let _ogw = _ogr - center;
  let b = dot(_o8z, _ogw);
  let _oc0 = b * b - (dot(_ogw, _ogw) - r * r);
  if (_oc0 < 0.0) {
    return _on;
  }
  return -b - sqrt(_oc0);
}
@fragment
fn clay_fragment(_ocx: _ov, @builtin(sample_index) sample: u32) -> _oq {
  var _oh7: _oq;
  let _ogb = 2.0 * _ocx._oic / _o6a.size - 1.0;
  let _o8z = normalize(vec3f(_ogb.x * _o6a._oop.x, _ogb.y * _o6a._oop.y, 1.0));
  let _oo7 = dot(_ocx._ofu, _o8z);
  let _ogr = _o8z * _oo7 - _ocx._ofu;
  let _ocm = length(_ocx._oc7);
  let _o3n = select(vec3f(0.0, 0.0, 1.0), _ocx._oc7 / _ocm, _ocm > 0.0);
  let _o4b = dot(_o8z, _o3n);
  let _o8j = 1.0 - _o4b * _o4b;
  var _ops = -sign(_o4b) * _ocm;
  if (_o8j > 1.0e-8) {
    _ops = dot(_o3n, _ogr) / _o8j;
  }
  _ops = clamp(_ops, -_ocm, _ocm);
  let _ola = _ops * _o4b;
  let _ogx = _ogr + _o8z * _ola - _o3n * _ops;
  let _o92 = length(_ogx);
  let _o8m = (_oo7 + _ola) * _o8z.z;
  if (_o8m <= _o6a._orw) {
    discard;
  }
  let _oid = 2.0 * _o6a._oop.x * _o8m / _o6a.size.x;
  let _ojz = _o6h[_ocx._opj];
  let _o8v = 2.0 * _ojz / _oid;
  var _oo6 = _ola;
  var _ogh: vec3f;
  if (_o8v >= 1.0) {
    let r = _ojz;
    _oo6 = _on;
    let _o9c = _o8z - _o3n * _o4b;
    let _oh3 = _ogr - _o3n * dot(_ogr, _o3n);
    let _oji = dot(_o9c, _o9c);
    let _ojj = dot(_oh3, _o9c);
    let _ojk = _ojj * _ojj - _oji * (dot(_oh3, _oh3) - r * r);
    if (_oji > 1.0e-12 && _ojk >= 0.0) {
      let _oot = (-_ojj - sqrt(_ojk)) / _oji;
      if (abs(dot(_ogr + _o8z * _oot, _o3n)) <= _ocm) {
        _oo6 = _oot;
        _ogh = (_oh3 + _o9c * _oot) / r;
      }
    }
    let _ook = _o6l(_ogr, _o8z, -_o3n * _ocm, r);
    if (_ook < _oo6) {
      _oo6 = _ook;
      _ogh = (_ogr + _o8z * _ook + _o3n * _ocm) / r;
    }
    let _oou = _o6l(_ogr, _o8z, _o3n * _ocm, r);
    if (_oou < _oo6) {
      _oo6 = _oou;
      _ogh = (_ogr + _o8z * _oou - _o3n * _ocm) / r;
    }
    if (_oo6 >= _on) {
      discard;
    }
  } else if (abs(_ops) < _ocm) {
    let w = 0.5 * _oid;
    if (_o92 > w) {
      discard;
    }
    let _oeb = _o6c(_ocx._opj ^ _o6c(u32(_ocx._o6r.x) ^ _o6c(u32(_ocx._o6r.y)
                        ^ _o6c(sample + 4u * _o6a._ob3))));
    if (f32(_oeb >> 8u) * (1.0 / 16777216.0) >= _o8v) {
      discard;
    }
    let _oai = (_o8z - _o3n * _o4b) * inverseSqrt(_o8j);
    let x = _o92 / w;
    _ogh = normalize(_ogx / w - _oai * sqrt(max(1.0 - x * x, 0.0)));
  } else {
    let r = _ojz;
    if (_o92 > r) {
      discard;
    }
    let x = _o92 / r;
    _ogh = normalize(_ogx / r - _o8z * sqrt(max(1.0 - x * x, 0.0)));
    _oo6 = _ola - sqrt(max(r * r - _o92 * _o92, 0.0));
  }
  let z = (_oo7 + _oo6) * _o8z.z;
  if (z <= _o6a._orw) {
    discard;
  }
  let _oj9 = _o8z * (_oo7 + _oo6);
  let _ohn = _o6a._o5r.xyz + _o6a._okw.xyz * _oj9.x + _o6a._o9b.xyz * _oj9.y + _o6a._ob2.xyz * _oj9.z;
  let _ogm = normalize(_o6a._okw.xyz * _ogh.x + _o6a._o9b.xyz * _ogh.y + _o6a._ob2.xyz * _ogh.z);
  var _odj = vec3f(_o6a._ori);
  for (var _ocr = 0u; _ocr < 3u; _ocr = _ocr + 1u) {
    let _oez = _o6a._of0[_ocr];
    let _opd = _oez.position.xyz - _ohn;
    let _o83 = dot(_opd, _opd);
    let _oef = _opd * inverseSqrt(_o83);
    let _o7g = max(dot(_ogm, _oef), 0.0);
    let _o7f = max(-dot(_oez._o3n.xyz, _oef), 0.0);
    _odj = _odj + _oez._ois.rgb * (_o7f * _o7g / _o83);
  }
  let _ojy = _ocx._o35 * _odj;
  _oh7._o72 = vec4f(_o6e(clamp(_ojy, vec3f(0.0), vec3f(1.0))), 1.0);
  _oh7._o8k = _o6a._orw / z;
  return _oh7;
}
@compute @workgroup_size(16, 16)
fn clay_accumulate(@builtin(global_invocation_id) id: vec3u) {
  let _ohn = _o6o;
  if (id.x >= _ohn._ord || id.y >= _ohn._ocf) {
    return;
  }
  let _o4z = textureLoad(_o6i, vec2i(id.xy), 0);
  let _odx = 4u * (id.y * _ohn._ord + id.x);
  if (_ohn._ob3 == 0u) {
    _o6n[_odx] = _o4z.r;
    _o6n[_odx + 1u] = _o4z.g;
    _o6n[_odx + 2u] = _o4z.b;
  } else {
    _o6n[_odx] = _o6n[_odx] + _o4z.r;
    _o6n[_odx + 1u] = _o6n[_odx + 1u] + _o4z.g;
    _o6n[_odx + 2u] = _o6n[_odx + 2u] + _o4z.b;
  }
}
@vertex
fn clay_present_vertex(@builtin(vertex_index) _od2: u32) -> @builtin(position) vec4f {
  let x = f32((_od2 << 1u) & 2u) * 2.0 - 1.0;
  let y = f32(_od2 & 2u) * 2.0 - 1.0;
  return vec4f(x, y, 0.0, 1.0);
}
fn _o6p(x: u32, y: u32) -> vec3f {
  let _odx = 4u * (y * _o6g._on5.x + x);
  return vec3f(_o6d[_odx], _o6d[_odx + 1u], _o6d[_odx + 2u]);
}
@fragment
fn clay_present_fragment(@builtin(position) position: vec4f) -> @location(0) vec4f {
  let _oit = _o6g;
  var rgb: vec3f;
  if (all(_oit._on5 == _oit._o9f)) {
    rgb = _o6p(min(u32(position.x), _oit._on5.x - 1u), min(u32(position.y), _oit._on5.y - 1u));
  } else {
    let _ola = vec2f(_oit._on5) / vec2f(_oit._o9f);
    let _ojc = max(position.xy * _ola - 0.5, vec2f(0.0));
    let _ocr = vec2u(_ojc);
    let _oaa = _ojc - vec2f(_ocr);
    let _oct = min(_ocr + 1u, _oit._on5 - 1u);
    let _ocs = min(_ocr, _oit._on5 - 1u);
    let a = mix(_o6p(_ocs.x, _ocs.y), _o6p(_oct.x, _ocs.y), _oaa.x);
    let b = mix(_o6p(_ocs.x, _oct.y), _o6p(_oct.x, _oct.y), _oaa.x);
    rgb = mix(a, b, _oaa.y);
  }
  return vec4f(clamp(rgb / _oit._ob8, vec3f(0.0), vec3f(1.0)), 1.0);
}
