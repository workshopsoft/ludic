---
id: log-warn
name: Log.warn
category: log
kind: namespace-method
tokens: Log.warn
sig: Log.warn(msg, [key, value]...) -> void
tip: Log at the warn level (3) — something looks wrong.
order: 4
ns: Log
member: warn
---

Logs <code>msg</code> at the **warn** level (3) — something is wrong but the game recovered: a missing asset fell back to a placeholder, a value was clamped, a deprecated path was taken. It prints on stderr as <code>[WARN] msg</code> with any structured <code>key=value</code> fields, when the <a href="log-set_level"><code>Log.set_level</code></a> threshold is 3 or lower. Warnings are a good level to keep on in release builds so player bug reports capture them.

Parameters:
- `msg` — the message string
- `key, value...` — optional trailing pairs; values may be strings or numbers

```ludic
program Warn {
  entry {
    Log.warn("missing texture, using placeholder", "path", "rock.png")
  }
}
```
