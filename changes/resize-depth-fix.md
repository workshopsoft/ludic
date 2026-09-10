bump: patch
type: fix
**Resizing the window (or entering fullscreen) no longer empties the world.** It left
`gl error 1286` — `GL_INVALID_FRAMEBUFFER_OPERATION` — on every frame from there on, with
the terrain, the trees, the grass and the water gone and only the sky drawn.

The sun-visibility pass added in `changes/terrain-perf.md` borrows the depth buffer the
frame is about to be drawn with, so that rasterising it doubles as a depth prepass. It
was storing that borrowed texture in its `Target`, and a `Target` deletes whatever its
`depth` names when it is freed. On the first resize the sequence was: `post_free` deletes
the frame's depth texture, `post_init` immediately makes the replacement — and GL hands
back the name that was just freed — and then the visibility target, rebuilt for the new
size, deleted that name believing it was its own. The scene framebuffer lost its depth
attachment. What is left is a colour-only framebuffer, which is *complete*, so drawing
carried on with no depth test at all: the sky is a fullscreen quad drawn last, and with
nothing left to fail against it painted over the entire valley. The 1286s came from the
passes whose own attachment now named a texture that no longer existed.

A borrowed attachment is never written into the target now, and the frame's depth is
attached afresh at the start of each pass — it is a different texture every time the
screen-sized buffers are rebuilt, and one `glFramebufferTexture2D` per pass is cheaper
than any scheme for noticing that it changed.

`R3D_RESIZE_AT=<frame>` rebuilds every screen-sized buffer from that frame on, cycling
through four drawable sizes every few frames. A window cannot be resized in a headless
run, so this is the only way to reach the path; it reproduced the fault in one frame and
now runs twenty resizes, with the fly camera and with the game, without an error.
