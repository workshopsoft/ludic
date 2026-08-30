---
id: duration-seconds
name: Duration.seconds
category: duration
kind: namespace-method
tokens: Duration.seconds
sig: Duration.seconds(n) -> int
tip: A span of n whole seconds.
order: 0
ns: Duration
member: seconds
---

A span of <code>n</code> whole seconds. Since a duration is just an <code>int</code> count of seconds, this is the identity — it exists so the unit is explicit at the call site.

```ludic
program Demo {
  handler Step phase Update {
    let cooldown = Duration.seconds(45)
  }
}
```
