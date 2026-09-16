bump: minor
type: feat
`package.ludic` gains `entry`, scripts and lifecycle hooks:
- `entry "src/game.ludic"` names the program `ludic run`/`build`/`bundle` compile. Without
  it, the one file under `src/` that declares a `program` is used.
- `script "dev" "ludic run --headless"` defines a command: `ludic dev` (or `ludic script dev`)
  runs it with any extra arguments, and `ludic scripts` lists them.
- `hook before|after <command> "…"` wraps `build`, `run`, `test`, `bundle`, `pack`, `get`, …
  or a script. A failing `before` hook stops the command; `after` hooks run only on success.
- Quoted manifest values accept `\"` and `\\` escapes.
