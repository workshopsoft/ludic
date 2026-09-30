in vec3 v_wpos;
in vec2 v_huv;
out vec4 o_color;
#ifdef TFAST_2
#define fbm(p, o) 0.1
#define ridged(p, o) 0.3
#define gnoise(p) 0.1
#endif
uniform sampler2D u_height;
uniform float u_half;
uniform float u_texel;               // height-map texel size in uv
uniform sampler2D u_grass_d; uniform sampler2D u_grass_n; uniform sampler2D u_grass_a;
uniform sampler2D u_ortho;
uniform sampler2D u_sunshadow;   // the sun visibility this pixel already has (tersun.frag)
uniform float u_ortho_on;
uniform sampler2D u_rock_d;  uniform sampler2D u_rock_n;  uniform sampler2D u_rock_a;
uniform sampler2D u_snow_d;  uniform sampler2D u_carpet;   // the clump cards baked straight down (alpha = coverage)
uniform float u_carpet_on;
uniform float u_grass_reach;   // where the GPU blades stop (0: none): the ground under them is in their shade
uniform float u_snow_line;
uniform float u_lake_level;      // the ground just above the water is wet and dark
// ---- RAIN THAT LEAVES SOMETHING BEHIND -----------------------------------------------------
// Rain fell and the ground did not change: the weather was a curtain of particles in front of a
// dry valley. This is one scalar, 0 dry to 1 soaked, and it does three things a wet surface
// does - darkens the albedo, drops the roughness so the sky glances off it, and pools in the
// low places. It dries out over minutes after the rain stops, which is the part that makes a
// player notice the weather happened at all.
uniform float u_wet;
uniform float u_sea_level;       // the sea's line: shore, forest and scree gates (terrain_sea)
uniform vec4 u_lake;             // the carved lake's outline: centre x/z, half extents (zero = none)
// The water line that applies here: the sea everywhere, the lake's own inside its outline -
// the rule the grass and the game's water test use. One line for both put a lake above the
// sea with no wet shore and forest painted down its bed.
float waterLine(vec2 xz) {
  float wl = u_sea_level;
  if (u_lake.z > 0.0) { vec2 q = (xz - u_lake.xy) / u_lake.zw;  if (dot(q, q) < 1.0) wl = max(wl, u_lake_level); }
  return wl;
}
uniform vec2 u_origin;           // world offset of the terrain grid

// The ground's own sun shadow comes from the baked height-field map (tershadow.frag),
// applied inside sunShadow() for every receiver in the scene.
// bicubic (B-spline) sample through four bilinear taps: the 10 m photo pixels stop reading as squares
vec3 orthoSmooth(vec2 uv) {
  vec2 res = vec2(textureSize(u_ortho, 0));
  vec2 t = uv * res - 0.5;
  vec2 f = fract(t);
  vec2 i = floor(t);
  vec2 w0 = (1.0 - f) * (1.0 - f) * (1.0 - f) / 6.0, w1 = (4.0 - 6.0 * f * f + 3.0 * f * f * f) / 6.0;
  vec2 w3 = f * f * f / 6.0, w2 = 1.0 - w0 - w1 - w3;
  vec2 s0 = w0 + w1, s1 = w2 + w3;
  vec2 o0 = (i - 1.0 + w1 / s0 + 0.5) / res, o1 = (i + 1.0 + w3 / s1 + 0.5) / res;
  return (texture(u_ortho, vec2(o0.x, o0.y)).rgb * s0.x + texture(u_ortho, vec2(o1.x, o0.y)).rgb * s1.x) * s0.y
       + (texture(u_ortho, vec2(o0.x, o1.y)).rgb * s0.x + texture(u_ortho, vec2(o1.x, o1.y)).rgb * s1.x) * s1.y;
}
uniform mat4 u_view;

// B-spline bicubic sample of the height field, through four bilinear taps. The height
// texture is only C0 under bilinear filtering: its slope jumps at every texel edge, and
// the mesh chords across each triangle, so the geometry and the normal were reading two
// different surfaces and the shading kinked along every triangle diagonal. Both stages
// call this, so they now agree on one smooth surface.
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
// baked at generation (ternormal.frag) into the height texture's GBA
vec3 terrainNormal(vec2 uv) {
  return normalize(texture(u_height, uv).gba);
}

