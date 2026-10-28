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
uniform float u_gi;         // the bounce (post.ludic: Unreal 5.8 has deprecated SSGI and leaves it off; R3D_UE_SSGI=1 turns it on)
uniform sampler2D u_hzb;    // the furthest depth at half size (ao_hzb.frag), as the view's distance
uniform float u_use_hzb;    // the taps read it, as Unreal's (R3D_UE_AO_HZB=0: the full frame's depth)
uniform vec4 u_pk;          // 1 / proj[0][0], 1 / proj[1][1], proj[2][0], proj[2][1]: a position from a distance
uniform vec2 u_full;        // the frame's size, in pixels
uniform vec3 u_ao_q;        // Unreal's AO shader quality (post.ludic post_ao_quality): x the directions (3 or 6), y the steps, z its quad blur
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
// an occlusion tap: Unreal's WedgeNoNormal reads the furthest HZB (GetHZBDepth, PostProcessAmbientOcclusionCommon.ush) at
// ComputeMipLevel's log2(r.AmbientOcclusionMipLevelFactor 0.5 x step x sample), below 0 for every tap: its mip 0, half the frame
vec3 tapPos(vec2 uv) {
  if (u_use_hzb < 0.5) return viewPos(uv);
  ivec2 hi = textureSize(u_hzb, 0) - 1;
  ivec2 q = clamp(ivec2(uv * u_full) / 2, ivec2(0), hi);
  float d = texelFetch(u_hzb, q, 0).r;
  vec2 ndc = uv * 2.0 - 1.0;
  return vec3(d * (ndc.x + u_pk.z) * u_pk.x, d * (ndc.y + u_pk.w) * u_pk.y, -d);
}
void main() {
  vec3 P = viewPos(v_uv);
  // past 900 m, or where a fog wall has already hidden everything (u_ao_far, post.ludic)
  // (no return before the quad blur below: it takes its neighbours' values by derivatives, which a quad must reach together)
  bool past = -P.z > (u_ao_far > 0.0 ? u_ao_far : 900.0);
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
  // ---- the occlusion: Unreal's screen-space AO as forward shading has it (PostProcessAmbientOcclusion.usf, USE_NORMALS 0): its
  // quality's directions on the disc (OcclusionSamplesOffsets: USE_SAMPLESET 1's three, or 3's six), each a symmetric pair of depth
  // samples at its SAMPLE_STEPS (WedgeNoNormal), the horizon angle between the pair; a pair with a side far behind the pixel is no occlusion (its
  // "fix concave case": a silhouette is not shadowed by what lies past it) and one with a side nearer than AmbientOcclusionDistance
  // (0.8 m) in front counts for less (its "avoid halos around objects"); the radius in the world (RadiusInWS), turned per pixel
  float ao = 1.0;
  if (!past) {
    const vec2 OFS3[3] = vec2[3](vec2(0.0, -0.43), vec2(0.406, 0.5698), vec2(-0.58, 0.814));
    const vec2 OFS6[6] = vec2[6](vec2(0.000, 0.200), vec2(0.325, 0.101), vec2(0.272, -0.396), vec2(-0.385, -0.488), vec2(-0.711, 0.274), vec2(0.060, 0.900));
    int DIRS = int(u_ao_q.x + 0.5);
    int STEPS = int(u_ao_q.y + 0.5);
    const float INV_DIST = 1.0 / 0.8;           // AmbientOcclusionDistance 80 cm
    const float FLAT_BIAS = 0.05;               // FlatSurfaceBias 5 cm
    const float AO_RADIUS = 2.0;                // AmbientOcclusionRadius 200 cm
    float z = -P.z;
    float ang = noise * 6.2831853;
    vec2 rv = vec2(cos(ang), sin(ang)) * AO_RADIUS;
    // the radius on the screen at the pixel's depth (FovFixXY: the projection's scale over the depth), in uv
    vec2 fov = vec2(u_proj[0][0], u_proj[1][1]) * 0.5 / z;
    vec4 base = vec4(rv, -rv.y, rv.x) * vec4(fov, fov);
    vec2 acc = vec2(0.0001);
    for (int i = 0; i < DIRS; i++) {
      vec2 of = DIRS == 6 ? OFS6[i] : OFS3[min(i, 2)];
      vec2 lr = of.x * base.xy + of.y * base.zw;
      vec2 la = vec2(0.0);
      for (int st = 0; st < STEPS; st++) {
        vec2 o = lr * (float(st + 1) / float(STEPS));
        vec3 SL = tapPos(v_uv + o), SR = tapPos(v_uv - o);
        vec3 dL = SL - P, dR = SR - P;
        float nAng = clamp((1.0 - dot(dL, dR) * inversesqrt(max(dot(dL, dL) * dot(dR, dR), 1e-12))) * 0.5, 0.0, 1.0);
        // left / right: the samples' depth in front of the pixel (Unreal's view z grows away from the eye)
        float left = z - (-SL.z), right = z - (-SR.z);
        if (left + right < FLAT_BIAS) nAng = 1.0;
        float w = clamp(-SL.z * INV_DIST + 1.0 - z * INV_DIST, 0.0, 1.0) * clamp(-SR.z * INV_DIST + 1.0 - z * INV_DIST, 0.0, 1.0);
        vec2 step = vec2((1.0 - nAng) / (w + 0.001), w);
        la = mix(la, vec2(max(la.x, step.x), 1.0), step.y);
      }
      float open = 1.0 - la.x;
      acc += vec2(open * open * la.y, la.y);
    }
    // AmbientOcclusionPower 2, then the intensity
    ao = 1.0 - (1.0 - pow(clamp(acc.x / acc.y, 0.0, 1.0), 2.0)) * u_intensity;
  }
  // its quad message passing blur (QUAD_MESSAGE_PASSING_BLUR 2, at the medium and low qualities): each pixel of a 2 x 2 quad takes
  // in its row's and its column's neighbour, by derivatives, each weighted by how alike their normals are (NormalTweak 4)
  if (u_ao_q.z > 0.5) {
    vec4 c = vec4(ao, past ? vec3(0.0) : N);          // a pixel past the AO's reach has no say (its weight 0)
    vec4 ddX = dFdxFine(c), ddY = dFdyFine(c);
    vec2 sgn = vec2(ivec2(gl_FragCoord.xy) % 2) * 2.0 - 1.0;
    vec4 pb = c - ddX * sgn.x, pc = c - ddY * sgn.y;
    float wb = clamp(pow(clamp(dot(N, pb.yzw) * inversesqrt(max(dot(pb.yzw, pb.yzw), 1e-8)), 0.0, 1.0), 4.0), 0.0, 1.0);
    float wc = clamp(pow(clamp(dot(N, pc.yzw) * inversesqrt(max(dot(pc.yzw, pc.yzw), 1e-8)), 0.0, 1.0), 4.0), 0.0, 1.0);
    ao = (ao + wb * pb.x + wc * pc.x) / (1.0 + wb + wc);
  }
  if (past) { o_color = vec4(0.0, 0.0, 0.0, 1.0); return; }
  // ---- the bounce: the lit colour of what rises over the pixel's hemisphere
  vec3 gi = vec3(0.0);
  float giW = 0.0;
  const int S = 8;
  float radius = u_radius * (1.0 + 0.01 * -P.z);
  vec3 up = abs(N.z) < 0.999 ? vec3(0, 0, 1) : vec3(1, 0, 0);
  vec3 t = normalize(cross(up, N)), b = cross(N, t);
  for (int i = 0; i < (u_gi > 0.5 ? S : 0); i++) {
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
