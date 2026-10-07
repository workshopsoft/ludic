bump: minor
type: feature
**`ludic.render3d`: the forest past the fog wall.** The trees are grown only inside the wall's reach, so past it
the slopes the land now draws through read as bare ground. A `GroundLayer` row may now say how much of the
ground its crowns roof from afar (`canopy`, a share per unit of its mean density) and their colour (`canopy_r`,
`canopy_g`, `canopy_b`, linear). At a map's open `ground_canopy_build` folds those rows' painted densities into
one sRGB texture of the map (8 m texels, spread over 40 m, alpha the share roofed; 1024 x 1024 on an 8 km map,
43-70 ms), and `terrain.frag` lays it over the ground where the wall's dissolve takes the trees (`u_fog_cut`):
stands and glades from the densities and a 100 m field, and while a pixel is smaller than a crown, a crown on
a jittered 5 m grid as a dome lit on its sun side with its gaps in shade (`canopyOver`, `crownCell`). It reads
only while the land draws through a wall (`u_canopy_on`); with no wall nothing changes. New:
`ground_canopy.ludic` (`ground_canopy_build`, `ground_canopy_sums`, `ground_canopy_side`, `ground_canopy_free`,
freed by `ground_density_close`), `ground_canopy_tex.ludic`, `tests/ground_canopy_test.ludic`;
`R3D_NOCANOPY=1` builds none. Maroon Lake at fog 4 (175 m): median frame +0.07 ms at the Bells view, +0.1 ms at
the camp (six interleaved runs each); fog 9 pixel-identical.
