// depth-aware 4x4 blur of the ao (a) and indirect bounce (rgb). Point-sampled and with the pixel itself among the taps, as Unreal's AO
// filter takes its depths (CalcSceneDepth at each tap, ComputeDepthSimilarity against a reference): taps between texels, depths blended
// across a silhouette, left a one-pixel outline with every weight near nothing and its occlusion black
in vec2 v_uv;
out vec4 o_color;
uniform sampler2D u_ao;
uniform sampler2D u_depth;
uniform vec2 u_texel;
void main() {
  ivec2 p = ivec2(gl_FragCoord.xy);
  ivec2 hi = textureSize(u_ao, 0) - 1;
  float cd = texelFetch(u_depth, p, 0).r;
  vec4 sum = vec4(0.0);
  float wsum = 0.0;
  for (int y = -2; y < 2; y++) for (int x = -2; x < 2; x++) {
    ivec2 q = clamp(p + ivec2(x, y), ivec2(0), hi);
    vec4 s = texelFetch(u_ao, q, 0);
    float sd = texelFetch(u_depth, q, 0).r;
    float w = exp(-abs(sd - cd) * 4000.0);
    sum += s * w; wsum += w;
  }
  o_color = sum / max(wsum, 1e-4);
}
