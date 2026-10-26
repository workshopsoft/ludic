// A MetaHuman's eye occlusion shell (actor.ludic actor_draw_shells): Epic's M_eye_occlusion_unified (MI_eye_occlusion_unified's values)
// on the thin mesh laid over each eye's opening. Unlit and opaque over what the scene drew: the scene's own colour under it, blurred by
// 16 taps toward the lids (the blur's reach the lids' distance in the shell's UV: u across the eye, v up it), then darkened and tinted
// toward the lids. The scene colour is the opaque frame copied before the shells (post_capture_scene).
in vec3 v_wpos;
in vec2 v_uv;
out vec4 o_color;
uniform sampler2D u_scene;
uniform vec2 u_screen;
uniform mat4 u_view;
uniform float u_tan_half;         // tan of half the horizontal field of view (ViewProperty TanHalfFieldOfView)

const float BLUR_SIZE = 0.13;
const vec3 BLUR_COLOR = vec3(1.0, 0.904661, 0.896269);
const vec3 SHADOW_TINT = vec3(0.901042);
const float SHADOW_MULTIPLY = 0.25;
// the masks' radius and hardness: outer (u 0), inner (u 1), bottom (v 1), top (v 0)
const vec4 BLUR_R = vec4(0.319, 0.2988, 0.262401, 0.33);
const vec4 BLUR_H = vec4(0.667, 0.8038, 0.73403, 0.78);
const vec4 BLURB_R = vec4(0.088, 0.173, 0.1408, 0.11);
const vec4 BLURB_H = vec4(0.114, 0.5333, 0.3264, 0.523);
const vec4 SHADOW_R = vec4(0.0, 0.274399, 0.0, 0.7504);
const vec4 SHADOW_H = vec4(0.0, 0.708, 0.0, 0.4864);
const vec4 SHADOWB_R = vec4(0.102, 0.2044, 0.05, 0.1844);
const vec4 SHADOWB_H = vec4(0.0, 0.382406, 0.0, 0.0);

// Unreal's SphereMask on one axis: saturate((1 - distance / radius) / (1 - hardness))
float sphereMask(float a, float b, float r, float h) {
  return clamp((1.0 - abs(a - b) / max(r, 1e-5)) / max(1.0 - h, 1e-5), 0.0, 1.0);
}
// the product of the four lids' (1 - mask)
float lids(vec2 uv, vec4 r, vec4 h) {
  return (1.0 - sphereMask(uv.x, 0.0, r.x, h.x)) * (1.0 - sphereMask(uv.x, 1.0, r.y, h.y))
       * (1.0 - sphereMask(uv.y, 1.0, r.z, h.z)) * (1.0 - sphereMask(uv.y, 0.0, r.w, h.w));
}

void main() {
  vec2 suv = gl_FragCoord.xy / u_screen;
  float depthCm = max(-(u_view * vec4(v_wpos, 1.0)).z, 0.01) * 100.0;
  vec2 k = vec2(0.2 / (u_tan_half * depthCm) * BLUR_SIZE);
  const vec2 taps[16] = vec2[16](vec2(0.4036, -0.7935), vec2(0.373, -0.273), vec2(-0.041, -0.597), vec2(-0.37093, -0.918),
    vec2(-0.379, -0.335), vec2(-0.3154, 0.107), vec2(-0.767, -0.614), vec2(-0.487, 0.639), vec2(0.236, 0.151), vec2(0.031, 0.731),
    vec2(-0.823, -0.106), vec2(-0.8732, 0.303), vec2(0.927, -0.116), vec2(0.698, 0.377), vec2(0.824, -0.515), vec2(0.508, 0.753));
  vec3 blur = vec3(0.0);
  for (int i = 0; i < 16; ++i) blur += textureLod(u_scene, suv + taps[i] * k, 0.0).rgb;
  blur = blur / 16.0 * BLUR_COLOR;
  vec3 scene = textureLod(u_scene, suv, 0.0).rgb;
  float blurAmt = 1.0 - clamp((1.0 - lids(v_uv, BLURB_R, BLURB_H)) + lids(v_uv, BLUR_R, BLUR_H), 0.0, 1.0);
  vec3 col = mix(scene, blur, blurAmt);
  float sh = clamp((1.0 - lids(v_uv, SHADOW_R, SHADOW_H)) * lids(v_uv, SHADOWB_R, SHADOWB_H), 0.0, 1.0);
  sh *= sh;
  col *= mix(vec3(1.0), SHADOW_TINT, sh) * mix(1.0, 1.0 - SHADOW_MULTIPLY, sh);
  o_color = vec4(col, 1.0);
}
