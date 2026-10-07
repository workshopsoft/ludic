// kit.frag - a building kit's surface: the glTF material lit as model.frag lights a mesh, times the instance's tint and
// a little per-instance variation; with INTERIOR_MAP the window cells of the facade show a room behind the glass
// (interior mapping: imi.ludic is the reference of the arithmetic here, and its tests hold the room choice, the lights
// and the ray-box to the properties the look depends on).
in vec3 v_wpos;
in vec3 v_nrm;
in vec2 v_uv;
in vec4 v_tint;
in vec4 v_col;
in float v_seed;
out vec4 o_color;
uniform sampler2D u_diff;
uniform vec4 u_fac_base_inv;
uniform vec2 u_fac_mr_inv;
uniform vec3 u_fac_emis;
uniform sampler2D u_nrm;
uniform sampler2D u_arm;
uniform mat4 u_view;
uniform float u_rough_scale;

mat3 cotangentFrame(vec3 N, vec3 p, vec2 uv) {
  vec3 dp1 = dFdx(p), dp2 = dFdy(p);
  vec2 duv1 = dFdx(uv), duv2 = dFdy(uv);
  vec3 dp2perp = cross(dp2, N), dp1perp = cross(N, dp1);
  vec3 T = dp2perp * duv1.x + dp1perp * duv2.x;
  vec3 B = dp2perp * duv1.y + dp1perp * duv2.y;
  float invmax = inversesqrt(max(dot(T, T), dot(B, B)) + 1e-12);
  return mat3(T * invmax, B * invmax, N);
}

#ifdef INTERIOR_MAP
in vec3 v_lpos;
in vec3 v_lnrm;
in vec3 v_lcam;
uniform sampler2D u_rooms;       // the atlas: room tiles, six faces each in a 3 x 2 block (interior_atlas.ludic)
uniform vec4 u_im_cell;          // window cell width, height (m), frame share, room depth (m)
uniform vec4 u_im_atlas;         // tiles across, tiles down, rooms painted, the share of rooms lit at full night
uniform vec4 u_im_gain;          // lit gain, dark gain, curtain share, texel size of a room face (m)
uniform vec3 u_im_lit;           // the warm colour of a lit room

// imi.ludic's imi_pcg, imi_hash, imi_unit, imi_room, imi_night, imi_wall, imi_hit, imi_atlas_uv, line for line
uint imiPcg(uint v) {
  uint s = v * 747796405u + 2891336453u;
  uint w = ((s >> ((s >> 28u) + 4u)) ^ s) * 277803737u;
  return (w >> 22u) ^ w;
}
uint imiHash(uint seed, uint wall, int cx, int cy, uint salt) {
  uint h = imiPcg((seed * 73856093u) ^ (wall * 19349663u));
  h = imiPcg(h ^ (uint(cx + 32768) * 83492791u));
  h = imiPcg(h ^ (uint(cy + 32768) * 668265263u));
  return imiPcg(h ^ (salt * 1597334677u));
}
float imiUnit(uint h) { return float((h >> 8u) & 0xffffffu) / 16777216.0; }
float imiNight(float sunY) {
  float t = clamp((0.06 - sunY) / 0.20, 0.0, 1.0);
  return t * t * (3.0 - 2.0 * t);
}
// the wall a model-space normal is: 0 +x, 1 -x, 2 +z, 3 -z, -1 none
int imiWall(vec3 n) {
  if (abs(n.y) > 0.35) return -1;
  if (n.x > 0.9) return 0;
  if (n.x < -0.9) return 1;
  if (n.z > 0.9) return 2;
  if (n.z < -0.9) return 3;
  return -1;
}
vec3 imiWallNormal(int wall) {
  if (wall == 0) return vec3(1.0, 0.0, 0.0);
  if (wall == 1) return vec3(-1.0, 0.0, 0.0);
  if (wall == 2) return vec3(0.0, 0.0, 1.0);
  return vec3(0.0, 0.0, -1.0);
}
// the ray from (px, py, 0) on the glass heading d (z into the room) out of the room's box: x the face, y and z its uv, w the distance
vec4 imiHit(vec3 room, float px, float py, vec3 d) {
  float t = 1.0e9;
  int face = 4;
  if (d.z > 1e-6) t = room.z / d.z;
  if (d.x > 1e-6) { float tx = (room.x - px) / d.x; if (tx < t) { t = tx; face = 1; } }
  else if (d.x < -1e-6) { float tx = -px / d.x; if (tx < t) { t = tx; face = 0; } }
  if (d.y > 1e-6) { float ty = (room.y - py) / d.y; if (ty < t) { t = ty; face = 3; } }
  else if (d.y < -1e-6) { float ty = -py / d.y; if (ty < t) { t = ty; face = 2; } }
  vec3 h = vec3(px + d.x * t, py + d.y * t, d.z * t);
  vec2 uv;
  if (face == 4) uv = vec2(h.x / room.x, h.y / room.y);
  else if (face == 0 || face == 1) uv = vec2(1.0 - h.z / room.z, h.y / room.y);
  else uv = vec2(h.x / room.x, 1.0 - h.z / room.z);
  return vec4(float(face), clamp(uv, 0.0, 1.0), t);
}
vec2 imiFaceCell(int face) {
  if (face == 0) return vec2(0.0, 0.0);
  if (face == 4) return vec2(1.0, 0.0);
  if (face == 1) return vec2(2.0, 0.0);
  if (face == 3) return vec2(0.0, 1.0);
  return vec2(1.0, 1.0);
}
vec2 imiAtlasUv(int room, int face, vec2 uv, float eps) {
  vec2 fc = imiFaceCell(face);
  float cols = u_im_atlas.x, rows = u_im_atlas.y;
  float tx = float(room % int(cols)), ty = float(room / int(cols));
  vec2 q = vec2(eps) + uv * (1.0 - 2.0 * eps);
  return vec2((tx + (fc.x + q.x) / 3.0) / cols, (ty + (fc.y + q.y) / 2.0) / rows);
}
// what a window shows: the room behind it lit as it is (returns rgb; a = 1 when this point is glass)
vec4 interiorAt(float lod) {
  int wall = imiWall(normalize(v_lnrm));
  if (wall < 0) return vec4(0.0);
  vec3 on = imiWallNormal(wall);
  vec3 tng = normalize(cross(vec3(0.0, 1.0, 0.0), on));
  float fu = dot(v_lpos, tng);
  float fv = v_lpos.y;
  vec2 cell = floor(vec2(fu / u_im_cell.x, fv / u_im_cell.y));
  vec2 loc = vec2(fu, fv) - cell * u_im_cell.xy;
  float fr = u_im_cell.z;
  if (loc.x < fr * u_im_cell.x || loc.x > (1.0 - fr) * u_im_cell.x || loc.y < fr * u_im_cell.y || loc.y > (1.0 - fr) * u_im_cell.y) return vec4(0.0);
  vec3 ray = normalize(v_lpos - v_lcam);
  vec3 d = vec3(dot(ray, tng), ray.y, -dot(ray, on));
  if (d.z < 0.0001) return vec4(0.0);
  uint seed = uint(int(v_tint.w));
  int cx = int(cell.x);
  int cy = int(cell.y);
  float rooms = u_im_atlas.z;
  int room = min(int(imiUnit(imiHash(seed, uint(wall), cx, cy, 0u)) * rooms), int(rooms) - 1);
  float night = imiNight(u_sun_dir.y);
  bool lit = imiUnit(imiHash(seed, uint(wall), cx, cy, 1u)) < night * u_im_atlas.w;
  bool curtain = imiUnit(imiHash(seed, uint(wall), cx, cy, 2u)) < u_im_gain.z;
  vec4 hit = imiHit(vec3(u_im_cell.x, u_im_cell.y, u_im_cell.w), loc.x, loc.y, d);
  vec3 tex;
  if (curtain) {
    float t = imiUnit(imiHash(seed, uint(wall), cx, cy, 3u));
    tex = mix(vec3(0.42, 0.34, 0.26), vec3(0.30, 0.36, 0.44), t) * (0.75 + 0.25 * loc.y / u_im_cell.y);
  } else {
    tex = textureLod(u_rooms, imiAtlasUv(room, int(hit.x + 0.5), hit.yz, 0.01), lod).rgb;
  }
  // by day the room shows its own look under the sky's light; at night an unlit room is dark and a lit one glows warm
  vec3 amb = skyIrradiance(vec3(0.0, 1.0, 0.0));
  float dayGain = mix(1.0, u_im_gain.y, night);
  vec3 col = tex * amb * 0.45 * dayGain;
  if (lit) col += tex * u_im_lit * u_im_gain.x * night;
  return vec4(col, 1.0);
}
#endif

