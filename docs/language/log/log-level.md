---
id: log-level
name: Log.level
category: log
kind: namespace-method
tokens: Log.level
sig: Log.level() -> int
tip: The current logging threshold.
order: 7
ns: Log
member: level
---

Returns the current logging threshold — the minimum level that <a href="log-set_level"><code>Log.set_level</code></a> last set (0 by default). Use it to branch on how verbose logging is: skip building an expensive debug string when it would be dropped anyway, or show an in-game indicator that verbose logging is on. The levels are <code>trace</code> 0 through <code>error</code> 4.

```ludic
program Level {
  entry {
    print(Log.level())        # 0
    Log.set_level(2)
    print(Log.level())        # 2
  }
}
```
