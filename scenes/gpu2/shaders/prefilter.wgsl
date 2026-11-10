@group(0) @binding(0) var<storage, read> _oae: array<f32>;
@group(0) @binding(1) var<storage, read> _ofw: array<f32>;
@group(0) @binding(2) var<storage, read_write> _oes: array<u32>;
@group(0) @binding(3) var<uniform> _o5v: _oo;
fn _oj9(_oei: u32) -> f32 {
  return _o5v._oju[_oei >> 2u][_oei & 3u];
}
@compute @workgroup_size(256)
fn prefilter(@builtin(local_invocation_index) _ofl: u32,
             @builtin(workgroup_id) _os6: vec3u,
             @builtin(num_workgroups) _ohc: vec3u) {
  let _odn = _ofq(_os6, _ohc) * _o2j + _ofl;
  if (_odn >= _o5v._olt) {
    return;
  }
  let _oic = 6u * _odn;
  let _o3n = _oae[_oic];
  let _o3s = _oae[_oic + 1u];
  let _o3t = _oae[_oic + 2u];
  let _o53 = _oae[_oic + 3u];
  let _o54 = _oae[_oic + 4u];
  let _o55 = _oae[_oic + 5u];
  let _o65 = 0.5 * (_o3n + _o53);
  let _o66 = 0.5 * (_o3s + _o54);
  let _o67 = 0.5 * (_o3t + _o55);
  let _ons = _o53 - _o3n;
  let _ont = _o54 - _o3s;
  let _onu = _o55 - _o3t;
  let _ocu = 0.5 * sqrt(_obd(_onu, _onu,
      _obd(_ons, _ons, _ont * _ont)));
  let _olz = 3u * _odn;
  let _ome = exp(_ofw[_olz]);
  let _omf = exp(_ofw[_olz + 1u]);
  let _omg = exp(_ofw[_olz + 2u]);
  var _ogf = _ome;
  _ogf = select(_omf, _ogf, _ogf >= _omf);
  _ogf = select(_omg, _ogf, _ogf >= _omg);
  let _oko = _obd(_ogf, _o5v._ooo, _ocu);
  var _odq = true;
  var _ob6 = _oe5(_o65) && _oe5(_o66) && _oe5(_o67)
      && _oe5(_ocu) && _oe5(_ome) && _oe5(_omf)
      && _oe5(_omg) && _oe5(_oko);
  for (var _on5 = 0u; _on5 < 4u; _on5 = _on5 + 1u) {
    let _o7k = select(1u, 0u, _on5 < 2u);
    let sign = select(1.0, -1.0, (_on5 & 1u) != 0u);
    let _oin = select(_o5v._ois, _o5v._oir, _on5 < 2u);
    let _ohd = _obd(_oj9(3u), _oin, sign * _oj9(_o7k));
    let _ohe = _obd(_oj9(7u), _oin, sign * _oj9(4u + _o7k));
    let _ohf = _obd(_oj9(11u), _oin, sign * _oj9(8u + _o7k));
    let _ohb = _obd(_oj9(15u), _oin, sign * _oj9(12u + _o7k));
    let _on9 = _obd(_o67, _ohf,
        _obd(_o65, _ohd, _o66 * _ohe)) + _ohb;
    let _oon = _oko * sqrt(_obd(_ohf, _ohf, _obd(_ohd, _ohd, _ohe * _ohe)));
    let _olp = 1.0e-6 * _obe(1.0, abs(_on9) + _oon);
    _ob6 = _ob6 && _oe5(_on9) && _oe5(_oon);
    _odq = _odq
        && _on9 + _oon >= -_olp;
  }
  let _ory = _oj9(3u);
  let _orz = _oj9(7u);
  let _os0 = _oj9(11u);
  let _o7b = _obd(_o67, _os0, _obd(_o65, _ory, _o66 * _orz)) + _oj9(15u);
  let _o7c = _oko * sqrt(_obd(_os0, _os0, _obd(_ory, _ory, _orz * _orz)));
  _ob6 = _ob6 && _oe5(_o7b) && _oe5(_o7c);
  let _opw = _obd(_obe(1.0, abs(_o7b) + _o7c), 1.0e-6, 1.0e-3);
  let _o69 = _o7b - _o7c > _opw;
  _oes[_odn] = select(0u, 1u, !_ob6 || !_o69 || _odq);
}
