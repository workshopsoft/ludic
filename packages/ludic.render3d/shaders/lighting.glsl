// ---- PBR + IBL + cascaded shadows + aerial perspective (shared) ---------------------
uniform sampler2D u_irradiance;          // equirect, diffuse-convolved sky
uniform sampler2DArray u_prefilter;      // equirect, GGX-prefiltered sky per roughness level
uniform sampler2D u_brdf;                // split-sum BRDF LUT
#define CASCADES 5
uniform sampler2DArrayShadow u_shadow;   // CASCADES layers
float shadowTap(vec2 uv, int c, float ref) { return texture(u_shadow, vec4(uv, float(c), ref)); }
// Depth is REVERSED everywhere (fmath.ludic): clip z runs 0 .. w, the buffer holds 1 at the near plane and 0 at the far
// one (infinity for the camera), cleared to 0, nearer is GREATER. A depth read back is clip z as it is; the sky's 0 is
// raised to a hair above so an inverse projection gives a point very far off rather than a division by zero.
float depthClip(float d) { return max(d, 1e-9); }
const float DEPTH_SKY = 0.0;          // what the cleared buffer holds where nothing was drawn
const float DEPTH_FAR_POINT = 1e-6;   // a clip z for a point far down a pixel's ray (50 km from a 5 cm near plane)
uniform mat4 u_cascade_vp[CASCADES];
uniform float u_cascade_split[CASCADES];  // view-space far distance of each cascade
uniform float u_cascade_range[CASCADES];  // light-frustum depth extent of each cascade (m)
uniform float u_cascade_texel[CASCADES];  // shadow texel size of each cascade (m)
uniform vec3 u_sun_dir;                  // toward the sun
uniform vec3 u_sun_color;                // radiance
uniform vec3 u_cam_pos;
uniform float u_prefilter_levels;
uniform float u_fog_density;
uniform float u_fog_height_falloff;
uniform float u_fog_base;          // the height the fog's density is measured from (0 = the world's y = 0)
uniform float u_clip_y;          // planar-reflection pass: discard everything below this height
uniform float u_spec_scale;      // 1 for surfaces; foliage crowns get a fraction: needles are
                                 // tiny rough cylinders, not sheets, and a crown of card quads
                                 // seen at grazing angles otherwise mirrors the sky and frosts

const float PI = 3.14159265359;
// never let a NaN or an infinity reach the frame: it would smear through the bloom pyramid
vec3 sane(vec3 c) { return (any(isnan(c)) || any(isinf(c))) ? vec3(0.0) : c; }

vec2 equirectUV(vec3 d) {
  return vec2(atan(d.x, -d.z) / (2.0 * PI) + 0.5, acos(clamp(d.y, -1.0, 1.0)) / PI);
}
// the HDRI itself is read through a yaw rotation (u_sky_rot = sin, cos), so the sun can be
// placed where the scene wants it; the convolved maps are built through the same rotation
uniform vec2 u_sky_rot;
vec2 skyUV(vec3 d) {
  vec3 r = vec3(u_sky_rot.y * d.x + u_sky_rot.x * d.z, d.y, -u_sky_rot.x * d.x + u_sky_rot.y * d.z);
  return equirectUV(r);
}
// The HDRI is a pure sky: below the horizon it is a flat bright grey, not ground. Anything
// whose normal points down — the underside of a needle card, the lower half of a crown —
// was lighting itself from that grey and came out white. Below the horizon the light is
// what the ground reflects: the horizon sky times a meadow albedo.
// What the ground under a surface reflects back up at it. It was one green constant for the
// whole world, which is right in a meadow, wrong on scree, and wrong under a cliff - and on a
// map that is not this one it is wrong everywhere. The colours are the map's now, and they
// cross over at its treeline, so a boulder's underside up in the talus is filled with grey
// rock light and one down by the lake is filled with green.
// (Sampling the terrain's own albedo would be better still and wants a texture bound to every
// program; that is phase 60's, where the terrain materials are being reworked anyway.)
uniform vec3 u_ground_alb;       // the low ground: meadow and forest
uniform vec3 u_ground_alb_hi;    // above the treeline: rock, scree, snow
uniform float u_ground_hi_y;     // the height they cross at (world units)
uniform float u_ground_hi_w;     // over how many metres
// How much of the ground's hue a surface takes from below: 0 the map's ground as it is, 1 its grey of the same brightness. A program
// that draws built things sets it before it lights (kit.frag: a cornice's, a canopy's or a balcony's underside stands over paving, not
// the meadow the map's ground colour is, and came out green); the light from below keeps its strength, only its hue goes.
float g_ground_grey = 0.0;
vec3 groundTone(vec3 a) { return mix(a, vec3(dot(a, vec3(0.2126, 0.7152, 0.0722))), g_ground_grey); }
vec3 groundAlbAt(float y) {
  return groundTone(mix(u_ground_alb, u_ground_alb_hi, smoothstep(u_ground_hi_y, u_ground_hi_y + u_ground_hi_w, y)));
}
// the time of day (daylight.ludic): the sky's light scaled toward night, and the campfire
uniform vec3 u_ibl_scale;
uniform float u_daylight;
uniform vec3 u_fire_pos;
uniform vec3 u_fire_color;
uniform vec3 u_hand_pos;          // a torch or flashlight in the hand
uniform vec3 u_hand_color;
uniform vec3 u_hand_dir;
uniform float u_hand_cone;        // cos of the half-angle; <= -1: a point light
uniform float u_hand_reach;       // metres to where it dies out entirely
// ---- Unreal's real-time sky light (u_ue_sl, ue_skylight.ludic): u_irradiance holds the packed SH (7x1, OutIrradianceEnvMapSH)
// and u_prefilter the GGX-filtered cube as an atlas (6 faces x u_ue_sl_mips layers, mip m in the top-left (size >> m)^2), Unreal's
// frame (x, z, y). UE 5.8 ReflectionEnvironmentShared.ush GetSkySHDiffuse and GetSkyLightReflection, times SkyLightColor; no ground
// term and no u_ibl_scale (the captured sky darkens by itself), below the horizon what Unreal's capture has there (black).
uniform float u_ue_sl;
uniform float u_ue_sl_size;            // the cube's mip 0 size (CubemapResolution)
uniform float u_ue_sl_mips;            // its mip count
uniform vec3 u_ue_sl_color;            // SkyLightColor: LightColor x Intensity
vec3 ueSkySH(vec3 nOurs) {
  vec4 nv = vec4(nOurs.x, nOurs.z, nOurs.y, 1.0);
  vec3 i0 = vec3(dot(texelFetch(u_irradiance, ivec2(0, 0), 0), nv), dot(texelFetch(u_irradiance, ivec2(1, 0), 0), nv), dot(texelFetch(u_irradiance, ivec2(2, 0), 0), nv));
  vec4 vB = nv.xyzz * nv.yzzx;
  vec3 i1 = vec3(dot(texelFetch(u_irradiance, ivec2(3, 0), 0), vB), dot(texelFetch(u_irradiance, ivec2(4, 0), 0), vB), dot(texelFetch(u_irradiance, ivec2(5, 0), 0), vB));
  float vC = nv.x * nv.x - nv.y * nv.y;
  vec3 i2 = texelFetch(u_irradiance, ivec2(6, 0), 0).xyz * vC;
  return max(vec3(0.0), i0 + i1 + i2) * u_ue_sl_color;
}
vec3 ueCubeAtlasMip(vec3 dUe, float m) {
  vec3 a = abs(dUe);
  vec2 sc;
  float face;
  if (a.x >= a.y && a.x >= a.z) { if (dUe.x > 0.0) { sc = vec2(-dUe.z, -dUe.y) / a.x;  face = 0.0; } else { sc = vec2(dUe.z, -dUe.y) / a.x;  face = 1.0; } }
  else if (a.y >= a.z) { if (dUe.y > 0.0) { sc = vec2(dUe.x, dUe.z) / a.y;  face = 2.0; } else { sc = vec2(dUe.x, -dUe.z) / a.y;  face = 3.0; } }
  else { if (dUe.z > 0.0) { sc = vec2(dUe.x, -dUe.y) / a.z;  face = 4.0; } else { sc = vec2(-dUe.x, -dUe.y) / a.z;  face = 5.0; } }
  float res = max(u_ue_sl_size / exp2(m), 1.0);
  vec2 uv = clamp((sc * 0.5 + 0.5) * res, vec2(0.5), vec2(res - 0.5)) / u_ue_sl_size;
  return texture(u_prefilter, vec3(uv, m * 6.0 + face)).rgb;
}
vec3 ueSkyReflection(vec3 rOurs, float rough) {
  vec3 d = vec3(rOurs.x, rOurs.z, rOurs.y);
  // ComputeReflectionCaptureMipFromRoughness(Roughness, SkyLightParameters.x = mips - 1)
  float maxMip = u_ue_sl_mips - 1.0;
  float levelFrom1x1 = 1.0 - 1.2 * log2(max(rough, 0.001));
  float m = clamp(maxMip - 1.0 - levelFrom1x1, 0.0, maxMip);
  float m0 = floor(m);
  float m1 = min(m0 + 1.0, maxMip);
  return mix(ueCubeAtlasMip(d, m0), ueCubeAtlasMip(d, m1), m - m0) * u_ue_sl_color;
}
vec3 skyIrradianceRaw(vec3 n) {
  if (u_ue_sl > 0.5) return ueSkySH(n);
  return texture(u_irradiance, equirectUV(n)).rgb * u_ibl_scale;
}
// The ground's light is the scene's own ground (u_ground_alb, the low ground: what bounce reads too).
// A surface tilted down still sees (1 + n.y) / 2 of the sky, so the window never gives it less: cut to
// nothing by n.y = -0.25, every jaw, neck and hanging arm was lit by the ground alone and came out olive.
vec3 skyIrradiance(vec3 n) {
  if (u_ue_sl > 0.5) return ueSkySH(n);
  vec3 up = skyIrradianceRaw(vec3(n.x, max(n.y, 0.0), n.z));
  vec3 ground = skyIrradianceRaw(normalize(vec3(n.x, 0.15, n.z) + vec3(1e-4, 0.0, 0.0))) * groundTone(u_ground_alb);
  return mix(ground, up, max(smoothstep(-0.25, 0.2, n.y), clamp(0.5 + 0.5 * n.y, 0.0, 1.0)));
}
vec3 skyPrefilteredRaw(vec3 r, float rough) {
  if (u_ue_sl > 0.5) return ueSkyReflection(r, rough);
  float lv = rough * (u_prefilter_levels - 1.0);
  float l0 = floor(lv);
  float l1 = min(l0 + 1.0, u_prefilter_levels - 1.0);
  vec2 uv = equirectUV(r);
  return mix(texture(u_prefilter, vec3(uv, l0)).rgb, texture(u_prefilter, vec3(uv, l1)).rgb, lv - l0) * u_ibl_scale;
}
// the campfire: one warm point light, out by twelve metres
vec3 fireLight(vec3 wpos, vec3 n, vec3 albedo) {
  vec3 d = u_fire_pos - wpos;
  float r2 = max(dot(d, d), 0.04);
  vec3 l = d * inversesqrt(r2);
  float att = smoothstep(14.0, 5.0, sqrt(r2)) / (0.6 + r2);
  return albedo / PI * u_fire_color * max(dot(n, l), 0.0) * att;
}
vec3 handLight(vec3 wpos, vec3 n, vec3 albedo) {
  vec3 d = u_hand_pos - wpos;
  float r2 = max(dot(d, d), 0.04);
  vec3 l = d * inversesqrt(r2);
  // A torch is not a point source in free air, and lighting it as one made it useless.
  // The old curve was an inverse square windowed off between 26 and 6 metres: two per cent
  // of its own near field by ten metres out, so carrying fire at night lit your boots and
  // nothing else. This is a reach and a gentle power falloff instead - about nine tenths at
  // a metre, half at half the reach, a tenth at nine tenths of it, nothing past it - which
  // is a pool of light with a gradient in it rather than a hotspot with a cliff.
  float att = pow(max(1.0 - sqrt(r2) / max(u_hand_reach, 0.001), 0.0), 1.25);
  if (u_hand_cone > -1.0) {
    float c = dot(-l, u_hand_dir);
    att *= smoothstep(u_hand_cone, u_hand_cone + 0.12, c);
  }
  return albedo / PI * u_hand_color * max(dot(n, l), 0.0) * att;
}
vec3 skyPrefiltered(vec3 r, float rough) {
  if (u_ue_sl > 0.5) return ueSkyReflection(r, rough);
  vec3 up = skyPrefilteredRaw(vec3(r.x, max(r.y, 0.0), r.z), rough);
  vec3 ground = skyPrefilteredRaw(normalize(vec3(r.x, 0.15, r.z) + vec3(1e-4, 0.0, 0.0)), max(rough, 0.6)) * groundTone(u_ground_alb);
  return mix(ground, up, smoothstep(-0.2, 0.15, r.y));
}

