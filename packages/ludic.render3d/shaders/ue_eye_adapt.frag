// Unreal's eye adaptation, ported from UE 5.8 PostProcessEyeAdaptation.usf (EyeAdaptationCS, EyeAdaptationCommon) and
// PostProcessHistogramCommon.ush (ComputeHistogramSum, ComputeAverageLuminanceWithoutOutlier, ComputeEyeAdaptation, ExponentialAdaption,
// LinearAdaption). The histogram (ue_histogram.frag) is u_bands rows of 16 texels, 4 buckets each; they are summed here (Unreal's
// PostProcessHistogramReduce). Output, 1x1: x the exposure scale the tonemapper multiplies by (EyeAdaptation.x), y the target's scale,
// z the average scene luminance, w MiddleGreyExposureCompensation (the 1x1 R32F target keeps x). The previous frame's x is u_prev;
// with none yet (0 or NaN) the target is taken at once, as ForceTarget does.
in vec2 v_uv;
out vec4 o_color;
uniform sampler2D u_hist;
uniform sampler2D u_prev;
uniform float u_bands;
uniform vec2 u_percent;           // ExposureLowPercent, ExposureHighPercent (0..1)
uniform vec2 u_scale_bias;        // HistogramScale, HistogramBias
uniform vec2 u_avg_lum;           // MinAverageLuminance, MaxAverageLuminance (white point x 0.18)
uniform float u_compensation;     // ExposureCompensationSettings x ExposureCompensationCurve: 2^AutoExposureBias, no curve
uniform vec2 u_speed;             // ExposureSpeedUp, ExposureSpeedDown (stops a second)
uniform vec2 u_exp_m;             // ExponentialUpM, ExponentialDownM
uniform float u_start_distance;   // r.EyeAdaptation.ExponentialTransitionDistance (1.5)
uniform float u_dt;               // DeltaWorldTime
uniform float u_force;            // ForceTarget: 1 on a camera cut or the first frame
const int HISTOGRAM_SIZE = 64;
float bucket(int i) {
  int tx = i / 4;
  float s = 0.0;
  for (int b = 0; b < 512; b++) {
    if (b >= int(u_bands)) break;
    vec4 t = texelFetch(u_hist, ivec2(tx, b), 0);
    int c = i - tx * 4;
    s += c == 0 ? t.r : (c == 1 ? t.g : (c == 2 ? t.b : t.a));
  }
  return s;
}
float logLumFromPosition(float p) { return (p - u_scale_bias.y) / u_scale_bias.x; }
float exponentialAdaption(float cur, float tgt, float ft, float speed, float m) {
  float factor = 1.0 - exp2(-ft * speed);
  return cur + (tgt - cur) * factor * m;
}
float linearAdaption(float cur, float tgt, float ft, float speed) {
  float off = ft * speed;
  return cur < tgt ? min(tgt, cur + off) : max(tgt, cur - off);
}
float computeEyeAdaptation(float oldExposure, float targetExposure, float ft, float forceTarget) {
  float lt = log2(targetExposure);
  float lo = log2(oldExposure);
  float d = lt - lo;
  float speed = d > 0.0 ? u_speed.x : u_speed.y;
  float m = d > 0.0 ? u_exp_m.x : u_exp_m.y;
  float le = exponentialAdaption(lo, lt, ft, speed, m);
  float ll = linearAdaption(lo, lt, ft, speed);
  float la = abs(d) > u_start_distance ? ll : le;
  return mix(exp2(la), targetExposure, forceTarget);
}
void main() {
  float hist[HISTOGRAM_SIZE];
  float sum = 0.0;
  for (int i = 0; i < HISTOGRAM_SIZE; i++) { hist[i] = bucket(i); sum += hist[i]; }
  // ComputeAverageLuminanceWithoutOutlier
  float avgLum;
  if (abs(u_percent.x - u_percent.y) < 0.0001) {
    avgLum = 1.0;
  } else {
    float minSum = sum * u_percent.x;
    float maxSum = sum * u_percent.y;
    vec2 acc = vec2(0.0);
    for (int i = 0; i < HISTOGRAM_SIZE; i++) {
      float v = hist[i];
      float sub = min(v, minSum);
      v -= sub;  minSum -= sub;  maxSum -= sub;
      v = min(v, maxSum);
      maxSum -= v;
      float lb = logLumFromPosition(float(i) / float(HISTOGRAM_SIZE - 1));
      acc += vec2(lb, 1.0) * v;
    }
    avgLum = acc.y == 0.0 ? u_avg_lum.x / 0.18 : exp2(acc.x / acc.y);
  }
  // EyeAdaptationCommon
  float oldScale = texture(u_prev, vec2(0.5)).r;
  float targetAvg = clamp(avgLum, u_avg_lum.x, u_avg_lum.y);
  float targetExposure = targetAvg / 0.18;
  float mgec = u_compensation;
  float oldExposure = mgec / (oldScale != 0.0 && oldScale == oldScale ? oldScale : 1.0);
  float force = (oldScale > 0.0 && oldScale == oldScale) ? u_force : 1.0;
  float est = computeEyeAdaptation(oldExposure, targetExposure, u_dt, force);
  float smoothed = clamp(est, u_avg_lum.x / 0.18, u_avg_lum.y / 0.18);
  float smoothedScale = 1.0 / max(0.0001, smoothed);
  float targetScale = 1.0 / max(0.0001, targetExposure);
  o_color = vec4(mgec * smoothedScale, mgec * targetScale, avgLum, mgec);
}