// stochastic (triangle-grid) sampling: three randomly offset / rotated taps blended by
// barycentric weights, so a scanned tile never repeats visibly
void triGrid(vec2 uv, out float w1, out float w2, out float w3, out vec2 v1, out vec2 v2, out vec2 v3) {
  const mat2 skew = mat2(1.0, 0.0, -0.57735027, 1.15470054);
  vec2 sk = skew * (uv * 3.4641016);
  vec2 base = floor(sk);
  vec3 t = vec3(fract(sk), 0.0);
  t.z = 1.0 - t.x - t.y;
  if (t.z > 0.0) { w1 = t.z; w2 = t.y; w3 = t.x; v1 = base; v2 = base + vec2(0, 1); v3 = base + vec2(1, 0); }
  else { w1 = -t.z; w2 = 1.0 - t.y; w3 = 1.0 - t.x; v1 = base + vec2(1, 1); v2 = base + vec2(1, 0); v3 = base + vec2(0, 1); }
}
// The per-cell rotation must be applied to the DERIVATIVES as well as the coordinate.
// Handing textureGrad the gradients of the unrotated uv makes every cell sample with a
// footprint pointing the wrong way, so each one lands on a slightly different mip and
// anisotropy — and that per-cell difference is exactly the faint lattice over every
// surface. Returning the rotation lets the caller transform its gradients to match.
mat2 cellRot(vec2 cell) {
  float a = hash1(cell) * 6.2831853;
  float c = cos(a), s = sin(a);
  return mat2(c, s, -s, c);
}
vec2 rotUV(vec2 uv, vec2 cell) {
  return cellRot(cell) * uv + hash2(cell + 3.7) * 4.0;
}
// A tap whose weight rounds away is a tap not worth taking. The barycentric weights are
// raised to the fourth power to sharpen the blend, which leaves one of the three
// dominant over most of the plane and the other two often at a few thousandths; taking
// only the ones that carry any of the result, and renormalising over those, is
// indistinguishable from taking all three and is most of what this shader used to spend
// on the ground. TRI_EPS is the weight below which a tap cannot move an 8-bit channel.
#define TRI_EPS 0.004
vec4 sampleCarpet(vec2 uv, vec2 dx, vec2 dy) {
  float w1, w2, w3; vec2 v1, v2, v3;
  triGrid(uv * 0.3, w1, w2, w3, v1, v2, v3);
  vec3 w = pow(vec3(w1, w2, w3), vec3(4.0)); w /= (w.x + w.y + w.z);
  vec4 acc = vec4(0.0);
  float wsum = 0.0;
  if (w.x > TRI_EPS) { mat2 C = cellRot(v1);  acc += textureGrad(u_carpet, rotUV(uv, v1), C * dx, C * dy) * w.x;  wsum += w.x; }
  if (w.y > TRI_EPS) { mat2 C = cellRot(v2);  acc += textureGrad(u_carpet, rotUV(uv, v2), C * dx, C * dy) * w.y;  wsum += w.y; }
  if (w.z > TRI_EPS) { mat2 C = cellRot(v3);  acc += textureGrad(u_carpet, rotUV(uv, v3), C * dx, C * dy) * w.z;  wsum += w.z; }
  return acc / max(wsum, 1e-4);
}
// Stochastic (triangle-grid) sampling: three randomly offset / rotated taps blended by
// barycentric weights, so a scanned tile never repeats visibly. The gradients are
// rotated per cell to match each tap's own rotation — handing textureGrad the gradients
// of the unrotated uv makes every cell sample with a footprint pointing the wrong way,
// landing on a different mip and anisotropy.
// one cell of the triangle grid: its rotation, its offset, and its three maps
void matTap(sampler2D d, sampler2D nm, sampler2D am, vec2 uv, vec2 dx, vec2 dy, vec2 cell, float wt,
            inout vec3 alb, inout vec3 nsum, inout vec3 arm, inout float wsum) {
  mat2 R = cellRot(cell);
  vec2 u = R * uv + hash2(cell + 3.7) * 4.0;
  vec2 gx = R * dx, gy = R * dy;
  alb += textureGrad(d, u, gx, gy).rgb * wt;
  nsum += (textureGrad(nm, u, gx, gy).rgb * 2.0 - 1.0) * wt;
  arm += textureGrad(am, u, gx, gy).rgb * wt;
  wsum += wt;
}
// Stochastic (triangle-grid) sampling: three randomly offset / rotated taps blended by
// barycentric weights, so a scanned tile never repeats visibly. The gradients are
// rotated per cell to match each tap's own rotation — handing textureGrad the gradients
// of the unrotated uv makes every cell sample with a footprint pointing the wrong way,
// landing on a different mip and anisotropy.
//
// The weights are sharpened to the fourth power, which leaves one cell dominant over
// most of the plane and the other two at a few thousandths. Everything a cell needs —
// its rotation (a hash, a sine and a cosine), its offset, its two rotated gradients —
// is computed inside its own test, so a cell that cannot move the result costs nothing.
void sampleMat(sampler2D d, sampler2D nm, sampler2D am, vec2 uv, vec2 dx, vec2 dy, out vec3 alb, out vec3 nrm, out vec3 arm) {
  float w1, w2, w3; vec2 v1, v2, v3;
  triGrid(uv * 0.3, w1, w2, w3, v1, v2, v3);
  vec3 w = pow(vec3(w1, w2, w3), vec3(4.0)); w /= (w.x + w.y + w.z);
  alb = vec3(0.0);  arm = vec3(0.0);
  vec3 nsum = vec3(0.0);
  float wsum = 0.0;
  if (w.x > TRI_EPS) { matTap(d, nm, am, uv, dx, dy, v1, w.x, alb, nsum, arm, wsum); }
  if (w.y > TRI_EPS) { matTap(d, nm, am, uv, dx, dy, v2, w.y, alb, nsum, arm, wsum); }
  if (w.z > TRI_EPS) { matTap(d, nm, am, uv, dx, dy, v3, w.z, alb, nsum, arm, wsum); }
  float iw = 1.0 / max(wsum, 1e-4);
  alb *= iw;  arm *= iw;
  // rotate the tangent normals back with their taps
  nrm = normalize(nsum);
}