float D_GGX(float NoH, float a) { float a2 = a * a; float d = NoH * NoH * (a2 - 1.0) + 1.0; return a2 / (PI * d * d); }
float V_Smith(float NoV, float NoL, float a) {
  float a2 = a * a;
  float gv = NoL * sqrt(NoV * NoV * (1.0 - a2) + a2);
  float gl = NoV * sqrt(NoL * NoL * (1.0 - a2) + a2);
  return 0.5 / max(gv + gl, 1e-4);
}
vec3 F_Schlick(float VoH, vec3 f0) { float f = pow(1.0 - VoH, 5.0); return f0 + (1.0 - f0) * f; }
vec3 F_SchlickRough(float NoV, vec3 f0, float rough) { return f0 + (max(vec3(1.0 - rough), f0) - f0) * pow(1.0 - NoV, 5.0); }

// interleaved-gradient noise for rotated PCF taps
float ign(vec2 p) { return fract(52.9829189 * fract(0.06711056 * p.x + 0.00583715 * p.y)); }

float cascadeRange(int c) { return u_cascade_range[c]; }
float cascadeTexel(int c) { return u_cascade_texel[c]; }

// biasWorld in metres; the receiver is pushed along its normal by a texel first
float shadowSample(int c, vec3 wpos, float biasWorld) {
  vec4 lp = u_cascade_vp[c] * vec4(wpos, 1.0);
  vec3 p = vec3(lp.xy / lp.w * 0.5 + 0.5, lp.z / lp.w);
  if (p.x < 0.0 || p.x > 1.0 || p.y < 0.0 || p.y > 1.0 || p.z < 0.0) return 1.0;
  float bias = biasWorld / cascadeRange(c);
  float texel = 1.0 / float(textureSize(u_shadow, 0).x);   // the shadow resolution setting
  float r = ign(gl_FragCoord.xy) * 6.2831853;
  float cs = cos(r), sn = sin(r);
  mat2 rot = mat2(cs, sn, -sn, cs);
  float s = 0.0;
  const vec2 taps[8] = vec2[8](vec2(-0.7071, 0.7071), vec2(-0.0, -0.875), vec2(0.5303, 0.5303), vec2(-0.625, -0.0),
                               vec2(0.3536, -0.3536), vec2(-0.0, 0.375), vec2(-0.1768, -0.1768), vec2(0.125, 0.0));
  // the far cascades' texels are metres wide: a wider filter turns their staircase into a penumbra
  float rad = texel * ((c >= 4) ? 2.6 : (c == 3) ? 2.0 : 1.5);
  for (int i = 0; i < 8; i++) {
    vec2 off = rot * taps[i] * rad;
    s += shadowTap(p.xy + off, c, p.z + bias);     // reversed: toward the sun is up
  }
  return s / 8.0;
}

// one cascade's lookup, with a normal offset and a slope-scaled depth bias
float shadowSlope(int c, vec3 wpos, vec3 n, float tanT) {
  float tx = cascadeTexel(c);
  float filt = (c >= 4) ? 2.6 : ((c == 3) ? 2.0 : 1.5);   // matches shadowSample's rad
  vec3 wp = wpos + n * tx * (2.5 + 1.5 * tanT);
  return shadowSample(c, wp, tx * (1.0 + filt * tanT) + 0.02);
}

// The baked height-field shadow (tershadow.frag): R = the lowest lit height over this
// ground texel, G = distance to the occluder that set it. Any receiver — ground, crown,
// card, water — compares its own height, so everything agrees on where the hill's
// shadow falls. The penumbra widens with the occluder's distance like a real one.
uniform sampler2D u_tershadow;      // R: the lowest lit height
uniform sampler2D u_tershadow_aux;  // R: the occluder distance, G: the cloud mask
uniform vec2 u_ts_origin;
uniform float u_ts_half;
uniform float u_ts_on;
uniform sampler2D u_ts_height;
// the ground's normal under a world position (4 m texels): cover standing on the ground
// is lit with this beyond a few tens of metres, so a hillside and the grass on it agree
vec3 terrainNormalAt(vec3 wpos) {
  vec2 uv = (wpos.xz - u_ts_origin) / (2.0 * u_ts_half) + 0.5;
  float step = 1.0 / float(textureSize(u_ts_height, 0).x);
  float world = step * 2.0 * u_ts_half;
  float hl = texture(u_ts_height, uv - vec2(step, 0)).r, hr = texture(u_ts_height, uv + vec2(step, 0)).r;
  float hd = texture(u_ts_height, uv - vec2(0, step)).r, hu = texture(u_ts_height, uv + vec2(0, step)).r;
  return normalize(vec3(hl - hr, 2.0 * world, hd - hu));
}
float terrainShadow(vec3 wpos) {
  if (u_ts_on < 0.5) return 1.0;
  vec2 uv = (wpos.xz - u_ts_origin) / (2.0 * u_ts_half) + 0.5;
  if (uv.x < 0.0 || uv.x > 1.0 || uv.y < 0.0 || uv.y > 1.0) return 1.0;
  vec2 s = vec2(texture(u_tershadow, uv).r, texture(u_tershadow_aux, uv).r);
  float w = 0.6 + 0.02 * s.y;
  return smoothstep(-w, w, wpos.y + 0.25 - s.x);
}

uniform int u_force_cascade;
// the far-field version: one hardware 2x2 tap in the cascade, no rotated disc, no blend
uniform float u_shadow_tan_max;     // a small caster's cap on the grazing push (actors: characters, cars); 0: the terrain's 10
float sunShadowCheap(vec3 wpos, vec3 n, float viewDepth) {
  int c = CASCADES - 1;
  for (int i = 0; i < CASCADES - 1; i++) { if (viewDepth < u_cascade_split[i]) { c = i; break; } }
  float tx = cascadeTexel(c);
  vec4 lp = u_cascade_vp[c] * vec4(wpos + n * tx * 2.5, 1.0);
  vec3 p = vec3(lp.xy / lp.w * 0.5 + 0.5, lp.z / lp.w);
  float s = 1.0;
  if (p.x >= 0.0 && p.x <= 1.0 && p.y >= 0.0 && p.y <= 1.0 && p.z >= 0.0) s = shadowTap(p.xy, c, p.z + (tx * 2.0 + 0.02) / cascadeRange(c));
  return min(s, terrainShadow(wpos));
}
float sunShadow(vec3 wpos, vec3 n, float viewDepth) {
  int c = CASCADES - 1;
  if (u_force_cascade >= 0) { float tx0 = cascadeTexel(u_force_cascade); return shadowSample(u_force_cascade, wpos + n * tx0 * 1.5, tx0 * 1.5 + 0.02); }
  for (int i = 0; i < CASCADES - 1; i++) { if (viewDepth < u_cascade_split[i]) { c = i; break; } }
  float NoL = max(dot(n, u_sun_dir), 0.0);
  // Depth across one shadow texel changes by texel * tan(theta) on a surface lit at
  // theta from its normal, and the PCF disc reaches `filt` texels out, so the bias must
  // cover the drop over the whole filter rather than a single texel. The old form used
  // (1 - NoL): at NoL = 0.2 that is 0.8 where tan(theta) is 4.9, six times short. With
  // the caster and receiver now the same mesh, that shortfall is what let the terrain
  // shadow itself along its own triangle edges — a faint grid over the whole slope.
  // (a small caster, a character or a car, takes a lower cap: on a torso's curve the terrain's 10 pushed the lookup a hand's
  // width out of the body at grazing light, where it read lit: rings of light on a shaded back)
  float tanT = min(sqrt(max(1.0 - NoL * NoL, 0.0)) / max(NoL, 0.05), (u_shadow_tan_max > 0.0) ? u_shadow_tan_max : 10.0);
  float s = shadowSlope(c, wpos, n, tanT);
  // blend across the cascade edge
  float edge = u_cascade_split[c];
  float f = smoothstep(edge * 0.85, edge, viewDepth);
  if (f > 0.0 && c < CASCADES - 1) {
    s = mix(s, shadowSlope(c + 1, wpos, n, tanT), f);
  }
  return min(s, terrainShadow(wpos));
}

// patchy sunlight: a cloud layer projected along the sun onto the ground
uniform float u_cloud_shadow;     // strength
uniform float u_time;
// the mask is baked beside the height-field shadow, in its aux texture's G (tershadow.frag); the
// projection along the sun and the drift are a uv shift
float cloudShadow(vec3 wpos) {
  if (u_cloud_shadow <= 0.0 || u_ts_on < 0.5) return 1.0;
  float h = 1400.0 - wpos.y;
  vec2 c = wpos.xz + u_sun_dir.xz / max(u_sun_dir.y, 0.1) * h;
  c += vec2(u_time * 3.0, u_time * 1.2);
  vec2 uv = (c - u_ts_origin) / (2.0 * u_ts_half) + 0.5;
  if (uv.x < 0.0 || uv.x > 1.0 || uv.y < 0.0 || uv.y > 1.0) return 1.0;
  return 1.0 - u_cloud_shadow * texture(u_tershadow_aux, uv).g;
}

// regional vegetation colour: aspen groves and drier ridges read lighter and yellower than
// the dark spruce and the lush hollows (a slow noise over the world, shaped by elevation)
vec3 regionTint(vec3 wpos, float strength) {
  float n = fbm(wpos.xz * 0.0018 + 4.0, 3) * 0.5 + 0.5;
  float aspen = smoothstep(0.52, 0.7, n) * smoothstep(520.0, 250.0, wpos.y);
  float dry = smoothstep(0.35, 0.15, fbm(wpos.xz * 0.004 + 9.0, 3) * 0.5 + 0.5);
  vec3 t = vec3(1.0);
  t = mix(t, vec3(1.25, 1.3, 0.85), aspen * strength);
  t = mix(t, vec3(1.15, 1.05, 0.7), dry * strength * 0.6);
  return t;
}

// Light zones (lightzone.ludic): boxes the sun does not reach (a tunnel). Each is 4 vec4s:
// (centre, end feather) (cos yaw, sin yaw, sky, grade) (half sizes, side feather) (ambient rgb, -). The weight is 0 outside
// the box, 1 deeper than the feathers inside (the end feather from its two faces along its depth, the side feather from
// the other four), smoothstep between; the box is sheared along its depth by its grade (a sloping tube's floor and roof);
// the strongest zone wins and lends its ambient and sky.
#define LZ_MAX 8
uniform vec4 u_lz[LZ_MAX * 4];
uniform int u_lz_n;
float lightZone(vec3 p, out vec4 amb) {
  float w = 0.0;
  amb = vec4(0.0, 0.0, 0.0, 1.0);
  for (int i = 0; i < LZ_MAX; i++) {
    if (i >= u_lz_n) break;
    vec4 a = u_lz[i * 4];
    vec4 b = u_lz[i * 4 + 1];
    vec4 c = u_lz[i * 4 + 2];
    vec3 d = p - a.xyz;
    vec3 l = vec3(b.x * d.x - b.y * d.z, d.y, b.y * d.x + b.x * d.z);
    l.y -= b.w * l.z;
    vec3 e = c.xyz - abs(l);
    float side = min(e.x, e.y);
    float wi = min((c.w > 0.0) ? smoothstep(0.0, c.w, side) : step(0.0, side), (a.w > 0.0) ? smoothstep(0.0, a.w, e.z) : step(0.0, e.z));
    if (wi > w) { w = wi; amb = vec4(u_lz[i * 4 + 3].rgb, b.z); }
  }
  return w;
}

// Zone lamps (zonelamp.ludic): point lights that light only inside a light zone (a tunnel's roof fixtures), the ZL_MAX
// nearest the camera, (x, y, z, fade) each. A windowed inverse square out to the reach, thrown mostly down (a fixture on a
// roof lights the road and the walls; the roof round it takes a share), diffuse only.
#define ZL_MAX 32
uniform vec4 u_zl[ZL_MAX];
uniform int u_zl_n;
uniform vec3 u_zl_color;
uniform float u_zl_reach;
vec3 zoneLamps(vec3 wpos, vec3 n, vec3 albedo) {
  vec3 s = vec3(0.0);
  float R2 = u_zl_reach * u_zl_reach;
  for (int i = 0; i < ZL_MAX; i++) {
    if (i >= u_zl_n) break;
    vec4 q = u_zl[i];
    vec3 d = q.xyz - wpos;
    float r2 = dot(d, d);
    if (r2 >= R2) continue;
    vec3 l = d * inversesqrt(max(r2, 1e-4));
    float win = 1.0 - r2 / R2;
    float att = win * win / (1.0 + 0.08 * r2);
    float down = mix(0.3, 1.0, smoothstep(-0.1, 0.4, l.y));
    s += max(dot(n, l), 0.0) * att * down * q.w;
  }
  return albedo / PI * u_zl_color * s;
}

