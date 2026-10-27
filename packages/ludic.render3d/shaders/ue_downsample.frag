// Unreal's scene colour downsample, ported from UE 5.8 PostProcessDownsample.usf, DOWNSAMPLE_QUALITY_HIGH (r.PostProcessing.
// DownsampleChainQuality 1): four bilinear taps one input texel off each diagonal (a 4x4 blur), averaged, negatives clamped.
in vec2 v_uv;
out vec4 o_color;
uniform sampler2D u_src;
uniform vec2 u_src_inv;           // Input_ExtentInverse
uniform vec2 u_out_inv;           // Output_ExtentInverse
vec4 sampleInput(vec2 uv) {
  uv = clamp(uv, 0.5 * u_src_inv, 1.0 - 0.5 * u_src_inv);   // Input_UVViewportBilinearMin / Max
  return textureLod(u_src, uv, 0.0);
}
void main() {
  vec2 uv = gl_FragCoord.xy * u_out_inv;
  vec4 c = sampleInput(uv + u_src_inv * vec2(-1.0, -1.0)) + sampleInput(uv + u_src_inv * vec2(1.0, -1.0))
         + sampleInput(uv + u_src_inv * vec2(-1.0, 1.0)) + sampleInput(uv + u_src_inv * vec2(1.0, 1.0));
  c *= 0.25;
  c.rgb = max(c.rgb, vec3(0.0));
  o_color = vec4(sane(c.rgb), c.a);
}
