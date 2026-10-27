// Unreal's Sky Atmosphere LUTs, ported from UE 5.8 SkyAtmosphere.usf (IntegrateSingleScatteredLuminance, RenderTransmittanceLutCS,
// RenderMultiScatteredLuminanceLutCS, RenderSkyViewLutCS) and SkyAtmosphereCommon.ush (SampleAtmosphereMediumRGB, the LUT uv mappings),
// with ParticipatingMediaCommon.ush's phase functions. Units are Unreal's sky units, kilometres; the planet frame is Unreal's, z up.
// One pass per define: UA_TRANSMITTANCE (256x64), UA_MULTISCAT (32x32), UA_SKYVIEW (192x104). Per-pixel noise is off in these LUT
// passes in Unreal too (DEFAULT_SAMPLE_OFFSET 0.3); the second atmosphere light is not ported (the moon lights the night instead).
in vec2 v_uv;
out vec4 o_color;
uniform vec2 ua_radii;                 // BottomRadiusKm, TopRadiusKm
uniform vec4 ua_rayleigh;              // RayleighScattering (rgb), RayleighDensityExpScale
uniform vec4 ua_mie_sca;               // MieScattering (rgb), MieDensityExpScale
uniform vec4 ua_mie_ext;               // MieExtinction (rgb), MiePhaseG
uniform vec3 ua_mie_abs;               // MieAbsorption
uniform vec3 ua_ozone;                 // AbsorptionExtinction
uniform vec4 ua_ozone_tent;            // AbsorptionDensity0LayerWidth, 0LinearTerm, 0ConstantTerm, 1LinearTerm
uniform float ua_ozone_c1;             // AbsorptionDensity1ConstantTerm
uniform vec3 ua_ground_albedo;         // GroundAlbedo
uniform float ua_ms_factor;            // MultiScatteringFactor
uniform vec4 ua_size;                  // this LUT's SizeAndInvSize
uniform vec4 ua_samples;               // TransmittanceSampleCount, MultiScatteringSampleCount, FastSkySampleCountMin, Max
uniform float ua_dist_to_max_inv;      // FastSkyDistanceToSampleCountMaxInv
uniform sampler2D ua_transmittance;    // the transmittance LUT (multi-scattering and sky view passes)
uniform sampler2D ua_multiscat;        // the multi-scattering LUT (sky view pass)
uniform vec4 ua_light_dir;             // xyz: the sun in the sky view LUT's local frame; w: the view height (km)
uniform vec3 ua_light_illum;           // AtmosphereLightIlluminanceOuterSpace x SkyAndAerialPerspectiveLuminanceFactor
const float UA_PI = 3.14159265358979;
const float UA_PLANET_RADIUS_OFFSET = 0.001;

vec2 uaRayIntersectSphere(vec3 ro, vec3 rd, vec4 sphere) {
  vec3 lp = ro - sphere.xyz;
  float a = dot(rd, rd);
  float b = 2.0 * dot(rd, lp);
  float c = dot(lp, lp) - sphere.w * sphere.w;
  float disc = b * b - 4.0 * a * c;
  vec2 r = vec2(-1.0);
  if (disc >= 0.0) { float s = sqrt(disc); r = vec2(-b - s, -b + s) / (2.0 * a); }
  return r;
}
float uaRaySphereIntersectNearest(vec3 ro, vec3 rd, vec3 c, float r) {
  vec2 sol = uaRayIntersectSphere(ro, rd, vec4(c, r));
  if (sol.x < 0.0 && sol.y < 0.0) return -1.0;
  if (sol.x < 0.0) return max(0.0, sol.y);
  if (sol.y < 0.0) return max(0.0, sol.x);
  return max(0.0, min(sol.x, sol.y));
}
float uaHenyeyGreenstein(float g, float cosTheta) {
  float numer = 1.0 - g * g;
  float denom = 1.0 + g * g + 2.0 * g * cosTheta;
  return numer / (4.0 * UA_PI * denom * sqrt(denom));
}
float uaRayleighPhase(float cosTheta) { return 3.0 / (16.0 * UA_PI) * (1.0 + cosTheta * cosTheta); }