// what is left of the sun at p: 1 outside every light zone, 0 deep inside one
float sunZone(vec3 p) { vec4 a; return 1.0 - lightZone(p, a); }

// the character light rig (charlight.ludic): this draw's weight of it and its three lights (toward each, world; radiance)
uniform float u_char_lit;
uniform vec3 u_cl_dir0;
uniform vec3 u_cl_dir1;
uniform vec3 u_cl_dir2;
uniform vec3 u_cl_col0;
uniform vec3 u_cl_col1;
uniform vec3 u_cl_col2;
vec3 clDir(int i) { return i == 0 ? u_cl_dir0 : (i == 1 ? u_cl_dir1 : u_cl_dir2); }
vec3 clCol(int i) { return i == 0 ? u_cl_col0 : (i == 1 ? u_cl_col1 : u_cl_col2); }

// a dielectric's reflectance at normal incidence: 0.04, Unreal's Specular 0.5 (0.08 x Specular). A material that keys its own
// specular sets it before shade() (the jeans: spec_basic_intensity times the weave; a MetaHuman's skin: model.frag)
float g_dielF0 = 0.04;

// A material's bent normal (Unreal's BentNormal custom output; a MetaHuman head's T_MH_BentNormal_AO, model.frag), set before shade():
// its world direction and the surface's base colour (the occlusion's multi-bounce is the base colour's, not the split's white)
bool g_bentOn = false;
vec3 g_bentW = vec3(0.0, 1.0, 0.0);
vec3 g_bentBase = vec3(0.0);

// SphericalGaussian.ush: G(v) = a exp(L (dot(u, v) - 1))
struct UeSG { vec3 axis; float sharp; float amp; };
float ueSgEval(UeSG g, vec3 d) { return g.amp * exp(g.sharp * (dot(g.axis, d) - 1.0)); }
float ueSgIntegral(UeSG g) { return 2.0 * PI * g.amp / g.sharp * (1.0 - exp(-2.0 * g.sharp)); }
UeSG ueSgMul(UeSG a, UeSG b) {
  float lm = a.sharp + b.sharp;
  vec3 um = a.sharp * a.axis + b.sharp * b.axis;
  float ul = length(um);
  return UeSG(um / ul, ul, a.amp * b.amp * exp(ul - lm));
}
// BasePassCommon.ush DotSpecularSG: the GGX lobe against a light's spherical Gaussian (the half-space ASG, H assumed in the YZ plane)
float ueDotSpecularSG(float rough, vec3 N, vec3 V, UeSG L) {
  float a = max(0.02, rough);
  a *= a;
  float a2 = a * a;
  vec3 H = normalize(V + L.axis);
  float NoV = clamp(abs(dot(N, V)) + 1e-5, 0.0, 1.0);
  float ndfSharp = 2.0 / a2;
  float ndfAmp = 1.0 / (PI * a2);
  float sx = L.sharp * 2.0 * NoV * NoV;
  float sy = L.sharp * 2.0;
  float nu = ndfSharp * 0.5;
  UeSG c = UeSG(N, 2.0 * (nu * sy) / (nu + sy), ndfAmp * L.amp * PI * inversesqrt((nu + sx) * (nu + sy)));
  return ueSgEval(c, H);
}
// BasePassCommon.ush ApplyBentNormal: the visible cone (BentNormalAO_ToSphericalGaussian) times the cosine lobe
// (ClampedCosine_ToSphericalGaussian) gives the diffuse's occlusion and its direction, and against the hemisphere's
// (Hemisphere_ToSphericalGaussian) the specular's. rough is the material's (GBuffer.Roughness), ao its Material AO
void ueApplyBentNormal(vec3 V, vec3 N, vec3 bent0, float rough, float ao, out float diffOcc, out float specOcc, out vec3 bentN) {
  float hs = 0.81;
  UeSG hemi = UeSG(N, hs, hs / (1.0 - exp(-2.0 * hs)));
  UeSG nrm = UeSG(N, 2.133, 1.17);
  float o = max(ao, 1e-4);                                   // (a fully occluded texel's cone has no width: kept finite)
  UeSG vis = UeSG(bent0, (0.75 + 1.25 * sqrt(1.0 - o)) / o, hs / (1.0 - exp(-2.0 * hs)));
  UeSG dif = ueSgMul(nrm, vis);
  bentN = dif.axis;
  diffOcc = clamp(ueSgIntegral(dif) * 0.42276995, 0.0, 1.0);
  specOcc = clamp(ueDotSpecularSG(rough, N, V, vis) / ueDotSpecularSG(rough, N, V, hemi), 0.0, 1.0);
}
// DeferredShadingCommon.ush AOMultiBounce (Jimenez et al. 2016): the light an occluded surface still gets from its own colour
vec3 ueAOMultiBounce(vec3 base, float ao) {
  vec3 a = 2.0404 * base - 0.3324;
  vec3 b = -4.7951 * base + 0.6417;
  vec3 c = 2.7552 * base + 0.6903;
  return max(vec3(ao), ((ao * a + b) * ao + c) * ao);
}

