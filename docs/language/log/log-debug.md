---
id: log-debug
name: Log.debug
category: log
kind: namespace-method
tokens: Log.debug
sig: Log.debug(msg, [key, value]...) -> void
tip: Log at the debug level (1) — development detail.
order: 2
ns: Log
member: debug
---

Logs <code>msg</code> at the **debug** level (1) — development-time detail that is useful while building a feature but noise in a shipped game. It prints on stderr as <code>[DEBUG] msg</code> with any structured <code>key=value</code> fields, when the <a href="log-set_level"><code>Log.set_level</code></a> threshold is 1 or lower. Reach for it to trace state transitions, loaded assets, or the values feeding a calculation you are not yet sure of.

Parameters:
- `msg` — the message string
- `key, value...` — optional trailing pairs; values may be strings or numbers

```ludic
program Debug {
  entry {
    Log.set_level(1)
    Log.debug("player state", "hp", 100, "phase", "combat")
  }
}
```
