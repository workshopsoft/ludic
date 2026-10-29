// rvt_clear.frag - one runtime virtual texture page's rect emptied before it is drawn (rvt.ludic): both colour atlases to nothing and
// the page depth to the far plane (0: reversed), so the page's surfaces are tested against nothing a former page left there. A clear
// inside a pass clears the whole atlas (gvk_clear), so a page is cleared by a triangle drawn into its viewport alone.
layout(location = 0) out vec4 o_color;
layout(location = 1) out vec4 o_rvt_b;
void main() {
  o_color = vec4(0.0, 0.0, 0.0, 1.0);
  o_rvt_b = vec4(0.5, 0.5, 0.0, 1.0);
  gl_FragDepth = 0.0;
}