// direct + image-based lighting for one surface
// ---- Unreal's local lights (ue_lights.ludic): point and spot lights in Unreal's units, attenuation and cone (UE 5.8
// DeferredLightingCommon.ush GetLocalLightAttenuation, DynamicLightingCommon.ush SpotAttenuation, CapsuleLightIntegrate.ush
// IntegrateLight with no source radius: 1 / (d^2 + DistBiasSqr), DistBiasSqr 1 cm^2), lit by the sun's BRDF; spot lights shadowed by ueSpotShadow.
// The forward light buffer (ue_lights.ludic ue_lights_frame), 5 vec4 a light: xyz position, w InvRadius (1 / AttenuationRadius);
// rgb the light's colour x its intensity in candela, w FalloffExponent (0: inverse squared); xyz the spot's -direction, w
// CosOuterCone (-2: a point light); x InvCosConeDifference, y SpecularScale, z DiffuseScale, w VolumetricScatteringIntensity;
// x its shadow map (ue_lightshadows.ludic: >= 0 a spot's layer, -2 - p a point light's cube, -1 none).
uniform int u_ll_n;
readonly buffer u_ue_lights { vec4 ue_ll[]; };
vec4 llPos(int i) { return ue_ll[i * 5]; }
vec4 llCol(int i) { return ue_ll[i * 5 + 1]; }
vec4 llDir(int i) { return ue_ll[i * 5 + 2]; }
vec4 llMisc(int i) { return ue_ll[i * 5 + 3]; }
float llShadow(int i) { return ue_ll[i * 5 + 4].x; }
// The light grid (ue_lightgrid.ludic): per cell a count and a first index into the lights' indices (LightGridCommon.ush).
readonly buffer u_ue_lg_num { uint ue_lg_num[]; };
readonly buffer u_ue_lg_data { uint ue_lg_data[]; };
uniform float u_lg_on;
uniform mat4 u_lg_vp;      // the main view's unjittered view-projection the grid was built with
uniform vec4 u_lg_zp;      // LightGridZParams (B, O, S), w the number of slices
uniform vec4 u_lg_grid;    // cells across, cells down, pixels a cell, MaxCulledLightsPerCell
uniform vec2 u_lg_view;    // the main view's size in pixels
// the lights a point reads: its cell's (ComputeLightGridCellCoordinate from the pixel and the scene depth), or every light when there
// is no grid or the point lies outside the main view; returns the count, `start` the first entry, `direct` when they are light indices
int ueLightGridRange(vec3 wpos, out int start, out bool direct) {
  start = 0;
  direct = true;
  if (u_lg_on < 0.5) return u_ll_n;
  vec4 c = u_lg_vp * vec4(wpos, 1.0);
  if (c.w <= 0.0) return u_ll_n;
  vec2 ndc = c.xy / c.w;
  if (any(lessThan(ndc, vec2(-1.0))) || any(greaterThan(ndc, vec2(1.0)))) return u_ll_n;
  vec2 pix = (ndc * 0.5 + 0.5) * u_lg_view;
  uvec2 cxy = min(uvec2(pix / u_lg_grid.z), uvec2(u_lg_grid.xy) - 1u);
  // the scene depth: the view-space distance along the camera's axis, which a perspective projection's w is
  uint slice = uint(max(0.0, log2(c.w * u_lg_zp.x + u_lg_zp.y) * u_lg_zp.z));
  slice = min(slice, uint(u_lg_zp.w) - 1u);
  uint cell = (slice * uint(u_lg_grid.y) + cxy.y) * uint(u_lg_grid.x) + cxy.x;
  direct = false;
  start = int(ue_lg_num[cell * 2u + 1u]);
  return int(min(ue_lg_num[cell * 2u], uint(u_ll_n)));
}
int ueLightGridLight(int start, int k, bool direct) { return direct ? k : int(ue_lg_data[start + k]); }
// GetLocalLightAttenuation x IntegrateLight's falloff, and the unit vector to the light
float ueLocalLightAttenuation(int i, vec3 wpos, float distBiasSqr, out vec3 L) {
  vec4 lp = llPos(i);
  vec3 toLight = lp.xyz - wpos;
  float d2 = dot(toLight, toLight);
  L = toLight * inversesqrt(max(d2, 1.0e-12));
  float invR = lp.w;
  float mask;
  float falloffExp = llCol(i).w;
  if (falloffExp <= 0.0) {
    float t = clamp(1.0 - (d2 * invR * invR) * (d2 * invR * invR), 0.0, 1.0);
    mask = t * t;
    mask *= 1.0 / (d2 + distBiasSqr);
  } else {
    vec3 wl = toLight * invR;
    mask = pow(1.0 - clamp(dot(wl, wl), 0.0, 1.0), falloffExp);   // RadialAttenuation; no 1/d^2 (Falloff 1 when not inverse squared)
  }
  vec4 ld = llDir(i);
  if (ld.w > -1.5) {
    float sm = clamp((dot(L, ld.xyz) - ld.w) * llMisc(i).x, 0.0, 1.0);
    mask *= sm * sm;
  }
  return mask;
}
// Spot light shadow maps (ue_lightshadows.ludic), 8 vec4 a map in u_ue_ls: FShadowProjectionMatrix (with the inner and border
// scales); a MinSubjectZ, MaxSubjectZ, DepthBias, SlopeDepthBias; b atlas page, -, 1 / TransitionSize, fade alpha; c ReceiverBias,
// ShadowSharpen x 7 + 1, MaxSlopeDepthBias, tile texels; t the tile's corner in the atlas (texels). llShadow names a light's map.
uniform int u_ue_ls_n;
uniform sampler2DArray u_ue_lsh;
uniform float u_ue_ls_size;          // an atlas's size in texels
readonly buffer u_ue_ls { vec4 ue_ls[]; };
mat4 lsM(int s) { int b = s * 8; return mat4(ue_ls[b], ue_ls[b + 1], ue_ls[b + 2], ue_ls[b + 3]); }
vec4 lsA(int s) { return ue_ls[s * 8 + 4]; }
vec4 lsB(int s) { return ue_ls[s * 8 + 5]; }
vec4 lsC(int s) { return ue_ls[s * 8 + 6]; }
vec4 lsT(int s) { return ue_ls[s * 8 + 7]; }
// the map holds FShadowProjectionMatrix's hardware depth; Unreal's caster writes the linear (z - MinZ) / (MaxZ - MinZ): turned back
vec4 ueLsLinear(vec4 d, vec4 a) {
  vec4 z = a.x * a.y / (d * (a.y - a.x) + a.x);
  return (z - a.x) / (a.y - a.x);
}
// ShadowFilteringCommon.ush HorizontalPCF5x2
vec2 ueHorizontalPCF5x2(vec2 f, vec4 v00, vec4 v20, vec4 v40) {
  float r0 = v00.w * (1.0 - f.x);
  float r1 = v00.x * (1.0 - f.x);
  r0 += v00.z;  r1 += v00.y;
  r0 += v20.w;  r1 += v20.x;
  r0 += v20.z;  r1 += v20.y;
  r0 += v40.w;  r1 += v40.x;
  r0 += v40.z * f.x;  r1 += v40.y * f.x;
  return vec2(r0, r1);
}
// CalculateShadowVisibilityTransmittanceFactor: saturate((ShadowmapDepth - SceneDepth) x TransitionScale + 1)
vec4 ueLsGather(int s, vec2 pos, ivec2 off, float sceneDepth, float ts) {
  vec4 d;
  // textureGatherOffset needs a constant offset
  if (off.y == -2) {
    if (off.x == -2) d = textureGatherOffset(u_ue_lsh, vec3(pos, lsB(s).x), ivec2(-2, -2));
    else if (off.x == 0) d = textureGatherOffset(u_ue_lsh, vec3(pos, lsB(s).x), ivec2(0, -2));
    else d = textureGatherOffset(u_ue_lsh, vec3(pos, lsB(s).x), ivec2(2, -2));
  } else if (off.y == 0) {
    if (off.x == -2) d = textureGatherOffset(u_ue_lsh, vec3(pos, lsB(s).x), ivec2(-2, 0));
    else if (off.x == 0) d = textureGatherOffset(u_ue_lsh, vec3(pos, lsB(s).x), ivec2(0, 0));
    else d = textureGatherOffset(u_ue_lsh, vec3(pos, lsB(s).x), ivec2(2, 0));
  } else {
    if (off.x == -2) d = textureGatherOffset(u_ue_lsh, vec3(pos, lsB(s).x), ivec2(-2, 2));
    else if (off.x == 0) d = textureGatherOffset(u_ue_lsh, vec3(pos, lsB(s).x), ivec2(0, 2));
    else d = textureGatherOffset(u_ue_lsh, vec3(pos, lsB(s).x), ivec2(2, 2));
  }
  return clamp((ueLsLinear(d, lsA(s)) - sceneDepth) * ts + 1.0, 0.0, 1.0);
}
// ShadowProjectionPixelShader at r.ShadowQuality 5: Manual5x5PCF, ShadowSharpen, ApplyPCFOverBlurCorrection, the fade
float ueSpotShadow(int s, vec3 wpos, vec3 n, vec3 L, vec3 fwd) {
  vec4 sp = lsM(s) * vec4(wpos, 1.0);
  if (sp.w <= 0.0) return 1.0;
  vec2 uv = sp.xy / sp.w * 0.5 + 0.5;
  vec4 a = lsA(s);
  // ShadowZ = 1 - ShadowPosition.z, the linear depth; min with 0.99999 so the cleared far plane reads lit
  float shadowZ = min((sp.w - a.x) / (a.y - a.x), 0.99999);
  // the caster's bias (ComputeDepthBiasDirectionalSpot: the slope against the light's axis), taken at the receiver
  float nl = abs(dot(fwd, n));
  float slope = nl > 0.0 ? clamp(sqrt(clamp(1.0 - nl * nl, 0.0, 1.0)) / nl, 0.0, lsC(s).z) : lsC(s).z;
  float sceneDepth = shadowZ - (a.z + a.w * slope);
  float ts = lsB(s).z * mix(lsC(s).x, 1.0, clamp(dot(n, L), 0.0, 1.0));
  // Manual5x5PCF over the light's tile of the layer
  vec2 texelPos = uv * lsC(s).w - 0.5;
  vec2 f = fract(texelPos);
  vec2 pos = (lsT(s).xy + floor(texelPos) + 1.0) / u_ue_ls_size;
  vec2 row0 = ueHorizontalPCF5x2(f, ueLsGather(s, pos, ivec2(-2, -2), sceneDepth, ts), ueLsGather(s, pos, ivec2(0, -2), sceneDepth, ts), ueLsGather(s, pos, ivec2(2, -2), sceneDepth, ts));
  float res = row0.x * (1.0 - f.y) + row0.y;
  vec2 row1 = ueHorizontalPCF5x2(f, ueLsGather(s, pos, ivec2(-2, 0), sceneDepth, ts), ueLsGather(s, pos, ivec2(0, 0), sceneDepth, ts), ueLsGather(s, pos, ivec2(2, 0), sceneDepth, ts));
  res += row1.x + row1.y;
  vec2 row2 = ueHorizontalPCF5x2(f, ueLsGather(s, pos, ivec2(-2, 2), sceneDepth, ts), ueLsGather(s, pos, ivec2(0, 2), sceneDepth, ts), ueLsGather(s, pos, ivec2(2, 2), sceneDepth, ts));
  res += row2.x + row2.y * f.y;
  float sh = 0.04 * res;
  sh = clamp((sh - 0.5) * lsC(s).y + 0.5, 0.0, 1.0);
  sh = sh * sh;
  return mix(1.0, sh, lsB(s).w);
}
// ComputeVolumeShadowing's spot path: one sample, SceneDepth < ShadowDepth - DepthBias, unshadowed outside the map
float ueSpotShadowVolume(int s, vec3 wpos) {
  vec4 sp = lsM(s) * vec4(wpos, 1.0);
  if (sp.w <= 0.0) return 1.0;
  vec2 uv = sp.xy / sp.w * 0.5 + 0.5;
  if (any(lessThan(uv, vec2(0.0))) || any(greaterThan(uv, vec2(1.0)))) return 1.0;
  vec4 a = lsA(s);
  float sceneDepth = (sp.w - a.x) / (a.y - a.x);
  float d = textureLod(u_ue_lsh, vec3((lsT(s).xy + uv * lsC(s).w) / u_ue_ls_size, lsB(s).x), 0.0).r;
  float shadowDepth = ueLsLinear(vec4(d), a).x;
  // the bias-free depth here: Unreal's stored depth already holds the caster's DepthBias + slope term, of which this takes DepthBias back
  return sceneDepth < shadowDepth ? 1.0 : 0.0;
}
// Point light cubes (ue_lightshadows.ludic), 32 vec4 a light in u_ue_lp: six face matrices (FReversedZPerspectiveMatrix x view,
// face f looking along +x, -x, +y, -y, +z, -z); a -, face size, DepthBias, SlopeDepthBias; b 1 / face size, fade alpha,
// ShadowSharpen x 7 + 1, the fog's DepthBias; then each face's tile: corner (texels), atlas page, size. llShadow -2 - p names one.
uniform int u_ue_lp_n;
uniform sampler2DArrayShadow u_ue_lph;
readonly buffer u_ue_lp { vec4 ue_lp[]; };
mat4 lpM(int p, int f) { int b = p * 32 + f * 4; return mat4(ue_lp[b], ue_lp[b + 1], ue_lp[b + 2], ue_lp[b + 3]); }
vec4 lpA(int p) { return ue_lp[p * 32 + 24]; }
vec4 lpB(int p) { return ue_lp[p * 32 + 25]; }
vec4 lpT(int p, int f) { return ue_lp[p * 32 + 26 + f]; }
// ShadowProjectionCommon.ush DiscSamples29: 29 points in a disc of radius 2.5
const vec2 ueDisc29[29] = vec2[29](
  vec2(0.000000, 2.500000), vec2(1.016842, 2.283864), vec2(1.857862, 1.672826), vec2(2.377641, 0.772542), vec2(2.486305, -0.261321),
  vec2(2.165063, -1.250000), vec2(1.469463, -2.022543), vec2(0.519779, -2.445369), vec2(-0.519779, -2.445369), vec2(-1.469463, -2.022542),
  vec2(-2.165064, -1.250000), vec2(-2.486305, -0.261321), vec2(-2.377641, 0.772543), vec2(-1.857862, 1.672827), vec2(-1.016841, 2.283864),
  vec2(0.091021, -0.642186), vec2(0.698035, 0.100940), vec2(0.959731, -1.169393), vec2(-1.053880, 1.180380), vec2(-1.479156, -0.606937),
  vec2(-0.839488, -1.320002), vec2(1.438566, 0.705359), vec2(0.067064, -1.605197), vec2(0.728706, 1.344722), vec2(1.521424, -0.380184),
  vec2(-0.199515, 1.590091), vec2(-1.524323, 0.364010), vec2(-0.692694, -0.086749), vec2(-0.082476, 0.654088));
// the face a direction from the light falls on, by its major axis (CubemapHardwarePCF's CubeFaceIndex)
int ueCubeFace(vec3 d) {
  vec3 a = abs(d);
  if (a.x >= a.y && a.x >= a.z) return d.x > 0.0 ? 0 : 1;
  if (a.y >= a.z) return d.y > 0.0 ? 2 : 3;
  return d.z > 0.0 ? 4 : 5;
}
// a cube texture's compare at a direction from the light (SampleCmpLevelZero, bilinear): 1 lit
float ueCubeCmp(int p, vec3 lightPos, vec3 dir, float ref) {
  int f = ueCubeFace(dir);
  vec4 c = lpM(p, f) * vec4(lightPos + dir, 1.0);
  vec2 uv = c.xy / c.w * 0.5 + 0.5;
  // a cube face is its own texture in Unreal: keep the bilinear taps inside this face's tile of the atlas
  float h = 0.5 * lpB(p).x;
  vec4 t = lpT(p, f);
  uv = (t.xy + clamp(uv, vec2(h), vec2(1.0 - h)) * t.w) / u_ue_ls_size;
  return texture(u_ue_lph, vec4(uv, t.z, ref));
}
// ShadowProjectionPixelShader's point branch at r.ShadowQuality 5: the normal receiver bias, CubemapHardwarePCF (29 samples),
// ShadowSharpen, ApplyPCFOverBlurCorrection, the fade
float uePointShadow(int p, int i, vec3 wpos, vec3 n) {
  vec3 lightPos = llPos(i).xyz;
  vec3 toLight = lightPos - wpos;
  float dist = length(toLight);
  if (dist * llPos(i).w >= 1.0) return 1.0;
  vec3 nl = toLight / dist;
  float slopeBias = (1.0 - clamp(dot(n, nl), 0.0, 1.0)) * lpA(p).w;
  // SideVector = normalize(cross(NormalizedLightVector, up)) with Unreal's up, which is our y
  vec3 side = cross(nl, vec3(0.0, 1.0, 0.0));
  float sl = length(side);
  side = sl > 1.0e-5 ? side / sl : vec3(1.0, 0.0, 0.0);
  vec3 upv = cross(side, nl);
  side *= lpB(p).x;
  upv *= lpB(p).x;
  int f = ueCubeFace(-toLight);
  vec4 sp = lpM(p, f) * vec4(wpos, 1.0);
  float compareDistance = sp.z / sp.w;
  // ShadowDepthBias = -(DepthBias + SlopeBias) / ShadowPosition.w, w in Unreal's centimetres
  float bias = (lpA(p).z + slopeBias) / (sp.w * 100.0);
  float sh = 0.0;
  for (int k = 0; k < 29; k++) {
    vec3 dir = nl + side * ueDisc29[k].x + upv * ueDisc29[k].y;
    // the cube is indexed by the vector to the light and holds what lies the other way: the same face from the light here
    sh += ueCubeCmp(p, lightPos, -dir, compareDistance + bias * length(ueDisc29[k]));
  }
  sh /= 29.0;
  sh = clamp((sh - 0.5) * lpB(p).z + 0.5, 0.0, 1.0);
  sh = sh * sh;
  return mix(1.0, sh, lpB(p).y);
}
// ComputeVolumeShadowing's cube path (SHADOW_QUALITY 2): one compare, DepthBias 0.03 x 512 / resolution, no slope
float uePointShadowVolume(int p, int i, vec3 wpos) {
  vec3 lightPos = llPos(i).xyz;
  vec3 toLight = lightPos - wpos;
  if (length(toLight) * llPos(i).w >= 1.0) return 1.0;
  int f = ueCubeFace(-toLight);
  vec4 sp = lpM(p, f) * vec4(wpos, 1.0);
  return ueCubeCmp(p, lightPos, -toLight, sp.z / sp.w + lpB(p).w / (sp.w * 100.0));
}
vec3 ueLocalLights(vec3 wpos, vec3 n, vec3 v, vec3 albedo, float a, float metal, vec3 f0, float NoV) {
  vec3 c = vec3(0.0);
  int start;
  bool direct;
  int count = ueLightGridRange(wpos, start, direct);
  for (int k = 0; k < count; k++) {
    int i = ueLightGridLight(start, k, direct);
    vec3 L;
    float att = ueLocalLightAttenuation(i, wpos, 0.0001, L);
    float NoL = max(dot(n, L), 0.0);
    if (att <= 0.0 || NoL <= 0.0) continue;
    float si = llShadow(i);
    if (u_ue_ls_n > 0 && si >= 0.0) {
      att *= ueSpotShadow(int(si), wpos, n, L, -llDir(i).xyz);
      if (att <= 0.0) continue;
    } else if (u_ue_lp_n > 0 && si < -1.5) {
      att *= uePointShadow(int(-si - 2.0 + 0.5), i, wpos, n);
      if (att <= 0.0) continue;
    }
    vec3 H = normalize(v + L);
    vec3 F = F_Schlick(max(dot(v, H), 0.0), f0);
    vec4 misc = llMisc(i);
    vec3 spec = min(D_GGX(max(dot(n, H), 0.0), a) * V_Smith(NoV, NoL, a), 12.0) * F * u_spec_scale * misc.y;
    vec3 diff = (1.0 - F) * (1.0 - metal) * albedo / PI * misc.z;
    c += (diff + spec) * llCol(i).rgb * NoL * att;
  }
  return c;
}

