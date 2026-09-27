// Procedural ground-cover blades, generated on the GPU, with NO distance rings.
//
// The world is cut into 16 m cells. Blade j of a cell always stands at the same place
// (a hash of the cell and j), so a blade never moves. How many of a cell's blades exist
// is a smooth function of the blade's own distance to the camera: cell area over the
// square of a spacing that grows linearly with distance. Thinning removes the highest
// indices first, and a blade shrinks before it goes, so density is continuous in space
// and in time and nothing can form a boundary. Draws are per tile (CPU-side frustum
// culling, grass.ludic); a tile only decides how many indices to feed the shader.
layout(location = 0) in vec3 a_pos;      // x: -0.5..0.5 across, y: 0..1 along the blade, z: bend
layout(location = 2) in vec2 a_uv;
uniform mat4 u_view;
uniform mat4 u_proj;
uniform mat4 u_vp;
uniform vec3 u_cam_pos;
uniform float u_time;
uniform sampler2D u_ts_height;
uniform vec2 u_ts_origin;
uniform float u_ts_half;
uniform sampler2D u_ortho;
uniform float u_ortho_on;
uniform float u_lake_level;
uniform float u_sea_level;    // the sea (terrain_sea); the lake's level when there is no separate sea
uniform vec4 u_lake;          // the carved lake: centre x/z, half extents (z = 0: none)
uniform float u_snow_line;
uniform float u_wind;
uniform vec3 u_push;      // x, z, radius: a body standing in the grass
uniform vec2 u_tile;         // world xz of this tile's corner
uniform int u_tile_cells;    // 16 m cells per tile side
uniform int u_per_cell;      // indices drawn per cell in this tile
#ifdef TILES
uniform vec4 u_tiles[256];   // per tile of the draw: corner x, corner z, indices per cell
#endif
uniform float u_s0;          // blade spacing at the camera (m)
uniform float u_d0;          // distance at which the spacing has doubled (m)
uniform float u_radius;      // no blades past this
uniform float u_px;          // one pixel's height in radians: no blade is drawn narrower than a pixel
uniform int u_dbg;           // R3D_GRASS_DBG: 1 lift blades 0.3 m, 2 light as ground everywhere, 3 both
out vec3 v_wpos;
out vec3 v_nrm;
out vec2 v_uv;
out float v_seed;
out vec2 v_rot;
out float v_hull;
out float v_quake;   // only aspens quake; written so model.frag can read it
out vec3 v_tint;     // the blade's colour field at its root (model.frag's regionTint and patchiness, once a blade)

