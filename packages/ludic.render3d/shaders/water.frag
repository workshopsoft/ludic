// still water: sky reflection with fresnel, sun glitter, scrolling ripple normals, absorption colour
in vec3 v_wpos;
out vec4 o_color;
uniform mat4 u_view;
uniform mat4 u_proj;       // its [1][1] turns a spread in metres into pixels
uniform vec3 u_wade;       // x, z, strength: a body standing in the water
uniform sampler2D u_depth;        // scene depth (resolved) for shore softness / depth tint
uniform mat4 u_inv_vp;
uniform vec2 u_screen;
uniform sampler2D u_refl;        // the world mirrored in the surface (rendered by the reflection pass)
uniform float u_refl_on;
uniform vec2 u_center;          // this body's centre and half extents (world xz)
uniform vec2 u_extent;
uniform float u_clip_ellipse;   // 1: the body is the ellipse inside its rectangle (a lake), 0: the whole plane (the sea)
uniform sampler2D u_scene;       // the scene as drawn before the water: the bed, to refract
// The wet mask (water_wet.ludic): a plane with u_wet_on draws only on wet texels. A texel a tile in the page says
// what the tile is - 0 not known (wet, as a plane with no mask), 1 all dry, 2 all wet, 3 + k mixed and resident in
// layer k of the tiles, one byte a texel (255 wet) on the height tiles' own grid, read bilinear: the edge runs halfway
// between a wet texel's centre and a dry one's. Off the map, wet.
uniform float u_wet_on;
uniform sampler2D u_wet_page;
uniform sampler2DArray u_wet_tiles;
uniform vec4 u_wet_grid;          // tile (0, 0)'s corner in render space x, z; metres a tile; tiles a side (cols)
uniform float u_wet_rows;
float wetAt(vec2 xz) {
  vec2 t = (xz - u_wet_grid.xy) / u_wet_grid.z;
  if (t.x < 0.0 || t.y < 0.0 || t.x >= u_wet_grid.w || t.y >= u_wet_rows) return 1.0;
  ivec2 ti = ivec2(floor(t));
  float v = floor(texelFetch(u_wet_page, ti, 0).r * 255.0 + 0.5);
  if (v < 0.5) return 1.0;
  if (v < 1.5) return 0.0;
  if (v < 2.5) return 1.0;
  return texture(u_wet_tiles, vec3(fract(t), v - 3.0)).r;
}
// The ground under a pixel, as the terrain draws it (the shore's terms belong to the bed, and the
// scene depth can be a fish or a pair of legs standing on it). terpage.glsl, pasted (the reference
// copy and its rules are there): the height sections, read through u_ts_height.
#define TP_FRAGMENT
// ---- the page table ----------------------------------------------------------------------
#ifndef TP_HELPERS
#define TP_HELPERS
uniform sampler2D u_tp_page;   // R32F, a texel a tile: slot + 1, 0 = not resident
uniform float u_tp_on;         // 1 while paging; 0 reads the whole maps exactly as before
uniform vec4 u_tp_dims;        // tiles a side, height texels a tile, photo texels a tile, full height res
// the layer holding a full-map uv, or -1: paging off, off the map, or not resident
float tpSlot(vec2 uv) {
  if (u_tp_on < 0.5 || uv.x < 0.0 || uv.y < 0.0 || uv.x >= 1.0 || uv.y >= 1.0) return -1.0;
  ivec2 t = min(ivec2(floor(uv * u_tp_dims.x)), ivec2(int(u_tp_dims.x) - 1));
  return texelFetch(u_tp_page, t, 0).r - 1.0;
}
// a full-map uv inside its tile's layer of k texels a side, past the one-texel border
vec2 tpUV(vec2 uv, float k) { return (1.0 + fract(uv * u_tp_dims.x) * k) / (k + 2.0); }
#endif
// ---- height (vertex and mesh stages) -----------------------------------------------------
#ifndef TP_HEIGHT
#define TP_HEIGHT
#ifndef TP_HMAP
#define TP_HMAP u_ts_height
#endif
uniform sampler2DArray u_tp_h;
// bilinear height, fine where a tile is resident. Outside a fragment stage texture() IS level 0
// (glslang emits the same explicit-lod sample), so this is the old read bit for bit.
float terHeight(vec2 uv) {
  float s = tpSlot(uv);
  if (s >= 0.0) return textureLod(u_tp_h, vec3(tpUV(uv, u_tp_dims.y), s), 0.0).r;
  return textureLod(TP_HMAP, uv, 0.0).r;
}
// The B-spline through four bilinear taps (heightSmooth). Paging on, the texel is the FULL
// map's - the coarse map's own size would halve the surface's detail - and each tap finds its
// own tile, so a patch straddling two tiles, or a tile and the coarse map, stays one surface.
float terHeightSmooth(vec2 uv) {
  vec2 res = u_tp_on > 0.5 ? vec2(u_tp_dims.w) : vec2(textureSize(TP_HMAP, 0));
  vec2 t = uv * res - 0.5;
  vec2 f = fract(t);
  vec2 i = floor(t);
  vec2 w0 = (1.0 - f) * (1.0 - f) * (1.0 - f) / 6.0;
  vec2 w1 = (4.0 - 6.0 * f * f + 3.0 * f * f * f) / 6.0;
  vec2 w3 = f * f * f / 6.0;
  vec2 w2 = 1.0 - w0 - w1 - w3;
  vec2 s0 = w0 + w1, s1 = w2 + w3;
  vec2 o0 = (i - 1.0 + w1 / s0 + 0.5) / res;
  vec2 o1 = (i + 1.0 + w3 / s1 + 0.5) / res;
  return (terHeight(vec2(o0.x, o0.y)) * s0.x + terHeight(vec2(o1.x, o0.y)) * s1.x) * s0.y
       + (terHeight(vec2(o0.x, o1.y)) * s0.x + terHeight(vec2(o1.x, o1.y)) * s1.x) * s1.y;
}
#endif
vec2 terUV(vec2 xz) { return (xz - u_ts_origin) / (2.0 * u_ts_half) + 0.5; }
// wind-streaked capillary ripples (stretched along the wind) over slower swells
float waterH(vec2 p, float t) {
  vec2 w = vec2(p.x * 0.7 + p.y * 0.15, p.y * 1.4) ;            // mildly anisotropic: cat's-paws stretched along the wind
  // A sheltered alpine lake, not a sea. The swell carries what movement there is and the
  // two capillary octaves are most of the way out: at their old weights the whole surface
  // was in motion to the horizon, which is chop, and chop is what stops a lake reading as
  // one sheet of water with a mountain in it.
  return 0.26 * gnoise(w * 0.9 + vec2(t * 0.05, t * 0.3)) + 0.075 * gnoise(p * 2.3 - vec2(t * 0.04, -t * 0.055)) + 0.028 * gnoise(p * 6.0 + vec2(t * 0.7, t * 0.24));
}
// What is under a rippled surface is seen through a spread of directions, one per ripple, and
// the spread on the far side widens with the depth below: a fish 0.5 m down is soft, the shelf
// at a metre and a half softer. One read of the scene's mips, r pixels wide (taps on a disc
// left ghost copies of a wader's fingers); narrowed by how much of its footprint finds something
// above the surface - the near bank, a wader's dry shoulders - or it would smear into the water.
vec3 underBlur(vec2 uv, vec3 c0, float r, float surfY) {
  float clear = 1.0;
  for (int i = 0; i < 4; i++) {
    vec2 tuv = clamp(uv + vec2(i < 2 ? -r : r, (i % 2) == 0 ? -r : r) / u_screen, 0.001, 0.999);
    vec4 tp = u_inv_vp * vec4(tuv * 2.0 - 1.0, depthClip(texture(u_depth, tuv).r), 1.0);
    if (tp.y / tp.w > surfY) clear -= 0.25;
  }
  if (clear <= 0.0) return c0;
  return sane(textureLod(u_scene, uv, log2(r) * clear).rgb);
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
  if (u_wet_on > 0.5 && wetAt(v_wpos.xz) < 0.5) discard;
  vec3 v = normalize(u_cam_pos - v_wpos);
  float dist = length(u_cam_pos - v_wpos);
  vec3 n = rippleNormal(v_wpos.xz, u_time);
  n = normalize(mix(n, vec3(0, 1, 0), smoothstep(60.0, 400.0, dist)));   // flat sooner: past a few tens of metres a still lake has no texture at all
  // ---- A BODY IN THE WATER ------------------------------------------------------------
  // You waded into a mountain lake and the surface did not notice. Rings spreading from the
  // legs and a patch of churn around them is the whole of it, and it is the difference
  // between standing in water and standing in a picture of water.
  //
  // Applied AFTER the distance flattening on purpose: the flattening is there because a
  // sheltered lake really is glass at forty metres, but what you yourself are doing to the
  // water is by definition within arm's reach, and it must not be flattened away.
  if (u_wade.z > 0.0) {
    float rd = length(v_wpos.xz - u_wade.xy);
    // rings travelling outward, dying off within a few metres
    float ring = sin(rd * 6.5 - u_time * 8.0) * exp(-rd * 0.5);
    // and the disturbed patch right at the body, which is not a ring but a mess
    float churn = exp(-rd * 1.8) * (sin(u_time * 13.0 + rd * 9.0) * 0.5 + 0.5);
    vec2 away = (rd > 1e-3) ? (v_wpos.xz - u_wade.xy) / rd : vec2(1.0, 0.0);
    float amp = u_wade.z * (ring * 0.9 + churn * 0.7);
    n = normalize(n + vec3(away.x * amp, 0.0, away.y * amp) * 0.55);
  }
  // how deep the ground is under this pixel: from the scene depth
  vec2 suv = gl_FragCoord.xy / u_screen;
  float sd = texture(u_depth, suv).r;
  vec4 gp = u_inv_vp * vec4(suv * 2.0 - 1.0, depthClip(sd), 1.0);
  vec3 ground = gp.xyz / gp.w;
  float depthBelow = clamp(v_wpos.y - ground.y, 0.0, 10.0);
  float alongRay = length(ground - v_wpos);
  // What the depth found may not be the bed: a fish, or the legs of someone wading, stands
  // clear of the ground it is over. The light to it still crosses depthBelow of water, but
  // the shore's terms - the wash, the lap and the soft edge, which exist to hide where the
  // plane cuts the BANK - read the bed under this pixel instead. Keyed off the object, they
  // laid the shoreline's foam over every fish within 35 cm of the top and the wader's hips,
  // and faded the surface away over a shallow fish, which then lay on the water unreflected.
  // Past half a metre of water to what was hit, neither term reaches it, so nothing is read.
  float body = 0.0;
  float standing = 0.0;      // the same test at any depth the water lets anything through: the veil below
  float shoreBelow = depthBelow;
  float shoreRay = alongRay;
  if (dist < 250.0 && depthBelow < 3.0 && ground.y < v_wpos.y) {
    float lift = ground.y - terHeightSmooth(terUV(ground.xz));
    standing = smoothstep(0.15, 0.35, lift) * smoothstep(250.0, 200.0, dist);
  }
  if (depthBelow < 0.5 && standing > 0.0) {
    body = standing;
    float bedBelow = clamp(v_wpos.y - terHeightSmooth(terUV(v_wpos.xz)), 0.0, 10.0);
    shoreBelow = mix(depthBelow, bedBelow, body);
    shoreRay = mix(alongRay, max(alongRay, bedBelow), body);
  }
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
  float lap = 0.5 + 0.5 * sin(shoreBelow * 9.0 - u_time * 1.6 + 2.0 * gnoise(v_wpos.xz * 0.8 + u_time * 0.2));
  float fdet = fbm(v_wpos.xz * 7.0 - u_time * 0.35, 3) * 0.5 + 0.5;      // fine bubbles
  float fmid = fbm(v_wpos.xz * 2.6 + u_time * 0.5, 3) * 0.5 + 0.5;
  float fedge = fbm(v_wpos.xz * 1.4 - u_time * 0.3, 2) * 0.5 + 0.5;
  // a still alpine lake has a wet line, not surf: the wash is thin (the last 0.35 m of
  // depth) and faint, and the terrain runs the same fields at the same strength
  foam += smoothstep(0.35, 0.0, shoreBelow) * (0.12 * smoothstep(0.30, 0.72, fmid) + 0.10 * smoothstep(0.55, 0.95, lap) * smoothstep(0.22, 0.6, fedge)) * (0.55 + 0.75 * fdet);
  // the lap is a near-field detail: from a distance a lake's edge is a line, not a surf
  foam *= smoothstep(120.0, 15.0, dist);
  // the wash dies where the surface meets the ground, so it cannot end on a hard line
  foam *= smoothstep(0.0, 0.5, shoreRay);
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
  vec4 rgp = u_inv_vp * vec4(ruv2 * 2.0 - 1.0, depthClip(rd), 1.0);
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
  // the ripples' spread, SPREAD metres a metre of depth, in pixels at this distance; only where
  // any of the bed still comes through (past that the read would soften what is not seen)
  const float SPREAD = 0.04;
  float vd = -(u_view * vec4(v_wpos, 1.0)).z;
  float spreadPx = min(SPREAD * depthBelow * 0.5 * u_screen.y * u_proj[1][1] / max(vd, 0.5), 3.0);
  if (spreadPx > 0.75 && trans.b > 0.03) { bed = underBlur(ruv2, bed, spreadPx, v_wpos.y); }
  vec3 tint = vec3(0.030, 0.085, 0.105) * skyIrradiance(vec3(0, 1, 0)) * 1.15;   // Maroon Lake: deep, dark blue-green, not turquoise
  // The bed comes here already wet (terrain.frag's `wet`, about 0.6) and under a film of the lake's
  // colour (`film`, about half its albedo); a fish, a wader's legs or a rock on the bed come lit as
  // if in air, and absorption alone left a trout half a metre down brighter than the gravel round
  // it, golden and un-tinted, lying ON the lake. What stands clear of the bed is darkened as a wet
  // surface is (a surface under water loses what air would have reflected) and veiled by its path.
  float under = standing * smoothstep(0.0, 0.1, depthBelow);
  vec3 through = bed * trans * (1.0 - 0.3 * under) + tint * (1.0 - trans);
  through = mix(through, tint, under * 0.4 * (1.0 - exp(-0.7 * pathLen)));
  // ---- surface -------------------------------------------------------------------
  // How much of what you see is the sky and how much is the bottom. The fresnel term is
  // physical and stays; what changed is the weight it is given and, more to the point, the
  // CEILING. At 0.86 the surface went to a near-total mirror as soon as you looked along it,
  // which is true of a sea and is why you could stand at the shore of a lake nine metres
  // deep and never see into it. At 0.70 the bed is there at every angle you actually stand
  // at, and the mirrored Bells are still the thing you see across the water.
  shadow *= sunZone(v_wpos);   // no glitter or sunlit foam inside a light zone
  vec3 col = mix(through, refl, clamp(F * 0.85 + 0.03, 0.0, 0.70)) + u_sun_color * glitter * F * shadow;
  col = mix(col, vec3(0.7, 0.75, 0.75) * (skyIrradiance(vec3(0, 1, 0)) * 0.5 + u_sun_color * 0.08 * shadow), clamp(foam, 0.0, 1.0));
  col = applyFog(col, v_wpos, dist);
  // Soft edge measured ALONG THE VIEW RAY, not vertically. Vertical depth collapses to
  // zero over a fraction of a pixel when the surface is seen edge-on, which is exactly
  // the low, near-the-waterline view where the plane's silhouette turns into a hard
  // glassy line. The distance from the surface to the bed along the ray stays a smooth
  // quantity at any angle, so the water dissolves into the ground it meets instead.
  float soft = smoothstep(0.0, 0.5, shoreRay);
  col = mix(bed, col, soft);
  o_color = vec4(sane(col), 1.0);
}
