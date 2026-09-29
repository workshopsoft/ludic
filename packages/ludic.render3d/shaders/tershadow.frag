// Height-field sun shadow, baked once per sun direction (the sun is fixed per scene).
//
// For every height-map texel: the lowest height at which a point above that texel still
// sees the sun. A point (xz, y) is lit iff the ray toward the sun clears the ground
// everywhere along it, i.e. y > h(xz + d.xz t) - d.y t for all t — so the value stored
// is the maximum of that expression over the ray. Every receiver in the scene (ground,
// trunk, crown, card, water) compares its own height against it: one march per texel,
// once, instead of 28 taps per terrain pixel per frame, and vegetation standing in a
// hillside's shadow goes dark with the hillside instead of glowing in front of it.
// The second channel is the distance to the occluder that set the bound, which widens
// the penumbra the way a real shadow softens with distance from its caster.
in vec2 v_uv;
out vec4 o;   // TS_AUX: the occluder distance and the cloud mask (RG16F); else the lowest lit height (R32F)
uniform sampler2D u_height;
uniform float u_half;
uniform vec3 u_sun;
void main() {
  vec2 xz = (v_uv - 0.5) * 2.0 * u_half;
  vec3 d = u_sun;
  float lit = -1.0e6;
  float at = 0.0;
  if (d.y > 0.02) {
    float t = 1.5, step = 1.5;
    for (int i = 0; i < 128; i++) {
      vec2 q = xz + d.xz * t;
      vec2 uv = q / (2.0 * u_half) + 0.5;
      if (uv.x < 0.0 || uv.x > 1.0 || uv.y < 0.0 || uv.y > 1.0) break;
      float h = texture(u_height, uv).r - d.y * t;
      if (h > lit) { lit = h; at = t; }
      t += step;
      step *= 1.045;
    }
  }
  // the cloud layer's mask, once, into the aux target's G: sampled by cloudShadow() with the sun offset and
  // the drift applied as a uv shift, instead of a five-octave fbm in every lit pixel of
  // every pass
  float cloud = smoothstep(0.02, 0.32, fbm(xz * 0.0011, 5));
#ifdef TS_AUX
  o = vec4(at, cloud, 0.0, 1.0);
#else
  o = vec4(lit, 0.0, 0.0, 1.0);
#endif
}