const float CELL = 4.0;   // grass.ludic GRASS_CELL: 4 m, so a near tile asks for what its blades need
// hash1 and fbm come from noise.glsl, which a GBLADE vertex stage is given (programs.ludic)
// An integer hash (PCG) for the per-blade values. The sine hash advanced linearly with
// the blade index, so a cell's blades fell into diagonal rows, and the rows read as
// streaks across the meadow with an edge wherever they thinned out.
uint pcg(uint v) { uint s = v * 747796405u + 2891336453u; uint w = ((s >> ((s >> 28u) + 4u)) ^ s) * 277803737u; return (w >> 22u) ^ w; }
float bladeHash(ivec2 cell, int j, int k) {
  uint h = pcg(uint(cell.x + 32768) * 73856093u ^ uint(cell.y + 32768) * 19349663u ^ uint(j) * 83492791u ^ uint(k) * 2654435761u);
  return float(h) * (1.0 / 4294967295.0);
}
float heightSmooth(sampler2D tex, vec2 uv) {
  vec2 res = vec2(textureSize(tex, 0));
  vec2 t = uv * res - 0.5;
  vec2 f = fract(t);
  vec2 i = floor(t);
  vec2 w0 = (1.0 - f) * (1.0 - f) * (1.0 - f) / 6.0;
  vec2 w1 = (4.0 - 6.0 * f * f + 3.0 * f * f * f) / 6.0;
  vec2 w3 = f * f * f / 6.0;
  vec2 w2 = 1.0 - w0 - w1 - w3;
  vec2 s0 = w0 + w1, s1 = w2 + w3;
  vec2 o0 = (i - 1.0 + w1 / s0 + 0.5) / res;
  vec2 o1 = (i + 1.0 + w3 / s1 + 0.5) / res;
  return (texture(tex, vec2(o0.x, o0.y)).r * s0.x + texture(tex, vec2(o1.x, o0.y)).r * s1.x) * s0.y
       + (texture(tex, vec2(o0.x, o1.y)).r * s0.x + texture(tex, vec2(o1.x, o1.y)).r * s1.x) * s1.y;
}
void cull() { gl_Position = vec4(0.0, 0.0, 2.0, 1.0); v_wpos = vec3(0.0); v_nrm = vec3(0.0, 1.0, 0.0); v_uv = vec2(0.0); v_seed = 0.0; v_rot = vec2(0.0, 1.0); v_hull = 1.0; v_quake = 0.0; v_tint = vec3(1.0); }
// lighting.glsl's regionTint(wpos, 0.35) times model.frag's patchiness, at the root: three fbm
// fields a blade pixel used to pay for, when the whole blade stands on one spot
vec3 bladeField(vec2 xz, float y) {
  float n = fbm(xz * 0.0018 + 4.0, 3) * 0.5 + 0.5;
  float aspen = smoothstep(0.52, 0.7, n) * smoothstep(520.0, 250.0, y);
  float dry = smoothstep(0.35, 0.15, fbm(xz * 0.004 + 9.0, 3) * 0.5 + 0.5);
  vec3 t = mix(vec3(1.0), vec3(1.25, 1.3, 0.85), aspen * 0.35);
  t = mix(t, vec3(1.15, 1.05, 0.7), dry * 0.35 * 0.6);
  float patchy = fbm(xz * 0.045, 3) * 0.5 + 0.5;
  t *= mix(vec3(0.7, 0.8, 0.55), vec3(1.1, 1.05, 0.85), patchy);
  // dry and green patches a few metres across, and the tussocks' own shade of the same green
  float dryp = smoothstep(0.2, 0.8, gnoise(xz * 0.33 + 17.0) * 0.5 + 0.5);
  t *= mix(vec3(0.92, 1.0, 0.95), vec3(1.30, 1.10, 0.62), dryp);
  return t * (0.72 + 0.56 * (gnoise(xz * 1.9 + 41.0) * 0.5 + 0.5));
}

