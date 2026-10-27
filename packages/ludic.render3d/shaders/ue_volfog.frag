// Unreal's volumetric fog, ported from UE 5.8 VolumetricFog.usf: MaterialSetupCS (the height fog's media in the froxel grid),
// LightScatteringCS (the sun with its shadows, the sky light, the phase function, temporal reprojection of last frame's grid) and
// FinalIntegrationCS (front-to-back, energy conserving). The grid is the view's tiles of GridPixelSize by GridSizeZ slices over
// VolumetricFogDistance, sliced as CalculateGridZParams (slice = log2(depth * B + O) * S). The GPU layer has no 3D render targets,
// so the grid is a 2D array with a layer a slice, drawn one slice at a time; VF_SCATTER does setup and scattering in one pass,
// VF_INTEGRATE writes slice z by integrating slices 0..z. Metres; Unreal's z up is our y.
// Not ported: local lights (none of ours are general lights yet), light functions, the conservative depth test and its history
// fix-up (FixupHistoryUV), super-sampling on a history miss (HistoryMissSuperSampleCount), local fog volumes, Lumen GI.
in vec2 v_uv;
out vec4 o_color;
uniform vec3 vf_grid;              // ViewGridSize: tiles across, down, slices
uniform vec3 vf_zp;                // GridZParams: B, O, S
uniform float vf_slice;            // the slice being drawn
uniform mat4 vf_inv_vp;            // the clean view-projection's inverse
uniform vec3 vf_cam;               // the camera
uniform vec3 vf_fwd;               // its forward
uniform vec2 vf_screen;            // the view's size in pixels
uniform float vf_pixel;            // GridPixelSize
const float VF_PI = 3.14159265358979;

float vfDepthFromSlice(float z) { return (exp2(z / vf_zp.z) - vf_zp.y) / vf_zp.x; }
float vfSliceFromDepth(float d) { return log2(d * vf_zp.x + vf_zp.y) * vf_zp.z; }
// ComputeCellTranslatedWorldPosition: the cell's screen point at the slice's view depth. The grid spans GridPixelSize x tiles,
// which can run past the view's edge (as Unreal's does); uv over the view.
vec3 vfCellPos(vec3 coord, vec3 offset, out float sceneDepth) {
  vec2 uv = (coord.xy + offset.xy) * vf_pixel / vf_screen;
  sceneDepth = vfDepthFromSlice(max(coord.z + offset.z, 0.0));
  vec4 far4 = vf_inv_vp * vec4(uv * 2.0 - 1.0, DEPTH_FAR_POINT, 1.0);
  vec3 dir = normalize(far4.xyz / far4.w - vf_cam);
  return vf_cam + dir * (sceneDepth / max(dot(dir, vf_fwd), 0.0001));
}

#ifdef VF_SCATTER
uniform sampler2D u_depth;          // the scene's depth (ApplyDepthConstraintsToOffset)
uniform mat4 vf_vp;                 // the clean view-projection
uniform sampler2DArray vf_hist;     // last frame's scattering and extinction grid
uniform mat4 vf_prev_vp;            // last frame's clean view-projection
uniform float vf_hist_on;           // a history worth reading (and r.VolumetricFog.TemporalReprojection)
uniform float vf_hist_weight;       // r.VolumetricFog.HistoryWeight
uniform vec3 vf_jitter;             // FrameJitterOffsets[0]: Halton (2, 3, 5) of the frame, or the centre
uniform vec4 vf_fog;                // the height fog: density (1/m), falloff (1/m), height, MatchHeightFogFactor x ExtinctionScale
uniform vec4 vf_fog2;               // the second fog: density, falloff, height
uniform vec3 vf_albedo;             // VolumetricFogAlbedo
uniform vec3 vf_emissive;           // VolumetricFogEmissive x 1/10000
uniform float vf_g;                 // VolumetricFogScatteringDistribution
uniform vec3 vf_sun_color;          // the sun's light (its illuminance) x its VolumetricScatteringIntensity
uniform vec3 vf_sun_dir;            // toward the sun
uniform float vf_sky_on;            // the sky light's SH is bound (u_irradiance) and SkyLightVolumetricScatteringIntensity
uniform vec3 vf_sky_color;          // SkyLightColor x SkyLightVolumetricScatteringIntensity
uniform float vf_center_offset;     // r.VolumetricFog.GridCenterOffsetFromDepthBuffer
uniform float vf_center_threshold;  // r.VolumetricFog.OffsetThresholdToAcceptDepthBufferOffset

