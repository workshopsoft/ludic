// a skinned glTF model (skin.ludic / actor.ludic): four joint influences per vertex, or eight (JOINTS_1 / WEIGHTS_1)
// blended on the GPU, then one model matrix. Writes the same varyings as model.vert so
// model.frag (lit) and shadow.frag (casters) shade it unchanged.
layout(location = 0) in vec3 a_pos;
layout(location = 1) in vec3 a_nrm;
layout(location = 2) in vec2 a_uv;
layout(location = 5) in vec4 a_joints;      // integer indices, read as floats
layout(location = 6) in vec4 a_weights;
layout(location = 7) in vec4 a_col;
layout(location = 10) in vec4 a_joints1;     // the second four influences; unfed (zero weights) on a mesh with four
layout(location = 11) in vec4 a_weights1;         // COLOR_0 as RGBA8 (gltf_colour); a mesh without it leaves it unfed (zero)
uniform mat4 u_model;
uniform mat4 u_bones[160];                  // skin.ludic SKIN_MAX_JOINTS
uniform float u_skinned;                    // 0: a rigid model on the same path
uniform mat4 u_view;
uniform mat4 u_proj;
uniform mat4 u_light_vp;
#ifdef OUTLINE
uniform float u_outline;                    // metres the shell is pushed out
#endif
#ifdef VELOCITY
// the motion pass (taa.ludic): last frame's placement and pose of the same vertex, through clean view-projections
uniform mat4 u_prev_model;
uniform mat4 u_prev_bones[160];
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
  mat4 m = u_model;
  if (u_skinned > 0.5) {
    mat4 sk = a_weights.x * u_bones[int(a_joints.x + 0.5)]
            + a_weights.y * u_bones[int(a_joints.y + 0.5)]
            + a_weights.z * u_bones[int(a_joints.z + 0.5)]
            + a_weights.w * u_bones[int(a_joints.w + 0.5)]
            + a_weights1.x * u_bones[int(a_joints1.x + 0.5)]
            + a_weights1.y * u_bones[int(a_joints1.y + 0.5)]
            + a_weights1.z * u_bones[int(a_joints1.z + 0.5)]
            + a_weights1.w * u_bones[int(a_joints1.w + 0.5)];
    m = u_model * sk;
  }
  vec4 w = m * vec4(a_pos, 1.0);
#ifdef VELOCITY
  mat4 pm = u_prev_model;
  if (u_skinned > 0.5) {
    mat4 psk = a_weights.x * u_prev_bones[int(a_joints.x + 0.5)]
             + a_weights.y * u_prev_bones[int(a_joints.y + 0.5)]
             + a_weights.z * u_prev_bones[int(a_joints.z + 0.5)]
             + a_weights.w * u_prev_bones[int(a_joints.w + 0.5)]
             + a_weights1.x * u_prev_bones[int(a_joints1.x + 0.5)]
             + a_weights1.y * u_prev_bones[int(a_joints1.y + 0.5)]
             + a_weights1.z * u_prev_bones[int(a_joints1.z + 0.5)]
             + a_weights1.w * u_prev_bones[int(a_joints1.w + 0.5)];
    pm = u_prev_model * psk;
  }
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
#ifdef SHADOW_PASS
  gl_Position = u_light_vp * w;
#else
  gl_Position = u_proj * u_view * w;
#endif
}
