---
id: kw-continue
name: continue
category: control
kind: keyword
tokens: continue
sig: continue
tip: Skip to the next iteration of the loop.
order: 10
---

<code>continue</code> abandons the rest of the current loop pass and jumps straight to the next one — the next condition check in a <code>while</code>, or the next index in a <code>for</code>. Use it to skip elements that do not apply without nesting the rest of the body inside an <code>if</code>: filter out empty slots, ignore inactive entities, or step over even numbers. Like <code>break</code>, it acts on the innermost loop only.

```ludic
program SumOdds {
  var total: int = 0

  handler Add phase Update {
    for i in 0 .. 10 {
      if i % 2 == 0 { continue }   # skip even numbers
      total = total + i
    }
  }
}
```
