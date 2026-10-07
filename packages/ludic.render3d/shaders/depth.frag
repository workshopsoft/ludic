// depth.frag — the foliage depth prepass (scatter_draw_depth, render.ludic).
//
// A crown of needle cards is many cut-out quads deep from any angle. Lit directly, every
// card behind the front one runs the whole lighting shader and is thrown away afterwards,
// because a shader that can discard switches early depth rejection off. So the near tree
// LODs first write depth with this: the same alpha coverage test the lit shader applies,
// and nothing else. The lit pass then draws them with no discard and an equal depth test
// (model.frag's EQ_PASS), and each pixel of foliage is lit once.
//
// The test must match model.frag's ALPHA_TEST exactly - a texel this pass keeps and that
// one would have cut is drawn solid - so it is the same formula, taken at coverage 0.5
// because without MSAA a fragment is either there or not.
in vec3 v_wpos;
in vec2 v_uv;
in float v_near;
uniform sampler2D u_diff;
void main() {
  if (v_wpos.y < u_clip_y) discard;
#ifndef SHADOW_PASS
  if (fogCut(v_wpos)) discard;   // the fog wall's dissolve (lighting.glsl)
#endif
#ifdef NEAR_FADE
  // Leaves in the camera's face (model.vert's v_near). Dithered out rather than blended:
  // no sorting, no second pass and no halo, and because it happens in the PREPASS the lit
  // pass never sees those pixels either - its equal-depth test simply finds nothing to
  // match. A branch a metre from the lens stops being an opaque wall in front of the body.
  if (v_near < 0.999 && v_near < fract(sin(dot(gl_FragCoord.xy, vec2(12.9898, 78.233))) * 43758.5453)) discard;
#endif
  vec4 d = texture(u_diff, v_uv);
  float lod = textureQueryLod(u_diff, v_uv).x;
  float a = min(d.a * (1.0 + 0.45 * max(lod, 0.0)), 1.0);
  float cov = (a - 0.4) / max(fwidth(a), 1e-4) + 0.5;
  if (cov < 0.5) discard;
}
