// depth-aware 4x4 blur of the ao (a) and indirect bounce (rgb)
in vec2 v_uv;
out vec4 o_color;
uniform sampler2D u_ao;
uniform sampler2D u_depth;
uniform vec2 u_texel;
void main() {
  float cd = texture(u_depth, v_uv).r;
  vec4 sum = vec4(0.0);
  float wsum = 0.0;
  for (int y = -2; y < 2; y++) for (int x = -2; x < 2; x++) {
    vec2 o = vec2(float(x) + 0.5, float(y) + 0.5) * u_texel;
    vec4 s = texture(u_ao, v_uv + o);
    float sd = texture(u_depth, v_uv + o).r;
    float w = exp(-abs(sd - cd) * 4000.0);
    sum += s * w; wsum += w;
  }
  o_color = sum / max(wsum, 1e-4);
}
