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
in float v_xf;                     // the mesh's weight in a crossfade by time (oimp.vert, scatter.ludic sc_xf_pack), -1 none
out vec4 o_color;
uniform sampler2D u_atlas_albedo;
uniform sampler2D u_atlas_normal;
uniform mat4 u_view;
uniform float u_radius;
uniform float u_frames;
uniform float u_frame_px;
uniform vec4 u_imp_alt;
uniform vec4 u_imp_fol;          // a scatter layer's card (SCATTER): x 1 for a foliage layer (its leaves' hue and two-sided light)          // the alternative's colour and share (kgpu_card_alt): 0 share for none

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
// frame f's capture direction (oimp_capture_dir)
vec3 frameDir(float f) {
  float n = u_frames;
  return octDecode(vec2(mod(f, n), floor(f / n)) / max(n - 1.0, 1.0));
}
#ifdef SCATTER
uniform sampler2D u_atlas_depth;   // its frames' depth (bake.frag OCT)
in vec4 v_cen;                     // the model's middle in the world, and the instance's scale
uniform vec4 u_lod_fade;           // the crossfade from the near mesh (model.vert): where the card starts (m), the band (m; 0 none), the camera's x z
#endif
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
#if defined(SCATTER) && !defined(SHADOW_PASS)
  // in the crossfade band the card is dithered IN by the complement of the mesh's dither (model.vert u_lod_fade, model.frag v_near)
  if (u_lod_fade.y > 0.0) {
    float keepMesh = 1.0 - smoothstep(u_lod_fade.x - u_lod_fade.y, u_lod_fade.x, length(v_cen.xz - u_lod_fade.zw));
    if (keepMesh > 0.001 && keepMesh >= fract(sin(dot(gl_FragCoord.xy, vec2(12.9898, 78.233))) * 43758.5453)) discard;
  }
  // by time: the instance's own weight, the same complement
  if (v_xf >= 0.0 && v_xf > 0.001 && v_xf >= fract(sin(dot(gl_FragCoord.xy, vec2(12.9898, 78.233))) * 43758.5453)) discard;
#endif
  vec4 a = vec4(0.0);
  vec4 nn = vec4(0.0);
  float wsum = 0.0;
  vec3 P = v_lctr;                 // the point the frames are read at, in the model's frame about its middle (model units)
#if defined(SCATTER) && !defined(SHADOW_PASS)
  // Unreal's ImpostorBaker reads each frame where ITS camera saw the surface, not at the card: the card's point is followed along the
  // view ray into the strongest frame's baked depth (two steps of its parallax, POM_Impostor), and that one surface point is projected
  // into all three frames (ImposterFrameTransform), so the three photographs line up instead of ghosting; a frame whose depth there
  // disagrees saw some other surface and gives way (its Depth Derived Weights).
  {
    int k0 = (v_fw.x >= v_fw.y && v_fw.x >= v_fw.z) ? 0 : ((v_fw.y >= v_fw.z) ? 1 : 2);
    float f0 = v_fi[k0];
    vec3 d0 = frameDir(f0);
    vec3 V = normalize(v_ldir);
    float vd = max(dot(V, d0), 0.2);
    vec3 X = v_lctr;
    float lod = (u_imp_fol.x > 0.5) ? 2.0 : 0.0;     // a crown's depth smoothed two mips down; a solid prop's read sharp
    for (int it = 0; it < 2; it++) {
      // on a smoothed depth (two mips down: a crown's needles are a noise of near and far that would throw the step about), the step
      // held inside the sphere
      vec2 uv0 = frameUv(f0, X);
      float c0 = textureLod(u_atlas_albedo, uv0, lod).a;
      if (c0 < 0.1) break;
      float z0 = (textureLod(u_atlas_depth, uv0, lod).r / c0 * 2.0 - 1.0) * u_radius;
      // move along the view ray until the point stands at that depth in frame 0's view
      float t = clamp((dot(v_lctr, d0) - z0) / vd, -u_radius, u_radius);
      X = v_lctr - V * t;
    }
    P = X;
  }
