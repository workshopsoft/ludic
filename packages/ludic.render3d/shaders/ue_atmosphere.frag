// Unreal's Sky Atmosphere LUTs, ported from UE 5.8 SkyAtmosphere.usf (IntegrateSingleScatteredLuminance, RenderTransmittanceLutCS,
// RenderMultiScatteredLuminanceLutCS, RenderSkyViewLutCS) and SkyAtmosphereCommon.ush (SampleAtmosphereMediumRGB, the LUT uv mappings),
// with ParticipatingMediaCommon.ush's phase functions. Units are Unreal's sky units, kilometres; the planet frame is Unreal's, z up.
// One pass per define: UA_TRANSMITTANCE (256x64), UA_MULTISCAT (32x32), UA_SKYVIEW (192x104), UA_AP (RenderCameraAerialPerspectiveVolumeCS:
// the 32x32x16 camera volume, drawn unwrapped 512x32, slice-major), UA_DISTANT (RenderDistantSkyLightLutCS, 1x1). Per-pixel noise is off in these LUT
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
uniform float ua_ap_scale;             // AerialPespectiveViewDistanceScale (the AP pass; 1 elsewhere)
uniform vec4 ua_ap;                    // AP volume: DepthResolution, SliceLengthKm, StartDepthKm, SampleCountPerSlice
uniform mat4 ua_inv_vp;                // the camera's inverse view-projection (our frame), for the AP pass's view directions
uniform vec3 ua_cam;                   // the camera position (our frame)
uniform float ua_sky_lum_factor;       // SkyLuminanceFactor (the distant sky light)
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
                     vec3 lightDir, vec3 lightIllum, bool useMultiScat, float tMaxMax) {
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
  tMax = min(tMax, tMaxMax);
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
    vec3 sampleOpticalDepth = m.extinction * dt * ua_ap_scale;
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
#if defined(UA_SKYVIEW) || defined(UA_AP) || defined(UA_DISTANT)
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

#ifdef UA_DISTANT
// FUniformSphereSamplesBuffer: 8x8 stratified uniform sphere directions, FRandomStream(0xDE4DC0DE)
const vec3 UA_SPHERE[64] = vec3[64](
vec3(0.5533525, 0.1492713, 0.8194627),
vec3(0.6553821, 0.5229896, 0.5449369),
vec3(0.9551223, 0.1363747, 0.2629513),
vec3(0.9037319, 0.3931198, 0.1694860),
vec3(0.7310924, 0.6774261, -0.0812270),
vec3(0.9518156, 0.1502742, -0.2673288),
vec3(0.6267459, 0.2442358, -0.7399584),
vec3(0.5682184, 0.1213691, -0.8138780),
vec3(0.0179671, 0.3142239, 0.9491789),
vec3(0.4159009, 0.5785654, 0.7016327),
vec3(0.2053719, 0.8438801, 0.4956700),
vec3(0.2957283, 0.9539495, 0.0502504),
vec3(0.3851888, 0.9039135, -0.1859299),
vec3(0.4122300, 0.8602490, -0.3000634),
vec3(0.2827352, 0.6756444, -0.6808564),
vec3(0.0195404, 0.6202590, -0.7841537),
vec3(-0.2634119, 0.5399484, 0.7994185),
vec3(-0.4683008, 0.6002202, 0.6484058),
vec3(-0.1940463, 0.8840112, 0.4252885),
vec3(-0.0780520, 0.9742335, 0.2116057),
vec3(-0.5417029, 0.8365845, -0.0817578),
vec3(-0.4006138, 0.8445971, -0.3551962),
vec3(-0.4140240, 0.5683758, -0.7110085),
vec3(-0.1103175, 0.5248388, -0.8440227),
vec3(-0.3752227, 0.0253295, 0.9265886),
vec3(-0.6333191, 0.4855792, 0.6025942),
vec3(-0.7332519, 0.4727092, 0.4887613),
vec3(-0.7805112, 0.5871858, 0.2145112),
vec3(-0.9705755, 0.1201932, -0.2086549),
vec3(-0.8530667, 0.3317304, -0.4027805),
vec3(-0.5928946, 0.4899529, -0.6390792),
vec3(-0.4724869, 0.2195276, -0.8535594),
vec3(-0.1518238, -0.1012729, 0.9832056),
vec3(-0.6905984, -0.0348385, 0.7223989),
vec3(-0.6766675, -0.6279244, 0.3844893),
vec3(-0.7842339, -0.5988998, 0.1621610),
vec3(-0.9299999, -0.2792799, -0.2389623),
vec3(-0.8441043, -0.2155534, -0.4909426),
vec3(-0.8226982, -0.1945482, -0.5341523),
vec3(-0.2219073, -0.1180164, -0.9678994),
vec3(-0.0207274, -0.6223063, 0.7824994),
vec3(-0.0281751, -0.7702711, 0.6370938),
vec3(-0.0199246, -0.8933119, 0.4489954),
vec3(-0.3998525, -0.8989339, 0.1789853),
vec3(-0.4873029, -0.8655967, -0.1152317),
vec3(-0.5097855, -0.8082692, -0.2946517),
vec3(-0.5238350, -0.5450683, -0.6545972),
vec3(-0.0765671, -0.3315041, -0.9403417),
vec3(0.0655846, -0.5159180, 0.8541237),
vec3(0.3149447, -0.6360748, 0.7044279),
vec3(0.3254340, -0.8316193, 0.4500023),
vec3(0.0359973, -0.9794625, 0.1983870),
vec3(0.4483085, -0.8747689, -0.1838447),
vec3(0.2361585, -0.8550158, -0.4617111),
vec3(0.1023631, -0.7330320, -0.6724477),
vec3(0.2624325, -0.5866616, -0.7661314),
vec3(0.4685708, -0.2661343, 0.8423859),
vec3(0.8496861, -0.0846064, 0.5204569),
vec3(0.9156181, -0.1573575, 0.3699759),
vec3(0.9768367, -0.2062251, 0.0571073),
vec3(0.7272789, -0.6743543, -0.1277168),
vec3(0.6824716, -0.6728795, -0.2854219),
vec3(0.5925695, -0.4412468, -0.6739159),
vec3(0.2228967, -0.0468816, -0.9737141)
);
#endif

void main() {
  vec2 pixPos = floor(gl_FragCoord.xy) + 0.5;
#ifdef UA_TRANSMITTANCE
  vec2 uv = pixPos * ua_size.zw;
  float viewHeight, viewZenithCosAngle;
  uaFromTransmittanceLutUVs(viewHeight, viewZenithCosAngle, uv);
  vec3 worldPos = vec3(0.0, 0.0, viewHeight);
  vec3 worldDir = vec3(0.0, sqrt(1.0 - viewZenithCosAngle * viewZenithCosAngle), viewZenithCosAngle);
  UaResult ss = uaIntegrate(worldPos, worldDir, false, false, ua_samples.x, false, vec3(0.0, 0.0, 1.0), vec3(0.0), false, 9000000.0);
  o_color = vec4(sqrt(exp(-ss.opticalDepth)), 1.0);   // EncodeTransmittance
#endif
#ifdef UA_MULTISCAT
  float cosLightZenith = (pixPos.x * ua_size.z) * 2.0 - 1.0;
  vec3 lightDir = vec3(0.0, sqrt(clamp(1.0 - cosLightZenith * cosLightZenith, 0.0, 1.0)), cosLightZenith);
  float viewHeight = ua_radii.x + (pixPos.y * ua_size.w) * (ua_radii.y - ua_radii.x);
  vec3 worldPos = vec3(0.0, 0.0, viewHeight);
  vec3 worldDir = vec3(0.0, 0.0, 1.0);
  // r.SkyAtmosphere.MultiScatteringLUT.HighQuality 0: two opposite directions
  UaResult r0 = uaIntegrate(worldPos, worldDir, true, false, ua_samples.y, false, lightDir, vec3(1.0), false, 9000000.0);
  UaResult r1 = uaIntegrate(worldPos, -worldDir, true, false, ua_samples.y, false, lightDir, vec3(1.0), false, 9000000.0);
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
  UaResult ss = uaIntegrate(worldPos, worldDir, false, true, 0.0, true, ua_light_dir.xyz, ua_light_illum, true, 9000000.0);
  o_color = vec4(ss.L, dot(ss.transmittance, vec3(1.0 / 3.0)));
#endif
#ifdef UA_AP
  // the volume unwrapped: x = slice * width + column
  float w = 32.0;
  float zi = floor(pixPos.x / w);
  vec2 uv = vec2(pixPos.x - zi * w, pixPos.y) / vec2(w, ua_size.y);
  vec4 far4 = ua_inv_vp * vec4(uv * 2.0 - 1.0, DEPTH_FAR_POINT, 1.0);
  vec3 dOurs = normalize(far4.xyz / far4.w - ua_cam);
  vec3 worldDir = vec3(dOurs.x, dOurs.z, dOurs.y);
  vec3 camPos = vec3(0.0, 0.0, ua_light_dir.w);      // GetTranslatedCameraPlanetPos: the planet centre straight below
  float res = ua_ap.x;
  float slice = (zi + 0.5) / res;
  slice *= slice;
  slice *= res;
  vec3 rayStart = camPos + ua_ap.z * worldDir;
  float tMax = slice * ua_ap.y;
  vec3 voxel = rayStart + tMax * worldDir;
  float voxelHeight = length(voxel);
  bool underGround = voxelHeight < ua_radii.x;
  vec3 camToVoxel = voxel - camPos;
  float camToVoxelLen = length(camToVoxel);
  vec3 camToVoxelDir = camToVoxel / camToVoxelLen;
  float planetNearT = uaRaySphereIntersectNearest(camPos, camToVoxelDir, vec3(0.0), ua_radii.x);
  bool belowHorizon = planetNearT > 0.0 && camToVoxelLen > planetNearT;
  if (belowHorizon || underGround) {
    camPos += normalize(camPos) * 0.02;
    vec3 voxNorm = normalize(voxel);
    vec3 camProj = normalize(camPos) * ua_radii.x;
    vec3 voxProj = voxNorm * ua_radii.x;
    vec3 voxGroundToRayStart = camPos - voxProj;
    if (belowHorizon && dot(normalize(voxGroundToRayStart), voxNorm) < 0.0001) {
      vec3 mid = 0.5 * (camProj + voxProj);
      vec3 midOnGround = normalize(mid) * ua_radii.x;
      voxel = camPos + 2.0 * (midOnGround - camPos);
    } else if (underGround) {
      voxel = normalize(voxel) * ua_radii.x;
    }
    worldDir = normalize(voxel - camPos);
    rayStart = camPos + ua_ap.z * worldDir;
    tMax = length(voxel - rayStart);
  }
  float tMaxMax = tMax;
  float viewHeight = length(rayStart);
  if (viewHeight >= ua_radii.y) {
    vec3 prev = rayStart;
    float tTop = uaRaySphereIntersectNearest(rayStart, worldDir, vec3(0.0), ua_radii.y);
    if (tTop < 0.0) { o_color = vec4(0.0, 0.0, 0.0, 1.0);  return; }
    rayStart = rayStart + worldDir * tTop - (rayStart / viewHeight) * UA_PLANET_RADIUS_OFFSET;
    float lenToAtmo = length(prev - rayStart);
    if (tMaxMax < lenToAtmo) { o_color = vec4(0.0, 0.0, 0.0, 1.0);  return; }
    tMaxMax = max(0.0, tMaxMax - lenToAtmo);
  }
  float count = max(1.0, (zi + 1.0) * ua_ap.w);
  UaResult ss = uaIntegrate(rayStart, worldDir, false, false, count, true, ua_light_dir.xyz, ua_light_illum, true, tMaxMax);
  o_color = vec4(ss.L, dot(ss.transmittance, vec3(1.0 / 3.0)));
#endif
#ifdef UA_DISTANT
  vec3 samplePos = vec3(0.0, 0.0, ua_radii.x + 6.0);   // r.SkyAtmosphere.DistantSkyLightLUT.Altitude
  vec3 acc = vec3(0.0);
  for (int i = 0; i < 64; i++) {
    UaResult ss = uaIntegrate(samplePos, UA_SPHERE[i], false, false, 10.0, false, ua_light_dir.xyz, ua_light_illum, true, 9000000.0);
    acc += ss.L * ua_sky_lum_factor;
  }
  vec3 illuminance = acc * (4.0 * UA_PI / 64.0);
  o_color = vec4(illuminance / (4.0 * UA_PI), 0.0);
#endif
}
