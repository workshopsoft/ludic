bump: minor
type: feature
**`ui_override(path, text)`: a template or stylesheet given from outside.** From then on a read of `path` answers
`text`; a component whose template or stylesheet it is swaps its own and is shown again with its state kept,
and an importer reads the new text. `ui_override_clear(path)` (or `""` for every one) brings the file back,
and `ui_overridden(path)` says whether one stands. A developer build's disk polling leaves an overridden
component alone. For a studio editing a running game's interface (devlink's `ui_override`); a game that
overrides nothing pays a length check per file read.
