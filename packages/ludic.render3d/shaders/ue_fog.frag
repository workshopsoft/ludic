// Unreal's exponential height fog and aerial perspective over the opaque scene, ported from UE 5.8 HeightFogPixelShader.usf
// (ExponentialPixelMain: CalculateHeightFog, then GetAerialPerspectiveLuminanceTransmittanceWithFogOver where there is geometry) with
// HeightFogCommon.ush GetExponentialHeightFog and SkyAtmosphereCommon.ush GetAerialPerspectiveLuminanceTransmittance. Project settings
// as Unreal's defaults: the sky atmosphere lights the fog (r.SupportSkyAtmosphereAffectsHeightFog 1: the distant sky light as ambient,
// the sun on the ground as the directional colour), r.SupportExpFogMatchesVolumetricFog 0. No inscattering cubemap, no volumetric fog
// (not ported yet). Blended over the scene as Unreal's fog pass is: scene x a + rgb (ONE, SRC_ALPHA). Metres; Unreal's z is our y.
in vec2 v_uv;
out vec4 o_color;
uniform sampler2D u_depth;
uniform mat4 u_inv_vp;
uniform vec4 uf_fog0;              // ExponentialFogParameters: collapsed density, falloff (1/m), MaxWorldObserverHeight, StartDistance
uniform vec4 uf_fog2;              // ExponentialFogParameters2: second fog's collapsed density, falloff, density, height
uniform vec4 uf_fog3;              // ExponentialFogParameters3: density, height, 0 (no cubemap), FogCutoffDistance
uniform vec4 uf_color;             // ExponentialFogColorParameter: FogInscatteringLuminance, 1 - FogMaxOpacity
uniform vec3 uf_ambient_scale;     // SkyAtmosphereAmbientContributionColorScale x SkyAtmosphereHeightFogContribution
uniform sampler2D uf_distant;      // the distant sky light (ue_atmosphere.frag UA_DISTANT), 1x1
uniform vec4 uf_light_dir;         // InscatteringLightDirection (toward the sun, ours), w: the start distance or -1 off
uniform vec4 uf_dir_color;         // DirectionalInscatteringColor (+ the sun on the ground after transmittance x contribution), exponent
uniform float uf_end;              // EndDistance (0 none)
uniform float uf_ap_on;            // the sky atmosphere's aerial perspective
uniform sampler2D uf_ap;           // the AP volume, unwrapped (32 x 16 slices) x 32
uniform vec4 uf_ap_params;         // DepthResolution, StartDepthKm, DepthSliceLengthKm, width of a slice in texels
uniform float uf_sky_dist;         // the distance a sky pixel is fogged at (reverse-Z depth 0: Unreal's far depth)
uniform float uf_vol_on;           // the volumetric fog (ue_volfog.frag) is applied (FogStruct.ApplyVolumetricFog)
uniform sampler2DArray uf_vol;     // its integrated grid, a layer a slice
uniform vec3 uf_vol_grid;          // ViewGridSize
uniform vec3 uf_vol_zp;            // GridZParams
uniform vec2 uf_vol_uv;            // the view's uv to the grid's (VolumetricFogSVPosToVolumeUV over the view)
uniform float uf_vol_dist;         // VolumetricFogMaxDistance (m)
uniform vec3 uf_fwd;               // the view's forward
uniform float uf_vol_debug;        // R3D_UE_VOLFOG_DEBUG: show the grid's cell at the pixel's depth (the sun's shadow factor)
const float UF_PI = 3.14159265358979;

float ufLineIntegralShared(float falloff, float rayDirZ, float rayOriginTerms) {
  float f = max(-127.0, falloff * rayDirZ);
  float li = (1.0 - exp2(-f)) / f;
  float lt = log(2.0) - (0.5 * log(2.0) * log(2.0)) * f;
  return rayOriginTerms * (abs(f) > 0.01 ? li : lt);         // FLT_EPSILON2 (HeightFogCommon.ush): 0.01
}

