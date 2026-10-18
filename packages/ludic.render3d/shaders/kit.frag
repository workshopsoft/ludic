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
in float v_h;
in float v_top;
out vec4 o_color;
uniform sampler2D u_diff;
uniform vec4 u_fac_base_inv;
uniform vec2 u_fac_mr_inv;
uniform vec3 u_fac_emis;
uniform sampler2D u_nrm;
uniform sampler2D u_arm;
uniform mat4 u_view;
uniform float u_rough_scale;
uniform vec2 u_storey;           // a line every x metres up the walls from the instance's base (0: none), y metres thick

// 1 on a storey line of an upright face, 0 between them. A box instance's lines hang from its top (its own h, the eave) every u_storey.x
// metres down to its base, so a plinth under the building (its base lower than its pad) shifts nothing: the lines are every storey up from
// the pad and the last one is the eave. Another kit's count from its base. A line is u_storey.y thick, the first is not within half a storey
// of the foot (that is the ground's edge, not a floor), and faces that look up or down (roofs) have none. The edge is as wide as a pixel is
// (fwidth), and a line thinner than a pixel fades out rather than shimmers.
float storeyLine(float h, float top, float ny) {
  float s = u_storey.x;
  if (s <= 0.0 || abs(ny) > 0.5) return 0.0;
  bool boxed = top >= 0.0;
  float down = boxed ? top - h : h;
  float line = u_storey.y;
  if (boxed && down < -0.5 * line) return 0.0;
  float k = max(floor(down / s + 0.5), boxed ? 0.0 : 1.0);
  float aa = max(fwidth(h), 1e-4);
  float edge = 1.0 - smoothstep(0.5 * line - aa, 0.5 * line + aa, abs(down - k * s));
  float seen = 1.0 - smoothstep(line, 2.0 * line, aa);
  return edge * seen * step(0.5 * s, h);
}

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

#ifdef FACADE
// ---- FACADE: a window grid fitted to each wall of a box instance (fac.ludic is the reference of this arithmetic) ----
in vec3 v_box;
in vec2 v_flags;
uniform vec4 u_fac_a;            // bay, glass share of a bay, sill, head (m over the storey's floor)
uniform vec4 u_fac_b;            // pier (m), upright bars, level bars, reveal depth (m)
uniform vec4 u_fac_c;            // ground storey mode (0 windows, 1 shopfront, 2 doors, 3 blank), spandrel darkening, storey height, rooms on
uniform vec4 u_fac_d;            // shopfront glass bottom, top (m), the rooms' distance, frame width (m)
uniform vec4 u_fac_e;            // the frames' tone

// what a point of a wall is: 0 wall, 1 glass, 2 frame or bar, 3 the opening's reveal, 4 a sill, 5 a shop's fascia
struct Fac { int kind; vec2 q; vec2 size; ivec2 cell; int wall; float shade; float bay; };

