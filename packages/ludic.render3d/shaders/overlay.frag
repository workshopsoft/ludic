// 2D overlay: an image texture, the font atlas (white glyphs on alpha) or a flat colour, times a
// colour. Which one is the vertex's own: v carries 4 x the mode (0 image, 1 font, 2 flat) on top of
// its real coordinate, so text, panels and an image's quads share a draw (overlay.ludic, ov_use_tex).
in vec2 v_uv;
in vec4 v_col;
uniform sampler2D u_tex;
uniform sampler2D u_font;
out vec4 o_color;
void main() {
  float mode = floor((v_uv.y + 0.5) * 0.25);
  vec2 uv = vec2(v_uv.x, v_uv.y - 4.0 * mode);
  if (mode > 1.5) {
    o_color = v_col;
  } else if (mode > 0.5) {
    o_color = vec4(v_col.rgb, v_col.a * texture(u_font, uv).a);
  } else {
    vec4 t = texture(u_tex, uv);
    o_color = vec4(v_col.rgb * t.rgb, v_col.a * t.a);
  }
}
