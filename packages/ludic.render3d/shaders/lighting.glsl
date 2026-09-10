// ---- PBR + IBL + cascaded shadows + aerial perspective (shared) ---------------------
uniform sampler2D u_irradiance;          // equirect, diffuse-convolved sky
uniform sampler2DArray u_prefilter;      // equirect, GGX-prefiltered sky per roughness level
uniform sampler2D u_brdf;                // split-sum BRDF LUT
#define CASCADES 5
uniform sampler2DArrayShadow u_shadow;   // CASCADES layers
float shadowTap(vec2 uv, int c, float ref) { return texture(u_shadow, vec4(uv, float(c), ref)); }
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
const vec3 GROUND_ALB = vec3(0.30, 0.34, 0.14);
// the time of day (daylight.ludic): the sky's light scaled toward night, and the campfire
uniform vec3 u_ibl_scale;
uniform float u_daylight;
uniform vec3 u_fire_pos;
uniform vec3 u_fire_color;
uniform vec3 u_hand_pos;          // a torch or flashlight in the hand
uniform vec3 u_hand_color;
uniform vec3 u_hand_dir;
uniform float u_hand_cone;        // cos of the half-angle; <= -1: a point light
vec3 skyIrradianceRaw(vec3 n) { return texture(u_irradiance, equirectUV(n)).rgb * u_ibl_scale; }
vec3 skyIrradiance(vec3 n) {
  vec3 up = skyIrradianceRaw(vec3(n.x, max(n.y, 0.0), n.z));
  vec3 ground = skyIrradianceRaw(normalize(vec3(n.x, 0.15, n.z) + vec3(1e-4, 0.0, 0.0))) * GROUND_ALB;
  return mix(ground, up, smoothstep(-0.25, 0.2, n.y));
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
  float att = smoothstep(26.0, 6.0, sqrt(r2)) / (0.5 + r2 * 0.35);
  if (u_hand_cone > -1.0) {
    float c = dot(-l, u_hand_dir);
    att *= smoothstep(u_hand_cone, u_hand_cone + 0.12, c);
  }
  return albedo / PI * u_hand_color * max(dot(n, l), 0.0) * att;
}
vec3 skyPrefiltered(vec3 r, float rough) {
  vec3 up = skyPrefilteredRaw(vec3(r.x, max(r.y, 0.0), r.z), rough);
  vec3 ground = skyPrefilteredRaw(normalize(vec3(r.x, 0.15, r.z) + vec3(1e-4, 0.0, 0.0)), max(rough, 0.6)) * GROUND_ALB;
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
  vec3 p = lp.xyz / lp.w * 0.5 + 0.5;
  if (p.x < 0.0 || p.x > 1.0 || p.y < 0.0 || p.y > 1.0 || p.z > 1.0) return 1.0;
  float bias = biasWorld / cascadeRange(c);
  float texel = 1.0 / 2048.0;
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
    s += shadowTap(p.xy + off, c, p.z - bias);
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
uniform sampler2D u_tershadow;
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
  vec2 s = texture(u_tershadow, uv).rg;
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
  vec3 p = lp.xyz / lp.w * 0.5 + 0.5;
  float s = 1.0;
  if (p.x >= 0.0 && p.x <= 1.0 && p.y >= 0.0 && p.y <= 1.0 && p.z <= 1.0) s = shadowTap(p.xy, c, p.z - (tx * 2.0 + 0.02) / cascadeRange(c));
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
// the mask is baked into the height-field shadow texture's B (tershadow.frag); the
// projection along the sun and the drift are a uv shift
float cloudShadow(vec3 wpos) {
  if (u_cloud_shadow <= 0.0 || u_ts_on < 0.5) return 1.0;
  float h = 1400.0 - wpos.y;
  vec2 c = wpos.xz + u_sun_dir.xz / max(u_sun_dir.y, 0.1) * h;
  c += vec2(u_time * 3.0, u_time * 1.2);
  vec2 uv = (c - u_ts_origin) / (2.0 * u_ts_half) + 0.5;
  if (uv.x < 0.0 || uv.x > 1.0 || uv.y < 0.0 || uv.y > 1.0) return 1.0;
  return 1.0 - u_cloud_shadow * texture(u_tershadow, uv).b;
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
  vec3 direct = (kd * albedo / PI + spec) * u_sun_color * NoL * shadow * cloudShadow(wpos);
  // IBL
  vec3 Fr = F_SchlickRough(NoV, f0, rough);
  vec3 kdi = (1.0 - Fr) * (1.0 - metal);
  vec3 irr = skyIrradiance(n);
  vec3 diffuseIBL = kdi * albedo * irr;
  vec3 r = reflect(-v, n);
  vec3 pre = skyPrefiltered(r, rough);
  vec2 brdf = texture(u_brdf, vec2(NoV, rough)).rg;
  vec3 specIBL = pre * (Fr * brdf.x + brdf.y) * u_spec_scale;
  // one bounce off the sunlit ground onto whatever faces it (a warm fill from below)
  vec3 groundAlb = vec3(0.16, 0.2, 0.07);
  vec3 bounce = kdi * albedo * groundAlb * (u_sun_color * max(u_sun_dir.y, 0.0) / PI + irr) * clamp(0.5 - 0.5 * n.y, 0.0, 1.0) * 0.5;
  // specular occlusion from ao
  float so = clamp(pow(NoV + ao, exp2(-16.0 * rough - 1.0)) - 1.0 + ao, 0.0, 1.0);
  // check for NaN before min(): on this GPU min(NaN, x) returns x, which would hide the fault as a hot pixel
  vec3 c = direct + (diffuseIBL * ao + specIBL * so) + bounce * ao + (fireLight(wpos, n, albedo) + handLight(wpos, n, albedo)) * ao;
  if (any(isnan(direct)) || any(isnan(diffuseIBL)) || any(isnan(specIBL)) || isnan(so)) return vec3(0.0);
  return sane(min(c, vec3(4096.0)));
}

// aerial perspective: exponential height fog toward the horizon sky, with sun inscatter
vec3 applyFog(vec3 col, vec3 wpos, float dist) {
  vec3 dir = normalize(wpos - u_cam_pos);
  float hf = u_fog_height_falloff;
  float t = dir.y * hf;
  float integ = (abs(t) > 1e-4) ? (1.0 - exp(-dist * t)) / t : dist * (1.0 - 0.5 * dist * t);
  float fogAmt = u_fog_density * exp(-u_cam_pos.y * hf) * integ;
  float f = 1.0 - exp(-fogAmt);
  vec3 fogCol = skyPrefiltered(vec3(dir.x, max(dir.y, 0.02), dir.z), 0.6);
  float sunAmt = pow(max(dot(dir, u_sun_dir), 0.0), 8.0);
  fogCol += u_sun_color * 0.02 * sunAmt;
  return mix(col, fogCol, clamp(f, 0.0, 1.0));
}
