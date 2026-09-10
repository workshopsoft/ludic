// screen-space ambient occlusion + one indirect diffuse bounce (SSGI) from the previous
// frame's lit colour; half resolution, denoised over time by the TAA history it feeds
in vec2 v_uv;
out vec4 o_color;
uniform sampler2D u_depth;
uniform sampler2D u_prev_color;      // last frame's anti-aliased HDR colour
uniform mat4 u_inv_proj;
uniform mat4 u_proj;
uniform vec2 u_texel;
uniform float u_radius;
uniform float u_intensity;
uniform float u_frame;
vec3 viewPos(vec2 uv) {
  float d = texture(u_depth, uv).r;
  vec4 p = u_inv_proj * vec4(uv * 2.0 - 1.0, d * 2.0 - 1.0, 1.0);
  return p.xyz / p.w;
}
void main() {
  vec3 P = viewPos(v_uv);
  if (-P.z > 900.0) { o_color = vec4(0.0, 0.0, 0.0, 1.0); return; }
  vec3 Pr = viewPos(v_uv + vec2(u_texel.x, 0.0)), Pl = viewPos(v_uv - vec2(u_texel.x, 0.0));
  vec3 Pu = viewPos(v_uv + vec2(0.0, u_texel.y)), Pd = viewPos(v_uv - vec2(0.0, u_texel.y));
  vec3 dx = (abs(Pr.z - P.z) < abs(P.z - Pl.z)) ? Pr - P : P - Pl;
  vec3 dy = (abs(Pu.z - P.z) < abs(P.z - Pd.z)) ? Pu - P : P - Pd;
  vec3 N = normalize(cross(dx, dy));
  // A fixed per-pixel dither, not a per-frame one. Advancing the sequence every frame
  // spreads the sampling error over time, which is only an improvement if something
  // then averages the frames; with no temporal anti-aliasing left it is just noise that
  // changes every frame, and it was the largest single source of the flicker on movement.
  float noise = ign(gl_FragCoord.xy);
  float ao = 0.0;
  vec3 gi = vec3(0.0);
  float giW = 0.0;
  const int S = 8;
  float radius = u_radius * (1.0 + 0.01 * -P.z);
  vec3 up = abs(N.z) < 0.999 ? vec3(0, 0, 1) : vec3(1, 0, 0);
  vec3 t = normalize(cross(up, N)), b = cross(N, t);
  for (int i = 0; i < S; i++) {
    float a = (float(i) + noise) * 2.3999632;
    float r = sqrt((float(i) + 0.5 + noise) / float(S));
    vec3 dir = vec3(cos(a) * r, sin(a) * r, sqrt(max(0.0, 1.0 - r * r)));
    vec3 wdir = t * dir.x + b * dir.y + N * dir.z;
    vec3 s = P + wdir * radius * (0.2 + 0.8 * r);
    vec4 c = u_proj * vec4(s, 1.0);
    vec2 suv = c.xy / c.w * 0.5 + 0.5;
    if (suv.x < 0.0 || suv.x > 1.0 || suv.y < 0.0 || suv.y > 1.0) continue;
    vec3 sp = viewPos(suv);
    float rangeCheck = smoothstep(0.0, 1.0, radius / max(abs(P.z - sp.z), 1e-3));
    bool occluded = sp.z >= s.z + 0.02 * radius;
    ao += (occluded ? 1.0 : 0.0) * rangeCheck;
    // the occluder's lit colour bounces back toward P (weighted by how squarely it faces P)
    if (occluded) {
      vec3 toS = sp - P;
      float d2 = max(dot(toS, toS), 1e-3);
      float cosP = max(dot(N, toS) * inversesqrt(d2), 0.0);
      vec3 col = sane(texture(u_prev_color, suv).rgb);
      gi += col * cosP * rangeCheck;
      giW += 1.0;
    }
  }
  ao = 1.0 - u_intensity * ao / float(S);
  float fade = smoothstep(120.0, 350.0, -P.z);
  ao = mix(clamp(ao, 0.0, 1.0), 1.0, fade);
  gi = (giW > 0.0 ? gi / float(S) : vec3(0.0)) * (1.0 - fade);
  o_color = vec4(gi, ao);
}
