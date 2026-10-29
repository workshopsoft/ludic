// exposure -> contrast -> ACES with the scene's hue -> grade -> vignette -> sRGB, with dithering
in vec2 v_uv;
out vec4 o_color;
uniform sampler2D u_hdr;
uniform sampler2D u_bloom;
uniform sampler2D u_ao;
uniform float u_ao_strength;
uniform float u_gi_strength;
uniform sampler2D u_hair_t;       // the strands' transmittance this frame (strands.ludic), when u_hair_on
uniform float u_hair_on;
uniform float u_ao_view;         // R3D_AO_VIEW: the occlusion itself, grey
uniform vec3 u_wb;                // white balance multiplier
uniform vec3 u_lift;
uniform vec3 u_gain;
uniform float u_exposure;
uniform sampler2D u_adapt;        // the GPU's adapted exposure (adapt.frag), 1x1
uniform float u_auto;             // 1: use it, 0: u_exposure as set
uniform float u_bloom_strength;
uniform float u_vignette;
uniform float u_saturation;
uniform float u_contrast;
vec3 aces(vec3 x) {
  const float a = 2.51, b = 0.03, c = 2.43, d = 0.59, e = 0.14;
  return clamp((x * (a * x + b)) / (x * (c * x + d) + e), 0.0, 1.0);
}
float hash(vec2 p) { return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453); }
// Written straight to the screen (post.ludic post_direct: no sharpen, FXAA or RCAS after a temporal upscaler, so the after-pass would
// only add its grain): sharpen.frag's film grain here instead, as Unreal's PostProcessTonemap.usf applies its grain in the one
// output-resolution pass. u_fold_grain 0 when the after-pass runs.
uniform float u_fold_grain;
uniform float u_fold_time;
vec3 foldGrain(vec3 c) {
  if (u_fold_grain == 0.0) return c;
  c = clamp(c, 0.0, 1.0);
  float lc = dot(c, vec3(0.299, 0.587, 0.114));
  float g = (hash(v_uv * 1731.0 + fract(u_fold_time)) - 0.5) * u_fold_grain;
  return clamp(c + g * (0.6 + 0.4 * (1.0 - lc)), 0.0, 1.0);
}
// The day's filmic contrast, in stops about mid grey: steeper above it (the highlights' punch) and the
// identity below, eased over the first stop so the curve has no corner. Steepening below mid grey too
// darkened every shadow: with ACES's toe a 6.5 : 1 sun-to-shade ratio reached the screen as 39 : 1.
vec3 contrastUp(vec3 c, float k) {
  vec3 t = log2(max(c, vec3(1.0e-8)) / 0.18);
  vec3 ease = t + (k - 1.0) * t * t * 0.5;
  vec3 lin = t + (k - 1.0) * (t - 0.5);
  vec3 q = mix(mix(t, ease, step(0.0, t)), lin, step(1.0, t));
  return 0.18 * exp2(q);
}
// Oklab (Ottosson, "A perceptual color space for image processing", 2020): lightness, and a and b whose
// angle is the hue - unlike an RGB channel ratio, a hue held there still looks like the same colour
vec3 toOklab(vec3 c) {
  vec3 lms = mat3(0.4122214708, 0.2119034982, 0.0883024619, 0.5363325363, 0.6806995451, 0.2817188376, 0.0514459929, 0.1073969566, 0.6299787005) * max(c, vec3(0.0));
  lms = pow(lms, vec3(1.0 / 3.0));
  return mat3(0.2104542553, 1.9779984951, 0.0259040371, 0.7936177850, -2.4285922050, 0.7827717662, -0.0040720468, 0.4505937099, -0.8086757660) * lms;
}
vec3 fromOklab(vec3 l) {
  vec3 lms = mat3(1.0, 1.0, 1.0, 0.3963377774, -0.1055613458, -0.0894841775, 0.2158037573, -0.0638541728, -1.2914855480) * l;
  lms = lms * lms * lms;
  return mat3(4.0767416621, -1.2684380046, -0.0041960863, -3.3077115913, 2.6097574011, -0.7034186147, 0.2309699292, -0.3413193965, 1.7076147010) * lms;
}
bool inGamut(vec3 c) { return all(greaterThanEqual(c, vec3(-1.0e-4))) && all(lessThanEqual(c, vec3(1.0001))); }
// ACES per channel decides how light a colour is and how rich, but not its hue: a channel that saturates
// first turns a bright red orange and skin yellow-white, and a dark orange red. So the colour is put back
// at the scene's own hue (Oklab) and, until it nears white, as rich as the scene was; near white as rich as
// the curve made it. Then the chroma comes down, at that lightness and hue, until it is a colour the screen has.
vec3 toneHue(vec3 c, float k) {
  vec3 cn = aces(contrastUp(c, k));
  vec3 co = aces(pow(c / 0.18, vec3(k)) * 0.18);
  vec3 ln = toOklab(cn);
  vec3 lo = toOklab(co);
  vec3 l0 = toOklab(c);
  float c0 = length(l0.yz);
  if (c0 < 1.0e-5 || ln.x < 1.0e-4) return cn;
  // as rich as the scene was (Unreal's tonemapper keeps it near enough: a MetaHuman's shaded skin stays at its albedo's hue and
  // saturation there, where the per-channel curve's - kept before - turned it magenta and every dark colour fiercer), until near
  // white, where the curve's own rolls it off
  float sc = length(lo.yz) / max(lo.x, 1.0e-4);
  float t = clamp((ln.x - 0.9) / 0.1, 0.0, 1.0);
  float s = mix(c0 / max(l0.x, 1.0e-4), max(sc, length(ln.yz) / ln.x), t * t * (3.0 - 2.0 * t));
  vec2 hue = l0.yz / c0;
  float cmax = s * ln.x;
  vec3 rgb = fromOklab(vec3(ln.x, hue * cmax));
  if (!inGamut(rgb)) {
    float a = 0.0;
    float b = 1.0;
    for (int i = 0; i < 10; i++) {
      float m = 0.5 * (a + b);
      if (inGamut(fromOklab(vec3(ln.x, hue * cmax * m)))) { a = m; } else { b = m; }
    }
    rgb = fromOklab(vec3(ln.x, hue * cmax * a));
  }
  return clamp(rgb, 0.0, 1.0);
}
// ---- Unreal's tonemapper (u_ue): UE 5.8 PostProcessTonemap.usf MainPS, its SDR path ----------------------------------------
// FinalLinearColor = SceneColor * SceneColorTint * (GlobalExposure * VignetteMask) + Bloom * (GlobalExposure * VignetteMask), then the
// colour grading LUT (combine_luts.frag) read by ColorLookupTable, then the triangular backbuffer quantization dither. No pre-exposure
// here (OneOverPreExposure is 1). Film grain and local exposure are not ported yet (their Unreal defaults are off).
uniform float u_ue;
uniform sampler2D u_lut;          // the unwrapped volume LUT, u_lut_size^2 x u_lut_size
uniform float u_lut_size;         // r.LUT.Size
uniform float u_lut_max;          // GetTonemappingMax: 1.05 for Filmic to sRGB
uniform vec3 u_scene_tint;        // SceneColorTint
uniform vec4 u_vignette_ue;       // VignetteIntensity, aspect (height / width), 0, 0
uniform vec2 u_grain_rand;        // GrainRandomFull: Halton (2, 3) of the frame
uniform float u_dither;           // BackbufferQuantizationDithering: 1 / 255 for an 8-bit target
vec3 ueLogToLin(vec3 l) { return exp2((l - 444.0 / 1023.0) * 14.0) * 0.18; }
vec3 ueLinToLog(vec3 c) { return log2(c) / 14.0 - log2(0.18) / 14.0 + 444.0 / 1023.0; }
// PostProcessCommon.ush UnwrappedTexture3DSample
vec3 ueUnwrapped3D(vec3 uvw, float size) {
  float inv = 1.0 / size;
  float intW = floor(uvw.z * size - 0.5);
  float fracW = uvw.z * size - 0.5 - intW;
  float u = (uvw.x + intW) * inv;
  vec3 a = texture(u_lut, vec2(u, uvw.y)).rgb;
  vec3 b = texture(u_lut, vec2(u + inv, uvw.y)).rgb;
  return mix(a, b, fracW);
}
vec3 ueColorLookupTable(vec3 lin) {
  vec3 enc = ueLinToLog(lin + ueLogToLin(vec3(0.0)));
  float n = u_lut_size;
  vec3 uvw = enc * ((n - 1.0) / n) + 0.5 / n;
  return ueUnwrapped3D(uvw, n) * u_lut_max;
}
// PostProcessCommon.ush VignetteSpace + ComputeVignetteMask, VIGNETTE_TYPE_COSINE_FOURTH_LAW, centre (0.5, 0.5)
float ueVignette(vec2 screenPos) {
  float intensity = u_vignette_ue.x;
  if (intensity <= 0.0) return 1.0;
  float ar = u_vignette_ue.y;
  vec2 p = screenPos * vec2(1.0, ar) * (sqrt(2.0) / sqrt(1.0 + ar * ar));
  p *= intensity;
  float t2 = dot(p, p);
  float c = 1.0 / (t2 + 1.0);
  return c * c;
}
// Local exposure, LOCAL_EXPOSURE_MODE_BILATERAL (ue_post.ludic ue_local_exposure_pass): PostProcessHistogramCommon.ush
// CalculateBaseLogLuminance (the grid read trilinear, BILATERAL_GRID_DEPTH 32, blended with the blurred log luminance) and
// CalculateLocalExposure. The grid is a buffer here (cell (x, y, bucket) at (bucket * tiles.y + y) * tiles.x + x), filtered by hand.
uniform float u_le_on;
readonly buffer u_le_grid { vec2 le_grid[]; };
uniform sampler2D u_le_blur;
uniform vec4 u_le_a;     // HighlightContrastScale, ShadowContrastScale, DetailStrength, BlurredLuminanceBlend
uniform vec4 u_le_b;     // MiddleGreyExposureCompensation, HighlightThreshold, ShadowThreshold, HighlightThresholdStrength
uniform vec4 u_le_c;     // ShadowThresholdStrength, BilateralGridUVScale xy, LuminanceMin
uniform vec4 u_le_d;     // grid tiles x y, HistogramScale, HistogramBias
vec2 ueLeCell(int x, int y, int z) {
  int tx = int(u_le_d.x), ty = int(u_le_d.y);
  x = clamp(x, 0, tx - 1);  y = clamp(y, 0, ty - 1);  z = clamp(z, 0, 31);
  return le_grid[(z * ty + y) * tx + x];
}
vec2 ueLeGrid(vec3 uvw) {
  vec3 p = uvw * vec3(u_le_d.xy, 32.0) - 0.5;
  vec3 f = fract(p);
  ivec3 i = ivec3(floor(p));
  vec2 a = mix(mix(ueLeCell(i.x, i.y, i.z), ueLeCell(i.x + 1, i.y, i.z), f.x), mix(ueLeCell(i.x, i.y + 1, i.z), ueLeCell(i.x + 1, i.y + 1, i.z), f.x), f.y);
  vec2 b = mix(mix(ueLeCell(i.x, i.y, i.z + 1), ueLeCell(i.x + 1, i.y, i.z + 1), f.x), mix(ueLeCell(i.x, i.y + 1, i.z + 1), ueLeCell(i.x + 1, i.y + 1, i.z + 1), f.x), f.y);
  return mix(a, b, f.z);
}
float ueLocalExposure(vec3 sceneColor, float globalExposure, float mgec) {
  float logLum = log2(max(dot(sceneColor, vec3(0.2126390059, 0.7151686788, 0.0721923154)), u_le_c.w));
  float logMiddleGrey = log2(0.18 * mgec * u_le_b.x);
  // CalculateBaseLogLuminance
  vec3 uvw;
  uvw.xy = v_uv * u_le_c.yz;
  uvw.z = ((logLum * u_le_d.z + u_le_d.w) * 31.0 + 0.5) / 32.0;
  vec2 g = ueLeGrid(uvw);
  float blurred = texture(u_le_blur, v_uv).r;
  float bilateral = g.y < 0.001 ? blurred : g.x / g.y;
  float baseLogLum = mix(bilateral, blurred, u_le_a.w) + log2(globalExposure);
  // CalculateLogLocalExposure, with the scene's log luminance under the exposure
  float lum = logLum + log2(globalExposure);
  float detail = lum - baseLogLum;
  float centered = baseLogLum - logMiddleGrey;
  float contrast = centered > 0.0 ? u_le_a.x : u_le_a.y;
  float m, t;
  if (centered > 0.0) {
    m = max(0.0, centered - u_le_b.y);
    t = smoothstep(u_le_b.y, u_le_b.y + 1.0 / (1.0 - u_le_b.w), abs(centered));
  } else {
    m = min(0.0, centered + u_le_b.z);
    t = smoothstep(u_le_b.z, u_le_b.z + 1.0 / (1.0 - u_le_c.x), abs(centered));
  }
  float offset = (centered - m) * (1.0 - t);
  centered -= offset;
  float logLocal = logMiddleGrey + offset + centered * contrast + detail * u_le_a.z;
  return exp2(logLocal - lum);
}
vec3 ueTonemap(vec3 sceneColor, vec3 bloom, float globalExposure) {
  vec2 screenPos = v_uv * 2.0 - 1.0;
  float vig = ueVignette(screenPos);
  float localExposure = 1.0;
  if (u_le_on > 0.5) localExposure = ueLocalExposure(sceneColor, globalExposure, texture(u_adapt, vec2(0.5)).a);
  vec3 lin = sceneColor * u_scene_tint * (globalExposure * vig * localExposure);
  lin += bloom * u_bloom_strength * (globalExposure * vig);
  vec3 dev = ueColorLookupTable(max(lin, vec3(0.0)));
  // GrainFromUV on TexCoord + GrainRandomFull, then triangular on [-1, 1]
  vec2 guv = v_uv + u_grain_rand;
  float g = fract(sin(guv.x + guv.y * 543.31) * 493013.0);
  float np = g * 2.0 - 1.0;
  float sgn = clamp(np * 1.0e30, -1.0, 1.0);
  float tri = sgn - sgn * sqrt(clamp(1.0 - abs(np), 0.0, 1.0));
  return dev + tri * u_dither;
}

