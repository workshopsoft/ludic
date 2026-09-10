in vec2 v_uv;
out vec4 o_color;
uniform sampler2D u_sky;
uniform mat4 u_inv_vp;
uniform float u_sky_gain;
uniform float u_sky_sat;
// a star: one hash per cell of the direction, a few of them bright, a slow twinkle
float starField(vec3 dir, float t) {
  vec3 p = dir * 230.0;
  vec3 c = floor(p);
  vec3 f = p - c - 0.5;
  float h = fract(sin(dot(c, vec3(12.9898, 78.233, 37.719))) * 43758.5453);
  float h2 = fract(h * 91.7);
  float bright = smoothstep(0.972, 1.0, h);
  float disc = smoothstep(0.42, 0.0, length(f));
  float twinkle = 0.7 + 0.3 * sin(t * (1.5 + 3.0 * h2) + h2 * 40.0);
  return bright * disc * twinkle * (0.5 + h2);
}
void main() {
  vec4 a = u_inv_vp * vec4(v_uv * 2.0 - 1.0, 1.0, 1.0);
  vec3 dir = normalize(a.xyz / a.w - u_cam_pos);
  // level 0: the equirect seam (atan wraps) would otherwise pick the smallest mip along one column
  vec3 col = min(textureLod(u_sky, skyUV(dir), 0.0).rgb, vec3(4096.0)) * u_sky_gain;
  float l = dot(col, vec3(0.2126, 0.7152, 0.0722));
  col = max(mix(vec3(l), col, u_sky_sat), vec3(0.0));
  // the photograph's sky dims with the day (daylight.ludic); the night adds its own
  col *= u_ibl_scale;
  float night = 1.0 - smoothstep(0.0, 0.45, u_daylight);
  if (night > 0.0) {
    vec3 nightCol = mix(vec3(0.012, 0.016, 0.034), vec3(0.003, 0.004, 0.010), clamp(dir.y, 0.0, 1.0));
    float stars = starField(dir, u_time) * smoothstep(-0.02, 0.15, dir.y);
    nightCol += stars * vec3(0.55, 0.6, 0.7) * night;
    col += nightCol * night;
  }
  // below the horizon the HDRI ground is replaced by the fog colour
  float below = smoothstep(0.0, -0.08, dir.y);
  vec3 fogCol = skyPrefiltered(vec3(dir.x, 0.02, dir.z), 0.6);
  col = mix(col, fogCol, below);
  o_color = vec4(sane(col), 1.0);
}
