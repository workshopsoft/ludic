// exposure -> contrast -> ACES with the scene's hue -> grade -> vignette -> sRGB, with dithering
in vec2 v_uv;
out vec4 o_color;
uniform sampler2D u_hdr;
uniform sampler2D u_bloom;
uniform sampler2D u_ao;
uniform float u_ao_strength;
uniform float u_gi_strength;
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
// at the scene's own hue (Oklab), as rich as the curve made it - and, until it nears white, at least as
// rich as the scene was - with the saturation the full contrast curve gave, so opening a shadow does not
// grey it. Then the chroma comes down, at that lightness and hue, until it is a colour the screen has.
vec3 toneHue(vec3 c, float k) {
  vec3 cn = aces(contrastUp(c, k));
  vec3 co = aces(pow(c / 0.18, vec3(k)) * 0.18);
  vec3 ln = toOklab(cn);
  vec3 lo = toOklab(co);
  vec3 l0 = toOklab(c);
  float c0 = length(l0.yz);
  if (c0 < 1.0e-5 || ln.x < 1.0e-4) return cn;
  float s = max(length(lo.yz) / max(lo.x, 1.0e-4), length(ln.yz) / ln.x);
  float t = clamp((ln.x - 0.9) / 0.1, 0.0, 1.0);
  s = max(s, c0 / max(l0.x, 1.0e-4) * (1.0 - t * t * (3.0 - 2.0 * t)));
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
  hdr *= mix(1.0, gi.a, u_ao_strength);
  // the indirect bounce arrives in the surface's own hue (no albedo buffer in a forward renderer)
  float l = dot(hdr, vec3(0.2126, 0.7152, 0.0722));
  hdr += gi.rgb * (hdr / max(l, 1e-3)) * u_gi_strength;
  vec3 bloom = texture(u_bloom, v_uv).rgb;
  float exposure = mix(u_exposure, texture(u_adapt, vec2(0.5)).r, u_auto);
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
  o_color = vec4(c, 1.0);
#endif
}