vec3 shade(vec3 wpos, vec3 n, vec3 albedo, float rough, float metal, float ao, float shadow, float viewDepth) {
  vec3 v = normalize(u_cam_pos - wpos);
  float roughG = rough;                       // the material's own, as Unreal's ApplyBentNormal takes it (GBuffer.Roughness)
  vec3 l = u_sun_dir;
  vec3 h = normalize(v + l);
  float NoV = max(dot(n, v), 1e-2);
  float NoL = max(dot(n, l), 0.0);
  float NoH = max(dot(n, h), 0.0);
  float VoH = max(dot(v, h), 0.0);
  rough = clamp(rough, 0.045, 1.0);
  float a = rough * rough;
  vec3 f0 = mix(vec3(g_dielF0), albedo, metal);
  vec3 F = F_Schlick(VoH, f0);
  vec3 spec = min(D_GGX(NoH, a) * V_Smith(NoV, NoL, a), 12.0) * F * u_spec_scale;   // cap the highlight: no half-float overflow, no fireflies
  vec3 kd = (1.0 - F) * (1.0 - metal);
  // a light zone takes the sun away (and the sky but its fraction) and adds its own ambient
  vec4 lzAmb;
  float lz = lightZone(wpos, lzAmb);
  float sunK = 1.0 - lz;
  float skyK = mix(1.0, lzAmb.a, lz);
  vec3 direct = (kd * albedo / PI + spec) * u_sun_color * NoL * shadow * cloudShadow(wpos) * sunK;
  // IBL
  vec3 Fr = F_SchlickRough(NoV, f0, rough);
  vec3 kdi = (1.0 - Fr) * (1.0 - metal);
  // a bent normal (g_bentOn): the sky's diffuse along the visible cone's axis and occluded, the reflections occluded, as
  // BasePassPixelShader.usf: the indirect diffuse x AOMultiBounce(BaseColor, DiffOcclusion), the image-based reflection x
  // AOMultiBounce(SpecularColor, SpecOcclusion) (ApplyBentNormal's)
  vec3 dOcc = vec3(ao);
  vec3 soB = vec3(1.0);
  vec3 irrN = n;
  if (g_bentOn) {
    float dO, sO;
    ueApplyBentNormal(v, n, g_bentW, roughG, ao, dO, sO, irrN);
    dOcc = ueAOMultiBounce(g_bentBase, dO);
    soB = ueAOMultiBounce(f0, sO);
  }
  vec3 irr = skyIrradiance(irrN);
  vec3 diffuseIBL = kdi * albedo * irr * skyK;
  vec3 r = reflect(-v, n);
  vec3 pre = skyPrefiltered(r, rough);
  vec2 brdf = texture(u_brdf, vec2(NoV, rough)).rg;
  vec3 specIBL = pre * (Fr * brdf.x + brdf.y) * u_spec_scale * skyK;
  // one bounce off the sunlit ground onto whatever faces it (a warm fill from below)
  vec3 groundAlb = groundAlbAt(wpos.y) * 0.55;
  vec3 bounce = kdi * albedo * groundAlb * (u_sun_color * max(u_sun_dir.y, 0.0) / PI * sunK + irr * skyK) * clamp(0.5 - 0.5 * n.y, 0.0, 1.0) * 0.5;
  vec3 zoneAmb = kdi * albedo * lzAmb.rgb * lz;
  if (lz > 0.0 && u_zl_n > 0) zoneAmb += kdi * zoneLamps(wpos, n, albedo) * lz;
  // specular occlusion from ao
  float so = clamp(pow(NoV + ao, exp2(-16.0 * rough - 1.0)) - 1.0 + ao, 0.0, 1.0);
  vec3 soC = g_bentOn ? soB : vec3(so);
  // check for NaN before min(): on this GPU min(NaN, x) returns x, which would hide the fault as a hot pixel
  vec3 c = direct + (diffuseIBL * dOcc + specIBL * soC) + bounce * dOcc + zoneAmb * dOcc + (fireLight(wpos, n, albedo) + handLight(wpos, n, albedo)) * ao;
  if (u_ll_n > 0) c += ueLocalLights(wpos, n, v, albedo, a, metal, f0, NoV);
  // the character rig: the same BRDF as the sun's, unshadowed, half dimmed by the occlusion (a soft studio light reaches into folds)
  if (u_char_lit > 0.0) {
    vec3 cl = vec3(0.0);
    for (int i = 0; i < 3; i++) {
      vec3 Lc = clDir(i);
      vec3 Hc = normalize(v + Lc);
      float nl = max(dot(n, Lc), 0.0);
      vec3 Fc = F_Schlick(max(dot(v, Hc), 0.0), f0);
      vec3 sc = min(D_GGX(max(dot(n, Hc), 0.0), a) * V_Smith(NoV, nl, a), 12.0) * Fc * u_spec_scale;
      cl += ((1.0 - Fc) * (1.0 - metal) * albedo / PI + sc) * clCol(i) * nl;
    }
    c += cl * u_char_lit * mix(1.0, ao, 0.5);
  }
  if (any(isnan(direct)) || any(isnan(diffuseIBL)) || any(isnan(specIBL)) || isnan(so) || any(isnan(dOcc)) || any(isnan(soC))) return vec3(0.0);
  return sane(min(c, vec3(4096.0)));
}

// A clear coat over a shaded surface (glTF KHR_materials_clearcoat, Filament's model): a dielectric layer (f0 0.04) of its own
// roughness on the geometric normal Ng, its sun highlight and its sky reflection added, the base under it dimmed by the coat's
// Fresnel at the view. `base` is shade()'s result for the paint under it
vec3 clearCoat(vec3 base, vec3 wpos, vec3 Ng, float coat, float cRough, float shadow) {
  vec3 v = normalize(u_cam_pos - wpos);
  vec3 l = u_sun_dir;
  vec3 h = normalize(v + l);
  float NoV = max(dot(Ng, v), 1e-2);
  float NoL = max(dot(Ng, l), 0.0);
  float NoH = max(dot(Ng, h), 0.0);
  float VoH = max(dot(v, h), 0.0);
  float cr = clamp(cRough, 0.045, 1.0);
  float a = cr * cr;
  float Fc = F_Schlick(VoH, vec3(0.04)).x * coat;
  float Fcv = F_Schlick(NoV, vec3(0.04)).x * coat;
  vec4 lzAmb;
  float lz = lightZone(wpos, lzAmb);
  float sunK = 1.0 - lz;
  float skyK = mix(1.0, lzAmb.a, lz);
  vec3 sunSpec = min(D_GGX(NoH, a) * V_Smith(NoV, NoL, a), 12.0) * Fc * u_spec_scale * u_sun_color * NoL * shadow * cloudShadow(wpos) * sunK;
  vec3 skySpec = skyPrefiltered(reflect(-v, Ng), cr) * Fcv * u_spec_scale * skyK;
  return sane(min(base * (1.0 - Fcv) + sunSpec + skySpec, vec3(4096.0)));
}

// aerial perspective: exponential height fog toward the horizon sky, with sun inscatter.
// The strength of all three terms is the DAY's (daylight.ludic), not a constant: a low sun
// is shining through far more air than a high one, and the whole look of a valley at dawn
// is that air.
uniform float u_fog_inscatter;   // how hard the air scatters the sun forward
uniform float u_fog_desat;       // how fast distance takes a surface's own colour away
uniform float u_fog_wall;        // r3d_fog_wall: > 0, the distance past which nothing but the land is drawn
uniform float u_fog_haze;        // how much of the wall's colour the far land takes (1: all, the land hidden too)
uniform vec2 u_fog_cut;          // the wall's dissolve, start and end (m) from the camera; end 0 for none
// the colour the fog wall hides things in: the haze the camera would see at the horizon that way. Its
// light is the whole sky's (its mean radiance, the irradiance an upward face takes - the photograph's
// average horizon), coloured as the drawn sky is at the horizon at this hour (analyticSky, by the same
// relight), and the sun scattered forward through it. It was the photograph's own horizon prefiltered at
// roughness 0.6: half that lobe is the puresky image's slate lower half and the rest its clouds, never
// relit - a storm on one side of a clear morning and white milk on the other.
uniform float u_sky_relight;     // 0 leaves the photograph alone; the day fades this in
vec3 analyticSky(vec3 dir) {
  float ct = clamp(dir.y, 0.0, 1.0);
  float cs = clamp(dot(dir, u_sun_dir), -1.0, 1.0);
  float lowsun = 1.0 - smoothstep(0.0, 0.45, u_sun_dir.y);
  // Rayleigh: deep overhead, pale at the horizon where the line of sight is longest
  vec3 base = mix(vec3(0.60, 0.70, 0.85), vec3(0.16, 0.33, 0.74), pow(ct, 0.55));
  // the sun's warmth spreads into the sky around it, and spreads FURTHER the lower it is
  float glow = pow(max(cs, 0.0), mix(9.0, 2.0, lowsun));
  base = mix(base, vec3(1.0, 0.55, 0.22), glow * mix(0.22, 0.88, lowsun));
  // and at dusk the whole horizon band warms, not only the part near the sun
  float band = (1.0 - smoothstep(0.0, 0.32, ct)) * lowsun;
  base = mix(base, vec3(0.96, 0.52, 0.28), band * 0.55);
  return base;
}
vec3 fogWallCol(vec3 dir) {
  vec3 amb = skyIrradianceRaw(vec3(0.0, 1.0, 0.0));
  vec3 sk = analyticSky(normalize(vec3(dir.x, 0.04, dir.z) + vec3(1e-4, 0.0, 0.0)));
  float la = dot(amb, vec3(0.2126, 0.7152, 0.0722));
  float ls = max(dot(sk, vec3(0.2126, 0.7152, 0.0722)), 1e-4);
  vec3 c = mix(amb, sk * (la / ls), u_sky_relight);
  return c + u_sun_color * u_fog_inscatter * pow(max(dot(dir, u_sun_dir), 0.0), 8.0);
}
vec3 applyFogSky(vec3 col, vec3 dir, float dist, vec3 skyCol);
vec3 applyFog(vec3 col, vec3 wpos, float dist) {
  vec3 dir = normalize(wpos - u_cam_pos);
  return applyFogSky(col, dir, dist, skyPrefiltered(vec3(dir.x, max(dir.y, 0.02), dir.z), 0.6));
}
// the same with the haze's sky colour (what skyPrefiltered gives toward the view direction, raised to a few degrees
// above the horizon, at roughness 0.6) read by the caller: a surface that reads the sky anyway, or that can do it
// with fewer fetches, does not pay for the full filter twice
vec3 applyFogSky(vec3 col, vec3 dir, float dist, vec3 skyCol) {
  float hf = u_fog_height_falloff;
  float t = dir.y * hf;
  float integ = (abs(t) > 1e-4) ? (1.0 - exp(-dist * t)) / t : dist * (1.0 - 0.5 * dist * t);
  // measured from u_fog_base: two maps on one height datum, one a thousand metres lower,
  // would otherwise have that one's air exp(falloff * 1000) times thicker
  float fogAmt = u_fog_density * exp(-(u_cam_pos.y - u_fog_base) * hf) * integ;
  float f = clamp(1.0 - exp(-fogAmt), 0.0, 1.0);
  vec3 fogCol = skyCol;
  float sunAmt = pow(max(dot(dir, u_sun_dir), 0.0), 8.0);
  fogCol += u_sun_color * u_fog_inscatter * sunAmt;
  // DISTANCE TAKES SATURATION BEFORE IT TAKES CONTRAST, and the mix below cannot do that on
  // its own: blending a saturated green ridge toward a saturated blue sky leaves a saturated
  // ridge. That is why the noon frame had a mountain three kilometres off reading as vividly
  // as the workbench two metres from the camera, while the same scene at dusk - where the fog
  // colour happens to be a warm grey - looked like a photograph. Pull the surface toward its
  // own luminance first, faster than the fog itself arrives, and the ridge recedes at every
  // hour rather than only at the one where the sky was already grey.
  float l = dot(col, vec3(0.2126, 0.7152, 0.0722));
  col = mix(col, vec3(l), clamp(f * u_fog_desat, 0.0, 1.0));
  col = mix(col, fogCol, f);
  // the fog wall: from three tenths of its distance on, everything takes the haze's colour - all of it by
  // 0.85 of the wall when the land is hidden too, a share (u_fog_haze) when the land draws through it
  if (u_fog_wall > 0.0) {
    float w = smoothstep(0.3 * u_fog_wall, 0.85 * u_fog_wall, dist) * u_fog_haze;
    if (w > 0.0) col = mix(col, fogWallCol(dir), w);
  }
  return col;
}
// is this fragment of a scatter instance, a layer or an actor dissolved at the wall? A dither from the
// dissolve's start to its end, so what the wall takes thins into the land behind rather than ending in a line
bool fogCut(vec3 wpos) {
  if (u_fog_cut.y <= 0.0) return false;
  float t = (length(wpos - u_cam_pos) - u_fog_cut.x) / max(u_fog_cut.y - u_fog_cut.x, 1.0);
  if (t <= 0.0) return false;
  return t >= fract(sin(dot(gl_FragCoord.xy, vec2(12.9898, 78.233))) * 43758.5453);
}

