bump: patch
type: fix
**`col_resolve` no longer throws a body across the map when it starts dead centre on a
collider.** The degenerate branch — a point exactly on a circle's axis, where there is
no direction to push it — chose a unit normal `(1, 0)` and then divided it by the
clamped `d = 0.001` anyway, along with the real normals. The push came out a thousand
times too large: a body standing exactly on a 0.5 m trunk was moved about 800 m instead
of the 0.85 m that clears it.

Off-centre the arithmetic was correct, and off-centre is how anything arrives at a
trunk while walking, so it never showed up in play — only a teleport, a spawn or a
world generator placing something on an existing collider could land on the axis.

`(ex, ez) / d` is always a unit vector for `d > 0`, because `d` is its own length: there
was never anything to clamp. The normal is now built once, explicitly, and the clamp is
gone.
