#ifdef ALPHA_TEST
// foliage meshes are cut-out cards: their shadow must have the card's shape, not the quad's
in vec2 v_uv;
uniform sampler2D u_diff;
void main() {
  float lod = textureQueryLod(u_diff, v_uv).x;
  if (texture(u_diff, v_uv).a * (1.0 + 0.45 * max(lod, 0.0)) < 0.45) discard;
}
#else
void main() { }
#endif
