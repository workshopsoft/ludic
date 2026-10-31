// One step of the water interaction height field (water_fx.ludic). A small toroidal grid of the surface around the camera:
// r = height (metres, down is positive), g = velocity (metres a step), b = foam (0 .. 1), a unused.
//
// The mechanism is Unreal 5.8's Water Advanced shallow water interaction (Plugins/Experimental/WaterAdvanced: ShallowWaterSubsystem.cpp
// snaps a Niagara Grid2D simulation of FShallowWaterSimParameters.WorldGridSize at ResolutionMaxAxis texels to the cursor pawn each tick,
// feeds its bodies and RegisterImpact(position, velocity, radius) calls to the sim through the NDC_ShallowWater data channel as
// position / velocity / radius, writes NormalAndHeight into a render target, and tells the water material the grid's centre through
// the SimLocation parameter): the same here, with the damped wave equation Grid2D_SW steps, the bodies and impacts as stamps (u_st0,
// u_st1), and water.frag reading the result as a normal offset and a foam term.
in vec2 v_uv;
out vec4 o_color;
uniform sampler2D u_prev;
uniform float u_n;              // texels a side (the grid is square, and wraps)
uniform float u_dx;             // metres a texel
uniform vec2 u_center_tex;      // the window's centre texel in the torus (an integer value)
uniform vec2 u_center_r;        // the same texel's place in render space, metres
uniform float u_k;              // (c dt / dx)^2: the wave speed's square in texel steps, under 0.5 for the scheme to hold
uniform float u_damp;           // velocity kept a step (1: none)
uniform float u_foam_keep;      // foam kept a step
uniform float u_stamps;         // stamps this step (0 on the steps after the first)
uniform vec4 u_st0[48];         // x, z (render space), radius, height pushed down (metres)
uniform vec4 u_st1[48];         // velocity pushed down (metres a step), foam, 0, 0

vec4 at(ivec2 p) {
  int n = int(u_n);
  return texelFetch(u_prev, ivec2((p.x % n + n) % n, (p.y % n + n) % n), 0);
}

void main() {
  ivec2 ij = ivec2(gl_FragCoord.xy);
  int n = int(u_n);
  vec4 c = at(ij);
  vec4 l = at(ij + ivec2(-1, 0));
  vec4 r = at(ij + ivec2(1, 0));
  vec4 d = at(ij + ivec2(0, -1));
  vec4 u = at(ij + ivec2(0, 1));
  // the texel's offset from the window's centre (the torus wraps: the nearest copy), and its place in the world
  vec2 rel = mod(vec2(ij) - u_center_tex + 0.5 * u_n, u_n) - 0.5 * u_n;
  vec2 wp = u_center_r + rel * u_dx;
  float h = c.r;
  float v = c.g;
  // the wave equation: the surface is pulled toward the mean of its neighbours, the motion is damped
  v += u_k * (l.r + r.r + d.r + u.r - 4.0 * h);
  v *= u_damp;
  h += v;
  // what the window is about to meet is nothing: the rim takes the motion off, so a texel the window moves over holds none of the far
  // side's, and no wave goes round the torus
  float rn = max(abs(rel.x), abs(rel.y)) / (0.5 * u_n);
  float rim = 1.0 - 0.45 * smoothstep(0.72, 0.98, rn);
  h *= rim;
  v *= rim;
  // foam spreads a little and dies
  float f = (c.b * 4.0 + l.b + r.b + d.b + u.b) * (1.0 / 8.0) * u_foam_keep;
  // the bodies and impacts of this frame
  int ns = int(u_stamps);
  for (int i = 0; i < ns; i++) {
    vec4 a = u_st0[i];
    vec4 b = u_st1[i];
    float dist = length(wp - a.xy);
    if (dist < a.z) {
      float k = 0.5 + 0.5 * cos(3.14159265 * dist / a.z);
      h += a.w * k;
      v += b.x * k;
      f += b.y * k;
    }
  }
  // a number that would end as nothing is nothing (half floats do not decay to zero by themselves)
  if (abs(h) < 0.00004 && abs(v) < 0.00002) { h = 0.0; v = 0.0; }
  if (f < 0.004) { f = 0.0; }
  o_color = vec4(clamp(h, -0.5, 0.5), clamp(v, -0.2, 0.2), clamp(f, 0.0, 1.0), 0.0);
}
