---
id: log-set_level
name: Log.set_level
category: log
kind: namespace-method
tokens: Log.set_level
sig: Log.set_level(n) -> void
tip: Show only messages at level n or above (0 = all).
order: 6
ns: Log
member: set_level
---

Sets the logging threshold: only messages whose level is <code>n</code> or higher are written; everything below is silently dropped. The levels are <code>trace</code> 0, <code>debug</code> 1, <code>info</code> 2, <code>warn</code> 3, <code>error</code> 4, so <code>set_level(3)</code> shows only warnings and errors, and the default of <code>0</code> shows everything. Set it once at startup — low in development, high (3, or 5 to silence all) for release — and every call site adjusts automatically. Read the current value back with <a href="log-level"><code>Log.level</code></a>.

Parameters:
- `n` — the minimum level to show (0–4; use 5 to silence every level)

```ludic
program Quiet {
  entry {
    Log.set_level(3)          # warnings and errors only
    Log.info("startup")       # dropped
    Log.warn("low memory")    # shown
  }
}
```
