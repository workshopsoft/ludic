// Depth of field, for the viewfinder. The camera mode (the game's photo mode) has had a frame,
// a zoom and a grade and no LENS: everything from the bootlaces to the Bells was equally sharp,
// which is the one thing a photograph never is.
//
// A disc of taps whose radius is this pixel's circle of confusion. It runs at full resolution
// and costs nothing when the aperture is shut, because the whole pass is skipped - in ordinary
// play there is no lens and this never draws.
in vec2 v_uv;
out vec4 o_color;
uniform sampler2D u_src;
uniform sampler2D u_depth;
uniform mat4 u_inv_proj;
uniform vec2 u_texel;
uniform float u_focus;        // metres to the plane in focus
uniform float u_aperture;     // how fast the blur opens either side of it
uniform float u_max_coc;      // in pixels, so a wide aperture cannot eat the whole frame

float viewZ(vec2 uv) {
  float d = texture(u_depth, uv).r;
  vec4 p = u_inv_proj * vec4(uv * 2.0 - 1.0, d * 2.0 - 1.0, 1.0);
  return -(p.z / p.w);
}

void main() {
  float z = viewZ(v_uv);
  // The circle of confusion, signed so the two sides of the focal plane can be told apart, and
  // normalised by the focus distance: a lens focused at two metres throws the background out
  // far harder than one focused at two hundred, and a constant here made a landscape shot read
  // as a macro.
  float coc = (z - u_focus) / max(z, 0.1) * u_aperture;
  float r = clamp(abs(coc), 0.0, 1.0) * u_max_coc;
  if (r < 0.75) { o_color = vec4(texture(u_src, v_uv).rgb, 1.0); return; }
  // a 16-point spiral, which reads as a lens rather than as a box blur
  vec3 acc = texture(u_src, v_uv).rgb;
  float wsum = 1.0;
  for (int i = 0; i < 16; i++) {
    float a = float(i) * 2.3999632;                  // golden angle
    float rr = sqrt((float(i) + 0.5) / 16.0) * r;
    vec2 off = vec2(cos(a), sin(a)) * rr * u_texel;
    vec2 uv2 = v_uv + off;
    // Do not drag a SHARP FOREGROUND pixel into a blurred background: that is the halo every
    // naive depth-of-field has round a near object. A tap only counts if it is at least as far
    // out of focus as this pixel is.
    float z2 = viewZ(uv2);
    float coc2 = abs((z2 - u_focus) / max(z2, 0.1) * u_aperture);
    float w = smoothstep(0.0, 0.35, coc2 * u_max_coc / max(r, 1e-3));
    acc += texture(u_src, uv2).rgb * w;
    wsum += w;
  }
  o_color = vec4(acc / wsum, 1.0);
}
