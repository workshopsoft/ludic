// 3x3 tent upsample, added onto the destination (blend ONE ONE)
in vec2 v_uv;
out vec4 o_color;
uniform sampler2D u_src;
uniform vec2 u_texel;
uniform float u_radius;
void main() {
  vec2 t = u_texel * u_radius;
  vec3 s = texture(u_src, v_uv + t * vec2(-1, 1)).rgb + texture(u_src, v_uv + t * vec2(0, 1)).rgb * 2.0 + texture(u_src, v_uv + t * vec2(1, 1)).rgb
         + texture(u_src, v_uv + t * vec2(-1, 0)).rgb * 2.0 + texture(u_src, v_uv).rgb * 4.0 + texture(u_src, v_uv + t * vec2(1, 0)).rgb * 2.0
         + texture(u_src, v_uv + t * vec2(-1, -1)).rgb + texture(u_src, v_uv + t * vec2(0, -1)).rgb * 2.0 + texture(u_src, v_uv + t * vec2(1, -1)).rgb;
  o_color = vec4(s / 16.0, 1.0);
}
