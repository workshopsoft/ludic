// auto-exposure on the GPU: the scene metered from its mip chain, eased toward from the previous
// frame's value, written to a 1x1 texture the tonemapper reads. Nothing comes back to the CPU (a
// readback there waited for the whole frame's GPU work and serialised the two: 34 ms -> the sum of
// both, measured 2026-09-09).
//
// The meter is a histogram over a grid of the frame, as Unreal's eye adaptation and Frostbite's
// camera meter it (Lagarde & de Rousiers, "Moving Frostbite to PBR", SIGGRAPH 2014): the cells are
// sorted into log-luminance bins, each weighted toward the centre of the screen (u_meter.z), the
// darkest u_meter.x and the brightest 1 - u_meter.y of the weight are dropped, and the rest is
// averaged - as light, not as log: the look was tuned on a mean that a bright sky holds down, and a
// log mean raised a dusk frame a stop. (0, 1, 0) is the mean of the whole frame, the old meter.
//
// A frame is not the light, though: under a tree every cell is shade, and metering it as if it were
// open ground made the shade read as noon. So by day the result is held within u_range stops (below,
// above) of the exposure open ground would get - the light a level face takes from the sky and the
// sun, of which u_open_share is such a frame's band mean - as an eye adapted to the day holds it.
// u_daylight fades the hold out toward night, where a fire is the scene and not the sky.
// (u_irradiance, u_ibl_scale, u_sun_*, u_daylight and PI come with lighting.glsl.)
in vec2 v_uv;
out vec4 o_color;
uniform sampler2D u_scene;
uniform sampler2D u_prev;
uniform float u_lod;              // the mip whose texels are the grid's cells
uniform vec2 u_grid;              // cells across and down (at most 64 x 36)
uniform vec3 u_meter;             // low cut, high cut (shares of the weight), centre weight
uniform vec2 u_range;             // stops below and above the open ground's exposure the day allows
uniform float u_open_share;       // a frame of open ground's band mean, as a share of its light
uniform float u_key;
uniform float u_max;
uniform vec2 u_rate;              // the share of the way covered this frame: scene brighter (exposure falls), darker (rises)
uniform float u_reset;
const int METER_BINS = 48;
const float METER_LMIN = -16.0;   // the log2 luminances the bins span
const float METER_LMAX = 8.0;
float meterLuma(vec3 c) { return dot(clamp(c, vec3(0.0), vec3(1.0e5)), vec3(0.2126, 0.7152, 0.0722)); }
float metered() {
  float wsum[METER_BINS];
  float lsum[METER_BINS];
  for (int i = 0; i < METER_BINS; i++) { wsum[i] = 0.0;  lsum[i] = 0.0; }
  int gw = int(u_grid.x);
  int gh = int(u_grid.y);
  float total = 0.0;
  for (int y = 0; y < 36; y++) {
    if (y >= gh) break;
    for (int x = 0; x < 64; x++) {
      if (x >= gw) break;
      vec2 uv = (vec2(float(x), float(y)) + 0.5) / u_grid;
      float l = meterLuma(textureLod(u_scene, uv, u_lod).rgb);
      vec2 q = uv * 2.0 - 1.0;
      float w = exp(-u_meter.z * dot(q, q));
      float f = (log2(max(l, 1.0e-6)) - METER_LMIN) / (METER_LMAX - METER_LMIN);
      int b = int(clamp(f * float(METER_BINS), 0.0, float(METER_BINS) - 0.5));
      wsum[b] += w;
      lsum[b] += w * l;
      total += w;
    }
  }
  // the band [lo, hi] of the cumulative weight; a bin the band cuts counts for the part inside it
  float lo = u_meter.x * total;
  float hi = u_meter.y * total;
  float run = 0.0;
  float bw = 0.0;
  float bl = 0.0;
  for (int i = 0; i < METER_BINS; i++) {
    float a = max(min(run + wsum[i], hi) - max(run, lo), 0.0);
    if (wsum[i] > 0.0) { bw += a;  bl += a * lsum[i] / wsum[i]; }
    run += wsum[i];
  }
  return bl / max(bw, 1.0e-6);
}
void main() {
  float target = clamp(u_key / max(metered(), 0.001), 0.02, u_max);
  // the open ground's light: the sky's on a level face (the convolved map's zenith row) and the sun's
  vec3 sky = textureLod(u_irradiance, vec2(0.5, 0.25 / 64.0), 0.0).rgb * u_ibl_scale;
  float open = meterLuma(sky + u_sun_color * max(u_sun_dir.y, 0.0) / PI) * u_open_share;
  float eo = u_key / max(open, 1.0e-4);
  float held = clamp(target, eo * exp2(-u_range.x), eo * exp2(u_range.y));
  target = clamp(mix(target, held, clamp(u_daylight, 0.0, 1.0)), 0.02, u_max);
  float prev = texture(u_prev, vec2(0.5)).r;
  float e = mix(prev, target, target < prev ? u_rate.x : u_rate.y);
  if (u_reset > 0.5 || !(prev > 0.0)) e = target;
  o_color = vec4(e, 0.0, 0.0, 1.0);
}
