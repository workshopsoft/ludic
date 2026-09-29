bump: minor
type: feature
**`ludic ui-preview`: a game's ludic.ui components previewed for a studio, over stdio.** A new
prebuilt tool (`bin/ludic-ui-preview`, built by `ludic-dev build` and shipped beside `ludic-lsp`) that
is ludic.ui with a backend that records every draw call as a line of text, and component classes the
studio describes: their template and styles (`load`, unsaved text welcome), their model (`model`),
their functions' answers (`calls`). `frame t` runs ludic.ui's own frame - build, cascade, layout,
input, draw - at interface time `t` and writes the draw list, then what happened (template errors
with file and line, calls, sets, emits, sounds); text is measured with the game's `font.json`
metrics on the CPU, translated through ludic.i18n with `locale`, and `tree` / `box` / `rules`
inspect the frame, rules with the file and line they were written on. No game code, no GPU, no
network. The wire protocol is frozen as `tools/ui-preview/protocol-v1.md`. ludic.ui gains what it
needs, all additive: `UiClass.make_of`, `UiBackend.said` / `emitted`, `UiRule.text` / `at`, and
`ui_root`, `ui_find`, `ui_rules_of`, `ui_class`, `ui_class_load`, `ui_file_forget`,
`ui_errors_clear`, `ui_building`.
