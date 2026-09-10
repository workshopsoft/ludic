// impostor bake: albedo + coverage, and the model-frame normal
in vec3 v_wpos;
in vec3 v_nrm;
in vec2 v_uv;
in float v_seed;
layout(location = 0) out vec4 o_albedo;
layout(location = 1) out vec4 o_normal;
uniform sampler2D u_diff;
uniform sampler2D u_arm;
void main() {
  vec4 d = texture(u_diff, v_uv);
  if (d.a < 0.5) discard;          // cut-out cards (needles, blades, leaves) bake with their shape
  vec3 N = normalize(v_nrm);
  if (!gl_FrontFacing) N = -N;
#ifdef FLOWER
  float vy = clamp(v_uv.y, 0.0, 1.0);
  if (v_uv.x >= 2.0) d.rgb = vec3(0.035, 0.09, 0.02) * (0.7 + 0.6 * vy);
  else if (v_uv.x >= 1.0) {
    float f = fract(v_uv.x);
    vec3 violet = vec3(0.06, 0.03, 0.3);
    vec3 lip = vec3(0.4, 0.3, 0.68);
    // each floret: a dark keel at the base, a pale standard at the top edge
    d.rgb = mix(violet, lip, smoothstep(0.35, 1.0, vy) * 0.6 + 0.25 * smoothstep(0.3, 0.0, abs(f - 0.5)));
    d.rgb *= 0.85 + 0.15 * vy;
  } else d.rgb = vec3(0.08, 0.17, 0.03);
#endif
  o_albedo = vec4(d.rgb, 1.0);
  o_normal = vec4(N * 0.5 + 0.5, texture(u_arm, v_uv).r);
}
