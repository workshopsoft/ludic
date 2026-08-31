---
id: input-pressed
name: Input.pressed
category: input
kind: namespace-method
tokens: Input.pressed
sig: Input.pressed(action: str) -> bool
tip: Did a named action go down this frame (a one-shot edge)?
order: 5
ns: Input
member: pressed
---

Returns whether a named action went down <em>this</em> frame — held on the frame last polled, but not on the one before — the edge you want for "press to jump / confirm / fire", where <a href="input-down.html"><code>Input.down</code></a> would retrigger every frame the key is held. Depends on the two most recent <a href="input-poll.html"><code>Input.poll</code></a> calls, so poll once per frame.

```ludic
program Edge {
  entry {
    Input.bind("jump", ' ')
    Input.poll()
    if Input.pressed("jump") { print(1) }
  }
}
```
