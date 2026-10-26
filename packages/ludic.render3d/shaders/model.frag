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
uniform vec2 u_mr_scale;      // the metal/roughness texture's uv scale (KHR_texture_transform; 0 or 1: none)
uniform vec2 u_fac_coat;      // clear coat: factor, roughness (KHR_materials_clearcoat; 0: none)
uniform vec3 u_fac_emis;
uniform sampler2D u_nrm;
uniform sampler2D u_arm;
uniform mat4 u_view;
uniform vec3 u_tint;
uniform float u_rough_scale;
uniform float u_emissive;     // self-lit (a flame): albedo added back after shading
#ifdef FABRIC
// A MetaHuman garment as Epic's M_fabric_simpler builds it (its graph read from the editor, MaterialEditingLibrary): the colours
// from the garment's masks, two materials' tiled variation, fuzz and the trims' material C. u_fp (actor_fabric, prim.fab):
//  0..3  colour 1, colour 2, material B's, material C's (linear; B's w: its mix of colours 1 and 2 when it takes them, -1 its own;
//        colour 2's w: the pilling normal's strength)
//  4..7  material A: (detail tiling, u distort, v distort, macro tiling), (detail variation, macro, wear strengths, overlay amount),
//        (exponent low, high, detail normal strength, sculpted detail 0/1), (detail colour overlay, multiply, roughness scale, metallic)
//  8..11 material B: the same
//  12    fuzz on, its amount, its amount on stitches, its exponent
//  13    fuzz power, pilling strength, pilling tiling, wrinkle strength
//  14    wrinkle tiling, the garment normal's strength, the stitches' normal strength, material B on
//  15    material C on, its mask overlay amount, its occlusion multiply, stitches take colour 2 (CustomStitchtx_diffuse_color_2)
//  16    C metal (-1: the map's), C roughness (-1: the map's), C takes material A's colour, on (0: a plain primitive in this
//        program, 1 M_fabric_simpler, 2 the jeans master: its own layout, below)
uniform vec4 u_fp[17];
uniform sampler2D u_fmask;    // the garment's Masks: R wear, G colour 2, B material B, A sculpted detail
uniform sampler2D u_fkit;     // material A's tiled maps: R detail variation, G macro variation, B pilling, A detail colour / its mean / 2
uniform sampler2D u_fdn;      // material A's tiled normals: RG detail, BA wrinkles (x, y in glTF's frame)
uniform sampler2D u_fkitb;    // material B's tiled maps, as u_fkit
uniform sampler2D u_fdnb;     // material B's detail normal in RG, the pilling normal in BA
uniform float u_dither_frame; // the frame's index (0..63): a hair card's dithered opacity moves each frame, for the temporal resolve
#endif
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
uniform vec4 u_gk_mat;           // ao_root, roughness, the flowering share of a forb from its tip
uniform vec4 u_gk_forb_a;        // a forb's flower colours: a third of the forbs each
uniform vec4 u_gk_forb_b;
uniform vec4 u_gk_forb_c;
#endif
#ifdef CARD
uniform float u_cull;        // the layer's cull distance (m); 0 = none
#endif
#ifdef TRANSLUCENT
// a blended actor (actor.ludic, actor_draw_translucent), drawn over the resolved scene with no depth write:
// x = alpha (times the material's), y = the soft-particle fade in metres (0 = none),
// z = the blend (1 over, 2 additive), w = 1 when unlit (base colour x emissive, no sun, sky or shadow)
uniform vec4 u_tr;
uniform sampler2D u_scene_depth;  // the resolved scene's depth (post_depth_copy), for the soft fade
uniform mat4 u_inv_vp;
uniform vec2 u_screen;
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