Fac facadeAt(vec3 ray) {
  Fac f;
  f.kind = 0; f.q = vec2(0.0); f.size = vec2(1.0); f.cell = ivec2(0); f.wall = -1; f.shade = 1.0; f.bay = 1.0;
  int wall = imiWall(normalize(v_lnrm));
  if (wall < 0 || v_box.x <= 0.0) return f;
  int flags = int(v_flags.x + 0.5) | (int(v_flags.y + 0.5) << 12);
  if (((flags >> wall) & 1) != 0) return f;
  f.wall = wall;
  float L = wall < 2 ? v_box.y : v_box.x;
  vec3 on = imiWallNormal(wall);
  vec3 tng = normalize(cross(vec3(0.0, 1.0, 0.0), on));
  float u = dot(v_lpos, tng) + 0.5 * L;
  float y = v_lpos.y;
  float h = v_box.z;
  float s = u_fac_c.z;
  if (s <= 0.0 || y >= h || y < 0.0) return f;
  int floors = (flags >> 4) & 127;
  int fit = int(floor((h + 0.02) / s));
  int rows = floors > 0 ? min(fit, floors) : fit;
  int k = int(floor((h - y) / s));
  if (k >= rows) return f;
  float yy = y - (h - float(k + 1) * s);
  bool ground = k == rows - 1;
  int gmode = int(u_fac_c.x + 0.5);
  bool shop = ground && gmode == 1;
  if (ground && gmode == 3) return f;
  float bay = u_fac_a.x, pier = u_fac_b.x;
  if (shop) pier = min(pier, 0.35);
  float span = L - 2.0 * pier;
  if (bay <= 0.0 || span < 0.5 * bay) return f;
  // a shopfront's fascia: the band from the glass's head to the storey above, end to end
  if (shop && yy > min(u_fac_d.y, s - 0.35) + 0.04 && u > 0.12 && u < L - 0.12) { f.kind = 5; return f; }
  int n = max(1, int(floor(span / bay + 0.5)));
  float cw = span / float(n);
  float cu = u - pier;
  f.bay = cw;
  float gw, g0, g1;
  if (shop) { gw = cw - 0.24; g0 = u_fac_d.x; g1 = min(u_fac_d.y, s - 0.35); }
  else { gw = cw * u_fac_a.y; g0 = u_fac_a.z; g1 = min(u_fac_a.w, s - 0.3); }
  // a curtain wall's spandrels: the wall between two rows of glass a little darker
  if (!shop && (yy < g0 || yy > g1)) f.shade = 1.0 - u_fac_c.y;
  if (cu < 0.0 || cu >= span) return f;
  int ci = min(int(floor(cu / cw)), n - 1);
  float lu = cu - float(ci) * cw;
  float gx0 = 0.5 * (cw - gw);
  float gh = g1 - g0;
  if (gh <= 0.1 || gw <= 0.1) return f;
  // a door on this wall's ground storey: no glass where it stands (a shopfront keeps its glass beside it)
  if (ground && (flags & 2048) != 0 && ((flags >> 12) & 3) == wall) {
    float du = float((flags >> 14) & 1023) * 0.1;
    float bx0 = pier + float(ci) * cw + gx0;
    if (shop) { if (abs(u - du) < 0.8) return f; }
    else if (bx0 + gw > du - 0.95 && bx0 < du + 0.95) return f;
  }
  float a = lu - gx0, b = yy - g0;
  // the sill: a lighter ledge under the opening
  if (!shop && b < 0.0 && b > -0.07 && a > -0.07 && a < gw + 0.07) { f.kind = 4; return f; }
  if (a < 0.0 || a > gw || b < 0.0 || b > gh) return f;
  // into the opening: the glass sits `reveal` behind the wall, so the ray meets its plane further on; short of it, the reveal
  float r = u_fac_b.w;
  vec3 d = vec3(dot(ray, tng), ray.y, -dot(ray, on));
  vec2 q = vec2(a, b);
  if (r > 0.0 && d.z > 0.02) {
    q += d.xy * (r / d.z);
    if (q.x < 0.0 || q.x > gw || q.y < 0.0 || q.y > gh) {
      f.kind = 3;
      f.shade = q.y > gh ? 0.45 : (q.y < 0.0 ? 0.85 : 0.65);
      return f;
    }
  }
  float fw = u_fac_d.w;
  f.q = q; f.size = vec2(gw, gh); f.cell = ivec2(ci, rows - 1 - k);
  if (q.x < fw || q.x > gw - fw || q.y < fw || q.y > gh - fw) { f.kind = 2; return f; }
  int nm = int(u_fac_b.y + 0.5), nt = int(u_fac_b.z + 0.5);
  if (shop) nm = max(nm, 1);
  for (int i = 1; i <= 8; i++) {
    if (i > nm) break;
    if (abs(q.x - gw * float(i) / float(nm + 1)) < 0.5 * fw) { f.kind = 2; return f; }
  }
  for (int i = 1; i <= 8; i++) {
    if (i > nt) break;
    if (abs(q.y - gh * float(i) / float(nt + 1)) < 0.5 * fw) { f.kind = 2; return f; }
  }
  f.kind = 1;
  return f;
}

