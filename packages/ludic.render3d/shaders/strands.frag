// A groom's strands (strands.ludic, skin.vert STRANDS): Unreal's hair strands drawn forward, each ribbon depth-tested against the scene
// and writing none. A strand thinner than the least radius at its depth covers that share of its ribbon (HairStrandsVisibilityPS:
// Coverage = r / max(r, PixelRadius)). TRANSMITTANCE: 1 - that coverage, multiplied into the transmittance target (ZERO, SRC_COLOR);
// otherwise the strand lit and weighted by it, added up (ONE, ONE): the sun through HairShading with the dual scattering's local term
// (ComputeDualScatteringTerms at no hair toward the light), the sky integrated over the sphere as r.HairStrands.SkyLighting.
// IntegrationType 2 (uniform) does: the skin under the strand blocking its half, the groom's own hair counted toward each direction.
// VIS (a head of hair, Unreal's HairVisibilityRenderMode_MSAA_Visibility, HairStrandsVisibilityPS.usf MainVisibility): no light, the
// sample's strand alone (PackHairVisControlPointMaterialId: the segment, 24 bits, and its material's slot) as three 11-bit integers a
// half holds exactly, the slot + 2 in alpha (the multisampled target is RGBA16F, which a groom of ribbons writes its light into with
// alpha 1). SHADE (a full-screen pass: HairStrandsVisibilityCompaction.usf and the lighting of its samples): each pixel's distinct
// strands lit once, weighted by the samples each holds (strands.ludic strands_shade)
#ifndef SHADE
in vec3 v_wpos;
in vec3 v_nrm;
in vec2 v_uv;
in vec4 v_col;
in float v_srad;
in float v_sdep;
in vec3 v_snrm;
in vec4 v_sky;
#else
in vec2 v_uv;
#endif
#ifdef VIS
in vec2 v_sid;                // the segment (skin.vert VIS: its low and high 12 bits)
uniform float u_st_slot;      // its head of hair's slot in this frame's visibility (strands.ludic ST_VIS_SLOTS)
#endif
out vec4 o_color;
uniform float u_strand_minr;
uniform vec4 u_fp[17];        // the hair's parameters in model.frag's hair-mode layout (mhHairColour; 2 Spec0, Spec1, SpecEdge, SpecFront),
                              // but 3 Backlit
uniform sampler2D u_scene_depth; // the opaque scene's depth (the visibility pass: its own depth buffer holds the strands')
uniform sampler2D u_hair_lut;  // hair_lut.frag
uniform float u_frame;
uniform float u_st_terms;     // R3D_STRAND_TERMS (strands.ludic): 1 the sun alone, 2 the sky alone, 0 both
uniform float u_st_cov;       // the Auto LOD's coverage scale (strands.ludic strands_lod: HairStrandsVisibilityPS HairCoverageScale)
#ifdef DOM
uniform sampler2D u_hs_front;  // the deep shadow's front depth (strands.ludic)
uniform vec4 u_hs_layers;      // its layers' depths (ComputeDeepShadowLayerDepths)
#endif
const int SKY_SAMPLES = 16;   // r.HairStrands.SkyLighting.SampleCount

