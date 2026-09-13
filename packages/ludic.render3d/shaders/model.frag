in vec3 v_wpos;
in vec3 v_nrm;
in vec2 v_uv;
in float v_seed;
in vec2 v_rot;
in float v_hull;
uniform float u_model_h;
out vec4 o_color;
uniform sampler2D u_diff;
uniform sampler2D u_nrm;
uniform sampler2D u_arm;
uniform mat4 u_view;
uniform vec3 u_tint;
uniform float u_rough_scale;
uniform float u_emissive;     // self-lit (a flame): albedo added back after shading
#ifdef BLADE
uniform vec3 u_blade_base;
uniform vec3 u_blade_tip;
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
#endif
  vec3 N = normalize(v_nrm);
  if (!gl_FrontFacing && v_hull >= 0.0) N = -N;
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
  alb = mix(u_blade_base, u_blade_tip, t * t) * regionTint(v_wpos, 0.35);
  float dry = smoothstep(0.7, 0.8, fract(v_seed * 3.17));
  alb = mix(alb, vec3(0.40, 0.36, 0.13) * (0.45 + 0.55 * t), dry * 0.75);
  float patchy = fbm(v_wpos.xz * 0.045, 3) * 0.5 + 0.5;
  alb *= mix(vec3(0.7, 0.8, 0.55), vec3(1.1, 1.05, 0.85), patchy);
  // a far tuft is a patch of the meadow, darker than a lit blade tip and never straw
  if (v_hull < 0.0) alb = mix(u_blade_base, u_blade_tip, 0.45) * regionTint(v_wpos, 0.35) * mix(vec3(0.7, 0.8, 0.55), vec3(1.1, 1.05, 0.85), patchy) * 0.72;
  // a rounded cross-section reads softer than a flat card
  vec3 side = normalize(cross(N, vec3(0.0, 1.0, 0.0)) + vec3(1e-4));
  n = (v_hull < 0.0) ? N : normalize(N + side * (v_uv.x * 2.0 - 1.0) * 0.6);
  arm = vec3(mix(0.2, 1.0, t * t), 0.85, 0.0);
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
  vec4 d = texture(u_diff, v_uv);
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
  n = normalize(mix(n, N, smoothstep(30.0, 120.0, dist)));
  alb = d.rgb;
  // a crown's interior is occluded by its own cards
  if (u_model_h > 2.0) arm.r *= mix(0.5, 1.0, v_hull);
#endif
  alb *= u_tint * (0.85 + 0.3 * fract(v_seed * 7.13));
#ifdef CARD
  // a card is its own caster: look up the shadow a little above and in front of it, and let
  // light bleed through the thin clump as real grass does
#ifdef CHEAP
  float shadow = cloudShadow(v_wpos) * terrainShadow(v_wpos);
#else
  float shadow = mix(1.0, sunShadow(v_wpos + N * 0.1 + vec3(0.0, 0.2, 0.0), N, viewDepth), 0.55);
#endif
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
  float thin = 1.0 - smoothstep(30.0, 140.0, dist);
  // a dense crown of cards is not a thin leaf: much less light comes through it
  if (u_model_h > 2.0) thin *= 0.3;
  col += alb * u_sun_color * (0.14 * back + 0.05 * wrap) * thin * shadow * cloudShadow(v_wpos);
  col += alb * skyIrradiance(vec3(0, 1, 0)) * 0.12 * arm.r;
#endif
  col += alb * u_emissive;
  if (any(isnan(col))) col = vec3(0.0);
  col = applyFog(col, v_wpos, dist);
#ifdef CARD
  o_color = vec4(sane(col), cardAlpha);
#else
  o_color = vec4(sane(col), meshAlpha);
#endif
}
