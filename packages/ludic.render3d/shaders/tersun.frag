// tersun.frag — the terrain's sun visibility, on its own, one screen-sized R8 buffer.
//
// The ground's shading shader is large: it blends four scanned materials, a photograph
// and a dozen noise fields. Adding a read of the cascade shadow map to it costs about
// six milliseconds a frame on this driver — and costs the same whether the map is tapped
// once or eight times, filtered or texelFetched, compared in hardware or by hand. It is
// a cliff the big shader falls off, not work it performs. The same read from a small
// shader is nearly free, so the read happens here instead: this pass rasterises the same
// CDLOD patches, evaluates the cascades once per pixel, and writes the answer for
// terrain.frag to look up by fragment coordinate.
in vec3 v_wpos;
in vec2 v_huv;
out float o_sh;
uniform sampler2D u_height;
uniform mat4 u_view;
uniform float u_far_split;
uniform float u_far_band;
void main() {
  vec3 p = v_wpos;
  if (p.y < u_clip_y) discard;
  vec3 N = normalize(texture(u_height, v_huv).gba);
  float dist = length(p - u_cam_pos);
  float viewDepth = -(u_view * vec4(p, 1.0)).z;
  // The same tier choice the ground makes, cross-faded over the same band: the near tier
  // keeps its filtered penumbra, the far tier its single tap, and the boundary between
  // them is not a contour you can find on the hillside.
  if (dist > u_far_split + u_far_band) o_sh = sunShadowCheap(p, N, viewDepth);
  else if (dist < u_far_split - u_far_band) o_sh = sunShadow(p, N, viewDepth);
  else o_sh = mix(sunShadow(p, N, viewDepth), sunShadowCheap(p, N, viewDepth),
                  smoothstep(u_far_split - u_far_band, u_far_split + u_far_band, dist));
}
