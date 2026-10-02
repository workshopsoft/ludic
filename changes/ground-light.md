bump: patch
type: fix
**`ludic.render3d`: the sky's light from below the horizon is the scene's own ground, and a surface tilted
down still sees its share of the sky.** `skyIrradiance` and `skyPrefiltered` tinted the ground half of the
IBL with a private olive constant, so a stage on a grey plate was lit from a lawn; they read `u_ground_alb`
now (the same colour the sun's bounce uses, bound with the IBL in `sky_bind_lighting`), whose default is
that constant, so nothing changes unless a scene says what it stands on with the new
`r3d_ground_albedo(r, g, b)`. And the sky/ground split never gives a normal less sky than its view factor,
`(1 + n.y) / 2`: the old window cut the sky to nothing by `n.y = -0.25`, so every jaw, neck and hanging arm
was lit by the ground alone and a pale skin came out olive. Upward and level normals are unchanged.
`ludic.lab`'s plate says its ground is the plate (its texture's mean linear albedo).