void main() {
  if (v_wpos.y < u_clip_y) discard;
#ifndef SHADOW_PASS
  if (fogCut(v_wpos)) discard;   // the fog wall's dissolve (lighting.glsl)
#endif
  vec3 N = normalize(v_nrm);
  if (!gl_FrontFacing) N = -N;
  float dist = length(v_wpos - u_cam_pos);
  float viewDepth = -(u_view * vec4(v_wpos, 1.0)).z;
  vec4 d = texture(u_diff, v_uv) * (vec4(1.0) - u_fac_base_inv) * v_col;
  vec3 tn = texture(u_nrm, v_uv).rgb * 2.0 - 1.0;
  mat3 tbn = cotangentFrame(N, v_wpos, v_uv);
  vec3 n = normalize(tbn * tn);
  vec3 arm = texture(u_arm, v_uv).rgb;
  arm.gb *= vec2(1.0) - u_fac_mr_inv;
  n = normalize(mix(n, N, smoothstep(30.0, 120.0, dist)));
  vec3 alb = d.rgb * v_tint.rgb * (0.92 + 0.16 * fract(v_seed * 7.13));
  float shadow = sunShadow(v_wpos, N, viewDepth);
  float roughF = clamp(arm.g * u_rough_scale, 0.35, 1.0);
  float ao = arm.r;
#ifdef INTERIOR_MAP
  // the derivative first, where every invocation of the quad is still running
  float pxm = length(fwidth(v_lpos));
  float lod = clamp(log2(max(pxm, 1e-5) / max(u_im_gain.w, 1e-4)), 0.0, 6.0);
  vec4 room = interiorAt(lod);
  vec3 glow = vec3(0.0);
  if (room.a > 0.5) {
    // glass: a dark, glossy, nearly-clear surface; what is behind it shows through by what the glass does not reflect
    vec3 v = normalize(u_cam_pos - v_wpos);
    float fres = 0.04 + 0.96 * pow(1.0 - max(dot(N, v), 0.0), 5.0);
    alb = vec3(0.02);
    roughF = 0.06;
    n = N;
    ao = 1.0;
    glow = room.rgb * (1.0 - fres);
  }
#endif
  vec3 col = shade(v_wpos, n, alb, roughF, 0.0, ao, shadow, viewDepth);
#ifdef INTERIOR_MAP
  col += glow;
#endif
  col += u_fac_emis;
  col = applyFog(col, v_wpos, dist);
  o_color = vec4(sane(col), 1.0);
}
