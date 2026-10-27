// Unreal's exposure histogram, ported from UE 5.8 PostProcessHistogram.usf with PostProcessHistogramCommon.ush: every texel of the
// half-resolution scene (u_lod 1) gives its luminance (CalculateEyeAdaptationLuminance) to the two of HISTOGRAM_SIZE (64) buckets that
// straddle its log2 position, split bilinearly; bucket 0 counts BlackHistogramBucketInfluence (0) of it; the meter mask is Unreal's
// default (white, weight 1). Unreal bins in compute shared memory and reduces the groups; here a fragment owns 4 buckets (the
// texture histogram's layout, HISTOGRAM_TEXEL_SIZE 16 texels a row) for one band of u_rows rows, and ue_eye_adapt.frag sums the bands.
in vec2 v_uv;
out vec4 o_color;
uniform sampler2D u_scene;
uniform float u_lod;              // the mip read: 1 half resolution (Unreal's default), 2 quarter
uniform vec2 u_size;              // that mip's size in texels
uniform float u_rows;             // rows a band
uniform vec2 u_scale_bias;        // HistogramScale, HistogramBias: position = log2(L) * scale + bias
uniform float u_lum_min;          // LuminanceMin: 2^HistogramLogMin
uniform float u_black;            // BlackHistogramBucketInfluence (r.EyeAdaptation.BlackHistogramBucketInfluence, 0)
const float HISTOGRAM_SIZE = 64.0;
const vec3 LUMA = vec3(0.2126390059, 0.7151686788, 0.0721923154);   // the sRGB working colour space's luminance factors
void main() {
  ivec2 px = ivec2(gl_FragCoord.xy);
  float b0 = float(px.x) * 4.0;              // the first of this texel's four buckets
  int y0 = px.y * int(u_rows);
  int w = int(u_size.x), h = int(u_size.y);
  vec4 acc = vec4(0.0);
  for (int dy = 0; dy < 64; dy++) {
    if (dy >= int(u_rows)) break;
    int y = y0 + dy;
    if (y >= h) break;
    for (int x = 0; x < 4096; x++) {
      if (x >= w) break;
      vec3 c = texelFetch(u_scene, ivec2(x, y), int(u_lod)).rgb;
      float l = max(dot(c, LUMA), u_lum_min);
      float f = clamp(log2(l) * u_scale_bias.x + u_scale_bias.y, 0.0, 1.0) * (HISTOGRAM_SIZE - 1.0);
      float k0 = floor(f);
      float k1 = min(k0 + 1.0, HISTOGRAM_SIZE - 1.0);
      float w1 = fract(f);
      float w0 = 1.0 - w1;
      if (k0 == 0.0) w0 *= u_black;
      vec4 i0 = vec4(equal(vec4(k0) - b0, vec4(0.0, 1.0, 2.0, 3.0)));
      vec4 i1 = vec4(equal(vec4(k1) - b0, vec4(0.0, 1.0, 2.0, 3.0)));
      acc += i0 * w0 + i1 * w1;
    }
  }
  o_color = acc;
}