void main() {
#ifdef TILES
  // Vulkan: one draw covers a chunk of tiles. Each record's firstInstance is its place in the chunk
  // times 65536 (grass.ludic), and u_tiles holds that place's corner and indices per cell.
  int ti = gl_InstanceIndex / 65536;
  int i = gl_InstanceIndex - ti * 65536;
  vec2 tile = u_tiles[ti].xy;
  int per_cell = int(u_tiles[ti].z + 0.5);
#else
  int i = gl_InstanceID;
  vec2 tile = u_tile;
  int per_cell = u_per_cell;
#endif
  int c = i / per_cell;
  int j = i - c * per_cell;
  vec2 cell = tile + vec2(float(c % u_tile_cells), float(c / u_tile_cells)) * CELL;
  vec2 cid = floor(cell / CELL + 0.5);
  ivec2 ci = ivec2(cid);
  float fj = float(j);
  // this blade's fixed place in its cell
  vec2 hv = vec2(bladeHash(ci, j, 0), bladeHash(ci, j, 1));
  vec2 xz = cell + hv * CELL;
  vec2 d2 = xz - u_cam_pos.xz;
  float dist = length(d2);
  if (dist >= u_radius) { cull(); return; }
  // how many of this cell's blades exist at this distance: area over spacing^2, spacing
  // growing linearly with distance. j beyond that count does not exist; the last fifth
  // of the count shrinks to nothing so a blade never pops.
  float spacing = u_s0 * (1.0 + dist / u_d0);
  float count = CELL * CELL / (spacing * spacing) * (1.0 - smoothstep(u_radius * 0.7, u_radius, dist));
  // WHICH blades thin out has to be random, not the last indices. `fj >= count` keeps
  // blades 0..N-1, and as N falls by one with distance, the SAME index dies in every
  // cell at the same radius - one blade in a fixed place per cell, over a whole ring.
  // Seen from above that is a set of arcs centred on the camera, and at eye level it is
  // the banding that reads as a ploughed field. Giving each blade its own fixed number
  // and comparing that against the density makes the thinning scatter instead.
  float keep = count / float(max(per_cell, 1));
  float r = bladeHash(ci, j, 5);
  if (r > keep) { cull(); return; }
  float life = 1.0 - smoothstep(keep * 0.75, keep, r);
  // the ground under it
  vec2 huv = (xz - u_ts_origin) / (2.0 * u_ts_half) + 0.5;
  if (huv.x < 0.0 || huv.x > 1.0 || huv.y < 0.0 || huv.y > 1.0) { cull(); return; }
  vec4 ht = texture(u_ts_height, huv);
  vec4 croot = u_vp * vec4(xz.x, ht.r, xz.y, 1.0);
  if (croot.w < -1.0 || abs(croot.x) > croot.w * 1.25 + 1.5 || abs(croot.y) > croot.w * 1.4 + 1.5) { cull(); return; }
  vec3 gn = normalize(ht.gba);
  float h3 = bladeHash(ci, j, 2), h4 = bladeHash(ci, j, 3);
  // No blades under water: the sea's line everywhere, and the lake's inside its outline. One
  // line for both left a lake above the sea with grass on its bed or a valley with none.
  float wl = u_sea_level;
  if (u_lake.z > 0.0) { vec2 q = (xz - u_lake.xy) / u_lake.zw;  if (dot(q, q) < 1.0) wl = max(wl, u_lake_level); }
  float ok = (1.0 - smoothstep(0.30, 0.55, 1.0 - gn.y)) * smoothstep(0.0, 0.6, ht.r - wl - 0.15) * smoothstep(u_snow_line - 80.0, u_snow_line - 200.0, ht.r);
  if (u_ortho_on > 0.5) {
    vec3 oc = textureLod(u_ortho, huv, 1.5).rgb;
    // Is this ground vegetated, by the photograph? The test used to be green DOMINANCE -
    // g - max(r, b) - which is a test for lush green and nothing else. A dry alpine meadow
    // is yellow-green: its red is as high as its green, so the whole meadow scored zero and
    // was thinned to the floor, a quarter of the blades, on exactly the ground that should
    // be thickest. Measured on Maroon's own ortho, g - max(r, b) reads +0.026 at the camp
    // and -0.002 six hundred metres away, flipping between full density and a quarter over
    // open meadow; g - b reads +0.076 and +0.014 and separates plant from rock and snow
    // just as well, because rock and snow are neutral and vegetation is not.
    ok *= 0.40 + 0.60 * smoothstep(0.0, 0.025, oc.g - oc.b);
  }
  if (h4 > ok) { cull(); return; }
  // the root on the drawn surface: the CDLOD mesh follows the B-spline to within
  // centimetres near the camera, so the smooth sample is the drawn height
  bool far = dist > 300.0;
  float h = far ? ht.r : heightSmooth(u_ts_height, huv);
  if (far) h += 0.03;
  if ((u_dbg & 1) != 0) h += 0.3;
  // the blade: sized so that coverage stays level as the spacing grows
  float seed = hv.x * 0.7 + hv.y * 0.3;
  // A BLADE'S YAW MUST NOT BE ITS POSITION. This was `hv.y * 2pi`, and hv.y is the same
  // number that places the blade along the cell's z - so every blade at the same depth
  // in a cell faced the same way, in rows, sixteen metres wide. That is the single thing
  // that made the meadow look ploughed. Its own hash costs nothing.
  float ang = bladeHash(ci, j, 6) * 6.2831853;
  float s = sin(ang), c_ = cos(ang);
  float grow = spacing / u_s0;                       // 1 at the camera, growing with distance
  // Height is biased SHORT rather than spread evenly. A meadow is not one length of grass: it
  // is a dense mat with taller stems and seed heads standing out of it, and h3 * h3 gives that
  // for nothing - half the blades come out under a quarter of the range, and the few long ones
  // are what carry the silhouette against the light. An even 0.18-0.42 spread read as a lawn
  // that had been cut, which is the one thing an alpine meadow is not.
  float hh = h3 * h3;
  float tall = mix(0.09, 0.60, hh) * mix(0.8, 1.2, hash1(cid * 0.1)) * (1.0 + 0.35 * smoothstep(1.0, 12.0, grow)) * life;
  // CLUMPS: grass grows in tussocks, taller and shorter patches a metre or so across, and that
  // relief is the texture a meadow has from above - an even height reads as felt
  float clump = gnoise(xz * 0.85 + 3.7) * 0.5 + 0.5;
  tall *= mix(0.45, 1.40, clump * clump * (3.0 - 2.0 * clump));
  // 2.8 cm was FIVE TIMES a blade of meadow grass, which is 3-6 mm. At 2 m from the
  // camera that is a broad dark scimitar lying along the ground rather than a blade
  // standing in a sward, and no amount of profile or colour work fixes a blade that is
  // the wrong size. Measured, not guessed: it is the one number behind every "too wide
  // and too flat" note in this stage.
  float bw = 0.010 * mix(1.0, 0.45 * grow, smoothstep(1.0, 4.0, grow));
  if (far) { bw = max(bw, spacing * 0.35); tall = min(tall, spacing * 0.3); }
  // a blade under a pixel is a vertex bill that shimmers: widen it to one and a bit, and let the
  // thinning (spacing) keep the coverage
  bw = max(bw, dist * u_px * 1.1);
  vec3 p = vec3(a_pos.x * bw, a_pos.y * tall, a_pos.z * tall * (0.6 + 0.8 * h4));
  vec3 n = vec3(0.0, 0.3, 1.0);
  // The shared field (wind.glsl), so the gust that crosses this meadow is the same gust that
  // reaches the trees behind it a moment later. The two sines that used to live here were a
  // standing wobble: the grass moved, but nothing ever travelled.
  float ph = u_time * 1.7 + seed * 6.2831 + xz.x * 0.05 + xz.y * 0.07;
  float sway = windSway(xz, u_time, ph, 0.0) * u_wind;
  float hgt = max(p.y, 0.0);
  p.x += sway * hgt * hgt * 0.35;
  p.z += sway * hgt * hgt * 0.15 * cos(ph * 0.7);
  p = vec3(c_ * p.x + s * p.z, p.y, -s * p.x + c_ * p.z);
  // A BODY STANDING IN IT. Applied here, after the blade's own yaw has put p into world axes
  // and before it is tipped onto the ground normal, so the push is a world direction rather
  // than something in the blade's private frame. The blade bends AWAY and DOWN - a trodden
  // stem is shorter as well as leaning, and leaving the height alone made them splay outward
  // like a fan instead of being walked through.
  if (u_push.z > 0.0) {
    vec2 away = xz - u_push.xy;
    float pd = length(away);
    float push = smoothstep(u_push.z, u_push.z * 0.2, pd);
    if (push > 0.0) {
      vec2 pdir = (pd > 1e-3) ? away / pd : vec2(1.0, 0.0);
      float bh = max(p.y, 0.0);
      p.x += pdir.x * push * bh * 1.05;
      p.z += pdir.y * push * bh * 1.05;
      p.y -= push * bh * 0.40;
    }
  }
  n = normalize(vec3(c_ * n.x + s * n.z, n.y, -s * n.x + c_ * n.z));
  // stand on the ground: rotate the blade's frame from world-up to the surface normal
  {
    vec3 up = vec3(0.0, 1.0, 0.0);
    vec3 k = cross(up, gn);
    float sk = length(k), ck = gn.y;
    if (sk > 1e-4) {
      k /= sk;
      p = p * ck + cross(k, p) * sk + k * dot(k, p) * (1.0 - ck);
      n = normalize(n * ck + cross(k, n) * sk + k * dot(k, n) * (1.0 - ck));
    }
  }
  // Blades are lit with the ground's normal from a few metres out. Lit by their own
  // facing, the wind's sine field bent them in bands and the lit/unlit sides flipped in
  // those bands: light and dark rows across the whole meadow. Ground-normal lighting is
  // what open-world grass does (the blade's own normal only matters within arm's reach).
  n = normalize(mix(n, gn, smoothstep(2.0, 12.0, dist)));
  vec3 w = vec3(xz.x, h - 0.02, xz.y) + p;
  v_wpos = w;
  v_nrm = n;
  v_uv = far ? vec2(a_uv.x, 0.45 + 0.2 * a_uv.y) : a_uv;
  v_seed = seed;
  v_rot = vec2(s, c_);
  v_quake = 0.0;
  v_tint = bladeField(xz, h);
  v_hull = (dist > 2.0 || far || (u_dbg & 2) != 0) ? -1.0 : 1.0;   // no back-face flip, no rounding past arm's reach
  gl_Position = u_proj * u_view * vec4(w, 1.0);
}
