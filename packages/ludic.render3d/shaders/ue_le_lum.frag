// ue_le_lum.frag - Unreal's SetupLogLuminanceCS (PostProcessLocalExposure.usf): log2 of the half-resolution scene's luminance
// (CalculateEyeAdaptationLuminance), the input of local exposure's blurred luminance (blurred with ue_blur.frag)
in vec2 v_uv;
out vec4 o_color;
uniform sampler2D u_scene;
uniform float u_lod;
uniform float u_lum_min;
const vec3 LUMA = vec3(0.2126390059, 0.7151686788, 0.0721923154);
void main() {
  vec3 c = textureLod(u_scene, v_uv, u_lod).rgb;
  o_color = vec4(log2(max(dot(c, LUMA), u_lum_min)), 0.0, 0.0, 1.0);
}
