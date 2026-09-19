// ---- ONE WIND, and everything in the valley is moved by it ----------------------------------
//
// Before this the grass had a gust term built from two sines and the trees had NO gust at all -
// just a per-instance wobble - so the meadow rippled and the canopy over it swayed to an
// unrelated rhythm. Nothing ever crossed the valley. A real gust is a WAVE: you watch it come
// over the grass, it reaches you, and it goes on into the trees behind you, and that single
// fact does more for "this place is alive" than any amount of extra detail.
//
// It is prepended to EVERY stage (programs.ludic), so the grass's vertex shader, the crown's
// vertex shader and the water's fragment shader all read the same field at the same world
// position and cannot drift apart. No uniforms are declared here on purpose: u_time and u_wind
// already exist in several of those files, and redeclaring them would be a compile error in
// whichever stage happened to include both. The caller passes what it already has.

// The prevailing wind down the valley. Maroon Creek runs roughly north-east, and a mountain
// valley funnels its wind along itself rather than across.
const vec2 WIND_DIR = vec2(0.86, 0.51);

// 0 = still, 1 = the middle of a gust. Mostly low with fronts travelling through it, because
// real wind is gusts separated by calm and not a constant shaking.
float windGust(vec2 xz, float t) {
  float d = dot(xz, WIND_DIR);
  float across = dot(xz, vec2(-WIND_DIR.y, WIND_DIR.x));
  // three scrolling bands: a fast narrow front, a slow broad swell, and a slight variation
  // along the front so it does not arrive as one straight wall
  // The wavelength has to fit INSIDE a view or nothing is ever seen to travel: at 0.030 the
  // front was 209 m from crest to crest, longer than the meadow you can see, so the whole
  // frame sat in one phase and the gust read as everything breathing together. At 0.085 it is
  // about 74 m and a front crosses a normal view in a couple of seconds.
  float g = sin(d * 0.085 - t * 2.6)
          + 0.65 * sin(d * 0.022 - t * 0.85 + 1.7)
          + 0.40 * sin(across * 0.040 - t * 0.55);
  // tighter than a plain smoothstep either side: gusts with calm between them, not a wobble
  return smoothstep(-0.10, 1.35, g);
}

// What a plant actually does: a small constant tremble it always has, plus the gust, which is
// most of the motion. `stiff` is how much the plant resists - grass near 0, a spruce trunk near
// 1 - so the same field moves a blade a long way and a bole hardly at all.
float windSway(vec2 xz, float t, float phase, float stiff) {
  float tremble = sin(phase) * 0.6 + sin(phase * 2.3 + 1.0) * 0.4;
  float gust = windGust(xz, t);
  return (tremble * 0.30 + gust * 1.35) * (1.0 - 0.85 * stiff);
}
