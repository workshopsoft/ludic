// Unreal's colour grading LUT, ported from UE 5.8 PostProcessCombineLUTs.usf (CombineLUTsCommon) with TonemapCommon.ush
// (FilmToneMap, WhiteBalance), ACES/ACESCommon.ush (matrices, ChromaticAdaptation) and GammaCorrectionCommon.ush (LogToLin,
// LinearToSrgb). Unreal's own path for: working colour space sRGB, TonemappingMethod Filmic, output device sRGB, output gamut
// sRGB D65, r.LUT.Shaper 0 (log2), no legacy LDR LUTs (BLENDCOUNT 1), MappingPolynomial (0, 1, 0).
//
// The volume LUT is drawn unwrapped, u_size slices side by side (u_size^2 x u_size), as Unreal's 2D LUT path does; tonemap.frag
// reads it back with UnwrappedTexture3DSample. Matrices are written row by row as Unreal writes them, so mul(M, v) is v * M here.
in vec2 v_uv;
out vec4 o_color;
uniform float u_size;              // r.LUT.Size (32)
uniform float u_white_temp;        // WhiteTemp (6500)
uniform float u_white_tint;        // WhiteTint (0)
uniform float u_temp_is_wb;        // TemperatureType: 1 TEMP_WhiteBalance, 0 TEMP_ColorTemperature
// ColorSaturation/Contrast/Gamma/Gain/Offset for Global, Shadows, Midtones, Highlights: [range * 5 + control]
uniform vec4 u_grade[20];
uniform vec3 u_cc_range;           // ColorCorrectionShadowsMax, ColorCorrectionHighlightsMin, ColorCorrectionHighlightsMax
uniform vec3 u_misc;               // BlueCorrection, ExpandGamut, ToneCurveAmount
uniform vec4 u_film;               // FilmSlope, FilmToe, FilmShoulder, FilmBlackClip
uniform float u_film_white_clip;   // FilmWhiteClip
uniform float u_lut_inv_max;       // 1 / GetTonemappingMax (1.05 for Filmic to sRGB)

const mat3 AP0_2_XYZ = mat3(0.9525523959, 0.0000000000, 0.0000936786, 0.3439664498, 0.7281660966, -0.0721325464, 0.0000000000, 0.0000000000, 1.0088251844);
const mat3 XYZ_2_AP0 = mat3(1.0498110175, 0.0000000000, -0.0000974845, -0.4959030231, 1.3733130458, 0.0982400361, 0.0000000000, 0.0000000000, 0.9912520182);
const mat3 AP1_2_XYZ = mat3(0.6624541811, 0.1340042065, 0.1561876870, 0.2722287168, 0.6740817658, 0.0536895174, -0.0055746495, 0.0040607335, 1.0103391003);
const mat3 XYZ_2_AP1 = mat3(1.6410233797, -0.3248032942, -0.2364246952, -0.6636628587, 1.6153315917, 0.0167563477, 0.0117218943, -0.0082844420, 0.9883948585);
const mat3 AP0_2_AP1 = mat3(1.4514393161, -0.2365107469, -0.2149285693, -0.0765537734, 1.1762296998, -0.0996759264, 0.0083161484, -0.0060324498, 0.9977163014);
const mat3 AP1_2_AP0 = mat3(0.6954522414, 0.1406786965, 0.1638690622, 0.0447945634, 0.8596711185, 0.0955343182, -0.0055258826, 0.0040252103, 1.0015006723);
const mat3 XYZ_2_sRGB = mat3(3.2409699419, -1.5373831776, -0.4986107603, -0.9692436363, 1.8759675015, 0.0415550574, 0.0556300797, -0.2039769589, 1.0569715142);
const mat3 sRGB_2_XYZ = mat3(0.4123907993, 0.3575843394, 0.1804807884, 0.2126390059, 0.7151686788, 0.0721923154, 0.0193308187, 0.1191947798, 0.9505321522);
const mat3 D65_2_D60 = mat3(1.0130349146, 0.0061052578, -0.0149709436, 0.0076982301, 0.9981633521, -0.0050320385, -0.0028413174, 0.0046851567, 0.9245061375);
const mat3 D60_2_D65 = mat3(0.9872240087, -0.0061132286, 0.0159532883, -0.0075983718, 1.0018614847, 0.0053300358, 0.0030725771, -0.0050959615, 1.0816806031);
const vec3 AP1_RGB2Y = vec3(0.2722287168, 0.6740817658, 0.0536895174);
const float PI_ = 3.14159265358979;

