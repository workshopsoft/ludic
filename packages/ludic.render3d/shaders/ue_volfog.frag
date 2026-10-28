// Unreal's volumetric fog, ported from UE 5.8 VolumetricFog.usf: MaterialSetupCS (the height fog's media in the froxel grid),
// LightScatteringCS (the sun with its shadows, the sky light, the phase function, temporal reprojection of last frame's grid) and
// FinalIntegrationCS (front-to-back, energy conserving). The grid is the view's tiles of GridPixelSize by GridSizeZ slices over
// VolumetricFogDistance, sliced as CalculateGridZParams (slice = log2(depth * B + O) * S). The GPU layer has no 3D render targets,
// so the grid is a 2D array with a layer a slice, drawn one slice at a time; VF_SCATTER does setup and scattering in one pass,
// VF_INTEGRATE writes slice z by integrating slices 0..z; with VF_CARRY it is FinalIntegrationCS's march itself, the running sum
// carried from slice to slice in a second target (vf_carry, last slice's) rather than in a thread's registers.
// VF_ATLAS lays the grid out as one 2D texture instead, the slices as tiles of vf_tiles.x across (slice z at tile (z % x, z / x)), so
// the scatter and the integration are a pass each over the whole grid, as Unreal's compute dispatches are, rather than a pass a
// slice (a render pass each on a tiled GPU, which the per-slice draws spent most of their time on); reads clamp to the tile's edge. Metres; Unreal's z up is our y.
// VF_CDEPTH is GenerateConservativeDepthBufferCS (GenerateConservativeDepth.usf): a texel a tile, the furthest depth under the tile
// widened by half a tile (ComputeFroxelCullRect's FootprintMargin 0.5), read from the depth buffer itself rather than the HZB; kept as
// view depth (m). With it (r.VolumetricFog.ConservativeDepth 1) VF_SCATTER skips a cell wholly behind it and FixupHistoryUV steers the
// history read off cells last frame's skipped.
// Not ported: local lights' shadows (ue_lights.ludic lights are unshadowed so far), light functions, super-sampling on a history miss
// (HistoryMissSuperSampleCount), local fog volumes, Lumen GI.
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
uniform vec2 vf_tiles;             // VF_ATLAS: the tiles across and down
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

#ifdef VF_CDEPTH
uniform sampler2D u_depth;          // the scene's depth, or (vf_cd_down 4) its 4 x 4 furthest (VF_CDEPTH_DOWN)
uniform float vf_cd_down;           // u_depth's texels to a pixel's: 1 or 4
#endif
#ifdef VF_CDEPTH_DOWN
uniform sampler2D u_depth;          // the scene's depth
#endif

#ifdef VF_ATLAS
vec2 vfAtlasTile(float z) { z = floor(z + 0.5);  return vec2(mod(z, vf_tiles.x), floor(z / vf_tiles.x)); }
// a bilinear read of slice z at the grid's uv, clamped to the tile's edge as an array layer's read is to its own
vec4 vfAtlasRead(sampler2D t, vec2 guv, float z) {
  vec2 cell = clamp(guv * vf_grid.xy, vec2(0.5), vf_grid.xy - 0.5);
  return texture(t, (vfAtlasTile(z) * vf_grid.xy + cell) / (vf_tiles * vf_grid.xy));
}
ivec2 vfAtlasTexel(ivec2 cell, int z) { return ivec2(z % int(vf_tiles.x), z / int(vf_tiles.x)) * ivec2(vf_grid.xy) + cell; }
#endif

#ifdef VF_SCATTER
uniform sampler2D u_depth;          // the scene's depth (ApplyDepthConstraintsToOffset)
uniform sampler2D vf_cdepth;        // this frame's conservative depth (VF_CDEPTH), view depth
uniform sampler2D vf_prev_cdepth;   // last frame's
uniform vec2 vf_cd_on;              // x: r.VolumetricFog.ConservativeDepth, y: last frame's is there too
uniform mat4 vf_vp;                 // the clean view-projection
#ifdef VF_ATLAS
uniform sampler2D vf_hist;          // last frame's scattering and extinction grid
#else
uniform sampler2DArray vf_hist;     // last frame's scattering and extinction grid
#endif
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
uniform float vf_debug;             // R3D_UE_VOLFOG_DEBUG: 1 stores the sun's shadow factor alone (no history)

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

