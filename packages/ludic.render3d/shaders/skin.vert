// a skinned glTF model (skin.ludic / actor.ludic): four joint influences per vertex, or eight (JOINTS_1 / WEIGHTS_1)
// blended on the GPU, then one model matrix. Writes the same varyings as model.vert so
// model.frag (lit) and shadow.frag (casters) shade it unchanged.
// SKIN4: a mesh with no second set (skin.ludic skin_attribs: JOINTS_1 / WEIGHTS_1 absent or all zero) blends four, as Unreal's GPU
// skin vertex factory is compiled for its section's influence count (GPUSkinPublicDefs.h: MAX_INFLUENCES_PER_STREAM 4, the
// second stream only for a mesh whose LOD uses more; a MetaHuman's LOD 3 on is four)
layout(location = 0) in vec3 a_pos;
layout(location = 1) in vec3 a_nrm;
layout(location = 2) in vec2 a_uv;
layout(location = 5) in vec4 a_joints;      // integer indices, read as floats
layout(location = 6) in vec4 a_weights;
layout(location = 7) in vec4 a_col;
#ifndef SKIN4
layout(location = 10) in vec4 a_joints1;     // the second four influences; unfed (zero weights) on a mesh with four
layout(location = 11) in vec4 a_weights1;
#endif
uniform mat4 u_model;
#ifdef ACTOR_INST
// an instanced draw of one model's actors (actor_inst.ludic): each instance's model matrix as three rows, then its tint and glow
layout(location = 3) in vec4 i_m0;
layout(location = 4) in vec4 i_m1;
layout(location = 8) in vec4 i_m2;
layout(location = 9) in vec4 i_te;
// x: the first row of the instance's palette in u_ai_bones (actor_inst.ludic ai_palette), three rows a joint: Unreal's instanced
// skinned mesh reads each instance's own bone data the same way (Components/InstancedSkinnedMeshComponent.h)
layout(location = 12) in vec4 i_bo;
readonly buffer u_ai_bones { vec4 ai_bones[]; };
out vec4 v_te;
// one influence: weight w of joint j's three rows (from palette row `base` of BUF), added in
#define AI_BONE(BUF, base, j, w) { int o_ = (base) + int((j) + 0.5) * 3; r0 += (w) * BUF[o_]; r1 += (w) * BUF[o_ + 1]; r2 += (w) * BUF[o_ + 2]; }
#ifdef SKIN4
#define AI_PALETTE(BUF, base) AI_BONE(BUF, base, a_joints.x, a_weights.x) AI_BONE(BUF, base, a_joints.y, a_weights.y) \
  AI_BONE(BUF, base, a_joints.z, a_weights.z) AI_BONE(BUF, base, a_joints.w, a_weights.w)
#else
#define AI_PALETTE(BUF, base) AI_BONE(BUF, base, a_joints.x, a_weights.x) AI_BONE(BUF, base, a_joints.y, a_weights.y) \
  AI_BONE(BUF, base, a_joints.z, a_weights.z) AI_BONE(BUF, base, a_joints.w, a_weights.w) \
  AI_BONE(BUF, base, a_joints1.x, a_weights1.x) AI_BONE(BUF, base, a_joints1.y, a_weights1.y) \
  AI_BONE(BUF, base, a_joints1.z, a_weights1.z) AI_BONE(BUF, base, a_joints1.w, a_weights1.w)
