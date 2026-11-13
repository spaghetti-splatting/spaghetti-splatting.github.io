// P4 of the primitive view: the colour of one kept row in Yizheng's primitive
// view (/theia-ssd/yizheng/honeybee_clay/shaded/bee_shaded.py, launch look
// "--space display --curve none"). It replaces the SV8 colour of sv8.wgsl;
// the other passes do not change, so the trained geometry, opacity and
// footprint composite the colour.
//
//   colour_i = base_i (ka AO_i + kd sum_l E_l T_l,i tint_l sin(t_i, L_l))
//              + ks sum_l E_l T_l,i tint_l sin(t_i, H_l)^p
//   rgb_i = srgb(clamp(exposure colour_i, 0, 1))
//
// base_i (linear), AO_i and T_l,i do not depend on the view; the bake
// (prototyping/honeybee_yz_primitive_bake.py of the tubes worktree) writes
// them to prim_shade.f32. t_i is the unit segment axis, V the unit vector from
// the segment midpoint to the camera, H_l = normalize(L_l + V).

struct PrimLook {
  light_dir: array<vec4f, 3>,   // xyz: unit direction to the light; w: irradiance E
  light_tint: array<vec4f, 3>,  // rgb tint
  ka: f32,
  kd: f32,
  ks: f32,
  p: f32,
  exposure: f32,
  pad0: f32,
  pad1: f32,
  pad2: f32,
};

@group(0) @binding(0) var<storage, read> kept_rows: array<u32>;   // [K]
@group(0) @binding(1) var<storage, read> tiles: array<u32>;       // [K]
@group(0) @binding(2) var<storage, read> endpoints: array<f32>;   // [N, 2, 3]
@group(0) @binding(3) var<storage, read> shade: array<vec4f>;     // [N, 2]: (base rgb, AO), (T key, fill, rim, 0)
@group(0) @binding(4) var<storage, read> counts: array<u32>;
@group(0) @binding(5) var<storage, read_write> rgb: array<f32>;   // [K, 3]
@group(0) @binding(6) var<uniform> cam: Camera;
@group(0) @binding(7) var<uniform> look: PrimLook;

// sqrt(max(1 - c^2, 0)): the sine of the angle between two unit vectors.
fn sine_of(c: f32) -> f32 {
  return sqrt(max(1.0 - c * c, 0.0));
}

@compute @workgroup_size(256)
fn prim_color(@builtin(local_invocation_index) lid: u32,
              @builtin(workgroup_id) wid: vec3u,
              @builtin(num_workgroups) nwg: vec3u) {
  let segment = linear_group(wid, nwg) * WORKGROUP_SIZE + lid;
  if (segment >= counts[SLOT_KEPT]) {
    return;
  }
  if (cam.diag == 0u && tiles[segment] == 0u) {
    return;
  }
  let row = kept_rows[segment];
  let e = 6u * row;
  let a = vec3f(endpoints[e], endpoints[e + 1u], endpoints[e + 2u]);
  let b = vec3f(endpoints[e + 3u], endpoints[e + 4u], endpoints[e + 5u]);
  let mid = 0.5 * (a + b);
  let t = (b - a) / max(length(b - a), 1e-12);
  let v = normalize(cam.campos.xyz - mid);
  let s0 = shade[2u * row];
  let s1 = shade[2u * row + 1u];
  var transmittance = vec3f(s1.x, s1.y, s1.z);
  var diffuse = vec3f(0.0);
  var specular = vec3f(0.0);
  for (var l = 0u; l < 3u; l = l + 1u) {
    let light = look.light_dir[l];
    let tint = look.light_tint[l].xyz;
    let sin_tl = sine_of(dot(t, light.xyz));
    let h = normalize(light.xyz + v);
    let sin_th = sine_of(dot(t, h));
    let lobe = select(pow(sin_th, look.p), 0.0, sin_th <= 0.0);
    diffuse = diffuse + light.w * ((transmittance[l] * sin_tl) * tint);
    specular = specular + light.w * ((transmittance[l] * lobe) * tint);
  }
  let shaded = s0.xyz * (look.ka * s0.w + look.kd * diffuse) + look.ks * specular;
  let c = clamp(shaded * look.exposure, vec3f(0.0), vec3f(1.0));
  let srgb = select(1.055 * pow(c, vec3f(1.0 / 2.4)) - 0.055, 12.92 * c, c <= vec3f(0.0031308));
  rgb[3u * segment] = srgb.x;
  rgb[3u * segment + 1u] = srgb.y;
  rgb[3u * segment + 2u] = srgb.z;
}
