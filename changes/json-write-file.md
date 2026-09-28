bump: minor
type: feature
**`Json.write_file(value, path)` saves without keeping anything.** It writes the text
`Json.encode` would give straight to the file (through `path.tmp` and a rename), built in a buffer
the runtime keeps, so a game that saves often holds nothing more for it. `Json.encode` itself is
built the same way and makes only the string it returns: it used to join its text with `+`, keeping
every piece and every number's text. `examples/lang/json_saves.ludic`: 1000 saves, 0 bytes.
