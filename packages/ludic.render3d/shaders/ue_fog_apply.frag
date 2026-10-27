// The fog (ue_fog.frag's target) laid over the scene as Unreal's fog pass blends it: scene x a + rgb (blend ONE, SRC_ALPHA).
in vec2 v_uv;
out vec4 o_color;
uniform sampler2D u_src;
void main() { o_color = texture(u_src, v_uv); }
