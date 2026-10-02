bump: minor
type: feat
**render3d: blended actors - smoke, a shield's bubble, an additive glow.** An `Actor` takes `blend`
(`ACTOR_OPAQUE` 0, as before; `ACTOR_ALPHA` 1, laid over the scene; `ACTOR_ADD` 2, added to it), `alpha`
(times the material's own alpha, its texture's included), `soft` (metres of soft-particle fade against the
scene's depth), `unlit` (base colour x emissive, no light) and `blend_casts`. Blended actors are drawn by
`r3d_frame` in a pass of their own after the opaque scene and the water and before bloom and the tonemap:
depth-tested, writing no depth, "over" sorted far to near (premultiplied), additive after, lit with the same
sun, shadow, sky light and fog as opaque actors (an additive one dimmed by the air rather than fogged), a
closed shape drawn inside then outside. They cast no shadow by default and are skipped by the opaque, shadow
and reflection passes. Nothing is made per frame. `packages/ludic.lab/example/blend.ludic` shows them.
