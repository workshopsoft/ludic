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
// The default is the temporal resolve (taa.ludic), and with it this pass runs RCAS (below) instead.
// What follows is the fallback with TAA off (R3D_NOTAA) - before taa.ludic there was no anti-aliasing
// at all on a machine without DLSS, which is every Mac.
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

// ---- after the temporal resolve -------------------------------------------------------------
// With TAA on (taa.ludic) the frame arrives anti-aliased but a little soft - the reconstruction
// filter and the history's resampling both blur - so it is sharpened back with a robust contrast-
// adaptive sharpen (the method of AMD's RCAS, FidelityFX FSR 1): a negative-lobed cross whose lobe is
// limited per pixel so the result never leaves the range of its four neighbours. It cannot ring or
// halo, and cannot bring back the aliasing the resolve took away the way the unsharp mask would.
// u_rcas is the sharpness, 0 (off) .. 1 (the most the limit allows).
uniform float u_rcas;
vec3 rcas(vec2 uv, vec2 texel) {
  vec3 b = texture(u_src, uv - vec2(0.0, texel.y)).rgb;
  vec3 d = texture(u_src, uv - vec2(texel.x, 0.0)).rgb;
  vec3 e = texture(u_src, uv).rgb;
  vec3 f = texture(u_src, uv + vec2(texel.x, 0.0)).rgb;
  vec3 h = texture(u_src, uv + vec2(0.0, texel.y)).rgb;
  vec3 mn = min(min(b, d), min(f, h));
  vec3 mx = max(max(b, d), max(f, h));
  // the largest negative lobe that keeps the result inside [min, max] of the ring, per channel
  vec3 hitMin = min(mn, e) / (4.0 * mx + 1e-4);
  vec3 hitMax = (1.0 - max(mx, e)) / (4.0 * mn - 4.0 - 1e-4);
  vec3 lobeRGB = max(-hitMin, hitMax);
  float lobe = max(-0.1875, min(max(lobeRGB.r, max(lobeRGB.g, lobeRGB.b)), 0.0)) * u_rcas;
  return clamp((lobe * (b + d + f + h) + e) / (4.0 * lobe + 1.0), 0.0, 1.0);
}

uniform float u_fxaa;
void main() {
  if (u_rcas > 0.0) {
    vec3 rc = rcas(v_uv, u_texel);
    float gr = (hash(v_uv * 1731.0 + fract(u_time)) - 0.5) * u_grain;
    rc += gr * (0.6 + 0.4 * (1.0 - luma(rc)));
    o_color = vec4(clamp(rc, 0.0, 1.0), 1.0);
    return;
  }
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