// SampleHairLUT for one channel: the atlas's trilinear sample (angle, roughness bilinear in a tile; absorption across two)
vec2 hairLut(float sinV, float rough, float c) {
  vec2 xy = clamp(vec2(sinV, rough) * 64.0, vec2(0.5), vec2(63.5));
  float z = clamp(c * 16.0 - 0.5, 0.0, 15.0);
  float z0 = floor(z), z1 = min(z0 + 1.0, 15.0);
  vec2 a = textureLod(u_hair_lut, (xy + vec2(mod(z0, 4.0), floor(z0 / 4.0)) * 64.0) / 256.0, 0.0).rg;
  vec2 b = textureLod(u_hair_lut, (xy + vec2(mod(z1, 4.0), floor(z1 / 4.0)) * 64.0) / 256.0, 0.0).rg;
  return mix(a, b, z - z0);
}
// ComputeDualScatteringTerms: the LocalScattering, and in gs the GlobalScattering by the hair count toward the light (count - 1: no
// self-shadow)
vec3 hairLocalScattering(vec3 base, float rough, vec3 T, vec3 V, vec3 L, float count, out vec3 gs) {
  float sinL = clamp(dot(T, L), -1.0, 1.0);
  float sinV = clamp(dot(T, V), -1.0, 1.0);
  vec3 c = sqrt(clamp(base, 0.0, 1.0));
  vec2 lr = hairLut(abs(sinL), rough, c.r), lg = hairLut(abs(sinL), rough, c.g), lb = hairLut(abs(sinL), rough, c.b);
  vec3 af = min(vec3(0.99), vec3(lr.x, lg.x, lb.x));
  vec3 ab = min(vec3(0.99), vec3(lr.y, lg.y, lb.y));
  vec3 af2 = af * af, ab2 = ab * ab, om = 1.0 - af2;
  vec3 Ab = ab * af2 / om + ab * ab2 * af2 / (om * om * om);
  float r = clamp(rough, 0.18, 0.6);
  vec3 beta = vec3(r * r, (r * 0.5) * (r * 0.5), (r * 2.0) * (r * 2.0));
  vec3 afw = af / (af.r + af.g + af.b);
  float betaF = dot(beta, afw);
  float betaF2 = betaF * betaF;
  float n = max(0.0, count - 1.0);
  float sigmaF2 = betaF2 * max(1.0, n);
  float thetaH = 0.5 * (asin(sinL) + asin(sinV));
  float shiftF = dot(vec3(-0.07, 0.035, 0.14), afw);
  vec3 deltaB = shiftF * (1.0 - 2.0 * ab2 / (om * om)) * shiftF * (2.0 * om * om + 4.0 * af2 * ab2) / (om * om * om);
  vec3 abw = ab / (ab.r + ab.g + ab.b);
  float betaB = dot(beta, abw);
  float betaB2 = betaB * betaB;
  vec3 sigmaB = (1.0 + 0.7 * af2) * (ab * sqrt(2.0 * betaF2 + betaB2) + ab * ab2 * sqrt(2.0 * betaF2 + betaB2)) / (ab + ab * ab2 * (2.0 * betaF + 3.0 * betaB));
  vec3 var = sigmaF2 + sigmaB * sigmaB;
  vec3 d = thetaH - deltaB;
  vec3 Sb = exp(-0.5 * d * d / var) / PI;
  vec3 Sf = exp(-0.5 * thetaH * thetaH / vec3(sigmaF2)) / PI;
  vec3 Tf = pow(max(vec3(lr.x, lg.x, lb.x), vec3(1e-4)), vec3(n));
  gs = mix(vec3(1.0), Tf * Sf * 0.7, clamp(n, 0.0, 1.0));
  return 2.0 * Ab * Sb * 0.7;
}
// HairShading with the dual scattering: GlobalScattering x (the lobes + LocalScattering)
vec3 strandShade(vec3 base, float rough, float spec, float backlit, vec3 T, vec3 V, vec3 L, float count) {
  vec3 gs;
  vec3 ls = hairLocalScattering(base, rough, T, V, L, count, gs);
  return gs * (hairBsdf(base, rough, spec, T, V, L, 0.0, backlit, true, true, 1.0) + ls);
}

#if !defined(TRANSMITTANCE) && !defined(DOM) && !defined(VIS)
// a strand's light at a point of it: T its tangent, Ns the skin's normal at its root, seed its seed, coord its place from the root, skyc
// the hair between it and the sky (x + yzw.L), sdep its view depth, fp its material
vec3 strandLight(vec3 wpos, vec3 T, vec3 Ns, float seed, float coord, vec4 skyc, float sdep, vec4 fp[17]) {
  vec3 V = normalize(u_cam_pos - wpos);
  // the material: M_hair_v4's colour for this strand (its seed, its place from the root), MF_Variation's roughness and specular
  vec3 base = mhHairColour(fp, seed, coord);
  float rough = hairVar(fp[1].w, fp[1].z, seed);
  float spec = mix(fp[2].y, fp[2].x, seed) * mix(fp[2].z, fp[2].w, 0.5);
  float backlit = clamp(fp[3].x, 0.0, 1.0);
  vec4 lzA;
  float lz = lightZone(wpos, lzA);
  // the sun: Shadow x HairShading (no cosine: the lobes carry it)
  float shadow = sunShadow(wpos, Ns, sdep);
  vec3 col = strandShade(base, rough, spec, backlit, T, V, u_sun_dir, hairCountAt(wpos)) * u_sun_color * shadow * cloudShadow(wpos) * (1.0 - lz);
  // the sky: 4 pi / N x the sum over N uniform directions of HairShading x visibility x the sky's radiance (roughness 0.1), the
  // directions turned per pixel and per frame (Unreal's blue noise, the temporal resolve averaging it)
  vec3 sky = vec3(0.0);
  vec2 j = fract(vec2(ign(gl_FragCoord.xy), ign(gl_FragCoord.yx + 17.0)) + u_frame * vec2(0.7548777, 0.5698403));
  for (int k = 0; k < SKY_SAMPLES; ++k) {
    vec2 e = fract(j + vec2(float(k) / float(SKY_SAMPLES), fract(float(k) * 0.6180340)));
    float phi = 2.0 * PI * e.x, cz = 1.0 - 2.0 * e.y, sz = sqrt(max(1.0 - cz * cz, 0.0));
    vec3 L = vec3(sz * cos(phi), cz, sz * sin(phi));
    float vis = smoothstep(-0.1, 0.1, dot(L, Ns));
    if (vis <= 0.0) continue;
    // the hair between it and the sky that way (Unreal's voxel march, baked: strands_mh.py), through the dual scattering
    float cnt = max(skyc.x + dot(skyc.yzw, L), 0.0);
    sky += strandShade(base, rough, spec, backlit, T, V, L, cnt) * vis * skyPrefiltered(L, 0.1);
  }
  if (u_st_terms > 1.5) col = vec3(0.0);
  if (u_st_terms > 0.5 && u_st_terms < 1.5) sky = vec3(0.0);
  col += sky * (4.0 * PI / float(SKY_SAMPLES)) * mix(1.0, lzA.a, lz);
  col += base * lzA.rgb * lz;
  col = applyFog(sane(col), wpos, length(u_cam_pos - wpos));
  return max(col, vec3(0.0));
}
#endif

