in vec2 v_uv;
out vec4 o_color;
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
  float NoV = max(v_uv.x, 1e-3);
  float rough = max(v_uv.y, 0.02);
  vec3 v = vec3(sqrt(1.0 - NoV * NoV), 0.0, NoV);
  float a = rough * rough;
  float A = 0.0, B = 0.0;
  const uint N = 512u;
  for (uint i = 0u; i < N; i++) {
    vec2 x = hammersley(i, N);
    float phi = 2.0 * PI * x.x;
    float ct = sqrt((1.0 - x.y) / (1.0 + (a * a - 1.0) * x.y));
    float st = sqrt(1.0 - ct * ct);
    vec3 h = vec3(cos(phi) * st, sin(phi) * st, ct);
    vec3 l = 2.0 * dot(v, h) * h - v;
    float NoL = max(l.z, 0.0), NoH = max(h.z, 0.0), VoH = max(dot(v, h), 0.0);
    if (NoL > 0.0) {
      float G = V_Smith(NoV, NoL, a) * 4.0 * NoL * NoV;   // Smith G from the visibility term
      float Gv = G * VoH / max(NoH * NoV, 1e-4);
      float Fc = pow(1.0 - VoH, 5.0);
      A += (1.0 - Fc) * Gv;
      B += Fc * Gv;
    }
  }
  o_color = vec4(clamp(A / float(N), 0.0, 1.0), clamp(B / float(N), 0.0, 1.0), 0.0, 1.0);
}
