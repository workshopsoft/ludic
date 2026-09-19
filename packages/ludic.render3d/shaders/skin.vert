// a skinned glTF model (skin.ludic / actor.ludic): four joint influences per vertex
// blended on the GPU, then one model matrix. Writes the same varyings as model.vert so
// model.frag (lit) and shadow.frag (casters) shade it unchanged.
layout(location = 0) in vec3 a_pos;
layout(location = 1) in vec3 a_nrm;
layout(location = 2) in vec2 a_uv;
layout(location = 5) in vec4 a_joints;      // integer indices, read as floats
layout(location = 6) in vec4 a_weights;
uniform mat4 u_model;
uniform mat4 u_bones[48];
uniform float u_skinned;                    // 0: a rigid model on the same path
uniform mat4 u_view;
uniform mat4 u_proj;
uniform mat4 u_light_vp;
#ifdef OUTLINE
uniform float u_outline;                    // metres the shell is pushed out
#endif
out vec3 v_wpos;
out vec3 v_nrm;
out vec2 v_uv;
out float v_seed;
out vec2 v_rot;
out float v_hull;
out float v_quake;   // only aspens quake; written so model.frag can read it
void main() {
  mat4 m = u_model;
  if (u_skinned > 0.5) {
    mat4 sk = a_weights.x * u_bones[int(a_joints.x + 0.5)]
            + a_weights.y * u_bones[int(a_joints.y + 0.5)]
            + a_weights.z * u_bones[int(a_joints.z + 0.5)]
            + a_weights.w * u_bones[int(a_joints.w + 0.5)];
    m = u_model * sk;
  }
  vec4 w = m * vec4(a_pos, 1.0);
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
#ifdef SHADOW_PASS
  gl_Position = u_light_vp * w;
#else
  gl_Position = u_proj * u_view * w;
#endif
}
