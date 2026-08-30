---
id: log-info
name: Log.info
category: log
kind: namespace-method
tokens: Log.info
sig: Log.info(msg, [key, value]...) -> void
tip: Log at the info level (2) — normal operation.
order: 3
ns: Log
member: info
---

Logs <code>msg</code> at the **info** level (2) — the normal-operation milestones you want to see in a running game: a level loaded, a match started, a save written. It prints on stderr as <code>[INFO] msg</code> with any structured <code>key=value</code> fields, when the <a href="log-set_level"><code>Log.set_level</code></a> threshold is 2 or lower. Info is a sensible default level for a development build.

Parameters:
- `msg` — the message string
- `key, value...` — optional trailing pairs; values may be strings or numbers

```ludic
program Info {
  entry {
    Log.info("level loaded", "name", "cavern", "entities", 42)
  }
}
```
