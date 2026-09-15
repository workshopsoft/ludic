bump: minor
type: feat
**A loading screen can show the renderer's start-up as it happens.** `r3d_open(w, h, title)` opens
the window and the graphics backend with nothing baked, and `r3d_load_count()` / `r3d_load_step(i)`
run the rest - the sky and its light, the terrain, the shadow and screen targets, the scattered cover
and actors, the grass - one step at a time, so a game can draw and present a frame between them.
`r3d_init` is those same calls in a row and is unchanged for everything that uses it.
