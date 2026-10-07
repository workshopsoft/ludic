bump: patch
type: fix
The lake mirrors what stands in it, and its shore stays on the shore.

`water_reflect_visible` judged a 32 m cell of water by five points - its centre and four near
the corners - and skipped the reflection pass when every one was dry, off the frame or behind
the ground. Wading off a dock, the water between the eye and the bank lies between those five:
two were behind the camera and the rest on the bank, so the pass was skipped while the lake filled
half the frame, and the surface mirrored the bare sky over everything under it - a wader's legs
became a pale ghost and every fish a pale blob. A cell the camera is in or beside (within a cell's
width) is now also walked on an 8 x 8 grid before it is called hidden
(`tests/water_reflect_test.ludic`).

`water.frag` keyed its shore terms - the wash, the lap and the soft edge that hides where the plane
cuts the bank - on whatever the scene depth found under the surface. A fish 20 cm down or a pair
of wading legs is not the bank: the shoreline's foam was laid over them and a shallow fish lost the
surface entirely. Where the depth stands clear of the ground the terrain draws there (the paged
height, read as `terpage.glsl` reads it), those terms read the bed under the pixel instead; the
light to the object is still attenuated over its own depth.
