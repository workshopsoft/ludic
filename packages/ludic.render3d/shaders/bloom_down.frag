// 13-tap downsample (Jimenez), with a soft threshold on the first level
in vec2 v_uv;
out vec4 o_color;
uniform sampler2D u_src;
uniform vec2 u_texel;
uniform float u_threshold;     // <0: no threshold
void main() {
  vec2 t = u_texel;
  vec3 a = texture(u_src, v_uv + t * vec2(-2, 2)).rgb, b = texture(u_src, v_uv + t * vec2(0, 2)).rgb, c = texture(u_src, v_uv + t * vec2(2, 2)).rgb;
  vec3 d = texture(u_src, v_uv + t * vec2(-2, 0)).rgb, e = texture(u_src, v_uv).rgb, f = texture(u_src, v_uv + t * vec2(2, 0)).rgb;
  vec3 g = texture(u_src, v_uv + t * vec2(-2, -2)).rgb, h = texture(u_src, v_uv + t * vec2(0, -2)).rgb, i = texture(u_src, v_uv + t * vec2(2, -2)).rgb;
  vec3 j = texture(u_src, v_uv + t * vec2(-1, 1)).rgb, k = texture(u_src, v_uv + t * vec2(1, 1)).rgb;
  vec3 l = texture(u_src, v_uv + t * vec2(-1, -1)).rgb, m = texture(u_src, v_uv + t * vec2(1, -1)).rgb;
  a = min(a, vec3(4096.0)); b = min(b, vec3(4096.0)); c = min(c, vec3(4096.0)); d = min(d, vec3(4096.0)); e = min(e, vec3(4096.0));
  f = min(f, vec3(4096.0)); g = min(g, vec3(4096.0)); h = min(h, vec3(4096.0)); i = min(i, vec3(4096.0)); j = min(j, vec3(4096.0));
  k = min(k, vec3(4096.0)); l = min(l, vec3(4096.0)); m = min(m, vec3(4096.0));
  vec3 col = e * 0.125 + (a + c + g + i) * 0.03125 + (b + d + f + h) * 0.0625 + (j + k + l + m) * 0.125;
  if (u_threshold >= 0.0) {
    float br = max(col.r, max(col.g, col.b));
    float knee = u_threshold * 0.5;
    float soft = clamp(br - u_threshold + knee, 0.0, 2.0 * knee);
    soft = soft * soft / (4.0 * knee + 1e-4);
    float contrib = max(soft, br - u_threshold) / max(br, 1e-4);
    col *= contrib;
  }
  o_color = vec4(sane(col), 1.0);
}
