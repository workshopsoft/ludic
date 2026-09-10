// the inverted-hull shell (skin.vert with OUTLINE): a flat colour, no shading. Cut-out
// meshes still need their shape, so the alpha test comes along.
uniform vec3 u_outline_col;
out vec4 o_color;
#ifdef ALPHA_TEST
in vec2 v_uv;
uniform sampler2D u_diff;
void main() {
  if (texture(u_diff, v_uv).a < 0.45) discard;
  o_color = vec4(u_outline_col, 1.0);
}
#else
void main() { o_color = vec4(u_outline_col, 1.0); }
#endif
