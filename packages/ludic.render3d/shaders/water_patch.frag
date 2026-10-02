// a water patch (a puddle): a soft organic shape on a plane, the world mirrored in it (the still
// water's reflection pass), rings from a foot bending the mirror, a dark body where it does not mirror
in vec3 v_wpos;
out vec4 o_color;
uniform mat4 u_view;
uniform vec2 u_screen;
uniform sampler2D u_refl;      // the world mirrored about the patches' plane
uniform float u_refl_on;
uniform vec2 u_center;         // this patch's centre, and the half size of its quad (1.3 radii)
uniform vec2 u_extent;
uniform float u_seed;
uniform vec4 u_rip[16];        // rings: x, z, age (s), strength (0: none)

// the outline's radius along an angle, in radii: 1 give or take a quarter, its lobes from the seed
float outline(float a) {
  float s = u_seed * 1.618;
  return 1.0 + 0.11 * sin(2.0 * a + s) + 0.07 * sin(3.0 * a + s * 2.3) + 0.05 * sin(5.0 * a + s * 3.7) + 0.03 * sin(7.0 * a + s * 5.1);
}

void main() {
  float radius = u_extent.x / 1.3;
  vec2 d = (v_wpos.xz - u_center) / radius;
  float r = length(d);
  float edge = outline(atan(d.y, d.x)) + 0.10 * gnoise(v_wpos.xz * 1.7 + u_seed);
  // the water thins to nothing over the last fifth of its radius: no line where it meets the floor
  float a = smoothstep(edge, edge - 0.22, r);
  if (a <= 0.001) discard;
  vec3 v = normalize(u_cam_pos - v_wpos);
  float dist = length(u_cam_pos - v_wpos);
  // standing water is all but flat: a breath of slow swell, then the rings
  vec2 slope = vec2(gnoise(v_wpos.xz * 0.9 + u_time * 0.05), gnoise(v_wpos.zx * 0.9 - u_time * 0.04)) * 0.012;
  for (int i = 0; i < 16; i++) {
    vec4 q = u_rip[i];
    if (q.w <= 0.0) continue;
    vec2 off = v_wpos.xz - q.xy;
    float rd = length(off);
    float front = q.z * 0.9;                               // the ring spreads at 0.9 m/s
    float band = rd - front;
    float wave = sin(band * 26.0) * exp(-band * band * 18.0);   // a few crests round the front
    float fade = exp(-q.z * 1.6) * q.w;
    slope += (rd > 1e-3 ? off / rd : vec2(0.0)) * wave * fade * 0.55;
  }
  vec3 n = normalize(vec3(-slope.x, 1.0, -slope.y));
  float NoV = max(dot(n, v), 0.0);
  float F = 0.02 + 0.98 * pow(1.0 - NoV, 5.0);
  vec2 suv = gl_FragCoord.xy / u_screen;
  vec3 r3 = reflect(-v, n);
  r3.y = abs(r3.y);
  vec3 refl = skyPrefiltered(r3, 0.05);
  if (u_refl_on > 0.5) {
    vec2 ruv = clamp(suv + n.xz * 0.06, 0.001, 0.999);
    refl = sane(textureLod(u_refl, ruv, 0.25).rgb);
  }
  // A puddle reads as a dark mirror: what it shows is the world above it, dimmed, more of it
  // looking along the surface (Fresnel) - a game camera looks down at 30-60 degrees, where a real
  // puddle still mirrors the bright things plainly, so the floor of the reflectance is lifted.
  float k = clamp(0.30 + F * 0.65, 0.0, 0.92);
  // a dark mirror: water returns less than it is shown, and a roof's film of grime greys the sky in it
  refl = mix(refl, vec3(dot(refl, vec3(0.2126, 0.7152, 0.0722))), 0.3) * 0.55;
  vec3 body = vec3(0.012, 0.014, 0.018) * skyIrradiance(vec3(0, 1, 0));
  vec3 hv = normalize(v + u_sun_dir);
  float glint = D_GGX(max(dot(n, hv), 0.0), 0.04) * 0.12;
  float viewDepth = -(u_view * vec4(v_wpos, 1.0)).z;
  float shadow = sunShadow(v_wpos, vec3(0, 1, 0), viewDepth);
  vec3 col = mix(body, refl, k) + u_sun_color * glint * F * shadow;
  col = applyFog(col, v_wpos, dist);
  o_color = vec4(sane(col), a);
}