#ifdef HDR10
// HDR10 output: nits in BT.2020 primaries, encoded with the SMPTE ST 2084 (PQ) curve. The three
// numbers are the player's calibration of their display (r3d_hdr_calibrate).
uniform float u_hdr_paper;        // nits the SDR picture's white sits at
uniform float u_hdr_peak;         // nits the brightest highlight rolls on to: what the display reaches
uniform float u_hdr_black;        // nits the darkest shade is lifted to, fading out toward paper white
vec3 bt709_to_2020(vec3 c) {
  return mat3(0.6274, 0.0691, 0.0164, 0.3293, 0.9195, 0.0880, 0.0433, 0.0114, 0.8956) * c;
}
vec3 pq_encode(vec3 nits) {
  const float m1 = 0.1593017578125, m2 = 78.84375, c1 = 0.8359375, c2 = 18.8515625, c3 = 18.6875;
  vec3 yp = pow(clamp(nits / 10000.0, 0.0, 1.0), vec3(m1));
  return pow((c1 + c2 * yp) / (1.0 + c3 * yp), vec3(m2));
}
#endif
void main() {
  vec3 hdr = sane(texture(u_hdr, v_uv).rgb);
  vec4 gi = texture(u_ao, v_uv);
  // the screen-space occlusion and bounce are the opaque scene's (its depth): none over the hair laid on it, as Unreal's hair pixels
  // take none of the scene's (their coverage, TransmittanceToCoverage at 0.98)
  float hairCov = u_hair_on > 0.5 ? clamp((1.0 - texture(u_hair_t, v_uv).r) / 0.98, 0.0, 1.0) : 0.0;
  gi = mix(gi, vec4(0.0, 0.0, 0.0, 1.0), hairCov);
  if (u_ao_view > 0.5) { o_color = vec4(vec3(gi.a), 1.0); return; }
  hdr *= mix(1.0, gi.a, u_ao_strength);
  // the indirect bounce arrives in the surface's own hue (no albedo buffer in a forward renderer)
  float l = dot(hdr, vec3(0.2126, 0.7152, 0.0722));
  hdr += gi.rgb * (hdr / max(l, 1e-3)) * u_gi_strength;
  vec3 bloom = texture(u_bloom, v_uv).rgb;
  float exposure = mix(u_exposure, texture(u_adapt, vec2(0.5)).r, u_auto);
#ifndef HDR10
  if (u_ue > 0.5) { o_color = vec4(foldGrain(ueTonemap(hdr, bloom, exposure)), 1.0); return; }
#endif
  vec3 c = (hdr + bloom * u_bloom_strength) * exposure * u_wb;
  c = max(c, vec3(0.0));
  vec3 pre = contrastUp(c, u_contrast);   // what ACES is about to roll off, kept for HDR highlights
  c = toneHue(c, u_contrast);
  // lift / gain grade in display space - after the 2.2, as the day's numbers mean it: in linear a
  // lift of 0.025 is a floor of 48/255 in sRGB, which painted every shadow at noon blue-grey
  c = pow(max(c, vec3(0.0)), vec3(1.0 / 2.2));
  c = c * u_gain + u_lift * (1.0 - c);
  c = pow(max(c, vec3(0.0)), vec3(2.2));
  float lum = dot(c, vec3(0.2126, 0.7152, 0.0722));
  c = mix(vec3(lum), c, u_saturation);
  vec2 q = v_uv * 2.0 - 1.0;
  float vig = 1.0 - u_vignette * dot(q, q) * 0.5;
  c *= vig;
#ifdef HDR10
  // up to paper white the SDR picture as it is; past it, the whole graded colour is brightened by one
  // factor from its brightest channel. Extending each channel on its own boosted a bright yellow's red
  // far more than its green, and yellow read as red on an HDR display.
  float paper = max(u_hdr_paper, 80.0);
  float peak = max(u_hdr_peak, paper);
  float over = max(max(pre.r, max(pre.g, pre.b)) - 1.0, 0.0);
  float lift = 1.0 + over / (over + 1.0) * (peak / paper - 1.0);
  vec3 nits = c * lift * paper;
  // the black level: the shadows' floor raised for a display that crushes them, gone by paper white
  nits += max(u_hdr_black, 0.0) * (1.0 - clamp(nits / paper, 0.0, 1.0));
  vec3 e = pq_encode(bt709_to_2020(nits));
  e += (hash(gl_FragCoord.xy) - 0.5) / 1023.0;
  o_color = vec4(e, 1.0);
#else
  c = pow(c, vec3(1.0 / 2.2));
  c += (hash(gl_FragCoord.xy) - 0.5) / 255.0;
  o_color = vec4(foldGrain(c), 1.0);
#endif
}
