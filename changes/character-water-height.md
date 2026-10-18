bump: minor
type: feature
**`ludic.character`: the water is asked at the body's height.** `CharacterGround.water` is `(x, y, z)` now: `y` is the
body's feet (the walk's next place, the safe spot's ground), so a game whose water has levels under it (a tunnel's
tube under a bay, a deck's underside below the surface) says "no water" for a body that is sealed off from it, and the
body walks on instead of starting to swim. An unbound port is still dry; a binding that ignores `y` behaves as before.
The test world has a tube under its lake: a walk down into it never swims, the same walk beside it does.
