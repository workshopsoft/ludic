#ifdef WATER_MESH
// a mesh body (water_mesh_add): the model's own positions, moved by the body's offset
layout(location = 0) in vec3 a_pos;
uniform vec3 u_offset;
#else
layout(location = 0) in vec2 a_xz;
#endif
uniform mat4 u_view;
uniform mat4 u_proj;
uniform float u_level;
uniform vec2 u_center;
uniform vec2 u_extent;
out vec3 v_wpos;
void main() {
#ifdef WATER_MESH
  vec3 p = a_pos + u_offset;
#else
  vec3 p = vec3(u_center.x + a_xz.x * 2.0 * u_extent.x, u_level, u_center.y + a_xz.y * 2.0 * u_extent.y);   // the grid spans ±0.5
#endif
  v_wpos = p;
  gl_Position = u_proj * u_view * vec4(p, 1.0);
}