vec4 ufHeightFog(vec3 camToReceiver, vec3 camPos, float excludeIn) {
  float minOpacity = uf_color.w;
  float maxObs = uf_fog0.z;
  vec3 obs = vec3(camPos.x, min(camPos.y, maxObs), camPos.z);
  float lenXZ2 = dot(camToReceiver.xz, camToReceiver.xz);
  if (uf_end > 0.0 && lenXZ2 > uf_end * uf_end) camToReceiver *= uf_end / sqrt(max(1.0, lenXZ2));
  camToReceiver.y += camPos.y - obs.y;
  float len2 = dot(camToReceiver, camToReceiver);
  float lenInv = inversesqrt(max(len2, 0.00000001));
  float len = len2 * lenInv;
  vec3 dirN = camToReceiver * lenInv;
  float rayOriginTerms = uf_fog0.x;
  float rayOriginTerms2 = uf_fog2.x;
  float rayLength = len;
  float rayDirY = camToReceiver.y;
  // PERMUTATION_SUPPORT_FOG_START_DISTANCE
  float exclude = max(excludeIn, uf_fog0.w);
  if (exclude > 0.0) {
    float t = exclude * lenInv;
    float camToExclY = t * camToReceiver.y;
    float exclY = obs.y + camToExclY;
    float exclToRecY = camToReceiver.y - camToExclY;
    rayLength = (1.0 - t) * len;
    rayDirY = exclToRecY;
    float e = max(-127.0, uf_fog0.y * (exclY - uf_fog3.y));
    rayOriginTerms = uf_fog3.x * exp2(-e);
    float e2 = max(-127.0, uf_fog2.y * (exclY - uf_fog2.w));
    rayOriginTerms2 = uf_fog2.z * exp2(-e2);
  }
  float sharedLI = ufLineIntegralShared(uf_fog0.y, rayDirY, rayOriginTerms);
  sharedLI += ufLineIntegralShared(uf_fog2.y, rayDirY, rayOriginTerms2);       // PERMUTATION_SUPPORT_FOG_SECOND_TERM
  float lineIntegral = sharedLI * rayLength;
  // ComputeInscatteringColor: the fog's luminance plus the sky's ambient (PROJECT_SUPPORT_SKY_ATMOSPHERE_AFFECTS_HEIGHFOG)
  vec3 inscattering = uf_color.rgb + uf_ambient_scale * texture(uf_distant, vec2(0.5)).rgb;
  vec3 directional = vec3(0.0);
  if (uf_light_dir.w >= 0.0) {
    const float uniformPhase = 1.0 / (4.0 * UF_PI);
    vec3 dl = uf_dir_color.rgb * pow(clamp(dot(dirN, uf_light_dir.xyz), 0.0, 1.0), uf_dir_color.w) * uniformPhase;
    float dirIntegral = sharedLI * max(rayLength - uf_light_dir.w, 0.0);
    float dirFactor = clamp(exp2(-dirIntegral), 0.0, 1.0);
    directional = dl * (1.0 - dirFactor);
  }
  float expFog = max(clamp(exp2(-lineIntegral), 0.0, 1.0), minOpacity);
  if (uf_fog3.w > 0.0 && len > uf_fog3.w) { expFog = 1.0;  directional = vec3(0.0); }
  return vec4(inscattering * (1.0 - expFog) + directional, expFog);
}

