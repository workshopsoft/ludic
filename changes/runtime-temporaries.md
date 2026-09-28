bump: patch
type: fix
**The runtime's text builtins keep nothing a call does not hand back.**
- `Log.*` builds nothing below the threshold (as documented) and frees the line it writes; a number
  field's text and a made message go too. A `Log.debug` in a frame loop left its line every frame.
- `DateTime.format` frees each field's digits and each piece joined so far.
- `Input.text()` writes the typed text into one buffer instead of joining a string per character.
- `Path.stem` / `Path.normalize`, `Mime.of` / `Mime.sniff`, `Fs.write_text` / `copy` / `mkdir` and
  `Os.save_dir` / `config_dir` / `cache_dir` free their working copies, on every way out.
- Every string `Text.*`, `Path.*`, `Mime.*`, `DateTime.format` and the `Os` directories return is
  fresh, so a comparison, a `+` or a `print` that reads it frees it; a string made for a `Text` call's
  argument (`Text.to_int(string(n))`) is freed once read.
`examples/lang/runtime_temps.ludic`: 20,000 rounds grew 19.8 MB before and 0 after; 200 rounds of
file work 64 KB before and 0 after.
