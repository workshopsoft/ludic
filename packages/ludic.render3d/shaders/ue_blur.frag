// Unreal's separable Gaussian blur pass, ported from UE 5.8 FilterPixelShader.usf MainPS (USE_DYNAMIC_LOOP) as AddGaussianBlurPass
// drives it (PostProcessWeightedSampleSum.cpp): u_count taps at u_ofs (uv offsets) times u_w (rgba weights, the tint folded in), the
// filter read through an AM_Border sampler (black outside), plus the Additive texture at the same uv when u_add_on (USE_COMBINE_ADDITIVE).
in vec2 v_uv;
out vec4 o_color;
uniform sampler2D u_src;
uniform sampler2D u_add;
uniform float u_add_on;
uniform vec2 u_out_inv;           // 1 / the output's size: the viewport uv, which is also the filter's (same viewport, any size)
uniform float u_count;
uniform vec4 u_ofs[32];           // xy: the tap's uv offset
uniform vec4 u_w[32];             // the tap's weight
vec4 sampleBorder(sampler2D t, vec2 uv) {
  if (uv.x < 0.0 || uv.y < 0.0 || uv.x > 1.0 || uv.y > 1.0) return vec4(0.0);
  return texture(t, uv);
}
void main() {
  vec2 uv = gl_FragCoord.xy * u_out_inv;
  vec4 c = vec4(0.0);
  for (int i = 0; i < 32; i++) {
    if (i >= int(u_count)) break;
    c += sampleBorder(u_src, uv + u_ofs[i].xy) * u_w[i];
  }
  if (u_add_on > 0.5) c += sampleBorder(u_add, uv);
  o_color = c;
}
