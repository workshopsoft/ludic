in vec3 v_wpos;
in vec3 v_nrm;
in vec2 v_uv;
in vec4 v_col;
in float v_seed;
in vec2 v_rot;
in float v_hull;
in float v_quake;   // an aspen leaf turning its pale side up
in float v_near;    // 0 in the camera's face, 1 past arm's length (NEAR_FADE)
#if defined(FOLIAGE) && !defined(BLADE)
in float v_lh;      // height above the model's base (model.vert)
#endif
uniform float u_model_h;
out vec4 o_color;
uniform sampler2D u_diff;
// a glTF material's factors, as 1 - factor (a program never given them reads 1) and its emission
uniform vec4 u_fac_base_inv;
uniform vec2 u_fac_mr_inv;
uniform vec3 u_fac_emis;
uniform sampler2D u_nrm;
uniform sampler2D u_arm;
uniform mat4 u_view;
uniform vec3 u_tint;
uniform float u_rough_scale;
uniform float u_emissive;     // self-lit (a flame): albedo added back after shading
#ifdef GBLADE
in vec3 v_tint;               // grass.vert's colour field (the mesh-shader and scatter blades work it out here)
#endif
#ifdef BLADE
uniform vec3 u_blade_base;
uniform vec3 u_blade_tip;
uniform sampler2D u_blade_tex;   // straightened photographic blades, side by side
uniform float u_blade_cols;      // how many are in it
uniform float u_blade_tex_on;
// the grass kind (grass_kind.ludic, grass_bind_look): the scatter's blade layers bind it too
uniform vec4 u_gk_seed;          // gone to seed: colour, and how far a seeded blade goes to it
uniform vec4 u_gk_look;          // seed_lo, seed_hi (the share gone to seed), tuft_mix, tuft_shade
uniform vec4 u_gk_mat;           // ao_root, roughness
#endif
#ifdef CARD
uniform float u_cull;        // the layer's cull distance (m); 0 = none
#endif

mat3 cotangentFrame(vec3 N, vec3 p, vec2 uv) {
  vec3 dp1 = dFdx(p), dp2 = dFdy(p);
  vec2 duv1 = dFdx(uv), duv2 = dFdy(uv);
  vec3 dp2perp = cross(dp2, N), dp1perp = cross(N, dp1);
  vec3 T = dp2perp * duv1.x + dp1perp * duv2.x;
  vec3 B = dp2perp * duv1.y + dp1perp * duv2.y;
  float invmax = inversesqrt(max(dot(T, T), dot(B, B)) + 1e-12);
  return mat3(T * invmax, B * invmax, N);
}

