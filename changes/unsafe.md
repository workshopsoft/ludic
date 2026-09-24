bump: minor
type: feature
**Memory is safe unless it says `unsafe` (L7).** `words(n)`, `floats(n)`, `fixeds(n)`, `doubles(n)`
and `pointers(n)` are bounds-checked, zero-filled slices now, and the type names mean those slices;
`buffer(n)` is a `[]byte`, with `text_of`, `Fs.read_bytes`, `Fs.write_bytes` and `view(xs, start,
count)` beside it. `bytes(n)`, indexing a raw pointer, `free`, `resize`, `Memory.*`, the raw file
calls, `data_of` and calling a C `extern` are refused outside `unsafe { }` / `unsafe function`, and
a project's own files may write `unsafe` only with `--unsafe`; the runtime and packages are the
platform and are unsafe throughout. A slice passed to an extern goes as its data.

Making the buffers slices found, and this release fixes: `Sync`'s atomics operating on a slice's
header rather than its cell; `words(n)` handing back uninitialised memory; `input.ludic` keeping a
stick's fixed axes in an int buffer; truetype's fixed outlines allocated as ints; skinning's float
matrices typed as ints. Rendering is byte-identical, and a frame costs the same.