void samplePlain(sampler2D d, sampler2D nm, sampler2D am, vec2 uv, vec2 dx, vec2 dy, out vec3 alb, out vec3 nrm, out vec3 arm) {
  alb = textureGrad(d, uv, dx, dy).rgb;
  nrm = textureGrad(nm, uv, dx, dy).rgb * 2.0 - 1.0;
  arm = textureGrad(am, uv, dx, dy).rgb;
}
// triplanar sample for steep rock
void sampleTri(sampler2D d, sampler2D nm, sampler2D am, vec3 p, vec3 dpx, vec3 dpy, vec3 n, float scale, out vec3 alb, out vec3 nrm, out vec3 arm) {
  vec3 w = pow(abs(n), vec3(4.0)); w /= (w.x + w.y + w.z);
  // The fourth power leaves ground facing one axis almost entirely on that axis's plane:
  // a slope has to be within a few degrees of a diagonal before a second projection
  // carries anything, and the third almost never does.
  vec3 a0, n0, r0;
  alb = vec3(0.0);  arm = vec3(0.0);
  vec3 nsum = vec3(0.0);
  float wsum = 0.0;
  if (w.x > TRI_EPS) {
    samplePlain(d, nm, am, p.zy * scale, dpx.zy * scale, dpy.zy * scale, a0, n0, r0);
    alb += a0 * w.x;  arm += r0 * w.x;
    nsum += vec3(n0.xy + n.zy, abs(n0.z) * n.x).zyx * w.x;
    wsum += w.x;
  }
  if (w.y > TRI_EPS) {
    samplePlain(d, nm, am, p.xz * scale, dpx.xz * scale, dpy.xz * scale, a0, n0, r0);
    alb += a0 * w.y;  arm += r0 * w.y;
    nsum += vec3(n0.xy + n.xz, abs(n0.z) * n.y).xzy * w.y;
    wsum += w.y;
  }
  if (w.z > TRI_EPS) {
    samplePlain(d, nm, am, p.xy * scale, dpx.xy * scale, dpy.xy * scale, a0, n0, r0);
    alb += a0 * w.z;  arm += r0 * w.z;
    nsum += vec3(n0.xy + n.xy, abs(n0.z) * n.z) * w.z;
    wsum += w.z;
  }
  float iw = 1.0 / max(wsum, 1e-4);
  alb *= iw;  arm *= iw;
  nrm = normalize(nsum);
}

