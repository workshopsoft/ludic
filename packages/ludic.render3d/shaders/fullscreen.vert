// full-screen triangle from gl_VertexID; uv in [0,1], z = 1 (the far plane)
out vec2 v_uv;
void main() {
  vec2 p = vec2((gl_VertexID == 1) ? 3.0 : -1.0, (gl_VertexID == 2) ? 3.0 : -1.0);
  v_uv = p * 0.5 + 0.5;
  gl_Position = vec4(p, 1.0, 1.0);
}
