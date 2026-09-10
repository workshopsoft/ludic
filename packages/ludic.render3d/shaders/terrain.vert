// CDLOD terrain (Strugar 2009): every draw is one 32x32 patch of the quadtree, placed
// and scaled by u_node. Toward the outer edge of its level's range each vertex morphs
// onto the parent level's grid (odd vertices slide to their even neighbours), so a patch
// meets its coarser neighbour edge-for-edge with no cracks and no popping. Height comes
// from one B-spline sample of the height field at the morphed position, so every level
// sits on the same continuous surface.
layout(location = 0) in vec2 a_xz;       // 0..1 across the patch
uniform sampler2D u_height;
uniform float u_half;
uniform mat4 u_view;
uniform mat4 u_proj;
uniform vec2 u_origin;
uniform vec3 u_cam_pos;
uniform vec3 u_node;          // x0, z0, size (m)
uniform vec2 u_morph;         // distance where the morph starts, and where it is complete
uniform float u_grid;         // cells per patch side
float heightSmooth(sampler2D tex, vec2 uv) {
  vec2 res = vec2(textureSize(tex, 0));
  vec2 t = uv * res - 0.5;
  vec2 f = fract(t);
  vec2 i = floor(t);
  vec2 w0 = (1.0 - f) * (1.0 - f) * (1.0 - f) / 6.0;
  vec2 w1 = (4.0 - 6.0 * f * f + 3.0 * f * f * f) / 6.0;
  vec2 w3 = f * f * f / 6.0;
  vec2 w2 = 1.0 - w0 - w1 - w3;
  vec2 s0 = w0 + w1, s1 = w2 + w3;
  vec2 o0 = (i - 1.0 + w1 / s0 + 0.5) / res;
  vec2 o1 = (i + 1.0 + w3 / s1 + 0.5) / res;
  return (texture(tex, vec2(o0.x, o0.y)).r * s0.x + texture(tex, vec2(o1.x, o0.y)).r * s1.x) * s0.y
       + (texture(tex, vec2(o0.x, o1.y)).r * s0.x + texture(tex, vec2(o1.x, o1.y)).r * s1.x) * s1.y;
}
out vec3 v_wpos;
out vec2 v_huv;
void main() {
  vec2 grid = a_xz * u_grid;
  vec2 xz = u_node.xy + a_xz * u_node.z;
  vec2 huv = (xz - u_origin) / (2.0 * u_half) + 0.5;
  float h0 = texture(u_height, huv).r;
  float d = distance(vec3(xz.x, h0, xz.y), u_cam_pos);
  float k = clamp((d - u_morph.x) / max(u_morph.y - u_morph.x, 1.0), 0.0, 1.0);
  vec2 frac2 = fract(grid * 0.5) * 2.0;             // 1 on odd vertices
  grid -= frac2 * k;
  xz = u_node.xy + grid / u_grid * u_node.z;
  huv = (xz - u_origin) / (2.0 * u_half) + 0.5;
  float h = heightSmooth(u_height, huv);
  vec3 p = vec3(xz.x, h, xz.y);
  v_wpos = p;
  v_huv = huv;
  gl_Position = u_proj * u_view * vec4(p, 1.0);
}
