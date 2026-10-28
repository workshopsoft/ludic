// A groom's strands laid over the scene (strands.ludic): Unreal's hair composition (HairStrandsComposition ComposeSamplePS). The pixel's
// coverage from the strands' transmittance (TransmittanceToCoverage at r.HairStrands.Visibility.CoverageThreshold 0.98), its colour the
// visibility samples' (strands.ludic: the multisampled resolve, each front strand's light x its samples / all; over the share hit it is
// Unreal's x samples / the samples hit); none hit, no hair (its compaction's empty pixel); premultiplied over the scene (ONE,
// ONE_MINUS_SRC_ALPHA). WRITE_DEPTH (ComposeSamplePS PERMUTATION_WRITE_DEPTH: OutDepth = the hair-only depth): the nearest of the
// visibility's samples into the scene's depth where there is hair. FILL_DEPTH (HairStrandsVisibilityFillOpaqueDepthPS, Unreal's
// FillVisibilityDepth): the opaque scene's depth into every sample of the visibility's, so its strands are depth-tested by the hardware
in vec2 v_uv;
out vec4 o_color;
#ifdef FILL_DEPTH
uniform sampler2D u_scene_depth;
void main() {
  gl_FragDepth = texelFetch(u_scene_depth, ivec2(gl_FragCoord.xy), 0).r;
  o_color = vec4(0.0);
}
#else
uniform sampler2D u_st_trans;
uniform sampler2D u_st_acc;
uniform float u_st_dbg;        // R3D_STRAND_COV: the coverage itself, grey, opaque
#ifdef WRITE_DEPTH
uniform sampler2DMS u_st_vdep; // the visibility's depth (reversed: the nearest the greatest)
uniform float u_st_n;          // its samples
#endif
void main() {
  ivec2 p = ivec2(gl_FragCoord.xy);
  float T = texelFetch(u_st_trans, p, 0).r;
  vec4 acc = texelFetch(u_st_acc, p, 0);
  float cov = clamp((1.0 - T) / 0.98, 0.0, 1.0);
  if (cov <= 0.0 || acc.a <= 1e-6) discard;
#ifdef WRITE_DEPTH
  // the hair's nearest sample: a sample the hair missed holds the scene's depth (or none), never nearer than the hair where it is
  float z = 0.0;
  for (int s = 0; s < min(int(u_st_n + 0.5), 8); ++s) z = max(z, texelFetch(u_st_vdep, p, s).r);
  gl_FragDepth = z;
#endif
  if (u_st_dbg > 0.5) {
    // bands: under 0.5 red, 0.5-0.9 orange, 0.9-0.99 yellow, full green
    vec3 b = cov < 0.5 ? vec3(4, 0, 0) : cov < 0.9 ? vec3(4, 1.5, 0) : cov < 0.99 ? vec3(3, 3, 0) : vec3(0, 3, 0);
    o_color = vec4(b, 1.0);
    return;
  }
  o_color = vec4(max(acc.rgb / acc.a, vec3(0.0)) * cov, cov);
}
#endif
