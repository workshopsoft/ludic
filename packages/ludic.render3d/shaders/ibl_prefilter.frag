in vec2 v_uv;
out vec4 o_color;
uniform sampler2D u_sky;
uniform float u_rough;
uniform float u_sun_clip;
uniform float u_sky_w;
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
  vec3 v = n;
  if (u_rough < 0.02) { o_color = vec4(textureLod(u_sky, skyUV(n), 0.0).rgb, 1.0); return; }
  vec3 up = abs(n.y) < 0.999 ? vec3(0, 1, 0) : vec3(1, 0, 0);
  vec3 t = normalize(cross(up, n));
  vec3 b = cross(n, t);
  float a = u_rough * u_rough;
  vec3 acc = vec3(0.0);
  float wsum = 0.0;
  const uint N = 256u;
  for (uint i = 0u; i < N; i++) {
    vec2 x = hammersley(i, N);
    float phi = 2.0 * PI * x.x;
    float ct = sqrt((1.0 - x.y) / (1.0 + (a * a - 1.0) * x.y));
    float st = sqrt(1.0 - ct * ct);
    vec3 h = t * (cos(phi) * st) + b * (sin(phi) * st) + n * ct;
    vec3 l = 2.0 * dot(v, h) * h - v;
    float NoL = dot(n, l);
    if (NoL > 0.0) {
      float NoH = max(ct, 0.0);
      float D = D_GGX(NoH, a);
      float pdf = D * NoH / (4.0 * max(dot(v, h), 1e-4)) + 1e-4;
      float saTexel = 4.0 * PI / (u_sky_w * u_sky_w * 0.5);
      float saSample = 1.0 / (float(N) * pdf);
      float mip = clamp(0.5 * log2(saSample / saTexel) + 1.0, 0.0, 8.0);
      vec3 c = textureLod(u_sky, skyUV(l), mip).rgb;
      acc += min(c, vec3(u_sun_clip)) * NoL;
      wsum += NoL;
    }
  }
  o_color = vec4(acc / max(wsum, 1e-4), 1.0);
}
