struct _or {
  position: vec4f,
  _o3n: vec4f,
  _oir: vec4f,
};
struct _os {
  _okv: vec4f,
  _o9a: vec4f,
  _ob1: vec4f,
  _o5r: vec4f,
  _ooo: vec2f,
  size: vec2f,
  _odq: vec2f,
  _orv: f32,
  _ob2: u32,
  _o3x: vec4f,
  _ojy: f32,
  _oll: f32,
  _orh: f32,
  _ohx: f32,
  _oez: array<_or, 3>,
};
struct _ou {
  _orc: u32,
  _oce: u32,
  _ob2: u32,
  _ohx: u32,
};
struct _ot {
  _on4: vec2u,
  _o9e: vec2u,
  _ob7: f32,
  _ohy: f32,
  _ohz: f32,
  _oi0: f32,
};
@group(0) @binding(0) var<uniform> _o6a: _os;
@group(0) @binding(1) var<storage, read> _o6j: array<u32>;
@group(0) @binding(2) var<storage, read> _o6b: array<f32>;
@group(0) @binding(3) var<storage, read> _o6i: array<f32>;
@group(0) @binding(4) var _o6h: texture_2d<f32>;
@group(0) @binding(5) var<storage, read_write> _o6m: array<f32>;
@group(0) @binding(6) var<uniform> _o6n: _ou;
@group(0) @binding(7) var<storage, read> _o6d: array<f32>;
@group(0) @binding(8) var<uniform> _o6g: _ot;
const _on: f32 = 3.0e38;
struct _ov {
  @builtin(position) _o6q: vec4f,
  @location(0) @interpolate(linear, sample) _oib: vec2f,
  @location(1) @interpolate(flat) _oft: vec3f,
  @location(2) @interpolate(flat) _oc6: vec3f,
  @location(3) @interpolate(flat) _o35: vec3f,
  @location(4) @interpolate(flat) _opi: u32,
};
struct _oq {
  @location(0) _o71: vec4f,
  @builtin(frag_depth) _o8j: f32,
};
fn _o6p(_ohm: vec3f) -> vec3f {
  return vec3f(dot(_o6a._okv.xyz, _ohm), dot(_o6a._o9a.xyz, _ohm), dot(_o6a._ob1.xyz, _ohm));
}
fn _o6f(_oqc: vec3f) -> vec2f {
  let _oga = vec2f(_oqc.x / (_oqc.z * _o6a._ooo.x), _oqc.y / (_oqc.z * _o6a._ooo.y));
  return (_oga + 1.0) * 0.5 * _o6a.size;
}
fn _o6l(_o4z: vec3f) -> vec3f {
  let _ofa = _o4z / 12.92;
  let _och = pow((_o4z + 0.055) / 1.055, vec3f(2.4));
  return select(_och, _ofa, _o4z <= vec3f(0.04045));
}
fn _o6e(_o4z: vec3f) -> vec3f {
  let _ofa = _o4z * 12.92;
  let _och = 1.055 * pow(_o4z, vec3f(1.0 / 2.4)) - 0.055;
  return select(_och, _ofa, _o4z <= vec3f(0.0031308));
}
fn _o6c(x: u32) -> u32 {
  let _on9 = x * 747796405u + 2891336453u;
  let _orf = ((_on9 >> ((_on9 >> 28u) + 4u)) ^ _on9) * 277803737u;
  return (_orf >> 22u) ^ _orf;
}
@vertex
fn clay_vertex(@builtin(vertex_index) vertex: u32,
               @builtin(instance_index) _opi: u32) -> _ov {
  var _oh6: _ov;
  let _o9m = 6u * _o6j[_opi];
  let a = vec3f(_o6b[_o9m], _o6b[_o9m + 1u], _o6b[_o9m + 2u]);
  let b = vec3f(_o6b[_o9m + 3u], _o6b[_o9m + 4u], _o6b[_o9m + 5u]);
  let _oft = _o6p(0.5 * (a + b) - _o6a._o5r.xyz);
  let _oc6 = _o6p(0.5 * (b - a));
  _oh6._oft = _oft;
  _oh6._oc6 = _oc6;
  _oh6._opi = _opi;
  let _o4z = clamp(vec3f(_o6i[3u * _opi], _o6i[3u * _opi + 1u], _o6i[3u * _opi + 2u]),
                vec3f(0.0), vec3f(1.0));
  let g = vec3f((_o4z.x + _o4z.y + _o4z.z) / 3.0);
  _oh6._o35 = _o6l(clamp(g + (_o4z - g) * _o6a._oll, vec3f(0.0), vec3f(1.0)));
  _oh6._oib = vec2f(0.0);
  _oh6._o6q = vec4f(2.0, 2.0, 2.0, 1.0);
  var _ohn = _oft - _oc6;
  var _oho = _oft + _oc6;
  let _ogc = _o6a._orv;
  if (max(_ohn.z, _oho.z) < _ogc) {
    return _oh6;
  }
  if (_ohn.z < _ogc) {
    _ohn = _ohn + (_oho - _ohn) * ((_ogc - _ohn.z) / (_oho.z - _ohn.z));
  }
  if (_oho.z < _ogc) {
    _oho = _oho + (_ohn - _oho) * ((_ogc - _oho.z) / (_ohn.z - _oho.z));
  }
  let _ojc = _o6f(_ohn);
  let _ojd = _o6f(_oho);
  let _oax = 0.5 * _o6a.size.x / _o6a._ooo.x;
  let _oc0 = max(1.5 * _o6a._ojy * _oax / _ohn.z, 0.5) + 0.25;
  let _oc1 = max(1.5 * _o6a._ojy * _oax / _oho.z, 0.5) + 0.25;
  let _o7z = _ojd - _ojc;
  let _oes = length(_o7z);
  let _opr = select(vec2f(1.0, 0.0), _o7z / _oes, _oes > 1.0e-6);
  let _og6 = vec2f(-_opr.y, _opr.x);
  let _o9s = vertex == 1u || vertex == 4u || vertex == 5u;
  let _ome = select(-1.0, 1.0, vertex == 2u || vertex == 3u || vertex == 5u);
  var _oib = _ojc - _opr * _oc0 + _og6 * (_ome * _oc0);
  if (_o9s) {
    _oib = _ojd + _opr * _oc1 + _og6 * (_ome * _oc1);
  }
  _oh6._oib = _oib;
  let _om0 = _oib + _o6a._odq;
  _oh6._o6q = vec4f(2.0 * _om0.x / _o6a.size.x - 1.0, 1.0 - 2.0 * _om0.y / _o6a.size.y, 0.5, 1.0);
  return _oh6;
}
fn _o6k(_ogq: vec3f, _o8y: vec3f, center: vec3f, r: f32) -> f32 {
  let _ogv = _ogq - center;
  let b = dot(_o8y, _ogv);
  let _obz = b * b - (dot(_ogv, _ogv) - r * r);
  if (_obz < 0.0) {
    return _on;
  }
  return -b - sqrt(_obz);
}
@fragment
fn clay_fragment(_ocw: _ov, @builtin(sample_index) sample: u32) -> _oq {
  var _oh6: _oq;
  let _oga = 2.0 * _ocw._oib / _o6a.size - 1.0;
  let _o8y = normalize(vec3f(_oga.x * _o6a._ooo.x, _oga.y * _o6a._ooo.y, 1.0));
  let _oo6 = dot(_ocw._oft, _o8y);
  let _ogq = _o8y * _oo6 - _ocw._oft;
  let _ocl = length(_ocw._oc6);
  let _o3n = select(vec3f(0.0, 0.0, 1.0), _ocw._oc6 / _ocl, _ocl > 0.0);
  let _o4b = dot(_o8y, _o3n);
  let _o8i = 1.0 - _o4b * _o4b;
  var _opr = -sign(_o4b) * _ocl;
  if (_o8i > 1.0e-8) {
    _opr = dot(_o3n, _ogq) / _o8i;
  }
  _opr = clamp(_opr, -_ocl, _ocl);
  let _ol9 = _opr * _o4b;
  let _ogw = _ogq + _o8y * _ol9 - _o3n * _opr;
  let _o91 = length(_ogw);
  let _o8l = (_oo6 + _ol9) * _o8y.z;
  if (_o8l <= _o6a._orv) {
    discard;
  }
  let _oic = 2.0 * _o6a._ooo.x * _o8l / _o6a.size.x;
  let _o8u = 2.0 * _o6a._ojy / _oic;
  var _oo5 = _ol9;
  var _ogg: vec3f;
  if (_o8u >= 1.0) {
    let r = _o6a._ojy;
    _oo5 = _on;
    let _o9b = _o8y - _o3n * _o4b;
    let _oh2 = _ogq - _o3n * dot(_ogq, _o3n);
    let _ojh = dot(_o9b, _o9b);
    let _oji = dot(_oh2, _o9b);
    let _ojj = _oji * _oji - _ojh * (dot(_oh2, _oh2) - r * r);
    if (_ojh > 1.0e-12 && _ojj >= 0.0) {
      let _oos = (-_oji - sqrt(_ojj)) / _ojh;
      if (abs(dot(_ogq + _o8y * _oos, _o3n)) <= _ocl) {
        _oo5 = _oos;
        _ogg = (_oh2 + _o9b * _oos) / r;
      }
    }
    let _ooj = _o6k(_ogq, _o8y, -_o3n * _ocl, r);
    if (_ooj < _oo5) {
      _oo5 = _ooj;
      _ogg = (_ogq + _o8y * _ooj + _o3n * _ocl) / r;
    }
    let _oot = _o6k(_ogq, _o8y, _o3n * _ocl, r);
    if (_oot < _oo5) {
      _oo5 = _oot;
      _ogg = (_ogq + _o8y * _oot - _o3n * _ocl) / r;
    }
    if (_oo5 >= _on) {
      discard;
    }
  } else if (abs(_opr) < _ocl) {
    let w = 0.5 * _oic;
    if (_o91 > w) {
      discard;
    }
    let _oea = _o6c(_ocw._opi ^ _o6c(u32(_ocw._o6q.x) ^ _o6c(u32(_ocw._o6q.y)
                        ^ _o6c(sample + 4u * _o6a._ob2))));
    if (f32(_oea >> 8u) * (1.0 / 16777216.0) >= _o8u) {
      discard;
    }
    let _oah = (_o8y - _o3n * _o4b) * inverseSqrt(_o8i);
    let x = _o91 / w;
    _ogg = normalize(_ogw / w - _oah * sqrt(max(1.0 - x * x, 0.0)));
  } else {
    let r = _o6a._ojy;
    if (_o91 > r) {
      discard;
    }
    let x = _o91 / r;
    _ogg = normalize(_ogw / r - _o8y * sqrt(max(1.0 - x * x, 0.0)));
    _oo5 = _ol9 - sqrt(max(r * r - _o91 * _o91, 0.0));
  }
  let z = (_oo6 + _oo5) * _o8y.z;
  if (z <= _o6a._orv) {
    discard;
  }
  let _oj8 = _o8y * (_oo6 + _oo5);
  let _ohm = _o6a._o5r.xyz + _o6a._okv.xyz * _oj8.x + _o6a._o9a.xyz * _oj8.y + _o6a._ob1.xyz * _oj8.z;
  let _ogl = normalize(_o6a._okv.xyz * _ogg.x + _o6a._o9a.xyz * _ogg.y + _o6a._ob1.xyz * _ogg.z);
  var _odi = vec3f(_o6a._orh);
  for (var _ocq = 0u; _ocq < 3u; _ocq = _ocq + 1u) {
    let _oey = _o6a._oez[_ocq];
    let _opc = _oey.position.xyz - _ohm;
    let _o82 = dot(_opc, _opc);
    let _oee = _opc * inverseSqrt(_o82);
    let _o7f = max(dot(_ogl, _oee), 0.0);
    let _o7e = max(-dot(_oey._o3n.xyz, _oee), 0.0);
    _odi = _odi + _oey._oir.rgb * (_o7e * _o7f / _o82);
  }
  let _ojx = _ocw._o35 * _odi;
  _oh6._o71 = vec4f(_o6e(clamp(_ojx, vec3f(0.0), vec3f(1.0))), 1.0);
  _oh6._o8j = _o6a._orv / z;
  return _oh6;
}
@compute @workgroup_size(16, 16)
fn clay_accumulate(@builtin(global_invocation_id) id: vec3u) {
  let _ohm = _o6n;
  if (id.x >= _ohm._orc || id.y >= _ohm._oce) {
    return;
  }
  let _o4z = textureLoad(_o6h, vec2i(id.xy), 0);
  let _odw = 4u * (id.y * _ohm._orc + id.x);
  if (_ohm._ob2 == 0u) {
    _o6m[_odw] = _o4z.r;
    _o6m[_odw + 1u] = _o4z.g;
    _o6m[_odw + 2u] = _o4z.b;
  } else {
    _o6m[_odw] = _o6m[_odw] + _o4z.r;
    _o6m[_odw + 1u] = _o6m[_odw + 1u] + _o4z.g;
    _o6m[_odw + 2u] = _o6m[_odw + 2u] + _o4z.b;
  }
}
@vertex
fn clay_present_vertex(@builtin(vertex_index) _od1: u32) -> @builtin(position) vec4f {
  let x = f32((_od1 << 1u) & 2u) * 2.0 - 1.0;
  let y = f32(_od1 & 2u) * 2.0 - 1.0;
  return vec4f(x, y, 0.0, 1.0);
}
fn _o6o(x: u32, y: u32) -> vec3f {
  let _odw = 4u * (y * _o6g._on4.x + x);
  return vec3f(_o6d[_odw], _o6d[_odw + 1u], _o6d[_odw + 2u]);
}
@fragment
fn clay_present_fragment(@builtin(position) position: vec4f) -> @location(0) vec4f {
  let _ois = _o6g;
  var rgb: vec3f;
  if (all(_ois._on4 == _ois._o9e)) {
    rgb = _o6o(min(u32(position.x), _ois._on4.x - 1u), min(u32(position.y), _ois._on4.y - 1u));
  } else {
    let _ol9 = vec2f(_ois._on4) / vec2f(_ois._o9e);
    let _ojb = max(position.xy * _ol9 - 0.5, vec2f(0.0));
    let _ocq = vec2u(_ojb);
    let _oa9 = _ojb - vec2f(_ocq);
    let _ocs = min(_ocq + 1u, _ois._on4 - 1u);
    let _ocr = min(_ocq, _ois._on4 - 1u);
    let a = mix(_o6o(_ocr.x, _ocr.y), _o6o(_ocs.x, _ocr.y), _oa9.x);
    let b = mix(_o6o(_ocr.x, _ocs.y), _o6o(_ocs.x, _ocs.y), _oa9.x);
    rgb = mix(a, b, _oa9.y);
  }
  return vec4f(clamp(rgb / _ois._ob7, vec3f(0.0), vec3f(1.0)), 1.0);
}
