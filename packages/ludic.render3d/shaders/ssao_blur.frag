// depth-aware 4x4 blur of the ao (a) and indirect bounce (rgb). Point-sampled and with the pixel itself among the taps, as Unreal's AO
// filter takes its depths (CalcSceneDepth at each tap, ComputeDepthSimilarity against a reference): taps between texels, depths blended
// across a silhouette, left a one-pixel outline with every weight near nothing and its occlusion black.
// u_ao_half 1 (post.ludic post_ao_half): the ao is half the frame and this pass, at full size, is its bilateral upsample as well: the
// 4x4 half-size texels round the pixel, each weighted by the full-size depth it was taken at (its block's top-left, ssgi.frag); a pixel
// no texel's depth matches (a one-pixel wire, a silhouette) takes the texel nearest it in depth rather than black.
in vec2 v_uv;
out vec4 o_color;
uniform sampler2D u_ao;
uniform sampler2D u_depth;
uniform vec2 u_texel;
uniform float u_ao_half;
void main() {
  ivec2 p = ivec2(gl_FragCoord.xy);
  ivec2 hi = textureSize(u_ao, 0) - 1;
  ivec2 dhi = textureSize(u_depth, 0) - 1;
  float cd = texelFetch(u_depth, p, 0).r;
  bool half_ = u_ao_half > 0.5;
  ivec2 base = half_ ? (p >> 1) + ivec2(1) : p;
  int scale = half_ ? 2 : 1;
  vec4 sum = vec4(0.0);
  float wsum = 0.0;
  vec4 best = vec4(0.0, 0.0, 0.0, 1.0);
  float bestd = 1e9;
  for (int y = -2; y < 2; y++) for (int x = -2; x < 2; x++) {
    ivec2 q = clamp(base + ivec2(x, y), ivec2(0), hi);
    vec4 s = texelFetch(u_ao, q, 0);
    float sd = texelFetch(u_depth, min(q * scale, dhi), 0).r;
    float dd = abs(sd - cd);
    float w = exp(-dd * 4000.0);
    sum += s * w; wsum += w;
    if (dd < bestd) { bestd = dd; best = s; }
  }
  o_color = (half_ && wsum < 1e-3) ? best : sum / max(wsum, 1e-4);
}
