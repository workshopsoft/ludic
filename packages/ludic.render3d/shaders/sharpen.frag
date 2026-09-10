// luma unsharp mask + film grain, on the final LDR image
in vec2 v_uv;
out vec4 o_color;
uniform sampler2D u_src;
uniform vec2 u_texel;
uniform float u_amount;
uniform float u_grain;
float hash(vec2 p) { return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453); }
float luma(vec3 c) { return dot(c, vec3(0.299, 0.587, 0.114)); }
void main() {
  vec3 c = texture(u_src, v_uv).rgb;
  vec3 n = texture(u_src, v_uv + vec2(0, u_texel.y)).rgb, s = texture(u_src, v_uv - vec2(0, u_texel.y)).rgb;
  vec3 e = texture(u_src, v_uv + vec2(u_texel.x, 0)).rgb, w = texture(u_src, v_uv - vec2(u_texel.x, 0)).rgb;
  float lc = luma(c);
  float lb = (luma(n) + luma(s) + luma(e) + luma(w) + lc * 4.0) / 8.0;
  float d = clamp((lc - lb) * u_amount, -0.08, 0.08);
  vec3 col = c * (1.0 + d / max(lc, 1e-3));
  float g = (hash(v_uv * 1731.0 + fract(u_time)) - 0.5) * u_grain;
  col += g * (0.6 + 0.4 * (1.0 - lc));
  o_color = vec4(clamp(col, 0.0, 1.0), 1.0);
}