// ---- Epic's hair (HairBsdf.ush HairShading, HairShadingCommon.ush): the R, TT and TRT lobes, shared by the hair cards (model.frag FABRIC
// mode 3) and the strands (strands.frag, hair_lut.frag). T along the strand, V and L toward the eye and the light; no cosine (the lobes
// carry it). tt: what is left of the light through the strand (TT, TRT; 1: all). backlit: Unreal's Backlit (R toward the light behind lerped to it, TT times it); legacy: bUseLegacyAbsorption (TT as a
// power of the colour, else the colour's absorption through the fibre); clampB: bClampBSDFValue (the lobes' width at least 0.01)
float hairG(float B, float theta, bool clampB) { return exp(-0.5 * theta * theta / (B * B)) / (sqrt(2.0 * PI) * (clampB ? max(B, 0.01) : B)); }
float hairF(float cosT) { float f0 = 0.0465; float m = 1.0 - cosT; return f0 + (1.0 - f0) * m * m * m * m * m; }
const float HAIR_D = 5.969 - 0.215 * 0.3 + 2.532 * 0.09 - 10.73 * 0.027 + 5.574 * 0.0081 + 0.245 * 0.00243;
vec3 hairAbsorption(vec3 c) { vec3 l = log(max(c, vec3(1e-4))) / HAIR_D; return l * l; }
vec3 hairColour(vec3 a) { return exp(-sqrt(a) * HAIR_D); }
vec3 hairBsdf(vec3 base, float rough, float spec, vec3 T, vec3 V, vec3 L, float area, float backlit, bool legacy, bool clampB, float tt) {
  float r = clamp(rough, 1.0 / 255.0, 1.0);
  float VoL = dot(V, L);
  float sinL = clamp(dot(T, L), -1.0, 1.0);
  float sinV = clamp(dot(T, V), -1.0, 1.0);
  float cosD = cos(0.5 * abs(asin(sinV) - asin(sinL)));
  vec3 Lp = L - sinL * T;
  vec3 Vp = V - sinV * T;
  float cosPhi = dot(Lp, Vp) * inversesqrt(dot(Lp, Lp) * dot(Vp, Vp) + 1e-4);
  float cosHalfPhi = sqrt(clamp(0.5 + 0.5 * cosPhi, 0.0, 1.0));
  float np = 1.19 / cosD + 0.36 * cosD;
  float shift = 0.035;
  float b0 = area + r * r, b1 = area + r * r * 0.5, b2 = area + r * r * 2.0;
  vec3 S = vec3(0.0);
  // R
  float sa = sin(-shift * 2.0), ca = cos(-shift * 2.0);
  float shiftR = 2.0 * sa * (ca * cosHalfPhi * sqrt(1.0 - sinV * sinV) + sa * sinV);
  S += vec3(hairG(b0 * sqrt(2.0) * cosHalfPhi, sinL + sinV - shiftR, clampB) * 0.25 * cosHalfPhi * hairF(sqrt(clamp(0.5 + 0.5 * VoL, 0.0, 1.0)))
            * spec * 2.0 * mix(1.0, backlit, clamp(-VoL, 0.0, 1.0)));
  // TT
  float a = 1.0 / np;
  float h = cosHalfPhi * (1.0 + a * (0.6 - 0.8 * cosPhi));
  float f = hairF(cosD * sqrt(clamp(1.0 - h * h, 0.0, 1.0)));
  vec3 tp = legacy ? pow(abs(base), vec3(0.5 * sqrt(max(1.0 - (h * a) * (h * a), 0.0)) / cosD))
                   : exp(-hairAbsorption(base) * 2.0 * abs(1.0 - (h * a) * (h * a) / cosD));
  S += hairG(b1, sinL + sinV - shift, clampB) * exp(-3.65 * cosPhi - 3.98) * (1.0 - f) * (1.0 - f) * tp * backlit * tt;
  // TRT
  float f2 = hairF(cosD * 0.5);
  S += hairG(b2, sinL + sinV - shift * 4.0, clampB) * exp(17.0 * cosPhi - 16.78) * (1.0 - f2) * (1.0 - f2) * f2 * pow(abs(base), vec3(0.8 / cosD)) * tt;
  return max(S, vec3(0.0));
}
// MF_Variation: the signal to a power the strand's seed picks (1 + v at 0, 1 at 0.5, 1 / (1 + v) at 1)
float hairVar(float v, float sgl, float seed) {
  float t = seed * 2.0;
  float lo = pow(max(sgl, 0.0), 1.0 + v), hi = pow(max(sgl, 0.0), 1.0 / (1.0 + v));
  return mix(mix(lo, sgl, clamp(t, 0.0, 1.0)), hi, clamp(t - 1.0, 0.0, 1.0));
}
// GetHairColorFromMelanin (HairShadingCommon.ush): eumelanin and pheomelanin absorptions, plus the dye's
vec3 hairMelanin(float m, float r, vec3 dye) {
  float mel = -log(max(1.0 - clamp(m, 0.0, 1.0), 1e-4));
  r = clamp(r, 0.0, 1.0);
  vec3 a = mel * (1.0 - r) * vec3(0.506, 0.841, 1.653) + mel * r * vec3(0.343, 0.733, 1.924);
  return hairColour(a + hairAbsorption(clamp(dye, vec3(0.0), vec3(1.0))));
}
// MF_Hair_Color's melanin: the parameter varied by the strand (fine to rough by the roughness), to the power 2.2
float hairMel(float m, float fine, float rough, float hr, float seed) {
  return pow(max(hairVar(mix(fine, rough, clamp(hr * 2.0, 0.0, 1.0)), m, seed), 0.0), 2.2);
}
// M_hair_v4's colour for one strand (a card's texel of it, or a groom's strand): fp the hair's parameters (gpp model.frag's hair mode
// layout: 0 the dye, 1 melanin variations and roughness, 5..11 the look's melanin, white strands, highlights and ombre, art hair_unreal.py),
// seed the strand's, coord its place along it (0 at the root, 1 at the tip)
vec3 mhHairColour(vec4 fp[17], float seed, float coord) {
  vec3 alb;
  // the colour: the dye's absorption, more or less by the strand (MF_Hair_Color's melanin variation, fine to rough by the roughness)
  float mv = mix(fp[1].x, fp[1].y, clamp(fp[1].z * 2.0, 0.0, 1.0));
  float k = hairVar(mv, 0.5, seed) / 0.5;
  alb = hairColour(hairAbsorption(fp[0].rgb) * k);
  if (fp[11].x > 0.5) {
    // M_hair_v4's colour from the look's melanin (art hair_unreal.py: u_fp 0 the dye, 5 melanin, redness, WhiteAmount, LightAmount,
    // 6 the white strands' melanin high, low, variation, Desat, 7 Highlights, its melanin, redness, blending, 8 its dye, intensity,
    // 9 Ombre, its melanin, redness, shift, 10 its dye, contrast, 11 on, the variations fine and rough, the ombre's intensity).
    // MF_Hair_ColorBlending, then MF_Hair_SaltAndPeper with the strands' coverage (WhiteAmount^2.4: what Unreal shows up close;
    // its cards' WhiteAmount x 1.08 greys dark hair), then the HairColor node and the Desaturation
    float hr0 = fp[1].z;
    float mel = hairMel(fp[5].x, fp[1].x, fp[1].y, hr0, seed);
    float red = fp[5].y;
    vec3 dye = fp[0].rgb;
    // the ombre, along the strand (the atlas's coordinate): CheapContrast of the shifted power
    float sh = (fp[9].w + 0.065) * 10.0 - 5.0;
    float tl = clamp(coord, 0.0, 1.0);
    float oa = sh > 0.0 ? pow(tl, sh + 1.0) : 1.0 - pow(1.0 - tl, abs(sh) + 1.0);
    oa = clamp(mix(-fp[10].w, 1.0 + fp[10].w, oa), 0.0, 1.0) * fp[11].w;
    float om = fp[9].x;
    mel = mix(mel, mix(mel, hairMel(fp[9].y, fp[11].y, fp[11].z, hr0, seed), oa), om);
    red = mix(red, mix(red, fp[9].z, oa), om);
    dye = mix(dye, mix(dye, fp[10].rgb, oa), om);
    // the highlights: Unreal's mask through the strand's root (cards: the mask plus 0.15 .. 0.3 by the seed); a card's strands have
    // no root position, the seed picks the mask's value
    float mask = fract(seed * 13.17 + 0.37);
    mask = mask * mask;
    float ha = clamp(pow(clamp(mix(mask + 0.15, mask + 0.3, seed * 1.08), 0.0, 1.0), 1.0 + fp[7].w * 5.0) * fp[8].w * 3.0, 0.0, 1.0);
    ha *= mix(1.0, oa, om) * fp[7].x;
    mel = mix(mel, hairMel(fp[7].y, fp[11].y, fp[11].z, hr0, seed), ha);
    red = mix(red, fp[7].z, ha);
    dye = mix(dye, fp[8].rgb, ha);
    // salt and pepper: the white strands' melanin over a WhiteAmount^2.4 share of them
    float wa = pow(max(fp[5].z, 0.0), 2.4);
    float wc = smoothstep(wa, wa - 0.05, seed);
    float wv = hairVar(fp[6].z, mix(fp[6].x, fp[6].y, fp[5].x), seed) * 1.25;
    mel = mix(mel, mix(wv, wv * 0.5, fp[5].w), wc);
    alb = hairMelanin(mel, red, dye);
    float lum = dot(alb, vec3(0.3, 0.59, 0.11));
    alb = mix(alb, vec3(lum), mix(fp[6].w, 0.9, wc));
  }
  return alb;
}
#if defined(EYE) || defined(SSS_SPLIT) || (defined(STRANDS) && !defined(DOM) && !defined(TRANSMITTANCE))
// the groom's deep shadow from the sun (strands.ludic: Unreal's front depth and four layers of hair coverage). u_hs_p: x on, y the map's
// size in texels, z the depth bias (the first layer's depth x DepthBiasScale 0.05), w DensityScale 2
uniform sampler2D u_hairsh;
uniform sampler2D u_hs_front;
uniform mat4 u_hs_view;
uniform mat4 u_hs_proj;
uniform vec4 u_hs_p;
uniform vec4 u_hs_layers;
// ToLightPosition: texel coordinates and the reversed depth; w 0 outside the map
vec4 hsLight(vec3 wpos) {
  vec4 c = u_hs_proj * (u_hs_view * vec4(wpos, 1.0));
  vec2 uv = c.xy / c.w * 0.5 + 0.5;
  bool in01 = all(greaterThanEqual(uv, vec2(0.0))) && all(lessThanEqual(uv, vec2(1.0)));
  return vec4(uv * u_hs_p.y, c.z / c.w, in01 ? 1.0 : 0.0);
}
// HairStrandsDeepShadowCommon.ush ComputeHairCount: the count in front of a point that far behind the front, between the layers
float hsCount(vec4 dom, float d) {
  vec4 L = u_hs_layers;
  if (d < L.x) return mix(0.0, dom.x, clamp(d / L.x, 0.0, 1.0));
  if (d < L.y) return mix(dom.x, dom.y, clamp((d - L.x) / (L.y - L.x), 0.0, 1.0));
  if (d < L.z) return mix(dom.y, dom.z, clamp((d - L.y) / (L.z - L.y), 0.0, 1.0));
  if (d < L.w) return mix(dom.z, dom.w, clamp((d - L.z) / (L.w - L.z), 0.0, 1.0));
  return dom.w;
}
float hsTexel(ivec2 t, float z) {
  int n = int(u_hs_p.y) - 1;
  t = clamp(t, ivec2(0), ivec2(n));
  float front = texelFetch(u_hs_front, t, 0).r;
  return hsCount(texelFetch(u_hairsh, t, 0), max(0.0, front - z - u_hs_p.z));        // GetDomDistanceToFrontDepthWithBias
}
// SampleDOM_PCF2x2: the four texels' counts, bilinear
float hsPCF2x2(vec3 p) {
  vec2 bl = floor(p.xy - 0.5);
  ivec2 c0 = ivec2(bl);
  vec2 f = fract(p.xy - (bl + 0.5));
  float a = mix(hsTexel(c0, p.z), hsTexel(c0 + ivec2(1, 0), p.z), f.x);
  float b = mix(hsTexel(c0 + ivec2(0, 1), p.z), hsTexel(c0 + ivec2(1, 1), p.z), f.x);
  return mix(a, b, f.y);
}
// the groom's shadow on the skin and eyes: HairStrandsDeepShadowMask.usf InternalGaussianTransmissionFilter (ShadowMaskKernelType 4):
// 1 - the mean of saturate(the count) over eight Poisson taps three texels out
float hairShadow(vec3 wpos) {
  if (u_hs_p.x < 0.5) return 1.0;
  vec4 p = hsLight(wpos);
  if (p.w < 0.5) return 1.0;
  const vec2 PD[8] = vec2[8](vec2(-0.94201624, -0.39906216), vec2(0.94558609, -0.76890725), vec2(-0.094184101, -0.92938870),
    vec2(0.34495938, 0.29387760), vec2(-0.91588581, 0.45771432), vec2(-0.81544232, -0.87912464), vec2(-0.38277543, 0.27676845),
    vec2(0.97484398, 0.75648379));
  float acc = 0.0;
  for (int i = 0; i < 8; ++i) acc += clamp(hsPCF2x2(vec3(p.xy + PD[i] * 3.0, p.z)), 0.0, 1.0);
  return 1.0 - acc / 8.0;
}
// the hair count between a strand and the sun: HairStrandsDeepTransmittanceMask.usf, SampleDOM_PCF (r.HairStrands.DeepShadow.KernelType 2:
// a 3 x 3 ring of 2 x 2 taps two texels apart) x DensityScale
float hairCountAt(vec3 wpos) {
  if (u_hs_p.x < 0.5) return 0.0;
  vec4 p = hsLight(wpos);
  if (p.w < 0.5) return 0.0;
  float n = 0.0;
  for (int j = -1; j <= 1; ++j)
  for (int i = -1; i <= 1; ++i) n += hsPCF2x2(vec3(p.xy + vec2(float(i), float(j)) * 2.0, p.z));
  return n / 9.0 * u_hs_p.w;
}
#endif

