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
// The moon: a disc a little over half a degree across, shaded by a terminator taken from
// its phase, with a few soft maria on it and a halo that opens up when the air is damp.
// It is the light the night already had (daylight.ludic repoints the sun after dusk) —
// this is that light finally having something you can look at.
uniform vec3 u_moon_dir;
uniform float u_moon_haze;       // the weather's overcast: dims the disc, widens the halo
uniform float u_moon_phase;      // 0 new .. 0.5 full .. 1 new
uniform float u_moon_illum;
vec3 moonColour(vec3 dir, float night) {
  if (night <= 0.001 || u_moon_dir.y < -0.08) return vec3(0.0);
  float ang = acos(clamp(dot(dir, u_moon_dir), -1.0, 1.0));
  const float R = 0.0096;                       // about 0.55 degrees
  // the halo first: wide, weak, and thicker through damp air
  float halo = exp(-ang / (R * 6.0)) * (0.02 + 0.35 * u_moon_haze) * u_moon_illum;
  vec3 col = vec3(0.55, 0.60, 0.75) * halo;
  if (ang < R) {
    // where on the disc: a unit offset from its centre, built in the sky's own frame
    vec3 up = abs(u_moon_dir.y) > 0.95 ? vec3(1.0, 0.0, 0.0) : vec3(0.0, 1.0, 0.0);
    vec3 rx = normalize(cross(up, u_moon_dir));
    vec3 ry = cross(u_moon_dir, rx);
    vec2 p = vec2(dot(dir, rx), dot(dir, ry)) / R;
    float r2 = clamp(dot(p, p), 0.0, 1.0);
    // the sphere's normal, and the direction its light comes from, turned by the phase
    vec3 n = vec3(p, sqrt(max(1.0 - r2, 0.0)));
    float a2 = u_moon_phase * 6.28318530718;
    vec3 lit = normalize(vec3(sin(a2), 0.0, -cos(a2)));
    float lam = smoothstep(-0.06, 0.10, dot(n, lit));
    // maria: two or three soft dark blotches, so it is not a flat white circle
    float m = 0.0;
    m += smoothstep(0.34, 0.0, length(p - vec2(-0.28, 0.22)));
    m += 0.7 * smoothstep(0.26, 0.0, length(p - vec2(0.24, -0.10)));
    m += 0.5 * smoothstep(0.20, 0.0, length(p - vec2(0.02, 0.44)));
    float edge = smoothstep(1.0, 0.86, sqrt(r2));
    vec3 disc = mix(vec3(1.0, 0.98, 0.93), vec3(0.62, 0.63, 0.68), clamp(m, 0.0, 1.0));
    // The lit face has to be bright enough to read as the moon and no brighter: the night
    // runs at an exposure of about five, so anything much over one saturates the whole
    // disc to a flat white circle and the terminator disappears. The dark limb keeps a
    // trace of earthshine, which is what makes a crescent look like a sphere.
    col += disc * (lam + 0.010 * (1.0 - lam)) * edge * 0.55;
  }
  return col * night * (1.0 - 0.9 * u_moon_haze);
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
    col += moonColour(dir, night);
  }
  // below the horizon the HDRI ground is replaced by the fog colour
  float below = smoothstep(0.0, -0.08, dir.y);
  vec3 fogCol = skyPrefiltered(vec3(dir.x, 0.02, dir.z), 0.6);
  col = mix(col, fogCol, below);
  o_color = vec4(sane(col), 1.0);
}
