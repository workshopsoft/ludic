bump: minor
type: feat
**HLOD proxies in the colours of the buildings they stand for.** A far block drew every proxy box in one hand-set grey
(`proxy_r/g/b`, 0.55 by default) on its walls and its roof alike, so past the full-detail radius the city went almost white
(a lit roof of 0.55 where the kit's roof is 0.11). Now:
- `RenderKit` has `proxy_roof` and `proxy_roof_r/g/b`: the roof of its HLOD box has its own colour (rows without them draw as
  before, walls and roof one colour).
- `kit_proxy_read(render3d_st, dir, file, node, kit)` (kitbox_read.ludic, CPU, no device) derives both from the kit's own mesh:
  every triangle in its material's base colour, the walls weighted by what a side view sees (area times the horizontal part of
  the normal), the roof by what a view from above sees (area times the upward part). Textured or vertex-coloured kits are left
  as their row says. The pure arithmetic is `hlod_colour_tri` / `hlod_colour_apply` (hlod.ludic).
- `hlod_prism_roof(m, px, pz, y0, y1, wall, roof)`; `hlod_prism` is unchanged (one colour). A merged box's colours are its
  members' weighted by their wall area and their plan (a door no longer counts as much as the building it is on).
- `kitbake_rows` writes the proxy colours when they are not the defaults.
Rebake the cells' `.lwh` (and the rows) after updating to get the new colours.
