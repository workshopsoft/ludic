---
id: kw-break
name: break
category: control
kind: keyword
tokens: break
sig: break
tip: Leave the enclosing loop immediately.
order: 9
---

<code>break</code> exits the innermost <code>while</code> or <code>for</code> loop at once, skipping the rest of the body and any remaining iterations, and continues with the code after the loop. Use it to stop early the moment you have what you need — the first match in a scan, a collision that ends the sweep, or a guard inside <code>while true</code> that decides when to leave. It affects only the loop that contains it; an outer loop keeps running.

```ludic
program FindFirst {
  var found: int = 0 - 1

  handler Scan phase Update {
    for i in 0 .. 10 {
      if i * i > 20 {
        found = i
        break        # stop at the first i whose square exceeds 20
      }
    }
  }
}
```
