// hlod.vert - a cell's merged proxy: vertices are the bake's (position in the cell's frame, normal, colour), placed by
// the cell's render-space offset, which is one uniform so a rebase of the floating origin moves nothing in memory.
layout(location = 0) in vec3 a_pos;
layout(location = 1) in vec3 a_nrm;
layout(location = 2) in vec4 a_col;
uniform mat4 u_view;
uniform mat4 u_proj;
uniform vec3 u_cell_off;
out vec3 v_wpos;
out vec3 v_nrm;
out vec4 v_col;
void main() {
  vec3 w = a_pos + u_cell_off;
  v_wpos = w;
  v_nrm = a_nrm;
  v_col = a_col;
  gl_Position = u_proj * u_view * vec4(w, 1.0);
}
