in vec2 v_uv;
in vec3 v_wpos;
in float v_seed;
in float v_tile;
in float v_yaw;
out vec4 o_color;
uniform sampler2D u_atlas_albedo;
uniform sampler2D u_atlas_normal;
uniform mat4 u_view;
uniform float u_tiles;
uniform vec3 u_tint;
uniform float u_radius;
void main() {
  if (v_wpos.y < u_clip_y) discard;
  vec2 uv = vec2((v_tile + v_uv.x) / u_tiles, v_uv.y);
#ifdef SHADOW_PASS
  // the map's texels are coarse: read a finer mip so the crown's coverage is not averaged away
  vec4 a = texture(u_atlas_albedo, uv, -3.0);
  if (a.a < 0.22) discard;
#else
  vec4 a = texture(u_atlas_albedo, uv);
  float rawA = a.a;
  a.rgb /= max(a.a, 1e-3);          // the atlas mips are premultiplied by coverage
  // alpha-to-coverage, sharpened per mip so the silhouette stays crisp at any distance
  float cov = (a.a - 0.3) / max(fwidth(a.a), 1e-4) + 0.5;
  if (cov < 0.02) discard;
  a.a = clamp(cov, 0.0, 1.0);
#endif
#ifdef SHADOW_PASS
  return;
#else
  // The normal atlas is cleared to black where nothing was drawn, and its mips average
  // that black into every silhouette texel — decoded, a half-covered texel pointed away
  // from everything and shaded near black, so each tree wore a dark outline. Dividing by
  // the same coverage restores the normal (and the AO in .a) of the covered part.
  vec4 nn = texture(u_atlas_normal, uv) / max(rawA, 1e-3);
  vec3 n = clamp(nn.rgb, 0.0, 1.0) * 2.0 - 1.0;
  // the tile was baked from angle tile*2pi/tiles around the canonical tree; rotate by the instance yaw
  float s = sin(v_yaw), c = cos(v_yaw);
  n = vec3(c * n.x + s * n.z, n.y, -s * n.x + c * n.z);
  n = normalize(n);
  // canopy hull normal: a rounded shell over the card, blended with the baked detail
  float far = smoothstep(200.0, 1200.0, length(v_wpos - u_cam_pos));
  vec2 q = vec2(v_uv.x * 2.0 - 1.0, v_uv.y * 2.0 - 1.0);
  vec3 toCam = normalize(u_cam_pos - v_wpos); toCam.y = 0.0; toCam = normalize(toCam);
  vec3 right = vec3(-toCam.z, 0.0, toCam.x);
  vec3 hull = normalize(right * q.x * 0.8 + vec3(0.0, 1.0, 0.0) * (q.y * 0.6 + 0.35) + toCam * 0.7);
  // Keep the BAKED normal. This was mix(0.65, 0.35, far), so past a few hundred metres
  // only a third of the foliage's own normal survived and two thirds was a smooth
  // rounded shell - which shades evenly and turns a canopy into a flat coloured blob.
  // Impostors draw nearly all the forest a player ever sees (turn them off and the
  // valley is bare), so that shell was most of the tree line.
  n = normalize(mix(hull, n, mix(0.88, 0.70, far)));
  float dist = length(v_wpos - u_cam_pos);
  float viewDepth = -(u_view * vec4(v_wpos, 1.0)).z;
  vec3 alb = a.rgb * u_tint * (0.85 + 0.3 * fract(v_seed * 7.13)) * regionTint(v_wpos, 0.4);
  // A distant stand reads as a dark mass, not as bright separate sprites - but this was
  // also pulling the colour out of it. Darken without desaturating: the same factor on
  // all three channels, and a touch of saturation put back, because the thing that makes
  // a far tree line read as forest rather than as a wash is that it is still GREEN.
  alb = mix(alb, alb * 0.72, far);
  float lum = dot(alb, vec3(0.2126, 0.7152, 0.0722));
  alb = mix(vec3(lum), alb, 1.45);          // conifer foliage is SATURATED, not grey-green
  alb *= 0.78;                               // and it is dark: a spruce canopy is not a lawn
  // the card itself is the caster: look up the shadow a little toward the sun so it does not self-shadow
  float shadow = sunShadow(v_wpos + u_sun_dir * u_radius * 0.7, vec3(0, 1, 0), viewDepth);
  // crowns are dense: darken toward the centre of the card as a cheap interior occlusion
  float interior = 1.0 - 0.22 * smoothstep(0.9, 0.3, abs(q.x)) * smoothstep(1.0, 0.2, v_uv.y);
  // ground contact: the lowest part of anything sitting on the ground is occluded by it
  // (a boulder's underside, a trunk's base); without it a far boulder is a sticker on the grass
  interior *= mix(0.55, 1.0, smoothstep(0.0, 0.3, v_uv.y));
  vec3 col = shade(v_wpos, n, alb, 0.85, 0.0, clamp(nn.a, 0.0, 1.0) * 0.8 * interior, shadow * interior, viewDepth);
  col += alb * skyIrradiance(vec3(0, 1, 0)) * 0.06;
  col = applyFog(col, v_wpos, dist);
  o_color = vec4(sane(col), a.a);
#endif
}
