// terpage.glsl - the terrain maps read through a page table of fine tiles, over a coarse map.
//
// THE REFERENCE COPY. Nothing prepends this file: a stage is assembled from its variant's
// defines, wind.glsl, and for a fragment stage noise.glsl and lighting.glsl, and there is no
// #include - so each shader that reads the ground carries the sections it needs, pasted from
// here, and a change here is a change pasted into every copy (grep TP_HELPERS). Each section
// has its own guard, so a stage that ends up with two copies still compiles, and a stage only
// declares the arrays it reads: glslang keeps every declared sampler in the program's layout.
//
// Before a paste: TP_FRAGMENT in a fragment stage (its fallbacks keep their implicit level of
// detail), and TP_HMAP when the stage's height sampler is not u_ts_height (terrain's u_height).
// The ground normal needs u_ter_normal declared first, the photograph u_ortho.
//
// The contract with the runtime: u_tp_page is n x n R32F, slot + 1 for a
// resident tile and 0 for none; each array layer is a tile with a one-texel border taken from
// its neighbours, so linear filtering and the B-spline's taps cross a tile edge seamlessly.
// While paging is on, u_ts_height / u_height, u_ter_normal and u_ortho hold a COARSE whole-map
// level; while it is off they hold today's full maps and every helper here is today's read.

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

// ---- the baked normal (x, z; y is rebuilt by the caller) ----------------------------------
#ifndef TP_NORMAL
#define TP_NORMAL
uniform sampler2DArray u_tp_nrm;
vec2 terNormalXZ(vec2 uv) {
#ifdef TP_FRAGMENT
  if (u_tp_on < 0.5) return texture(u_ter_normal, uv).rg;
  // taken before the per-pixel branch: a neighbour on another tile must not decide the level
  vec2 dx = dFdx(uv), dy = dFdy(uv);
#endif
  float s = tpSlot(uv);
  if (s >= 0.0) return textureLod(u_tp_nrm, vec3(tpUV(uv, u_tp_dims.y), s), 0.0).rg;
#ifdef TP_FRAGMENT
  return textureGrad(u_ter_normal, uv, dx, dy).rg;
#else
  return textureLod(u_ter_normal, uv, 0.0).rg;
#endif
}
#endif

// ---- the photograph ----------------------------------------------------------------------
#ifndef TP_ORTHO
#define TP_ORTHO
uniform sampler2DArray u_tp_ortho;
// level-0 colour, fine where a tile is resident; the coarse map (with its mips) elsewhere
vec3 terOrtho(vec2 uv) {
#ifdef TP_FRAGMENT
  if (u_tp_on < 0.5) return texture(u_ortho, uv).rgb;
  vec2 dx = dFdx(uv), dy = dFdy(uv);
#endif
  float s = tpSlot(uv);
  if (s >= 0.0) return textureLod(u_tp_ortho, vec3(tpUV(uv, u_tp_dims.z), s), 0.0).rgb;
#ifdef TP_FRAGMENT
  return textureGrad(u_ortho, uv, dx, dy).rgb;
#else
  return textureLod(u_ortho, uv, 0.0).rgb;
#endif
}
#endif

// ---- the photograph's measures (declares no sampler: a stage reading u_ortho blurred needs no tile)
#ifndef TP_ORTHO_LOD
#define TP_ORTHO_LOD
// the FULL photograph's texels a side, for filters that weigh by the texel (orthoSmooth)
vec2 tpOrthoRes() { return u_tp_on > 0.5 ? vec2(u_tp_dims.z * u_tp_dims.x) : vec2(textureSize(u_ortho, 0)); }
// A blurred read (textureLod 1..2.5) names a level of the FULL photograph; on the coarse map
// the same detail is that many levels lower, so the ground's far colour does not soften.
float tpOrthoLod(float lod) {
  if (u_tp_on < 0.5) return lod;
  return max(lod - log2(u_tp_dims.z * u_tp_dims.x / float(textureSize(u_ortho, 0).x)), 0.0);
}
#endif
