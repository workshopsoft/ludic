// tersun.frag — the terrain's sun visibility, on its own, one screen-sized R8 buffer.
//
// The ground's shading shader is large: it blends four scanned materials, a photograph
// and a dozen noise fields. Adding a read of the cascade shadow map to it costs about
// six milliseconds a frame on this driver — and costs the same whether the map is tapped
// once or eight times, filtered or texelFetched, compared in hardware or by hand. It is
// a cliff the big shader falls off, not work it performs. The same read from a small
// shader is nearly free, so the read happens here instead: this pass rasterises the same
// CDLOD patches, evaluates the cascades once per pixel, and writes the answer for
// terrain.frag to look up by fragment coordinate.
in vec3 v_wpos;
in vec2 v_huv;
out float o_sh;
// no u_height here: the vertex stage reads the ground, and every declared sampler counts
// against the stage's limit (MoltenVK) whether it is read or not
// the baked terrain normal: x and z in RG16F, y rebuilt (a terrain normal always points up)
uniform sampler2D u_ter_normal;
#define TP_FRAGMENT
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
vec3 terNormal(vec2 uv) { vec2 xz = terNormalXZ(uv);  return vec3(xz.x, sqrt(max(1.0 - dot(xz, xz), 0.0)), xz.y); }
uniform mat4 u_view;
uniform float u_far_split;
uniform float u_far_band;
void main() {
  vec3 p = v_wpos;
  if (p.y < u_clip_y) discard;
  vec3 N = terNormal(v_huv);
  float dist = length(p - u_cam_pos);
  float viewDepth = -(u_view * vec4(p, 1.0)).z;
  // The same tier choice the ground makes, cross-faded over the same band: the near tier
  // keeps its filtered penumbra, the far tier its single tap, and the boundary between
  // them is not a contour you can find on the hillside.
  if (dist > u_far_split + u_far_band) o_sh = sunShadowCheap(p, N, viewDepth);
  else if (dist < u_far_split - u_far_band) o_sh = sunShadow(p, N, viewDepth);
  else o_sh = mix(sunShadow(p, N, viewDepth), sunShadowCheap(p, N, viewDepth),
                  smoothstep(u_far_split - u_far_band, u_far_split + u_far_band, dist));
}
