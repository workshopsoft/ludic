bump: minor
type: feat
ludic.render3d: `model_from_arrays` makes a Model from vertex, colour and index arrays a game worked out (a decal laid on a wall's triangles, a muzzle's star, a streak), so a game draws a shape of its own through the actor pass without touching a pointer. One primitive in the plain white material; the vertex colour shapes the colour and, for a blended actor, the alpha. `model_release` gives it back.
