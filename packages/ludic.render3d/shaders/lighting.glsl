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
vec3 skyIrradianceRaw(vec3 n) { return texture(u_irradiance, equirectUV(n)).rgb * u_ibl_scale; }
// The ground's light is the scene's own ground (u_ground_alb, the low ground: what bounce reads too).
// A surface tilted down still sees (1 + n.y) / 2 of the sky, so the window never gives it less: cut to
// nothing by n.y = -0.25, every jaw, neck and hanging arm was lit by the ground alone and came out olive.
vec3 skyIrradiance(vec3 n) {
  vec3 up = skyIrradianceRaw(vec3(n.x, max(n.y, 0.0), n.z));
  vec3 ground = skyIrradianceRaw(normalize(vec3(n.x, 0.15, n.z) + vec3(1e-4, 0.0, 0.0))) * groundTone(u_ground_alb);
  return mix(ground, up, max(smoothstep(-0.25, 0.2, n.y), clamp(0.5 + 0.5 * n.y, 0.0, 1.0)));
}
vec3 skyPrefilteredRaw(vec3 r, float rough) {
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
  float tanT = min(sqrt(max(1.0 - NoL * NoL, 0.0)) / max(NoL, 0.05), 10.0);
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

// direct + image-based lighting for one surface
vec3 shade(vec3 wpos, vec3 n, vec3 albedo, float rough, float metal, float ao, float shadow, float viewDepth) {
  vec3 v = normalize(u_cam_pos - wpos);
  vec3 l = u_sun_dir;
  vec3 h = normalize(v + l);
  float NoV = max(dot(n, v), 1e-2);
  float NoL = max(dot(n, l), 0.0);
  float NoH = max(dot(n, h), 0.0);
  float VoH = max(dot(v, h), 0.0);
  rough = clamp(rough, 0.045, 1.0);
  float a = rough * rough;
  vec3 f0 = mix(vec3(0.04), albedo, metal);
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
  vec3 irr = skyIrradiance(n);
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
  // check for NaN before min(): on this GPU min(NaN, x) returns x, which would hide the fault as a hot pixel
  vec3 c = direct + (diffuseIBL * ao + specIBL * so) + bounce * ao + zoneAmb * ao + (fireLight(wpos, n, albedo) + handLight(wpos, n, albedo)) * ao;
  if (any(isnan(direct)) || any(isnan(diffuseIBL)) || any(isnan(specIBL)) || isnan(so)) return vec3(0.0);
  return sane(min(c, vec3(4096.0)));
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
