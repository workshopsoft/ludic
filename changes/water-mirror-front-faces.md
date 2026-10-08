bump: patch
type: fix
The lake mirrors a meadow's plants as plants, not as white blobs, and `R3D_NOREFL` turns the mirror off.

The reflection pass drew through a mirrored camera (determinant -1) and kept the right faces by culling
`GPU_FRONT`. That left every fragment it drew a back face to the rasterizer, so every shader that turns a normal
by `gl_FrontFacing` (`model.frag`, `kit.frag`) turned it the wrong way in the reflection: a two-sided tuft or
flower lit from its far side came out near white, and a hillside of them lay on the water as pale blobs. A pass
drawn through a mirror now says so (`gpu_mirror`): its pipelines take counter-clockwise front faces and cull
`GPU_BACK` as any other pass does, the same faces survive, and `gl_FrontFacing` means what it means elsewhere
(`tests/mirror_face_test.ludic`).

`R3D_NOREFL` set `r3d_no_refl`, which a game's water setting writes over when settings apply, so the switch did
nothing. It is its own field now (`r3d_env_no_refl`), read beside the game's.
