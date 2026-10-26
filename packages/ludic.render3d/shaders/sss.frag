// Skin's subsurface scattering in screen space: Epic's Burley normalized SSS (Unreal's SubsurfaceBurleyNormalized.ush, BurleyNormalizedSS,
// and BurleyNormalizedSSSCommon.ush), the skin's diffuse light (model.frag SSS_SPLIT) blurred by the Christensen-Burley diffusion profile
// with importance-sampled radii, bilateral on depth, the center sample reweighted; then Unreal's recombine (SubsurfaceRecombinePS): the
// scattered light times the base colour in place of the sharp one. Drawn added over the scene (actor.ludic actor_draw_sss), so what it
// writes is the difference: the base colour x (scattered - own light).
//
// The profile is Unreal's: SurfaceAlbedo, the diffuse mean free path (mm, its largest channel in w) and the world unit scale, as the
// MetaHuman skin's SSP_skin_unified sets them (actor.ludic). What is not Unreal's: one pass at full resolution and a fixed sample count
// (Unreal adapts it per pixel and keeps a variance history), no mips of the light for the far samples, and no normal weight (Unreal's
// depth-only kernel, BILATERAL_FILTER_KERNEL_FUNCTION_DEPTH): the temporal resolve averages the noise as Unreal's does.
in vec2 v_uv;
out vec4 o_color;
uniform sampler2D u_sss_light;   // rgb the skin's diffuse light (no base colour), a its view depth (m); 0 off the skin
uniform sampler2D u_sss_alb;     // rgb the base colour (as the fog leaves it), a the material's subsurface opacity (scales the path)
uniform vec4 u_sss_dmfp;         // the diffuse mean free path per channel (mm), w the largest (GetDiffuseMeanFreePathForSampling)
uniform vec4 u_sss_albedo;       // the profile's surface albedo, w the channel of the largest path (GetComponentForScalingFactorEstimation)
uniform vec2 u_sss_scale;        // uv per metre at one metre: the projection's x and y scale / 2 (CalculateBurleyScale, SSSScaleX)
uniform float u_sss_wus;         // the profile's world unit scale (cm per its unit) x 10: 1 for the skin
uniform vec2 u_sss_px;           // 1 / the target's size
uniform int u_sss_n;             // samples per pixel
uniform int u_sss_frame;         // the frame, for the sequence's start (SeedStart = View.FrameNumber)

const float BURLEY_CM_2_MM = 10.0;
const float CLAMP_PDF = 0.00001;

// LIGHT_PERPENDICULAR_DIFFUSE_SURFACE (SubsurfaceProfileCommon.ush): the search light scaling factor
float scalingFactor(float a) { float v = a - 0.33; return 3.5 + 100.0 * v * v * v * v; }
vec3 scalingFactor3(vec3 a) { vec3 v = a - 0.33; return 3.5 + 100.0 * v * v * v * v; }
float cdf(float d, float x) { return 1.0 - 0.25 * exp(-x / d) - 0.75 * exp(-x / (3.0 * d)); }
float pdf(float r, float l, float s) { float d = l / s; return max(0.25 / d * (exp(-r / d) + exp(-r / (3.0 * d))), CLAMP_PDF); }
// rR(r): GetDiffuseReflectProfileWithDiffuseMeanFreePath
vec3 profile(vec3 l, vec3 s3, float r) {
  vec3 d = 1.0 / s3;
  vec3 nr = -(r / l) / d;
  return max((exp(nr) + exp(nr / 3.0)) / (d * l) * (1.0 / (8.0 * PI)), vec3(1e-12));
}
// Brian's approximation (ROOT_APROXIMATE): the radius whose cdf is u
float radiusFor(float d, float u) { return d * ((2.0 - 2.6) * u - 2.0) * log(1.0 - u); }
// Rand3DPCG16's first channel (Random.ush) and R2Sequence: the sequence's start per pixel and frame, then sequential
uint pcg16(ivec3 p) {
  uvec3 v = uvec3(p) * 1664525u + 1013904223u;
  v.x += v.y * v.z;  v.y += v.z * v.x;  v.z += v.x * v.y;
  v.x += v.y * v.z;  v.y += v.z * v.x;  v.z += v.x * v.y;
  return v.x >> 16u;
}
vec2 r2(uint i) {
  const float g = 1.32471795724474602596;
  return fract(0.5 + float(i) * vec2(1.0 / g, 1.0 / (g * g)));
}

void main() {
  vec4 c = texture(u_sss_light, v_uv);
  float depth = c.a;
  if (depth <= 0.0) discard;
  vec4 albc = texture(u_sss_alb, v_uv);
  if (albc.a <= 0.1) discard;
  // the opacity shortens the path (GetBurleyParameters: DiffuseMeanFreePath *= SurfaceOpacity)
  float op = albc.a;
  vec4 dm = u_sss_dmfp * op;
  float dmfp = dm.w;
  float s = scalingFactor(u_sss_albedo.w);
  vec3 s3 = scalingFactor3(u_sss_albedo.xyz);
  // uv per mm at this depth (CalculateBurleyScale: the world unit scale, the projection, the depth; Unreal's in cm, ours in metres)
  vec2 bs = u_sss_wus * u_sss_scale / (depth * 1000.0);
  // the center sample: the radius one pixel spans, the cdf inside it, its share per channel (CalculateCenterSample*)
  float cr = 0.5 * (u_sss_px.x / bs.x + u_sss_px.y / bs.y);
  float ccdf = cdf(dmfp / s, cr);
  vec3 dd = dm.xyz / s3;
  vec3 cw = vec3(cdf(dd.x, cr), cdf(dd.y, cr), cdf(dd.z, cr));
  uint seed = pcg16(ivec3(gl_FragCoord.xy, u_sss_frame));
  vec3 acc = vec3(0.0), wsum = vec3(0.0);
  for (int i = 0; i < u_sss_n; ++i) {
    vec2 u = r2(seed + uint(i));
    u.x = ccdf + u.x * (1.0 - ccdf);
    float r = max(radiusFor(dmfp / s, u.x), 0.00001);
    float th = u.y * 2.0 * PI;
    float p = pdf(r, dmfp, s);
    vec2 off = bs * r * vec2(cos(th), sin(th));
    vec4 sm = textureLod(u_sss_light, v_uv + off, 0.0);
    float mask = sm.a > 0.0 ? 1.0 : 0.0;
    // the bilateral distance: the depth step brought into the profile's units (mm over the world unit scale)
    float dz = (sm.a - depth) * 100.0 * BURLEY_CM_2_MM / u_sss_wus;
    float rs = sqrt(r * r + dz * dz);
    vec3 w = profile(dm.xyz, s3, rs) / p * mask;
    acc += w * sm.rgb;
    wsum += w;
  }
  // (no sample on the skin at all, a lone pixel of it: its own light, where Unreal's goes black)
  vec3 scat = mix(c.rgb, acc / max(wsum, vec3(1e-20)) / 0.99995, step(vec3(1e-20), wsum));
  // BoundaryColorBleedAccum * InvNumOfSamples: the skin's own bleed is 1 (SSP_skin_unified), so every sample counts 1
  scat = mix(scat, c.rgb, cw);
  // a low opacity fades to no scattering at all (SSSS_OPACITY_THRESHOLD_EPS 0.1)
  scat = mix(c.rgb, scat, clamp((op - 0.1) / 0.1, 0.0, 1.0));
  o_color = vec4(albc.rgb * (scat - c.rgb), 0.0);
}