vec3 mulR(mat3 m, vec3 v) { return v * m; }
// the working colour space (sRGB) to and from AP1: XYZ_2_AP1 D65_2_D60 sRGB_2_XYZ, and back
vec3 toAP1(vec3 c) { return mulR(XYZ_2_AP1, mulR(D65_2_D60, mulR(sRGB_2_XYZ, c))); }
vec3 fromAP1(vec3 c) { return mulR(XYZ_2_sRGB, mulR(D60_2_D65, mulR(AP1_2_XYZ, c))); }

// GammaCorrectionCommon.ush
vec3 logToLin(vec3 l) { return exp2((l - 444.0 / 1023.0) * 14.0) * 0.18; }
vec3 linearToSrgb(vec3 lin) { return min(lin * 12.92, pow(max(lin, vec3(0.00313067)), vec3(1.0 / 2.4)) * 1.055 - 0.055); }

// ACESCommon.ush
float rgb_2_saturation(vec3 rgb) {
  float minrgb = min(min(rgb.r, rgb.g), rgb.b);
  float maxrgb = max(max(rgb.r, rgb.g), rgb.b);
  return (max(maxrgb, 1e-10) - max(minrgb, 1e-10)) / max(maxrgb, 1e-2);
}
float rgb_2_hue(vec3 rgb) {
  float hue;
  if (rgb.r == rgb.g && rgb.g == rgb.b) { hue = 0.0; }
  else { hue = (180.0 / PI_) * atan(sqrt(3.0) * (rgb.g - rgb.b), 2.0 * rgb.r - rgb.g - rgb.b); }
  if (hue < 0.0) hue = hue + 360.0;
  return clamp(hue, 0.0, 360.0);
}
float center_hue(float hue, float centerH) {
  float h = hue - centerH;
  if (h < -180.0) h += 360.0; else if (h > 180.0) h -= 360.0;
  return h;
}
float rgb_2_yc(vec3 rgb) {
  float chroma = sqrt(max(rgb.b * (rgb.b - rgb.g) + rgb.g * (rgb.g - rgb.r) + rgb.r * (rgb.r - rgb.b), 0.0));
  return (rgb.b + rgb.g + rgb.r + 1.75 * chroma) / 3.0;
}
float sigmoid_shaper(float x) {
  float t = max(1.0 - abs(0.5 * x), 0.0);
  float y = 1.0 + sign(x) * (1.0 - t * t);
  return 0.5 * y;
}
float glow_fwd(float ycIn, float glowGainIn, float glowMid) {
  if (ycIn <= 2.0 / 3.0 * glowMid) return glowGainIn;
  if (ycIn >= 2.0 * glowMid) return 0.0;
  return glowGainIn * (glowMid / ycIn - 0.5);
}
vec3 xyY_2_XYZ(vec3 xyY) {
  return vec3(xyY.x * xyY.z / max(xyY.y, 1e-10), xyY.z, (1.0 - xyY.x - xyY.y) * xyY.z / max(xyY.y, 1e-10));
}
// Bradford von Kries, as a row-major matrix: InvConeResponse * VonKries * ConeResponse
mat3 chromaticAdaptation(vec2 src_xy, vec2 dst_xy) {
  const mat3 Cone = mat3(0.8951, 0.2664, -0.1614, -0.7502, 1.7135, 0.0367, 0.0389, -0.0685, 1.0296);
  const mat3 InvCone = mat3(0.9869929, -0.1470543, 0.1599627, 0.4323053, 0.5183603, 0.0492912, -0.0085287, 0.0400428, 0.9684867);
  vec3 s = mulR(Cone, xyY_2_XYZ(vec3(src_xy, 1.0)));
  vec3 d = mulR(Cone, xyY_2_XYZ(vec3(dst_xy, 1.0)));
  // in the transposed storage, a row-major product A * B is stored as B' * A'
  mat3 vk = mat3(d.x / s.x, 0.0, 0.0, 0.0, d.y / s.y, 0.0, 0.0, 0.0, d.z / s.z);
  return Cone * vk * InvCone;
}

