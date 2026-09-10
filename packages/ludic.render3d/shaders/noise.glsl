// ---- shared noise (value / gradient / fbm / ridged) ----------------------------
float hash1(vec2 p) { return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453123); }
vec2 hash2(vec2 p) { p = vec2(dot(p, vec2(127.1, 311.7)), dot(p, vec2(269.5, 183.3))); return fract(sin(p) * 43758.5453123) * 2.0 - 1.0; }
float gnoise(vec2 p) {
  vec2 i = floor(p), f = fract(p);
  vec2 u = f * f * (3.0 - 2.0 * f);
  return mix(mix(dot(hash2(i + vec2(0, 0)), f - vec2(0, 0)), dot(hash2(i + vec2(1, 0)), f - vec2(1, 0)), u.x),
             mix(dot(hash2(i + vec2(0, 1)), f - vec2(0, 1)), dot(hash2(i + vec2(1, 1)), f - vec2(1, 1)), u.x), u.y);
}
float fbm(vec2 p, int oct) {
  float a = 0.5, s = 0.0, n = 0.0;
  mat2 r = mat2(0.8, 0.6, -0.6, 0.8) * 2.02;
  for (int i = 0; i < oct; i++) { s += a * gnoise(p); n += a; a *= 0.5; p = r * p; }
  return s / n;
}
float ridged(vec2 p, int oct) {
  float a = 0.5, s = 0.0, w = 1.0;
  mat2 r = mat2(0.8, 0.6, -0.6, 0.8) * 2.1;
  for (int i = 0; i < oct; i++) { float n = 1.0 - abs(gnoise(p)); n = n * n * w; w = clamp(n * 1.5, 0.0, 1.0); s += a * n; a *= 0.5; p = r * p; }
  return s;
}
// the dirt track: distance from a winding curve through the meadow
float pathDist(vec2 xz) {
  float cx = 40.0 * sin(xz.y * 0.011) + 18.0 * sin(xz.y * 0.031 + 1.7) - 30.0;
  float cx2 = -180.0 + 25.0 * sin(xz.y * 0.017 + 0.4) + (xz.y * 0.35);
  return min(abs(xz.x - cx), abs(xz.x - cx2) + 1.0);
}
