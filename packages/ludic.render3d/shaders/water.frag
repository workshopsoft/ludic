// still water: sky reflection with fresnel, sun glitter, scrolling ripple normals, absorption colour
in vec3 v_wpos;
out vec4 o_color;
uniform mat4 u_view;
uniform mat4 u_proj;       // its [1][1] turns a spread in metres into pixels
uniform vec3 u_wade;       // x, z, strength: a body standing in the water
uniform sampler2D u_depth;        // scene depth (resolved) for shore softness / depth tint
uniform mat4 u_inv_vp;
uniform vec2 u_screen;
uniform sampler2D u_refl;        // the world mirrored in the surface (rendered by the reflection pass)
uniform float u_refl_on;
uniform vec2 u_center;          // this body's centre and half extents (world xz)
uniform vec2 u_extent;
uniform float u_clip_ellipse;   // 1: the body is the ellipse inside its rectangle (a lake), 0: the whole plane (the sea)
uniform sampler2D u_scene;       // the scene as drawn before the water: the bed, to refract
// The wet mask (water_wet.ludic): a plane with u_wet_on draws only on wet texels. A texel a tile in the page says
// what the tile is - 0 not known (wet, as a plane with no mask), 1 all dry, 2 all wet, 3 + k mixed and resident in
// layer k of the tiles, one byte a texel (255 wet) on the height tiles' own grid, read bilinear: the edge runs halfway
// between a wet texel's centre and a dry one's. Off the map, wet.
uniform float u_wet_on;
uniform sampler2D u_wet_page;
uniform sampler2DArray u_wet_tiles;
uniform vec4 u_wet_grid;          // tile (0, 0)'s corner in render space x, z; metres a tile; tiles a side (cols)
uniform float u_wet_rows;
uniform float u_sea;              // 1: the open sea (swell, deep colour, the shore foam band); 0: still water as before
uniform float u_wash;             // 1: the thin lapping wash on a still body's edge (the sea has its foam band instead)
uniform sampler2D u_swell_a;      // the sea's swell as slopes (water_sea.ludic's bake), tiling every SEA_TILE_A metres
uniform sampler2D u_swell_b;      // the same for the short ripples, tiling every SEA_TILE_B metres
// One texel of the mask by its global index, read across tile borders: a tile of the page says what the tile is, an
// array layer holds a mixed tile's texels. Off the map and a tile with no file read wet.
float wetTexel(ivec2 g, int res) {
  ivec2 ti = ivec2(floor(vec2(g) / float(res)));
  if (ti.x < 0 || ti.y < 0 || ti.x >= int(u_wet_grid.w) || ti.y >= int(u_wet_rows)) return 1.0;
  float v = floor(texelFetch(u_wet_page, ti, 0).r * 255.0 + 0.5);
  if (v < 0.5) return 1.0;
  if (v < 1.5) return 0.0;
  if (v < 2.5) return 1.0;
  return texelFetch(u_wet_tiles, ivec3(g - ti * res, int(v) - 3), 0).r;
}
// Bilinear between texel centres, each neighbour found through the page on its own: a border between two tiles is not
// a seam (a layer's own sampler clamps at its edge, which put a half-texel step of the mask on every tile border).
float wetAt(vec2 xz) {
  int res = textureSize(u_wet_tiles, 0).x;
  vec2 g = (xz - u_wet_grid.xy) / u_wet_grid.z * float(res) - 0.5;
  ivec2 g0 = ivec2(floor(g));
  vec2 f = g - vec2(g0);
  // nearly everywhere the four texels are one tile's: one read of the page says all dry or all wet, and a mixed tile's
  // layer is read bilinear by the sampler (the same blend of the same four texels)
  ivec2 t0 = ivec2(floor(vec2(g0) / float(res)));
  if (t0 == ivec2(floor(vec2(g0 + 1) / float(res)))) {
    if (t0.x < 0 || t0.y < 0 || t0.x >= int(u_wet_grid.w) || t0.y >= int(u_wet_rows)) return 1.0;
    float v = floor(texelFetch(u_wet_page, t0, 0).r * 255.0 + 0.5);
    if (v < 0.5) return 1.0;
    if (v < 1.5) return 0.0;
    if (v < 2.5) return 1.0;
    return textureLod(u_wet_tiles, vec3((vec2(g0 - t0 * res) + f + 0.5) / float(res), float(int(v) - 3)), 0.0).r;
  }
  return mix(mix(wetTexel(g0, res), wetTexel(g0 + ivec2(1, 0), res), f.x),
             mix(wetTexel(g0 + ivec2(0, 1), res), wetTexel(g0 + ivec2(1, 1), res), f.x), f.y);
}
// The least of the mask at the four points r metres from xz (east, west, north, south). Nearly always the texels the four reads
// need lie in one tile, and then one read of the page serves all four; near a tile's border each is found on its own.
float wetMin4(vec2 xz, float r) {
  int res = textureSize(u_wet_tiles, 0).x;
  float k = float(res) / u_wet_grid.z;
  vec2 g = (xz - u_wet_grid.xy) * k - 0.5;
  vec2 gr = vec2(r * k);
  ivec2 t0 = ivec2(floor(floor(g - gr) / float(res)));
  ivec2 t1 = ivec2(floor((floor(g + gr) + 1.0) / float(res)));
  if (t0 == t1 && t0.x >= 0 && t0.y >= 0 && t0.x < int(u_wet_grid.w) && t0.y < int(u_wet_rows)) {
    float v = floor(texelFetch(u_wet_page, t0, 0).r * 255.0 + 0.5);
    if (v < 0.5 || (v > 1.5 && v < 2.5)) return 1.0;
    if (v < 1.5) return 0.0;
    vec2 uv = (xz - u_wet_grid.xy) / u_wet_grid.z - vec2(t0);
    float dr = r / u_wet_grid.z;
    float layer = float(int(v) - 3);
    return min(min(textureLod(u_wet_tiles, vec3(uv + vec2(dr, 0.0), layer), 0.0).r, textureLod(u_wet_tiles, vec3(uv - vec2(dr, 0.0), layer), 0.0).r),
               min(textureLod(u_wet_tiles, vec3(uv + vec2(0.0, dr), layer), 0.0).r, textureLod(u_wet_tiles, vec3(uv - vec2(0.0, dr), layer), 0.0).r));
  }
  return min(min(wetAt(xz + vec2(r, 0.0)), wetAt(xz - vec2(r, 0.0))), min(wetAt(xz + vec2(0.0, r)), wetAt(xz - vec2(0.0, r))));
}
// The ground under a pixel, as the terrain draws it (the shore's terms belong to the bed, and the
// scene depth can be a fish or a pair of legs standing on it). terpage.glsl, pasted (the reference
// copy and its rules are there): the height sections, read through u_ts_height.
#define TP_FRAGMENT
// ---- the page table ----------------------------------------------------------------------
#ifndef TP_HELPERS
#define TP_HELPERS
uniform sampler2D u_tp_page;   // R32F, a texel a tile: slot + 1, 0 = not resident
uniform float u_tp_on;         // 1 while paging; 0 reads the whole maps exactly as before
uniform vec4 u_tp_dims;        // tiles a side, height texels a tile, photo texels a tile, full height res
// the layer holding a full-map uv, or -1: paging off, off the map, or not resident
float tpSlot(vec2 uv) {
  if (u_tp_on < 0.5 || uv.x < 0.0 || uv.y < 0.0 || uv.x >= 1.0 || uv.y >= 1.0) return -1.0;
  ivec2 t = min(ivec2(floor(uv * u_tp_dims.x)), ivec2(int(u_tp_dims.x) - 1));
  return texelFetch(u_tp_page, t, 0).r - 1.0;
}
// a full-map uv inside its tile's layer of k texels a side, past the one-texel border
vec2 tpUV(vec2 uv, float k) { return (1.0 + fract(uv * u_tp_dims.x) * k) / (k + 2.0); }
#endif
// ---- height (vertex and mesh stages) -----------------------------------------------------
#ifndef TP_HEIGHT
#define TP_HEIGHT
#ifndef TP_HMAP
#define TP_HMAP u_ts_height
#endif
uniform sampler2DArray u_tp_h;
// bilinear height, fine where a tile is resident. Outside a fragment stage texture() IS level 0
// (glslang emits the same explicit-lod sample), so this is the old read bit for bit.
float terHeight(vec2 uv) {
  float s = tpSlot(uv);
  if (s >= 0.0) return textureLod(u_tp_h, vec3(tpUV(uv, u_tp_dims.y), s), 0.0).r;
  return textureLod(TP_HMAP, uv, 0.0).r;
}
// The B-spline through four bilinear taps (heightSmooth). Paging on, the texel is the FULL
// map's - the coarse map's own size would halve the surface's detail - and each tap finds its
// own tile, so a patch straddling two tiles, or a tile and the coarse map, stays one surface.
float terHeightSmooth(vec2 uv) {
  vec2 res = u_tp_on > 0.5 ? vec2(u_tp_dims.w) : vec2(textureSize(TP_HMAP, 0));
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
  return (terHeight(vec2(o0.x, o0.y)) * s0.x + terHeight(vec2(o1.x, o0.y)) * s1.x) * s0.y
       + (terHeight(vec2(o0.x, o1.y)) * s0.x + terHeight(vec2(o1.x, o1.y)) * s1.x) * s1.y;
}
#endif
vec2 terUV(vec2 xz) { return (xz - u_ts_origin) / (2.0 * u_ts_half) + 0.5; }
// wind-streaked capillary ripples (stretched along the wind) over slower swells
float waterH(vec2 p, float t) {
  vec2 w = vec2(p.x * 0.7 + p.y * 0.15, p.y * 1.4) ;            // mildly anisotropic: cat's-paws stretched along the wind
  // A sheltered alpine lake, not a sea. The swell carries what movement there is and the
  // two capillary octaves are most of the way out: at their old weights the whole surface
  // was in motion to the horizon, which is chop, and chop is what stops a lake reading as
  // one sheet of water with a mountain in it.
  return 0.26 * gnoise(w * 0.9 + vec2(t * 0.05, t * 0.3)) + 0.075 * gnoise(p * 2.3 - vec2(t * 0.04, -t * 0.055)) + 0.028 * gnoise(p * 6.0 + vec2(t * 0.7, t * 0.24));
}
// What is under a rippled surface is seen through a spread of directions, one per ripple, and
// the spread on the far side widens with the depth below: a fish 0.5 m down is soft, the shelf
// at a metre and a half softer. One read of the scene's mips, r pixels wide (taps on a disc
// left ghost copies of a wader's fingers); narrowed by how much of its footprint finds something
// above the surface - the near bank, a wader's dry shoulders - or it would smear into the water.
vec3 underBlur(vec2 uv, vec3 c0, float r, float surfY) {
  float clear = 1.0;
  for (int i = 0; i < 4; i++) {
    vec2 tuv = clamp(uv + vec2(i < 2 ? -r : r, (i % 2) == 0 ? -r : r) / u_screen, 0.001, 0.999);
    vec4 tp = u_inv_vp * vec4(tuv * 2.0 - 1.0, depthClip(texture(u_depth, tuv).r), 1.0);
    if (tp.y / tp.w > surfY) clear -= 0.25;
  }
  if (clear <= 0.0) return c0;
  return sane(textureLod(u_scene, uv, log2(r) * clear).rgb);
}
vec3 rippleNormal(vec2 p, float t) {
  float e = 0.06;
  float h = waterH(p, t), hx = waterH(p + vec2(e, 0), t), hz = waterH(p + vec2(0, e), t);
  // and the slope the height is turned into is shallower still: the normal is what the
  // reflection is read through, so this is what decides whether a mirrored ridge arrives
  // whole or shivered into pieces
  return normalize(vec3(-(hx - h) * 0.15 / e, 1.0, -(hz - h) * 0.15 / e));
}
// ---- the open sea ---------------------------------------------------------------------------------------
// A calm sea is the surface flat and the light bent by swells. The swells are baked once (water_sea.ludic: a few dozen plane
// waves of whole wavenumbers, spread over a cone of directions, summed into slopes that tile): the long tile is read twice,
// the second time turned and stretched so no repeat shows, and the ripple tile once, nudged by the long swell. A swell that
// the screen cannot resolve is averaged by the mips and faded out, so it averages to flat instead of crawling as glitter.
// Nothing is displaced, so no shore, quay or hull ever meets a moving surface.
const float SEA_TILE_A = 256.0;
const float SEA_TILE_B = 16.0;
vec2 swellRead(sampler2D s, vec2 uv) { return (texture(s, uv, 0.5).rg - 0.5) * 0.5; }
// pixG: metres of the surface one pixel spans along the view
vec3 seaNormal(vec2 p, float t, float pixG) {
  vec2 pa = p - vec2(0.9394, 0.3429) * (1.9 * t);
  vec2 pb = mat2(0.7986, -0.6018, 0.6018, 0.7986) * (p - vec2(-0.5, 0.866) * (1.1 * t)) * 0.63;
  vec2 s = (swellRead(u_swell_a, pa * (1.0 / SEA_TILE_A)) + swellRead(u_swell_a, pb * (1.0 / SEA_TILE_A))) * (1.0 - smoothstep(0.3, 1.0, pixG));
  // the ripples, nudged by the long swell, only where a pixel is under 12 cm (a ripple is not drawn past it: the fetch is not
  // made, which is most of a frame's sea). Explicit gradients, taken outside the branch, so the mips are right at its edge.
  vec2 uvb = (p - vec2(0.6967, 0.7174) * (0.8 * t) + s * 6.0) * (1.0 / SEA_TILE_B);
  vec2 gx = dFdx(uvb) * 1.41, gy = dFdy(uvb) * 1.41;
  if (pixG < 0.12) { s += (textureGrad(u_swell_b, uvb, gx, gy).rg - 0.5) * (0.5 * (1.0 - smoothstep(0.03, 0.12, pixG))); }
  return normalize(vec3(-s.x, 1.0, -s.y));
}
// equirectUV with the arc functions as polynomials (Abramowitz and Stegun 4.4.49 and 4.4.45): the error is 1e-5 and 7e-5 of a
// radian, a fiftieth of a texel of the sky's maps, and the two calls this pass makes a pixel are a fifth of what it costs.
vec2 equirectFast(vec3 d) {
  float ax = abs(d.x), az = abs(d.z);
  float mn = min(ax, az) / max(max(ax, az), 1e-8);
  float s = mn * mn;
  float a = mn * (0.99997726 + s * (-0.33262347 + s * (0.19354346 + s * (-0.11643287 + s * (0.05265332 + s * -0.01172120)))));
  if (ax > az) { a = 1.5707963 - a; }                                   // atan(|x| / |z|): the ratio was the smaller over the larger
  if (-d.z < 0.0) { a = 3.1415927 - a; }                                // atan(x, -z): the far half is past a quarter turn
  a = d.x < 0.0 ? -a : a;
  float y = clamp(d.y, -1.0, 1.0);
  float ay = abs(y);
  float ac = sqrt(1.0 - ay) * (1.5707288 + ay * (-0.2121144 + ay * (0.0742610 + ay * -0.0187293)));
  if (y < 0.0) { ac = 3.1415927 - ac; }
  return vec2(a * 0.15915494 + 0.5, ac * 0.31830989);
}
// The prefiltered sky at one roughness: one fetch at the nearest roughness level (the sea's roughness is a constant, so every
// pixel reads the same two levels; the blend between them is not worth a second fetch). One read serves the reflection and the
// haze of the fog both: the swell scatters a reflection over a cone wider than the blur of the level read, and the fog's colour
// is the sky a few degrees over the horizon, which is where every pixel far enough to be fogged reflects. Toward the ground the
// sky's lower half is the ground's colour (skyPrefiltered's mix, with the ground's own blurred read taken to be the sky's
// at the same direction: they differ by a blur nothing here can see).
vec3 seaSkyRaw(vec3 d, float rough) {
  float lv = floor(rough * (u_prefilter_levels - 1.0) + 0.5);
  return texture(u_prefilter, vec3(equirectFast(d), lv)).rgb * u_ibl_scale;
}
// The point of the plane under this pixel from its view ray. The interpolated position across a quad a hundred
// kilometres wide carries a few millimetres of error: nothing a wave would show, but the ray is exact at any size.
vec3 seaPos(float level) {
  vec2 q = gl_FragCoord.xy / u_screen * 2.0 - 1.0;
  vec4 nr = u_inv_vp * vec4(q, 1.0, 1.0);
  vec3 dir = normalize(nr.xyz / nr.w - u_cam_pos);
  if (abs(dir.y) < 1e-4) return v_wpos;
  float s = (level - u_cam_pos.y) / dir.y;
  if (s <= 0.0) return v_wpos;
  return u_cam_pos + dir * s;
}
// The shore foam: a band where the water over the bed is under a metre deep, white where the swash has just been, lace
// beyond it to the band's edge, nothing at or past a metre. `d` is the water's depth under the pixel; `rayLen` the
// distance along the view to the bed (zero where the surface meets the ground). The pattern fades to its mean once a
// pixel spans more than it can show.
float seaFoam(float d, float fwD, float rayLen, vec2 p, float t, float pixG) {
  float band = 1.0 - smoothstep(0.55, 1.0, d);
  if (band <= 0.0) return 0.0;
  // the swash runs up the shore and back, out of step along the coast
  float run = 0.5 + 0.5 * sin(t * 0.5 + 2.5 * (sin(p.x * 0.0231 + 1.7) + sin(p.y * 0.0187 - 0.9)));      // two slow sines, not a noise: a lattice's hash and blend cost more than the whole swash
  float front = mix(0.04, 0.16, run);
  float solid = 1.0 - smoothstep(0.4 * front, front, d);
  // the lace is drawn where a pixel can show it (under half a metre, and the depth not changing faster than a pixel); past
  // that it is its mean and the noise is not computed
  float fine = (1.0 - smoothstep(0.12, 0.5, pixG)) * (1.0 - smoothstep(0.7, 1.6, 8.0 * fwD));
  float lace = 0.22;
  if (fine > 0.0) {
    float b = fbm(p * 1.6 + vec2(t * 0.07, 0.0), 3) * 0.5 + 0.5;
    float lines = 0.5 + 0.5 * sin(d * 8.0 - t * 0.8 - 3.0 * b);
    lace = mix(0.22, smoothstep(0.55, 0.95, lines) * smoothstep(0.30, 0.68, b), fine);
  }
  float foam = max(solid, 0.9 * lace * smoothstep(0.5 * front, front + 0.08, d)) * band;
  // the line where the plane meets the ground is two surfaces a few millimetres apart (a few centimetres of the view ray):
  // no foam on it, so it cannot flicker between white and the bank
  return foam * smoothstep(0.0, 0.03, rayLen);
}
// Which program this is: the sea's (WATER_SEA) is the sea's code alone, the others' (lakes, rivers, meshes) their own, so
// neither carries the other's registers. The test is a constant in both.
#ifdef WATER_SEA
const bool sea = true;
#else
const bool sea = false;
#endif
void main() {
  // A lake is an ellipse - the carved bed, the grass and a game's own water test all use
  // one - but its plane is the rectangle around it, and the corners between the two hold
  // ground below the lake's level. Without this they show as sheets of water on dry land.
  if (!sea && u_clip_ellipse > 0.5) {
    vec2 q = (v_wpos.xz - u_center) / max(u_extent, vec2(0.001));
    if (dot(q, q) > 1.0) discard;
  }
  vec3 wp = sea ? seaPos(v_wpos.y) : v_wpos;
  vec3 v = normalize(u_cam_pos - wp);
  float dist = length(u_cam_pos - wp);
  // metres of the surface a pixel spans along the view (a swell shorter than a few of them is not drawn)
  float pixG = min(dist / (0.5 * u_screen.y * u_proj[1][1]) / max(abs(v.y), 0.04), 400.0);
  // how deep the ground is under this pixel: from the scene depth
  vec2 suv = gl_FragCoord.xy / u_screen;
  float sd = texture(u_depth, suv).r;
  vec4 gp = u_inv_vp * vec4(suv * 2.0 - 1.0, depthClip(sd), 1.0);
  vec3 ground = gp.xyz / gp.w;
  float depthBelow = clamp(wp.y - ground.y, 0.0, 10.0);
  float fwD = fwidth(depthBelow);                 // before any discard: a pixel's neighbours are all still running
  float alongRay = length(ground - wp);
  if (u_wet_on > 0.5 && wetAt(wp.xz) < 0.5) discard;
  vec3 n;
  if (sea) {
    n = seaNormal(wp.xz, u_time, pixG);
    // seen along the surface a swell is foreshortened to a line, and a line is flicker: flat toward the horizon
    if (v.y < 0.10) { n = normalize(mix(n, vec3(0.0, 1.0, 0.0), smoothstep(0.10, 0.015, v.y))); }
  } else {
    n = rippleNormal(wp.xz, u_time);
    n = normalize(mix(n, vec3(0, 1, 0), smoothstep(60.0, 400.0, dist)));   // flat sooner: past a few tens of metres a still lake has no texture at all
  }
  // ---- A BODY IN THE WATER ------------------------------------------------------------
  // You waded into a mountain lake and the surface did not notice. Rings spreading from the
  // legs and a patch of churn around them is the whole of it, and it is the difference
  // between standing in water and standing in a picture of water.
  //
  // Applied AFTER the distance flattening on purpose: the flattening is there because a
  // sheltered lake really is glass at forty metres, but what you yourself are doing to the
  // water is by definition within arm's reach, and it must not be flattened away.
  if (u_wade.z > 0.0) {
    float rd = length(wp.xz - u_wade.xy);
    // rings travelling outward, dying off within a few metres
    float ring = sin(rd * 6.5 - u_time * 8.0) * exp(-rd * 0.5);
    // and the disturbed patch right at the body, which is not a ring but a mess
    float churn = exp(-rd * 1.8) * (sin(u_time * 13.0 + rd * 9.0) * 0.5 + 0.5);
    vec2 away = (rd > 1e-3) ? (wp.xz - u_wade.xy) / rd : vec2(1.0, 0.0);
    float amp = u_wade.z * (ring * 0.9 + churn * 0.7);
    n = normalize(n + vec3(away.x * amp, 0.0, away.y * amp) * 0.55);
  }
  // What the depth found may not be the bed: a fish, or the legs of someone wading, stands
  // clear of the ground it is over. The light to it still crosses depthBelow of water, but
  // the shore's terms - the wash, the lap and the soft edge, which exist to hide where the
  // plane cuts the BANK - read the bed under this pixel instead. Keyed off the object, they
  // laid the shoreline's foam over every fish within 35 cm of the top and the wader's hips,
  // and faded the surface away over a shallow fish, which then lay on the water unreflected.
  // Past half a metre of water to what was hit, neither term reaches it, so nothing is read.
  // (The sea has no fish, and reads depth as it is: the bed is the scene's.)
  float body = 0.0;
  float standing = 0.0;      // the same test at any depth the water lets anything through: the veil below
  float shoreBelow = depthBelow;
  float shoreRay = alongRay;
  if (!sea && dist < 250.0 && depthBelow < 3.0 && ground.y < wp.y) {
    float lift = ground.y - terHeightSmooth(terUV(ground.xz));
    standing = smoothstep(0.15, 0.35, lift) * smoothstep(250.0, 200.0, dist);
  }
  if (depthBelow < 0.5 && standing > 0.0) {
    body = standing;
    float bedBelow = clamp(wp.y - terHeightSmooth(terUV(wp.xz)), 0.0, 10.0);
    shoreBelow = mix(depthBelow, bedBelow, body);
    shoreRay = mix(alongRay, max(alongRay, bedBelow), body);
  }
  // How opaque the water is at the shoreline. This used to fade over the last 1.2 m of
  // depth, which is the same band the foam lives in, so the surface went transparent
  // exactly where it should have been breaking white: the foam was drawn and then
  // alpha'd away, leaving a gap of dark wet ground and water that looked like it
  // stopped short of the bank. Fade over a much shorter distance so the water reaches
  // the edge, and let the foam carry its own opacity below.

  vec3 r = reflect(-v, n);
  r.y = abs(r.y);
  vec3 skyRaw = vec3(0.0);
  vec3 refl;
  if (sea) {
    skyRaw = seaSkyRaw(vec3(r.x, max(r.y, 0.02), r.z), 0.4);
    refl = skyRaw * mix(u_ground_alb, vec3(1.0), smoothstep(-0.2, 0.15, r.y));
  } else {
    refl = skyPrefiltered(r, 0.12);
  }
  if (u_refl_on > 0.5) {
    // the mirrored render lines up with the screen; the ripples nudge and soften the lookup.
    // The nudge is halved with the ripples that drive it - at the old strength a calm
    // surface still tore the reflection, because the offset was tuned against a normal
    // that no longer exists.
    vec2 ruv = suv + n.xz * 0.010 * smoothstep(500.0, 20.0, dist);
    float blur = mix(0.5, 0.2, smoothstep(0.0, 300.0, dist));
    refl = sane(textureLod(u_refl, clamp(ruv, 0.001, 0.999), blur).rgb);
  }
  // Water is a dim mirror, not a bright one. The mirrored render comes back at the scene's
  // own exposure, so at full strength the lake was as bright as the ridge standing in it and
  // the surface read as polished metal - and being that bright it also buried the bed under
  // it whatever the fresnel mix said. REFL_DIM is what a real surface returns.
  const float REFL_DIM = 0.72;
  refl *= REFL_DIM;
  // wind-blown foam streaks and shoreline wash
  float foam = 0.0;
  if (!sea) {
    foam = u_wash * smoothstep(0.62, 0.9, gnoise(vec2(wp.x * 0.25 + u_time * 0.24, wp.z * 1.5) ) * 0.5 + 0.5) * 0.014 * smoothstep(200.0, 30.0, dist);
    // Wash: the shallows lapping the shore. Built from fbm rather than one gnoise octave —
    // a single octave is a blobby lattice that magnifies into visible squares when you
    // stand next to it, which is what made the wash read as cartoon cut-outs. Several
    // octaves plus a fine breakup term give it structure at every range it is seen from.
    float lap = 0.5 + 0.5 * sin(shoreBelow * 9.0 - u_time * 1.6 + 2.0 * gnoise(wp.xz * 0.8 + u_time * 0.2));
    float fdet = fbm(wp.xz * 7.0 - u_time * 0.35, 3) * 0.5 + 0.5;      // fine bubbles
    float fmid = fbm(wp.xz * 2.6 + u_time * 0.5, 3) * 0.5 + 0.5;
    float fedge = fbm(wp.xz * 1.4 - u_time * 0.3, 2) * 0.5 + 0.5;
    // a still alpine lake has a wet line, not surf: the wash is thin (the last 0.35 m of
    // depth) and faint, and the terrain runs the same fields at the same strength
    foam += u_wash * smoothstep(0.35, 0.0, shoreBelow) * (0.12 * smoothstep(0.30, 0.72, fmid) + 0.10 * smoothstep(0.55, 0.95, lap) * smoothstep(0.22, 0.6, fedge)) * (0.55 + 0.75 * fdet);
    // the lap is a near-field detail: from a distance a lake's edge is a line, not a surf
    foam *= smoothstep(120.0, 15.0, dist);
    // the wash dies where the surface meets the ground, so it cannot end on a hard line
    foam *= smoothstep(0.0, 0.5, shoreRay);
  }
  float NoV = max(dot(n, v), 0.0);
  float F = 0.02 + 0.98 * pow(1.0 - NoV, 5.0);
  vec3 hv = normalize(v + u_sun_dir);
  float NoH = max(dot(n, hv), 0.0);
  float glitter = D_GGX(NoH, sea ? 0.07 : 0.06) * (sea ? 0.2 : 0.17);   // a narrower sun track: glitter is spread by ripples, and there are fewer
  // The sea's foam is found first, since it and the sun's glitter are all the shadow is asked for: over most of the sea
  // neither is there (the glitter is a track, the foam a band along the shore), and the shadow is not read at all.
  float sf = 0.0;
  if (sea) {
    // the shore foam is lit as the ground is and goes through the same fog as the water it lies on
    sf = clamp(seaFoam(depthBelow, fwD, alongRay, wp.xz, u_time, pixG), 0.0, 1.0);
    if (sf > 0.0 && u_wet_on > 0.5) {
      // where the sea's own region ends over ground that is still under the water (a river mouth, a dock's wall) the mask
      // is an edge in the water, not a shore: the foam fades out over the two metres before it
      float wmin = wetMin4(wp.xz, 2.0);
      sf *= smoothstep(0.45, 0.9, wmin);
    }
  }
  float shadow = 1.0;
  bool sunSeen = !sea;
  // the sea's own shadows (a hull, a quay) matter in the near field only, and under glitter and foam one tap is enough:
  // the lake takes the full filter, the sea one tap out to 250 m and none past it, and none where there is no glitter
  // (a hundredth of the sun's colour or less, which a shadow could dim by that much and no more) or foam to light
  if (!sea) {
    float viewDepth = -(u_view * vec4(wp, 1.0)).z;
    shadow = sunShadow(wp, vec3(0, 1, 0), viewDepth) * cloudShadow(wp);
  } else if (sf > 0.0 || max(u_sun_color.r, max(u_sun_color.g, u_sun_color.b)) * glitter * F > 0.01) {
    sunSeen = true;
    if (dist < 250.0) { shadow = sunShadowCheap(wp, vec3(0, 1, 0), -(u_view * vec4(wp, 1.0)).z); }
    shadow *= cloudShadow(wp);
  }
  // ---- what is under the surface -------------------------------------------------
  // The bed is sampled from the scene as it was drawn before the water, nudged by the
  // ripple normal (refraction), then attenuated per channel over the path the light
  // actually travelled: down through the water and back up to the eye. Red goes first,
  // then green, so shallows stay bright and readable and depth turns blue-green and
  // dark on its own. This is what makes it a body of water rather than a tinted sheet:
  // the ground is seen through it, not behind it.
  // Deep sea shows no bed: the light never comes back, so none of the bed's reads is made (the sea over the map's edge, where
  // there is no ground at all, is the same colour as over a bed far down). The most of the bed that can come through is
  // the blue's, which the water takes least of; where that is under a hundredth the bed is not read.
  float pathLen = depthBelow * (1.0 + 1.0 / max(NoV, 0.25));
  float blueLeft = exp(-0.06 * pathLen);
  bool deep = sea && blueLeft * (1.0 - smoothstep(4.0, 9.0, depthBelow)) < 0.012;
  vec2 ruv2 = suv;
  vec3 bed = vec3(0.0);
  vec3 trans = vec3(0.0);
  if (!deep) {
    // Per metre: red first, then green — a cold blue-teal depth. Pulled down by a third, so
    // the light reaches about half as far again into the water as it did: at the old rates a
    // metre and a half of a clear mountain lake was already opaque, which is a pond, and the
    // gravel of the shelf went out before the bank did.
    vec3 absorb = sea ? vec3(0.40, 0.12, 0.06) : vec3(0.34, 0.15, 0.09);
    trans = sea ? vec3(exp(-0.40 * pathLen), exp(-0.12 * pathLen), blueLeft) : exp(-absorb * pathLen);
    if (sea) trans *= 1.0 - smoothstep(4.0, 9.0, depthBelow);          // by nine metres the sea is its own colour
    // the ripples' spread, SPREAD metres a metre of depth, in pixels at this distance; only where
    // any of the bed still comes through (past that the read would soften what is not seen)
    const float SPREAD = 0.04;
    float vd = -(u_view * vec4(wp, 1.0)).z;
    float spreadPx = min(SPREAD * depthBelow * 0.5 * u_screen.y * u_proj[1][1] / max(vd, 0.5), 3.0);
    if (sea && depthBelow > 4.0) {
      // the sea past four metres: the bed is a dim veil under the swell, seen through the spread as one read of the scene's
      // mips - no refraction, none of the guards against the bank (a hull's edge is not within reach of a pixel's spread of
      // this much water), the same read the guarded one comes to wherever no bank is near
      bed = sane(textureLod(u_scene, suv, trans.b > 0.03 ? log2(max(spreadPx, 1.0)) : 0.0).rgb);
    } else {
      // the refraction fades out over the sea's last metre and a half to four, where the plain read takes over
      float rfr = 1.0;
      if (sea) { rfr = 1.0 - smoothstep(2.5, 4.0, depthBelow); }
      ruv2 = clamp(suv + n.xz * 0.03 * smoothstep(0.0, 2.0, depthBelow) * rfr, 0.001, 0.999);
      // never refract something that is actually in front of the surface (the near bank),
      // or the grass on the shore smears out over the water
      float rd = textureLod(u_depth, ruv2, 0.0).r;
      vec4 rgp = u_inv_vp * vec4(ruv2 * 2.0 - 1.0, depthClip(rd), 1.0);
      vec3 rground = rgp.xyz / rgp.w;
      if (rground.y > wp.y) { ruv2 = suv; }
      bed = sane(sea ? textureLod(u_scene, ruv2, 0.0).rgb : texture(u_scene, ruv2).rgb);
      if (spreadPx > 0.75 && trans.b > 0.03) { bed = underBlur(ruv2, bed, spreadPx, wp.y); }
    }
  }
  // (skyIrradiance of straight up is the sky's irradiance map read once there: the ground's read is mixed out entirely)
  vec3 skyUp = textureLod(u_irradiance, vec2(0.5, 0.0), 0.0).rgb * u_ibl_scale;
  vec3 tint = (sea ? vec3(0.018, 0.075, 0.115) : vec3(0.030, 0.085, 0.105)) * skyUp * 1.15;   // Maroon Lake: deep, dark blue-green, not turquoise
  // The bed comes here already wet (terrain.frag's `wet`, about 0.6) and under a film of the lake's
  // colour (`film`, about half its albedo); a fish, a wader's legs or a rock on the bed come lit as
  // if in air, and absorption alone left a trout half a metre down brighter than the gravel round
  // it, golden and un-tinted, lying ON the lake. What stands clear of the bed is darkened as a wet
  // surface is (a surface under water loses what air would have reflected) and veiled by its path.
  float under = standing * smoothstep(0.0, 0.1, depthBelow);
  vec3 through = bed * trans * (1.0 - 0.3 * under) + tint * (1.0 - trans);
  through = mix(through, tint, under * 0.4 * (1.0 - exp(-0.7 * pathLen)));
  // ---- surface -------------------------------------------------------------------
  // How much of what you see is the sky and how much is the bottom. The fresnel term is
  // physical and stays; what changed is the weight it is given and, more to the point, the
  // CEILING. At 0.86 the surface went to a near-total mirror as soon as you looked along it,
  // which is true of a sea and is why you could stand at the shore of a lake nine metres
  // deep and never see into it. At 0.70 the bed is there at every angle you actually stand
  // at, and the mirrored Bells are still the thing you see across the water.
  if (sunSeen) { shadow *= sunZone(wp); }   // no glitter or sunlit foam inside a light zone
  vec3 col = mix(through, refl, clamp(F * 0.85 + 0.03, 0.0, 0.70)) + u_sun_color * glitter * F * shadow;
  if (sea) {
    col = mix(col, vec3(1.15, 1.18, 1.18) * (skyUp + u_sun_color * (max(u_sun_dir.y, 0.0) / 3.14159) * shadow), sf);
    // the haze is the sky a few degrees above the horizon: the one read, as the ground mixes it in there
    col = applyFogSky(col, -v, dist, skyRaw * mix(u_ground_alb, vec3(1.0), smoothstep(-0.2, 0.15, 0.02)));
  } else {
    col = mix(col, vec3(0.7, 0.75, 0.75) * (skyUp * 0.5 + u_sun_color * 0.08 * shadow), clamp(foam, 0.0, 1.0));
    col = applyFog(col, wp, dist);
  }
  // Soft edge measured ALONG THE VIEW RAY, not vertically. Vertical depth collapses to
  // zero over a fraction of a pixel when the surface is seen edge-on, which is exactly
  // the low, near-the-waterline view where the plane's silhouette turns into a hard
  // glassy line. The distance from the surface to the bed along the ray stays a smooth
  // quantity at any angle, so the water dissolves into the ground it meets instead.
  // The sea's foam is the one thing that stays white where the water ends.
  float soft = smoothstep(0.0, 0.5, shoreRay);
  col = mix(bed, col, max(soft, sf));
  o_color = vec4(sane(col), 1.0);
}
