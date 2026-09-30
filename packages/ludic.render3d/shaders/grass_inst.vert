// grass_inst.vert - a blade grass_cull.comp has already decided on (Vulkan). Everything about the
// blade - where it stands, its facing, height, width, colour field and the ground under it - is its
// instance record; this only bends, sways, pushes and stands the vertices, as grass.vert's second
// half does, so the two draw the same meadow.
layout(location = 0) in vec3 a_pos;      // x: -0.5..0.5 across, y: 0..1 along the blade, z: bend
layout(location = 2) in vec2 a_uv;
layout(location = 3) in vec4 i_root;     // xyz the root, w the seed
layout(location = 4) in vec4 i_shape;    // sin and cos of the yaw, height, width
layout(location = 5) in vec4 i_tint;     // the colour field, and how far the tip arches
layout(location = 6) in vec4 i_ground;   // the ground's normal, and the distance it was decided at
uniform mat4 u_view;
uniform mat4 u_proj;
uniform float u_time;
uniform float u_wind;
uniform vec3 u_push;      // x, z, radius: a body standing in the grass
uniform int u_dbg;        // R3D_GRASS_DBG (2: light as ground everywhere)
out vec3 v_wpos;
out vec3 v_nrm;
out vec2 v_uv;
out float v_seed;
out vec2 v_rot;
out float v_hull;
out float v_quake;
out vec4 v_col;     // vertex colour: none here, so white (model.frag multiplies it in)
out float v_near;   // model.frag declares it; 1 = no near fade
out float v_lh;     // model.frag declares it; 1 = no low-plant occlusion
out vec3 v_tint;

void main() {
  vec2 xz = i_root.xz;
  float seed = i_root.w;
  float s = i_shape.x, c_ = i_shape.y, tall = i_shape.z, bw = i_shape.w;
  vec3 gn = i_ground.xyz;
  float dist = i_ground.w;
  vec3 p = vec3(a_pos.x * bw, a_pos.y * tall, a_pos.z * tall * i_tint.w);
  vec3 n = vec3(0.0, 0.3, 1.0);
  float ph = u_time * 1.7 + seed * 6.2831 + xz.x * 0.05 + xz.y * 0.07;
  float sway = windSway(xz, u_time, ph, 0.0) * u_wind;
  float hgt = max(p.y, 0.0);
  p.x += sway * hgt * hgt * 0.35;
  p.z += sway * hgt * hgt * 0.15 * cos(ph * 0.7);
  p = vec3(c_ * p.x + s * p.z, p.y, -s * p.x + c_ * p.z);
  if (u_push.z > 0.0) {
    vec2 away = xz - u_push.xy;
    float pd = length(away);
    float push = smoothstep(u_push.z, u_push.z * 0.2, pd);
    if (push > 0.0) {
      vec2 pdir = (pd > 1e-3) ? away / pd : vec2(1.0, 0.0);
      float bh = max(p.y, 0.0);
      p.x += pdir.x * push * bh * 1.05;
      p.z += pdir.y * push * bh * 1.05;
      p.y -= push * bh * 0.40;
    }
  }
  n = normalize(vec3(c_ * n.x + s * n.z, n.y, -s * n.x + c_ * n.z));
  vec3 k = cross(vec3(0.0, 1.0, 0.0), gn);
  float sk = length(k), ck = gn.y;
  if (sk > 1e-4) {
    k /= sk;
    p = p * ck + cross(k, p) * sk + k * dot(k, p) * (1.0 - ck);
    n = normalize(n * ck + cross(k, n) * sk + k * dot(k, n) * (1.0 - ck));
  }
  n = normalize(mix(n, gn, smoothstep(2.0, 12.0, dist)));
  vec3 w = i_root.xyz + p;
  v_wpos = w;
  v_nrm = n;
  v_uv = a_uv;
  v_seed = seed;
  v_rot = vec2(s, c_);
  v_quake = 0.0;
  v_col = vec4(1.0);
  v_near = 1.0;
  v_lh = 1.0;
  v_tint = i_tint.rgb;
  v_hull = (dist > 2.0 || (u_dbg & 2) != 0) ? -1.0 : 1.0;
  gl_Position = u_proj * u_view * vec4(w, 1.0);
}
