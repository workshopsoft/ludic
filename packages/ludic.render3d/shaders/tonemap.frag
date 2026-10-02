// exposure -> ACES -> vignette -> sRGB, with dithering
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
  // filmic contrast around mid grey in log space
  c = max(c, vec3(0.0));
  c = pow(c / 0.18, vec3(u_contrast)) * 0.18;
  vec3 pre = c;                    // what ACES is about to roll off, kept for HDR highlights
  c = aces(c);
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
