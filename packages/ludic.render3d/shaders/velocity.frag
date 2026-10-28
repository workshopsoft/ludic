// A moving actor's own motion (taa.ludic): skin.vert VELOCITY gives this frame's and last frame's
// clip positions of the same surface point (last frame's model matrix and bone palette), both through
// clean view-projections. Drawn over the camera's motion, depth-tested GEQUAL against the scene, so
// only the pixels the actor won keep it.
in vec2 v_uv;
in vec4 v_cur_clip;
in vec4 v_prev_clip;
out vec4 o_color;
uniform sampler2D u_diff;
uniform vec4 u_fac_base_inv;
#ifdef HAIR_CARD
// a hair card (model.frag FABRIC mode 3, R3D_CARD_VELOCITY_CUT): cut by its groom's coverage as the lit pass cuts it (Unreal's velocity
// pass clips by the material's mask: VelocityShader.usf "Manual clipping here (alpha-test, etc)"); u_fp in model.frag's layout
uniform vec4 u_fp[17];
uniform sampler2D u_fmask;
#endif
void main() {
#ifdef ALPHA_TEST
  bool cut = false;
#ifdef HAIR_CARD
  if (u_fp[16].w > 2.5) {
    if (!hairCardKeep(texture(u_fmask, (v_uv - u_fp[4].xy) / u_fp[4].z).r, u_fp[3], u_dither_frame)) discard;
    cut = true;
  }
#endif
  if (!cut) {
    // the lit pass's own cut (model.frag ALPHA_TEST), so a hair card's empty corners keep the motion behind them
    float da = texture(u_diff, v_uv).a * (1.0 - u_fac_base_inv.a);
    float lod = textureQueryLod(u_diff, v_uv).x;
    if (u_card_cut.x > 0.5) {
      // (R3D_CARD_DITHER: the lit pass's dithered cut, model.frag)
      if (u_card_cut.y < 0.5) da = min(da * (1.0 + 0.45 * max(lod, 0.0)), 1.0);
      if (!cardDitherKeep(da, u_dither_frame)) discard;
    } else {
      float a = min(da * (1.0 + 0.45 * max(lod, 0.0)), 1.0);
      float cov = (a - 0.4) / max(fwidth(a), 1e-4) + 0.5;
      if (cov < 0.02) discard;
    }
  }
#endif
  vec2 c = v_cur_clip.xy / max(v_cur_clip.w, 1e-7);
  vec2 p = v_prev_clip.xy / max(v_prev_clip.w, 1e-7);
  vec2 mv = (p - c) * 0.5;
  if (v_prev_clip.w <= 0.0) mv = vec2(4.0);
  o_color = vec4(mv, 0.0, 1.0);
}
