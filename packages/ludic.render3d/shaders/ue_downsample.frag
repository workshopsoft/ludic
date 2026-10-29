// Unreal's scene colour downsample, ported from UE 5.8 PostProcessDownsample.usf DownsampleCommon. DOWNSAMPLE_QUALITY_HIGH
// (r.PostProcessing.DownsampleChainQuality 1, the chain's stages): four bilinear taps one input texel off each diagonal (a 4x4 blur),
// averaged, negatives clamped. u_low 1 is DOWNSAMPLE_QUALITY_LOW (r.PostProcessing.DownsampleQuality 0, PostProcessing.cpp's
// "PostProcessing.SceneColor.HalfRes" from the full-resolution scene): one filtered tap at the output texel's centre (a 2x2 box).
in vec2 v_uv;
out vec4 o_color;
uniform sampler2D u_src;
uniform vec2 u_src_inv;           // Input_ExtentInverse
uniform vec2 u_out_inv;           // Output_ExtentInverse
uniform float u_low;              // DOWNSAMPLE_QUALITY_LOW
vec4 sampleInput(vec2 uv) {
  uv = clamp(uv, 0.5 * u_src_inv, 1.0 - 0.5 * u_src_inv);   // Input_UVViewportBilinearMin / Max
  return textureLod(u_src, uv, 0.0);
}
void main() {
  vec2 uv = gl_FragCoord.xy * u_out_inv;
  if (u_low > 0.5) {
    vec4 l = sampleInput(uv);
    o_color = vec4(sane(l.rgb), l.a);
    return;
  }
  vec4 c = sampleInput(uv + u_src_inv * vec2(-1.0, -1.0)) + sampleInput(uv + u_src_inv * vec2(1.0, -1.0))
         + sampleInput(uv + u_src_inv * vec2(-1.0, 1.0)) + sampleInput(uv + u_src_inv * vec2(1.0, 1.0));
  c *= 0.25;
  c.rgb = max(c.rgb, vec3(0.0));
  o_color = vec4(sane(c.rgb), c.a);
}