// the room behind a window's glass (or, past the rooms' distance, flat glass lit as the room would be): rgb
vec3 facadeRoom(Fac f, vec3 ray, float lod, bool rays) {
  vec3 on = imiWallNormal(f.wall);
  vec3 tng = normalize(cross(vec3(0.0, 1.0, 0.0), on));
  vec3 d = vec3(dot(ray, tng), ray.y, -dot(ray, on));
  uint seed = uint(int(v_tint.w));
  uint wall = uint(f.wall);
  int cx = f.cell.x, cy = f.cell.y;
  float night = imiNight(u_sun_dir.y);
  bool lit = imiUnit(imiHash(seed, wall, cx, cy, 1u)) < night * u_im_atlas.w;
  bool curtain = imiUnit(imiHash(seed, wall, cx, cy, 2u)) < u_im_gain.z;
  vec3 amb = skyIrradiance(vec3(0.0, 1.0, 0.0));
  float dayGain = mix(1.0, u_im_gain.y, night);
  vec3 tex;
  if (!rays || u_fac_c.w < 0.5 || d.z < 0.0001) {
    // flat: a room's average grey, a little darker near the top of the glass (the ceiling's shade)
    float t = imiUnit(imiHash(seed, wall, cx, cy, 0u));
    tex = vec3(0.30 + 0.12 * t) * (0.8 + 0.2 * f.q.y / max(f.size.y, 0.01));
  } else if (curtain) {
    float t = imiUnit(imiHash(seed, wall, cx, cy, 3u));
    tex = mix(vec3(0.62, 0.60, 0.56), vec3(0.48, 0.50, 0.53), t) * (0.75 + 0.25 * f.q.y / f.size.y);
  } else {
    float rooms = u_im_atlas.z;
    int room = min(int(imiUnit(imiHash(seed, wall, cx, cy, 0u)) * rooms), int(rooms) - 1);
    vec4 hit = imiHit(vec3(f.size.x, f.size.y, u_im_cell.w), f.q.x, f.q.y, d);
    tex = textureLod(u_rooms, imiAtlasUv(room, int(hit.x + 0.5), hit.yz, 0.01), lod).rgb;
  }
  vec3 col = tex * amb * 0.45 * dayGain;
  if (lit) col += tex * u_im_lit * u_im_gain.x * night;
  return col;
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
  alb *= 1.0 - 0.45 * storeyLine(v_h, v_top, N.y);
  float shadow = sunShadow(v_wpos, N, viewDepth);
  float roughF = clamp(arm.g * u_rough_scale, 0.35, 1.0);
  float ao = arm.r;
#ifdef FACADE
  // the derivatives first, where every invocation of the quad is still running
  float pxm = length(fwidth(v_lpos));
  float lod = clamp(log2(max(pxm, 1e-5) / max(u_im_gain.w, 1e-4)), 0.0, 6.0);
  vec3 fray = normalize(v_lpos - v_lcam);
  Fac fa = facadeAt(fray);
  vec3 glow = vec3(0.0);
  // a bay smaller than a few pixels: the grid fades to the wall darkened by what its glass would take (no shimmer far off)
  float gone = smoothstep(0.12 * fa.bay, 0.35 * fa.bay, pxm);
  if (fa.kind == 1) {
    vec3 v = normalize(u_cam_pos - v_wpos);
    float fres = 0.04 + 0.96 * pow(1.0 - max(dot(N, v), 0.0), 5.0);
    vec3 room = facadeRoom(fa, fray, lod, dist < u_fac_d.z);
    alb = mix(vec3(0.02), alb * 0.6, gone);
    roughF = mix(0.06, roughF, gone);
    n = N;
    ao = 1.0;
    glow = room * (1.0 - fres) * (1.0 - 0.6 * gone);
  } else if (fa.kind == 2) {
    alb = mix(u_fac_e.rgb, alb * 0.7, gone);
  } else if (fa.kind == 3) {
    alb *= mix(fa.shade, 0.8, gone);
  } else if (fa.kind == 4) {
    alb = mix(min(alb * 1.22, vec3(1.0)), alb, gone);
  } else if (fa.kind == 5) {
    alb = mix(u_fac_e.rgb * 1.4, alb, gone * 0.5);
  } else {
    alb *= mix(fa.shade, 1.0, gone);
  }
#elif defined(INTERIOR_MAP)
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
#if defined(INTERIOR_MAP) || defined(FACADE)
  col += glow;
#endif
  col += u_fac_emis;
  col = applyFog(col, v_wpos, dist);
  o_color = vec4(sane(col), 1.0);
}