// SkyAtmosphereCommon.ush
vec2 uaFromUnitToSubUvs(vec2 uv, vec4 s) { return (uv + 0.5 * s.zw) * (s.xy / (s.xy + 1.0)); }
vec2 uaFromSubUvsToUnit(vec2 uv, vec4 s) { return (uv - 0.5 * s.zw) * (s.xy / (s.xy - 1.0)); }
void uaFromTransmittanceLutUVs(out float viewHeight, out float viewZenithCosAngle, vec2 uv) {
  float bottom = ua_radii.x, top = ua_radii.y;
  float h = sqrt(top * top - bottom * bottom);
  float rho = h * uv.y;
  viewHeight = sqrt(rho * rho + bottom * bottom);
  float dmin = top - viewHeight;
  float dmax = rho + h;
  float d = dmin + uv.x * (dmax - dmin);
  viewZenithCosAngle = d == 0.0 ? 1.0 : (h * h - rho * rho - d * d) / (2.0 * viewHeight * d);
  viewZenithCosAngle = clamp(viewZenithCosAngle, -1.0, 1.0);
}
vec2 uaTransmittanceLutUvs(float viewHeight, float viewZenithCosAngle) {
  float bottom = ua_radii.x, top = ua_radii.y;
  float h = sqrt(max(0.0, top * top - bottom * bottom));
  float rho = sqrt(max(0.0, viewHeight * viewHeight - bottom * bottom));
  float discr = viewHeight * viewHeight * (viewZenithCosAngle * viewZenithCosAngle - 1.0) + top * top;
  float d = max(0.0, -viewHeight * viewZenithCosAngle + sqrt(discr));
  float dmin = top - viewHeight;
  float dmax = rho + h;
  return vec2((d - dmin) / (dmax - dmin), rho / h);
}
struct UaMedium { vec3 scattering; vec3 extinction; vec3 scatteringMie; vec3 scatteringRay; };
UaMedium uaSampleMedium(vec3 p) {
  float h = max(0.0, length(p) - ua_radii.x);
  float dMie = exp(ua_mie_sca.w * h);
  float dRay = exp(ua_rayleigh.w * h);
  float dOzo = h < ua_ozone_tent.x ? clamp(ua_ozone_tent.y * h + ua_ozone_tent.z, 0.0, 1.0) : clamp(ua_ozone_tent.w * h + ua_ozone_c1, 0.0, 1.0);
  UaMedium m;
  m.scatteringMie = dMie * ua_mie_sca.rgb;
  m.scatteringRay = dRay * ua_rayleigh.rgb;
  m.scattering = m.scatteringMie + m.scatteringRay;
  m.extinction = dMie * ua_mie_ext.rgb + m.scatteringRay + dOzo * ua_ozone;
  return m;
}
vec3 uaGetTransmittance(float lightZenithCosAngle, float pHeight) {
  vec3 t = textureLod(ua_transmittance, uaTransmittanceLutUvs(pHeight, lightZenithCosAngle), 0.0).rgb;
  return t * t;                                      // DecodeTransmittance
}
vec3 uaGetMultipleScattering(vec3 p, float viewZenithCosAngle) {
  vec2 uv = clamp(vec2(viewZenithCosAngle * 0.5 + 0.5, (length(p) - ua_radii.x) / (ua_radii.y - ua_radii.x)), 0.0, 1.0);
  return textureLod(ua_multiscat, uv, 0.0).rgb;
}

