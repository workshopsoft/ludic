// impostor bake: albedo + coverage, and the model-frame normal
in vec3 v_wpos;
in vec3 v_nrm;
in vec2 v_uv;
in float v_seed;
layout(location = 0) out vec4 o_albedo;
layout(location = 1) out vec4 o_normal;
uniform sampler2D u_diff;
uniform vec4 u_fac_base_inv;   // a glTF material's base colour factor, as 1 - factor
uniform sampler2D u_arm;
void main() {
  vec4 d = texture(u_diff, v_uv) * (vec4(1.0) - u_fac_base_inv);
  // a surface's maps are laid by place, not by these uvs (surface.ludic): a card takes its mean colour (or the material's, toned)
  if (u_surf.x > 0.0) {
    float l = dot(u_surf_c.rgb, vec3(0.2126, 0.7152, 0.0722));
    d.rgb = (u_surf_b.x > 0.5) ? (vec3(1.0) - u_fac_base_inv.rgb) : mix(vec3(l), u_surf_c.rgb, u_surf_d.y) * u_surf_d.x;
  }
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
  // the occlusion in the lower half; a material that has an alternative (a render wall some buildings wear as brick) marks its
  // texels with the top (oimp.frag u_imp_alt): its occlusion means nothing (its maps are laid by place, not these uvs)
  bool alt = u_surf.x > 0.0 && u_s2.x > 0.0 && u_s2_e.w < 0.5;   // a flat roof's gravel (u_s2_e.w) is not the card's alternative
  o_normal = vec4(N * 0.5 + 0.5, alt ? 1.0 : texture(u_arm, v_uv).r * 0.49);
}
