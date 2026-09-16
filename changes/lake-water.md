bump: patch
type: fix
**A lake can be the water that mirrors the world** — a reflecting body is clipped to its
ellipse like any other unless it is an unbounded sea, so a map whose reflection belongs to
its lake no longer floods every hollow in the survey with that lake's level; and the
terrain's wet shore, forest and scree gates read the carved lake's line inside its outline
(`u_lake`), the rule the grass already used, so a lake above the sea keeps its wet bank and
no forest is painted down its bed.

`terrain_lake_carve(false)` keeps a lake's line, outline and shore but skips carving its
bed, for a height map that already carries a shaped one.
