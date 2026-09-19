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
void main() {
  float s = i_rot.x, c = i_rot.y;
  vec3 p = a_pos * i_pos.w;
#ifdef CARD
  p = vec3(p.x * u_card_w, p.y * u_card_h, p.z * u_card_w);
#endif
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
  p.x += sway * hgt * hgt * 0.35;
  p.z += sway * hgt * hgt * 0.15 * cos(ph * 0.7);
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
}
