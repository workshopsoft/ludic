// Epic's hair dual scattering LUT (HairStrandsLUT.usf, PERMUTATION_LUT_TYPE_DUALSCATTERING), drawn once into a 256 x 256 atlas
// (strands.ludic): 64 incident angles (x) by 64 roughnesses (y) by 16 absorptions, the absorptions in 4 x 4 tiles (GetAtlasCoord2d).
// Each texel the hair's average scattering toward the front (R) and back (G) half spaces, its BSDF (HairShading at Specular 0.5,
// Backlit 1, no area, InitHairStrandsTransmittanceData: its own absorption, not the legacy one, the lobes unclamped) integrated over
// the sphere by Unreal's own uniform samples (R2-jittered strata, the counts falling with the roughness)
out vec4 o_color;
vec2 r2Sequence(uint i) { const float g = 1.32471795724474602596; return fract(vec2(1.0 / g, 1.0 / (g * g)) * float(i)); }
vec3 uniformSphere(vec2 e) { float phi = 2.0 * PI * e.x; float c = 1.0 - 2.0 * e.y; float s = sqrt(max(1.0 - c * c, 0.0)); return vec3(s * cos(phi), s * sin(phi), c); }
void main() {
  ivec2 px = ivec2(gl_FragCoord.xy);
  int z = px.x / 64 + 4 * (px.y / 64);
  float sinA = clamp((float(px.x % 64) + 0.5) / 64.0, 0.0, 1.0);
  float rough = clamp((float(px.y % 64) + 0.5) / 64.0, 0.0, 1.0);
  float ab = clamp((float(z) + 0.5) / 16.0, 0.0, 1.0);
  vec3 base = vec3(ab * ab);                               // ToLinearAbsorption: the axis is perceptual
  vec3 V = vec3(sqrt(1.0 - sinA * sinA), 0.0, sinA);
  vec3 T = vec3(0.0, 0.0, 1.0);
  uint nT = max(1u, uint(mix(128.0, 64.0, rough)));
  uint nP = max(1u, uint(mix(128.0, 32.0, rough)));
  float front = 0.0, back = 0.0;
  uint fc = 0u, bc = 0u;
  for (uint y = 0u; y < nP; ++y)
  for (uint x = 0u; x < nT; ++x) {
    vec2 u = (vec2(float(x), float(y)) + r2Sequence(x + y * nT)) / vec2(float(nT), float(nP));
    vec3 L = uniformSphere(u.yx);
    float f = hairBsdf(base, rough, 0.5, T, V, L, 0.0, 1.0, false, false, 1.0).x * (4.0 * PI);
    if (L.x > 0.0) { back += f; ++bc; } else { front += f; ++fc; }
  }
  o_color = vec4(clamp(front / float(max(fc, 1u)) * 0.5, 0.0, 1.0), clamp(back / float(max(bc, 1u)) * 0.5, 0.0, 1.0), 0.0, 1.0);
}
