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
#define TP_HMAP u_height
// terpage.glsl, pasted (the reference copy and its rules are there)
// ---- the page table ----------------------------------------------------------------------
#ifndef TP_HELPERS
#define TP_HELPERS
uniform sampler2D u_tp_page;   // R32F, a texel a tile: slot + 1, 0 = not resident
uniform float u_tp_on;         // 1 while paging; 0 reads the whole maps exactly as before
uniform vec4 u_tp_dims;        // tiles a side, height texels a tile, photo texels a tile, full height res
// the layer holding a full-map uv, or -1: paging off, off the map, or not resident
float tpSlot(vec2 uv) {
  if (u_tp_on < 0.5 || uv.x < 0.0 || uv.y < 0.0 || uv.x >= 1.0 || uv.y >= 1.0) return -1.0;
  ivec2 t = min(ivec2(floor(uv * u_tp_dims.x)), ivec2(int(u_tp_dims.x) - 1));
  return texelFetch(u_tp_page, t, 0).r - 1.0;
}
// a full-map uv inside its tile's layer of k texels a side, past the one-texel border
vec2 tpUV(vec2 uv, float k) { return (1.0 + fract(uv * u_tp_dims.x) * k) / (k + 2.0); }
#endif
// ---- height (vertex and mesh stages) -----------------------------------------------------
#ifndef TP_HEIGHT
#define TP_HEIGHT
#ifndef TP_HMAP
#define TP_HMAP u_ts_height
#endif
uniform sampler2DArray u_tp_h;
// bilinear height, fine where a tile is resident. Outside a fragment stage texture() IS level 0
// (glslang emits the same explicit-lod sample), so this is the old read bit for bit.
float terHeight(vec2 uv) {
  float s = tpSlot(uv);
  if (s >= 0.0) return textureLod(u_tp_h, vec3(tpUV(uv, u_tp_dims.y), s), 0.0).r;
  return textureLod(TP_HMAP, uv, 0.0).r;
}
// The B-spline through four bilinear taps (heightSmooth). Paging on, the texel is the FULL
// map's - the coarse map's own size would halve the surface's detail - and each tap finds its
// own tile, so a patch straddling two tiles, or a tile and the coarse map, stays one surface.
float terHeightSmooth(vec2 uv) {
  vec2 res = u_tp_on > 0.5 ? vec2(u_tp_dims.w) : vec2(textureSize(TP_HMAP, 0));
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
  return (terHeight(vec2(o0.x, o0.y)) * s0.x + terHeight(vec2(o1.x, o0.y)) * s1.x) * s0.y
       + (terHeight(vec2(o0.x, o1.y)) * s0.x + terHeight(vec2(o1.x, o1.y)) * s1.x) * s1.y;
}
#endif
out vec3 v_wpos;
out vec2 v_huv;
void main() {
  vec2 grid = a_xz * u_grid;
  vec2 xz = u_node.xy + a_xz * u_node.z;
  vec2 huv = (xz - u_origin) / (2.0 * u_half) + 0.5;
  float h0 = terHeight(huv);
  float d = distance(vec3(xz.x, h0, xz.y), u_cam_pos);
  float k = clamp((d - u_morph.x) / max(u_morph.y - u_morph.x, 1.0), 0.0, 1.0);
  vec2 frac2 = fract(grid * 0.5) * 2.0;             // 1 on odd vertices
  grid -= frac2 * k;
  xz = u_node.xy + grid / u_grid * u_node.z;
  huv = (xz - u_origin) / (2.0 * u_half) + 0.5;
  float h = terHeightSmooth(huv);
  vec3 p = vec3(xz.x, h, xz.y);
  v_wpos = p;
  v_huv = huv;
  gl_Position = u_proj * u_view * vec4(p, 1.0);
}