struct UaResult { vec3 L; vec3 opticalDepth; vec3 transmittance; vec3 multiScatAs1; };
// IntegrateSingleScatteredLuminance, the LUT passes' path (no depth buffer, no shadow map, no clouds)
UaResult uaIntegrate(vec3 worldPos, vec3 worldDir, bool ground, bool variableCount, float sampleCountIni, bool mieRayPhase,
                     vec3 lightDir, vec3 lightIllum, bool useMultiScat) {
  UaResult r;
  r.L = vec3(0.0);  r.opticalDepth = vec3(0.0);  r.transmittance = vec3(1.0);  r.multiScatAs1 = vec3(0.0);
  if (dot(worldPos, worldPos) <= ua_radii.x * ua_radii.x) return r;
  float tBottom = 0.0;
  vec2 solB = uaRayIntersectSphere(worldPos, worldDir, vec4(0.0, 0.0, 0.0, ua_radii.x));
  vec2 solT = uaRayIntersectSphere(worldPos, worldDir, vec4(0.0, 0.0, 0.0, ua_radii.y));
  bool noBot = solB.x < 0.0 && solB.y < 0.0;
  bool noTop = solT.x < 0.0 && solT.y < 0.0;
  float tMax;
  if (noTop) return r;
  else if (noBot) tMax = max(solT.x, solT.y);
  else { tBottom = max(0.0, min(solB.x, solB.y));  tMax = tBottom; }
  tMax = min(tMax, 9000000.0);
  float sampleCount = sampleCountIni;
  float sampleCountFloor = sampleCountIni;
  float tMaxFloor = tMax;
  if (variableCount) {
    sampleCount = mix(ua_samples.z, ua_samples.w, clamp(tMax * ua_dist_to_max_inv, 0.0, 1.0));
    sampleCountFloor = floor(sampleCount);
    tMaxFloor = tMax * sampleCountFloor / sampleCount;
  }
  float dt = tMax / sampleCount;
  const float uniformPhase = 1.0 / (4.0 * UA_PI);
  float cosTheta = dot(lightDir, worldDir);
  float miePhase = uaHenyeyGreenstein(ua_mie_ext.w, -cosTheta);
  float rayPhase = uaRayleighPhase(cosTheta);
  vec3 L = vec3(0.0);
  vec3 throughput = vec3(1.0);
  vec3 opticalDepth = vec3(0.0);
  const float pixelNoise = 0.3;                       // DEFAULT_SAMPLE_OFFSET
  for (int i = 0; i < 64; i++) {
    float sampleI = float(i);
    if (sampleI >= sampleCount) break;
    float t;
    if (variableCount) {
      float t0 = sampleI / sampleCountFloor;
      float t1 = (sampleI + 1.0) / sampleCountFloor;
      t0 = t0 * t0;  t1 = t1 * t1;
      t0 = tMaxFloor * t0;
      t1 = t1 > 1.0 ? tMax : tMaxFloor * t1;
      t = t0 + (t1 - t0) * pixelNoise;
      dt = t1 - t0;
    } else {
      t = tMax * (sampleI + pixelNoise) / sampleCount;
    }
    vec3 P = worldPos + t * worldDir;
    float pHeight = length(P);
    UaMedium m = uaSampleMedium(P);
    vec3 sampleOpticalDepth = m.extinction * dt;
    vec3 sampleTransmittance = exp(-sampleOpticalDepth);
    opticalDepth += sampleOpticalDepth;
    vec3 up = P / pHeight;
    float lightZenithCos = dot(lightDir, up);
    vec3 transToLight = vec3(1.0);
#ifndef UA_TRANSMITTANCE
    transToLight = uaGetTransmittance(lightZenithCos, pHeight);
#endif
    vec3 phaseTimesScattering = mieRayPhase ? m.scatteringMie * miePhase + m.scatteringRay * rayPhase : m.scattering * uniformPhase;
    vec3 multiScat = vec3(0.0);
#ifdef UA_SKYVIEW
    if (useMultiScat) multiScat = uaGetMultipleScattering(P, lightZenithCos);
#endif
    float tPlanet = uaRaySphereIntersectNearest(P, lightDir, UA_PLANET_RADIUS_OFFSET * up, ua_radii.x);
    float planetShadow = tPlanet >= 0.0 ? 0.0 : 1.0;
    vec3 S = lightIllum * (planetShadow * transToLight * phaseTimesScattering + multiScat * m.scattering);
    vec3 safeExt = max(m.extinction, vec3(1.0e-9));
    r.multiScatAs1 += throughput * m.scattering * dt;
    vec3 Sint = (S - S * sampleTransmittance) / safeExt;
    L += throughput * Sint;
    throughput *= sampleTransmittance;
  }
  if (ground && tMax == tBottom) {
    vec3 P = worldPos + tBottom * worldDir;
    float pHeight = length(P);
    vec3 up = P / pHeight;
    float lightZenithCos = dot(lightDir, up);
    vec3 transToLight = vec3(1.0);
#ifndef UA_TRANSMITTANCE
    transToLight = uaGetTransmittance(lightZenithCos, pHeight);
#endif
    float NdotL = clamp(dot(up, lightDir), 0.0, 1.0);
    L += lightIllum * transToLight * throughput * NdotL * ua_ground_albedo / UA_PI;
  }
  r.L = L;
  r.opticalDepth = opticalDepth;
  r.transmittance = throughput;
  return r;
}