#endif
// the instance's skin: its palette's influences blended, as one matrix
mat4 aiSkin(int base) {
  vec4 r0 = vec4(0.0), r1 = vec4(0.0), r2 = vec4(0.0);
  AI_PALETTE(ai_bones, base)
  return transpose(mat4(r0, r1, r2, vec4(0.0, 0.0, 0.0, 1.0)));
}
#ifdef VELOCITY
// the motion pass's instances (actor_inst.ludic ai_build, the motion slot): last frame's model matrix as three rows, and (i_bo.y) the
// first row of last frame's palette in last frame's bone buffer, kept whole for this frame to read (ai_palette's two buffers). Unreal's
// per-instance PrevTransform (MassRepresentationTypes.h, FMassInstancedStaticMeshInfo::AddBatchedTransform's PrevTransform) and the
// skin's PreviousReferenceToLocal (GPUSkinVertexFactory.cpp: PreviousBoneMatrices beside BoneMatrices)
layout(location = 13) in vec4 i_p0;
layout(location = 14) in vec4 i_p1;
layout(location = 15) in vec4 i_p2;
readonly buffer u_ai_pbones { vec4 ai_pbones[]; };
mat4 aiPrevSkin(int base) {
  vec4 r0 = vec4(0.0), r1 = vec4(0.0), r2 = vec4(0.0);
  AI_PALETTE(ai_pbones, base)
  return transpose(mat4(r0, r1, r2, vec4(0.0, 0.0, 0.0, 1.0)));
}
#endif
#else
uniform mat4 u_bones[160];                  // skin.ludic SKIN_MAX_JOINTS
#endif
uniform float u_skinned;                    // 0: a rigid model on the same path
uniform mat4 u_view;
uniform mat4 u_proj;
uniform mat4 u_light_vp;
#ifdef OUTLINE
uniform float u_outline;                    // metres the shell is pushed out
#endif
#ifdef STRANDS
// a groom's strands (strands.ludic): each point twice, NORMAL its tangent (root to tip) times its radius (m), TEXCOORD_0 (u root to
// tip, side -1 / +1), COLOR_0 the skin's normal at its root (RGB) and the strand's seed (A)
uniform float u_strand_minr;                // the least radius a strand is drawn at, at a metre's distance (strands.ludic)
layout(location = 9) in vec4 a_sky;         // _HAIRSKY: the hairs between the point and the sky, count(w) = x + yzw.w (the bind frame)
out vec4 v_sky;
out float v_srad;
out float v_sdep;
out vec3 v_snrm;
#ifdef INST
// a head of hair (model_set_strand_points): Unreal's packed control points, a segment an instance, read at four offsets of one buffer: the
// previous point, A, B and the next. Each point: three halves (its position from u_strand_c) and u 8 | radius 6 | type 2 bits, read as
// four 16-bit integers; the sky's four halves; the root's normal (octahedral) and the strand's seed, 8 bits each
layout(location = 8) in vec4 i_p;
layout(location = 3) in vec4 i_a;
layout(location = 13) in vec4 i_as;
layout(location = 15) in vec4 i_an;
layout(location = 4) in vec4 i_b;
layout(location = 14) in vec4 i_bs;
layout(location = 12) in vec4 i_n;
#ifdef VIS
out vec2 v_sid;                              // the segment (strands.frag VIS): gl_InstanceIndex, its low and high 12 bits (exact through any interpolation)
#endif
uniform vec3 u_strand_c;
uniform float u_strand_rmax;
vec3 stPos(vec4 v) { uvec4 q = uvec4(v + 0.5); return vec3(unpackHalf2x16(q.x).x, unpackHalf2x16(q.y).x, unpackHalf2x16(q.z).x) + u_strand_c; }
uint stType(vec4 v) { return uint(v.w + 0.5) >> 14u; }
float stU(vec4 v) { return float(uint(v.w + 0.5) & 255u) / 255.0; }
float stR(vec4 v) { return float((uint(v.w + 0.5) >> 8u) & 63u) / 63.0 * u_strand_rmax; }
vec4 stSky(vec4 v) { uvec4 q = uvec4(v + 0.5); return vec4(unpackHalf2x16(q.x).x, unpackHalf2x16(q.y).x, unpackHalf2x16(q.z).x, unpackHalf2x16(q.w).x); }
// UnitVectorToOctahedron's inverse (Unreal's OctahedronToUnitVector)
vec3 stOct(vec2 e) {
  e = e * 2.0 - 1.0;
  vec3 n = vec3(e, 1.0 - abs(e.x) - abs(e.y));
  float t = max(-n.z, 0.0);
  n.xy += vec2(n.x >= 0.0 ? -t : t, n.y >= 0.0 ? -t : t);
  return normalize(n);
}
#endif
#endif
#ifndef ACTOR_INST
// a palette's influences blended (u_bones or u_prev_bones), four or eight
#define SKIN_SUM4(B) (a_weights.x * B[int(a_joints.x + 0.5)] + a_weights.y * B[int(a_joints.y + 0.5)] \
  + a_weights.z * B[int(a_joints.z + 0.5)] + a_weights.w * B[int(a_joints.w + 0.5)])
#ifdef SKIN4
#define SKIN_MAT(B) SKIN_SUM4(B)
#else
#define SKIN_MAT(B) (SKIN_SUM4(B) + a_weights1.x * B[int(a_joints1.x + 0.5)] + a_weights1.y * B[int(a_joints1.y + 0.5)] \
  + a_weights1.z * B[int(a_joints1.z + 0.5)] + a_weights1.w * B[int(a_joints1.w + 0.5)])