// ---- surfaces: a scanned material tiled in metres over a mesh whose material names it (surface.ludic) ------------------------------
// The mesh's own uvs, the world (planar along the normal's axis, blended at corners), or a kit's own frame (box instances: the
// metres of the stretched box, so a wall's bricks keep their size at any width) give the place in tiles; two taps a projection at
// offsets that change across a few tiles (Quilez's texture repetition, technique 3) hide the tile; a slow variation over tens of
// metres breaks a large flat area. Off (u_surf.x 0) nothing here runs and the material draws as before. A second surface (u_s2:
// the ground's paving under its grass) is blended in by the vertex colour: where the land-use tone is green, the first.
uniform vec4 u_surf;     // metres a tile (0: off), mapping (0 world, 1 the mesh's uvs, 2 a kit's frame), the origin's offset x, z in tiles
uniform vec4 u_surf_b;   // tone (1: the material's colour times the texture's detail over its mean; 0: the texture's own colour),
                         // anti-tiling share 0..1, macro variation share, normal strength (negative flips the map's green)
uniform vec4 u_surf_c;   // the texture's mean albedo r g b (tone divides by it), metres a unit of the mesh's uvs
uniform vec4 u_surf_d;   // albedo gain, saturation (1 the scan's own), roughness scale
uniform vec4 u_surf_e;   // the height map's depth in tiles (the diffuse map's alpha; 0 none), a kit's alternative's share (on u_s2_e),
                         // a road's gutter pan and a kerb's nose in metres (surfKerb; 0 none)
uniform vec4 u_s2;       // the second surface, as u_surf .. u_surf_e (u_s2.x 0: none)
uniform vec4 u_s2_b;
uniform vec4 u_s2_c;
uniform vec4 u_s2_d;
uniform vec4 u_s2_e;
uniform sampler2D u_s2_diff;
uniform sampler2D u_s2_nrm;
uniform sampler2D u_s2_arm;
uniform sampler2D u_lu;  // the ground's lawn coverage of the patch's tile (tilemap_mask.ludic tmk_lawn): 1 lawn, 0 paving, its edge softened
uniform vec4 u_lu_on;    // x 1: read it (0: the vertex colour decides), y z the tile's place in the uvs' tile grid
struct SurfP { vec4 a; vec4 b; vec4 c; vec4 d; vec4 e; };
// period 1024 / scale cells: every pattern repeats in a whole number of 1024-tile spans, so the origin's offset (mod 1024 tiles)
// moves nothing on a rebase
float surfHash(vec2 c, float per) { c = mod(c, per); return fract(sin(dot(c, vec2(127.1, 311.7))) * 43758.5453); }
float surfNoise(vec2 x, float per) {
  vec2 i = floor(x), f = fract(x);
  f = f * f * (3.0 - 2.0 * f);
  return mix(mix(surfHash(i, per), surfHash(i + vec2(1.0, 0.0), per), f.x),
             mix(surfHash(i + vec2(0.0, 1.0), per), surfHash(i + vec2(1.0, 1.0), per), f.x), f.y);
}
mat3 surfFrame(vec3 N, vec3 dp1, vec3 dp2, vec2 duv1, vec2 duv2) {
  vec3 dp2perp = cross(dp2, N), dp1perp = cross(N, dp1);
  vec3 T = dp2perp * duv1.x + dp1perp * duv2.x;
  vec3 B = dp2perp * duv1.y + dp1perp * duv2.y;
  float invmax = inversesqrt(max(max(dot(T, T), dot(B, B)), 1e-36));
  return mat3(T * invmax, B * invmax, N);
}
// parallax occlusion: the place the eye's ray (vt: toward the eye in the projection's tangent frame, z out of the surface) first
// meets the height map (the diffuse map's alpha, white high), `depth` tiles deep; marched in steps, refined between the last two
vec2 surfParallax(sampler2D d, vec2 uv, vec2 dx, vec2 dy, vec3 vt, float depth) {
  if (depth <= 0.0) return uv;
  const int N = 16;
  float layer = 1.0 / float(N);
  vec2 step = -vt.xy / max(vt.z, 0.2) * depth * layer;
  vec2 p = uv;
  float cur = 0.0;
  float h = 1.0 - textureGrad(d, p, dx, dy).a;
  for (int i = 0; i < N; ++i) {
    if (cur >= h) break;
    p += step;
    cur += layer;
    h = 1.0 - textureGrad(d, p, dx, dy).a;
  }
  vec2 prev = p - step;
  float after = h - cur;
  float before = (1.0 - textureGrad(d, prev, dx, dy).a) - (cur - layer);
  float w = after / min(after - before, -1e-5);
  return mix(p, prev, clamp(w, 0.0, 1.0));
}
// one projection: uv in tiles, its screen derivatives; the albedo, the tangent-space normal and AO/roughness/metal
void surfTap(sampler2D d, sampler2D nm, sampler2D am, float anti, vec2 uv, vec2 dx, vec2 dy, vec3 vt, float depth,
             out vec3 alb, out vec3 tn, out vec3 arm) {
  float k = surfNoise(uv * 0.25, 256.0) * 8.0 * anti;
  float i = floor(k), f = fract(k);
  vec2 oa = sin(vec2(3.0, 7.0) * i), ob = sin(vec2(3.0, 7.0) * (i + 1.0));
  // the parallax found once, on the first tap's place, and moved with both
  uv += surfParallax(d, uv + oa, dx, dy, vt, depth) - (uv + oa);
  vec3 a1 = textureGrad(d, uv + oa, dx, dy).rgb;
  vec3 a2 = textureGrad(d, uv + ob, dx, dy).rgb;
  float w = (anti <= 0.0) ? 0.0 : smoothstep(0.2, 0.8, f - 0.1 * dot(a1 - a2, vec3(1.0)));
  alb = mix(a1, a2, w);
  tn = mix(textureGrad(nm, uv + oa, dx, dy).rgb, textureGrad(nm, uv + ob, dx, dy).rgb, w) * 2.0 - 1.0;
  arm = mix(textureGrad(am, uv + oa, dx, dy).rgb, textureGrad(am, uv + ob, dx, dy).rgb, w);
}
// the place in tiles of world point wp / the mesh's uv / the kit's frame point lp (+ a seed's offset), for the surface P
vec3 surfPlace(SurfP P, vec3 wp, vec2 uv, vec3 lp) {
  if (P.a.y == 1.0) return vec3(uv * P.c.w / P.a.x, 0.0);
  if (P.a.y == 2.0) return lp / P.a.x;
  return vec3(wp.x / P.a.x + P.a.z, wp.y / P.a.x, wp.z / P.a.x + P.a.w);
}
// surface P at q (tiles, in the mapping's frame) with that frame's normal nq; N, wp the world normal and position (their
// derivatives give the tangent frames); base the material's colour (tone). Out: albedo, world normal, ao/roughness/metal.
void surfaceAtP(sampler2D d, sampler2D nm, sampler2D am, SurfP P, vec3 q, vec3 nq, vec3 N, vec3 wp, vec3 base,
                out vec3 alb, out vec3 n, out vec3 arm) {
  vec3 dqx = dFdx(q), dqy = dFdy(q);
  vec3 dpx = dFdx(wp), dpy = dFdy(wp);
  vec3 V = normalize(u_cam_pos - wp);
  // the depth fades out by 25 m (a pixel there spans more than the relief)
  float depth = P.e.x * (1.0 - smoothstep(12.0, 25.0, length(u_cam_pos - wp)));
  vec3 w = (P.a.y == 1.0) ? vec3(0.0, 0.0, 1.0) : pow(abs(nq), vec3(8.0));
  w /= max(w.x + w.y + w.z, 1e-5);
  alb = vec3(0.0);  arm = vec3(0.0);
  vec3 nsum = vec3(0.0);
  float gs = P.b.w < 0.0 ? -1.0 : 1.0;
  float str = abs(P.b.w);
  for (int a = 0; a < 3; ++a) {
    float wa = (a == 0) ? w.x : ((a == 1) ? w.y : w.z);
    if (wa < 0.01) continue;
    // x looks along x: (z, y); y up: (x, z); z: (x, y); the mesh's uvs ride in q.xy with w on z
    vec2 uv  = (a == 0) ? q.zy : ((a == 1) ? q.xz : q.xy);
    vec2 ux  = (a == 0) ? dqx.zy : ((a == 1) ? dqx.xz : dqx.xy);
    vec2 uy  = (a == 0) ? dqy.zy : ((a == 1) ? dqy.xz : dqy.xy);
    vec3 ta, tt, tr;
    mat3 tbn = surfFrame(N, dpx, dpy, ux, uy);
    vec3 vt = vec3(dot(V, normalize(tbn[0])), dot(V, normalize(tbn[1])), dot(V, N));
    surfTap(d, nm, am, P.b.y, uv, ux, uy, vt, depth, ta, tt, tr);
    tt.y *= gs;
    tt.xy *= str;
    nsum += wa * normalize(tbn * tt);
    alb += wa * ta;
    arm += wa * tr;
  }
  n = normalize(nsum + N * 1e-4);
  // the slow variation: a patch every 8 tiles or so, brighter or darker by the share
  vec2 mq = (abs(nq.y) > 0.5) ? q.xz : vec2(q.x + q.z, q.y);
  float m = surfNoise(mq * 0.125, 128.0) * 0.65 + surfNoise(mq * 0.031, 32.0) * 0.35;
  alb *= 1.0 + P.b.z * (m - 0.5) * 2.0;
  if (P.b.x > 0.5) alb = base * alb / max(P.c.rgb, vec3(0.02));
  // graded (a scan's own colour, or the material's toned): its saturation round its luminance, then its brightness (a photographed
  // asphalt is paler than a road's, a land use's green brighter than a lawn's)
  float l = dot(alb, vec3(0.2126, 0.7152, 0.0722));
  alb = max(mix(vec3(l), alb, P.d.y), vec3(0.0)) * P.d.x;
  arm.g = clamp(arm.g * P.d.z, 0.02, 1.0);
}
SurfP surfMain() { return SurfP(u_surf, u_surf_b, u_surf_c, u_surf_d, u_surf_e); }
SurfP surfSecond() { return SurfP(u_s2, u_s2_b, u_s2_c, u_s2_d, u_s2_e); }
// two surfaces blended: the ground's (u_s2_e.y 0) the first where the vertex colour (the land-use tone) is green, the second (paving)
// elsewhere, the edge broken by a noise a metre or so across; a mesh's alternative (u_s2_e.y its share, .z its patch's metres: a
// worn asphalt, a marking's paint worn through) the second over that share of the surface, in patches with a ragged edge
void surfaceGround(sampler2D d, sampler2D nm, sampler2D am, vec3 wp, vec3 N, vec3 col, vec2 uv, out vec3 alb, out vec3 n, out vec3 arm) {
  SurfP A = surfMain(), B = surfSecond();
  vec3 a1, n1, r1, a2, n2, r2;
  surfaceAtP(d, nm, am, A, surfPlace(A, wp, uv, wp), N, N, wp, col, a1, n1, r1);
  // the ground's paving takes the land use's tone, but no brighter than the sidewalk's concrete (a pale map colour would blow out in
  // the sun); a mesh's alternative takes the colour as it is
  float cl = dot(col, vec3(0.2126, 0.7152, 0.0722));
  vec3 col2 = B.e.y > 0.0 ? col : col * min(1.0, 0.18 / max(cl, 1e-3));
  // where the lawn texture says paving, a green the vertex colour drew in from a lawn a cell away (or a sliver taken out) is not paving's
  if (B.e.y == 0.0 && u_lu_on.x > 0.5) col2 = mix(col2, vec3(dot(col2, vec3(0.2126, 0.7152, 0.0722))), clamp((col.g - max(col.r, col.b)) * 25.0, 0.0, 1.0));
  surfaceAtP(u_s2_diff, u_s2_nrm, u_s2_arm, B, surfPlace(B, wp, uv, wp), N, N, wp, col2, a2, n2, r2);
  float w;
  if (B.e.y > 0.0) {
    // world metres from the first's own origin offset (whole 1024-tile spans: a rebase moves no patch)
    vec2 q = (wp.xz + vec2(A.a.z, A.a.w) * A.a.x) / max(B.e.z, 0.1);
    float m = surfNoise(q, 1024.0) * 0.7 + surfNoise(q * 3.4, 1024.0) * 0.2 + surfNoise(q * 25.0, 1024.0) * 0.1;
    w = smoothstep(B.e.y - 0.015, B.e.y + 0.015, m);   // the first's weight: the second where m is under the share
  } else if (u_lu_on.x > 0.5) {
    // the lawn's own texture (a texel a metre): its half-way line is the edge, nudged a hand's width either way by a noise, sharp
    // as a pixel; a soil line a few centimetres wide on the lawn's side of it, where the grass thins at its edge
    float c = texture(u_lu, uv - u_lu_on.yz).r;
    float e = surfNoise(wp.xz * 3.0 + vec2(A.a.z, A.a.w) * A.a.x, 1024.0) - 0.5;
    float v = c + e * 0.06;
    float aa = max(fwidth(v), 1e-4);
    w = smoothstep(0.5 - aa, 0.5 + aa, v);
    float soil = w * (1.0 - smoothstep(0.5, 0.56 + aa, v));
    vec3 mixed = mix(a2, a1, w);
    alb = mix(mixed, mixed * vec3(0.55, 0.5, 0.42), soil * 0.7);
    n = normalize(mix(n2, n1, w));
    arm = mix(r2, r1, w);
    return;
  } else {
    float green = col.g - max(col.r, col.b);
    float e = surfNoise(wp.xz * 0.8 + vec2(A.a.z, A.a.w) * A.a.x * 0.8, 1024.0) - 0.5;
    // a narrow step: the vertex colour runs between land uses over a whole triangle, so a wide one smears a lawn's edge metres wide
    w = smoothstep(0.036, 0.044, green + e * 0.012);
  }
  alb = mix(a2, a1, w);
  n = normalize(mix(n2, n1, w));
  arm = mix(r2, r1, w);
}

