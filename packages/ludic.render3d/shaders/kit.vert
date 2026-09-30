// kit.vert - a building (or prop) kit, instanced: attribute 3 = (x, y, z, scale), 4 = (sin yaw, cos yaw, seed, flags),
// 5 = (tint r, g, b, variation). The instance lists are what kinst_cull.comp packs (or kinst.ludic fills), in
// render space: positions have the floating origin taken out already, so nothing here sees a large number.
layout(location = 0) in vec3 a_pos;
layout(location = 1) in vec3 a_nrm;
layout(location = 2) in vec2 a_uv;
layout(location = 3) in vec4 i_pos;
layout(location = 4) in vec4 i_rot;
layout(location = 5) in vec4 i_tint;
uniform mat4 u_view;
uniform mat4 u_proj;
uniform mat4 u_light_vp;
uniform vec3 u_cam_pos;
out vec3 v_wpos;
out vec3 v_nrm;
out vec2 v_uv;
out vec4 v_tint;
out float v_seed;
#ifdef INTERIOR_MAP
// the model's own frame, where the facade's window grid lives: nothing in it moves when the origin does, and a
// turned or scaled instance carries its windows with it
out vec3 v_lpos;
out vec3 v_lnrm;
out vec3 v_lcam;
#endif
void main() {
  float s = i_rot.x, c = i_rot.y;
  vec3 p = a_pos * i_pos.w;
  p = vec3(c * p.x + s * p.z, p.y, -s * p.x + c * p.z);
  vec3 n = vec3(c * a_nrm.x + s * a_nrm.z, a_nrm.y, -s * a_nrm.x + c * a_nrm.z);
  vec3 w = p + i_pos.xyz;
  v_wpos = w;
  v_nrm = n;
  v_uv = a_uv;
  v_tint = i_tint;
  v_seed = i_rot.z;
#ifdef INTERIOR_MAP
  v_lpos = a_pos;
  v_lnrm = a_nrm;
  vec3 d = (u_cam_pos - i_pos.xyz) / i_pos.w;
  v_lcam = vec3(c * d.x - s * d.z, d.y, s * d.x + c * d.z);
#endif
#ifdef SHADOW_PASS
  gl_Position = u_light_vp * vec4(w, 1.0);
#else
  gl_Position = u_proj * u_view * vec4(w, 1.0);
#endif
}
