// screen-space ambient occlusion from the resolved depth (half resolution)
in vec2 v_uv;
out vec4 o_color;
uniform sampler2D u_depth;
uniform mat4 u_inv_proj;
uniform mat4 u_proj;
uniform vec2 u_texel;
uniform float u_radius;       // world metres
uniform float u_intensity;
vec3 viewPos(vec2 uv) {
  float d = texture(u_depth, uv).r;
  vec4 p = u_inv_proj * vec4(uv * 2.0 - 1.0, d * 2.0 - 1.0, 1.0);
  return p.xyz / p.w;
}
void main() {
  vec3 P = viewPos(v_uv);
  if (-P.z > 900.0) { o_color = vec4(1.0); return; }
  // normal from the depth's neighbourhood (take the smaller difference on each axis)
  vec3 Pr = viewPos(v_uv + vec2(u_texel.x, 0.0)), Pl = viewPos(v_uv - vec2(u_texel.x, 0.0));
  vec3 Pu = viewPos(v_uv + vec2(0.0, u_texel.y)), Pd = viewPos(v_uv - vec2(0.0, u_texel.y));
  vec3 dx = (abs(Pr.z - P.z) < abs(P.z - Pl.z)) ? Pr - P : P - Pl;
  vec3 dy = (abs(Pu.z - P.z) < abs(P.z - Pd.z)) ? Pu - P : P - Pd;
  vec3 N = normalize(cross(dx, dy));
  float noise = ign(gl_FragCoord.xy);
  float ao = 0.0;
  const int S = 12;
  float radius = u_radius * (1.0 + 0.01 * -P.z);
  for (int i = 0; i < S; i++) {
    float a = (float(i) + noise) * 2.3999632;            // golden angle spiral
    float r = sqrt((float(i) + 0.5 + noise) / float(S));
    vec3 dir = vec3(cos(a) * r, sin(a) * r, sqrt(max(0.0, 1.0 - r * r)));
    // hemisphere around N
    vec3 up = abs(N.z) < 0.999 ? vec3(0, 0, 1) : vec3(1, 0, 0);
    vec3 t = normalize(cross(up, N)), b = cross(N, t);
    vec3 s = P + (t * dir.x + b * dir.y + N * dir.z) * radius * (0.2 + 0.8 * r);
    vec4 c = u_proj * vec4(s, 1.0);
    vec2 suv = c.xy / c.w * 0.5 + 0.5;
    if (suv.x < 0.0 || suv.x > 1.0 || suv.y < 0.0 || suv.y > 1.0) continue;
    float sz = viewPos(suv).z;
    float rangeCheck = smoothstep(0.0, 1.0, radius / max(abs(P.z - sz), 1e-3));
    ao += (sz >= s.z + 0.02 * radius ? 1.0 : 0.0) * rangeCheck;
  }
  ao = 1.0 - u_intensity * ao / float(S);
  // contact occlusion is a near-field effect: fade it out with distance
  ao = mix(clamp(ao, 0.0, 1.0), 1.0, smoothstep(120.0, 350.0, -P.z));
  o_color = vec4(ao, -P.z, 0.0, 1.0);
}
