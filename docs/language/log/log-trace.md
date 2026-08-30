---
id: log-trace
name: Log.trace
category: log
kind: namespace-method
tokens: Log.trace
sig: Log.trace(msg, [key, value]...) -> void
tip: Log at the trace level (0) — the most verbose.
order: 1
ns: Log
member: trace
---

Logs <code>msg</code> at the **trace** level (0), the most verbose — the fine-grained "I am here, this is the value" tracing you turn on only when hunting a specific problem. It appears on stderr as <code>[TRACE] msg</code>, followed by any structured <code>key=value</code> fields, but only when the threshold set by <a href="log-set_level"><code>Log.set_level</code></a> is 0. Because trace is usually filtered out, keep the calls wherever they help; a disabled level costs only a comparison.

Parameters:
- `msg` — the message string
- `key, value...` — optional trailing pairs; values may be strings or numbers

```ludic
program Trace {
  entry {
    Log.set_level(0)
    Log.trace("spawned entity", "id", 7, "at", "cave")
  }
}
```