// TonemapCommon.ush
vec2 planckianLocusChromaticity(float T) {
  float u = (0.860117757 + 1.54118254e-4 * T + 1.28641212e-7 * T * T) / (1.0 + 8.42420235e-4 * T + 7.08145163e-7 * T * T);
  float v = (0.317398726 + 4.22806245e-5 * T + 4.20481691e-8 * T * T) / (1.0 - 2.89741816e-5 * T + 1.61456053e-7 * T * T);
  return vec2(3.0 * u, 2.0 * v) / (2.0 * u - 8.0 * v + 4.0);
}
vec2 dIlluminantChromaticity(float T) {
  T *= 1.4388 / 1.438;
  float o = 1.0 / T;
  float x = T <= 7000.0 ? 0.244063 + (0.09911e3 + (2.9678e6 - 4.6070e9 * o) * o) * o
                        : 0.237040 + (0.24748e3 + (1.9018e6 - 2.0064e9 * o) * o) * o;
  return vec2(x, -3.0 * x * x + 2.87 * x - 0.275);
}
vec2 planckianIsothermal(float T, float tint) {
  float u = (0.860117757 + 1.54118254e-4 * T + 1.28641212e-7 * T * T) / (1.0 + 8.42420235e-4 * T + 7.08145163e-7 * T * T);
  float v = (0.317398726 + 4.22806245e-5 * T + 4.20481691e-8 * T * T) / (1.0 - 2.89741816e-5 * T + 1.61456053e-7 * T * T);
  float a = 1.41213984e6 + 1189.62 * T + T * T;
  float b = 6.19363586e6 - 179.456 * T + T * T;
  float ud = (-1.13758118e9 - 1.91615621e6 * T - 1.53177 * T * T) / (a * a);
  float vd = (1.97471536e9 - 705674.0 * T - 308.607 * T * T) / (b * b);
  vec2 uvd = normalize(vec2(ud, vd));
  u += uvd.y * tint * 0.05;
  v += -uvd.x * tint * 0.05;
  return vec2(3.0 * u, 2.0 * v) / (2.0 * u - 8.0 * v + 4.0);
}
vec3 whiteBalance(vec3 lin, float T, float tint, bool isWB) {
  vec2 srcPlanck = planckianLocusChromaticity(T);
  vec2 src = T < 4000.0 ? srcPlanck : dIlluminantChromaticity(T);
  vec2 d65 = vec2(0.31270, 0.32900);
  src += planckianIsothermal(T, tint) - srcPlanck;
  if (!isWB) { vec2 t = src; src = d65; d65 = t; }
  mat3 m = chromaticAdaptation(src, d65);
  // XYZ_2_WCS * m * WCS_2_XYZ, the working colour space being sRGB
  return mulR(XYZ_2_sRGB, mulR(m, mulR(sRGB_2_XYZ, lin)));
}

