// world height (metres) for the texel's x/z; R32F target
in vec2 v_uv;
out vec4 o;
uniform float u_half;
#ifdef DEM
uniform sampler2D u_dem;        // 16-bit height map of a real place (Copernicus GLO-30)
uniform float u_dem_min;
uniform float u_dem_max;
uniform float u_dem_base;       // the elevation that becomes y = 0
uniform vec2 u_origin;          // world x/z of the map's centre
uniform vec4 u_lake;            // a lake: centre x/z, half extents (zero = none)
uniform float u_lake_level;     // its surface height; the model records the surface, the bed is carved below it
uniform vec4 u_isle;            // an island: centre x/z, radius (or rim margin), falloff width
uniform float u_isle_mode;      // 0 none, 1 radial (terrain_island), 2 inward from the survey's edge (terrain_coast)
// The DEM is Copernicus GLO-30 — 30 m data resampled onto this 4 m grid — so the stored
// field is piecewise linear with a slope discontinuity every ~7 texels. Differencing it
// for a shading normal turns each kink into a ridge, and on steep ground, where the same
// kink spans a large height change, they read as a regular corrugation running across
// the slope. Smoothing across that lattice removes them and discards no real detail:
// there is none below 30 m in the source, and the fractal detail below supplies the fine
// relief. Kernel is a separable gaussian sampled at 3-texel spacing (~12 m each side).
float demRaw(vec2 uv) { return texture(u_dem, uv).r; }
// u_dem_blur texels of separable gaussian (0 = the survey as it is). The 30 m Copernicus
// model needed ~3 texels to hide its resampling lattice; 2 m lidar needs none.
uniform float u_dem_blur;
float demH(vec2 uv) {
  if (u_dem_blur <= 0.0) return mix(u_dem_min, u_dem_max, demRaw(uv));
  vec2 t = u_dem_blur / vec2(textureSize(u_dem, 0));
  float c = demRaw(uv);
  float e = demRaw(uv + vec2(t.x, 0.0)) + demRaw(uv - vec2(t.x, 0.0))
          + demRaw(uv + vec2(0.0, t.y)) + demRaw(uv - vec2(0.0, t.y));
  float d = demRaw(uv + t) + demRaw(uv - t)
          + demRaw(uv + vec2(t.x, -t.y)) + demRaw(uv + vec2(-t.x, t.y));
  float f = demRaw(uv + 2.0 * vec2(t.x, 0.0)) + demRaw(uv - 2.0 * vec2(t.x, 0.0))
          + demRaw(uv + 2.0 * vec2(0.0, t.y)) + demRaw(uv - 2.0 * vec2(0.0, t.y));
  float h = (12.0 * c + 6.0 * e + 3.0 * d + 2.0 * f) / (12.0 + 24.0 + 12.0 + 8.0);
  return mix(u_dem_min, u_dem_max, h);
}
#endif
float bump(vec2 p, vec2 c, float r) { float d = length(p - c) / r; return exp(-d * d * 2.0); }
void main() {
#ifdef DEM
  vec2 xz = (v_uv - 0.5) * 2.0 * u_half + u_origin;
  float e = 1.0 / 2048.0;
  float h = demH(v_uv) - u_dem_base;
  // the basin mask keys off the UNSMOOTHED sample: the lake is only ~1 m below its shore
  // in the model, and the 12 m blur above averages the shore with the flat water beside
  // it, dragging it under the outline threshold — the camera's own bank was carved 7 m down
  float raw = demRaw(v_uv) * (u_dem_max - u_dem_min) + u_dem_min - u_dem_base;
  // the survey carries its own relief at this resolution; only the foot track is added
  h -= 0.25 * smoothstep(6.0, 1.5, pathDist(xz));
  if (u_lake.z > 0.0) {
    // the elevation model samples the water surface as flat ground: inside the lake's
    // outline sink it into a bed, deepest in the middle, with a gentle gravel ramp at the shore
    vec2 q = (xz - u_lake.xy) / u_lake.zw;
    float inside = smoothstep(1.0, 0.8, dot(q, q));
    // the lidar records the lake as a flat surface exactly at its level: everything at or
    // just above that level inside the outline is lake bed
    float basin = smoothstep(u_lake_level + 0.6, u_lake_level - 0.3, raw) * inside;
    float bed = u_lake_level - 0.4 - (5.0 + 3.0 * (1.0 - dot(q, q)) + 1.5 * fbm(xz * 0.02, 3)) * basin * basin;   // a gentle gravel ramp, then the drop
    h = mix(h, bed, basin);
  }
  // The island. The terrain is scaled toward the water line and then taken below it, so
  // the shoreline is not drawn on: it is wherever the survey's own relief, shrunk, happens
  // to cross the water. Low ground becomes beach and shallows, high ground becomes cliff,
  // and a bay stays a bay.
  //
  // Two ways of deciding where that happens. RADIAL measures out from a centre, which
  // suits a made-up map. COAST measures inward from the survey's own boundary, which suits
  // a real one: everything the data covers stays land and the sea starts where the data
  // runs out, rather than two thirds of an expensive survey being drowned to make an
  // island of the rest.
  if (u_isle_mode > 0.5 && u_isle.z > 0.0) {
    float t;
    float shelf;
    if (u_isle_mode > 1.5) {
      vec2 e = abs(xz - u_isle.xy);
      float inland = u_half - max(e.x, e.y);                     // metres in from the boundary
      inland += 180.0 * (fbm(xz * 0.00085, 4) * 2.0 - 1.0);      // headlands and bays
      t = 1.0 - smoothstep(u_isle.z, u_isle.z + u_isle.w, inland);
      shelf = 26.0 + 34.0 * smoothstep(u_isle.z, 0.0, inland);
    } else {
      float d = distance(xz, u_isle.xy);
      t = smoothstep(u_isle.z, u_isle.z + u_isle.w, d);          // 0 inland, 1 past the fall
      shelf = 26.0 + 34.0 * smoothstep(0.0, 1.0, (d - u_isle.z - u_isle.w) / max(u_isle.w, 1.0));
    }
    float above = h - u_lake_level;
    h = u_lake_level + above * (1.0 - t) - t * shelf;
    // A strand. Scaling alone hands a 500 m mountainside a 40-degree plunge into the sea,
    // which is a cliff coast and nothing else. Real shores are cut flat by the water they
    // meet, so the last few metres of height either side of the line are compressed —
    // which stretches them out horizontally into beach and shallows. Only inside the
    // coastal band: an inland lake has its own bed and wants none of this.
    float near = 1.0 - smoothstep(0.0, 48.0, abs(h - u_lake_level));
    h = mix(h, u_lake_level + (h - u_lake_level) * 0.30, near * smoothstep(0.02, 0.30, t));
  }
  o = vec4(h, 0.0, 0.0, 1.0);
#elif defined(SMOOTH)
  // A purpose-built test ground: 2 km square, analytically smooth everywhere. No survey
  // data, so no resampling lattice and no quantised source — if a grid still shows on
  // this, the cause is in the renderer rather than the elevation model.
  vec2 xz = (v_uv - 0.5) * 2.0 * u_half;
  float d = length(xz);
  // meadow: a gentle roll a few metres either side of 8 m, two octaves only
  float h = 8.0 + 4.5 * fbm(xz * 0.0018, 3) + 1.4 * fbm(xz * 0.007, 3);
  // a small pond in the middle: a smooth basin ~90 m across, floor about 5 m down
  float pond = exp(-dot(xz, xz) / (2.0 * 70.0 * 70.0));
  h -= 13.0 * pond;
  // the rim mountain, 200 m above the meadow, starting well outside the grass
  h += smoothstep(620.0, 980.0, d) * (200.0 + 90.0 * fbm(xz * 0.0025 + 4.0, 4));
  o = vec4(h, 0.0, 0.0, 1.0);
#else
  vec2 xz = (v_uv - 0.5) * 2.0 * u_half;
  float d = length(xz);
  // the meadow falls away northward (-z) from the rise the camera stands on, into a broad valley
  float base = 0.055 * xz.y + 4.0 * fbm(xz * 0.008, 5) + 1.2 * fbm(xz * 0.04, 4) + 0.15 * fbm(xz * 0.35, 3);
  // soft valley floor with a stream
  float floorY = -22.0;
  float k = 12.0;
  base = floorY + k * log(1.0 + exp((base - floorY) / k));
  float sb = smoothstep(6.0, 0.0, abs(xz.x - 150.0 - 90.0 * sin(xz.y * 0.006 + 1.0))) * smoothstep(-220.0, -400.0, xz.y);
  base -= 1.6 * sb;
  // the track sits slightly worn in
  base -= 0.25 * smoothstep(6.0, 1.5, pathDist(xz));
  float h = base;
  // far ridge across the valley, forested hills
  float back = smoothstep(-550.0, -1000.0, xz.y);
  h += back * (90.0 + 160.0 * ridged(xz * 0.0025 + 5.0, 6));
  // the great snow mountain to the north-west, and its shoulder
  float m1 = bump(xz, vec2(-820.0, -520.0), 520.0);
  float m2 = bump(xz, vec2(-1150.0, -900.0), 600.0);
  float m3 = bump(xz, vec2(-560.0, -150.0), 260.0);
  float mtn = max(m1 * 620.0, max(m2 * 720.0, m3 * 180.0));
  h += mtn * (0.45 + 0.55 * ridged(xz * 0.0018 + 11.0, 7)) + 40.0 * (m1 + m2) * ridged(xz * 0.008 + 3.0, 5);
  // hills to the east, lower and rounder
  float e1 = bump(xz, vec2(760.0, -420.0), 420.0);
  float e2 = bump(xz, vec2(950.0, 150.0), 380.0);
  h += (e1 * 170.0 + e2 * 120.0) * (0.6 + 0.4 * fbm(xz * 0.004 + 9.0, 5));
  // the outer rim so nothing ends at a flat edge
  h += smoothstep(750.0, 1024.0, d) * (120.0 + 120.0 * ridged(xz * 0.003, 5));
  // a rocky knoll on the right of the meadow
  float knoll = 14.0 * bump(xz, vec2(230.0, -40.0), 70.0);
  h += knoll * (0.6 + 0.4 * fbm(xz * 0.05, 4));
  o = vec4(h, 0.0, 0.0, 1.0);
#endif
}
