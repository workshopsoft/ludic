bump: patch
type: feature
**ludic.lab: 16-bit PNGs** — `lab_png_write16_from(st, path, w, h, channels, px, at)` writes 16-bit samples (two bytes each, most significant first) the way `lab_png_write_from` writes 8-bit ones, so a test can write a height map render3d's decoder reads back as R16; `lp_png_bytes(stride, h)` is the size of one.
