// A groom's strands laid over the scene (strands.ludic): Unreal's hair composition (HairStrandsComposition ComposeSamplePS). The pixel's
// coverage from the strands' transmittance (TransmittanceToCoverage at r.HairStrands.Visibility.CoverageThreshold 0.98), its colour the
// strands' lit samples averaged by their coverage (standing for the visibility samples' weights, which also sum to one); premultiplied
// over the scene (ONE, ONE_MINUS_SRC_ALPHA)
in vec2 v_uv;
out vec4 o_color;
uniform sampler2D u_st_trans;
uniform sampler2D u_st_acc;
void main() {
  ivec2 p = ivec2(gl_FragCoord.xy);
  float T = texelFetch(u_st_trans, p, 0).r;
  vec4 acc = texelFetch(u_st_acc, p, 0);
  float cov = clamp((1.0 - T) / 0.98, 0.0, 1.0);
  if (cov <= 0.0 || acc.a <= 1e-6) discard;
  o_color = vec4(max(acc.rgb / acc.a, vec3(0.0)) * cov, cov);
}