// GetAerialPerspectiveLuminanceTransmittance (NearFadeOutRangeInvDepthKm for 1 cm), the volume unwrapped by slice
vec4 ufAerialPerspective(vec2 screenUv, float distKm) {
  float res = uf_ap_params.x;
  float tDepth = max(0.0, distKm - uf_ap_params.y);
  float linearSlice = tDepth / uf_ap_params.z;
  float linearW = linearSlice / res;
  float nonLinW = sqrt(linearW);
  float nonLinSlice = nonLinW * res;
  float weight = 1.0;
  if (nonLinSlice < 0.70710678118654752) weight = clamp(nonLinSlice * nonLinSlice * 2.0, 0.0, 1.0);
  weight *= clamp(tDepth * 100000.0, 0.0, 1.0);
  // trilinear across slices: slice centres at (i + 0.5) / res
  float z = clamp(nonLinW * res - 0.5, 0.0, res - 1.0);
  float z0 = floor(z);
  float z1 = min(z0 + 1.0, res - 1.0);
  float fz = z - z0;
  float w = uf_ap_params.w;
  float sx = clamp(screenUv.x, 0.5 / w, 1.0 - 0.5 / w);
  float atlasW = w * res;
  vec4 a = texture(uf_ap, vec2((z0 * w + sx * w) / atlasW, screenUv.y));
  vec4 b = texture(uf_ap, vec2((z1 * w + sx * w) / atlasW, screenUv.y));
  vec4 ap = mix(a, b, fz);
  ap.rgb *= weight;
  ap.a = 1.0 - (weight * (1.0 - ap.a));
  return ap;
}

void main() {
  float d = texture(u_depth, v_uv).r;
  vec4 far4 = u_inv_vp * vec4(v_uv * 2.0 - 1.0, DEPTH_FAR_POINT, 1.0);
  vec3 dir = normalize(far4.xyz / far4.w - u_cam_pos);
  bool sky = d <= DEPTH_SKY;
  vec3 rel;
  if (sky) {
    rel = dir * uf_sky_dist;
  } else {
    vec4 h4 = u_inv_vp * vec4(v_uv * 2.0 - 1.0, depthClip(d), 1.0);
    rel = h4.xyz / h4.w - u_cam_pos;
  }
  // CalculateHeightFog: with the volumetric fog on, the analytic fog starts where its range (along the view's z) ends
  float exclude = 0.0;
  if (uf_vol_on > 0.5) {
    float cosAngle = dot(normalize(rel), uf_fwd);
    exclude = uf_vol_dist * (cosAngle > 1.0e-7 ? 1.0 / cosAngle : 0.0);
  }
  vec4 fog = ufHeightFog(rel, u_cam_pos, exclude);
  if (!sky && uf_ap_on > 0.5) {
    vec4 ap = ufAerialPerspective(v_uv, length(rel) * 0.001);
    fog = vec4(fog.rgb + ap.rgb * fog.a, fog.a * ap.a);
  }
  // CombineVolumetricFog: the integrated grid at the pixel's view depth, over the analytic fog
  if (uf_vol_on > 0.5) {
    float sceneDepth = max(dot(rel, uf_fwd), 0.0001);
    float zs = log2(sceneDepth * uf_vol_zp.x + uf_vol_zp.y) * uf_vol_zp.z / uf_vol_grid.z;
    vec2 guv = v_uv * uf_vol_uv;
    float zz = clamp(zs * uf_vol_grid.z - 0.5, 0.0, uf_vol_grid.z - 1.0);
    float z0 = floor(zz);
    float z1 = min(z0 + 1.0, uf_vol_grid.z - 1.0);
    vec4 vol = mix(texture(uf_vol, vec3(guv, z0)), texture(uf_vol, vec3(guv, z1)), zz - z0);
    if (uf_vol_debug > 0.5) {
      // the cell just in front of the surface (Unreal's samples are pulled onto it), the scene replaced
      float zd = clamp(floor(zs * uf_vol_grid.z) - 0.5, 0.0, uf_vol_grid.z - 1.0);
      o_color = vec4(texture(uf_vol, vec3(guv, zd)).rgb, 0.0);
      return;
    }
    fog = vec4(vol.rgb + fog.rgb * vol.a, vol.a * fog.a);
  }
  o_color = vec4(sane(fog.rgb), clamp(fog.a, 0.0, 1.0));
}