vec3 filmToneMap(vec3 colorAP1) {
  float slope = u_film.x, toe = u_film.y, shoulder = u_film.z, blackClip = u_film.w, whiteClip = u_film_white_clip;
  vec3 ap0 = mulR(AP1_2_AP0, colorAP1);
  // "Glow" module
  float saturation = rgb_2_saturation(ap0);
  float ycIn = rgb_2_yc(ap0);
  float s = sigmoid_shaper((saturation - 0.4) / 0.2);
  ap0 *= 1.0 + glow_fwd(ycIn, 0.05 * s, 0.08);
  // Red modifier
  float hue = rgb_2_hue(ap0);
  float centeredHue = center_hue(hue, 0.0);
  float hw = smoothstep(0.0, 1.0, 1.0 - abs(2.0 * centeredHue / 135.0));
  hw *= hw;
  ap0.r += hw * saturation * (0.03 - ap0.r) * (1.0 - 0.82);
  vec3 wc = max(mulR(AP0_2_AP1, ap0), vec3(0.0));
  wc = mix(vec3(dot(wc, AP1_RGB2Y)), wc, 0.96);                       // pre desaturate
  float toeScale = 1.0 + blackClip - toe;
  float shoulderScale = 1.0 + whiteClip - shoulder;
  const float InMatch = 0.18;
  const float OutMatch = 0.18;
  float toeMatch;
  if (toe > 0.8) {
    toeMatch = (1.0 - toe - OutMatch) / slope + log(InMatch) / log(10.0);
  } else {
    float bt = (OutMatch + blackClip) / toeScale - 1.0;
    toeMatch = log(InMatch) / log(10.0) - 0.5 * log((1.0 + bt) / (1.0 - bt)) * (toeScale / slope);
  }
  float straightMatch = (1.0 - toe) / slope - toeMatch;
  float shoulderMatch = shoulder / slope - straightMatch;
  vec3 logColor = log(wc) / log(10.0);
  vec3 straightColor = slope * (logColor + straightMatch);
  vec3 toeColor = (-blackClip) + (2.0 * toeScale) / (1.0 + exp((-2.0 * slope / toeScale) * (logColor - toeMatch)));
  vec3 shoulderColor = (1.0 + whiteClip) - (2.0 * shoulderScale) / (1.0 + exp((2.0 * slope / shoulderScale) * (logColor - shoulderMatch)));
  toeColor = mix(straightColor, toeColor, vec3(lessThan(logColor, vec3(toeMatch))));
  shoulderColor = mix(straightColor, shoulderColor, vec3(greaterThan(logColor, vec3(shoulderMatch))));
  vec3 t = clamp((logColor - toeMatch) / (shoulderMatch - toeMatch), 0.0, 1.0);
  if (shoulderMatch < toeMatch) t = 1.0 - t;
  t = (3.0 - 2.0 * t) * t * t;
  vec3 tone = mix(toeColor, shoulderColor, t);
  tone = mix(vec3(dot(tone, AP1_RGB2Y)), tone, 0.93);                // post desaturate
  return max(tone, vec3(0.0));
}