vec3 dbg_n; vec3 dbg_alb; float dbg_shadow; vec3 dbg_mat;
// cheap = the far tier: single taps, noise at its mean, one shadow tap. Same code, same
// mean colour, so the tier boundary cannot show as a ring.
float fbmC(bool cheap, vec2 q, int o) { return cheap ? 0.0 : fbm(q, o); }
float ridgedC(bool cheap, vec2 q, int o) { return cheap ? 0.35 : ridged(q, o); }
float gnoiseC(bool cheap, vec2 q) { return cheap ? 0.0 : gnoise(q); }
vec3 orthoC(bool cheap, vec2 uv) { return cheap ? textureLod(u_ortho, uv, 1.0).rgb : orthoSmooth(uv); }
vec4 carpetC(bool cheap, vec2 uv, vec2 dx, vec2 dy) { return cheap ? textureGrad(u_carpet, uv, dx, dy) : sampleCarpet(uv, dx, dy); }
void matC(bool cheap, sampler2D d, sampler2D nm, sampler2D am, vec2 uv, vec2 dx, vec2 dy, out vec3 alb, out vec3 nrm, out vec3 arm) {
  if (cheap) samplePlain(d, nm, am, uv, dx, dy, alb, nrm, arm); else sampleMat(d, nm, am, uv, dx, dy, alb, nrm, arm);
}
void triC(bool cheap, sampler2D d, sampler2D nm, sampler2D am, vec3 p, vec3 dpx, vec3 dpy, vec3 n, float scale, out vec3 alb, out vec3 nrm, out vec3 arm) {
  if (cheap) { samplePlain(d, nm, am, p.xz * scale, dpx.xz * scale, dpy.xz * scale, alb, nrm, arm); nrm = normalize(vec3(nrm.x, 1.0, nrm.y) + vec3(0.0, 1e-3, 0.0)); }
  else sampleTri(d, nm, am, p, dpx, dpy, n, scale, alb, nrm, arm);
}
#ifdef SUN_INLINE
// Vulkan: the cascades are read here, in the ground's own shader, and tersun.frag's pass - a second
// rasterisation of every patch - is not drawn. The cliff tersun.frag describes is OpenGL's driver, and
// OpenGL keeps that pass. The same normal, the same two tiers and the same cross-fade as tersun.frag.
uniform float u_far_split;
uniform float u_far_band;
float sunInline(vec3 p, float dist, float viewDepth) {
  vec3 Ng = normalize(texture(u_height, v_huv).gba);
  if (dist > u_far_split + u_far_band) return sunShadowCheap(p, Ng, viewDepth);
  if (dist < u_far_split - u_far_band) return sunShadow(p, Ng, viewDepth);
  return mix(sunShadow(p, Ng, viewDepth), sunShadowCheap(p, Ng, viewDepth),
             smoothstep(u_far_split - u_far_band, u_far_split + u_far_band, dist));
}
#endif
vec3 groundShade(vec3 p, vec3 N, float slope, float dist, float viewDepth, bool cheap) {
  // ---- material weights ----
  float macro = fbmC(cheap, p.xz * 0.02, 2);
  // a foot track: two metres wide, worn into whatever the ground is, not a painted band
  float pathW = 0.6 * smoothstep(3.0 + 0.8 * macro, 1.0, pathDist(p.xz)) * smoothstep(0.35, 0.1, slope);
  float rockW = max(smoothstep(0.30, 0.55, slope + 0.1 * macro), 0.9 * smoothstep(170.0, 300.0, p.y + 30.0 * macro));
  // The ridge field places the snow line's raggedness and nothing else. Both terms below
  // are zero more than 160 m under the snow line whatever it returns (macro and ridgeN
  // can lift the test height by at most 100 m), which is the whole valley floor.
  float snowW = 0.0;
  if (p.y > u_snow_line - 160.0) {
    float ridgeN = ridgedC(cheap, p.xz * 0.0018 + 11.0, 2);
    snowW = smoothstep(u_snow_line - 60.0, u_snow_line + 60.0, p.y + 60.0 * macro + 40.0 * ridgeN) * smoothstep(0.55, 0.15, slope);
    // wind-packed snow lingers in the gullies of the steep faces too
    snowW = max(snowW, 0.6 * smoothstep(u_snow_line - 120.0, u_snow_line, p.y) * smoothstep(0.45, 0.2, slope) * smoothstep(0.55, 0.75, ridgeN));
  }
  float grassW = 1.0 - max(pathW, max(rockW, snowW));

  // ---- what the photograph says is here -------------------------------------------
  // This classification used to sit between the material samples, which meant every
  // pixel sampled every material before anything knew which of them it would use. It
  // runs first now: it costs three filtered taps of the survey image and it decides
  // whether the scanned grass, rock and snow are needed at all.
  vec3 oc = vec3(0.0);
  float forestW = 0.0;      // dense conifer: the ground under it is duff, not meadow
  float screeC = 0.0;       // bare ground: talus, moraine gravel, the lake's cobble shore
  float snowC = 0.0;
  bool orthoOn = u_ortho_on > 0.5;
#ifdef TFAST_4
  orthoOn = false;
#endif
  if (orthoOn) {
    oc = orthoC(cheap, v_huv);
    // (classified from a ~40 m blur: thresholding the raw 10 m pixels drew hard squares)
    vec3 ocf = textureLod(u_ortho, v_huv, 2.0).rgb;
    float gx = ocf.g - max(ocf.r, ocf.b);
    // (the photograph is sampled linear: sRGB 72 is 0.06, 92 is 0.11)
    forestW = smoothstep(0.12, 0.06, max(ocf.r, max(ocf.g, ocf.b))) * smoothstep(0.004, 0.012, gx) * smoothstep(waterLine(p.xz) + 0.8, waterLine(p.xz) + 1.8, p.y);
    // Classify from a ~60 m blur, never from the pixels: the survey's 10 m pixels carry
    // a foot trail as a broken line of bare ground, and thresholding them painted it
    // across the meadow as tan dashes (and, on the CPU, lined boulders up along it).
    vec3 ocl = textureLod(u_ortho, v_huv, 2.5).rgb;
    float mxc = max(ocl.r, max(ocl.g, ocl.b)), mnc = min(ocl.r, min(ocl.g, ocl.b));
    float greenEx = ocl.g - max(ocl.r, ocl.b);
    screeC = smoothstep(0.008, -0.002, greenEx) * smoothstep(0.06, 0.12, mxc) * (1.0 - smoothstep(0.55, 0.75, mxc)) * smoothstep(waterLine(p.xz) + 0.2, waterLine(p.xz) + 1.2, p.y);
    // Snow, according to the photograph: bright and unsaturated. Both of which a SUNLIT ROCK
    // FACE also is, seen from a satellite through several kilometres of air - so the Bells'
    // own faces classified as snow and were painted 90% white, which is the real reason the
    // range named for the colour of its rock rendered as a white cone. It needs the elevation
    // gate the terrain's own snow has: snow does not lie below the snow line in July, however
    // pale the photograph is there.
    snowC = smoothstep(0.08, 0.04, mxc - mnc) * smoothstep(0.62, 0.84, mxc)
          * smoothstep(u_snow_line - 260.0, u_snow_line - 40.0, p.y);
  }
  // snow lingering in the high gullies is drawn further down, but whether it can be
  // there at all is known now, and it is the third caller of the snow sample
  // Snow lingering in the high gullies, and it has to be gated on THE SNOW LINE rather than on
  // two absolute heights. At 450-650 m it started five hundred metres below where snow can lie,
  // covered most of the upper mountain at nine tenths opacity, and is the single biggest reason
  // the Bells rendered as a white cone: the mean colour of that peak measured 208/255 and
  // neutral, which is not rock under any light, it is snow. Gullies hold snow NEAR the line,
  // not half a kilometre under it.
  float gullyGate = smoothstep(u_snow_line - 340.0, u_snow_line - 120.0, p.y) * smoothstep(0.75, 0.35, slope);

  // ---- samples ---------------------------------------------------------------------
  // World-space derivatives, taken once and in unbranched control flow: every sample
  // below is in a branch and takes its gradients from these.
  vec3 dpx = dFdx(p), dpy = dFdy(p);
  vec3 gA = vec3(0.3, 0.4, 0.2), gN = vec3(0.0, 0.0, 1.0), gR = vec3(1.0, 0.8, 0.0);
  // The rock's fallback is the MAROON MEAN, not a neutral grey. The far tier (TFAST_3) skips
  // the rock sample altogether and leaves this constant standing in for it, so a neutral grey
  // here is what the mountain three kilometres away is actually painted - and it is the
  // mountain the range is named for. The file's own rule a hundred lines up says the cheap
  // tier must keep the near tier's MEAN COLOUR or the boundary shows as a ring; this is that
  // rule applied to the one material where the mean is not grey.
  vec3 rA = vec3(0.24, 0.085, 0.065), rN = vec3(0.0, 1.0, 0.0), rR = vec3(1.0, 0.8, 0.0);
  vec3 sA = vec3(0.86, 0.88, 0.92), sN = vec3(0.0, 0.0, 1.0), sR = vec3(1.0, 0.55, 0.0);
  vec3 pA, pN, pR;
  vec2 uvg = p.xz * 0.28;
  vec2 duvgx = dpx.xz * 0.28, duvgy = dpy.xz * 0.28;
  // the grass carries the path too (the track is worn into it), and the forest duff
  float needGrass = max(grassW, pathW);
  float needRock = max(rockW, screeC);
  float needSnow = max(snowW, max(snowC, gullyGate));
#ifdef TFAST_3
  needGrass = 0.0;  needRock = 0.0;
#endif
  if (needGrass > 0.002) {
    // dry / lush variation across the meadow (read only here and by the carpet below)
    float lush = fbmC(cheap, p.xz * 0.006 + 2.0, 2) * 0.5 + 0.5;
    matC(cheap, u_grass_d, u_grass_n, u_grass_a, uvg, duvgx, duvgy, gA, gN, gR);
    // tint the grass by lushness
    gA *= mix(vec3(0.42, 0.55, 0.3), vec3(0.28, 0.55, 0.25), lush) * 0.5;
    // sun-facing slopes (south, +z) dry out lighter and warmer; shaded faces stay deep green
    gA *= mix(vec3(0.85, 0.92, 0.9), vec3(1.12, 1.06, 0.82), smoothstep(-0.35, 0.35, N.z));
    // beyond the blade rings the ground itself carries the clumps: the same cards, seen from above
    // Also under the near blades, at reduced weight: the ground seen between standing
    // blades must carry the same hue as the carpet that replaces them further out, or
    // the field turns from grey-beige to green along a line that walks with the viewer.
    float carpetW = mix(0.55, 1.0, smoothstep(8.0, 45.0, dist)) * smoothstep(0.7, 0.35, slope) * grassW;
#ifdef TFAST_3
    carpetW = 0.0;
#endif
    if (u_carpet_on > 0.5 && carpetW > 0.002) {
      vec4 cp = carpetC(cheap, p.xz / 6.0, dpx.xz / 6.0, dpy.xz / 6.0);
      // the standing blades in front of it are self-shaded: the carpet is held darker to match them
      vec3 cc = cp.rgb * vec3(0.5, 0.57, 0.45) * mix(vec3(0.85, 0.92, 0.9), vec3(1.1, 1.05, 0.85), smoothstep(-0.35, 0.35, N.z)) * (0.75 + 0.35 * lush);
      gA = mix(gA, cc, max(cp.a, 0.35) * carpetW * 0.97);
    }
    // The blades' own patches (grass_cull.comp's bladeField): patchiness and dry patches, so where
    // the blades thin out the ground they stand on carries the same meadow, not a lawn
    {
      float patchy = fbmC(cheap, p.xz * 0.045, 3) * 0.5 + 0.5;
      float dryp = smoothstep(0.2, 0.8, gnoise(p.xz * 0.33 + 17.0) * 0.5 + 0.5);
      vec3 pf = mix(vec3(0.7, 0.8, 0.55), vec3(1.1, 1.05, 0.85), patchy) * mix(vec3(0.92, 1.0, 0.95), vec3(1.30, 1.10, 0.62), dryp);
      // and the tussocks' own shade, half a metre across: where blades stand a pixel wide the ground
      // is most of what shows, and it has to carry the same light and dark as the blades on it
      float tus = 0.55 + 0.80 * (gnoise(p.xz * 1.9 + 41.0) * 0.5 + 0.5);
      gA *= mix(vec3(1.0), pf / vec3(0.95, 0.96, 0.72) * tus, grassW);
      if (u_grass_reach > 0.0) gA *= mix(1.0, mix(0.50, 1.0, smoothstep(u_grass_reach * 0.25, u_grass_reach, dist)), grassW);
    }
    // Subalpine forest floor: dark duff where the stands are dense. The photograph-driven
    // term marks duff only where the survey actually shows dense conifer, and is the same
    // at any distance — ground shading must not depend on where the viewer is.
    gA = mix(gA, vec3(0.045, 0.06, 0.025), forestW * 0.85);
  }
  pA = gA * vec3(0.95, 0.82, 0.62);   // the same ground, worn to earth
  pN = gN;  pR = vec3(0.9, 0.85, 0.0);
  // the scanned cliff face on the steep, high slopes; scree below
  // The cliff sample and the relief/cliff blend that used to sit here wrote rA/rN/rR
  // and were then overwritten wholesale by the rock sample below — they never reached
  // the screen (removing them is pixel-identical). Deleting them frees the two sampler
  // slots the histogram LUT needs; this shader was at the hardware limit of 16.
  if (needRock > 0.002) {
    triC(cheap, u_rock_d, u_rock_n, u_rock_a, p, dpx, dpy, N, 0.12, rA, rN, rR);
    // macro rock structure for the mountains: a coarse second tile, strata darkening, blue-grey shade side
    vec2 uv2 = p.xz * 0.006 + p.y * 0.002;
    vec3 rA2 = textureGrad(u_rock_d, uv2, dpx.xz * 0.006 + dpx.y * 0.002, dpy.xz * 0.006 + dpy.y * 0.002).rgb;
    vec3 rN2 = textureGrad(u_rock_n, p.zy * 0.01, dpx.zy * 0.01, dpy.zy * 0.01).rgb * 2.0 - 1.0;
    rA = mix(rA, rA * rA2 * 2.2, 0.35) * (0.9 + 0.2 * fbmC(cheap, vec2(p.y * 0.03, p.x * 0.004 + p.z * 0.004), 3));
    // the Bells' sedimentary strata: near-horizontal bands, tilted a little, sharper on the cliffs
    float strata = 0.5 + 0.5 * sin(p.y * 0.45 + p.x * 0.012 + 3.0 * fbmC(cheap, p.xz * 0.01, 2));
    rA *= mix(1.0, 0.75 + 0.5 * smoothstep(0.35, 0.65, strata), 0.5 * smoothstep(0.3, 0.6, slope));
    rN = normalize(rN + vec3(rN2.x, 0.0, rN2.y) * 0.6 * smoothstep(80.0, 400.0, dist));
    // the Bells are maroon mudstone: warm red-brown rock with grey scree below
    // The Bells are maroon mudstone: warm red-brown rock, with grey weathered scree below.
    // These were tuned while 55% of a grey photograph was mixed over them, so they had to
    // be dark and timid to survive it; with the rock now mostly its own colour they can be
    // the colour the range is named for.
    // Darker AND more saturated, which are different knobs and I moved the wrong one first:
    // raising the magnitude from 0.14 to 0.38 made the face lighter, not redder, and it came
    // out pale tan. The albedo debug view measured red:blue at 1.56 where maroon mudstone wants
    // nearer 4, so what this needed was the GREEN and BLUE pulled down, not the red pushed up.
    rA *= mix(vec3(0.30, 0.085, 0.065), vec3(0.47, 0.155, 0.115), fbmC(cheap, p.xz * 0.003, 2) * 0.5 + 0.5);
  }
  if (needSnow > 0.002) {
    sA = textureGrad(u_snow_d, p.xz * 0.25, dpx.xz * 0.25, dpy.xz * 0.25).rgb * 0.8;
  }
  // ---- blend (height-ish: sharpen with the weights) ----
  vec3 alb = gA * grassW + pA * pathW + rA * rockW + sA * snowW;
  // the photographed surface (a satellite image of this ground) takes over with distance,
  // keeping the scanned materials' fine luminance detail so the middle ground still has grain
  float screeMix = 0.0;
  if (orthoOn) {
    if (screeC > 0.002) {
      // near the camera the scanned rocks take the scree at cobble scale (the far talus keeps the coarse tile)
      float pebW = smoothstep(220.0, 40.0, dist);
      vec3 pebA = vec3(0.36, 0.35, 0.33), pebN = vec3(0.0, 0.0, 1.0);
      if (pebW > 0.002) {
        pebA = textureGrad(u_rock_d, p.xz * 0.55, dpx.xz * 0.55, dpy.xz * 0.55).rgb * vec3(0.36, 0.35, 0.33);
        pebN = textureGrad(u_rock_n, p.xz * 0.55, dpx.xz * 0.55, dpy.xz * 0.55).rgb * 2.0 - 1.0;
      }
      vec3 screeA = mix(rA * vec3(1.25, 1.2, 1.15), pebA * (0.75 + 0.5 * fbmC(cheap, p.xz * 0.15, 2)), pebW);
      // the 10 m photo pixels blur turf and gravel together on the shore: keep grass showing between the cobbles
      alb = mix(alb, screeA, screeC * (1.0 - rockW) * mix(0.55, 0.9, smoothstep(30.0, 200.0, dist)));
      rN = normalize(mix(rN, normalize(vec3(pebN.x, 1.0, pebN.y)), screeC * pebW * 0.8));
      screeMix = screeC;
    }
    alb = mix(alb, sA, snowC * 0.9);
    float lumA = dot(alb, vec3(0.3, 0.59, 0.11));
    // How much of the photograph shows through. This was smoothstep(260, 800, dist) —
    // ground colour cross-fading toward the survey image as it receded from the camera.
    // The photograph has shadows and dark vegetation baked into it from the day it was
    // flown, so grass that was plain up close grew dark patches as you backed away, and
    // those patches slid and changed shape as you walked. A constant keeps the
    // photograph's large-scale colour without tying any of it to the camera.
    // How much of the photograph shows through, and it is NOT one number any more.
    //
    // The Maroon Bells are named for the colour of their mudstone and rendered grey, and
    // this line was why: the maroon tint two hundred lines up is real, and then 55% of a
    // hazy, sun-washed aerial photograph was mixed over the top of it everywhere. A survey
    // image is a good record of WHERE the forest and the scree are and a poor record of
    // what a steep rock face is coloured - it is shot through kilometres of atmosphere at
    // an angle no player ever stands at.
    //
    // So the photograph keeps the meadow and the forest, where it carries real variation
    // nothing else knows about, and gives the rock back to the rock. Deliberately NOT a
    // distance fade: one used to live here and was removed because the photograph has the
    // day's own shadows baked into it, so grass that was plain up close grew dark patches
    // as you backed away and those patches slid as you walked. This keys off the material,
    // which does not move when the camera does.
    float orthoW = 0.55 * (1.0 - 0.62 * rockW);
    // ...and it falls away with HEIGHT as well. A survey image is least trustworthy exactly
    // where it matters most here: a high face is shot through the most air, at the most
    // oblique angle, and comes back pale and grey whatever colour the rock is. Down in the
    // valley the same image is the best record there is of where the meadow, the duff and the
    // gravel actually are, so it keeps the valley and gives up the mountain.
    orthoW *= 1.0 - 0.72 * smoothstep(280.0, 720.0, p.y);
    // grain at three scales so the far slopes keep structure the photograph's pixels cannot carry
#ifdef TFAST_20
    float grain = 0.82;
#else
    float grain = 0.82 + 0.36 * fbmC(cheap, p.xz * 0.7, 2) + 0.12 * fbmC(cheap, p.xz * 4.0, 2) + 0.3 * (fbmC(cheap, p.xz * 0.06 + 5.0, 3) - 0.5) + 0.15 * (ridgedC(cheap, p.xz * 0.02 + 9.0, 2) - 0.5);
#endif
    alb = mix(alb, oc * (0.35 + 1.4 * lumA / max(lumA + 0.12, 1e-3)) * grain, orthoW);
  }
  // ---- the shoreline, continued onto the land ------------------------------------
  // A flat water plane cutting a slope meets it along one exact contour, and no amount
  // of shading on the water side removes a mathematically sharp line. The transition
  // has to be drawn on BOTH surfaces, so the same wash the water runs is continued up
  // the bank here: identical noise fields, identical time, identical phase, keyed off
  // height above the lake instead of depth below it. Across the seam the two agree, so
  // there is nothing there to read as an edge.
  float above = p.y - waterLine(p.xz);                    // >0 on land, metres
  // wet ground: darker and glossier near the water, fading out over ~1.2 m
  float wet = smoothstep(1.2, 0.0, above);
  // the rain's wetness joins the shore's: the same term, from a different cause
  wet = max(wet, u_wet);
  alb *= mix(1.0, 0.5, wet * 0.85);
  // Puddles. A soaked ground does not darken evenly - water finds the low places, and the flat
  // ground holds it while a slope sheds it. The noise is the same macro field the materials
  // already use, so a puddle sits where the ground is genuinely dished rather than in a
  // pattern of its own.
  float pud = 0.0;
  if (u_wet > 0.01) {
    float lowness = smoothstep(0.35, 0.0, slope);
    pud = smoothstep(0.45, 0.72, fbmC(cheap, p.xz * 0.35 + 17.0, 2) * 0.5 + 0.5) * lowness * u_wet;
  }
  // A sheet of water actually runs up the bank ahead of the foam, so the ground inside
  // the wash is seen through water, not bare. Without this the gaps between the foam
  // streaks showed dry grass and the wash looked like white paint on a lawn.
  float film = smoothstep(0.4, 0.0, above);
  vec3 shoreWater = vec3(0.05, 0.11, 0.13) * skyIrradiance(vec3(0, 1, 0)) * 1.15;
  alb = mix(alb, mix(alb * 0.5, shoreWater, 0.45), film);
  // The wash itself: the water's lap, run above the line and fading as it climbs — the
  // same fields, octaves and phase the water uses, so the two agree across the seam.
  // Its two gates — the last 22 cm above the waterline, and the first 120 m from the
  // camera — are pure geometry, and outside them the four noise fields behind it cannot
  // reach the screen. They are worth testing first: the wash is a hairline along one
  // shore and the fields were being evaluated for every pixel of the valley.
  float washGate = smoothstep(0.22, 0.0, above) * smoothstep(120.0, 15.0, dist);
  if (washGate > 0.002) {
    float lapT = 0.5 + 0.5 * sin(-above * 9.0 - u_time * 1.6 + 2.0 * gnoiseC(cheap, p.xz * 0.8 + u_time * 0.2));
    float fdetT = fbmC(cheap, p.xz * 7.0 - u_time * 0.35, 3) * 0.5 + 0.5;
    float fmidT = fbmC(cheap, p.xz * 2.6 + u_time * 0.5, 3) * 0.5 + 0.5;
    float fedgeT = fbmC(cheap, p.xz * 1.4 - u_time * 0.3, 2) * 0.5 + 0.5;
    // a still alpine lake has a wet line, not surf: keep the wash thin and faint
    float fringe = washGate
                 * (0.12 * smoothstep(0.30, 0.72, fmidT)
                  + 0.10 * smoothstep(0.55, 0.95, lapT) * smoothstep(0.22, 0.6, fedgeT)) * (0.55 + 0.75 * fdetT);
    alb = mix(alb, vec3(0.72, 0.76, 0.76), clamp(fringe, 0.0, 1.0));
  }
  // snow lingering in the high gullies (the July photograph's white streaks)
  float gully = 0.0;
  if (gullyGate > 0.002) { gully = smoothstep(0.62, 0.85, ridgedC(cheap, p.xz * 0.02 + 3.0, 2)) * gullyGate; }
  alb = mix(alb, sA * 1.05, gully * 0.9);
  vec3 arm = gR * grassW + pR * pathW + rR * rockW + sR * snowW;
  // world tangent frame for the planar maps
  vec3 T = normalize(vec3(1.0, 0.0, 0.0) - N * N.x);
  vec3 B = cross(N, T);
  vec3 tn = normalize(gN * grassW + pN * pathW + sN * snowW + vec3(0, 0, 1e-3));
  vec3 nPlanar = normalize(T * tn.x + B * tn.y + N * tn.z);
  vec3 n = normalize(mix(nPlanar, rN, max(rockW, screeMix * 0.6)));
  // fade the detail normal with distance so the far terrain does not sparkle
  n = normalize(mix(n, N, smoothstep(150.0, 900.0, dist)));
  float ao = arm.r;
  float rough = clamp(arm.g, 0.3, 1.0);
  // Wet ground is SMOOTH. That is what makes a soaked meadow read as soaked rather than as
  // dark: the sky glances off it. A puddle is smoother still and flat, so its normal is the
  // world's up rather than the ground's relief.
  rough = mix(rough, 0.28, wet * 0.8);
  if (pud > 0.01) {
    rough = mix(rough, 0.06, pud);
    n = normalize(mix(n, vec3(0.0, 1.0, 0.0), pud * 0.9));
    alb = mix(alb, alb * 0.55, pud);
  }
  float metal = 0.0;
  // the shadow map carries the objects standing on the ground (trees, rocks); the
  // ground's own relief is in the baked height-field shadow that sunShadow() applies
#ifdef TFAST_1
  float shadow = 1.0;
#elif defined(SUN_INLINE)
  float shadow = sunInline(p, dist, viewDepth);
#else
  // tersun.frag computed this for exactly this pixel; see the note there for why the
  // cascade read cannot happen in here (on OpenGL).
  float shadow = texelFetch(u_sunshadow, ivec2(gl_FragCoord.xy), 0).r;
#endif
  vec3 col = shade(p, n, alb, rough, metal, ao, shadow, viewDepth);
  dbg_n = n; dbg_alb = alb; dbg_shadow = shadow; dbg_mat = vec3(rockW, grassW, snowW);
  return col;
}

