# ludic ui-preview

A game's `ludic.ui` components, previewed for a studio (a UI editor) without the game: `ludic.ui`
itself, with a backend that records its draw calls instead of drawing them, and component classes
the studio describes over stdin. No game code is built, nothing touches a GPU, nothing opens a
network connection. It is the toolchain's own program, shipped prebuilt as `bin/ludic-ui-preview`.

```bash
ludic ui-preview [--font DIR] [--no-default-font]   # the host on stdin/stdout; DIR holds the game's font.json
```

**The wire protocol is [protocol-v1.md](protocol-v1.md)**, frozen: every request, every reply and
every line format. `smoke.txt` is a scripted session with what each reply must contain, and `smoke.py` runs it
(`python3 tools/ui-preview/smoke.py tools/ui-preview/smoke.txt bin/ludic-ui-preview`).

## What it does

- **Components are mocks.** `load` registers a `UiClass` named as the component, with the template
  and styles the studio sends (unsaved text is fine), or changes that class in place. Its model is
  the story's (`model`), with the props its parent's tag gives it and whatever its template `set`s
  laid over it; its functions answer from the story's table (`calls`). A component tag the studio
  has not sent yet is an empty class until it is.
- **The frame is ludic.ui's own.** `frame t` sets the interface clock to `t`, hands over the input
  the studio sent (`input ...`), and calls `ui_show`: build, cascade, layout, pointer and focus,
  draw, then the actions a press ran. The draw list is every `UiBackend` call in painting order.
- **Text is measured as the game measures it.** `font DIR` (or `--font DIR`) reads the same
  `font.json` ludic.render3d's overlay reads, and the width of a run is the overlay's sum of glyph
  advances at the font's whole-pixel size; each `text` line carries it, so the studio fits its own
  rendering to the game's line breaks.
- **No font asked for means the toolchain's.** With no `--font` the host loads the default font
  (Noto Sans, `fonts/noto-sans/baked/` under the install root: `$LUDIC_HOME`, else beside `bin/`, else
  `~/.ludic`) and `hello` reports its directory; `--no-default-font` keeps the old half-size measure
  (smoke.py uses it). A studio that knows the game's font passes `--font` or sends `font DIR`.
- **Languages** are the game's: `locale <file.po>` translates every drawn text with ludic.i18n.
- **Natives** (a radar, a dial) are game code, so a `native` line is a box for the studio to fill.
- **Inspection**: `tree`, `box <id>` (box and computed style) and `rules <id>` (the matching rules,
  each with the file and line its selector was written on).

## ludic.ui additions it relies on

All additive, and none changes what a game draws:

- `UiClass.make_of` - a constructor handed the class, so one host function makes every mock.
- `UiBackend.said` - template errors to the host instead of `print`; `UiBackend.emitted` - every
  `emit`, for the host's log.
- `UiRule.text` and `UiRule.at` - a rule's selector as written and `file:line`. A stylesheet's
  comments keep their line breaks when stripped, so lines count true; a component's own styles are
  read under its `.lss` path.
- `inspect.ludic`: `ui_root`, `ui_find`, `ui_rules_of`, `ui_rule_value`, `ui_building`,
  `ui_class_load`, `ui_file_forget`, `ui_errors_clear`; `class.ludic`: `ui_class`;
  `ui_nine_cuts_into` exported.

## Limits in v1

- An error's column is not known (`col` is 0): ludic.ui records a file and line per element and per
  rule, not a column. A malformed XML file is read leniently by the runtime's parser and does not
  report a syntax error.
- In a GAME build a component's styles have their `@import`s inlined by the compiler, so a rule's
  line there counts in the inlined text; in the host the studio sends the file as written, and
  lines are the file's.
- A declaration's value is given as written only when it is plain text; one with `{...}` holes is
  `""` in `rules` (its computed result is in `box`).
- Images are referenced, not decoded: the studio draws them from its own copies of the game's files
  and atlases, and says a picture's natural size with `image` when `object-fit` needs it.
