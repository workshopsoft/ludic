// hlod.frag - the proxy box, lit: the bake's colour, a faint floor banding on walls for a sense of scale, the sun's
// shadow from the cheap tap (a proxy is far away), fog
in vec3 v_wpos;
in vec3 v_nrm;
in vec4 v_col;
out vec4 o_color;
uniform mat4 u_view;
void main() {
  if (v_wpos.y < u_clip_y) discard;
#ifndef SHADOW_PASS
  if (fogCut(v_wpos)) discard;   // the fog wall's dissolve (lighting.glsl)
#endif
  vec3 N = normalize(v_nrm);
  float dist = length(v_wpos - u_cam_pos);
  float viewDepth = -(u_view * vec4(v_wpos, 1.0)).z;
  vec3 alb = v_col.rgb;
  if (N.y < 0.5) {
    float floors = step(0.12, fract(v_wpos.y / 3.4));
    alb *= mix(0.86, 1.0, floors);
  }
  float shadow = sunShadowCheap(v_wpos, N, viewDepth);
  vec3 col = shade(v_wpos, N, alb, 0.9, 0.0, 1.0, shadow, viewDepth);
  col = applyFog(col, v_wpos, dist);
  o_color = vec4(sane(col), 1.0);
}
