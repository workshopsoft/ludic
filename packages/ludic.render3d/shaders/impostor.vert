// camera-facing (around y) card per instance, showing the atlas tile nearest the view angle
layout(location = 0) in vec2 a_xy;       // [-0.5, 0.5] x [0, 1]
layout(location = 1) in vec2 a_uv;
layout(location = 3) in vec4 i_pos;      // x y z scale
layout(location = 4) in vec4 i_rot;      // sin cos seed wind
uniform mat4 u_view;
uniform mat4 u_proj;
uniform mat4 u_light_vp;
uniform vec3 u_cam_pos;
uniform vec3 u_face_dir;                 // direction the cards face (to the camera, or the sun in the shadow pass)
uniform float u_radius;
uniform float u_height;
uniform float u_tiles;
out vec2 v_uv;
out vec3 v_wpos;
out float v_seed;
out float v_tile;
out float v_yaw;
void main() {
  vec3 center = i_pos.xyz;
#ifdef SHADOW_PASS
  vec3 toCam = normalize(vec3(u_face_dir.x, 0.0, u_face_dir.z));
#else
  vec3 toCam = u_cam_pos - center; toCam.y = 0.0; toCam = normalize(toCam);
#endif
  vec3 right = vec3(-toCam.z, 0.0, toCam.x);
  float yaw = atan(i_rot.x, i_rot.y);
  // angle of the viewer around the (rotated) tree, in tile units
  float ang = atan(toCam.x, -toCam.z) - yaw;
  float t = floor(fract(ang / 6.2831853) * u_tiles + 0.5);
  v_tile = mod(t, u_tiles);
  v_yaw = yaw;
  vec3 w = center + right * (a_xy.x * 2.0 * u_radius * i_pos.w) + vec3(0.0, a_xy.y * u_height * i_pos.w, 0.0);
  v_wpos = w;
  v_uv = a_uv;
  v_seed = i_rot.z;
#ifdef SHADOW_PASS
  gl_Position = u_light_vp * vec4(w, 1.0);
#else
  gl_Position = u_proj * u_view * vec4(w, 1.0);
#endif
}
