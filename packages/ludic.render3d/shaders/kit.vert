// kit.vert - a building (or prop) kit, instanced: attribute 3 = (x, y, z, scale), 4 = (sin yaw, cos yaw, seed, flags),
// 5 = (tint r, g, b, variation), 6 = (w, d, h, radius) of a box kit's instance (radius 0: an ordinary one). The instance
// lists are what kinst_cull.comp packs (or kinst.ludic fills), in render space: positions have the floating origin taken
// out already, so nothing here sees a large number. A box instance puts each vertex at its anchors (kitbox.ludic):
// x = sx w + ox, z = sz d + oz, y = sh h + sd d + oy, attributes 8 (sx, sz, sh, sd) and 9 (ox, oy, oz).
layout(location = 0) in vec3 a_pos;
layout(location = 1) in vec3 a_nrm;
layout(location = 2) in vec2 a_uv;
layout(location = 3) in vec4 i_pos;
layout(location = 4) in vec4 i_rot;
layout(location = 5) in vec4 i_tint;
layout(location = 6) in vec4 i_box;
layout(location = 8) in vec4 a_anchor;
layout(location = 9) in vec3 a_offset;
// COLOR_0 (glTF vertex colour), attribute 7. A mesh without it leaves the input unfed, which Vulkan reads as (0,0,0,0): that means white.
layout(location = 7) in vec4 a_col;
uniform mat4 u_view;
uniform mat4 u_proj;
uniform mat4 u_light_vp;
uniform vec3 u_cam_pos;
out vec3 v_wpos;
out vec3 v_nrm;
out vec2 v_uv;
out vec4 v_tint;
out vec4 v_col;
out float v_seed;
// the height above the instance's base (its origin), in metres: where the storey lines of kit.frag count from
out float v_h;
#ifdef INTERIOR_MAP
// the model's own frame, where the facade's window grid lives: nothing in it moves when the origin does, and a
// turned or scaled instance carries its windows with it
out vec3 v_lpos;
out vec3 v_lnrm;
out vec3 v_lcam;
#endif
void main() {
  float s = i_rot.x, c = i_rot.y;
  bool boxed = i_box.w > 0.0;
  vec3 lp = boxed ? vec3(a_anchor.x * i_box.x + a_offset.x, a_anchor.z * i_box.z + a_anchor.w * i_box.y + a_offset.y, a_anchor.y * i_box.y + a_offset.z) : a_pos;
  float sc = boxed ? 1.0 : i_pos.w;
  vec3 p = lp * sc;
  p = vec3(c * p.x + s * p.z, p.y, -s * p.x + c * p.z);
  vec3 n = vec3(c * a_nrm.x + s * a_nrm.z, a_nrm.y, -s * a_nrm.x + c * a_nrm.z);
  vec3 w = p + i_pos.xyz;
  v_wpos = w;
  v_nrm = n;
  v_uv = a_uv;
  v_tint = i_tint;
  v_col = (a_col == vec4(0.0)) ? vec4(1.0) : a_col;
  v_seed = i_rot.z;
  v_h = p.y;
#ifdef INTERIOR_MAP
  v_lpos = lp;
  v_lnrm = a_nrm;
  vec3 d = (u_cam_pos - i_pos.xyz) / sc;
  v_lcam = vec3(c * d.x - s * d.z, d.y, s * d.x + c * d.z);
#endif
#ifdef SHADOW_PASS
  gl_Position = u_light_vp * vec4(w, 1.0);
#else
  gl_Position = u_proj * u_view * vec4(w, 1.0);
#endif
}
