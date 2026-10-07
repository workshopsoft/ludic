bump: patch
type: fix
**`ludic.render3d`: the grass carpet is drawn from the clumps, not their cards.** `carpet_bake` drew each card
layer's crossed card straight down, and a crossed card is two upright quads - edge-on from above, so they covered
no texel and the tile came out all zeros (a game's baked carpet was a black, transparent tile that darkened its far
ground). It now draws the model each card's atlas was baked from (`carpet_source`), with that model's own
textures, through the impostor bake program; a model layer draws its own model. A game re-runs its carpet bake.