#endif
#endif
#ifdef VELOCITY
// the motion pass (taa.ludic): last frame's placement and pose of the same vertex, through clean view-projections
#ifndef ACTOR_INST
uniform mat4 u_prev_model;
uniform mat4 u_prev_bones[160];
#endif
uniform mat4 u_vp_cur;
uniform mat4 u_vp_prev;
out vec4 v_cur_clip;
out vec4 v_prev_clip;
#endif
out vec3 v_wpos;
out vec3 v_nrm;
out vec2 v_uv;
out float v_seed;
out vec2 v_rot;
out float v_hull;
out float v_quake;   // only aspens quake; written so model.frag can read it
out vec4 v_col;          // COLOR_0, or white when the mesh has none (model.frag multiplies it in)
out float v_near;         // model.frag declares it; 1 = no near fade
out float v_lh;           // model.frag declares it; 1 = no low-plant occlusion
void main() {
#ifdef ACTOR_INST
  mat4 m = transpose(mat4(i_m0, i_m1, i_m2, vec4(0.0, 0.0, 0.0, 1.0)));
  v_te = i_te;
#else
  mat4 m = u_model;
#endif
  if (u_skinned > 0.5) {
#ifdef ACTOR_INST
    // the instance's own palette (actor_inst.ludic): the influences' rows blended, then its model matrix
    m = m * aiSkin(int(i_bo.x + 0.5));
#else
    m = u_model * SKIN_MAT(u_bones);
#endif
  }
  vec4 w = m * vec4(a_pos, 1.0);
#ifdef VELOCITY
#ifdef ACTOR_INST
  mat4 pm = transpose(mat4(i_p0, i_p1, i_p2, vec4(0.0, 0.0, 0.0, 1.0)));
  if (u_skinned > 0.5) pm = pm * aiPrevSkin(int(i_bo.y + 0.5));
#else
  mat4 pm = u_prev_model;
  if (u_skinned > 0.5) pm = u_prev_model * SKIN_MAT(u_prev_bones);
#endif
  v_cur_clip = u_vp_cur * w;
  v_prev_clip = u_vp_prev * (pm * vec4(a_pos, 1.0));
#endif
#ifdef OUTLINE
  // an inverted hull: the shell is pushed out along the world normal and drawn with the
  // front faces culled, so what survives is a rim of `u_outline` metres around the model
  w.xyz += normalize(mat3(m) * a_nrm) * u_outline;
#endif
  v_wpos = w.xyz;
  v_nrm = normalize(mat3(m) * a_nrm);
  v_uv = a_uv;
  // model.frag scales the albedo by 0.85 + 0.3 * fract(seed * 7.13); this seed makes that 1
  v_seed = 0.0701;
  v_rot = vec2(0.0, 1.0);
  v_hull = 1.0;
  v_quake = 0.0;
  v_col = (a_col == vec4(0.0)) ? vec4(1.0) : a_col;   // as model.vert: an unfed input reads zero
  v_near = 1.0;
  v_lh = 1.0;
#ifdef STRANDS
  // Unreal's view-facing ribbon (HairStrandsVertexFactory): the point moved across the strand, at right angles to it and to the camera's
  // forward axis, by its radius or the least one at its distance, whichever is more
#ifdef INST
  // HAIR_CONTROLPOINT_INSIDE 0, START 1, END 2: a segment from a strand's tip is none; the tangent at a point the mean of its two
  // segments' directions, one at a root or a tip
  uint tA = stType(i_a), tB = stType(i_b);
  bool cut = tA == 2u;
  bool atB = a_uv.x > 0.5 && !cut;
  vec3 pA = stPos(i_a), pB = stPos(i_b);
  vec3 dAB = pB - pA;
  dAB /= max(length(dAB), 1e-12);
  vec3 TA = dAB, TB = dAB;
  if (tA != 1u) { vec3 d = pA - stPos(i_p); TA += d / max(length(d), 1e-12); }
  if (tB != 2u) { vec3 d = stPos(i_n) - pB; TB += d / max(length(d), 1e-12); }
  vec3 sP = atB ? pB : pA;
  vec3 sT = atB ? TB : TA;
  float sR = atB ? stR(i_b) : stR(i_a);
  w = m * vec4(sP, 1.0);
  vec3 tw = mat3(m) * (normalize(sT) * sR);
  float sSide = cut ? 0.0 : a_uv.y;
  float sU = atB ? stU(i_b) : stU(i_a);
  vec3 sN = stOct(i_an.xy);
  float sSeed = i_an.z;
  vec4 sSky = atB ? stSky(i_bs) : stSky(i_as);
#ifdef VIS
  v_sid = vec2(float(gl_InstanceIndex & 4095), float(gl_InstanceIndex >> 12));
#endif
#else
  vec3 tw = mat3(m) * a_nrm;
  float sSide = a_uv.y;
  float sU = a_uv.x;
  vec3 sN = a_col.rgb * 2.0 - 1.0;
  float sSeed = a_col.a;
  vec4 sSky = a_sky;
#endif
  float r = length(tw);
  vec3 T = tw / max(r, 1e-12);
  vec3 camF = -vec3(u_view[0][2], u_view[1][2], u_view[2][2]);
  vec3 camP = -transpose(mat3(u_view)) * u_view[3].xyz;
  vec3 right = cross(T, -camF);
  right = dot(right, right) > 1e-12 ? normalize(right) : normalize(cross(T, vec3(0.0, 1.0, 0.0)) + vec3(1e-6, 0.0, 0.0));
  w.xyz += right * sSide * max(r, u_strand_minr * length(camP - w.xyz));
  v_wpos = w.xyz;
  v_nrm = T;
  v_uv = vec2(sU, sSide);
  v_col = vec4(v_col.rgb, sSeed);
  v_srad = r;
  v_sdep = -(u_view * w).z;
  v_snrm = normalize(mat3(m) * sN);
  v_sky = vec4(sSky.x, mat3(m) * sSky.yzw);
#endif
#ifdef SHADOW_PASS
  gl_Position = u_light_vp * w;
#else
  gl_Position = u_proj * u_view * w;
#endif
}
