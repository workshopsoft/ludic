bump: minor
type: feat
**`ludic.render3d`: a rim outline on an actor.** An actor gains `outline` (metres of
rim) and `ocol` (its colour). The pass draws the model again with its vertices pushed
along their normals and its front faces culled, so only the far side of the swollen
shell survives - a silhouette exactly `outline` wide, depth-tested against the scene, so
anything standing in front of the actor hides its rim too.
