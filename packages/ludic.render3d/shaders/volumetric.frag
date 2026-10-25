// Light you can see: sun shafts through the canopy, mist lying in the valley, and a ridge at
// dusk standing in glowing air. Everything before this made the AIR a colour applied to a
// surface; nothing put light in the space between surfaces, so the basin had no shafts, no
// pooled mist and no rays off the peaks at any hour.
//
// This is a half-resolution march from the camera to whatever the depth buffer says is in
// front of it. At each step it asks the SAME shadow the rest of the frame asks - the cascades,
// the baked height-field shadow and the cloud mask - so a shaft is cast by the actual trees
// and the actual ridge, and a cloud passing over dims its own rays.
in vec2 v_uv;
out vec4 o_color;
uniform sampler2D u_depth;
uniform mat4 u_inv_vp;
uniform float u_vol_steps;
uniform float u_vol_density;     // how much light the air scatters back at you
uniform float u_vol_falloff;     // how fast the haze thins with height above the fog datum
uniform float u_vol_far;         // stop marching here (m): past it the analytic fog carries on
uniform float u_vol_g;           // Henyey-Greenstein anisotropy: how forward-throwing the air is
uniform float u_vol_mist;        // a denser layer lying ON the ground at dawn and dusk
uniform float u_vol_mist_h;      // how deep that layer is (m)

// One shadow lookup for a point in mid-air. It wants no normal and no slope bias - there is no
// surface here to shadow-acne - so it is the cheap tap rather than the receiver's rotated disc.
float volShadow(vec3 wpos, float viewDepth) {
  int c = CASCADES - 1;
  for (int i = 0; i < CASCADES - 1; i++) { if (viewDepth < u_cascade_split[i]) { c = i; break; } }
  vec4 lp = u_cascade_vp[c] * vec4(wpos, 1.0);
  vec3 p = vec3(lp.xy / lp.w * 0.5 + 0.5, lp.z / lp.w);
  float s = 1.0;
  if (p.x >= 0.0 && p.x <= 1.0 && p.y >= 0.0 && p.y <= 1.0 && p.z >= 0.0) {
    s = shadowTap(p.xy, c, p.z + 0.0016);
  }
  return min(s, terrainShadow(wpos)) * cloudShadow(wpos);
}

// how much air there is at a height: the basin's own haze, plus a shallow mist that lies on
// the ground rather than filling the valley
float volDensity(vec3 wpos) {
  float y = wpos.y - u_fog_base;
  float air = exp(-max(y, 0.0) * u_vol_falloff);
  float mist = u_vol_mist * exp(-max(y, 0.0) / max(u_vol_mist_h, 1.0));
  return u_vol_density * (air + mist);
}

// Henyey-Greenstein: real air throws light FORWARD, which is why a low sun makes the whole
// valley glow when you look into it and almost nothing when you look away from it.
float phaseHG(float c, float g) {
  float g2 = g * g;
  float d = 1.0 + g2 - 2.0 * g * c;
  return (1.0 - g2) / (4.0 * PI * max(d * sqrt(max(d, 1e-4)), 1e-4));
}

void main() {
  float d = texture(u_depth, v_uv).r;
  // the world point this pixel looks at, and the ray to it
  vec4 far4 = u_inv_vp * vec4(v_uv * 2.0 - 1.0, DEPTH_FAR_POINT, 1.0);
  vec3 farP = far4.xyz / far4.w;
  vec3 dir = normalize(farP - u_cam_pos);
  float march;
  if (d <= DEPTH_SKY) {
    march = u_vol_far;                       // sky: march the whole way
  } else {
    vec4 h4 = u_inv_vp * vec4(v_uv * 2.0 - 1.0, depthClip(d), 1.0);
    march = min(length(h4.xyz / h4.w - u_cam_pos), u_vol_far);
  }
  int steps = int(u_vol_steps);
  float dt = march / float(steps);
  // A dither per pixel, not per frame. The shafts are composited before the temporal resolve
  // (taa.ludic) now, so a per-frame dither could be averaged; it stays fixed so the picture with
  // R3D_NOTAA is the same as it was.
  float jitter = ign(gl_FragCoord.xy);
  float ph = phaseHG(dot(dir, u_sun_dir), u_vol_g);
  vec3 acc = vec3(0.0);
  float trans = 1.0;
  for (int i = 0; i < 64; i++) {
    if (i >= steps) break;
    float t = (float(i) + jitter) * dt;
    vec3 p = u_cam_pos + dir * t;
    float dens = volDensity(p);
    if (dens > 1e-5) {
      vec4 lzAmb;
      float vis = volShadow(p, t) * (1.0 - lightZone(p, lzAmb));   // no sun shafts inside a light zone
      // in-scattering from the sun, and a little from the sky so shadowed air is not black
      // The sky's own contribution is kept SMALL and deliberately so. It is added at every
      // step, so it accumulates into a flat grey wash that lifts lit and shadowed air by the
      // same amount - which is exactly the contrast a shaft is made of. At 0.06 the valley
      // came out as one pale sheet with no rays in it at all; the sun's term has to dominate
      // or there is no light to see, only fog.
      vec3 inscat = u_sun_color * vis * ph + skyIrradiance(vec3(0.0, 1.0, 0.0)) * 0.012;
      float a = dens * dt;
      acc += inscat * a * trans;
      trans *= exp(-a);
    }
  }
  o_color = vec4(sane(acc), 1.0);
}
