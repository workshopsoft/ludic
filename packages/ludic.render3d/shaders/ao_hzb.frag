// the AO's depth: Unreal's furthest HZB mip 0 (HZB.cpp, EHZBType::FurthestHZB), half the frame's size, each texel the furthest
// of the 2 x 2 under it, as the view's distance (positive, metres) so the AO's taps rebuild a position without a matrix
in vec2 v_uv;
out vec4 o_color;
uniform sampler2D u_depth;
uniform mat4 u_inv_proj;
float viewDist(ivec2 q, ivec2 hi) {
  q = min(q, hi);
  float d = texelFetch(u_depth, q, 0).r;
  vec2 uv = (vec2(q) + 0.5) / vec2(hi + 1);
  vec4 p = u_inv_proj * vec4(uv * 2.0 - 1.0, depthClip(d), 1.0);
  return -p.z / p.w;
}
void main() {
  ivec2 hi = textureSize(u_depth, 0) - 1;
  ivec2 p = ivec2(gl_FragCoord.xy) * 2;
  float z = max(max(viewDist(p, hi), viewDist(p + ivec2(1, 0), hi)), max(viewDist(p + ivec2(0, 1), hi), viewDist(p + ivec2(1, 1), hi)));
  o_color = vec4(z, 0.0, 0.0, 1.0);
}