#ifdef VF_SCATTER
// FixupHistoryUV: of the four history texels a bilinear read would mix, keep those last frame computed (their conservative depth
// beyond the cell), else the read is no history at all
vec2 vfFixupHistoryUV(vec2 uv, vec2 size, float prevCellDepth, out bool valid) {
  vec2 full = uv * size;
  vec2 sc = floor(full - 0.5);
  vec2 gatherUV = (sc + 1.0) / size;
  vec2 off = full - sc;
  bvec4 ok = greaterThan(textureGather(vf_prev_cdepth, gatherUV, 0), vec4(prevCellDepth));
  valid = true;
  if (all(ok)) return uv;
  // the gather's order: w z on the row of the lower v, x y on the higher
  if (ok.w && ok.z) return (sc + vec2(off.x, 0.5)) / size;
  if (ok.x && ok.y) return (sc + vec2(off.x, 1.5)) / size;
  if (ok.w && ok.x) return (sc + vec2(0.5, off.y)) / size;
  if (ok.z && ok.y) return (sc + vec2(1.5, off.y)) / size;
  if (ok.x) return (sc + vec2(0.5, 1.5)) / size;
  if (ok.y) return (sc + vec2(1.5, 1.5)) / size;
  if (ok.w) return (sc + vec2(0.5, 0.5)) / size;
  if (ok.z) return (sc + vec2(1.5, 0.5)) / size;
  valid = false;
  return uv;
}
#endif

#ifdef VF_INTEGRATE
#ifdef VF_ATLAS
uniform sampler2D vf_scatter;       // this frame's scattering and extinction grid
#else
uniform sampler2DArray vf_scatter;  // this frame's scattering and extinction grid
#endif
uniform float vf_fade_inv;          // VolumetricFogNearFadeInDistanceInv
#ifdef VF_CARRY
uniform sampler2D vf_carry;         // the integration through the slice before (VF_CARRY): in-scattering, transmittance
layout(location = 1) out vec4 o_carry;
#endif
#endif

void main() {
#ifdef VF_CDEPTH_DOWN
  // the furthest (reversed z: the least) of the 4 x 4 pixels under this texel, an HZB level of 4 for VF_CDEPTH
  ivec2 dhi = textureSize(u_depth, 0) - 1;
  ivec2 d0 = ivec2(gl_FragCoord.xy) * 4;
  float dm = 1.0;
  for (int y = 0; y < 4; y++)
    for (int x = 0; x < 4; x++) dm = min(dm, texelFetch(u_depth, min(d0 + ivec2(x, y), dhi), 0).r);
  o_color = vec4(dm, 0.0, 0.0, 1.0);
  return;
#endif
#ifdef VF_CDEPTH
  // the tile's pixels widened by half a tile, the furthest depth among them (reversed z: the least), as view depth
  ivec2 hi = textureSize(u_depth, 0) - 1;
  ivec2 t = ivec2(gl_FragCoord.xy);
  int px = int(vf_pixel);
  int dn = int(vf_cd_down);
  ivec2 lo = clamp((t * px - px / 2) / dn, ivec2(0), hi);
  ivec2 up = clamp(((t + 1) * px + px / 2 - 1) / dn, ivec2(0), hi);
  float dmin = 1.0;
  for (int y = lo.y; y <= up.y; y++)
    for (int x = lo.x; x <= up.x; x++) dmin = min(dmin, texelFetch(u_depth, ivec2(x, y), 0).r);
  float far = 1.0e7;
  if (dmin > DEPTH_SKY) {
    vec2 suv = (vec2(t) + 0.5) * vf_pixel / vf_screen;
    vec4 h4 = vf_inv_vp * vec4(suv * 2.0 - 1.0, depthClip(dmin), 1.0);
    far = dot(h4.xyz / h4.w - vf_cam, vf_fwd);
  }
  o_color = vec4(far, 0.0, 0.0, 1.0);
  return;
#endif
#ifdef VF_ATLAS
  // the cell: this texel's tile is its slice, its place in the tile its tile of the view (v_uv spans the atlas; a fragment stage
  // that reads no input fails MoltenVK's pipeline build)
  ivec2 fc = ivec2(floor(v_uv * vf_tiles * vf_grid.xy));
  ivec2 gi = ivec2(vf_grid.xy);
  ivec2 tl = fc / gi;
  int zi = tl.y * int(vf_tiles.x) + tl.x;
  if (zi >= int(vf_grid.z)) { o_color = vec4(0.0);  return; }
  ivec2 cellI = fc - tl * gi;
  vec3 coord = vec3(vec2(cellI), float(zi));
#else
  // the cell: v_uv spans the grid target, the same uv the fog pass samples it with
  vec3 coord = vec3(floor(v_uv * vf_grid.xy), vf_slice);
  ivec2 cellI = ivec2(gl_FragCoord.xy);
#endif
  float slice = coord.z;
#ifdef VF_SCATTER
  // the cell wholly behind the tile's furthest depth (its near face, FarDepthOffset z -0.5): no light, no media
  if (vf_cd_on.x > 0.5 && texelFetch(vf_cdepth, ivec2(coord.xy), 0).r < vfDepthFromSlice(max(coord.z - 0.5, 0.0))) {
    o_color = vec4(0.0);
    return;
  }
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
  vec4 lzAmb;
  float shadow = vfShadow(pos, sceneDepth) * (1.0 - lightZone(pos, lzAmb));       // no sun inside a light zone (tunnels)
  if (vf_debug > 0.5) { o_color = vec4(vec3(shadow), 1.0);  return; }
  L += vf_sun_color * shadow * vfPhase(vf_g, dot(vf_sun_dir, -camVec));
  if (vf_sky_on > 0.5) L += vf_sky_color * vfSkySHSimple(camVec * -vf_g);
  // the local lights (ue_lights.ludic): DistanceBiasSqr = max(CellRadius x InverseSquaredLightDistanceBiasScale (1), 1 cm)^2
  if (u_ll_n > 0) {
    float unusedR;
    float cellRadius = length(pos - vfCellPos(coord + vec3(1.0), off, unusedR));
    float bias = max(cellRadius, 0.01);
    bias *= bias;
    int start;
    bool direct;
    int count = ueLightGridRange(pos, start, direct);
    for (int k = 0; k < count; k++) {
      int i = ueLightGridLight(start, k, direct);
      float vsi = llMisc(i).w;
      if (vsi <= 0.0) continue;
      vec3 Ll;
      float att = ueLocalLightAttenuation(i, pos, bias, Ll);
      float si = llShadow(i);
      if (att > 0.0 && u_ue_ls_n > 0 && si >= 0.0) att *= ueSpotShadowVolume(int(si), pos);
      else if (att > 0.0 && u_ue_lp_n > 0 && si < -1.5) att *= uePointShadowVolume(int(-si - 2.0 + 0.5), i, pos);
      if (att > 0.0) L += llCol(i).rgb * (vfPhase(vf_g, dot(Ll, -camVec)) * att * vsi);
    }
  }
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
    bool valid = true;
    if (vf_cd_on.y > 0.5) guv = vfFixupHistoryUV(guv, vf_grid.xy, pc.w, valid);
    if (valid && pc.w > 0.0 && all(greaterThanEqual(vec3(guv, pz), vec3(0.0))) && all(lessThan(vec3(guv, pz), vec3(1.0)))) {
      float zz = clamp(pz * vf_grid.z - 0.5, 0.0, vf_grid.z - 1.0);
      float z0 = floor(zz);
      float z1 = min(z0 + 1.0, vf_grid.z - 1.0);
#ifdef VF_ATLAS
      hist = mix(vfAtlasRead(vf_hist, guv, z0), vfAtlasRead(vf_hist, guv, z1), zz - z0);
#else
      hist = mix(texture(vf_hist, vec3(guv, z0)), texture(vf_hist, vec3(guv, z1)), zz - z0);
#endif
      histAlpha = vf_hist_weight;
    }
  }
  o_color = max(mix(cur, hist, histAlpha), vec4(0.0));