void main() {
#ifndef EQ_PASS
  // (the EQ_PASS variant draws over the foliage prepass: any discard at all would switch
  //  early depth rejection off and bring the overdraw back, and the prepass has already
  //  cut both the clip plane and the alpha)
  if (v_wpos.y < u_clip_y) discard;
#ifdef NEAR_FADE
  // the same dither as the prepass, for the draws that have no prepass in front of them
  if (v_near < 0.999 && v_near < fract(sin(dot(gl_FragCoord.xy, vec2(12.9898, 78.233))) * 43758.5453)) discard;
#endif
#endif
  vec3 N = normalize(v_nrm);
  if (!gl_FrontFacing && v_hull >= 0.0) N = -N;
#ifdef BLADE
  // A blade is thin and two-sided: the sun lights whichever face it reaches (the other glows
  // through, below). Faced away from the sun, half the meadow was lit by the sky alone.
  if (dot(N, u_sun_dir) < 0.0) N = -N;
#endif
#ifdef CARD
  // a baked card: albedo with coverage (premultiplied mips), normal in the card's own frame
  vec4 ca = texture(u_diff, v_uv);
  float rawA = ca.a;
  ca.rgb /= max(ca.a, 1e-3);
#ifdef SHADOW_PASS
  if (ca.a < 0.3) discard;
  float cardAlpha = 1.0;
  return;
#else
  float cov = (ca.a - 0.4) / max(fwidth(ca.a), 1e-4) + 0.5;
  if (cov < 0.02) discard;
  float cardAlpha = clamp(cov, 0.0, 1.0);
#endif
#endif
  float dist = length(v_wpos - u_cam_pos);
  float viewDepth = -(u_view * vec4(v_wpos, 1.0)).z;
#if defined(CARD) && !defined(SHADOW_PASS)
  // A clump card at 400 m is a two-pixel disc of pure leaf colour on whatever the ground
  // is doing — on dark scree it glows. Dissolve toward the cull distance: the carpet
  // drape on the ground carries the meadow's colour from there on.
  if (u_cull > 1.0) cardAlpha *= 1.0 - smoothstep(u_cull * 0.55, u_cull, dist);
  if (cardAlpha < 0.02) discard;
#endif
  vec3 alb;
  vec3 n;
  vec3 arm;
  float meshAlpha = 1.0;
#ifdef BLADE
  // a procedural blade: dark at the root, lighter at the tip; some blades gone to seed
  float t = clamp(v_uv.y, 0.0, 1.0);
  // most of a blade is its own green, only the sheath darker: t*t held the lower two thirds at the
  // root colour (0.14, darker than the ground), and a meadow of those reads as dark wire
#ifndef GBLADE
  vec3 field = regionTint(v_wpos, 0.35);
  float patchy = fbm(v_wpos.xz * 0.045, 3) * 0.5 + 0.5;
  field *= mix(vec3(0.7, 0.8, 0.55), vec3(1.1, 1.05, 0.85), patchy);
#else
  vec3 field = v_tint;
#endif
  alb = mix(u_blade_base, u_blade_tip, smoothstep(0.0, 0.55, t)) * field;
  float dry = smoothstep(u_gk_look.x, u_gk_look.y, fract(v_seed * 3.17));
  alb = mix(alb, u_gk_seed.rgb * (0.45 + 0.55 * t), dry * u_gk_seed.w);
  // A REAL BLADE, if the game gave us one. Each blade picks a column of the atlas from
  // its own seed and runs v from sheath to tip, so a meadow is eight different plants
  // rather than one plant ten thousand times. The photograph carries the midrib, the
  // olive-to-straw run and the dry browning; the gradient above stays as the tint that
  // the season and the lushness drive, so nothing that used to control the colour stops
  // working - the picture multiplies it rather than replacing it.
  if (u_blade_tex_on > 0.5) {
    float col = floor(fract(v_seed * 7.31) * u_blade_cols);
    vec2 buv = vec2((col + clamp(v_uv.x, 0.0, 1.0)) / u_blade_cols, 1.0 - t);
    vec3 photo = texture(u_blade_tex, buv).rgb;
    // Normalised by the atlas's OWN MEAN LUMINANCE - a measured constant, 0.3736 over the
    // opaque pixels - and not by each pixel's mean. Dividing by the per-pixel mean was the
    // bug: it cancels exactly the thing the photograph was fetched for. What survives is
    // the hue ratio, so every blade comes back out at the same brightness and the midrib,
    // the dry browning and the sheath-to-tip run all vanish. It looked like a faint tint
    // over the old procedural blade, which is precisely what it was.
    // Blended, not applied whole. At full strength a photo pixel brighter than the
    // atlas's mean is multiplied by up to 1.9, and the bright blades came out white -
    // straws in a green sward. Three quarters of the photograph keeps the midrib, the
    // browning and the sheath-to-tip run and leaves the extremes alone.
    // CLAMPED. The atlas's mean luminance is 0.3736, so a blade pixel brighter than the
    // mean is multiplied by up to 2.7 and comes out white - and a white blade is the one
    // thing grass never is. Holding the factor to 1.15 keeps the midrib and the browning,
    // which are the parts of the photograph worth having, and refuses the bleach.
    vec3 g = photo * (1.0 / 0.3736);
    alb *= mix(vec3(1.0), min(g, vec3(1.15)), 0.85);
  }
  // a far tuft is a patch of the meadow, darker than a lit blade tip and never straw
  if (v_hull < 0.0) alb = mix(u_blade_base, u_blade_tip, u_gk_look.z) * field * u_gk_look.w;
  // a rounded cross-section reads softer than a flat card
  vec3 side = normalize(cross(N, vec3(0.0, 1.0, 0.0)) + vec3(1e-4));
  n = (v_hull < 0.0) ? N : normalize(N + side * (v_uv.x * 2.0 - 1.0) * 0.6);
  // and a sward is lit as a mass leaning to the sky: a level normal took the light at a graze
  n = normalize(n + vec3(0.0, 0.45, 0.0));
  // A blade's own ambient occlusion. This was mix(0.2, 1.0, t*t): 80% occluded at the
  // sheath and still 60% at half height, because t*t holds the curve down. Measured in a
  // walking-distance shot the blades came out at 24-31 of 255 against a ground of 143 -
  // near-black on light earth - and at that contrast the eye reads every blade as a hard
  // EDGE rather than as a mass of vegetation, whatever shape it is. No albedo can answer
  // an occlusion term; grass albedo is capped near 0.5 and this was dividing it by five.
  // A blade is a thin thing standing in open air: shaded at the root by its neighbours,
  // not buried.
  arm = vec3(mix(u_gk_mat.x, 1.0, t), u_gk_mat.y, 0.0);
#elif defined(CARD)
  // thin grass is lit from either side: face the card toward the sun before shading
  if (dot(N, u_sun_dir) < 0.0) N = -N;
  // the normal atlas is premultiplied by coverage like the albedo (see impostor.frag)
  vec4 cn = texture(u_nrm, v_uv) / max(rawA, 1e-3);
  cn = clamp(cn, 0.0, 1.0);
  vec3 bn = cn.rgb * 2.0 - 1.0;
  // the card frame: right along the quad, up, and out of the quad
  vec3 T = normalize(cross(vec3(0.0, 1.0, 0.0), N) + vec3(1e-5));
  n = normalize(T * -bn.x + vec3(0.0, 1.0, 0.0) * bn.y + N * max(abs(bn.z), 0.25));
  n = normalize(mix(n, normalize(N + vec3(0.0, 0.8, 0.0)), 0.35));
  // A clump is a few pixels at 100 m: what the eye reads there is the hillside's shading,
  // and a card facing the sun on a slope facing away from it glows against the ground
  // like a sticker. Light it with the ground's own normal as it recedes (as the blades
  // already do), so cover and terrain darken together.
#ifdef CHEAP
  n = terrainNormalAt(v_wpos);
#else
  n = normalize(mix(n, terrainNormalAt(v_wpos), smoothstep(25.0, 90.0, dist)));
#endif
  alb = ca.rgb * 1.05 * regionTint(v_wpos, 0.8);
  arm = vec3(mix(0.5, 1.0, clamp(v_uv.y, 0.0, 1.0)) * (0.6 + 0.4 * cn.a), 0.85, 0.0);
#elif defined(FLOWER)
  // a lupine: green stem (uv.x < 1), violet florets above (uv.x in [1,2]), tinted per plant
  float hue = fract(v_seed * 5.71);
  float vy = clamp(v_uv.y, 0.0, 1.0);
  vec3 violet = mix(vec3(0.07, 0.03, 0.32), vec3(0.28, 0.06, 0.36), hue);
  vec3 tipc = mix(violet, vec3(0.5, 0.3, 0.7), 0.3);
  if (v_uv.x >= 2.0) {
    alb = vec3(0.05, 0.13, 0.025) * (0.7 + 0.6 * vy);
  } else if (v_uv.x >= 1.0) {
    float f = fract(v_uv.x);
    alb = mix(violet, tipc, vy) * (0.65 + 0.35 * abs(f * 2.0 - 1.0));
    // florets as little lobes: darker between them, a paler lip on each
    float lobe = 0.55 + 0.45 * abs(sin(vy * 9.0 + f * 6.0));
    alb = mix(alb * lobe, vec3(0.55, 0.45, 0.75), 0.18 * smoothstep(0.6, 1.0, lobe));
  } else {
    alb = vec3(0.07, 0.16, 0.03);
  }
  vec3 side = normalize(cross(N, vec3(0.0, 1.0, 0.0)) + vec3(1e-4));
  n = normalize(N + side * (fract(v_uv.x) * 2.0 - 1.0) * 0.7);
  arm = vec3(0.9, 0.7, 0.0);
#else
  vec4 d = texture(u_diff, v_uv) * (vec4(1.0) - u_fac_base_inv) * v_col;
#ifdef ALPHA_TEST
  // A needle sprig's alpha averages away in the mips, so a plain 0.5 test strips the
  // crown bare past 50 m. Scale the alpha back up by the mip level (Castano's alpha
  // mipmaps, done at sample time) and sharpen the edge with its screen derivative, then
  // let alpha-to-coverage resolve it.
  float lod = textureQueryLod(u_diff, v_uv).x;
  float a = min(d.a * (1.0 + 0.45 * max(lod, 0.0)), 1.0);
  float cov = (a - 0.4) / max(fwidth(a), 1e-4) + 0.5;
  if (cov < 0.02) discard;
  meshAlpha = clamp(cov, 0.0, 1.0);
#endif
  vec3 tn = texture(u_nrm, v_uv).rgb * 2.0 - 1.0;
  mat3 tbn = cotangentFrame(N, v_wpos, v_uv);
  n = normalize(tbn * tn);
  arm = texture(u_arm, v_uv).rgb;
  arm.gb *= vec2(1.0) - u_fac_mr_inv;
  n = normalize(mix(n, N, smoothstep(30.0, 120.0, dist)));
  alb = d.rgb;
  // a crown's interior is occluded by its own cards
  if (u_model_h > 2.0) arm.r *= mix(0.5, 1.0, v_hull);
#endif
  alb *= u_tint * (0.85 + 0.3 * fract(v_seed * 7.13));
#if defined(FOLIAGE) && !defined(BLADE)
  // A fern or a clump stands IN the sward, and its low leaves see the sky through it no more than the
  // blades beside them do. Its own occlusion map knows nothing of the grass around it, so by night -
  // when the sky's light is nearly all the light there is - it stood out lit against the meadow.
  if (u_model_h <= 2.0) arm.r *= mix(0.35, 1.0, smoothstep(0.0, 0.9, v_lh));
#endif
  // The quake made visible. A turning aspen leaf shows its pale, almost white underside, so
  // the crown does not merely move - it GLITTERS, leaf by leaf, and that is what reads at a
  // distance and in a still frame. Toward the viewer is the pale side; away is the face.
  // The quake, as a LIGHTENING rather than a repaint. This used to mix up to 75% toward
  // a fixed near-white (0.42,0.45,0.33), which was written for a hand-painted leaf atlas
  // that had no pale underside of its own. On a photographed leaf it does not read as a
  // turning leaf at all - it reads as parts of the tree going WHITE, because that is
  // exactly what it does: it replaces three quarters of the leaf's colour with a constant.
  // Nothing in a wood turns white in the sun. A real turning leaf shows a paler, greyer
  // version of ITSELF, so lift and desaturate the leaf's own colour instead.
  if (v_quake > 0.0) {
    float q = min(v_quake * 2.6, 0.75);
    float l = dot(alb, vec3(0.2126, 0.7152, 0.0722));
    alb = mix(alb, mix(alb, vec3(l), 0.45) * 1.30, q);
  } else if (v_quake < 0.0) {
    alb *= 1.0 + v_quake * 0.28;   // the dark half stays gentle: a crown should shimmer, not flicker
  }
#if defined(FOLIAGE) && !defined(BLADE)
  // Per-plant HUE, not only per-plant brightness. The line above varies value by +-15% and
  // nothing else, so a stand of one species was one colour at fifteen different exposures -
  // and a real stand is not: neighbouring trees of the same species sit anywhere from
  // yellow-green to blue-green depending on age, aspect and how dry the ground under them is.
  // Trading red against blue is a hue rotation about green, which is the axis that matters for
  // foliage and costs two multiplies. Blades are excluded: they get their own patchy field
  // and regionTint already, and doubling up on them reads as noise rather than variety.
  float hj = fract(v_seed * 3.71) - 0.5;
  alb *= vec3(1.0 + 0.20 * hj, 1.0, 1.0 - 0.20 * hj);
#endif
#ifdef CARD
  // a card is its own caster: look up the shadow a little above and in front of it, and let
  // light bleed through the thin clump as real grass does
#ifdef CHEAP
  float shadow = cloudShadow(v_wpos) * terrainShadow(v_wpos);
#else
  float shadow = mix(1.0, sunShadow(v_wpos + N * 0.1 + vec3(0.0, 0.2, 0.0), N, viewDepth), 0.55);
#endif
#elif defined(BLADE)
  // A blade stands within a shadow texel of the ground under it, and biased along its own
  // (level) normal it read the terrain as its caster: the whole meadow in shadow, dark wire.
  // Looked up a hand's width up, along the ground's up, trees and rocks still shade it.
  // past arm's length a blade is a pixel or two wide: one tap is what a soft filter averages to
  float shadow = (dist < 8.0) ? sunShadow(v_wpos + vec3(0.0, 0.25, 0.0), vec3(0.0, 1.0, 0.0), viewDepth)
                              : sunShadowCheap(v_wpos + vec3(0.0, 0.25, 0.0), vec3(0.0, 1.0, 0.0), viewDepth);
#else
  float shadow = sunShadow(v_wpos, N, viewDepth);
#endif
#ifdef FOLIAGE
  // leaves and needles are matte at every angle: no grazing Fresnel on a two-sided card
  float roughF = 1.0;
#else
  float roughF = clamp(arm.g * u_rough_scale, 0.35, 1.0);
#endif
  vec3 col = shade(v_wpos, n, alb, roughF, 0.0, arm.r, shadow, viewDepth);
#ifdef FOLIAGE
  // thin-leaf translucency: light leaking through toward the viewer, and a wrapped diffuse
  vec3 v = normalize(u_cam_pos - v_wpos);
  float back = pow(max(dot(-v, u_sun_dir), 0.0), 3.0);
  float wrap = max(dot(N, u_sun_dir) * 0.5 + 0.5, 0.0);
  // Only a thin leaf a few metres away is translucent. A clump card at 200 m is a whole
  // bush in two pixels, and giving it the leaf's glow toward the sun painted the
  // backlit hillsides with lime discs. The term fades out with distance.
  // A backlit stand glows for as far as you can see it, not 140 m. The cap below is what
  // keeps a two-pixel clump card at distance from becoming a lime disc.
  float thin = 1.0 - smoothstep(60.0, 260.0, dist);
  // a dense crown of cards is not a thin leaf: much less light comes through it
  if (u_model_h > 2.0) thin *= 0.45;
  col += alb * u_sun_color * (0.24 * back + 0.07 * wrap) * thin * shadow * cloudShadow(v_wpos);
  col += alb * skyIrradiance(vec3(0, 1, 0)) * 0.12 * arm.r;
  // ---- leaf sheen ---------------------------------------------------------------------
  // A LEAF IS NOT MATTE. Foliage roughness is pinned to 1.0 just above and grazing Fresnel
  // is switched off, so nothing green in this game has ever had a highlight - and the glint
  // off wet needles and waxy leaves is most of what makes a real stand look alive rather
  // than painted. The reason it was switched off is real, though: a crown is card quads, and
  // at a grazing angle the card's normal is a lie, so a plain specular lobe frosted whole
  // crowns white against the sky.
  //
  // So the sheen is added back as its own term and gated on exactly that: it fades out as
  // the card turns edge-on (NoV), which is where its normal stops meaning anything. A tight
  // lobe for the glint, a weak wide one for the waxy rim, and nothing at all at the angles
  // that used to frost.
  {
    vec3 vv = normalize(u_cam_pos - v_wpos);
    vec3 hh = normalize(vv + u_sun_dir);
    float NoH = max(dot(n, hh), 0.0);
    float NoV = max(dot(n, vv), 0.0);
    float sheen = pow(NoH, 26.0) * 0.55 + pow(1.0 - NoV, 4.0) * 0.05;
    sheen *= smoothstep(0.10, 0.42, NoV);
#ifdef BLADE
    sheen *= 0.2;   // a sward seen from above is tips edge-on to the sun: the leaf's glint frosted them white
#endif
    col += u_sun_color * sheen * shadow * cloudShadow(v_wpos) * 0.4 * (0.45 + 0.55 * arm.r);
  }
#endif
  col += alb * u_emissive;
  if (any(isnan(col))) col = vec3(0.0);
  col += u_fac_emis;
  col = applyFog(col, v_wpos, dist);
#ifdef CARD
  o_color = vec4(sane(col), cardAlpha);
#else
  o_color = vec4(sane(col), meshAlpha);
#endif
}
