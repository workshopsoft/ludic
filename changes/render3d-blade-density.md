bump: minor
type: feature
**`ludic.render3d`: the GPU blades grow where a painted density says.** `grass_density_layer(l)` names a layer of
the ground densities (`ground_density_open`: the same 2 m texel, 64 m tiles, bake and dev fallback) as the
blades'; `grass_cull.comp` then keeps a blade by that density, bilinear, where it used to apply its rules (the
slope, the water's margin, the snow line, the photograph). Without one, nothing changes. The cull reads a
window of 5 x 5 density tiles round the camera (160^2 bytes, a host-visible storage buffer, re-filled from
the CPU tile cache when the camera crosses a 64 m tile), never the whole map. `grass_rule_at(x, z)` is the
rules on the CPU, for a migration that paints them; `grass_density_texels()` the side a density PNG has.