#ifdef FABRIC
// ---- hair cards (mode 3): Epic's HairShading (HairBsdf.ush) with the cards' transmittance data (InitHairTransmittanceData: legacy
// absorption, a separable R, no backlit), the material M_hair_v4 feeds it (MF_Variation, GetHairColorFromMelanin's absorption) -------
float hairG(float B, float theta) { return exp(-0.5 * theta * theta / (B * B)) / (sqrt(2.0 * PI) * max(B, 0.01)); }
float hairF(float cosT) { float f0 = 0.0465; float m = 1.0 - cosT; return f0 + (1.0 - f0) * m * m * m * m * m; }
// T along the strand, V and L toward the eye and the light: the light it scatters toward the eye (no cosine: the lobes carry it)
vec3 hairShading(vec3 base, float rough, float spec, vec3 T, vec3 V, vec3 L, float area) {
  float r = clamp(rough, 1.0 / 255.0, 1.0);
  float VoL = dot(V, L);
  float sinL = clamp(dot(T, L), -1.0, 1.0);
  float sinV = clamp(dot(T, V), -1.0, 1.0);
  float cosD = cos(0.5 * abs(asin(sinV) - asin(sinL)));
  vec3 Lp = L - sinL * T;
  vec3 Vp = V - sinV * T;
  float cosPhi = dot(Lp, Vp) * inversesqrt(dot(Lp, Lp) * dot(Vp, Vp) + 1e-4);
  float cosHalfPhi = sqrt(clamp(0.5 + 0.5 * cosPhi, 0.0, 1.0));
  float np = 1.19 / cosD + 0.36 * cosD;
  float shift = 0.035;
  float b0 = area + r * r, b1 = area + r * r * 0.5, b2 = area + r * r * 2.0;
  vec3 S = vec3(0.0);
  // R
  float sa = sin(-shift * 2.0), ca = cos(-shift * 2.0);
  float shiftR = 2.0 * sa * (ca * cosHalfPhi * sqrt(1.0 - sinV * sinV) + sa * sinV);
  S += vec3(hairG(b0 * sqrt(2.0) * cosHalfPhi, sinL + sinV - shiftR) * 0.25 * cosHalfPhi * hairF(sqrt(clamp(0.5 + 0.5 * VoL, 0.0, 1.0))) * spec * 2.0);
  // TT
  float a = 1.0 / np;
  float h = cosHalfPhi * (1.0 + a * (0.6 - 0.8 * cosPhi));
  float f = hairF(cosD * sqrt(clamp(1.0 - h * h, 0.0, 1.0)));
  vec3 tp = pow(abs(base), vec3(0.5 * sqrt(max(1.0 - (h * a) * (h * a), 0.0)) / cosD));
  S += hairG(b1, sinL + sinV - shift) * exp(-3.65 * cosPhi - 3.98) * (1.0 - f) * (1.0 - f) * tp;
  // TRT
  float f2 = hairF(cosD * 0.5);
  S += hairG(b2, sinL + sinV - shift * 4.0) * exp(17.0 * cosPhi - 16.78) * (1.0 - f2) * (1.0 - f2) * f2 * pow(abs(base), vec3(0.8 / cosD));
  // the light scattered through many strands: KajiyaKayDiffuseAttenuation's shape (a wrapped term on the normal facing the eye, a third of
  // Kajiya-Kay), with the hair's colour as its albedo. M_hair_v4's cards leave Scatter at 0 (Unreal lights them with the three lobes and
  // the groom's voxel scattering, which cards have none of here); its sqrt(colour) at a scatter of 1 lifted black hair to grey, and the
  // looks' colours (the dye) are the colours Unreal's renders show, which an albedo of them gives back
  float kk = 1.0 - abs(dot(T, L));
  vec3 fakeN = normalize(V - T * dot(V, T) + vec3(0.0, 1e-4, 0.0));
  float nol = clamp((dot(fakeN, L) + 1.0) / 4.0, 0.0, 1.0);
  S += abs(base) * (1.0 / PI) * mix(nol, kk, 0.33);
  return max(S, vec3(0.0));
}
// MF_Variation: the signal to a power the strand's seed picks (1 + v at 0, 1 at 0.5, 1 / (1 + v) at 1)
float hairVar(float v, float sgl, float seed) {
  float t = seed * 2.0;
  float lo = pow(max(sgl, 0.0), 1.0 + v), hi = pow(max(sgl, 0.0), 1.0 / (1.0 + v));
  return mix(mix(lo, sgl, clamp(t, 0.0, 1.0)), hi, clamp(t - 1.0, 0.0, 1.0));
}
// HairAbsorptionToColor / HairColorToAbsorption (B 0.3), HairShadingCommon.ush
const float HAIR_D = 5.969 - 0.215 * 0.3 + 2.532 * 0.09 - 10.73 * 0.027 + 5.574 * 0.0081 + 0.245 * 0.00243;
vec3 hairAbsorption(vec3 c) { vec3 l = log(max(c, vec3(1e-4))) / HAIR_D; return l * l; }
vec3 hairColour(vec3 a) { return exp(-sqrt(a) * HAIR_D); }
#endif

