bump: minor
type: feat
**`ludic.render3d`: a map's clearings, edits and hero things as rows over its painted ground.**
Paint stays the forest; a row exists only where a designer said something. Four `@PerMap` registries sit beside
`ground_layers.lres` (`ground_rows.ludic`): `GroundClearings` (areas) and `GroundStrips` (trails), handed over
with `ground_clearings_use`, thin every trampled layer - a polygon by the even-odd rule, a strip within half its
width of the centre line, each back to full across `feather` on the disc's smoothstep (`ground_clear_shape.ludic`;
`r3d_ground_clearing_area` / `_strip` are the verbs, and discs still work). `GroundEdits` names a grown solid thing by
its id and says how it differs - removed, moved, turned, resized, grown as another kind - and applies as the thing
grows, so the list, the draw and everything keyed by id agree; `GroundHeroes` places solid things by hand, listed
with the layer whose new `GroundFill.kind` is theirs, in the chunk they stand in, ids in layer 63's range
(`ground_hero_id`, which `ground_solid_id` no longer gives). `ground_edits_use` takes both at a map's load and
prints once each row it cannot honour (a thing that no longer grows, an id edited twice, a kind no layer grows).
Outside every clearing and edit the same candidates stand with the same numbers: the golden's earlier sections are
unchanged, and it gains `clearing_shapes` (289 probes) and `edits` (five edits, two heroes, three chunk lists).
`studio.lres` shows the clearings, strips and heroes; `GroundSolids` carries each thing's `cells`.
