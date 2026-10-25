// Temporal anti-aliasing: the resolve (taa.ludic). The scene is drawn with a sub-pixel jitter that
// cycles through a Halton (2, 3) pattern, so eight frames sample eight places inside every pixel; this
// pass folds each frame into a history that follows the surfaces across the screen, so over a few
// frames every pixel becomes the average of its whole area - an edge, a blade, a hair card resolved
// as if by supersampling. The method is the one Karis set out (High Quality Temporal Supersampling,
// 2014) and Unreal and Playdead ship; this is its own implementation from that math:
//   - the current frame is reconstructed at the pixel's centre from its 3x3 neighbours, each weighted
//     by a Blackman-Harris-like kernel over its distance from the centre once the jitter is undone;
//   - everything is compared and blended in a reversible tonemapped space (Karis), so one HDR
//     highlight cannot dominate an average, and in YCoCg, where the clamp box fits colour best;
//   - the history is read where the surface was last frame (the motion target: the camera's motion
//     from depth, the moving actors' own) with a Catmull-Rom filter, which does not soften it;
//   - before it is used it is clipped into the box of what this frame's neighbourhood can be (mean
//     +- 1.25 standard deviations, inside the min/max): a colour that is no longer there - something
//     that moved away, a reflection that slid - cannot survive, which is what stops ghosting;
//   - the current frame's share is 4 % on a still pixel (Unreal's default) and rises to 20 % with
//     speed, so motion stays sharp; a pixel uncovered since last frame (its history was nearer the
//     camera) or off last frame's screen starts over from this frame.
// Reactive: what was laid over the opaque scene after it was drawn - the water, puddles, the blended
// actors (smoke, glows) - has no motion of its own in the target and must not be dragged. Its pixels
// are found by comparing the final colour with the opaque copy taken before them (post_scene): where
// they differ, the history is clipped hard and the frame takes at least a quarter (Unreal's responsive
// pixels), so the reflection a turning camera sweeps across a lake cannot trail behind it.
in vec2 v_uv;
out vec4 o_color;
uniform sampler2D u_cur;       // this frame, jittered, linear HDR
uniform sampler2D u_hist;      // last frame's resolve: rgb linear HDR, a linear view depth (m)
uniform sampler2D u_vel;       // prev uv - this uv
uniform sampler2D u_depth;     // this frame's depth (reversed)
uniform sampler2D u_opaque;    // this frame's colour before the transparent passes
uniform float u_has_opaque;
uniform vec2 u_texel;
uniform vec2 u_jitter;         // this frame's sub-pixel offset, in pixels (the image moved by it)
// the reconstruction's weights for the 3x3, row by row from (-1, -1), normalised (taa.ludic works them out
// from the jitter once a frame: exp(-2.29 d^2) at each sample's distance from the centre, the jitter undone)
uniform vec4 u_wa;
uniform vec4 u_wb;
uniform float u_wc;
uniform float u_reset;         // 1: no history worth reading
uniform float u_weight;        // the current frame's share on a still pixel
uniform mat4 u_inv_proj;
uniform float u_cam_move;      // metres the camera moved since last frame
uniform float u_exposure;
uniform sampler2D u_adapt;
uniform float u_auto;

float taaE = 1.0;
vec3 taaTone(vec3 c) { c = max(c, vec3(0.0)) * taaE; return c / (1.0 + max(c.r, max(c.g, c.b))); }
vec3 taaUntone(vec3 t) { return t / max(1.0 - max(t.r, max(t.g, t.b)), 1e-3) / taaE; }
vec3 taaYCoCg(vec3 c) { return vec3(0.25 * c.r + 0.5 * c.g + 0.25 * c.b, 0.5 * c.r - 0.5 * c.b, -0.25 * c.r + 0.5 * c.g - 0.25 * c.b); }
vec3 taaRGB(vec3 y) { return vec3(y.x + y.y - y.z, y.x + y.z, y.x - y.y - y.z); }
vec3 taaFinite(vec3 c) { return (any(isnan(c)) || any(isinf(c))) ? vec3(0.0) : c; }
float taaViewZ(float d) {
  vec4 p = u_inv_proj * vec4(0.0, 0.0, depthClip(d), 1.0);
  return min(abs(p.z / p.w), 60000.0);
}
// Catmull-Rom through the 4x4 texels round uv, from five bilinear taps (the corners' weights are
// small enough to leave out): sharp where bilinear would blur the history a little every frame
vec3 taaHistory(vec2 uv, vec2 size) {
  vec2 sp = uv * size;
  vec2 tp = floor(sp - 0.5) + 0.5;
  vec2 f = sp - tp;
  vec2 w0 = f * (-0.5 + f * (1.0 - 0.5 * f));
  vec2 w1 = 1.0 + f * f * (-2.5 + 1.5 * f);
  vec2 w2 = f * (0.5 + f * (2.0 - 1.5 * f));
  vec2 w3 = f * f * (-0.5 + 0.5 * f);
  vec2 w12 = w1 + w2;
  vec2 t0 = (tp - 1.0) * u_texel;
  vec2 t3 = (tp + 2.0) * u_texel;
  vec2 t12 = (tp + w2 / w12) * u_texel;
  float a = w12.x * w0.y, b = w0.x * w12.y, c = w12.x * w12.y, d = w3.x * w12.y, e = w12.x * w3.y;
  vec3 s = textureLod(u_hist, vec2(t12.x, t0.y), 0.0).rgb * a
         + textureLod(u_hist, vec2(t0.x, t12.y), 0.0).rgb * b
         + textureLod(u_hist, t12, 0.0).rgb * c
         + textureLod(u_hist, vec2(t3.x, t12.y), 0.0).rgb * d
         + textureLod(u_hist, vec2(t12.x, t3.y), 0.0).rgb * e;
  return max(s / (a + b + c + d + e), vec3(0.0));
}
// pull h toward the box's centre until it is inside the box (an AABB clip, not a per-channel clamp,
// so the colour keeps its hue on the way in)
vec3 taaClip(vec3 h, vec3 bmin, vec3 bmax) {
  vec3 ctr = 0.5 * (bmax + bmin);
  vec3 ext = 0.5 * (bmax - bmin) + 1e-5;
  vec3 v = h - ctr;
  vec3 r = abs(v / ext);
  float m = max(r.x, max(r.y, r.z));
  return (m > 1.0) ? ctr + v / m : h;
}

