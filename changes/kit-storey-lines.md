bump: minor
type: feat
**Storey lines on kits: a line across the walls every `storey_h` metres of height.** A `RenderKits` row with `storey_h` (metres, 0 = none)
and `storey_line` (thickness, 0.12 m) has `kit.frag` darken a thin band at every multiple of `storey_h` above the instance's base on
every upright face, so a box kit of 3 floors and one of 72 show the same lines (they count height in metres, not texture coordinates, and
a box instance's scale never stretches them). Faces that look up or down have none, and a line thinner than a pixel fades out instead of
shimmering. `kgpu_kit_storey(g, id, h, line)` sets it on the GPU kit (`bw_setup_kits` does it from the row), `kitbake_storey(kb, id, h, line)`
writes it into the rows of a bake. `kit.vert` gains an output `v_h` (the height above the instance's base). Shaders rebuilt
(`ludic-dev shaders`). The impostor cards and HLOD proxies are baked without lines.
