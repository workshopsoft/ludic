#if defined(CARD_DOM)
// hair cards into the hair's deep shadow (strands.ludic, R3D_CARDS_DOM), as Unreal draws a groom's cards there (HairStrandsInterface.cpp
// CardsOrMeshesShadowView; HairStrandsDeepShadowPS.usf MainDom with SUPPORT_OPACITY_MASK 0; HairStrandsDeepShadowVS.usf HairCoverage 1 for
// a mesh that is not strands): the whole card's coverage into each layer its distance behind the front depth lies within (reversed depth:
// the front is the greater; ComputeDOMWeights), added up
uniform sampler2D u_hs_front;
uniform vec4 u_hs_layers;
out vec4 o_color;
void main() {
  float front = texelFetch(u_hs_front, ivec2(gl_FragCoord.xy), 0).r;
  float dist = max(0.0, front - gl_FragCoord.z);
  o_color = vec4(lessThan(vec4(dist), u_hs_layers));
}
#elif defined(ALPHA_TEST)
// foliage meshes are cut-out cards: their shadow must have the card's shape, not the quad's
in vec2 v_uv;
uniform sampler2D u_diff;
#ifdef HAIR_CARD
// a hair card (model.frag FABRIC mode 3, R3D_CARD_SHADOW_CUT): its shadow cut by the groom's coverage as its lit pass cuts it (Unreal's
// shadow depth pass evaluates the material's mask: ShadowDepthPixelShader.usf GetMaterialClippingShadowDepth); u_fp in model.frag's layout
uniform vec4 u_fp[17];
uniform sampler2D u_fmask;
#endif
void main() {
#ifdef HAIR_CARD
  if (u_fp[16].w > 2.5) {
    if (!hairCardKeep(texture(u_fmask, (v_uv - u_fp[4].xy) / u_fp[4].z).r, u_fp[3], u_dither_frame)) discard;
    return;
  }
#endif
  float lod = textureQueryLod(u_diff, v_uv).x;
#ifndef WIND
  // an actor's cut-out atlas as its lit pass cuts it (R3D_CARD_DITHER: model.frag)
  if (u_card_cut.x > 0.5) {
    float ca = texture(u_diff, v_uv).a;
    if (u_card_cut.y < 0.5) ca = min(ca * (1.0 + 0.45 * max(lod, 0.0)), 1.0);
    if (!cardDitherKeep(ca, u_dither_frame)) discard;
    return;
  }
#endif
  if (texture(u_diff, v_uv).a * (1.0 + 0.45 * max(lod, 0.0)) < 0.45) discard;
}
#else
void main() { }
#endif