// a road's gutter and a kerb's rounded nose (u_surf_e.z, .w metres; the road bake's kerbDistances): a road's and a kerb top's uvs are their
// distances to the kerb's foot along two lines (the lesser is the distance), a kerb face's v runs up it. Along the kerb the road is a gutter
// pan g wide (the asphalt's detail on a smoother, paler concrete, a dark joint at its edge, grime packed against the kerb) with a dirty
// fringe beyond it, gully grates in it, and in the lanes repair patches and manhole covers; the kerb's top and face turn round a nose r across (a quarter round: the normal leans toward the road on the top and
// up on the face as either nears the arris), worn a little paler there. Every derivative is taken before a branch.
void surfKerb(vec2 uv, vec3 wp, vec3 N, inout vec3 alb, inout vec3 n, inout vec3 arm) {
  float g = u_surf_e.z, r = u_surf_e.w;
  float d = min(uv.x, uv.y);
  vec2 dd = vec2(dFdx(d), dFdy(d));
  vec3 px = dFdx(wp), py = dFdy(wp);
  float fh = length(vec2(px.y, py.y)) / max(length(vec2(dFdx(uv.y), dFdy(uv.y))), 1e-6);   // a face's height (m) from its v
  float aa = max(length(dd), 1e-4);
  float along = surfNoise(wp.xz * 1.7, 1024.0) * 0.6 + surfNoise(wp.xz * 7.0, 1024.0) * 0.4;
  // the road's own frame: the way to the kerb (the distance's gradient, solved from the screen derivatives of place and distance) and
  // along it; world metres from the surface's origin offset (whole tiles: a rebase moves nothing)
  mat2 sm = mat2(px.x, py.x, px.z, py.z);
  float sdet = sm[0][0] * sm[1][1] - sm[0][1] * sm[1][0];
  vec2 grad = abs(sdet) > 1e-10 ? inverse(sm) * dd : vec2(0.0);
  vec2 q = wp.xz + u_surf.zw * u_surf.x;
  if (g > 0.0) {
    vec2 gn = length(grad) > 1e-6 ? normalize(grad) : vec2(1.0, 0.0);
    vec2 tg = vec2(-gn.y, gn.x);
    float s = dot(q, tg) + 97.0 * surfHash(floor(vec2(atan(tg.y, tg.x) * 4.0, 0.5)), 1024.0);
    // repair patches: rectangles of fresher, darker asphalt with a sealed seam, set square to the kerb in the lanes (a cell of 16 m
    // along and 3.5 m across, a fifth of them patched)
    float pa = s / 16.0;
    float pd = (d - g - 0.15) / 3.5;
    vec2 pc = vec2(floor(pa), floor(pd));
    float ph = surfHash(pc + 17.0, 1024.0);
    if (pd >= 0.0 && ph < 0.2) {
      vec2 lo = vec2(0.1 + 0.4 * surfHash(pc + 3.0, 1024.0), 0.05 + 0.3 * surfHash(pc + 5.0, 1024.0));
      vec2 hi = lo + vec2(0.15 + 0.3 * surfHash(pc + 7.0, 1024.0), 0.35 + 0.3 * surfHash(pc + 11.0, 1024.0));
      vec2 f = vec2(fract(pa), fract(pd));
      vec2 m2 = vec2(16.0, 3.5);
      vec2 e = min(f - lo, hi - f) * m2;                  // metres inside the patch's edges (negative outside)
      // a lane's repair stops at the middle of the road (the two kerbs' distances add to its width), so the two sides' never cross
      float inside = min(min(e.x, e.y), 0.5 * (uv.x + uv.y) - 0.15 - d);
      float pw = max(fwidth(inside), 1e-4);
      float in1 = smoothstep(-pw, pw, inside);
      float seam = 1.0 - smoothstep(0.02, 0.05 + pw, abs(inside));
      alb = mix(alb, mix(vec3(dot(alb, vec3(0.333))), alb, 0.5) * 0.72, in1);
      arm.g = mix(arm.g, arm.g * 0.9, in1);
      alb *= 1.0 - 0.5 * seam;
    }
    float pan = 1.0 - smoothstep(g - aa, g + aa, d);
    float l = dot(alb, vec3(0.2126, 0.7152, 0.0722));
    vec3 concrete = mix(vec3(l), alb, 0.25) * 1.9;
    alb = mix(alb, concrete, pan);
    arm.g = mix(arm.g, arm.g * 0.92, pan);
    n = normalize(mix(n, N, 0.5 * pan));
    float joint = 1.0 - smoothstep(0.0, 0.012 + aa, abs(d - g));
    alb *= 1.0 - 0.45 * joint;
    float grime = (1.0 - smoothstep(0.0, 0.05 + 0.05 * along, d)) * 0.45;
    float fringe = smoothstep(g, g + 0.05, d) * (1.0 - smoothstep(g + 0.1, g + 0.45 + 0.25 * along, d)) * 0.18 * along;
    alb *= 1.0 - grime - fringe;
    // gully grates in the gutter, one each 28 m along the kerb: an iron frame round bars across the flow, black between them
    float ga = mod(s, 28.0);
    if (ga < 0.6 && d > 0.02 && d < g) {
      float fr = min(min(ga, 0.6 - ga), min(d - 0.02, g - d));
      float bar = step(0.5, fract(ga * 22.0));
      vec3 iron = vec3(0.075, 0.068, 0.06) * (0.8 + 0.4 * along);
      bool frame = fr < 0.035;
      alb = frame ? iron * 1.2 : mix(vec3(0.006), iron, bar);
      arm = vec3(frame ? 1.0 : mix(0.2, 1.0, bar), 0.55, 0.5);
      if (!frame) n = normalize(N + vec3(tg.x, 0.0, tg.y) * (bar - 0.5) * 0.15);
    }
    // manholes: round cast-iron covers, one candidate a 14 m cell of the world (four in five kept), drawn where the whole cover lies 1.6 m or more from a kerb
    // (the distance at its middle carried straight from this pixel: exact on a strip, where the distance is linear)
    vec2 cell = floor(q / 14.0);
    vec2 mc = (cell + 0.15 + 0.7 * vec2(surfHash(cell + 31.0, 1024.0), surfHash(cell + 47.0, 1024.0))) * 14.0;
    vec2 dv = q - mc;
    float rr = length(dv);
    float dmid = d + dot(grad, mc - q);
    if (rr < 0.37 && dmid > 1.6 && dmid < 9.0 && surfHash(cell + 59.0, 1024.0) < 0.8) {
      float rw = max(fwidth(rr), 1e-4);
      float ang = surfHash(cell + 71.0, 1024.0) * 6.2832;
      vec2 rp = mat2(cos(ang), sin(ang), -sin(ang), cos(ang)) * dv;
      // the cover's raised grid of studs, its frame, the gap between them, the tar ring the frame is set in
      vec2 cg = abs(fract(rp * 14.0) - 0.5);
      float stud = step(max(cg.x, cg.y), 0.28);
      // cast iron worn by traffic: its studs polished paler, the cover rust-browner than the asphalt round it
      vec3 iron = vec3(0.13, 0.105, 0.085) * (0.8 + 0.4 * along);
      float cover = 1.0 - smoothstep(0.295 - rw, 0.295 + rw, rr);
      float gap = smoothstep(0.29, 0.297, rr) * (1.0 - smoothstep(0.303, 0.31, rr));
      float frame = smoothstep(0.305 - rw, 0.305 + rw, rr) * (1.0 - smoothstep(0.335 - rw, 0.335 + rw, rr));
      float tar = smoothstep(0.335 - rw, 0.335 + rw, rr) * (1.0 - smoothstep(0.365 - rw, 0.37, rr));
      vec3 c = mix(iron, vec3(0.2, 0.19, 0.18), stud * cover);
      vec3 base = alb;
      alb = mix(base, c, cover + frame);
      alb = mix(alb, vec3(0.008), gap);
      alb = mix(alb, base * 0.55, tar);
      float metal = (cover + frame) * 0.6;
      arm = vec3(mix(arm.r, 1.0, cover + frame), mix(arm.g, 0.5 - 0.15 * stud * cover, cover + frame), mix(arm.b, metal, cover + frame));
      n = normalize(mix(n, N, clamp(cover + frame, 0.0, 1.0)));   // cast iron: flat, not the asphalt's grain
    }
  }
  if (r > 0.0) {
    if (N.y > 0.5) {
      if (d < r && length(grad) > 1e-6) {
        float a = asin(clamp(1.0 - d / r, 0.0, 1.0)) * 0.9;
        vec2 to = -normalize(grad);
        n = normalize(n * cos(a) + vec3(to.x, 0.0, to.y) * sin(a));
        alb *= 1.0 + 0.08 * (1.0 - d / r);
      }
    } else if (abs(N.y) < 0.5) {
      float top = (1.0 - uv.y) * fh;
      float foot = uv.y * fh;
      if (top < r) {
        float a = asin(clamp(1.0 - top / r, 0.0, 1.0)) * 0.9;
        n = normalize(n * cos(a) + vec3(0.0, 1.0, 0.0) * sin(a));
        alb *= 1.0 + 0.08 * (1.0 - top / r);
      }
      alb *= 1.0 - 0.2 * (1.0 - smoothstep(0.0, 0.05 + 0.03 * along, foot));
    }
  }
}
