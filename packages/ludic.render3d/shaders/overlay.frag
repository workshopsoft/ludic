// 2D overlay: an image texture, the font atlas (glyph coverage, R8) or a flat colour, times a
// colour. Which one is the vertex's own: v carries 4 x the mode (0 image, 1 font, 2 flat) on top of
// its real coordinate, so text, panels and an image's quads share a draw (overlay.ludic, ov_use_tex).
in vec2 v_uv;
in vec4 v_col;
uniform sampler2D u_tex;
uniform sampler2D u_font;
out vec4 o_color;
#ifdef HDR10
// the interface is sRGB: drawn into an HDR10 frame its white sits at the player's paper white, as the
// picture's white does. u_hdr_scale multiplies that for one batch (ov_hdr_nits): a calibration
// screen's test patches, which have to reach past paper white to the display's peak.
uniform float u_hdr_paper;
uniform float u_hdr_scale;
vec3 bt709_to_2020(vec3 c) {
  return mat3(0.6274, 0.0691, 0.0164, 0.3293, 0.9195, 0.0880, 0.0433, 0.0114, 0.8956) * c;
}
vec3 pq_encode(vec3 nits) {
  const float m1 = 0.1593017578125, m2 = 78.84375, c1 = 0.8359375, c2 = 18.8515625, c3 = 18.6875;
  vec3 yp = pow(clamp(nits / 10000.0, 0.0, 1.0), vec3(m1));
  return pow((c1 + c2 * yp) / (1.0 + c3 * yp), vec3(m2));
}
#endif
void main() {
  float mode = floor((v_uv.y + 0.5) * 0.25);
  vec2 uv = vec2(v_uv.x, v_uv.y - 4.0 * mode);
  if (mode > 1.5) {
    o_color = v_col;
  } else if (mode > 0.5) {
    o_color = vec4(v_col.rgb, v_col.a * texture(u_font, uv).r);   // the atlas is its coverage alone (R8)
  } else {
    vec4 t = texture(u_tex, uv);
    o_color = vec4(v_col.rgb * t.rgb, v_col.a * t.a);
  }
#ifdef HDR10
  float nits = max(u_hdr_paper, 80.0) * max(u_hdr_scale, 0.0);
  o_color.rgb = pq_encode(bt709_to_2020(pow(max(o_color.rgb, vec3(0.0)), vec3(2.2))) * nits);
#endif
}