#ifdef FABRIC
// Unreal's Blend_Overlay, a channel at a time
float fabOv(float b, float l) { return b > 0.5 ? 1.0 - 2.0 * (1.0 - b) * (1.0 - l) : 2.0 * b * l; }
vec3 fabOv3(vec3 b, float l) { return vec3(fabOv(b.r, l), fabOv(b.g, l), fabOv(b.b, l)); }
// BlendAngleCorrectedNormals (reoriented normal mapping)
vec3 fabRnm(vec3 b, vec3 a) { b += vec3(0.0, 0.0, 1.0);  a *= vec3(-1.0, -1.0, 1.0);  return b * dot(b, a) / b.z - a; }
vec3 fabN2(vec2 t) { vec2 xy = t * 2.0 - 1.0;  return vec3(xy, sqrt(max(1.0 - dot(xy, xy), 0.0))); }
// MF_NormalStrength: from flat towards the normal
vec3 fabNs(vec3 n, float s) { return mix(vec3(0.0, 0.0, 1.0), n, s); }
// one material's base colour: AvgColorReplace (the detail colour over its mean), then MF_PowerVariation (the colour to an exponent
// the variation picks: low at 0, 1 at 0.5, high at 1) and Blend_Overlay with the variation. The variation is the detail's, the
// macro's and the wear mask's, each from 0.5 by its strength, overlaid in that order
vec3 fabLayer(vec3 avgc, vec4 msk, sampler2D kit, vec4 p0, vec4 p1, vec4 p2, vec4 p3, vec2 duv) {
  vec4 k = texture(kit, duv);
  float macro = texture(kit, v_uv * p0.w).g;
  vec3 det = avgc * (k.a * 2.0);
  vec3 c = mix(det, avgc, p3.x);
  c = mix(c, det * c, p3.y);
  float d = mix(0.5, p2.w > 0.5 ? msk.a : k.r, p1.x);
  float m = mix(0.5, macro, p1.y);
  float w = mix(0.5, msk.r, p1.z);
  float var = fabOv(fabOv(d, m), w);
  float t = var * 2.0;
  float e = mix(mix(p2.x, 1.0, clamp(t, 0.0, 1.0)), p2.y, clamp(t - 1.0, 0.0, 1.0));
  return fabOv3(pow(max(c, vec3(0.0)), vec3(e)), mix(0.5, var, p1.w));
}
#endif

