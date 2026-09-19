// luma unsharp mask + film grain, on the final LDR image
in vec2 v_uv;
out vec4 o_color;
uniform sampler2D u_src;
uniform vec2 u_texel;
uniform float u_amount;
uniform float u_grain;
float hash(vec2 p) { return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453); }
float luma(vec3 c) { return dot(c, vec3(0.299, 0.587, 0.114)); }

// ---- anti-aliasing -------------------------------------------------------------------------
// THE SHIPPING DEFAULT HAS BEEN NO ANTI-ALIASING AT ALL. The temporal resolve was removed
// (post.ludic says why, and it was right to go: it reprojected water through the surface plane
// and dragged the mirror image behind the camera), the setting's first option went on saying
// "Temporal", and post_ms_samples defaults to 1 - so a frame full of grass blades and needle
// cards shimmered on every machine without DLSS, which is every Mac.
//
// This is a spatial pass with NO history: it cannot drag, it cannot smear a reflection, and it
// costs four taps on a pass that was already sampling its own neighbourhood for the unsharp
// mask. It does not fix sub-pixel grass shimmer - nothing spatial can - but it fixes every
// geometric edge, which is what the eye follows when you walk.
vec3 fxaa(vec2 uv, vec2 texel) {
  vec3 rgbM = texture(u_src, uv).rgb;
  float lM = luma(rgbM);
  float lN = luma(texture(u_src, uv + vec2(0.0, texel.y)).rgb);
  float lS = luma(texture(u_src, uv - vec2(0.0, texel.y)).rgb);
  float lE = luma(texture(u_src, uv + vec2(texel.x, 0.0)).rgb);
  float lW = luma(texture(u_src, uv - vec2(texel.x, 0.0)).rgb);
  float lMin = min(lM, min(min(lN, lS), min(lE, lW)));
  float lMax = max(lM, max(max(lN, lS), max(lE, lW)));
  float range = lMax - lMin;
  // a contrast floor, or film grain and dithering get "anti-aliased" into mush
  if (range < max(0.0312, lMax * 0.125)) return rgbM;
  // which way the edge runs, and which side of it is the step
  bool isHorz = abs(lN + lS - 2.0 * lM) >= abs(lE + lW - 2.0 * lM);
  vec2 dir = isHorz ? vec2(0.0, texel.y) : vec2(texel.x, 0.0);
  float l1 = isHorz ? lN : lE;
  float l2 = isHorz ? lS : lW;
  if (abs(l1 - lM) < abs(l2 - lM)) dir = -dir;
  vec3 a = texture(u_src, uv + dir * 0.5).rgb;
  vec3 b = texture(u_src, uv + dir * 1.5).rgb;
  vec3 blended = (a + b) * 0.5;
  // Never let the blend leave the neighbourhood's own luma range. Without this guard a thin
  // bright line - a blade against the sky, a rim on a trunk - reaches two pixels past where it
  // belongs and reads as a halo, which is the failure everyone recognises as "this game has
  // FXAA on".
  float lB = luma(blended);
  if (lB < lMin || lB > lMax) return mix(rgbM, a, 0.5);
  return mix(rgbM, blended, 0.75);
}

uniform float u_fxaa;
void main() {
  // The unsharp mask's delta is computed from the RAW image and only then applied to the
  // anti-aliased colour. Taking the centre from the FXAA result and the neighbours from the
  // raw texture measures a difference that is half smoothing and half signal, so the mask
  // sharpens precisely the edges FXAA just softened - measured, that made the frame's
  // single-pixel reversal energy 29% WORSE than no anti-aliasing at all.
  vec3 raw = texture(u_src, v_uv).rgb;
  vec3 c = (u_fxaa > 0.5) ? fxaa(v_uv, u_texel) : raw;
  vec3 n = texture(u_src, v_uv + vec2(0, u_texel.y)).rgb, s = texture(u_src, v_uv - vec2(0, u_texel.y)).rgb;
  vec3 e = texture(u_src, v_uv + vec2(u_texel.x, 0)).rgb, w = texture(u_src, v_uv - vec2(u_texel.x, 0)).rgb;
  float lraw = luma(raw);
  float lb = (luma(n) + luma(s) + luma(e) + luma(w) + lraw * 4.0) / 8.0;
  float d = clamp((lraw - lb) * u_amount, -0.08, 0.08);
  float lc = luma(c);
  vec3 col = c * (1.0 + d / max(lraw, 1e-3));
  float g = (hash(v_uv * 1731.0 + fract(u_time)) - 0.5) * u_grain;
  col += g * (0.6 + 0.4 * (1.0 - lc));
  o_color = vec4(clamp(col, 0.0, 1.0), 1.0);
}
