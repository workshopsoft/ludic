// Unreal's real-time sky light capture and convolution, ported from UE 5.8 ReflectionEnvironmentRealTimeCapture.cpp and
// ReflectionEnvironmentShaders.usf: the sky captured into a cube (the sky atmosphere without its sun disc, as Unreal's capture skips
// it to not double the specular; then the distant height fog, RenderRealTimeReflectionHeightFogPS, blended ONE / SRC_ALPHA; then the
// lower hemisphere black, ApplyLowerHemisphereColorPS with bLowerHemisphereIsBlack), its mips (DownsampleCS), the GGX convolution
// per mip (FilterCS) and the diffuse irradiance as third-order SH (ComputeSkyEnvMapDiffuseIrradianceCS).
//
// The cube lives in 2D arrays, 6 faces x mips layers at sl_size (128), mip m in the top-left (sl_size >> m)^2 of its layers
// (layer m * 6 + face); the capture's even mips in one array and its odd ones in another, so a mip is drawn from the one above; cube faces and directions are Unreal's (GetCubemapVector, z up), our frame maps to it as (x, z, y).
// One pass per define: SL_CAPTURE, SL_DOWNSAMPLE, SL_FILTER, SL_SH (7x1: OutIrradianceEnvMapSH[0..6]).
in vec2 v_uv;
out vec4 o_color;
uniform float sl_face;             // the face being drawn
uniform float sl_mip;              // the mip being drawn
uniform float sl_mips;             // NumMips (log2(u_size) + 1)
uniform float sl_size;             // the cube's mip 0 size
uniform sampler2DArray sl_src;     // the capture's even mips (a layer of one atlas cannot be read while another is drawn)
uniform sampler2DArray sl_src2;    // and its odd mips
const float SL_PI = 3.14159265358979;

vec3 slCubemapVector(vec2 s, int face) {
  if (face == 0) return vec3(1.0, -s.y, -s.x);
  if (face == 1) return vec3(-1.0, -s.y, s.x);
  if (face == 2) return vec3(s.x, 1.0, s.y);
  if (face == 3) return vec3(s.x, -1.0, -s.y);
  if (face == 4) return vec3(s.x, -s.y, 1.0);
  return vec3(-s.x, -s.y, -1.0);
}
// its inverse: the face and the face's [-1, 1] coordinates of a direction
int slFaceOf(vec3 d, out vec2 s) {
  vec3 a = abs(d);
  if (a.x >= a.y && a.x >= a.z) {
    if (d.x > 0.0) { s = vec2(-d.z, -d.y) / a.x;  return 0; }
    s = vec2(d.z, -d.y) / a.x;  return 1;
  }
  if (a.y >= a.z) {
    if (d.y > 0.0) { s = vec2(d.x, d.z) / a.y;  return 2; }
    s = vec2(d.x, -d.z) / a.y;  return 3;
  }
  if (d.z > 0.0) { s = vec2(d.x, -d.y) / a.z;  return 4; }
  s = vec2(-d.x, -d.y) / a.z;  return 5;
}
// SampleLevel at an integer mip, bilinear inside the face
vec4 slSampleMip(vec3 dir, float mip) {
  vec2 s;
  int face = slFaceOf(dir, s);
  float m = clamp(mip, 0.0, sl_mips - 1.0);
  float res = max(sl_size / exp2(m), 1.0);
  vec2 uv = (s * 0.5 + 0.5) * res;
  uv = clamp(uv, vec2(0.5), vec2(res - 0.5)) / sl_size;
  if (mod(m, 2.0) > 0.5) return texture(sl_src2, vec3(uv, m * 6.0 + float(face)));
  return texture(sl_src, vec3(uv, m * 6.0 + float(face)));
}
// SampleLevel with a trilinear sampler
vec4 slSample(vec3 dir, float mip) {
  float m = clamp(mip, 0.0, sl_mips - 1.0);
  float m0 = floor(m);
  float m1 = min(m0 + 1.0, sl_mips - 1.0);
  return mix(slSampleMip(dir, m0), slSampleMip(dir, m1), m - m0);
}
// the face's [-1, 1] coordinates of this fragment at the mip being drawn
vec2 slScaledUVs() {
  float res = max(sl_size / exp2(sl_mip), 1.0);
  return ((floor(gl_FragCoord.xy) + 0.5) / res) * 2.0 - 1.0;
}