void main() {
#ifndef EQ_PASS
  // (the EQ_PASS variant draws over the foliage prepass: any discard at all would switch
  //  early depth rejection off and bring the overdraw back, and the prepass has already
  //  cut both the clip plane and the alpha)
  if (v_wpos.y < u_clip_y) discard;
#ifndef SHADOW_PASS
  if (fogCut(v_wpos)) discard;   // the fog wall's dissolve (lighting.glsl)
#endif
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
  // A forb in flower among the grass (grass_cull.comp marks one by its seed, plus 2): the top of it is
  // its flower in one of the kind's three colours - a July meadow's colour is its forbs, not its grass
  if (v_seed > 1.5) {
    float fl = smoothstep(1.0 - u_gk_mat.z - 0.04, 1.0 - u_gk_mat.z, t);
    float pick = fract(v_seed * 5.13);
    vec3 fc = pick < 0.34 ? u_gk_forb_a.rgb : (pick < 0.67 ? u_gk_forb_b.rgb : u_gk_forb_c.rgb);
    alb = mix(alb, fc * (0.75 + 0.25 * t), fl);
  }
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
#ifdef TRANSLUCENT
  // the texture's alpha, the material's base alpha and the vertex colour's, times the actor's
  meshAlpha = d.a * u_tr.x;
  if (meshAlpha < 0.002) discard;
#endif
#ifdef ALPHA_TEST
#ifdef FABRIC
  // (a hair card's coverage is its groom's atlas, tested in its own mode below: the colour texture's alpha is not its cut)
  if (u_fp[16].w < 2.5) {
#endif
  // A needle sprig's alpha averages away in the mips, so a plain 0.5 test strips the
  // crown bare past 50 m. Scale the alpha back up by the mip level (Castano's alpha
  // mipmaps, done at sample time) and sharpen the edge with its screen derivative, then
  // let alpha-to-coverage resolve it.
  float lod = textureQueryLod(u_diff, v_uv).x;
  float a = min(d.a * (1.0 + 0.45 * max(lod, 0.0)), 1.0);
  float cov = (a - 0.4) / max(fwidth(a), 1e-4) + 0.5;
  if (cov < 0.02) discard;
  meshAlpha = clamp(cov, 0.0, 1.0);
#ifdef FABRIC
  }
#endif
#endif
  vec3 tn = texture(u_nrm, v_uv).rgb * 2.0 - 1.0;
  mat3 tbn = cotangentFrame(N, v_wpos, v_uv);
  n = normalize(tbn * tn);
  arm = texture(u_arm, v_uv).rgb;
  // the roughness and metal at their own tiling (a car paint's flake noise is its texture 20 times over; the occlusion is not)
  if (u_mr_scale.x > 0.0 && u_mr_scale != vec2(1.0)) arm.gb = texture(u_arm, v_uv * u_mr_scale).gb;
  arm.gb *= vec2(1.0) - u_fac_mr_inv;
#ifdef FABRIC
  vec3 hT = vec3(0.0);
  float hRough = 0.5, hSpec = 0.5, hAO = 1.0;
  if (u_fp[16].w > 2.5) {
    // a hair card (u_fp: 0 the dye (linear), 1 melanin variation fine and rough, the roughness, its variation, 2 Spec0, Spec1, SpecEdge,
    // SpecFront, 3 scraggle, opacity scale and power, 4 the cards' tile in the atlas: u, v, size). The groom's atlases: u_fmask R
    // coverage, G depth, B seed; u_fkit RGB the strand's direction in the card's frame, A its coordinate (1 at the root)
    vec2 auv = (v_uv - u_fp[4].xy) / u_fp[4].z;
    vec4 at = texture(u_fmask, auv);
    vec4 tg = texture(u_fkit, auv);
    float seed = at.b;
    // the sky a strand sees: a strand deep in its clump (the atlas's depth) sees little of it. Unreal shades a groom's sky through its
    // voxelised density (the strands' own occlusion); a card has its clump's depth instead
    hAO = mix(1.0, 0.15, clamp(at.g, 0.0, 1.0));
    // the opacity mask: DitherTemporalAA (the mask plus a sixth of a per-pixel noise, a new pattern each frame) of pow(coverage x scale,
    // power), clipped at M_hair_v4's 0.33
    float op = pow(max(at.r * u_fp[3].y, 0.0), u_fp[3].z);
    float dth = fract(ign(gl_FragCoord.xy) + u_dither_frame * 0.6180340);
    if (op + 0.1666 * dth < 0.33) discard;
    // the colour: the dye's absorption, more or less by the strand (MF_Hair_Color's melanin variation, fine to rough by the roughness)
    float mv = mix(u_fp[1].x, u_fp[1].y, clamp(u_fp[1].z * 2.0, 0.0, 1.0));
    float k = hairVar(mv, 0.5, seed) / 0.5;
    alb = hairColour(hairAbsorption(u_fp[0].rgb) * k);
    hRough = hairVar(u_fp[1].w, u_fp[1].z, seed);
    hSpec = mix(u_fp[2].y, u_fp[2].x, seed) * mix(u_fp[2].z, u_fp[2].w, 0.5);
    // the strand: the atlas's direction in the card's plane on the card's own axes (its u and v), scraggled by the seed
    mat3 hf = cotangentFrame(N, v_wpos, v_uv);
    vec2 tdir = tg.xy * 2.0 - 1.0;
    tdir.x += (seed - 0.5) * u_fp[3].x * 2.0;
    hT = normalize(hf[0] * tdir.x + hf[1] * tdir.y + N * 1e-3);
    n = N;
    arm = vec3(1.0, hRough, 0.0);
    d.rgb = alb;
  } else if (u_fp[16].w > 1.5) {
    // Epic's M_jeans_nrm_custom_master: the denim baked untinted (fabric.py: the pair's colour over its fabric average, Unreal's power
    // and multiply, the stitches white by their SmoothCurve mask) at half in u_diff; the tints multiplied over it by region (u_fmask:
    // R stitches, G rivets, B the leather patch): colour 1 the denim, 2 the stitches, B's the leather, C's the metal. The weave tiled
    // u_fp[4].x times (turned u_fp[4].y turns) and the fuzz u_fp[4].z times over the baked normal, at strengths u_fp[4].w, u_fp[5].x
    vec4 msk = texture(u_fmask, v_uv);
    vec3 tint = mix(mix(mix(u_fp[0].rgb, u_fp[1].rgb, msk.r), u_fp[3].rgb, msk.g), u_fp[2].rgb, msk.b);
    alb = texture(u_diff, v_uv).rgb * 2.0 * tint;
    float ra = u_fp[4].y * 6.2831853;
    vec2 wuv = mat2(cos(ra), -sin(ra), sin(ra), cos(ra)) * (v_uv * u_fp[4].x - 0.5) + 0.5;
    vec3 wn = fabNs(fabN2(texture(u_fdn, wuv).rg), u_fp[4].w);
    vec3 zn = fabNs(fabN2(texture(u_fdn, v_uv * u_fp[4].z).ba), u_fp[5].x);
    vec3 bn = texture(u_nrm, v_uv).rgb * 2.0 - 1.0;
    // (the rivets and the patch keep the baked normal alone, as Unreal's final mix does)
    float plain = clamp(max(msk.g, msk.b), 0.0, 1.0);
    vec3 tn = mix(fabRnm(fabRnm(bn, wn), zn), bn, plain);
    n = normalize(cotangentFrame(N, v_wpos, v_uv) * tn);
    arm = texture(u_arm, v_uv).rgb;
    d.rgb = alb;
  } else if (u_fp[16].w > 0.5) {
    vec4 msk = texture(u_fmask, v_uv);
    vec4 nm = texture(u_nrm, v_uv);
    vec4 ao = texture(u_arm, v_uv);
    float stitch = 1.0 - nm.a;                       // CustomStitch (stored inverted: a map with no alpha has none)
    vec3 c1 = u_fp[0].rgb, c2 = u_fp[1].rgb;
    // material A: colour 1 to colour 2 by the mask's green (or by the stitches), the stitches colour 2 outright
    vec3 avgA = mix(c1, c2, u_fp[15].w > 0.5 ? stitch : msk.g);
    vec2 duvA = v_uv * u_fp[4].yz * u_fp[4].x;
    vec3 col = mix(fabLayer(avgA, msk, u_fkit, u_fp[4], u_fp[5], u_fp[6], u_fp[7], duvA), c2, stitch);
    float rough = u_fp[7].z * ao.g;
    float metal = u_fp[7].w;
    vec3 fn = mix(fabNs(fabN2(texture(u_fdn, duvA).rg), u_fp[6].z), vec3(0.0, 0.0, 1.0), stitch);
    // material B over it by the mask's blue (MatLayerBlend)
    if (u_fp[14].w > 0.5) {
      vec2 duvB = v_uv * u_fp[8].yz * u_fp[8].x;
      // (B_UseAColor: material B's colour is colours 1 and 2 mixed, u_fp[2].w the mix; -1 its own)
      vec3 cB = u_fp[2].w < 0.0 ? u_fp[2].rgb : mix(c1, c2, u_fp[2].w);
      vec3 colB = fabLayer(mix(cB, c2, msk.g), msk, u_fkitb, u_fp[8], u_fp[9], u_fp[10], u_fp[11], duvB);
      vec3 fnB = fabNs(fabN2(texture(u_fdnb, duvB).rg), u_fp[10].z);
      col = mix(col, colB, msk.b);
      rough = mix(rough, u_fp[11].z * ao.g, msk.b);
      metal = mix(metal, u_fp[11].w, msk.b);
      fn = mix(fn, fnB, msk.b);
    }
    // pilling's normal over the materials' (not on the stitches): u_fdnb's BA at the pilling tiling, its strength u_fp[1].w
    if (u_fp[1].w != 0.0) fn = fabRnm(fn, mix(fabNs(fabN2(texture(u_fdnb, v_uv * u_fp[13].z).ba), u_fp[1].w), vec3(0.0, 0.0, 1.0), stitch));
    // pilling: the fibre balls lighten (Blend_Lighten), not on the stitches
    if (u_fp[13].y != 0.0) {
      float pa = texture(u_fkit, v_uv * u_fp[13].z).b;
      col = mix(max(col, pa * avgA * u_fp[13].y), col, stitch);
    }
    // the tiled crease wrinkles over the material's normal
    if (u_fp[13].w != 0.0) fn = fabRnm(fn, fabNs(fabN2(texture(u_fdn, v_uv * u_fp[14].x).ba), u_fp[13].w));
    // the garment's own normal (and its stitches'), with the materials' over it
    vec3 gn = nm.rgb * 2.0 - 1.0;
    vec3 base = fabRnm(fabNs(gn, u_fp[14].y), mix(vec3(0.0, 0.0, 1.0), fabNs(gn, u_fp[14].z), stitch));
    // material C (buttons, zips, trims) over everything by the occlusion map's alpha: no normal of its own
    float ca = u_fp[15].x > 0.5 ? ao.a : 0.0;
    if (ca > 0.0) {
      rough = mix(rough, u_fp[16].y < 0.0 ? ao.g : u_fp[16].y, ca);
      metal = mix(metal, u_fp[16].x < 0.0 ? ao.b : u_fp[16].x, ca);
      fn = mix(fn, vec3(0.0, 0.0, 1.0), ca);
    }
    mat3 ftbn = cotangentFrame(N, v_wpos, v_uv);
    n = normalize(ftbn * fabRnm(base, fn));
    // fuzz on the base materials (the pixel's final normal at a graze, Fresnel with Unreal's 0.04 floor): the colour raised to an
    // exponent below 1
    if (u_fp[12].x > 0.5) {
      float nv = max(dot(n, normalize(u_cam_pos - v_wpos)), 0.0);
      float fr = pow(1.0 - nv, u_fp[13].x) * 0.96 + 0.04;
      col = mix(col, pow(max(col, vec3(0.0)), vec3(u_fp[12].w)), mix(u_fp[12].y, u_fp[12].z, stitch) * fr);
    }
    // material C laid over it
    if (ca > 0.0) {
      vec3 cc = u_fp[16].z > 0.5 ? mix(c1, c2, msk.g) : u_fp[3].rgb;
      col = mix(col, fabOv3(cc, mix(0.5, msk.r, u_fp[15].y)) * mix(1.0, ao.r, u_fp[15].z), ca);
    }
    alb = col;
    arm = vec3(ao.r, clamp(rough, 0.0, 1.0), clamp(metal, 0.0, 1.0));
    d.rgb = alb;
  }
#endif
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
#elif defined(TRANSLUCENT)
  // an unlit glow looks up no shadow
  float shadow = (u_tr.w > 0.5) ? 1.0 : sunShadow(v_wpos, N, viewDepth);
#else
  float shadow = sunShadow(v_wpos, N, viewDepth);
#endif
#ifdef FOLIAGE
  // leaves and needles are matte at every angle: no grazing Fresnel on a two-sided card
  float roughF = 1.0;
#else
  // Down to a near mirror (car paint, chrome, glass, a wet eye). The highlight a curved glossy surface
  // makes is narrower than a pixel at distance and would sparkle without a temporal resolve: the
  // normal's change across the pixel widens it (Kaplanyan 2016, specular antialiasing)
  float roughF = clamp(arm.g * u_rough_scale, 0.05, 1.0);
  {
    vec3 dnx = dFdx(n), dny = dFdy(n);
    float kern = min(0.25 * (dot(dnx, dnx) + dot(dny, dny)), 0.18);
    float a2 = roughF * roughF * roughF * roughF + kern;
    roughF = clamp(sqrt(sqrt(a2)), 0.05, 1.0);
  }
#endif
#ifdef FOLIAGE
  float metalF = 0.0;
#else
  float metalF = arm.b;                     // (a material with none reads the default's 0)
#endif
#ifdef TRANSLUCENT
  // unlit: the base colour x emissive (added below; the base colour itself when emissive is 0) and the
  // material's emission, and no light at all
  vec3 col = (u_tr.w > 0.5) ? ((u_emissive > 0.0) ? vec3(0.0) : alb) : shade(v_wpos, n, alb, roughF, metalF, arm.r, shadow, viewDepth);
#else
  vec3 col = shade(v_wpos, n, alb, roughF, metalF, arm.r, shadow, viewDepth);
#ifdef FABRIC
  // a hair card lit as Epic's hair: the sun through HairShading, the sky as Unreal's hair environment (pi x the shading toward the light
  // a strand's normal would face, at area 0.2, times the sky there)
  if (u_fp[16].w > 2.5) {
    vec3 V = normalize(u_cam_pos - v_wpos);
    vec4 lzA;
    float lz = lightZone(v_wpos, lzA);
    vec3 sunL = hairShading(alb, hRough, hSpec, hT, V, u_sun_dir, 0.0) * u_sun_color * shadow * cloudShadow(v_wpos) * (1.0 - lz);
    vec3 Lf = normalize(V - hT * dot(V, hT) + vec3(0.0, 1e-4, 0.0));
    vec3 sky = PI * hairShading(alb, hRough, hSpec, hT, V, Lf, 0.2) * skyIrradiance(Lf) * mix(1.0, lzA.a, lz);
    col = sane(sunL + sky * hAO + alb * lzA.rgb * lz);
  }
#endif
#ifndef FOLIAGE
  // a clear coat over it (car paint): a second, smooth reflection on the surface's own normal, the paint under it dimmed by it
  if (u_fac_coat.x > 0.0) col = clearCoat(col, v_wpos, N, u_fac_coat.x, u_fac_coat.y, shadow);
#endif
#endif
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
  float sunLeft = sunZone(v_wpos);   // a light zone takes the sun's glow through the leaf and its sheen too
  col += alb * u_sun_color * (0.24 * back + 0.07 * wrap) * thin * shadow * cloudShadow(v_wpos) * sunLeft;
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
    col += u_sun_color * sheen * shadow * cloudShadow(v_wpos) * 0.4 * (0.45 + 0.55 * arm.r) * sunLeft;
  }
