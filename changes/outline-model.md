bump: minor
type: feat
**`ludic.render3d`: `outline_model(model, mat, width, r, g, b)`** — a rim around something
that is not an Actor.

An Actor has had an `outline` since the outline pass landed, and everything else in a
scene had nothing: the pass walked the actor list and stopped. Instanced scatter was the
gap that mattered, because a game that highlights whatever the crosshair is on could
highlight every object in the world *except* the twenty thousand most common ones — the
trees.

`outline_model` queues a model at a transform from anywhere in the frame and the outline
pass flushes it alongside the actors', which is what gets the depth test right: the rim has
to be drawn after the scene it is tested against, and a caller does not control pass order.
A layer whose vertex shader moves its instances — wind, or standing them on the drawn
terrain — should be handed the transform that shader arrives at.
