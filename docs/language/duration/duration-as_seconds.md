---
id: duration-as_seconds
name: Duration.as_seconds
category: duration
kind: namespace-method
tokens: Duration.as_seconds
sig: Duration.as_seconds(span) -> int
tip: The span in whole seconds.
order: 4
ns: Duration
member: as_seconds
---

The span expressed in whole seconds. The inverse of <code>Duration.seconds</code>; also the identity, provided for symmetry with the other readers.

```ludic
program Demo {
  handler Step phase Update {
    let s = Duration.as_seconds(Duration.minutes(3))   # 180
  }
}
```
