# Noto Sans: the toolchain's default font

A game that declares no font still draws readable text: `ludic.render3d`'s overlay (and so `ludic.ui`)
falls back to this one, and so does `ludic ui-preview` when it is started without `--font`.

- **Source**: Noto Sans, version 2.015 (`NotoSans-Regular.ttf`, `NotoSans-Bold.ttf`), from
  <https://github.com/notofonts/latin-greek-cyrillic>.
- **Licence**: SIL Open Font License 1.1, in [OFL.txt](OFL.txt). The font may be bundled with, and
  shipped in, any game; it may not be sold by itself. It keeps its licence and copyright notice.
- **Coverage**: Latin, Latin Extended-A (Turkish, Polish, Czech, ... ), Romanian comma-below letters, Greek,
  Cyrillic, and the common punctuation and symbols (`€`, `₺`, `№`, arrows, dashes, quotes).

## The baked atlas

`baked/` is `NotoSans-Regular.ttf` baked with

```bash
ludic font bake fonts/noto-sans/NotoSans-Regular.ttf -o fonts/noto-sans/baked --name "Noto Sans"
```

It is generated but committed (about 300 KB: 522 glyphs, a 2048 x 1088 RGBA atlas of 64 px cells at a
48 px em, plus `font.json` with the code points and advances), so nothing is baked on first use and a
machine with only the install needs no bake step. `ludic-dev test-fonts` re-bakes it and fails if the
committed files differ, so they cannot drift from the bake tool. The same files are in
`packages/ludic.render3d/fonts/default/`, the copy a shipped game's `.lpak` carries (the test checks
that one too).

## Using it

- `ludic ui-preview` with no `--font` reads `baked/` from the toolchain (`$LUDIC_HOME/fonts/noto-sans/baked`,
  else the install root found from the binary's own location, else `~/.ludic`); `hello` reports the directory.
- A game: `overlay_init(render3d_st, "")` (an empty font directory) loads the default. To ship its own font
  a game bakes a TTF (`ludic font bake MyFont.ttf -o assets/font`) and passes that directory. `Font.load`
  (the software renderer) takes any `.ttf` path and needs no bake.