// PostProcessCombineLUTs.usf
vec3 colorCorrect(vec3 wc, vec4 sat, vec4 con, vec4 gam, vec4 gai, vec4 off) {
  float luma = dot(wc, AP1_RGB2Y);
  wc = max(vec3(0.0), mix(vec3(luma), wc, sat.xyz * sat.w));
  wc = pow(wc * (1.0 / 0.18), con.xyz * con.w) * 0.18;
  wc = pow(wc, 1.0 / (gam.xyz * gam.w));
  return wc * (gai.xyz * gai.w) + (off.xyz + off.w);
}
vec3 rangeCC(vec3 wc, int r) {
  int b = r * 5;
  return colorCorrect(wc, u_grade[b] * u_grade[0], u_grade[b + 1] * u_grade[1], u_grade[b + 2] * u_grade[2],
                      u_grade[b + 3] * u_grade[3], u_grade[b + 4] + u_grade[4]);
}
vec3 colorCorrectAll(vec3 wc) {
  float luma = dot(wc, AP1_RGB2Y);
  vec3 sh = rangeCC(wc, 1);
  float wsh = 1.0 - smoothstep(0.0, u_cc_range.x, luma);
  vec3 hi = rangeCC(wc, 3);
  float whi = smoothstep(u_cc_range.y, u_cc_range.z, luma);
  vec3 mi = rangeCC(wc, 2);
  float wmi = 1.0 - wsh - whi;
  return sh * wsh + mi * wmi + hi * whi;
}
vec3 computeFilmColorNoGamma(vec3 colorAP1) {
  const mat3 BlueCorrect = mat3(0.9404372683, -0.0183068787, 0.0778696104, 0.0083786969, 0.8286599939, 0.1629613092, 0.0005471261, -0.0008833746, 1.0003362486);
  const mat3 BlueCorrectInv = mat3(1.06318, 0.0233956, -0.0865726, -0.0106337, 1.20632, -0.19569, -0.000590887, 0.00105248, 0.999538);
  float blue = u_misc.x;
  // BlueCorrectAP1 = AP0_2_AP1 * BlueCorrect * AP1_2_AP0
  vec3 bc = mulR(AP0_2_AP1, mulR(BlueCorrect, mulR(AP1_2_AP0, colorAP1)));
  colorAP1 = mix(colorAP1, bc, blue);
  colorAP1 = mix(colorAP1, filmToneMap(colorAP1), u_misc.z);
  vec3 bi = mulR(AP0_2_AP1, mulR(BlueCorrectInv, mulR(AP1_2_AP0, colorAP1)));
  colorAP1 = mix(colorAP1, bi, blue);
  vec3 film = max(vec3(0.0), fromAP1(colorAP1));
  // ColorCorrection (MappingPolynomial 0, 1, 0), ColorScale 1, OverlayColor alpha 0: identity
  return film;
}

void main() {
  float n = u_size;
  vec2 px = floor(gl_FragCoord.xy);
  // unwrapped: x = r + n * b, y = g
  vec3 idx = vec3(mod(px.x, n), px.y, floor(px.x / n));
  vec3 lutEncoded = idx / (n - 1.0);
  vec3 lin = logToLin(lutEncoded) - logToLin(vec3(0.0));
  vec3 balanced = lin;
  if (abs(u_white_temp - 6500.0) > 1e-8 || abs(u_white_tint) > 1e-8) balanced = whiteBalance(lin, u_white_temp, u_white_tint, u_temp_is_wb > 0.5);
  vec3 ap1 = toAP1(balanced);
  // ExpandGamut: bright saturated colours pushed between P3 and AP1
  float lumaAP1 = dot(ap1, AP1_RGB2Y);
  vec3 chroma = ap1 / max(lumaAP1, 1e-10);
  float cd2 = dot(chroma - 1.0, chroma - 1.0);
  float expandAmount = (1.0 - exp2(-4.0 * cd2)) * (1.0 - exp2(-4.0 * u_misc.y * lumaAP1 * lumaAP1));
  const mat3 Wide_2_XYZ = mat3(0.5441691, 0.2395926, 0.1666943, 0.2394656, 0.7021530, 0.0583814, -0.0023439, 0.0361834, 1.0552183);
  // ExpandMat = Wide_2_AP1 * AP1_2_sRGB, Wide_2_AP1 = XYZ_2_AP1 * Wide_2_XYZ, AP1_2_sRGB = XYZ_2_sRGB * D60_2_D65 * AP1_2_XYZ
  vec3 expand = mulR(XYZ_2_AP1, mulR(Wide_2_XYZ, mulR(XYZ_2_sRGB, mulR(D60_2_D65, mulR(AP1_2_XYZ, ap1)))));
  ap1 = mix(ap1, expand, expandAmount);
  ap1 = colorCorrectAll(ap1);
  // ApplyToneCurve, Filmic, sRGB gamut: InverseGamma.y = 2.2 / DisplayGamma = 1
  vec3 outGamut = computeFilmColorNoGamma(ap1);
  vec3 device = linearToSrgb(outGamut);
  o_color = vec4(device * u_lut_inv_max, 0.0);
}
