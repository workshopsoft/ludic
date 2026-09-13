bump: minor
type: feat
**Overlay text is UTF-8, and a font atlas can carry any script** — `ludic.render3d`'s `ov_text`,
`ov_text_w` and `ov_text_wrap` decode UTF-8 instead of drawing bytes 32–126, so a game can show
Turkish, German, Polish, Greek, Cyrillic or whatever its atlas holds.

- `font.json` may list the atlas's code points in `"codes"` (atlas order). An atlas without it is
  read as before: consecutive code points from `"first"`, so existing ASCII fonts keep working.
- A code point the atlas lacks draws as `?`; a control character as a space; a malformed or
  cut-off sequence as one `?`, so a string sliced mid-character still draws.
- `overlay_font(dir)` loads or swaps the atlas at run time, for a language that brings its own font.