#endif
  col += alb * u_emissive;
  if (any(isnan(col))) col = vec3(0.0);
  col += u_fac_emis;
#ifdef TRANSLUCENT
  // Over: the surface is fogged and then laid over what is behind it. Additive: the light it adds is
  // dimmed by the air between it and the eye and adds no fog of its own (applyFog is linear in the
  // colour, so fog(c) - fog(0) is c times the air's transmittance), or a far glow would add the sky.
  if (u_tr.z > 1.5) col = applyFog(col, v_wpos, dist) - applyFog(vec3(0.0), v_wpos, dist);
  else col = applyFog(col, v_wpos, dist);
  float a = meshAlpha;
  // soft particles: fade out over u_tr.y metres in front of the scene behind, so a puff that cuts the
  // ground or a wall shows no hard line where it does
  if (u_tr.y > 0.0) {
    vec2 suv = gl_FragCoord.xy / u_screen;
    float sd = texture(u_scene_depth, suv).r;
    vec4 gp = u_inv_vp * vec4(suv * 2.0 - 1.0, depthClip(sd), 1.0);
    float sceneDist = length(gp.xyz / gp.w - u_cam_pos);
    a *= clamp((sceneDist - dist) / u_tr.y, 0.0, 1.0);
  }
  if (a < 0.002) discard;
  // premultiplied: over is (ONE, ONE_MINUS_SRC_ALPHA), additive (ONE, ONE), one program for both
  o_color = vec4(max(sane(col), vec3(0.0)) * a, a);
#else
  col = applyFog(col, v_wpos, dist);
#ifdef CARD
  o_color = vec4(sane(col), cardAlpha);
#else
  o_color = vec4(sane(col), meshAlpha);
#endif
#if defined(FABRIC) && defined(ALPHA_TEST)
  // A hair card writes its own depth, unchanged: a program that may discard after its depth is known is shaded late. Without it, on an
  // Apple GPU at one sample a pixel, the surfaces behind a card (the scalp) were dropped as hidden by it before its discard ran: holes to
  // what lay there before the actors (the ground, black where the sky was still to come)
  gl_FragDepth = gl_FragCoord.z;
#endif
#endif
}
