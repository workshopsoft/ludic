// A groom's strands (strands.ludic, skin.vert STRANDS): Unreal's hair strands drawn forward, each ribbon depth-tested against the scene
// and writing none. A strand thinner than the least radius at its depth covers that share of its ribbon (HairStrandsVisibilityPS:
// Coverage = r / max(r, PixelRadius)). TRANSMITTANCE: 1 - that coverage, multiplied into the transmittance target (ZERO, SRC_COLOR);
// otherwise the strand lit and weighted by it, added up (ONE, ONE): the sun through HairShading with the dual scattering's local term
// (ComputeDualScatteringTerms at no hair toward the light), the sky integrated over the sphere as r.HairStrands.SkyLighting.
// IntegrationType 2 (uniform) does, the skin under the strand standing for the voxels' occlusion
in vec3 v_wpos;
in vec3 v_nrm;
in vec2 v_uv;
in vec4 v_col;
in float v_srad;
in float v_sdep;
in vec3 v_snrm;
out vec4 o_color;
uniform float u_strand_minr;
uniform vec4 u_fp[17];        // 0 the colour (the dye), 1 melanin variation fine / rough, roughness, its variation, 2 Spec0, Spec1, SpecEdge,
                              // SpecFront, 3 Backlit, the coverage scale
uniform sampler2D u_hair_lut;  // hair_lut.frag
uniform float u_frame;
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
// ComputeDualScatteringTerms' LocalScattering, the hair count toward the light 0 (GlobalScattering 1 then)
vec3 hairLocalScattering(vec3 base, float rough, vec3 T, vec3 V, vec3 L) {
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
  float sigmaF2 = betaF2;                                            // x max(1, hair count) at none
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
  return 2.0 * Ab * Sb * 0.7;
}
vec3 strandShade(vec3 base, float rough, float spec, float backlit, vec3 T, vec3 V, vec3 L) {
  return hairBsdf(base, rough, spec, T, V, L, 0.0, backlit, true, true, 1.0) + hairLocalScattering(base, rough, T, V, L);
}

void main() {
  float c = clamp(v_srad / max(v_srad, u_strand_minr * v_sdep), 0.0, 1.0);
#ifdef TRANSMITTANCE
  o_color = vec4(1.0 - c);
#else
  if (c <= 0.0) discard;
  vec3 T = normalize(v_nrm);
  vec3 V = normalize(u_cam_pos - v_wpos);
  vec3 Ns = normalize(v_snrm);
  float seed = v_col.a;
  // the material (M_hair_v4's strands: MF_Hair_Color's melanin variation by the seed, MF_Variation's roughness and specular)
  float mv = mix(u_fp[1].x, u_fp[1].y, clamp(u_fp[1].z * 2.0, 0.0, 1.0));
  vec3 base = hairColour(hairAbsorption(u_fp[0].rgb) * (hairVar(mv, 0.5, seed) / 0.5));
  float rough = hairVar(u_fp[1].w, u_fp[1].z, seed);
  float spec = mix(u_fp[2].y, u_fp[2].x, seed) * mix(u_fp[2].z, u_fp[2].w, 0.5);
  float backlit = clamp(u_fp[3].x, 0.0, 1.0);
  vec4 lzA;
  float lz = lightZone(v_wpos, lzA);
  // the sun: Shadow x HairShading (no cosine: the lobes carry it)
  float shadow = sunShadow(v_wpos, Ns, v_sdep);
  vec3 col = strandShade(base, rough, spec, backlit, T, V, u_sun_dir) * u_sun_color * shadow * cloudShadow(v_wpos) * (1.0 - lz);
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
    sky += strandShade(base, rough, spec, backlit, T, V, L) * vis * skyPrefiltered(L, 0.1);
  }
  col += sky * (4.0 * PI / float(SKY_SAMPLES)) * mix(1.0, lzA.a, lz);
  col += base * lzA.rgb * lz;
  col = applyFog(sane(col), v_wpos, length(u_cam_pos - v_wpos));
  o_color = vec4(max(col, vec3(0.0)) * c, c);
#endif
}
