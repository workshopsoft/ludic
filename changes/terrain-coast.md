bump: minor
type: feat
**`ludic.render3d`: `terrain_coast(cx, cz, margin, fall)`** — the other way to make an
island, and the one a real survey wants: the sea goes around the survey's **own edge**
rather than being cut out of the middle of it.

`terrain_island` measures a radius out from a centre, which suits a made-up map and
drowns most of a real one — an 8 km mountain survey loses two thirds of itself to make an
island of the rest. `terrain_coast` measures inward from the boundary instead: everything
the data covers stays land, the outer `margin` metres go under water, and the `fall` metres
inside that are scaled down into it. The band is wobbled by low-frequency noise, so what
comes out is headlands and bays rather than the square the data arrived in.

Both modes also gained a **strand**. Scaling alone hands a 500 m mountainside a 40-degree
plunge into the sea, which is a cliff coast and nothing else; the last few metres of height
either side of the water line are now compressed, which stretches them out horizontally
into beach and shallows. Inland lakes are untouched — they have their own bed.
