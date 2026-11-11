struct _o2d {
  _opk: u32,
  _oss: u32,
  _od3: u32,
  _otj: u32,
  _odd: f32,
  _o9a: f32,
  _oa8: f32,
  _o4t: f32,
  _ops: f32,
  _opt: f32,
  _opr: f32,
  _opg: f32,
  _o89: f32,
  _ohf: f32,
  _ord: f32,
  _od9: f32,
  _o9c: vec4f,
  _oti: vec4f,
  _oo0: vec4f,
  _oo1: vec4u,
  _od4: vec4f,
};
@group(0) @binding(0) var<uniform> _oou: _o2d;
@group(0) @binding(1) var<storage, read> _opj: array<u32>;
@group(0) @binding(2) var<storage, read> _omi: array<vec4f>;
@group(0) @binding(3) var<storage, read_write> _o3w: array<vec4f>;
@group(0) @binding(4) var<storage, read_write> _od1: array<vec4f>;
@group(0) @binding(5) var<storage, read_write> _otv: array<vec4f>;
@group(0) @binding(6) var<storage, read_write> _ot0: array<vec4f>;
@group(0) @binding(7) var<storage, read> _ony: array<f32>;
@group(0) @binding(8) var<storage, read_write> _ope: array<atomic<u32>>;
struct _o2c {
  _o8v: f32,
  g: vec3f,
};
fn _onz(_ojb: vec3f) -> _o2c {
  var _oiv: _o2c;
  let _oic = _oou._oo1.x;
  let _oid = _oou._oo1.y;
  let _oie = _oou._oo1.z;
  let _ob7 = (_ojb - _oou._oo0.xyz) * _oou._oo0.w;
  if (_ob7.x < 0.0 || _ob7.y < 0.0 || _ob7.z < 0.0 || _ob7.x > f32(_oic) - 1.001 || _ob7.y > f32(_oid) - 1.001
      || _ob7.z > f32(_oie) - 1.001) {
    _oiv._o8v = 1.0e6;
    _oiv.g = vec3f(0.0);
    return _oiv;
  }
  let _oe7 = u32(_ob7.x);
  let _of3 = u32(_ob7.y);
  let _ofd = u32(_ob7.z);
  let _ocl = _ob7.x - f32(_oe7);
  let _ocm = _ob7.y - f32(_of3);
  let _ocn = _ob7.z - f32(_ofd);
  let _oif = (_oe7 * _oid + _of3) * _oie + _ofd;
  let _ook = _oie;
  let _oo9 = _oid * _oie;
  let _o5m = _ony[_oif];
  let _o5n = _ony[_oif + 1u];
  let _o5p = _ony[_oif + _ook];
  let _o5q = _ony[_oif + _ook + 1u];
  let _o5t = _ony[_oif + _oo9];
  let _o5u = _ony[_oif + _oo9 + 1u];
  let _o5w = _ony[_oif + _oo9 + _ook];
  let _o5x = _ony[_oif + _oo9 + _ook + 1u];
  let _o5l = _o5m + (_o5n - _o5m) * _ocn;
  let _o5o = _o5p + (_o5q - _o5p) * _ocn;
  let _o5s = _o5t + (_o5u - _o5t) * _ocn;
  let _o5v = _o5w + (_o5x - _o5w) * _ocn;
  let _o5k = _o5l + (_o5o - _o5l) * _ocm;
  let _o5r = _o5s + (_o5v - _o5s) * _ocm;
  let _oda = _o5r - _o5k;
  let _odb = (1.0 - _ocl) * (_o5o - _o5l) + _ocl * (_o5v - _o5s);
  let _oak = (_o5n - _o5m) * (1.0 - _ocm) + (_o5q - _o5p) * _ocm;
  let _oal = (_o5u - _o5t) * (1.0 - _ocm) + (_o5x - _o5w) * _ocm;
  let _odc = _oak * (1.0 - _ocl) + _oal * _ocl;
  let g = vec3f(_oda, _odb, _odc);
  let _ohv = length(g);
  _oiv.g = select(vec3f(0.0), g / _ohv, _ohv > 0.0);
  _oiv._o8v = _o5k + (_o5r - _o5k) * _ocl;
  return _oiv;
}
fn _o9v(_oe7: u32) -> vec3f {
  return _otv[_oe7].xyz - _omi[_oe7].xyz;
}
fn _obx(_ogd: vec3f, _ol1: vec3f, _omj: vec3f, _oge: f32) -> vec3f {
  var _oaj = _ol1 - _ogd;
  var _ohv = length(_oaj);
  if (_ohv < 1.0e-12) {
    _oaj = _omj;
    _ohv = length(_oaj);
  }
  return _ogd + _oaj * (_oge / _ohv);
}
fn _o3v(_oon: u32, _osm: f32) {
  atomicMax(&_ope[_oon], bitcast<u32>(max(_osm, 0.0)));
}
@compute @workgroup_size(64)
fn substep(@builtin(global_invocation_id) _ocy: vec3u, @builtin(num_workgroups) _oib: vec3u) {
  let _on4 = _ocy.x + _ocy.y * _oib.x * 64u;
  if (_on4 >= _oou._opk) {
    return;
  }
  let _o4g = _opj[_on4];
  let _ohv = _opj[_on4 + 1u] - _o4g;
  if (_ohv < 2u) {
    return;
  }
  let _odd = _oou._odd;
  let _ofl = _oou._o4t;
  let _o50 = _oou._opg;
  let _o98 = 2.0 * sqrt(_o50);
  let _oeb = 1.0 / _odd;
  let _o6p = _oou._o89 / _odd;
  _otv[_o4g] = vec4f(_omi[_o4g].xyz, 0.0);
  _ot0[_o4g] = vec4f(0.0);
  var _oti = vec3f(0.0);
  if (_oou._otj != 0u) {
    let _oc9 = f32(_on4);
    let _od9 = 0.6 + 0.4 * sin(2.3 * _oou._ord + 0.0007 * _oc9) + 0.25 * sin(5.1 * _oou._ord + 0.0013 * _oc9);
    _oti = _oou._oti.xyz * _od9;
  }
  var _os6 = vec3f(0.0);
  var _os5 = vec3f(0.0);
  var _orx = vec3f(0.0);
  var _osc = _o9v(_o4g + 1u);
  var _osd = vec3f(0.0);
  if (_ohv > 2u) {
    _osd = _o9v(_o4g + 2u);
  }
  var _ogc = _omi[_o4g].xyz;
  var _okj = _ogc;
  var _okk = _ogc;
  var _oh9 = 0.0;
  var _oh8 = 0.0;
  let _ogb = _ohv - 1u;
  for (var _ofd = 1u; _ofd < _ohv; _ofd = _ofd + 1u) {
    _os6 = _os5;
    _os5 = _orx;
    _orx = _osc;
    _osc = _osd;
    if (_ofd + 2u < _ohv) {
      _osd = _o9v(_o4g + _ofd + 2u);
    } else {
      _osd = vec3f(0.0);
    }
    let _oe7 = _o4g + _ofd;
    let x = _otv[_oe7].xyz;
    let _osh = _ot0[_oe7].xyz;
    let _oln = _omi[_oe7];
    let _o3z = _o3w[_oe7];
    let _o9z = select(vec3f(0.0), _os6 - 2.0 * _os5 + _orx, _ofd >= 2u);
    let _o9y = select(vec3f(0.0), _os5 - 2.0 * _orx + _osc, _ofd <= _ohv - 2u);
    let _oa0 = select(vec3f(0.0), _orx - 2.0 * _osc + _osd, _ofd + 1u <= _ohv - 2u);
    let _o4s = -_o9z + 2.0 * _o9y - _oa0;
    let _oph = _oou._opt + (_oou._ops - _oou._opt) * exp(-_oln.w / _oou._opr);
    var a = -_oph * _orx + _ofl * _o4s + _oou._oa8 * (_oti - _osh);
    let w = _o3z.z;
    if (_oou._od3 != 0u && w > 0.0) {
      let _ocz = _od1[_oe7].xyz + _o3z.w * _oou._o9c.xyz;
      a = a + w * (_o50 * (_ocz - x) - _o98 * _osh);
    }
    let _osq = (_osh + _odd * a) * _oou._o9a;
    let _ojc = x + _odd * _osq;
    let _omk = _o3z.x;
    let _oa1 = _o3z.y;
    let _omj = _oln.xyz - _omi[_oe7 - 1u].xyz;
    var _ol1 = _obx(_ogc, _ojc, _omj, _omk);
    for (var _of2 = 0u; _of2 < 2u; _of2 = _of2 + 1u) {
      let _oop = _onz(_ol1);
      if (!(_oop._o8v < _oa1)) {
        break;
      }
      _ol1 = _ol1 + (_oa1 - _oop._o8v) * _oop.g;
      _ol1 = _obx(_ogc, _ol1, _omj, _omk);
    }
    let _o8v = _ol1 - _ojc;
    if (_ofd >= 2u) {
      let _of3 = _oe7 - 1u;
      let _osy = (_okj - _okk) * _oeb - _o6p * _o8v;
      _ot0[_of3] = vec4f(_osy, 0.0);
      _otv[_of3] = vec4f(_okj, 0.0);
      _oh9 = max(_oh9, dot(_osy, _osy));
      let _os4 = _okj - _omi[_of3].xyz;
      _oh8 = max(_oh8, dot(_os4, _os4));
    }
    _okj = _ol1;
    _okk = x;
    _ogc = _ol1;
    if (_ofd == _ogb) {
      let _ot1 = (_ol1 - x) * _oeb;
      _ot0[_oe7] = vec4f(_ot1, 0.0);
      _otv[_oe7] = vec4f(_ol1, 0.0);
      _oh9 = max(_oh9, dot(_ot1, _ot1));
      let _osg = _ol1 - _oln.xyz;
      _oh8 = max(_oh8, dot(_osg, _osg));
    }
  }
  _o3v(0u, _oh9);
  _o3v(1u, _oh8);
}
@compute @workgroup_size(64)
fn grab_begin(@builtin(global_invocation_id) _ocy: vec3u, @builtin(num_workgroups) _oib: vec3u) {
  let _on4 = _ocy.x + _ocy.y * _oib.x * 64u;
  if (_on4 >= _oou._opk) {
    return;
  }
  let _o4g = _opj[_on4];
  let _ohv = _opj[_on4 + 1u] - _o4g;
  let _ols = _oou._od4.w;
  let _o6m = _oou._od4.xyz;
  var _o4u = _ols;
  var _ofl = 0u;
  for (var _ofd = 1u; _ofd < _ohv; _ofd = _ofd + 1u) {
    let _o99 = length(_otv[_o4g + _ofd].xyz - _o6m);
    if (_o99 < _o4u) {
      _o4u = _o99;
      _ofl = _ofd;
    }
  }
  let _ooc = 0.5 * _ols * _ols;
  let _ot5 = exp(-_o4u * _o4u / _ooc);
  let _o3r = max(_omi[_o4g + _ofl].w, 1.0e-9);
  for (var _ofd = 0u; _ofd < _ohv; _ofd = _ofd + 1u) {
    let _oe7 = _o4g + _ofd;
    var _o3z = _o3w[_oe7];
    if (_ofl > 0u && _ofd >= 1u && _ofd <= _ofl) {
      _o3z.z = _ot5;
      _o3z.w = pow(min(_omi[_oe7].w / _o3r, 1.0), 1.5);
      _od1[_oe7] = _otv[_oe7];
    } else {
      _o3z.z = 0.0;
      _o3z.w = 0.0;
    }
    _o3w[_oe7] = _o3z;
  }
  if (_ofl > 0u) {
    atomicAdd(&_ope[2], 1u);
  }
}
@compute @workgroup_size(256)
fn reset_state(@builtin(global_invocation_id) _ocy: vec3u, @builtin(num_workgroups) _oib: vec3u) {
  let _oe7 = _ocy.x + _ocy.y * _oib.x * 256u;
  if (_oe7 >= _oou._oss) {
    return;
  }
  _otv[_oe7] = vec4f(_omi[_oe7].xyz, 0.0);
  _ot0[_oe7] = vec4f(0.0);
  var _o3z = _o3w[_oe7];
  _o3z.z = 0.0;
  _o3z.w = 0.0;
  _o3w[_oe7] = _o3z;
}
