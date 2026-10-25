// screen-space ambient occlusion + one indirect diffuse bounce (SSGI) from the previous
// frame's lit colour (the TAA resolve's this frame while it runs, taa.ludic; else last frame's copy)
in vec2 v_uv;
out vec4 o_color;
uniform float u_ao_far;
uniform sampler2D u_depth;
uniform sampler2D u_prev_color;      // last frame's anti-aliased HDR colour
uniform mat4 u_inv_proj;
uniform mat4 u_proj;
uniform vec2 u_texel;
uniform float u_radius;
uniform float u_intensity;
uniform float u_contact;    // the tight contact pass; 0 switches it off entirely
uniform float u_frame;
// A sample must be behind the surface by more than this much of its sideways distance from the pixel (the tangent of the
// angle, 0.4 about 22 degrees) before it counts as occluded. The pixel's normal is its triangle's, so a ground of 1 m
// triangles, curved by a few degrees from one to the next, has the neighbouring triangle rise over a sample taken across
// the edge and darkens the near side of every triangle: a pattern of the mesh, in a smooth ground. A real crease (a wall
// on a floor, a step) is far steeper and is kept.
const float ANGLE_BIAS = 0.4;
vec3 viewPos(vec2 uv) {
  float d = texture(u_depth, uv).r;
  vec4 p = u_inv_proj * vec4(uv * 2.0 - 1.0, depthClip(d), 1.0);
  return p.xyz / p.w;
}
void main() {
  vec3 P = viewPos(v_uv);
  // past 900 m, or where a fog wall has already hidden everything (u_ao_far, post.ludic)
  if (-P.z > (u_ao_far > 0.0 ? u_ao_far : 900.0)) { o_color = vec4(0.0, 0.0, 0.0, 1.0); return; }
  vec3 Pr = viewPos(v_uv + vec2(u_texel.x, 0.0)), Pl = viewPos(v_uv - vec2(u_texel.x, 0.0));
  vec3 Pu = viewPos(v_uv + vec2(0.0, u_texel.y)), Pd = viewPos(v_uv - vec2(0.0, u_texel.y));
  vec3 dx = (abs(Pr.z - P.z) < abs(P.z - Pl.z)) ? Pr - P : P - Pl;
  vec3 dy = (abs(Pu.z - P.z) < abs(P.z - Pd.z)) ? Pu - P : P - Pd;
  vec3 N = normalize(cross(dx, dy));
  // A fixed per-pixel dither, not a per-frame one. Advancing the sequence every frame
  // spreads the sampling error over time, which is only an improvement if something
  // then averages the frames - and this pass runs after the temporal resolve (it is applied in
  // the tonemap), so nothing does: it would be noise that changes every frame.
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
    bool occluded = sp.z >= s.z + 0.02 * radius + ANGLE_BIAS * r * radius * (0.2 + 0.8 * r);
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
  // ---- CONTACT -----------------------------------------------------------------------
  // The occlusion above is tuned as AMBIENT occlusion: a wide radius that answers "how open
  // is the sky here". It is the right question and it leaves every object in the frame
  // hovering, because the thing that says a log is ON the ground rather than in front of it
  // is a hard, narrow darkening in the last few centimetres where the two meet - and at a
  // metre and a half of radius that darkening is spread so thin it is not there.
  //
  // So a second, tight pass. It is cheap because it is SHORT: eight taps inside a quarter of
  // a metre, which at any normal distance is a handful of pixels and stays in cache.
  if (u_contact > 0.0) {
    float cao = 0.0;
    const int CS = 8;
    float crad = 0.40 * (1.0 + 0.004 * -P.z);
    for (int i = 0; i < CS; i++) {
      float a2 = (float(i) + noise) * 2.3999632;
      float r2 = sqrt((float(i) + 0.5 + noise) / float(CS));
      vec3 dir2 = vec3(cos(a2) * r2, sin(a2) * r2, sqrt(max(0.0, 1.0 - r2 * r2)));
      vec3 s2 = P + (t * dir2.x + b * dir2.y + N * dir2.z) * crad;
      vec4 c2 = u_proj * vec4(s2, 1.0);
      vec2 uv2 = c2.xy / c2.w * 0.5 + 0.5;
      if (uv2.x < 0.0 || uv2.x > 1.0 || uv2.y < 0.0 || uv2.y > 1.0) continue;
      float sz2 = viewPos(uv2).z;
      // a tight range check: only something genuinely touching counts, or a wall across the
      // room darkens the floor in front of it
      float rc2 = smoothstep(0.0, 1.0, crad / max(abs(P.z - sz2), 1e-4));
      cao += (sz2 >= s2.z + 0.004 * crad + ANGLE_BIAS * r2 * crad ? 1.0 : 0.0) * rc2;
    }
    cao = 1.0 - u_contact * cao / float(CS);
    ao = min(ao, clamp(cao, 0.0, 1.0));
  }
  float fade = smoothstep(120.0, 350.0, -P.z);
  ao = mix(clamp(ao, 0.0, 1.0), 1.0, fade);
  gi = (giW > 0.0 ? gi / float(S) : vec3(0.0)) * (1.0 - fade);
  o_color = vec4(gi, ao);
}
