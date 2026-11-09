struct _o1s {
  _okb: vec4f,
  _okc: vec4f,
  _okd: vec4f,
  _oou: vec4f,
  _oc4: vec4f,
  _ojy: vec4f,
  _oda: u32,
  _oig: u32,
  _oih: u32,
  _oii: u32,
};
@group(1) @binding(0) var<uniform> _oj7: _o1s;
fn _oj9(_osg: vec3f) -> vec3f {
  if (_oj7._oda != 0u) {
    return _osg;
  }
  return _oj7._okb.xyz * _osg.x + _oj7._okc.xyz * _osg.y + _oj7._okd.xyz * _osg.z + _oj7._oou.xyz;
}
fn _oj8(_or2: vec3f) -> vec3f {
  if (_oj7._oda != 0u) {
    return _or2;
  }
  return _oj7._okb.xyz * _or2.x + _oj7._okc.xyz * _or2.y + _oj7._okd.xyz * _or2.z;
}
fn _oja(x: vec3f) -> vec3f {
  if (_oj7._oda != 0u) {
    return x;
  }
  let _o89 = x - _oj7._oou.xyz;
  return vec3f(dot(_oj7._okb.xyz, _o89), dot(_oj7._okc.xyz, _o89), dot(_oj7._okd.xyz, _o89));
}
