---
id: log-error
name: Log.error
category: log
kind: namespace-method
tokens: Log.error
sig: Log.error(msg, [key, value]...) -> void
tip: Log at the error level (4) — a failure.
order: 5
ns: Log
member: error
---

Logs <code>msg</code> at the **error** level (4), the highest — a real failure the game could not handle cleanly: a save that would not write, a required asset that could not load. It prints on stderr as <code>[ERROR] msg</code> with any structured <code>key=value</code> fields, and shows at every threshold except one set above 4. Error is the level you almost always want visible, including in release builds.

Parameters:
- `msg` — the message string
- `key, value...` — optional trailing pairs; values may be strings or numbers

```ludic
program Error {
  entry {
    Log.error("save failed", "path", "slot1.sav", "code", 5)
  }
}
```
