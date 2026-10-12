// oimp.vert - an octahedral impostor card for a far building (oimp.ludic is the reference of the arithmetic). One
// card a building, the same instance record as kit.vert: attribute 3 = (x, y, z, scale), 4 = (sin yaw, cos yaw, seed,
// flags), 5 = (tint r, g, b, variation). The card is a square of side 2 * radius * scale round the model's middle,
// turned to face the camera; the three frames of the atlas nearest the view direction are chosen here and blended in
// oimp.frag, each by projecting the card's point into that frame's own orthographic view. A box kit's instance
// (attribute 6, kitbox.ludic) gets a card the size of its own drawn bounds - from the kit's anchor tuples, as kit.vert
// draws it - and its points are stretched into the frames, which hold the instance the kit was baked at (u_box_ref).
layout(location = 0) in vec2 a_xy;       // [-0.5, 0.5] x [0, 1]
layout(location = 1) in vec2 a_uv;
layout(location = 3) in vec4 i_pos;
layout(location = 4) in vec4 i_rot;
layout(location = 5) in vec4 i_tint;
layout(location = 6) in vec4 i_box;      // a box kit's instance: w, d, h, radius (0: an ordinary instance)
uniform mat4 u_view;
uniform mat4 u_proj;
uniform vec3 u_cam_pos;
uniform float u_radius;                  // the card's half side, model units
uniform float u_centre_y;                // the model's middle, model units above its base
uniform float u_frames;                  // frames along one side of the atlas
uniform vec4 u_box_ref;                  // a box kit: the drawn width, depth and top its frames hold; w 0 for an ordinary kit
uniform vec4 u_kt[48];                   // its anchor tuples (kitbox_uniforms): 16 (sx, ox), 16 (sz, oz), 16 (sh, sd, oy)
uniform vec3 u_kn;                       // how many of each
out vec3 v_wpos;
out vec2 v_q;                            // the card's own (0..1, 0..1)
out vec3 v_lctr;                         // the card's point in the model's frame, relative to its middle (model units)
out vec4 v_fw;                           // the three frames' weights ...
out vec3 v_fi;                           // ... and their indices
out vec4 v_tint;
out vec4 v_rot;                          // sin cos seed flags
out vec3 v_ldir;                         // the direction to the camera in the model's frame
vec2 octEncode(vec3 d) {
  float l = abs(d.x) + max(d.y, 0.0) + abs(d.z);
  vec2 p = d.xz / max(l, 1e-6);
  return clamp(vec2(p.x + p.y + 1.0, p.x - p.y + 1.0) * 0.5, 0.0, 1.0);
}
void main() {
  float s = i_rot.x, c = i_rot.y;
  // the instance's own bounds and how a point of it maps into the frames (1 for an ordinary kit, its scale doing the rest)
  float half_side = u_radius * i_pos.w;
  float cy = u_centre_y * i_pos.w;
  vec3 toRef = vec3(1.0 / i_pos.w);
  if (i_box.w > 0.0 && u_box_ref.w > 0.0) {
    float hx = 0.0, hz = 0.0, top = 0.0;
    for (int k = 0; k < 16; k++) {
      if (float(k) < u_kn.x) hx = max(hx, abs(u_kt[k].x * i_box.x + u_kt[k].y));
      if (float(k) < u_kn.y) hz = max(hz, abs(u_kt[16 + k].x * i_box.y + u_kt[16 + k].y));
      if (float(k) < u_kn.z) top = max(top, u_kt[32 + k].x * i_box.z + u_kt[32 + k].y * i_box.y + u_kt[32 + k].z);
    }
    vec3 ext = vec3(2.0 * hx, top, 2.0 * hz);
    half_side = 0.5 * length(ext);
    cy = 0.5 * top;
    toRef = vec3(u_box_ref.x, u_box_ref.z, u_box_ref.y) / max(ext, vec3(1e-3));
  }
  vec3 centre = i_pos.xyz + vec3(0.0, cy, 0.0);
  vec3 toCam = u_cam_pos - centre;
  float dist = length(toCam);
  vec3 dir = toCam / max(dist, 1e-4);
  // the frame to look from, in the model's own frame (the instance's yaw turned out of the view)
  vec3 ld = normalize(vec3(c * dir.x - s * dir.z, dir.y, s * dir.x + c * dir.z) * toRef);
  v_ldir = ld;
  vec2 uv = octEncode(ld);
  float n = u_frames;
  vec2 g = uv * (n - 1.0);
  vec2 i0 = clamp(floor(g), vec2(0.0), vec2(max(n - 2.0, 0.0)));
  vec2 f = g - i0;
  vec2 i1 = min(i0 + 1.0, vec2(n - 1.0));
  if (f.x + f.y <= 1.0) {
    v_fi = vec3(i0.y * n + i0.x, i0.y * n + i1.x, i1.y * n + i0.x);
    v_fw = vec4(1.0 - f.x - f.y, f.x, f.y, 0.0);
  } else {
    v_fi = vec3(i1.y * n + i1.x, i1.y * n + i0.x, i0.y * n + i1.x);
    v_fw = vec4(f.x + f.y - 1.0, 1.0 - f.x, 1.0 - f.y, 0.0);
  }
  // the card faces the camera: right = normalize(cross(up, dir)), up' = cross(dir, right)
  vec3 up = abs(dir.y) > 0.999 ? vec3(0.0, 0.0, -1.0) : vec3(0.0, 1.0, 0.0);
  vec3 right = normalize(cross(up, dir));
  vec3 upv = cross(dir, right);
  vec2 q = vec2(a_xy.x + 0.5, a_xy.y);
  vec2 off = (q - 0.5) * 2.0 * half_side;
  vec3 w = centre + right * off.x + upv * off.y;
  v_wpos = w;
  v_q = q;
  // the same point in the model's frame: unrotate, then into the frames' units
  vec3 rel = w - centre;
  v_lctr = vec3(c * rel.x - s * rel.z, rel.y, s * rel.x + c * rel.z) * toRef;
  v_tint = i_tint;
  v_rot = i_rot;
  gl_Position = u_proj * u_view * vec4(w, 1.0);
}
