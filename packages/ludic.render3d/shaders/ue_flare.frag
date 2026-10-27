// ue_flare.frag - Unreal's lens flares (PostProcessLensFlares.usf): LensFlareBlurPS (the pixel's colour x the bokeh shape) and
// LensFlareCompositePS (the blur x FlareColor, masked by two discs on the screen).
in vec2 v_uv;
in vec4 v_color;
out vec4 o_color;
uniform float u_mode;
uniform sampler2D u_bokeh;
uniform sampler2D u_blur;
uniform vec3 u_flare_color;
uniform vec2 u_out_size;
float flareMask(vec2 p) { float x = clamp(1.0 - dot(p, p), 0.0, 1.0); return x * x; }
void main() {
  if (u_mode < 0.5) {
    o_color = vec4(v_color.rgb * texture(u_bokeh, v_uv).rgb, 1.0);
  } else {
    vec2 sp = gl_FragCoord.xy / u_out_size * 2.0 - 1.0;
    float m = flareMask(sp) * flareMask(sp * 0.8);
    o_color = vec4(texture(u_blur, v_uv).rgb * u_flare_color * m, 0.0);
  }
}
