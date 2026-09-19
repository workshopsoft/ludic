// still water: sky reflection with fresnel, sun glitter, scrolling ripple normals, absorption colour
in vec3 v_wpos;
out vec4 o_color;
uniform mat4 u_view;
uniform sampler2D u_depth;        // scene depth (resolved) for shore softness / depth tint
uniform mat4 u_inv_vp;
uniform vec2 u_screen;
uniform sampler2D u_refl;        // the world mirrored in the surface (rendered by the reflection pass)
uniform float u_refl_on;
uniform vec2 u_center;          // this body's centre and half extents (world xz)
uniform vec2 u_extent;
uniform float u_clip_ellipse;   // 1: the body is the ellipse inside its rectangle (a lake), 0: the whole plane (the sea)
uniform sampler2D u_scene;       // the scene as drawn before the water: the bed, to refract
// wind-streaked capillary ripples (stretched along the wind) over slower swells
float waterH(vec2 p, float t) {
  vec2 w = vec2(p.x * 0.7 + p.y * 0.15, p.y * 1.4) ;            // mildly anisotropic: cat's-paws stretched along the wind
  // A sheltered alpine lake, not a sea. The swell carries what movement there is and the
  // two capillary octaves are most of the way out: at their old weights the whole surface
  // was in motion to the horizon, which is chop, and chop is what stops a lake reading as
  // one sheet of water with a mountain in it.
  return 0.26 * gnoise(w * 0.9 + vec2(t * 0.05, t * 0.3)) + 0.075 * gnoise(p * 2.3 - vec2(t * 0.04, -t * 0.055)) + 0.028 * gnoise(p * 6.0 + vec2(t * 0.7, t * 0.24));
}
vec3 rippleNormal(vec2 p, float t) {
  float e = 0.06;
  float h = waterH(p, t), hx = waterH(p + vec2(e, 0), t), hz = waterH(p + vec2(0, e), t);
  // and the slope the height is turned into is shallower still: the normal is what the
  // reflection is read through, so this is what decides whether a mirrored ridge arrives
  // whole or shivered into pieces
  return normalize(vec3(-(hx - h) * 0.15 / e, 1.0, -(hz - h) * 0.15 / e));
}
void main() {
  // A lake is an ellipse - the carved bed, the grass and a game's own water test all use
  // one - but its plane is the rectangle around it, and the corners between the two hold
  // ground below the lake's level. Without this they show as sheets of water on dry land.
  if (u_clip_ellipse > 0.5) {
    vec2 q = (v_wpos.xz - u_center) / max(u_extent, vec2(0.001));
    if (dot(q, q) > 1.0) discard;
  }
  vec3 v = normalize(u_cam_pos - v_wpos);
  float dist = length(u_cam_pos - v_wpos);
  vec3 n = rippleNormal(v_wpos.xz, u_time);
  n = normalize(mix(n, vec3(0, 1, 0), smoothstep(60.0, 400.0, dist)));   // flat sooner: past a few tens of metres a still lake has no texture at all
  // how deep the ground is under this pixel: from the scene depth
  vec2 suv = gl_FragCoord.xy / u_screen;
  float sd = texture(u_depth, suv).r;
  vec4 gp = u_inv_vp * vec4(suv * 2.0 - 1.0, sd * 2.0 - 1.0, 1.0);
  vec3 ground = gp.xyz / gp.w;
  float depthBelow = clamp(v_wpos.y - ground.y, 0.0, 10.0);
  // How opaque the water is at the shoreline. This used to fade over the last 1.2 m of
  // depth, which is the same band the foam lives in, so the surface went transparent
  // exactly where it should have been breaking white: the foam was drawn and then
  // alpha'd away, leaving a gap of dark wet ground and water that looked like it
  // stopped short of the bank. Fade over a much shorter distance so the water reaches
  // the edge, and let the foam carry its own opacity below.

  vec3 r = reflect(-v, n);
  r.y = abs(r.y);
  vec3 refl = skyPrefiltered(r, 0.12);
  if (u_refl_on > 0.5) {
    // the mirrored render lines up with the screen; the ripples nudge and soften the lookup.
    // The nudge is halved with the ripples that drive it - at the old strength a calm
    // surface still tore the reflection, because the offset was tuned against a normal
    // that no longer exists.
    vec2 ruv = suv + n.xz * 0.010 * smoothstep(500.0, 20.0, dist);
    float blur = mix(0.5, 0.2, smoothstep(0.0, 300.0, dist));
    refl = sane(textureLod(u_refl, clamp(ruv, 0.001, 0.999), blur).rgb);
  }
  // Water is a dim mirror, not a bright one. The mirrored render comes back at the scene's
  // own exposure, so at full strength the lake was as bright as the ridge standing in it and
  // the surface read as polished metal - and being that bright it also buried the bed under
  // it whatever the fresnel mix said. REFL_DIM is what a real surface returns.
  const float REFL_DIM = 0.72;
  refl *= REFL_DIM;
  // wind-blown foam streaks and shoreline wash
  float foam = smoothstep(0.62, 0.9, gnoise(vec2(v_wpos.x * 0.25 + u_time * 0.24, v_wpos.z * 1.5) ) * 0.5 + 0.5) * 0.014 * smoothstep(200.0, 30.0, dist);
  // Wash: the shallows lapping the shore. Built from fbm rather than one gnoise octave —
  // a single octave is a blobby lattice that magnifies into visible squares when you
  // stand next to it, which is what made the wash read as cartoon cut-outs. Several
  // octaves plus a fine breakup term give it structure at every range it is seen from.
  float lap = 0.5 + 0.5 * sin(depthBelow * 9.0 - u_time * 1.6 + 2.0 * gnoise(v_wpos.xz * 0.8 + u_time * 0.2));
  float fdet = fbm(v_wpos.xz * 7.0 - u_time * 0.35, 3) * 0.5 + 0.5;      // fine bubbles
  float fmid = fbm(v_wpos.xz * 2.6 + u_time * 0.5, 3) * 0.5 + 0.5;
  float fedge = fbm(v_wpos.xz * 1.4 - u_time * 0.3, 2) * 0.5 + 0.5;
  // a still alpine lake has a wet line, not surf: the wash is thin (the last 0.35 m of
  // depth) and faint, and the terrain runs the same fields at the same strength
  foam += smoothstep(0.35, 0.0, depthBelow) * (0.12 * smoothstep(0.30, 0.72, fmid) + 0.10 * smoothstep(0.55, 0.95, lap) * smoothstep(0.22, 0.6, fedge)) * (0.55 + 0.75 * fdet);
  // the lap is a near-field detail: from a distance a lake's edge is a line, not a surf
  foam *= smoothstep(120.0, 15.0, dist);
  // the wash dies where the surface meets the ground, so it cannot end on a hard line
  foam *= smoothstep(0.0, 0.5, length(ground - v_wpos));
  float NoV = max(dot(n, v), 0.0);
  float F = 0.02 + 0.98 * pow(1.0 - NoV, 5.0);
  vec3 hv = normalize(v + u_sun_dir);
  float NoH = max(dot(n, hv), 0.0);
  float glitter = D_GGX(NoH, 0.06) * 0.17;   // a narrower sun track: glitter is spread by ripples, and there are fewer
  float viewDepth = -(u_view * vec4(v_wpos, 1.0)).z;
  float shadow = sunShadow(v_wpos, vec3(0, 1, 0), viewDepth) * cloudShadow(v_wpos);
  // ---- what is under the surface -------------------------------------------------
  // The bed is sampled from the scene as it was drawn before the water, nudged by the
  // ripple normal (refraction), then attenuated per channel over the path the light
  // actually travelled: down through the water and back up to the eye. Red goes first,
  // then green, so shallows stay bright and readable and depth turns blue-green and
  // dark on its own. This is what makes it a body of water rather than a tinted sheet:
  // the ground is seen through it, not behind it.
  vec2 ruv2 = clamp(suv + n.xz * 0.03 * smoothstep(0.0, 2.0, depthBelow), 0.001, 0.999);
  // never refract something that is actually in front of the surface (the near bank),
  // or the grass on the shore smears out over the water
  float rd = texture(u_depth, ruv2).r;
  vec4 rgp = u_inv_vp * vec4(ruv2 * 2.0 - 1.0, rd * 2.0 - 1.0, 1.0);
  vec3 rground = rgp.xyz / rgp.w;
  if (rground.y > v_wpos.y) { ruv2 = suv; }
  vec3 bed = sane(texture(u_scene, ruv2).rgb);
  float pathLen = depthBelow * (1.0 + 1.0 / max(NoV, 0.25));
  // Per metre: red first, then green — a cold blue-teal depth. Pulled down by a third, so
  // the light reaches about half as far again into the water as it did: at the old rates a
  // metre and a half of a clear mountain lake was already opaque, which is a pond, and the
  // gravel of the shelf went out before the bank did.
  vec3 absorb = vec3(0.34, 0.15, 0.09);
  vec3 trans = exp(-absorb * pathLen);
  vec3 tint = vec3(0.030, 0.085, 0.105) * skyIrradiance(vec3(0, 1, 0)) * 1.15;   // Maroon Lake: deep, dark blue-green, not turquoise
  vec3 through = bed * trans + tint * (1.0 - trans);
  // ---- surface -------------------------------------------------------------------
  // How much of what you see is the sky and how much is the bottom. The fresnel term is
  // physical and stays; what changed is the weight it is given and, more to the point, the
  // CEILING. At 0.86 the surface went to a near-total mirror as soon as you looked along it,
  // which is true of a sea and is why you could stand at the shore of a lake nine metres
  // deep and never see into it. At 0.70 the bed is there at every angle you actually stand
  // at, and the mirrored Bells are still the thing you see across the water.
  vec3 col = mix(through, refl, clamp(F * 0.85 + 0.03, 0.0, 0.70)) + u_sun_color * glitter * F * shadow;
  col = mix(col, vec3(0.7, 0.75, 0.75) * (skyIrradiance(vec3(0, 1, 0)) * 0.5 + u_sun_color * 0.08 * shadow), clamp(foam, 0.0, 1.0));
  col = applyFog(col, v_wpos, dist);
  // Soft edge measured ALONG THE VIEW RAY, not vertically. Vertical depth collapses to
  // zero over a fraction of a pixel when the surface is seen edge-on, which is exactly
  // the low, near-the-waterline view where the plane's silhouette turns into a hard
  // glassy line. The distance from the surface to the bed along the ray stays a smooth
  // quantity at any angle, so the water dissolves into the ground it meets instead.
  float alongRay = length(ground - v_wpos);
  float soft = smoothstep(0.0, 0.5, alongRay);
  col = mix(bed, col, soft);
  o_color = vec4(sane(col), 1.0);
}
