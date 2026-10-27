// oimp.frag - the far building: three atlas frames blended, each read at the card's point as that frame's own
// orthographic view sees it (oimp_basis / oimp_project), lit from the normal the bake stored.
in vec3 v_wpos;
in vec2 v_q;
in vec3 v_lctr;
in vec4 v_fw;
in vec3 v_fi;
in vec4 v_tint;
in vec4 v_rot;
in vec3 v_ldir;
out vec4 o_color;
uniform sampler2D u_atlas_albedo;
uniform sampler2D u_atlas_normal;
uniform mat4 u_view;
uniform float u_radius;
uniform float u_frames;
uniform float u_frame_px;
uniform vec4 u_imp_alt;          // the alternative's colour and share (kgpu_card_alt): 0 share for none

vec3 octDecode(vec2 uv) {
  vec2 a = uv * 2.0 - 1.0;
  vec2 p = vec2((a.x + a.y) * 0.5, (a.x - a.y) * 0.5);
  float y = 1.0 - abs(p.x) - abs(p.y);
  return normalize(vec3(p.x, y, p.y));
}
// frame f's camera basis, in the model's frame (oimp_basis)
void frameBasis(vec3 d, out vec3 right, out vec3 up) {
  vec3 u0 = abs(d.y) > 0.999 ? vec3(0.0, 0.0, -1.0) : vec3(0.0, 1.0, 0.0);
  right = normalize(cross(u0, d));
  up = cross(d, right);
}
// the atlas uv of this card point in frame f (oimp_project, oimp_atlas_uv)
vec2 frameUv(float f, vec3 p) {
  float n = u_frames;
  float i = mod(f, n);
  float j = floor(f / n);
  vec3 d = octDecode(vec2(i, j) / max(n - 1.0, 1.0));
  vec3 right, up;
  frameBasis(d, right, up);
  vec2 q = vec2(dot(p, right), dot(p, up)) / (2.0 * u_radius) + 0.5;
  float sz = 1.0 / n;
  float half_texel = 0.5 / (n * u_frame_px);
  vec2 qc = clamp(q, 0.0, 1.0);
  return vec2(i, j) * sz + vec2(half_texel) + qc * (sz - 2.0 * half_texel);
}
void main() {
  if (v_wpos.y < u_clip_y) discard;
#ifndef SHADOW_PASS
  if (fogCut(v_wpos)) discard;   // the fog wall's dissolve (lighting.glsl)
#endif
  vec4 a = vec4(0.0);
  vec4 nn = vec4(0.0);
  float wsum = 0.0;
  for (int k = 0; k < 3; k++) {
    float w = v_fw[k];
    float f = v_fi[k];
    vec2 uv = frameUv(f, v_lctr);
    vec4 ta = texture(u_atlas_albedo, uv);
    vec4 tn = texture(u_atlas_normal, uv);
    // premultiplied by coverage: weight by it so an empty corner of one frame does not dim a full one
    a += ta * w;
    nn += tn * w;
    wsum += w;
  }
  a /= max(wsum, 1e-4);
  nn /= max(wsum, 1e-4);
  float cov = (a.a - 0.35) / max(fwidth(a.a), 1e-4) + 0.5;
  if (cov < 0.02) discard;
  float rawA = a.a;
  vec3 col0 = a.rgb / max(rawA, 1e-3);
  // the bake's normal, in the model's frame, turned back out by the instance's yaw
  vec3 nl = clamp(nn.rgb / max(rawA, 1e-3), 0.0, 1.0) * 2.0 - 1.0;
  // the bake's occlusion in the lower half; the top marks a material with an alternative (bake.frag)
  float aw = clamp(nn.a / max(rawA, 1e-3), 0.0, 1.0);
  float altT = smoothstep(0.42, 0.58, aw);
  float ao = mix(clamp(aw / 0.49, 0.0, 1.0), 1.0, altT);
  float s = v_rot.x, c = v_rot.y;
  vec3 n = normalize(vec3(c * nl.x + s * nl.z, nl.y, -s * nl.x + c * nl.z));
  float dist = length(v_wpos - u_cam_pos);
  float viewDepth = -(u_view * vec4(v_wpos, 1.0)).z;
  vec3 alb = col0 * v_tint.rgb * (0.92 + 0.16 * fract(v_rot.z * 7.13));
  // an instance that wears the alternative near (kit.frag: the same seed, the same share) wears its colour on those texels here
  if (u_imp_alt.w > 0.0 && fract(v_rot.z * 91.7 + 0.31) < u_imp_alt.w) alb = mix(alb, u_imp_alt.rgb, altT);
  float shadow = sunShadowCheap(v_wpos, vec3(0.0, 1.0, 0.0), viewDepth);
  vec3 col = shade(v_wpos, n, alb, 0.85, 0.0, ao, shadow, viewDepth);
  col = applyFog(col, v_wpos, dist);
  o_color = vec4(sane(col), clamp(cov, 0.0, 1.0));
}
