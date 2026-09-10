// 2D overlay: a texture times a colour; the font atlas is white glyphs on alpha
in vec2 v_uv;
in vec4 v_col;
uniform sampler2D u_tex;
uniform float u_is_font;
out vec4 o_color;
void main() {
  vec4 t = texture(u_tex, v_uv);
  if (u_is_font > 0.5) {
    o_color = vec4(v_col.rgb, v_col.a * t.a);
  } else {
    o_color = vec4(v_col.rgb * t.rgb, v_col.a * t.a);
  }
}
