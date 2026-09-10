// auto-exposure on the GPU: the scene's mean luminance from the top of its mip chain,
// eased toward from the previous frame's value, written to a 1x1 texture the tonemapper
// reads. Nothing comes back to the CPU (a readback there waited for the whole frame's
// GPU work and serialised the two: 34 ms -> the sum of both, measured 2026-09-09).
in vec2 v_uv;
out vec4 o_color;
uniform sampler2D u_scene;
uniform sampler2D u_prev;
uniform float u_lod;
uniform float u_key;
uniform float u_max;
uniform float u_rate;
uniform float u_reset;
void main() {
  vec3 c = textureLod(u_scene, vec2(0.5), u_lod).rgb;
  c = clamp(c, vec3(0.0), vec3(1.0e5));
  float lum = dot(c, vec3(0.2126, 0.7152, 0.0722));
  float target = clamp(u_key / max(lum, 0.001), 0.02, u_max);
  float prev = texture(u_prev, vec2(0.5)).r;
  float e = mix(prev, target, u_rate);
  if (u_reset > 0.5 || !(prev > 0.0)) e = target;
  o_color = vec4(e, 0.0, 0.0, 1.0);
}
