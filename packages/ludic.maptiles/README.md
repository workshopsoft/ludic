# ludic.maptiles

A map picture drawn from above, for a game's minimap and pause map tiles: RGB canvases of a square of the world, filled with
flat-coloured triangles (a baked mesh's top faces, by material), turned rectangles (footprints), lines, a class raster through
a palette (land use), and a hillshade of a height raster; boxed down 2 x 2 (supersampling, and each level of a tile pyramid
from the four tiles under it); written as PNG with deflate's fixed codes (flat map colours compress to a few percent).
Uses `ludic.base` and nothing else; no game words.

```ludic
import "ludic.maptiles"
let c = maptiles_canvas(512, 512, x0, z0, 0.5)    # 512 px over 256 m: supersampled
maptiles_clear(c, 0x6b8a4e)
maptiles_tris(c, xyz, 0, ntris, 0x9a9ea3)          # 9 numbers a triangle, the height ignored
let tile = maptiles_canvas(256, 256, x0, z0, 1.0)
maptiles_down(c, tile, 0, 0)
let t = maptiles_png_tables()                       # once
let z = maptiles_png_out(256, 256)                  # once a worker
let n = maptiles_png_encode(t, tile, z)             # no allocation: safe on Job.parallel_for workers
```

- A pixel is painted when its centre is inside a shape, so canvases that meet at a seam paint exactly what one canvas over
  both would (tiles have no seams at any level).
- x grows right, z grows down the picture (north, -z, up), as `ludic.minimap` draws.
- Colours are `0xRRGGBB`; `maptiles_rgb_linear` turns an actor's linear tint into the sRGB a picture holds.