#ifdef SHADE
// the visibility pass's samples (strands.ludic: its RGBA16F target and its depth, u_st_n samples a pixel) and each slot's head of hair:
// its material (17 vec4s each, model.frag's hair-mode layout), its bind space to the world (the model matrix x the head joint, which the
// segment's quad is wholly weighted to), its points' centre (xyz) and largest radius (w), and its points (morph.ludic
// model_set_strand_points: 20 bytes, five words, a point)
uniform sampler2DMS u_st_vis;
uniform sampler2DMS u_st_vdep;
uniform float u_st_n;
uniform vec2 u_st_size;
uniform mat4 u_st_ivp;         // clip to the world, the visibility pass's camera
uniform vec3 u_st_fwd;         // the camera's forward axis (a point's view depth)
uniform vec4 u_stm_fp[68];
uniform mat4 u_stm_m[4];
uniform vec4 u_stm_c[4];
readonly buffer u_st_pts0 { uint st_pts0[]; };
readonly buffer u_st_pts1 { uint st_pts1[]; };
readonly buffer u_st_pts2 { uint st_pts2[]; };
readonly buffer u_st_pts3 { uint st_pts3[]; };
uint stWord(int s, uint i) {
  if (s == 0) return st_pts0[i];
  if (s == 1) return st_pts1[i];
  if (s == 2) return st_pts2[i];
  return st_pts3[i];
}
// one packed control point (FPackedHairVertex, as skin.vert INST reads it): its position (three halves from the centre), u 8 | radius 6 |
// type 2 bits, the sky's four halves
struct StPt { vec3 p; float u; uint t; vec4 sky; };
StPt stPoint(int s, uint rec) {
  uint b = rec * 5u;
  uint w0 = stWord(s, b), w1 = stWord(s, b + 1u);
  StPt o;
  o.p = vec3(unpackHalf2x16(w0), unpackHalf2x16(w1).x) + u_stm_c[s].xyz;
  uint pk = w1 >> 16u;
  o.u = float(pk & 255u) / 255.0;
  o.t = pk >> 14u;
  o.sky = vec4(unpackHalf2x16(stWord(s, b + 2u)), unpackHalf2x16(stWord(s, b + 3u)));
  return o;
}
// UnitVectorToOctahedron's inverse (Unreal's OctahedronToUnitVector), as skin.vert stOct
vec3 stOctN(vec2 e) {
  e = e * 2.0 - 1.0;
  vec3 n = vec3(e, 1.0 - abs(e.x) - abs(e.y));
  float t = max(-n.z, 0.0);
  n.xy += vec2(n.x >= 0.0 ? -t : t, n.y >= 0.0 ? -t : t);
  return normalize(n);
}
// a visibility sample's strand lit: segment i of slot s (instance i: points i .. i + 3, its ends i + 1 and i + 2) at device depth d. What
// skin.vert INST gives the forward pass at that point of the ribbon, made from the same records: the position from the depth (the
// compaction keeps the sample's depth), the tangents at the ends (each the mean of its two segments' directions, one at a root or a tip)
// blended along the segment, u and the sky the same way, the root's normal and the seed from its first end
vec3 stShade(int s, uint i, float d) {
  vec4 c = u_st_ivp * vec4(gl_FragCoord.xy / u_st_size * 2.0 - 1.0, d, 1.0);
  vec3 wp = c.xyz / c.w;
  StPt P = stPoint(s, i), A = stPoint(s, i + 1u), B = stPoint(s, i + 2u), N = stPoint(s, i + 3u);
  mat4 m = u_stm_m[s];
  vec3 dAB = B.p - A.p;
  dAB /= max(length(dAB), 1e-12);
  vec3 TA = dAB, TB = dAB;
  if (A.t != 1u) { vec3 e = A.p - P.p; TA += e / max(length(e), 1e-12); }
  if (B.t != 2u) { vec3 e = N.p - B.p; TB += e / max(length(e), 1e-12); }
  vec3 wa = (m * vec4(A.p, 1.0)).xyz, wb = (m * vec4(B.p, 1.0)).xyz;
  vec3 ab = wb - wa;
  float t = clamp(dot(wp - wa, ab) / max(dot(ab, ab), 1e-12), 0.0, 1.0);
  vec3 T = normalize(mix(normalize(mat3(m) * normalize(TA)), normalize(mat3(m) * normalize(TB)), t));
  uint w4 = stWord(s, (i + 1u) * 5u + 4u);
  vec3 Ns = normalize(mat3(m) * stOctN(vec2(float(w4 & 255u), float((w4 >> 8u) & 255u)) / 255.0));
  float seed = float((w4 >> 16u) & 255u) / 255.0;
  vec4 sk = mix(A.sky, B.sky, t);
  vec4 fp[17];
  for (int k = 0; k < 17; ++k) fp[k] = u_stm_fp[s * 17 + k];
  return strandLight(wp, T, Ns, seed, mix(A.u, B.u, t), vec4(sk.x, mat3(m) * sk.yzw), dot(wp - u_cam_pos, u_st_fwd), fp);
}
// HairStrandsVisibilityCompaction.usf: a pixel's samples, the same strand's merged (its count of them, its nearest depth), each distinct
// one lit once and weighted by its samples. Written as the multisampled resolve wrote it: the light summed over all the samples (alpha
// the share hit), which strands_resolve.frag divides by the share hit (Unreal's weight: its samples over the samples hit). A ribbon's
// sample (alpha 1) carries its own light
void main() {
  ivec2 px = ivec2(gl_FragCoord.xy);
  int n = min(int(u_st_n + 0.5), 8);
  uint key[8];
  float cnt[8];
  float dep[8];
  int nk = 0;
  vec3 acc = vec3(0.0);
  float hit = 0.0;
  for (int s = 0; s < n; ++s) {
    vec4 v = texelFetch(u_st_vis, px, s);
    if (v.a < 0.5) continue;
    hit += 1.0;
    if (v.a < 1.5) { acc += v.rgb; continue; }
    uint k = ((uint(v.r + 0.5) | (uint(v.g + 0.5) << 11u) | (uint(v.b + 0.5) << 22u)) << 2u) | (uint(v.a - 1.5) & 3u);
    float d = texelFetch(u_st_vdep, px, s).r;
    int f = -1;
    for (int j = 0; j < nk; ++j) if (key[j] == k) f = j;
    if (f < 0) { key[nk] = k; cnt[nk] = 1.0; dep[nk] = d; nk += 1; }
    else { cnt[f] += 1.0; dep[f] = max(dep[f], d); }
  }
  for (int j = 0; j < nk; ++j) acc += stShade(int(key[j] & 3u), key[j] >> 2u, dep[j]) * cnt[j];
  o_color = vec4(acc, hit) / float(max(n, 1));
}
#else
void main() {
  float c = clamp(v_srad / max(v_srad, u_strand_minr * v_sdep), 0.0, 1.0);
#ifdef TRANSMITTANCE
  // the curves the Auto LOD left out given back in coverage: saturate(r / max(r, PixelRadius) x HairCoverageScale)
  o_color = vec4(1.0 - clamp(c * u_st_cov, 0.0, 1.0));
#elif defined(DOM)
  // the deep shadow's layers (strands.ludic, HairStrandsDeepShadowPS.usf MainDom): the strand's coverage into each layer its distance
  // behind the front depth lies within (reversed depth: the front is the greater; ComputeDOMWeights), added up
  float front = texelFetch(u_hs_front, ivec2(gl_FragCoord.xy), 0).r;
  float dist = max(0.0, front - gl_FragCoord.z);
  o_color = vec4(lessThan(vec4(dist), u_hs_layers)) * c;
#elif defined(VIS)
  // PackHairVisControlPointMaterialId: the segment and its head of hair's slot; no light, and no scene test in the shader (the
  // visibility's depth starts as the scene's: FillVisibilityDepth)
  uint id = uint(v_sid.x + 0.5) + (uint(v_sid.y + 0.5) << 12u);
  o_color = vec4(float(id & 2047u), float((id >> 11u) & 2047u), float((id >> 22u) & 3u), 2.0 + u_st_slot);
#else
  // the visibility pass: behind the opaque scene (reversed depth) is no sample of the hair's
  if (gl_FragCoord.z < texelFetch(u_scene_depth, ivec2(gl_FragCoord.xy), 0).r) discard;
  o_color = vec4(strandLight(v_wpos, normalize(v_nrm), normalize(v_snrm), v_col.a, v_uv.x, v_sky, v_sdep, u_fp), 1.0);
#endif
}
#endif
