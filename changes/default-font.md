bump: minor
type: feat
**A default font, and `ludic font bake`.** The toolchain now ships Noto Sans (SIL OFL 1.1; Regular and
Bold TTFs, the licence and a README under `fonts/`, in the install and the release tarball like
`templates/`). A game that names no font - `overlay_init(st, "")` - draws `ludic.ui` text with it
instead of nothing, and `ludic ui-preview` started without `--font` measures with it (`hello` reports
its directory; `--no-default-font` keeps the old half-size measure; the protocol's line formats are
unchanged). `ludic font bake <ttf> [-o DIR] [--size N] [--chars SPEC]` (a new `bin/ludic-font-bake`)
bakes any TrueType font into the `font.json` + `font.png` atlas the overlay and the preview read, with
the runtime's own rasteriser: Latin, Latin Extended-A, Greek, Cyrillic and common punctuation by
default, a glyph the font lacks left out. The default font is baked and committed
(`fonts/noto-sans/baked/`, about 300 KB), so there is no bake on first use; `ludic-dev test-fonts`
keeps it in step with the tool.