#ifdef SL_CAPTURE
// the sky atmosphere (sky.frag uaSkyLuminance without the disc) and the height fog (ue_fog.frag ufHeightFog), uniforms as there
uniform sampler2D ua_skyview;
uniform vec4 ua_skyview_size;
uniform vec2 ua_radii_s;
uniform float ua_view_height;
uniform vec3 ua_ref0;
uniform vec3 ua_ref1;
uniform vec3 ua_ref2;
uniform vec3 ua_sky_factor;
uniform vec4 uf_fog0;
uniform vec4 uf_fog2;
uniform vec4 uf_fog3;
uniform vec4 uf_color;
uniform vec3 uf_ambient_scale;
uniform sampler2D uf_distant;
uniform vec4 uf_light_dir;
uniform vec4 uf_dir_color;
uniform float uf_end;
uniform float uf_sky_dist;
uniform vec3 sl_lower_color;       // LowerHemisphereColor
uniform float sl_lower_on;         // bLowerHemisphereIsBlack
float slNearest(vec3 ro, vec3 rd, float r) {
  float b = 2.0 * dot(rd, ro);
  float c = dot(ro, ro) - r * r;
  float disc = b * b - 4.0 * c;
  if (disc < 0.0) return -1.0;
  float sq = sqrt(disc);
  float t0 = (-b - sq) * 0.5, t1 = (-b + sq) * 0.5;
  if (t0 < 0.0 && t1 < 0.0) return -1.0;
  if (t0 < 0.0) return max(0.0, t1);
  if (t1 < 0.0) return max(0.0, t0);
  return max(0.0, min(t0, t1));
}
vec3 slSky(vec3 worldDir) {
  float vh = ua_view_height;
  vec3 dl = vec3(dot(ua_ref0, worldDir), dot(ua_ref1, worldDir), dot(ua_ref2, worldDir));
  bool ground = slNearest(vec3(0.0, 0.0, vh), dl, ua_radii_s.x) >= 0.0;
  float vHorizon = sqrt(max(vh * vh - ua_radii_s.x * ua_radii_s.x, 0.0));
  float beta = acos(vHorizon / vh);
  float zha = SL_PI - beta;
  float vza = acos(clamp(dl.z, -1.0, 1.0));
  vec2 uv;
  if (!ground) { float c = vza / zha;  c = 1.0 - c;  c = sqrt(max(c, 0.0));  c = 1.0 - c;  uv.y = c * 0.5; }
  else { float c = (vza - zha) / beta;  c = sqrt(max(c, 0.0));  uv.y = c * 0.5 + 0.5; }
  uv.x = (atan(-dl.y, -dl.x) + SL_PI) / (2.0 * SL_PI);
  uv = (uv + 0.5 * ua_skyview_size.zw) * (ua_skyview_size.xy / (ua_skyview_size.xy + 1.0));
  return textureLod(ua_skyview, uv, 0.0).rgb * ua_sky_factor;
}
float slLineIntegralShared(float falloff, float rayDirZ, float rayOriginTerms) {
  float f = max(-127.0, falloff * rayDirZ);
  float li = (1.0 - exp2(-f)) / f;
  float lt = log(2.0) - (0.5 * log(2.0) * log(2.0)) * f;
  return rayOriginTerms * (abs(f) > 0.01 ? li : lt);
}
// GetExponentialHeightFog with bOverrideOrigin at the sky light's position. Unreal's real-time sky light captures where the camera
// is here (ue_skylight.ludic), so the main view's collapsed fog parameters are reused; the ray is the far depth's (near infinite)
vec4 slHeightFog(vec3 dirOurs) {
  vec3 camToReceiver = dirOurs * uf_sky_dist;
  float len = length(camToReceiver);
  vec3 dirN = camToReceiver / len;
  float rayOriginTerms = uf_fog0.x;
  float rayOriginTerms2 = uf_fog2.x;
  float rayLength = len;
  float rayDirY = camToReceiver.y;
  float sharedLI = slLineIntegralShared(uf_fog0.y, rayDirY, rayOriginTerms) + slLineIntegralShared(uf_fog2.y, rayDirY, rayOriginTerms2);
  float lineIntegral = sharedLI * rayLength;
  vec3 inscattering = uf_color.rgb + uf_ambient_scale * texture(uf_distant, vec2(0.5)).rgb;
  vec3 directional = vec3(0.0);
  if (uf_light_dir.w >= 0.0) {
    vec3 dl = uf_dir_color.rgb * pow(clamp(dot(dirN, uf_light_dir.xyz), 0.0, 1.0), uf_dir_color.w) / (4.0 * SL_PI);
    float dirFactor = clamp(exp2(-sharedLI * max(rayLength - uf_light_dir.w, 0.0)), 0.0, 1.0);
    directional = dl * (1.0 - dirFactor);
  }
  float expFog = max(clamp(exp2(-lineIntegral), 0.0, 1.0), uf_color.w);
  if (uf_fog3.w > 0.0 && len > uf_fog3.w) { expFog = 1.0;  directional = vec3(0.0); }
  return vec4(inscattering * (1.0 - expFog) + directional, expFog);
}
#endif

