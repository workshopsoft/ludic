bump: minor
type: feat
**Storey lines on kits: a line across the walls every `storey_h` metres of height.** A `RenderKits` row with `storey_h` (metres, 0 = none)
and `storey_line` (thickness, 0.12 m) has `kit.frag` darken a thin band every `storey_h` metres on every upright face, so a box kit of 3 floors and
one of 72 show the same lines (they count height in metres, not texture coordinates, and a box instance's scale never stretches them). A box
instance's lines hang from its top (its own `h`, the eave) down, so a plinth under the building shifts nothing: they are every storey up from its
pad and the last is the eave; another kit's count up from its base. Faces that look up or down have none, and a line thinner than a pixel fades out instead of
shimmering. `kgpu_kit_storey(g, id, h, line)` sets it on the GPU kit (`bw_setup_kits` does it from the row), `kitbake_storey(kb, id, h, line)`
writes it into the rows of a bake. `kit.vert` gains outputs `v_h` (the height above the instance's base) and `v_top` (a box instance's `h`, -1 for another). Shaders rebuilt
(`ludic-dev shaders`). The impostor cards and HLOD proxies are baked without lines.