// HenyeyGreensteinPhase (ParticipatingMediaCommon.ush): 1 + g^2 + 2 g cos
float vfPhase(float g, float c) {
  float denom = 1.0 + g * g + 2.0 * g * c;
  return (1.0 - g * g) / (4.0 * VF_PI * denom * sqrt(denom));
}
// ApplyDepthConstraintsToOffset: pull a sample just behind the depth buffer forward onto it
void vfDepthConstraint(vec3 coord, inout vec3 off) {
  if (vf_center_offset < 0.0) return;
  float unused;
  vec3 p = vfCellPos(coord, off, unused);
  vec4 c = vf_vp * vec4(p, 1.0);
  vec2 suv = c.xy / c.w * 0.5 + 0.5;
  float d = texture(u_depth, clamp(suv, 0.0, 1.0)).r;
  float sceneDepth = 1.0e7;
  if (d > DEPTH_SKY) {
    vec4 h4 = vf_inv_vp * vec4(suv * 2.0 - 1.0, depthClip(d), 1.0);
    sceneDepth = dot(h4.xyz / h4.w - vf_cam, vf_fwd);
  }
  float depthSlice = vfSliceFromDepth(max(sceneDepth, 0.0001)) - vf_center_offset;
  float delta = depthSlice - (coord.z + off.z);
  if (delta < 0.0 && -delta < vf_center_threshold) off.z += delta;
}
// the sun's shadow in mid-air (volumetric.frag volShadow: the cascades, the height-field shadow and the cloud mask)
float vfShadow(vec3 wpos, float viewDepth) {
  int c = CASCADES - 1;
  for (int i = 0; i < CASCADES - 1; i++) { if (viewDepth < u_cascade_split[i]) { c = i; break; } }
  vec4 lp = u_cascade_vp[c] * vec4(wpos, 1.0);
  vec3 p = vec3(lp.xy / lp.w * 0.5 + 0.5, lp.z / lp.w);
  float s = 1.0;
  if (p.x >= 0.0 && p.x <= 1.0 && p.y >= 0.0 && p.y <= 1.0 && p.z >= 0.0) s = shadowTap(p.xy, c, p.z + 0.0016);
  return min(s, terrainShadow(wpos)) * cloudShadow(wpos);
}
// GetSkySHDiffuseSimple: bands 0 and 1 of the sky light's SH, Unreal's frame
vec3 vfSkySHSimple(vec3 nOurs) {
  vec4 nv = vec4(nOurs.x, nOurs.z, nOurs.y, 1.0);
  return max(vec3(0.0), vec3(dot(texelFetch(u_irradiance, ivec2(0, 0), 0), nv), dot(texelFetch(u_irradiance, ivec2(1, 0), 0), nv), dot(texelFetch(u_irradiance, ivec2(2, 0), 0), nv)));
}
#endif

#ifdef VF_INTEGRATE
uniform sampler2DArray vf_scatter;  // this frame's scattering and extinction grid
uniform float vf_fade_inv;          // VolumetricFogNearFadeInDistanceInv
#endif

