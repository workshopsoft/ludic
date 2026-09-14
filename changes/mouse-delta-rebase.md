bump: patch
type: fix
**`Input.mouse_dx` / `mouse_dy` no longer jump on the first frame or when the cursor mode changes.**
The delta was the position minus the previous frame's, and the previous position started at 0,0,
so the first frame reported the cursor's whole distance from the corner as motion, and switching
between a locked cursor's virtual reticle and the real cursor did the same. A camera that adds
`mouse_dy` to its pitch came up pointing at the ground with nobody touching the mouse. Both frames
now report no motion; every other frame is unchanged, windowed or headless, on macOS and Windows.
