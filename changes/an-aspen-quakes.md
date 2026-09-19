bump: minor
type: feat
An aspen leaf hangs on a flattened stalk and turns in air a spruce never feels, and the
kit had no way to say so. `layer_flutter(l, v)` gives a scatter layer a per-leaf tremble:
the vertex stage offsets each leaf by a phase taken from its own place on the card, so
neighbouring leaves are never in step, and writes the result out as a varying the
fragment stage uses to flash the leaf's pale underside as it turns. The flash is the part
that reads - a still frame of a tremble is a still frame of nothing. One uniform, one
varying, no extra pass, and every other layer leaves it at zero.

Also fixes the sway itself, which was measured in METRES: `hgt * hgt * 0.35` is right for
a 40 cm flower and puts ten metres of sideways into a 14 m trunk, so every tall tree in
the valley stood bent over like a fishing rod. It is a fraction of the model's own height
now, so the tip moves a few per cent of the tree whatever the tree is and the base does
not move at all.
