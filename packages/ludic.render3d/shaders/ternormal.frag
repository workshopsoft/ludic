// Second generation pass: bake the B-spline surface normal, once, at texel resolution: x and z
// into an RG16F beside the R32F height (y is rebuilt where it is read). terrain.frag used to differentiate the bicubic height
// per pixel — four bicubic reads, sixteen taps — for a quantity that never changes.
in vec2 v_uv;
out vec4 o;
uniform sampler2D u_src;
uniform float u_half;
float heightSmooth(sampler2D tex, vec2 uv) {
  vec2 res = vec2(textureSize(tex, 0));
  vec2 t = uv * res - 0.5;
  vec2 f = fract(t);
  vec2 i = floor(t);
  vec2 w0 = (1.0 - f) * (1.0 - f) * (1.0 - f) / 6.0;
  vec2 w1 = (4.0 - 6.0 * f * f + 3.0 * f * f * f) / 6.0;
  vec2 w3 = f * f * f / 6.0;
  vec2 w2 = 1.0 - w0 - w1 - w3;
  vec2 s0 = w0 + w1, s1 = w2 + w3;
  vec2 o0 = (i - 1.0 + w1 / s0 + 0.5) / res;
  vec2 o1 = (i + 1.0 + w3 / s1 + 0.5) / res;
  return (texture(tex, vec2(o0.x, o0.y)).r * s0.x + texture(tex, vec2(o1.x, o0.y)).r * s1.x) * s0.y
       + (texture(tex, vec2(o0.x, o1.y)).r * s0.x + texture(tex, vec2(o1.x, o1.y)).r * s1.x) * s1.y;
}
void main() {
  float step = 1.0 / float(textureSize(u_src, 0).x);
  float world = step * 2.0 * u_half;
  float hl = heightSmooth(u_src, v_uv - vec2(step, 0));
  float hr = heightSmooth(u_src, v_uv + vec2(step, 0));
  float hd = heightSmooth(u_src, v_uv - vec2(0, step));
  float hu = heightSmooth(u_src, v_uv + vec2(0, step));
  vec3 n = normalize(vec3(hl - hr, 2.0 * world, hd - hu));
  o = vec4(n.x, n.z, 0.0, 0.0);      // into RG16F: x and z, y rebuilt when read (always up)
}
