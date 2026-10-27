# Tiled golden fixtures

The curated, version-pinned corpus for the Ludic Tiled reader (design record:
[Design: Tiled maps](https://github.com/workshopsoft/ludic/wiki/Design%2FTiled),
issues #67–#74). No single Tiled file covers the format surface, so this is a
subset of the official [`mapeditor/tiled`](https://github.com/mapeditor/tiled)
`examples/` tree plus a few hand-authored files for the gaps the official
examples miss.

## Vendored from mapeditor/tiled (`examples/`)

Fetched from `https://raw.githubusercontent.com/mapeditor/tiled/master/examples/`.
Tiled's example assets carry their own licenses (see the upstream repo's
per-folder `*.license`/README); vendored here with attribution for testing only.

| File | Exercises |
|---|---|
| `desert.tmx` + `desert.tsx` | orthogonal, external `.tsx`, base64+zlib (P0/P1) |
| `sewers.tmx` | orthogonal, base64+zlib, embedded tileset, opacity (P0) |
| `orthogonal-outside.tmx` | object layers, shapes, custom properties (P4) |
| `perspective_walls.tsx` | per-tile bool properties, `<tileoffset>` (P4) |
| `isometric_grass_and_water.tmx` | isometric orientation, Wang set (P5) |
| `hexagonal-mini.tmx` | hexagonal orientation (P5) |

## Hand-authored (CC0 / public domain)

| File | Exercises |
|---|---|
| `handmade.tmx` + `handmade.tsx` | a 4×4 orthogonal map whose four layers carry the **same** GID array in CSV, base64-uncompressed, base64+gzip and base64+zlib — so every encoding path must decode identically. The last tile is GID 1 with the horizontal-flip flag (`0x80000001`), forcing real GID decode. `handmade.tsx` also carries a `solid` bool property and a per-tile `<objectgroup>` collision shape for P2. |
