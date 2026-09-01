bump: minor
type: feat

**Tiled map support (#67–#74)** — load and draw [Tiled](https://www.mapeditor.org/) maps (TMX/TSX/TX and TMJ/TSJ/TJ), the design record from #66.

- **P0 parsing primitives (#67)** — a minimal pure-Ludic XML reader (`Xml.*`) for the element/attribute/CDATA subset TMX/TSX/TX use; standard base64 decode/encode (`Base64.*`, RFC 4648), whose decoder ignores the whitespace Tiled wraps into `<data>`; and gzip framing (`z_gunzip`, RFC 1952) wrapping the existing DEFLATE inflater. zlib and the JSON reader already shipped. A curated, attributed golden corpus lands under `assets/tiled-fixtures/`.
