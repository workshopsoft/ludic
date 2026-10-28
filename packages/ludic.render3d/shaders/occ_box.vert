// an occlusion test's box (occlusion.ludic): the unit cube placed on an actor's bounds, in the frame's view
layout(location = 0) in vec3 a_pos;
uniform mat4 u_vp;
uniform vec3 u_c;           // the box's middle
uniform vec3 u_e;           // and its half extents
void main() {
  gl_Position = u_vp * vec4(u_c + a_pos * u_e, 1.0);
}
