in vec2 v_uv;
out vec4 o_color;
uniform sampler2D u_sky;
uniform float u_sun_clip;      // clamp the sun's radiance so it does not alias the convolution
vec3 dirFromUV(vec2 uv) {
  float phi = (uv.x - 0.5) * 2.0 * PI;
  float theta = uv.y * PI;
  return vec3(sin(theta) * sin(phi), cos(theta), -sin(theta) * cos(phi));
}
vec2 hammersley(uint i, uint n) {
  uint b = i;
  b = (b << 16u) | (b >> 16u);
  b = ((b & 0x55555555u) << 1u) | ((b & 0xAAAAAAAAu) >> 1u);
  b = ((b & 0x33333333u) << 2u) | ((b & 0xCCCCCCCCu) >> 2u);
  b = ((b & 0x0F0F0F0Fu) << 4u) | ((b & 0xF0F0F0F0u) >> 4u);
  b = ((b & 0x00FF00FFu) << 8u) | ((b & 0xFF00FF00u) >> 8u);
  return vec2(float(i) / float(n), float(b) * 2.3283064365386963e-10);
}
void main() {
  vec3 n = dirFromUV(v_uv);
  vec3 up = abs(n.y) < 0.999 ? vec3(0, 1, 0) : vec3(1, 0, 0);
  vec3 t = normalize(cross(up, n));
  vec3 b = cross(n, t);
  vec3 acc = vec3(0.0);
  const uint N = 512u;
  for (uint i = 0u; i < N; i++) {
    vec2 h = hammersley(i, N);
    float phi = 2.0 * PI * h.x;
    float ct = sqrt(1.0 - h.y);            // cosine-weighted
    float st = sqrt(h.y);
    vec3 d = t * (cos(phi) * st) + b * (sin(phi) * st) + n * ct;
    vec3 c = textureLod(u_sky, skyUV(d), 5.0).rgb;
    acc += min(c, vec3(u_sun_clip));
  }
  o_color = vec4(acc / float(N), 1.0);
}
