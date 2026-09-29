// instanced glTF model: attribute 3 = (x, y, z, scale), 4 = (sin yaw, cos yaw, seed, wind)
layout(location = 0) in vec3 a_pos;
layout(location = 1) in vec3 a_nrm;
layout(location = 2) in vec2 a_uv;
layout(location = 3) in vec4 i_pos;
layout(location = 4) in vec4 i_rot;
uniform mat4 u_view;
uniform mat4 u_proj;
uniform mat4 u_light_vp;
uniform float u_time;
uniform float u_wind;
uniform float u_card_w;
uniform float u_card_h;
#ifdef BLADE
uniform vec3 u_cam_pos;
uniform float u_cull;        // the blade ring's edge (m)
#endif
// Ground cover is placed on the CPU from a bilinear read of the 4 m height texels, but
// the terrain is drawn from a B-spline of the same texels — two different surfaces,
// up to half a metre apart on rough ground, which buried blades and floated cards.
// Cover layers (u_ground) read the surface the terrain actually draws, so they always
// stand on it, at any tessellation level, with no hand-tuned lift.
uniform float u_ground;
uniform sampler2D u_ts_height;
uniform vec2 u_ts_origin;
uniform float u_ts_half;
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
out vec3 v_wpos;
// The foliage prepass (depth.frag) and the lit pass after it compile this same source
// into two programs and compare depths for equality: the position must come out
// bit-identical in both, which is what `invariant` promises.
invariant gl_Position;
out vec3 v_nrm;
out vec2 v_uv;
out float v_seed;
out vec2 v_rot;
// Crown hull: a tree's needle cards are lit as if they were the surface of a rounded
// crown (normal from the crown's centre), not each as a flat top-lit quad, and the
// cards near the trunk are darkened as the crown's interior. This is how game trees
// have been shaded since SpeedTree; without it a card crown reads as frosted.
uniform float u_model_h;     // the model's height (m), 0 = not a crown
out float v_hull;            // 0 at the crown's axis .. 1 at its rim
// An aspen leaf hangs on a flattened stalk, so it twists in air a conifer does not feel at
// all. u_flutter is per layer: 0 for everything else, and the quake is written out as a
// varying so the fragment stage can flash the leaf's pale underside as it turns - which is
// the part you actually SEE. A still frame of a tremble is a still frame of nothing.
uniform float u_flutter;
out float v_near;                // 0 in the camera's face, 1 past arm's length (NEAR_FADE)
out float v_quake;
out float v_lh;                  // height above the model's base (m): a small plant's ground occlusion
void main() {
  float s = i_rot.x, c = i_rot.y;
  v_quake = 0.0;
  vec3 p = a_pos * i_pos.w;
#ifdef CARD
  p = vec3(p.x * u_card_w, p.y * u_card_h, p.z * u_card_w);
#endif
  v_lh = max(p.y, 0.0);
  vec3 n = a_nrm;
#ifdef BLADE
  // distant blades: wider so a thinner field keeps its coverage, lit like the ground
  // they stand on, and sunk into the carpet texture at the ring's edge instead of popping
  float bd = distance(u_cam_pos.xz, i_pos.xz);
  p.x *= 1.0 + 2.5 * smoothstep(12.0, 90.0, bd);
  p.y *= 1.0 - smoothstep(u_cull * 0.72, u_cull, bd);
  n = normalize(mix(n, vec3(0.0, 1.0, 0.0), smoothstep(15.0, 70.0, bd)));
#endif
  v_rot = vec2(s, c);
  p = vec3(c * p.x + s * p.z, p.y, -s * p.x + c * p.z);
  n = vec3(c * n.x + s * n.z, n.y, -s * n.x + c * n.z);
#ifdef WIND
  // sway grows with height above the base; gust phase from the instance seed
  float hgt = max(p.y, 0.0);
  float ph = u_time * 1.7 + i_rot.z * 6.2831 + i_pos.x * 0.05 + i_pos.z * 0.07;
  // A crown had NO gust at all - only this per-instance wobble - so the canopy swayed to a
  // rhythm of its own while the meadow under it rippled to another. It is the same field now,
  // read at the tree's own place in the world, so a gust crosses the grass and goes on into
  // the trees. `stiff` is 0.35 because a bole resists what a blade cannot.
  float sway = windSway(i_pos.xz, u_time, ph, 0.35) * u_wind * i_rot.w;
  // The bend is a FRACTION OF THE TREE, not a number of metres. `hgt * hgt` in metres is
  // fine for a 40 cm flower and ruinous for a 14 m aspen - it put ten metres of sideways
  // into a trunk and bent it over like a fishing rod, which is what standing under one and
  // looking up finally showed. Normalised, the tip moves a few per cent of the tree's own
  // height whatever the tree is, and the base does not move at all.
  float th = max(u_model_h * i_pos.w, 0.001);
  float hn = (u_model_h > 2.0) ? clamp(hgt / th, 0.0, 1.0) : min(hgt, 1.0);
  // A tree bends a few per cent of its height at the top in a gust, not a fifth of it: at 0.22 a 14 m
  // aspen's crown swung three metres and the bole read as rope. The side-to-side part is slower too.
  float reach = (u_model_h > 2.0) ? th * 0.045 : 0.35;
  p.x += sway * hn * hn * reach;
  p.z += sway * hn * hn * reach * 0.25 * cos(ph * 0.37);
  if (u_model_h > 2.0) {
    // Each branch moves as one piece: nothing at the trunk, more the further out along it, and
    // phased by which way it points out of the trunk - the same all along a branch, where a phase
    // from the vertex's own place wiggled it like a rope - so neighbouring branches are out of step.
    float br = length(a_pos.xz) * i_pos.w;
    float bout = smoothstep(0.35, 2.5, br);
    float bph = u_time * 1.9 + atan(a_pos.z, a_pos.x + 1e-4) * 2.0 + i_rot.z * 6.2831;
    float bamp = (0.25 + windGust(i_pos.xz, u_time)) * u_wind * i_rot.w * bout * br * 0.035;
    p.y += sin(bph) * bamp;
    p.x += cos(bph * 0.8) * bamp * 0.5;
    p.z += sin(bph * 0.7 + 1.3) * bamp * 0.5;
  }
  if (u_flutter > 0.0) {
    // per-leaf, not per-tree: the phase comes from the vertex's own place on the card, so
    // neighbouring leaves are never in step - a crown that trembles as one block reads as
    // the whole tree shivering.
    // a slow change across the model: a leaf card's corners move together and so do a few
    // centimetres of twig, where eleven radians a metre bent every branch along its length
    float qp = u_time * 8.5 + a_pos.x * 3.1 + a_pos.z * 2.7 + a_pos.y * 1.9 + i_rot.z * 6.2831;
    float q = sin(qp) * 0.65 + sin(qp * 1.73 + 1.1) * 0.35;
    // ...and only out on the CROWN. The mask was height alone, so on an aspen every vertex
    // of a ten metre bole above 1.2 m trembled along with the leaves and the TRUNK moved
    // like cloth. What separates a leaf from a bole is not height, it is distance from the
    // model's own centre line: the leaves are out at the edge of the crown and the trunk is
    // on the axis. Small plants keep the old mask - a flower is all leaf.
    float rmask = 1.0;
    if (u_model_h > 2.0) rmask = smoothstep(0.22, 0.75, length(a_pos.xz) / max(u_model_h * 0.22, 0.05));
    float amp = u_flutter * (0.40 + 0.60 * windGust(i_pos.xz, u_time)) * smoothstep(0.0, 1.2, hgt) * rmask;
    p.x += q * amp * 0.05;
    p.y += q * amp * 0.025;
    p.z += cos(qp * 0.9) * amp * 0.05;
    v_quake = q * amp;
  }
#endif
  v_hull = 1.0;
  if (u_model_h > 2.0) {
    vec3 cc = vec3(0.0, u_model_h * i_pos.w * 0.55, 0.0);
    vec3 rel = p - cc;
    float rr = length(rel.xz) / max(u_model_h * i_pos.w * 0.28, 0.1);
    v_hull = clamp(rr, 0.0, 1.0);
    vec3 hull = normalize(vec3(rel.x, rel.y * 0.5, rel.z) + vec3(0.0, 0.15, 0.0));
    n = normalize(mix(n, hull, 0.7));
  }
  vec3 w = p + i_pos.xyz;
  if (u_ground > 0.5) {
    vec2 huv = (i_pos.xz - u_ts_origin) / (2.0 * u_ts_half) + 0.5;
    w.y = heightSmooth(u_ts_height, huv) - 0.03 + p.y;
  }
  v_wpos = w;
  v_nrm = n;
  v_uv = a_uv;
  v_seed = i_rot.z;
#ifdef SHADOW_PASS
  gl_Position = u_light_vp * vec4(w, 1.0);
#else
  gl_Position = u_proj * u_view * vec4(w, 1.0);
#endif
  // Leaves in the camera's face. A third-person camera walks through a crown and the
  // branch between it and the body is an opaque wall a metre from the lens; in first
  // person it is the whole screen. Tree foliage within arm's length of the CAMERA fades
  // out - w is the view-space depth for a perspective projection, so this costs nothing
  // and needs no uniform. Blades, cards and flowers are excluded on purpose: they live at
  // the player's feet, they are always this close, and fading them opens a hole in the
  // meadow. The shadow pass keeps every leaf, or a tree would stop shading the ground it
  // is standing on as you walked up to it.
  v_near = 1.0;
#if defined(NEAR_FADE) && !defined(SHADOW_PASS)
  // The BOLE is never faded, only what hangs off it. A conifer's trunk and its needle
  // cards are one mesh drawn by one program, so the first cut dissolved the trunk into a
  // dither pattern as you walked up to it - a solid tree you can see through reads as a
  // fault, where a branch getting out of your way reads as the camera being polite. Same
  // signal as the quake's crown mask: the trunk is on the model's axis and the foliage is
  // out from it.
  float ax = 1.0;
  if (u_model_h > 2.0) ax = smoothstep(0.12, 0.30, length(a_pos.xz) / max(u_model_h * 0.22, 0.05));
  v_near = mix(1.0, clamp((gl_Position.w - 0.5) / 1.7, 0.0, 1.0), ax);
#endif
}
