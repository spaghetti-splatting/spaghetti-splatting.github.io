struct _ot {
  position: vec4f,
  _o3r: vec4f,
  _ojh: vec4f,
};
struct _ou {
  _oll: vec4f,
  _o9s: vec4f,
  _obk: vec4f,
  _o5y: vec4f,
  _opi: vec2f,
  size: vec2f,
  _oec: vec2f,
  _oss: f32,
  _obl: u32,
  _o41: vec4f,
  _oko: f32,
  _omb: f32,
  _osc: f32,
  _o42: f32,
  _ofn: array<_ot, 3>,
};
struct _ow {
  _os7: u32,
  _ocy: u32,
  _obl: u32,
  _oin: u32,
};
struct _ov {
  _onx: vec2u,
  _o9w: vec2u,
  _obq: f32,
  _o37: f32,
  _oip: f32,
  _oiq: f32,
  _o41: vec4f,
};
@group(0) @binding(0) var<uniform> _o6h: _ou;
@group(0) @binding(1) var<storage, read> _o70: array<u32>;
@group(0) @binding(2) var<storage, read> _o6p: array<f32>;
@group(0) @binding(3) var<storage, read> _o6y: array<f32>;
@group(0) @binding(9) var<storage, read> _o6w: array<f32>;
@group(0) @binding(12) var<storage, read> _o6n: array<u32>;
@group(0) @binding(13) var<storage, read> _o6o: array<u32>;
struct _oq {
  _oll: vec4f,
  _o9s: vec4f,
  _obk: vec4f,
  _o5y: vec4f,
  _opi: vec2f,
  size: vec2f,
  _oss: f32,
  _ol7: f32,
  _oip: f32,
  _oiq: f32,
  _ong: vec4f,
};
@group(0) @binding(10) var<uniform> _o6l: _oq;
@group(0) @binding(11) var _o6m: texture_depth_2d;
@group(0) @binding(4) var _o6x: texture_2d<f32>;
@group(0) @binding(5) var<storage, read_write> _o73: array<f32>;
@group(0) @binding(6) var<uniform> _o74: _ow;
@group(0) @binding(7) var<storage, read> _o6s: array<f32>;
@group(0) @binding(8) var<uniform> _o6v: _ov;
@group(0) @binding(14) var _o6i: texture_3d<f32>;
@group(0) @binding(15) var _o6k: sampler;
const _on: f32 = 3.0e38;
struct _ox {
  @builtin(position) _o78: vec4f,
  @location(0) @interpolate(linear, sample) _oj1: vec2f,
  @location(1) @interpolate(flat) _ogi: vec3f,
  @location(2) @interpolate(flat) _ocq: vec3f,
  @location(3) @interpolate(flat) _o38: vec3f,
  @location(4) @interpolate(flat) _oqd: u32,
};
struct _or {
  @location(0) _o7j: vec4f,
  @builtin(frag_depth) _o91: f32,
};
fn _o76(_oic: vec3f) -> vec3f {
  return vec3f(dot(_o6h._oll.xyz, _oic), dot(_o6h._o9s.xyz, _oic), dot(_o6h._obk.xyz, _oic));
}
fn _o6u(_or7: vec3f) -> vec2f {
  let _oh0 = vec2f(_or7.x / (_or7.z * _o6h._opi.x), _or7.y / (_or7.z * _o6h._opi.y));
  return (_oh0 + 1.0) * 0.5 * _o6h.size;
}
fn _o72(_o56: vec3f) -> vec3f {
  let _ofy = _o56 / 12.92;
  let _od2 = pow((_o56 + 0.055) / 1.055, vec3f(2.4));
  return select(_od2, _ofy, _o56 <= vec3f(0.04045));
}
fn _o6t(_o56: vec3f) -> vec3f {
  let _ofy = _o56 * 12.92;
  let _od2 = 1.055 * pow(_o56, vec3f(1.0 / 2.4)) - 0.055;
  return select(_od2, _ofy, _o56 <= vec3f(0.0031308));
}
fn _o6z(w: u32) -> vec3f {
  let _omd = exp2(f32(w >> 27u) - 24.0);
  return vec3f(f32(w & 511u), f32((w >> 9u) & 511u), f32((w >> 18u) & 511u)) * _omd;
}
fn _o6j(linear: vec3f) -> vec3f {
  let _ogp = -12.47393;
  let _og7 = 4.026069;
  let x = clamp((log2(max(linear, vec3f(exp2(_ogp)))) - _ogp) / (_og7 - _ogp), vec3f(0.0), vec3f(1.0));
  let _ogw = 65.0;
  return textureSampleLevel(_o6i, _o6k, (x * (_ogw - 1.0) + 0.5) / _ogw, 0.0).rgb;
}
fn _o6q(x: u32) -> u32 {
  let _oo2 = x * 747796405u + 2891336453u;
  let _osa = ((_oo2 >> ((_oo2 >> 28u) + 4u)) ^ _oo2) * 277803737u;
  return (_osa >> 22u) ^ _osa;
}
@vertex
fn clay_vertex(@builtin(vertex_index) vertex: u32,
               @builtin(instance_index) _oqd: u32) -> _ox {
  var _ohw: _ox;
  let _oa4 = 6u * _o70[_oqd];
  let a = vec3f(_o6p[_oa4], _o6p[_oa4 + 1u], _o6p[_oa4 + 2u]);
  let b = vec3f(_o6p[_oa4 + 3u], _o6p[_oa4 + 4u], _o6p[_oa4 + 5u]);
  let _ogi = _o76(0.5 * (a + b) - _o6h._o5y.xyz);
  let _ocq = _o76(0.5 * (b - a));
  _ohw._ogi = _ogi;
  _ohw._ocq = _ocq;
  _ohw._oqd = _oqd;
  let _o56 = clamp(vec3f(_o6y[3u * _oqd], _o6y[3u * _oqd + 1u], _o6y[3u * _oqd + 2u]),
                vec3f(0.0), vec3f(1.0));
  let g = vec3f((_o56.x + _o56.y + _o56.z) / 3.0);
  _ohw._o38 = _o72(clamp(g + (_o56 - g) * _o6h._omb, vec3f(0.0), vec3f(1.0)));
  _ohw._oj1 = vec2f(0.0);
  _ohw._o78 = vec4f(2.0, 2.0, 2.0, 1.0);
  var _oid = _ogi - _ocq;
  var _oie = _ogi + _ocq;
  let _oh2 = _o6h._oss;
  if (max(_oid.z, _oie.z) < _oh2) {
    return _ohw;
  }
  if (_oid.z < _oh2) {
    _oid = _oid + (_oie - _oid) * ((_oh2 - _oid.z) / (_oie.z - _oid.z));
  }
  if (_oie.z < _oh2) {
    _oie = _oie + (_oid - _oie) * ((_oh2 - _oie.z) / (_oid.z - _oie.z));
  }
  let _ok2 = _o6u(_oid);
  let _ok3 = _o6u(_oie);
  let _obg = 0.5 * _o6h.size.x / _o6h._opi.x;
  let _oko = _o6w[_oqd];
  let _ocj = max(1.5 * _oko * _obg / _oid.z, 0.5) + 0.25;
  let _ock = max(1.5 * _oko * _obg / _oie.z, 0.5) + 0.25;
  let _o8h = _ok3 - _ok2;
  let _ofg = length(_o8h);
  let _oqm = select(vec2f(1.0, 0.0), _o8h / _ofg, _ofg > 1.0e-6);
  let _ogw = vec2f(-_oqm.y, _oqm.x);
  let _oaa = vertex == 1u || vertex == 4u || vertex == 5u;
  let _on5 = select(-1.0, 1.0, vertex == 2u || vertex == 3u || vertex == 5u);
  var _oj1 = _ok2 - _oqm * _ocj + _ogw * (_on5 * _ocj);
  if (_oaa) {
    _oj1 = _ok3 + _oqm * _ock + _ogw * (_on5 * _ock);
  }
  _ohw._oj1 = _oj1;
  let _omr = _oj1 + _o6h._oec;
  _ohw._o78 = vec4f(2.0 * _omr.x / _o6h.size.x - 1.0, 1.0 - 2.0 * _omr.y / _o6h.size.y, 0.5, 1.0);
  return _ohw;
}
fn _o71(_ohg: vec3f, _o9g: vec3f, center: vec3f, r: f32) -> f32 {
  let _ohl = _ohg - center;
  let b = dot(_o9g, _ohl);
  let _oci = b * b - (dot(_ohl, _ohl) - r * r);
  if (_oci < 0.0) {
    return _on;
  }
  return -b - sqrt(_oci);
}
fn _o77(_oic: vec3f, _ohb: vec3f) -> f32 {
  let _oso = dot(_o6l._obk.xyz, _oic - _o6l._o5y.xyz);
  if (_oso <= _o6l._oss) {
    return 1.0;
  }
  let _ops = _o6l._o5y.w * _oso;
  let _o8h = _oic + _ohb * (1.5 * _ops) - _o6l._o5y.xyz;
  let _or7 = vec3f(dot(_o6l._oll.xyz, _o8h), dot(_o6l._o9s.xyz, _o8h), dot(_o6l._obk.xyz, _o8h));
  let _oh0 = vec2f(_or7.x / (_or7.z * _o6l._opi.x), _or7.y / (_or7.z * _o6l._opi.y));
  if (any(abs(_oh0) >= vec2f(1.0))) {
    return 1.0;
  }
  let _ok1 = min(vec2i((_oh0 + 1.0) * 0.5 * _o6l.size), vec2i(_o6l.size) - 1);
  let _oob = textureLoad(_o6m, _ok1, 0);
  if (_oob <= 0.0) {
    return 1.0;
  }
  let _o4u = _o6l._oss / _oob;
  if (_or7.z <= _o4u + 1.5 * _ops) {
    return 1.0;
  }
  if (_o6l._ol7 > 0.0 && _or7.z - _o4u > _o6l._ol7) {
    return 1.0;
  }
  return 0.0;
}
struct _os {
  _ooz: f32,
  _o9g: vec3f,
  _oh6: vec3f,
};
fn _o6r(_odi: _ox, sample: u32) -> _os {
  let _oh0 = 2.0 * _odi._oj1 / _o6h.size - 1.0;
  let _o9g = normalize(vec3f(_oh0.x * _o6h._opi.x, _oh0.y * _o6h._opi.y, 1.0));
  let _op0 = dot(_odi._ogi, _o9g);
  let _ohg = _o9g * _op0 - _odi._ogi;
  let _od6 = length(_odi._ocq);
  let _o3r = select(vec3f(0.0, 0.0, 1.0), _odi._ocq / _od6, _od6 > 0.0);
  let _o4g = dot(_o9g, _o3r);
  let _o90 = 1.0 - _o4g * _o4g;
  var _oqm = -sign(_o4g) * _od6;
  if (_o90 > 1.0e-8) {
    _oqm = dot(_o3r, _ohg) / _o90;
  }
  _oqm = clamp(_oqm, -_od6, _od6);
  let _olz = _oqm * _o4g;
  let _ohm = _ohg + _o9g * _olz - _o3r * _oqm;
  let _o9j = length(_ohm);
  let _o93 = (_op0 + _olz) * _o9g.z;
  if (_o93 <= _o6h._oss) {
    discard;
  }
  let _oj2 = 2.0 * _o6h._opi.x * _o93 / _o6h.size.x;
  let _oko = _o6w[_odi._oqd];
  let _o9c = 2.0 * _oko / _oj2;
  var _ooz = _olz;
  var _oh6: vec3f;
  if (_o9c >= 1.0) {
    let r = _oko;
    _ooz = _on;
    let _o9t = _o9g - _o3r * _o4g;
    let _ohs = _ohg - _o3r * dot(_ohg, _o3r);
    let _ok7 = dot(_o9t, _o9t);
    let _ok8 = dot(_ohs, _o9t);
    let _ok9 = _ok8 * _ok8 - _ok7 * (dot(_ohs, _ohs) - r * r);
    if (_ok7 > 1.0e-12 && _ok9 >= 0.0) {
      let _opm = (-_ok8 - sqrt(_ok9)) / _ok7;
      if (abs(dot(_ohg + _o9g * _opm, _o3r)) <= _od6) {
        _ooz = _opm;
        _oh6 = (_ohs + _o9t * _opm) / r;
      }
    }
    let _opd = _o71(_ohg, _o9g, -_o3r * _od6, r);
    if (_opd < _ooz) {
      _ooz = _opd;
      _oh6 = (_ohg + _o9g * _opd + _o3r * _od6) / r;
    }
    let _opn = _o71(_ohg, _o9g, _o3r * _od6, r);
    if (_opn < _ooz) {
      _ooz = _opn;
      _oh6 = (_ohg + _o9g * _opn - _o3r * _od6) / r;
    }
    if (_ooz >= _on) {
      discard;
    }
  } else if (abs(_oqm) < _od6) {
    let w = 0.5 * _oj2;
    if (_o9j > w) {
      discard;
    }
    let _oey = _o6q(_odi._oqd ^ _o6q(u32(_odi._o78.x) ^ _o6q(u32(_odi._o78.y)
                        ^ _o6q(sample + 4u * _o6h._obl))));
    if (f32(_oey >> 8u) * (1.0 / 16777216.0) >= _o9c) {
      discard;
    }
    let _oaz = (_o9g - _o3r * _o4g) * inverseSqrt(_o90);
    let x = _o9j / w;
    _oh6 = normalize(_ohm / w - _oaz * sqrt(max(1.0 - x * x, 0.0)));
  } else {
    let r = _oko;
    if (_o9j > r) {
      discard;
    }
    let x = _o9j / r;
    _oh6 = normalize(_ohm / r - _o9g * sqrt(max(1.0 - x * x, 0.0)));
    _ooz = _olz - sqrt(max(r * r - _o9j * _o9j, 0.0));
  }
  let z = (_op0 + _ooz) * _o9g.z;
  if (z <= _o6h._oss) {
    discard;
  }
  return _os(_op0 + _ooz, _o9g, _oh6);
}
@fragment
fn clay_fragment(_odi: _ox, @builtin(sample_index) sample: u32) -> _or {
  var _ohw: _or;
  let _od5 = _o6r(_odi, sample);
  let _o9g = _od5._o9g;
  let _oh6 = _od5._oh6;
  let z = _od5._ooz * _o9g.z;
  let _ojy = _o9g * _od5._ooz;
  let _oic = _o6h._o5y.xyz + _o6h._oll.xyz * _ojy.x + _o6h._o9s.xyz * _ojy.y + _o6h._obk.xyz * _ojy.z;
  let _ohb = normalize(_o6h._oll.xyz * _oh6.x + _o6h._o9s.xyz * _oh6.y + _o6h._obk.xyz * _oh6.z);
  let _on6 = u32(_o6h._o42);
  if (_on6 > 0u) {
    let _od8 = _o6h._oll.xyz * _odi._ocq.x + _o6h._o9s.xyz * _odi._ocq.y + _o6h._obk.xyz * _odi._ocq.z;
    let _od7 = dot(_od8, _od8);
    var _o3n = vec3f(1.0, 0.0, 0.0);
    if (_od7 > 1.0e-24) {
      _o3n = _od8 * inverseSqrt(_od7);
    }
    let _ocz = select(vec3f(1.0, 0.0, 0.0), vec3f(0.0, 0.0, 1.0), abs(_o3n.z) < 0.9);
    let _o50 = normalize(cross(_o3n, _ocz));
    let _o52 = cross(_o3n, _o50);
    let _oba = fract(atan2(dot(_ohb, _o52), dot(_ohb, _o50)) * (1.0 / 6.2831853)) * f32(_on6);
    let _oej = min(u32(_oba), _on6 - 1u);
    let _oek = (_oej + 1u) % _on6;
    let _oq5 = _oba - f32(_oej);
    let first = _o6o[2u * _odi._oqd];
    let _og2 = max(_o6o[2u * _odi._oqd + 1u], 1u);
    let _oco = dot(_odi._ocq, _odi._ocq);
    var _o39 = 0.5;
    if (_oco > 1.0e-24) {
      _o39 = clamp(0.5 + 0.5 * dot(_ojy - _odi._ogi, _odi._ocq) / _oco, 0.0, 1.0);
    }
    let _obr = _o39 * f32(_og2) - 0.5;
    let _oe9 = u32(clamp(floor(_obr), 0.0, f32(_og2 - 1u)));
    let _oea = min(_oe9 + 1u, _og2 - 1u);
    let _oq4 = clamp(_obr - f32(_oe9), 0.0, 1.0);
    let _ok2 = (first + _oe9) * _on6;
    let _ok3 = (first + _oea) * _on6;
    var _o57: vec3f;
    var _o5e: vec3f;
    if (_o6h._o41.w > 0.5) {
      _o57 = mix(_o6z(_o6n[_ok2 + _oej]), _o6z(_o6n[_ok2 + _oek]), _oq5);
      _o5e = mix(_o6z(_o6n[_ok3 + _oej]), _o6z(_o6n[_ok3 + _oek]), _oq5);
    } else {
      _o57 = mix(unpack4x8unorm(_o6n[_ok2 + _oej]).rgb, unpack4x8unorm(_o6n[_ok2 + _oek]).rgb, _oq5);
      _o5e = mix(unpack4x8unorm(_o6n[_ok3 + _oej]).rgb, unpack4x8unorm(_o6n[_ok3 + _oek]).rgb, _oq5);
    }
    _ohw._o7j = vec4f(mix(_o57, _o5e, _oq4), 1.0);
    _ohw._o91 = _o6h._oss / z;
    return _ohw;
  }
  var _osd = 1.0;
  if (_o6l._ong.w > 0.5) {
    _osd = 4.0 * max(dot(_ohb, _o6l._ong.xyz), 0.0) * _o77(_oic, _ohb);
  }
  var _oe4 = vec3f(_o6h._osc * _osd);
  for (var _odc = 0u; _odc < 3u; _odc = _odc + 1u) {
    let _ofm = _o6h._ofn[_odc];
    let _oq7 = _ofm.position.xyz - _oic;
    let _o8k = dot(_oq7, _oq7);
    let _of2 = _oq7 * inverseSqrt(_o8k);
    let _o7x = max(dot(_ohb, _of2), 0.0);
    let _o7w = max(-dot(_ofm._o3r.xyz, _of2), 0.0);
    _oe4 = _oe4 + _ofm._ojh.rgb * (_o7w * _o7x / _o8k);
  }
  let _okn = _odi._o38 * _oe4;
  _ohw._o7j = vec4f(_o6t(clamp(_okn, vec3f(0.0), vec3f(1.0))), 1.0);
  _ohw._o91 = _o6h._oss / z;
  return _ohw;
}
@fragment
fn clay_ao_fragment(_odi: _ox) -> @builtin(frag_depth) f32 {
  let _od5 = _o6r(_odi, 0u);
  return _o6h._oss / (_od5._ooz * _od5._o9g.z);
}
@compute @workgroup_size(16, 16)
fn clay_accumulate(@builtin(global_invocation_id) id: vec3u) {
  let _oic = _o74;
  if (id.x >= _oic._os7 || id.y >= _oic._ocy) {
    return;
  }
  let _o56 = textureLoad(_o6x, vec2i(id.xy), 0);
  let _oei = 4u * (id.y * _oic._os7 + id.x);
  if (_oic._obl == 0u) {
    _o73[_oei] = _o56.r;
    _o73[_oei + 1u] = _o56.g;
    _o73[_oei + 2u] = _o56.b;
    _o73[_oei + 3u] = _o56.a;
  } else {
    _o73[_oei] = _o73[_oei] + _o56.r;
    _o73[_oei + 1u] = _o73[_oei + 1u] + _o56.g;
    _o73[_oei + 2u] = _o73[_oei + 2u] + _o56.b;
    _o73[_oei + 3u] = _o73[_oei + 3u] + _o56.a;
  }
}
@vertex
fn clay_present_vertex(@builtin(vertex_index) _odn: u32) -> @builtin(position) vec4f {
  let x = f32((_odn << 1u) & 2u) * 2.0 - 1.0;
  let y = f32(_odn & 2u) * 2.0 - 1.0;
  return vec4f(x, y, 0.0, 1.0);
}
fn _o75(x: u32, y: u32) -> vec4f {
  let _oei = 4u * (y * _o6v._onx.x + x);
  return vec4f(_o6s[_oei], _o6s[_oei + 1u], _o6s[_oei + 2u], _o6s[_oei + 3u]);
}
@fragment
fn clay_present_fragment(@builtin(position) position: vec4f) -> @location(0) vec4f {
  let _oji = _o6v;
  var rgb: vec4f;
  if (all(_oji._onx == _oji._o9w)) {
    rgb = _o75(min(u32(position.x), _oji._onx.x - 1u), min(u32(position.y), _oji._onx.y - 1u));
  } else {
    let _olz = vec2f(_oji._onx) / vec2f(_oji._o9w);
    let _ok1 = max(position.xy * _olz - 0.5, vec2f(0.0));
    let _odc = vec2u(_ok1);
    let _oar = _ok1 - vec2f(_odc);
    let _ode = min(_odc + 1u, _oji._onx - 1u);
    let _odd = min(_odc, _oji._onx - 1u);
    let a = mix(_o75(_odd.x, _odd.y), _o75(_ode.x, _odd.y), _oar.x);
    let b = mix(_o75(_odd.x, _ode.y), _o75(_ode.x, _ode.y), _oar.x);
    rgb = mix(a, b, _oar.y);
  }
  var _o56 = rgb.rgb / _oji._obq;
  if (_oji._o37 > 0.5) {
    let a = rgb.a / _oji._obq;
    var _oqd = vec3f(0.0);
    if (a > 0.0) {
      _oqd = _o6j(_o56 / a);
    }
    _o56 = _oqd * a + _oji._o41.rgb * (1.0 - a);
  }
  return vec4f(clamp(_o56, vec3f(0.0), vec3f(1.0)), 1.0);
}