void main() {
  vec2 pixPos = floor(gl_FragCoord.xy) + 0.5;
#ifdef UA_TRANSMITTANCE
  vec2 uv = pixPos * ua_size.zw;
  float viewHeight, viewZenithCosAngle;
  uaFromTransmittanceLutUVs(viewHeight, viewZenithCosAngle, uv);
  vec3 worldPos = vec3(0.0, 0.0, viewHeight);
  vec3 worldDir = vec3(0.0, sqrt(1.0 - viewZenithCosAngle * viewZenithCosAngle), viewZenithCosAngle);
  UaResult ss = uaIntegrate(worldPos, worldDir, false, false, ua_samples.x, false, vec3(0.0, 0.0, 1.0), vec3(0.0), false);
  o_color = vec4(sqrt(exp(-ss.opticalDepth)), 1.0);   // EncodeTransmittance
#endif
#ifdef UA_MULTISCAT
  float cosLightZenith = (pixPos.x * ua_size.z) * 2.0 - 1.0;
  vec3 lightDir = vec3(0.0, sqrt(clamp(1.0 - cosLightZenith * cosLightZenith, 0.0, 1.0)), cosLightZenith);
  float viewHeight = ua_radii.x + (pixPos.y * ua_size.w) * (ua_radii.y - ua_radii.x);
  vec3 worldPos = vec3(0.0, 0.0, viewHeight);
  vec3 worldDir = vec3(0.0, 0.0, 1.0);
  // r.SkyAtmosphere.MultiScatteringLUT.HighQuality 0: two opposite directions
  UaResult r0 = uaIntegrate(worldPos, worldDir, true, false, ua_samples.y, false, lightDir, vec3(1.0), false);
  UaResult r1 = uaIntegrate(worldPos, -worldDir, true, false, ua_samples.y, false, lightDir, vec3(1.0), false);
  const float sphereSolidAngle = 4.0 * UA_PI;
  vec3 integratedIlluminance = (sphereSolidAngle / 2.0) * (r0.L + r1.L);
  vec3 multiScatAs1 = 0.5 * (r0.multiScatAs1 + r1.multiScatAs1);
  vec3 inScattered = integratedIlluminance / sphereSolidAngle;
  vec3 m2 = multiScatAs1 * multiScatAs1;
  vec3 L = inScattered * (1.0 + multiScatAs1 + m2 + multiScatAs1 * m2 + m2 * m2);
  o_color = vec4(L * ua_ms_factor, 1.0);
#endif
#ifdef UA_SKYVIEW
  vec2 uv = uaFromSubUvsToUnit(pixPos * ua_size.zw, ua_size);
  float viewHeight = ua_light_dir.w;
  vec3 worldPos = vec3(0.0, 0.0, viewHeight);
  // UvToSkyViewLutParams
  float vHorizon = sqrt(viewHeight * viewHeight - ua_radii.x * ua_radii.x);
  float cosBeta = vHorizon / viewHeight;
  float beta = acos(cosBeta);
  float zenithHorizonAngle = UA_PI - beta;
  float viewZenithAngle;
  if (uv.y < 0.5) {
    float c = 2.0 * uv.y;
    c = 1.0 - c;  c *= c;  c = 1.0 - c;
    viewZenithAngle = zenithHorizonAngle * c;
  } else {
    float c = uv.y * 2.0 - 1.0;
    c *= c;
    viewZenithAngle = zenithHorizonAngle + beta * c;
  }
  float cosVZ = cos(viewZenithAngle);
  float sinVZ = sqrt(1.0 - cosVZ * cosVZ) * (viewZenithAngle > 0.0 ? 1.0 : -1.0);
  float lon = uv.x * 2.0 * UA_PI;
  float cosLon = cos(lon);
  float sinLon = sqrt(1.0 - cosLon * cosLon) * (lon <= UA_PI ? 1.0 : -1.0);
  vec3 worldDir = vec3(sinVZ * cosLon, sinVZ * sinLon, cosVZ);
  // MoveToTopAtmosphere
  if (viewHeight > ua_radii.y) {
    float tTop = uaRaySphereIntersectNearest(worldPos, worldDir, vec3(0.0), ua_radii.y);
    if (tTop >= 0.0) worldPos = worldPos + worldDir * tTop - (worldPos / viewHeight) * UA_PLANET_RADIUS_OFFSET;
    else { o_color = vec4(0.0);  return; }
  }
  UaResult ss = uaIntegrate(worldPos, worldDir, false, true, 0.0, true, ua_light_dir.xyz, ua_light_illum, true);
  o_color = vec4(ss.L, dot(ss.transmittance, vec3(1.0 / 3.0)));
#endif
}
