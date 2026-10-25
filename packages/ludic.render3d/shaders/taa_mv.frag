// The camera's motion at every pixel, from the depth (taa.ludic): where this pixel's surface was on
// screen last frame, as prev uv - this uv. The scene's own pixels are still (the static world is
// most of a frame); the moving actors are drawn over this afterwards with motion of their own
// (skin.vert VELOCITY, velocity.frag). Both use the clean view-projections, so the motion holds no
// jitter: a still camera gives exactly zero, which is what the resolve and DLSS expect.
in vec2 v_uv;
out vec4 o_color;
uniform sampler2D u_depth;     // the opaque scene's depth (reversed: 1 near, 0 the sky)
uniform mat4 u_inv_vp;         // this frame's jittered inverse view-projection: the depth was drawn with it
uniform mat4 u_vp_cur;         // this frame's clean view-projection
uniform mat4 u_vp_prev;        // last frame's
void main() {
  float d = texture(u_depth, v_uv).r;
  // the sky (d = 0) is a direction, not a point: the far plane is at infinity, so w comes out 0 and
  // the two projections below still place it - only the camera's turn moves it
  vec4 w = u_inv_vp * vec4(v_uv * 2.0 - 1.0, d, 1.0);
  vec4 c = u_vp_cur * w;
  vec4 p = u_vp_prev * w;
  vec2 mv = (p.xy / max(p.w, 1e-7) - c.xy / max(c.w, 1e-7)) * 0.5;
  // behind last frame's camera (a sharp turn past a near wall): no history there
  if (p.w <= 0.0) mv = vec2(4.0);
  o_color = vec4(mv, 0.0, 1.0);
}