#endif
#ifdef VF_INTEGRATE
  vec3 acc = vec3(0.0);
  float trans = 1.0;
  float unused3;
  // the cells' centres lie on the one ray from the camera, so a step's length is its depth step over the ray's cosine
  vec3 p0 = vfCellPos(vec3(coord.xy, 0.0), vec3(0.5, 0.5, 0.0), unused3);
  float invCos = 1.0 / max(dot(normalize(p0 - vf_cam), vf_fwd), 0.0001);
  float prevDepth = vfDepthFromSlice(0.0);
  float accDepth = 0.0;
#ifdef VF_CARRY
  // one step of the march: the slice before's sum (none before slice 0), this slice's cell added
  vec4 prev = vec4(0.0, 0.0, 0.0, 1.0);
  float d0 = prevDepth;
  if (slice > 0.5) { prev = texelFetch(vf_carry, cellI, 0);  prevDepth = vfDepthFromSlice(slice - 0.5); }
  vec4 se = texelFetch(vf_scatter, ivec3(cellI, int(slice)), 0);
  float d = vfDepthFromSlice(slice + 0.5);
  float stepLen = (d - prevDepth) * invCos;
  float t = exp(-se.w * stepLen);
  float fade = clamp((d - d0) * invCos * vf_fade_inv, 0.0, 1.0);
  acc = prev.rgb + fade * (se.rgb - se.rgb * t) / max(se.w, 0.00001) * prev.a;   // ENERGY_CONSERVING_INTEGRATION
  trans = prev.a * mix(1.0, t, fade);
  o_carry = vec4(acc, trans);
#else
  for (int k = 0; k < 128; k++) {
    if (float(k) > slice) break;
#ifdef VF_ATLAS
    vec4 se = texelFetch(vf_scatter, vfAtlasTexel(cellI, k), 0);              // this cell in slice k
#else
    vec4 se = texelFetch(vf_scatter, ivec3(cellI, k), 0);                     // this fragment's own texel in slice k
#endif
    float d = vfDepthFromSlice(float(k) + 0.5);
    float stepLen = (d - prevDepth) * invCos;
    prevDepth = d;
    float t = exp(-se.w * stepLen);
    accDepth += stepLen;
    float fade = clamp(accDepth * vf_fade_inv, 0.0, 1.0);
    acc += fade * (se.rgb - se.rgb * t) / max(se.w, 0.00001) * trans;   // ENERGY_CONSERVING_INTEGRATION
    trans *= mix(1.0, t, fade);
  }
#endif
  o_color = vec4(acc, trans);
#endif
}