void main() {
  // the cell: v_uv spans the grid target, the same uv the fog pass samples it with
  vec3 coord = vec3(floor(v_uv * vf_grid.xy), vf_slice);
#ifdef VF_SCATTER
  // MaterialSetupCS at the cell's centre
  vec3 mOff = vec3(0.5);
  vfDepthConstraint(coord, mOff);
  float unusedDepth;
  vec3 mPos = vfCellPos(coord, mOff, unusedDepth);
  float density = vf_fog.x * exp2(-vf_fog.y * (mPos.y - vf_fog.z)) + vf_fog2.x * exp2(-vf_fog2.y * (mPos.y - vf_fog2.z));
  float extinction = max(density * vf_fog.w, 0.0);
  vec3 scattering = vf_albedo * extinction;
  // LightScatteringCS: the sample jittered within the cell
  vec3 off = vf_jitter;
  vfDepthConstraint(coord, off);
  float sceneDepth;
  vec3 pos = vfCellPos(coord, off, sceneDepth);
  vec3 camVec = normalize(pos - vf_cam);
  vec3 L = vec3(0.0);
  {
    vec4 lzAmb;
    float shadow = vfShadow(pos, sceneDepth) * (1.0 - lightZone(pos, lzAmb));     // no sun inside a light zone (tunnels)
    L += vf_sun_color * shadow * vfPhase(vf_g, dot(vf_sun_dir, -camVec));
  }
  if (vf_sky_on > 0.5) L += vf_sky_color * vfSkySHSimple(camVec * -vf_g);
  vec4 cur = vec4(L * scattering + vf_emissive, extinction);
  // temporal reprojection of the cell's centre into last frame's grid
  float histAlpha = 0.0;
  vec4 hist = vec4(0.0);
  if (vf_hist_on > 0.5) {
    float unused2;
    vec3 c0 = vfCellPos(coord, vec3(0.5), unused2);
    vec4 pc = vf_prev_vp * vec4(c0, 1.0);
    vec2 puv = pc.xy / pc.w * 0.5 + 0.5;
    vec2 guv = puv * vf_screen / (vf_grid.xy * vf_pixel);
    float pz = vfSliceFromDepth(max(pc.w, 0.0001)) / vf_grid.z;
    if (pc.w > 0.0 && all(greaterThanEqual(vec3(guv, pz), vec3(0.0))) && all(lessThan(vec3(guv, pz), vec3(1.0)))) {
      float zz = clamp(pz * vf_grid.z - 0.5, 0.0, vf_grid.z - 1.0);
      float z0 = floor(zz);
      float z1 = min(z0 + 1.0, vf_grid.z - 1.0);
      hist = mix(texture(vf_hist, vec3(guv, z0)), texture(vf_hist, vec3(guv, z1)), zz - z0);
      histAlpha = vf_hist_weight;
    }
  }
  o_color = max(mix(cur, hist, histAlpha), vec4(0.0));
#endif
#ifdef VF_INTEGRATE
  vec3 acc = vec3(0.0);
  float trans = 1.0;
  float unused3;
  vec3 prevPos = vfCellPos(vec3(coord.xy, 0.0), vec3(0.5, 0.5, 0.0), unused3);
  float accDepth = 0.0;
  for (int k = 0; k < 128; k++) {
    if (float(k) > vf_slice) break;
    vec4 se = texelFetch(vf_scatter, ivec3(ivec2(gl_FragCoord.xy), k), 0);    // this fragment's own texel in slice k
    vec3 lp = vfCellPos(vec3(coord.xy, float(k)), vec3(0.5), unused3);
    float stepLen = length(lp - prevPos);
    prevPos = lp;
    float t = exp(-se.w * stepLen);
    accDepth += stepLen;
    float fade = clamp(accDepth * vf_fade_inv, 0.0, 1.0);
    acc += fade * (se.rgb - se.rgb * t) / max(se.w, 0.00001) * trans;   // ENERGY_CONSERVING_INTEGRATION
    trans *= mix(1.0, t, fade);
  }
  o_color = vec4(acc, trans);
#endif
}