void main() {
  vec2 size = 1.0 / u_texel;
  ivec2 isz = ivec2(size + 0.5) - 1;
  ivec2 px = ivec2(gl_FragCoord.xy);
  taaE = max((u_auto > 0.5) ? texture(u_adapt, vec2(0.5)).r : u_exposure, 1e-4);

  // the neighbourhood: its reconstruction at the pixel's centre, its moments and its bounds, and the
  // nearest surface in the cross (whose motion the pixel takes, so an edge moves with what is in front)
  vec3 m1 = vec3(0.0), m2 = vec3(0.0), mn = vec3(1e9), mx = vec3(-1e9), filt = vec3(0.0);
  float wts[9] = float[9](u_wa.x, u_wa.y, u_wa.z, u_wa.w, u_wb.x, u_wb.y, u_wb.z, u_wb.w, u_wc);
  float best = -1.0;
  float dc = 0.0;
  ivec2 bestP = px;
  vec3 c0 = vec3(0.0);
  for (int y = -1; y <= 1; y++) {
    for (int x = -1; x <= 1; x++) {
      ivec2 q = clamp(px + ivec2(x, y), ivec2(0), isz);
      vec3 t = taaFinite(taaTone(texelFetch(u_cur, q, 0).rgb));
      vec3 c = taaYCoCg(t);
      if (x == 0 && y == 0) c0 = t;
      m1 += c;  m2 += c * c;
      mn = min(mn, c);  mx = max(mx, c);
      filt += c * wts[(y + 1) * 3 + x + 1];
      if (x == 0 || y == 0) {
        float d = texelFetch(u_depth, q, 0).r;
        if (x == 0 && y == 0) dc = d;
        if (d > best) { best = d;  bestP = q; }
      }
    }
  }
  m1 /= 9.0;  m2 /= 9.0;
  vec3 sigma = sqrt(max(m2 - m1 * m1, vec3(0.0)));

  // what was laid over the opaque scene (water, puddles, smoke): responsive
  float reactive = 0.0;
  if (u_has_opaque > 0.5) {
    vec3 o = taaTone(texelFetch(u_opaque, px, 0).rgb);
    vec3 dd = abs(c0 - o);
    reactive = clamp(max(dd.r, max(dd.g, dd.b)) * 24.0, 0.0, 1.0);
  }
  float gamma = mix(1.25, 0.75, reactive);
  vec3 bmin = max(mn, m1 - gamma * sigma);
  vec3 bmax = min(mx, m1 + gamma * sigma);

  vec2 mv = texelFetch(u_vel, bestP, 0).rg;
  vec2 puv = v_uv + mv;
  float dcur = taaViewZ(dc);
  float wc = u_weight;
  bool fresh = u_reset > 0.5 || mv.x > 3.0 || any(lessThan(puv, vec2(0.0))) || any(greaterThan(puv, vec2(1.0)));
  vec3 res;
  if (fresh) {
    res = filt;
  } else {
    vec3 h = taaYCoCg(taaTone(taaFinite(taaHistory(puv, size))));
    h = taaClip(h, bmin, bmax);
    // faster motion keeps more of this frame: the history has been resampled more often and is softer
    float speed = length(mv * size);
    wc = mix(wc, 0.2, clamp(speed / 40.0, 0.0, 1.0));
    // uncovered: last frame something stood nearer the camera here than this surface is now
    float dh = texelFetch(u_hist, clamp(ivec2(puv * size), ivec2(0), isz), 0).a;
    float tol = 0.06 * dcur + 2.0 * u_cam_move + 0.05;
    float rej = clamp((dcur - dh - tol) / max(tol, 1e-3), 0.0, 1.0);
    wc = mix(wc, 1.0, rej);
    wc = max(wc, 0.25 * reactive);
    res = mix(h, filt, wc);
  }
  vec3 rgb = taaUntone(clamp(taaRGB(res), vec3(0.0), vec3(0.999)));
  o_color = vec4(taaFinite(rgb), dcur);
}