#endif
  float covA = 0.0;                 // the coverage from the plain weights (SCATTER: the depth's say is for colour only, so a crown keeps its outline)
  for (int k = 0; k < 3; k++) {
    float w = v_fw[k];
    float f = v_fi[k];
    vec2 uv = frameUv(f, P);
    vec4 ta = texture(u_atlas_albedo, uv);
    vec4 tn = texture(u_atlas_normal, uv);
    covA += ta.a * v_fw[k];
#if defined(SCATTER) && !defined(SHADOW_PASS)
    if (ta.a > 0.05) {
      float zk = (texture(u_atlas_depth, uv).r / ta.a * 2.0 - 1.0) * u_radius;
      float e = (zk - dot(P, frameDir(f))) / (0.12 * u_radius);
      w *= max(exp(-e * e), 0.02);
    }
#endif
    // premultiplied by coverage: weight by it so an empty corner of one frame does not dim a full one
    a += ta * w;
    nn += tn * w;
    wsum += w;
  }
  a /= max(wsum, 1e-4);
  nn /= max(wsum, 1e-4);
#if defined(SCATTER) && !defined(SHADOW_PASS)
  // colour and normal as the depth-weighted frames have them (made straight by their own coverage), worn at the plain coverage
  {
    float wa = max(a.a, 1e-4);
    float cw = covA / max(v_fw.x + v_fw.y + v_fw.z, 1e-4);
    a = vec4(a.rgb / wa * cw, cw);
    nn = nn / wa * cw;
  }
#endif
#ifdef SHADOW_PASS
  if (a.a < 0.3) discard;
  return;
#else
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
  vec3 wpos = v_wpos;
#ifdef SCATTER
  // lit and shadowed where the surface is (the point the frames were read at), not on the card: the crown's sun side in front of the
  // sun's card is lit, its far side behind it shadowed, as the near mesh's own self-shadow
  {
    vec3 Pw = P * v_cen.w;
    wpos = v_cen.xyz + vec3(c * Pw.x + s * Pw.z, Pw.y, -s * Pw.x + c * Pw.z);
  }
#endif
  float dist = length(wpos - u_cam_pos);
  float viewDepth = -(u_view * vec4(wpos, 1.0)).z;
#ifdef SCATTER
  // the near mesh's own per-instance colour (model.frag: value +-15% by seed; FOLIAGE turns red against blue by seed, the leaves only)
  vec3 alb = col0 * v_tint.rgb * (0.85 + 0.3 * fract(v_rot.z * 7.13));
  if (u_imp_fol.x > 0.5) {
    float leaf = smoothstep(0.0, 0.04, col0.g - max(col0.r, col0.b) * 0.9);
    float hj = fract(v_rot.z * 3.71) - 0.5;
    alb *= mix(vec3(1.0), vec3(1.0 + 0.20 * hj, 1.0, 1.0 - 0.20 * hj), leaf);
  }
#else
  vec3 alb = col0 * v_tint.rgb * (0.92 + 0.16 * fract(v_rot.z * 7.13));
#endif
  // an instance that wears the alternative near (kit.frag: the same seed, the same share) wears its colour on those texels here
  if (u_imp_alt.w > 0.0 && fract(v_rot.z * 91.7 + 0.31) < u_imp_alt.w) alb = mix(alb, u_imp_alt.rgb, altT);
#ifdef SCATTER
  float shadow = sunShadow(wpos, n, viewDepth);
#else
  float shadow = sunShadowCheap(v_wpos, vec3(0.0, 1.0, 0.0), viewDepth);
#endif
  vec3 col = shade(wpos, n, alb, 0.85, 0.0, ao, shadow, viewDepth);
#ifdef SCATTER
  if (u_imp_fol.x > 0.5 && u_leaf_tr.x < 0.5) {
    // the crown's leaves through Unreal's Two Sided Foliage, as the near mesh (model.frag FOLIAGE) and the old card (impostor.frag)
    vec3 vI = normalize(u_cam_pos - wpos);
    vec3 ssCol = alb * ((u_leaf_tr.y > 0.0) ? u_leaf_tr.y : 1.0);
    float wrapNoL = clamp((-dot(n, u_sun_dir) + 0.5) / (1.5 * 1.5), 0.0, 1.0);
    float scatter = D_GGX(clamp(-dot(vI, u_sun_dir), 0.0, 1.0), 0.6);
    col += u_sun_color * (wrapNoL * scatter) * ssCol * shadow * cloudShadow(wpos) * sunZone(wpos);
    col += skyIrradiance(-n) * ssCol * ueAOMultiBounce(alb, ao);
  }
#endif
  col = applyFog(col, wpos, dist);
  o_color = vec4(sane(col), clamp(cov, 0.0, 1.0));
#endif
}
