// ue_flare.vert - Unreal's lens flares (PostProcessLensFlares.usf), drawn on the card mesh (mesh_card: a_uv the quad's corner).
// u_mode 0, LensFlareBlurVS: one instance an input pixel - the pixel's colour (bilinear at its corner, DiscMask'd), its quad
// collapsed below the threshold, else KernelSize pixels wide, inside the guard band (half the target). u_mode 1, the composite:
// the quad centred and scaled by u_scale (negative mirrors it) over the bloom output.
layout(location = 0) in vec2 a_xy;
layout(location = 1) in vec2 a_uv;
uniform float u_mode;
uniform sampler2D u_src;
uniform vec2 u_src_size;          // the flare viewport (the downsample stage), pixels
uniform vec3 u_kernel;            // KernelSize, KernelAreaInverse, Threshold
uniform float u_scale;
uniform float u_exposure;         // the scene isn't pre-exposed here: Unreal's threshold applies to SceneColor x PreExposure
uniform sampler2D u_adapt;        // (last frame's exposure), the tonemapper's own
uniform float u_auto;
out vec2 v_uv;
out vec4 v_color;
// PostProcessCommon.ush DiscMask
float flareDiscMask(vec2 p) { float x = clamp(1.0 - dot(p, p), 0.0, 1.0); return x * x; }
void main() {
  v_uv = a_uv;
  if (u_mode < 0.5) {
    int w = int(u_src_size.x);
    vec2 tile = vec2(float(gl_InstanceIndex % w), float(gl_InstanceIndex / w));
    // PixelToScreenPos x GuardBandScaleInverse (a Vulkan target's row 0 is NDC y = -1)
    vec2 pos = (tile / u_src_size * 2.0 - 1.0) * 0.5;
    vec2 uv = clamp(tile / u_src_size, 0.5 / u_src_size, 1.0 - 0.5 / u_src_size);
    vec4 c = textureLod(u_src, uv, 0.0);
    c.rgb *= flareDiscMask(pos);
    float preExposure = mix(u_exposure, textureLod(u_adapt, vec2(0.5), 0.0).r, u_auto);
    float thr = dot(c.rgb, vec3(1.0)) * preExposure < u_kernel.z ? 0.0 : 1.0;
    v_color = c * u_kernel.y;
    // the corners: KernelSize pixels across
    pos += 2.0 * (a_uv - 0.5) / u_src_size * u_kernel.x * thr;
    gl_Position = vec4(pos, 0.0, 1.0);
  } else {
    v_color = vec4(0.0);
    gl_Position = vec4((a_uv * 2.0 - 1.0) * u_scale, 0.0, 1.0);
  }
}
