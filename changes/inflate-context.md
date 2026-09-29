bump: minor
type: feature
**Inflate in a caller-owned context.** `ZInflate` holds everything one inflate works in - the bit reader,
the RFC's length and distance tables, and every Huffman table and scratch list a block builds - made once
by `z_inflate_new()` and rebuilt in place, so an inflate allocates nothing and each thread that inflates
holds a context of its own. `z_inflate_in(z, src, len, out, cap)`, `z_uncompress_in` (zlib) and
`z_gunzip_in` (gzip) take the context; `z_inflate` / `z_uncompress` / `z_gunzip` keep their signatures,
working in the one context `RtInflateState` holds, so no caller changes.