#ifndef SUN_INLINE
uniform float u_far_split;
uniform float u_far_band;
#endif
void main() {
  vec3 p = v_wpos;
  if (p.y < u_clip_y) discard;
  vec3 N = terrainNormal(v_huv);
  float slope = 1.0 - N.y;
  float dist = length(p - u_cam_pos);
  float viewDepth = -(u_view * vec4(p, 1.0)).z;
  vec3 col;
#ifdef NEAR_ONLY
  // The near program: this patch lies entirely inside the split, so only the detailed
  // tier can run here. Compiled alone it does not have to hold the cheap tier's code
  // beside it, which is what pushed the combined shader past the register budget.
  col = groundShade(p, N, slope, dist, viewDepth, false);
#elif defined(FAR_ONLY)
  // The far program: this patch is entirely beyond u_far_split + u_far_band, so every
  // pixel in it would take the cheap tier anyway. Compiling that tier on its own — with
  // no near path inlined beside it — is the whole point: the two tiers together put this
  // shader over the register budget, and the far pixels (most of the screen: the valley
  // walls and the Bells) were paying for a near path they never ran.
  col = groundShade(p, N, slope, dist, viewDepth, true);
#elif defined(TFAST_5)
  col = groundShade(p, N, slope, dist, viewDepth, false);
#else
  float band = u_far_band;
  if (dist > u_far_split + band) col = groundShade(p, N, slope, dist, viewDepth, true);
  else if (dist < u_far_split - band) col = groundShade(p, N, slope, dist, viewDepth, false);
  else col = mix(groundShade(p, N, slope, dist, viewDepth, false), groundShade(p, N, slope, dist, viewDepth, true), smoothstep(u_far_split - band, u_far_split + band, dist));
#endif
  col = applyFog(col, p, dist);
#ifdef DEBUG_SHADOW
  col = vec3(dbg_shadow);
#endif
#ifdef DEBUG_NRM
  col = dbg_n * 0.5 + 0.5;
#endif
#ifdef DEBUG_MAT
  col = dbg_mat;
#endif
#ifdef DEBUG_WIND
  // The wind field itself, painted on the ground: R3D_DEBUG_WIND=1 with two shots a moment
  // apart shows the gust fronts and shows them MOVING, which no still of grass ever will.
  col = vec3(windGust(p.xz, u_time)) * vec3(1.0, 0.95, 0.75);
#endif
#ifdef DEBUG_ALB
  col = dbg_alb * 3.0;
#endif
  o_color = vec4(sane(col), 1.0);
}
