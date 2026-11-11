struct _ot {
  position: vec4f,
  _o42: vec4f,
  _okh: vec4f,
};
struct _ou {
  _omq: vec4f,
  _oa6: vec4f,
  _oc0: vec4f,
  _o6c: vec4f,
  _oqr: vec2f,
  size: vec2f,
  _of7: vec2f,
  _ou3: f32,
  _oc3: u32,
  _o4c: vec4f,
  _ols: f32,
  _ong: f32,
  _otm: f32,
  _o4d: f32,
  _ogl: array<_ot, 3>,
};
struct _ow {
  _oth: u32,
  _odt: u32,
  _oc3: u32,
  _ojm: u32,
};
struct _ov {
  _op3: vec2u,
  _oaa: vec2u,
  _oc8: f32,
  _o3e: f32,
  _ojo: f32,
  _ojp: f32,
  _o4c: vec4f,
};
@group(0) @binding(0) var<uniform> _o6v: _ou;
@group(0) @binding(1) var<storage, read> _o7e: array<u32>;
@group(0) @binding(2) var<storage, read> _o73: array<f32>;
@group(0) @binding(3) var<storage, read> _o7c: array<f32>;
@group(0) @binding(9) var<storage, read> _o7a: array<f32>;
@group(0) @binding(12) var<storage, read> _o71: array<u32>;
@group(0) @binding(13) var<storage, read> _o72: array<u32>;
struct _oq {
  _omq: vec4f,
  _oa6: vec4f,
  _oc0: vec4f,
  _o6c: vec4f,
  _oqr: vec2f,
  size: vec2f,
  _ou3: f32,
  _omc: f32,
  _ojo: f32,
  _ojp: f32,
  _ool: vec4f,
};
@group(0) @binding(10) var<uniform> _o6z: _oq;
@group(0) @binding(11) var _o70: texture_depth_2d;
@group(0) @binding(4) var _o7b: texture_2d<f32>;
@group(0) @binding(5) var<storage, read_write> _o7h: array<f32>;
@group(0) @binding(6) var<uniform> _o7i: _ow;
@group(0) @binding(7) var<storage, read> _o76: array<f32>;
@group(0) @binding(8) var<uniform> _o79: _ov;
@group(0) @binding(14) var _o6w: texture_3d<f32>;
@group(0) @binding(15) var _o6y: sampler;
const _on: f32 = 3.0e38;
struct _ox {
  @builtin(position) _o7m: vec4f,
  @location(0) @interpolate(linear, sample) _ok1: vec2f,
  @location(1) @interpolate(flat) _ohh: vec3f,
  @location(2) @interpolate(flat) _odl: vec3f,
  @location(3) @interpolate(flat) _o3g: vec3f,
  @location(4) @interpolate(flat) _orn: u32,
};
struct _or {
  @location(0) _o7x: vec4f,
  @builtin(frag_depth) _o9f: f32,
};
fn _o7k(_ojb: vec3f) -> vec3f {
  return vec3f(dot(_o6v._omq.xyz, _ojb), dot(_o6v._oa6.xyz, _ojb), dot(_o6v._oc0.xyz, _ojb));
}
fn _o78(_osh: vec3f) -> vec2f {
  let _ohz = vec2f(_osh.x / (_osh.z * _o6v._oqr.x), _osh.y / (_osh.z * _o6v._oqr.y));
  return (_ohz + 1.0) * 0.5 * _o6v.size;
}
fn _o7g(_o5j: vec3f) -> vec3f {
  let _ogw = _o5j / 12.92;
  let _odx = pow((_o5j + 0.055) / 1.055, vec3f(2.4));
  return select(_odx, _ogw, _o5j <= vec3f(0.04045));
}
fn _o77(_o5j: vec3f) -> vec3f {
  let _ogw = _o5j * 12.92;
  let _odx = 1.055 * pow(_o5j, vec3f(1.0 / 2.4)) - 0.055;
  return select(_odx, _ogw, _o5j <= vec3f(0.0031308));
}
fn _o7d(w: u32) -> vec3f {
  let _oni = exp2(f32(w >> 27u) - 24.0);
  return vec3f(f32(w & 511u), f32((w >> 9u) & 511u), f32((w >> 18u) & 511u)) * _oni;
}
fn _o6x(linear: vec3f) -> vec3f {
  let _oho = -12.47393;
  let _oh6 = 4.026069;
  let x = clamp((log2(max(linear, vec3f(exp2(_oho)))) - _oho) / (_oh6 - _oho), vec3f(0.0), vec3f(1.0));
  let _ohv = 65.0;
  return textureSampleLevel(_o6w, _o6y, (x * (_ohv - 1.0) + 0.5) / _ohv, 0.0).rgb;
}
fn _o74(x: u32) -> u32 {
  let _op8 = x * 747796405u + 2891336453u;
  let _otk = ((_op8 >> ((_op8 >> 28u) + 4u)) ^ _op8) * 277803737u;
  return (_otk >> 22u) ^ _otk;
}
@vertex
fn clay_vertex(@builtin(vertex_index) vertex: u32,
               @builtin(instance_index) _orn: u32) -> _ox {
  var _oiv: _ox;
  let _oaj = 6u * _o7e[_orn];
  let a = vec3f(_o73[_oaj], _o73[_oaj + 1u], _o73[_oaj + 2u]);
  let b = vec3f(_o73[_oaj + 3u], _o73[_oaj + 4u], _o73[_oaj + 5u]);
  let _ohh = _o7k(0.5 * (a + b) - _o6v._o6c.xyz);
  let _odl = _o7k(0.5 * (b - a));
  _oiv._ohh = _ohh;
  _oiv._odl = _odl;
  _oiv._orn = _orn;
  let _o5j = clamp(vec3f(_o7c[3u * _orn], _o7c[3u * _orn + 1u], _o7c[3u * _orn + 2u]),
                vec3f(0.0), vec3f(1.0));
  let g = vec3f((_o5j.x + _o5j.y + _o5j.z) / 3.0);
  _oiv._o3g = _o7g(clamp(g + (_o5j - g) * _o6v._ong, vec3f(0.0), vec3f(1.0)));
  _oiv._ok1 = vec2f(0.0);
  _oiv._o7m = vec4f(2.0, 2.0, 2.0, 1.0);
  var _ojc = _ohh - _odl;
  var _ojd = _ohh + _odl;
  let _oi1 = _o6v._ou3;
  if (max(_ojc.z, _ojd.z) < _oi1) {
    return _oiv;
  }
  if (_ojc.z < _oi1) {
    _ojc = _ojc + (_ojd - _ojc) * ((_oi1 - _ojc.z) / (_ojd.z - _ojc.z));
  }
  if (_ojd.z < _oi1) {
    _ojd = _ojd + (_ojc - _ojd) * ((_oi1 - _ojd.z) / (_ojc.z - _ojd.z));
  }
  let _ol2 = _o78(_ojc);
  let _ol3 = _o78(_ojd);
  let _obw = 0.5 * _o6v.size.x / _o6v._oqr.x;
  let _ols = _o7a[_orn];
  let _ode = max(1.5 * _ols * _obw / _ojc.z, 0.5) + 0.25;
  let _odf = max(1.5 * _ols * _obw / _ojd.z, 0.5) + 0.25;
  let _o8v = _ol3 - _ol2;
  let _oge = length(_o8v);
  let _orw = select(vec2f(1.0, 0.0), _o8v / _oge, _oge > 1.0e-6);
  let _ohv = vec2f(-_orw.y, _orw.x);
  let _oaq = vertex == 1u || vertex == 4u || vertex == 5u;
  let _ooa = select(-1.0, 1.0, vertex == 2u || vertex == 3u || vertex == 5u);
  var _ok1 = _ol2 - _orw * _ode + _ohv * (_ooa * _ode);
  if (_oaq) {
    _ok1 = _ol3 + _orw * _odf + _ohv * (_ooa * _odf);
  }
  _oiv._ok1 = _ok1;
  let _onw = _ok1 + _o6v._of7;
  _oiv._o7m = vec4f(2.0 * _onw.x / _o6v.size.x - 1.0, 1.0 - 2.0 * _onw.y / _o6v.size.y, 0.5, 1.0);
  return _oiv;
}
fn _o7f(_oif: vec3f, _o9u: vec3f, center: vec3f, r: f32) -> f32 {
  let _oik = _oif - center;
  let b = dot(_o9u, _oik);
  let _odd = b * b - (dot(_oik, _oik) - r * r);
  if (_odd < 0.0) {
    return _on;
  }
  return -b - sqrt(_odd);
}
fn _o7l(_ojb: vec3f, _oia: vec3f) -> f32 {
  let _oty = dot(_o6z._oc0.xyz, _ojb - _o6z._o6c.xyz);
  if (_oty <= _o6z._ou3) {
    return 1.0;
  }
  let _or1 = _o6z._o6c.w * _oty;
  let _o8v = _ojb + _oia * (1.5 * _or1) - _o6z._o6c.xyz;
  let _osh = vec3f(dot(_o6z._omq.xyz, _o8v), dot(_o6z._oa6.xyz, _o8v), dot(_o6z._oc0.xyz, _o8v));
  let _ohz = vec2f(_osh.x / (_osh.z * _o6z._oqr.x), _osh.y / (_osh.z * _o6z._oqr.y));
  if (any(abs(_ohz) >= vec2f(1.0))) {
    return 1.0;
  }
  let _ol1 = min(vec2i((_ohz + 1.0) * 0.5 * _o6z.size), vec2i(_o6z.size) - 1);
  let _opi = textureLoad(_o70, _ol1, 0);
  if (_opi <= 0.0) {
    return 1.0;
  }
  let _o55 = _o6z._ou3 / _opi;
  if (_osh.z <= _o55 + 1.5 * _or1) {
    return 1.0;
  }
  if (_o6z._omc > 0.0 && _osh.z - _o55 > _o6z._omc) {
    return 1.0;
  }
  return 0.0;
}
struct _os {
  _oq8: f32,
  _o9u: vec3f,
  _oi5: vec3f,
};
fn _o75(_oed: _ox, sample: u32) -> _os {
  let _ohz = 2.0 * _oed._ok1 / _o6v.size - 1.0;
  let _o9u = normalize(vec3f(_ohz.x * _o6v._oqr.x, _ohz.y * _o6v._oqr.y, 1.0));
  let _oq9 = dot(_oed._ohh, _o9u);
  let _oif = _o9u * _oq9 - _oed._ohh;
  let _oe1 = length(_oed._odl);
  let _o42 = select(vec3f(0.0, 0.0, 1.0), _oed._odl / _oe1, _oe1 > 0.0);
  let _o4r = dot(_o9u, _o42);
  let _o9e = 1.0 - _o4r * _o4r;
  var _orw = -sign(_o4r) * _oe1;
  if (_o9e > 1.0e-8) {
    _orw = dot(_o42, _oif) / _o9e;
  }
  _orw = clamp(_orw, -_oe1, _oe1);
  let _on4 = _orw * _o4r;
  let _oil = _oif + _o9u * _on4 - _o42 * _orw;
  let _o9x = length(_oil);
  let _o9h = (_oq9 + _on4) * _o9u.z;
  if (_o9h <= _o6v._ou3) {
    discard;
  }
  let _ok2 = 2.0 * _o6v._oqr.x * _o9h / _o6v.size.x;
  let _ols = _o7a[_oed._orn];
  let _o9q = 2.0 * _ols / _ok2;
  var _oq8 = _on4;
  var _oi5: vec3f;
  if (_o9q >= 1.0) {
    let r = _ols;
    _oq8 = _on;
    let _oa7 = _o9u - _o42 * _o4r;
    let _oir = _oif - _o42 * dot(_oif, _o42);
    let _ol8 = dot(_oa7, _oa7);
    let _ol9 = dot(_oir, _oa7);
    let _olb = _ol9 * _ol9 - _ol8 * (dot(_oir, _oir) - r * r);
    if (_ol8 > 1.0e-12 && _olb >= 0.0) {
      let _oqv = (-_ol9 - sqrt(_olb)) / _ol8;
      if (abs(dot(_oif + _o9u * _oqv, _o42)) <= _oe1) {
        _oq8 = _oqv;
        _oi5 = (_oir + _oa7 * _oqv) / r;
      }
    }
    let _oqm = _o7f(_oif, _o9u, -_o42 * _oe1, r);
    if (_oqm < _oq8) {
      _oq8 = _oqm;
      _oi5 = (_oif + _o9u * _oqm + _o42 * _oe1) / r;
    }
    let _oqw = _o7f(_oif, _o9u, _o42 * _oe1, r);
    if (_oqw < _oq8) {
      _oq8 = _oqw;
      _oi5 = (_oif + _o9u * _oqw - _o42 * _oe1) / r;
    }
    if (_oq8 >= _on) {
      discard;
    }
  } else if (abs(_orw) < _oe1) {
    let w = 0.5 * _ok2;
    if (_o9x > w) {
      discard;
    }
    let _oft = _o74(_oed._orn ^ _o74(u32(_oed._o7m.x) ^ _o74(u32(_oed._o7m.y)
                        ^ _o74(sample + 4u * _o6v._oc3))));
    if (f32(_oft >> 8u) * (1.0 / 16777216.0) >= _o9q) {
      discard;
    }
    let _obf = (_o9u - _o42 * _o4r) * inverseSqrt(_o9e);
    let x = _o9x / w;
    _oi5 = normalize(_oil / w - _obf * sqrt(max(1.0 - x * x, 0.0)));
  } else {
    let r = _ols;
    if (_o9x > r) {
      discard;
    }
    let x = _o9x / r;
    _oi5 = normalize(_oil / r - _o9u * sqrt(max(1.0 - x * x, 0.0)));
    _oq8 = _on4 - sqrt(max(r * r - _o9x * _o9x, 0.0));
  }
  let z = (_oq9 + _oq8) * _o9u.z;
  if (z <= _o6v._ou3) {
    discard;
  }
  return _os(_oq9 + _oq8, _o9u, _oi5);
}
@fragment
fn clay_fragment(_oed: _ox, @builtin(sample_index) sample: u32) -> _or {
  var _oiv: _or;
  let _oe0 = _o75(_oed, sample);
  let _o9u = _oe0._o9u;
  let _oi5 = _oe0._oi5;
  let z = _oe0._oq8 * _o9u.z;
  let _oky = _o9u * _oe0._oq8;
  let _ojb = _o6v._o6c.xyz + _o6v._omq.xyz * _oky.x + _o6v._oa6.xyz * _oky.y + _o6v._oc0.xyz * _oky.z;
  let _oia = normalize(_o6v._omq.xyz * _oi5.x + _o6v._oa6.xyz * _oi5.y + _o6v._oc0.xyz * _oi5.z);
  let _oob = u32(_o6v._o4d);
  if (_oob > 0u) {
    let _oe3 = _o6v._omq.xyz * _oed._odl.x + _o6v._oa6.xyz * _oed._odl.y + _o6v._oc0.xyz * _oed._odl.z;
    let _oe2 = dot(_oe3, _oe3);
    var _o3y = vec3f(1.0, 0.0, 0.0);
    if (_oe2 > 1.0e-24) {
      _o3y = _oe3 * inverseSqrt(_oe2);
    }
    let _odu = select(vec3f(1.0, 0.0, 0.0), vec3f(0.0, 0.0, 1.0), abs(_o3y.z) < 0.9);
    let _o5d = normalize(cross(_o3y, _odu));
    let _o5f = cross(_o3y, _o5d);
    let _obq = fract(atan2(dot(_oia, _o5f), dot(_oia, _o5d)) * (1.0 / 6.2831853)) * f32(_oob);
    let _ofe = min(u32(_obq), _oob - 1u);
    let _off = (_ofe + 1u) % _oob;
    let _orf = _obq - f32(_ofe);
    let first = _o72[2u * _oed._orn];
    let _oh1 = max(_o72[2u * _oed._orn + 1u], 1u);
    let _odj = dot(_oed._odl, _oed._odl);
    var _o3h = 0.5;
    if (_odj > 1.0e-24) {
      _o3h = clamp(0.5 + 0.5 * dot(_oky - _oed._ohh, _oed._odl) / _odj, 0.0, 1.0);
    }
    let _oc9 = _o3h * f32(_oh1) - 0.5;
    let _of4 = u32(clamp(floor(_oc9), 0.0, f32(_oh1 - 1u)));
    let _of5 = min(_of4 + 1u, _oh1 - 1u);
    let _ore = clamp(_oc9 - f32(_of4), 0.0, 1.0);
    let _ol2 = (first + _of4) * _oob;
    let _ol3 = (first + _of5) * _oob;
    var _o5k: vec3f;
    var _o5r: vec3f;
    if (_o6v._o4c.w > 0.5) {
      _o5k = mix(_o7d(_o71[_ol2 + _ofe]), _o7d(_o71[_ol2 + _off]), _orf);
      _o5r = mix(_o7d(_o71[_ol3 + _ofe]), _o7d(_o71[_ol3 + _off]), _orf);
    } else {
      _o5k = mix(unpack4x8unorm(_o71[_ol2 + _ofe]).rgb, unpack4x8unorm(_o71[_ol2 + _off]).rgb, _orf);
      _o5r = mix(unpack4x8unorm(_o71[_ol3 + _ofe]).rgb, unpack4x8unorm(_o71[_ol3 + _off]).rgb, _orf);
    }
    _oiv._o7x = vec4f(mix(_o5k, _o5r, _ore), 1.0);
    _oiv._o9f = _o6v._ou3 / z;
    return _oiv;
  }
  var _otn = 1.0;
  if (_o6z._ool.w > 0.5) {
    _otn = 4.0 * max(dot(_oia, _o6z._ool.xyz), 0.0) * _o7l(_ojb, _oia);
  }
  var _oez = vec3f(_o6v._otm * _otn);
  for (var _oe7 = 0u; _oe7 < 3u; _oe7 = _oe7 + 1u) {
    let _ogk = _o6v._ogl[_oe7];
    let _orh = _ogk.position.xyz - _ojb;
    let _o8y = dot(_orh, _orh);
    let _og0 = _orh * inverseSqrt(_o8y);
    let _o8b = max(dot(_oia, _og0), 0.0);
    let _o8a = max(-dot(_ogk._o42.xyz, _og0), 0.0);
    _oez = _oez + _ogk._okh.rgb * (_o8a * _o8b / _o8y);
  }
  let _olr = _oed._o3g * _oez;
  _oiv._o7x = vec4f(_o77(clamp(_olr, vec3f(0.0), vec3f(1.0))), 1.0);
  _oiv._o9f = _o6v._ou3 / z;
  return _oiv;
}
@fragment
fn clay_ao_fragment(_oed: _ox) -> @builtin(frag_depth) f32 {
  let _oe0 = _o75(_oed, 0u);
  return _o6v._ou3 / (_oe0._oq8 * _oe0._o9u.z);
}
@compute @workgroup_size(16, 16)
fn clay_accumulate(@builtin(global_invocation_id) id: vec3u) {
  let _ojb = _o7i;
  if (id.x >= _ojb._oth || id.y >= _ojb._odt) {
    return;
  }
  let _o5j = textureLoad(_o7b, vec2i(id.xy), 0);
  let _ofd = 4u * (id.y * _ojb._oth + id.x);
  if (_ojb._oc3 == 0u) {
    _o7h[_ofd] = _o5j.r;
    _o7h[_ofd + 1u] = _o5j.g;
    _o7h[_ofd + 2u] = _o5j.b;
    _o7h[_ofd + 3u] = _o5j.a;
  } else {
    _o7h[_ofd] = _o7h[_ofd] + _o5j.r;
    _o7h[_ofd + 1u] = _o7h[_ofd + 1u] + _o5j.g;
    _o7h[_ofd + 2u] = _o7h[_ofd + 2u] + _o5j.b;
    _o7h[_ofd + 3u] = _o7h[_ofd + 3u] + _o5j.a;
  }
}
@vertex
fn clay_present_vertex(@builtin(vertex_index) _oei: u32) -> @builtin(position) vec4f {
  let x = f32((_oei << 1u) & 2u) * 2.0 - 1.0;
  let y = f32(_oei & 2u) * 2.0 - 1.0;
  return vec4f(x, y, 0.0, 1.0);
}
fn _o7j(x: u32, y: u32) -> vec4f {
  let _ofd = 4u * (y * _o79._op3.x + x);
  return vec4f(_o76[_ofd], _o76[_ofd + 1u], _o76[_ofd + 2u], _o76[_ofd + 3u]);
}
@fragment
fn clay_present_fragment(@builtin(position) position: vec4f) -> @location(0) vec4f {
  let _oki = _o79;
  var rgb: vec4f;
  if (all(_oki._op3 == _oki._oaa)) {
    rgb = _o7j(min(u32(position.x), _oki._op3.x - 1u), min(u32(position.y), _oki._op3.y - 1u));
  } else {
    let _on4 = vec2f(_oki._op3) / vec2f(_oki._oaa);
    let _ol1 = max(position.xy * _on4 - 0.5, vec2f(0.0));
    let _oe7 = vec2u(_ol1);
    let _ob7 = _ol1 - vec2f(_oe7);
    let _oe9 = min(_oe7 + 1u, _oki._op3 - 1u);
    let _oe8 = min(_oe7, _oki._op3 - 1u);
    let a = mix(_o7j(_oe8.x, _oe8.y), _o7j(_oe9.x, _oe8.y), _ob7.x);
    let b = mix(_o7j(_oe8.x, _oe9.y), _o7j(_oe9.x, _oe9.y), _ob7.x);
    rgb = mix(a, b, _ob7.y);
  }
  var _o5j = rgb.rgb / _oki._oc8;
  if (_oki._o3e > 0.5) {
    let a = rgb.a / _oki._oc8;
    var _orn = vec3f(0.0);
    if (a > 0.0) {
      _orn = _o6x(_o5j / a);
    }
    _o5j = _orn * a + _oki._o4c.rgb * (1.0 - a);
  }
  return vec4f(clamp(_o5j, vec3f(0.0), vec3f(1.0)), 1.0);
}