#ifdef SL_SH
// FThreeBandSHVector SHBasisFunction3, Unreal's frame
void slSHBasis(vec3 v, out vec4 v0, out vec4 v1, out float v2) {
  v0 = vec4(0.282095, -0.488603 * v.y, 0.488603 * v.z, -0.488603 * v.x);
  vec3 sq = v * v;
  v1 = vec4(1.092548 * v.x * v.y, -1.092548 * v.y * v.z, 0.315392 * (3.0 * sq.z - 1.0), -1.092548 * v.x * v.z);
  v2 = 0.546274 * (sq.x - sq.y);
}
#endif

void main() {
#ifdef SL_CAPTURE
  vec3 dUe = normalize(slCubemapVector(slScaledUVs(), int(sl_face)));
  vec3 dOurs = vec3(dUe.x, dUe.z, dUe.y);
  vec3 L = slSky(dUe);
  vec4 fog = slHeightFog(dOurs);
  L = L * fog.a + fog.rgb;
  // ApplyLowerHemisphereColorPS: below the horizon (Unreal's N.z < 0) the solid colour by its coverage (alpha 1: all of it)
  if (dUe.z < 0.0 && sl_lower_on > 0.5) L = sl_lower_color;
  o_color = vec4(max(L, vec3(0.0)), 1.0);
#endif
#ifdef SL_DOWNSAMPLE
  // DownsampleCS: four taps at +-0.5 x SampleOffset (2 x 2 / MipSize, this mip's size) along the face's tangents, from the mip above
  vec2 su = slScaledUVs();
  int face = int(sl_face);
  vec3 cc = slCubemapVector(su, face);
  float mipSize = max(sl_size / exp2(sl_mip), 1.0);
  vec3 tz = normalize(cc);
  vec3 tx = normalize(cross(slCubemapVector(su + vec2(0.0, 1.0), face), tz));
  vec3 ty = cross(tz, tx);
  float off = 2.0 * 2.0 / mipSize;
  vec4 c = vec4(0.0);
  c += slSampleMip(cc + tx * (-0.5 * off) + ty * (-0.5 * off), sl_mip - 1.0);
  c += slSampleMip(cc + tx * (0.5 * off) + ty * (-0.5 * off), sl_mip - 1.0);
  c += slSampleMip(cc + tx * (0.5 * off) + ty * (0.5 * off), sl_mip - 1.0);
  c += slSampleMip(cc + tx * (-0.5 * off) + ty * (0.5 * off), sl_mip - 1.0);
  o_color = c * 0.25;
#endif
#ifdef SL_FILTER
  vec3 cc = slCubemapVector(slScaledUVs(), int(sl_face));
  vec3 N = normalize(cc);
  // GetTangentBasis
  float sgn = N.z >= 0.0 ? 1.0 : -1.0;
  float a = -1.0 / (sgn + N.z);
  float b = N.x * N.y * a;
  vec3 TX = vec3(1.0 + sgn * a * N.x * N.x, sgn * b, -sgn * N.x);
  vec3 TY = vec3(b, sgn + a * N.y * N.y, -N.y);
  // ComputeReflectionCaptureRoughnessFromMip(MipIndex, NumMips - 1)
  float maxMip = sl_mips - 1.0;
  float roughness = exp2((1.0 - (maxMip - 1.0 - sl_mip)) / 1.2);
  if (roughness < 0.01) { o_color = max(slSampleMip(cc, 0.0), vec4(0.0));  return; }
  float cubeSize = exp2(sl_mips - 1.0);
  float solidAngleTexel = 4.0 * SL_PI / (6.0 * cubeSize * cubeSize) * 2.0;
  int numSamples = roughness < 0.1 ? 32 : 64;
  vec4 filtered = vec4(0.0);
  if (roughness > 0.99) {
    for (int i = 0; i < 64; i++) {
      if (i >= numSamples) break;
      vec2 E = vec2(fract(float(i) / float(numSamples)), float(bitfieldReverse(uint(i))) * 2.3283064365386963e-10);   // Hammersley
      float phi = 2.0 * SL_PI * E.x;
      float ct = sqrt(E.y);
      float st = sqrt(1.0 - ct * ct);
      vec3 Lt = vec3(st * cos(phi), st * sin(phi), ct);                              // CosineSampleHemisphere
      float pdf = Lt.z / SL_PI;
      float sa = 1.0 / (float(numSamples) * pdf);
      float mip = 0.5 * log2(sa / solidAngleTexel);
      vec3 Lw = Lt.x * TX + Lt.y * TY + Lt.z * N;
      filtered += slSample(Lw, mip);
    }
    o_color = filtered / float(numSamples);
  } else {
    float weight = 0.0;
    float a2 = roughness * roughness * roughness * roughness;                        // Pow4(Roughness)
    for (int i = 0; i < 64; i++) {
      if (i >= numSamples) break;
      vec2 E = vec2(fract(float(i) / float(numSamples)), float(bitfieldReverse(uint(i))) * 2.3283064365386963e-10);
      E.y *= 0.995;
      // ImportanceSampleGGX
      float phi = 2.0 * SL_PI * E.x;
      float ct = sqrt((1.0 - E.y) / (1.0 + (a2 - 1.0) * E.y));
      float st = sqrt(1.0 - ct * ct);
      vec3 H = vec3(st * cos(phi), st * sin(phi), ct);
      vec3 Lt = 2.0 * H.z * H - vec3(0.0, 0.0, 1.0);
      float NoL = Lt.z;
      float NoH = H.z;
      if (NoL > 0.0) {
        float d = (NoH * a2 - NoH) * NoH + 1.0;
        float pdf = a2 / (SL_PI * d * d) * 0.25;                                     // D_GGX(a2, NoH) * 0.25
        float sa = 1.0 / (float(numSamples) * pdf);
        float mip = 0.5 * log2(sa / solidAngleTexel);
        vec3 Lw = Lt.x * TX + Lt.y * TY + Lt.z * N;
        filtered += slSample(Lw, mip) * NoL;
        weight += NoL;
      }
    }
    o_color = filtered / weight;
  }
  o_color = max(o_color, vec4(0.0));
#endif
#ifdef SL_SH
  // 64 uniform directions (8 x 8 cells), the capture's mip MipIndex point-sampled, each weighted by 4 PI / 64
  vec4 r0 = vec4(0.0), r1 = vec4(0.0), g0 = vec4(0.0), g1 = vec4(0.0), b0 = vec4(0.0), b1 = vec4(0.0);
  float r2 = 0.0, g2 = 0.0, b2 = 0.0;
  float w = 4.0 * SL_PI / 64.0;
  for (int y = 0; y < 8; y++) {
    for (int x = 0; x < 8; x++) {
      vec2 E = (vec2(float(x), float(y)) + 0.5) / 8.0;
      float phi = 2.0 * SL_PI * E.x;
      float ct = 1.0 - 2.0 * E.y;
      float st = sqrt(1.0 - ct * ct);
      vec3 d = vec3(st * cos(phi), st * sin(phi), ct);                               // UniformSampleSphere
      // SF_Point at MipIndex: the nearest texel
      vec2 s;
      int face = slFaceOf(d, s);
      float res = max(sl_size / exp2(sl_mip), 1.0);
      ivec2 tc = ivec2(clamp(floor((s * 0.5 + 0.5) * res), vec2(0.0), vec2(res - 1.0)));
      ivec3 tl = ivec3(tc, int(sl_mip) * 6 + face);
      vec3 c = (int(sl_mip) % 2 == 1 ? texelFetch(sl_src2, tl, 0).rgb : texelFetch(sl_src, tl, 0).rgb) * w;
      vec4 v0, v1;  float v2;
      slSHBasis(d, v0, v1, v2);
      r0 += v0 * c.r;  r1 += v1 * c.r;  r2 += v2 * c.r;
      g0 += v0 * c.g;  g1 += v1 * c.g;  g2 += v2 * c.g;
      b0 += v0 * c.b;  b1 += v1 * c.b;  b2 += v2 * c.b;
    }
  }
  float sqrtPI = sqrt(SL_PI);
  float c0 = 1.0 / (2.0 * sqrtPI);
  float c1 = sqrt(3.0) / (3.0 * sqrtPI);
  float c2 = sqrt(15.0) / (8.0 * sqrtPI);
  float c3 = sqrt(5.0) / (16.0 * sqrtPI);
  float c4 = 0.5 * c2;
  int i = int(floor(gl_FragCoord.x));
  vec4 o = vec4(0.0);
  if (i == 0) o = vec4(-c1 * r0.w, -c1 * r0.y, c1 * r0.z, c0 * r0.x - c3 * r1.z);
  if (i == 1) o = vec4(-c1 * g0.w, -c1 * g0.y, c1 * g0.z, c0 * g0.x - c3 * g1.z);
  if (i == 2) o = vec4(-c1 * b0.w, -c1 * b0.y, c1 * b0.z, c0 * b0.x - c3 * b1.z);
  if (i == 3) o = vec4(c2 * r1.x, -c2 * r1.y, 3.0 * c3 * r1.z, -c2 * r1.w);
  if (i == 4) o = vec4(c2 * g1.x, -c2 * g1.y, 3.0 * c3 * g1.z, -c2 * g1.w);
  if (i == 5) o = vec4(c2 * b1.x, -c2 * b1.y, 3.0 * c3 * b1.z, -c2 * b1.w);
  if (i == 6) o = vec4(c4 * r2, c4 * g2, c4 * b2, 1.0);
  o_color = o;
#endif
}
