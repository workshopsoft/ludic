---
id: input-poll
name: Input.poll
category: input
kind: namespace-method
tokens: Input.poll
sig: Input.poll() -> int
tip: Advance one frame of input; the single per-frame read behind actions and replay.
order: 3
ns: Input
member: poll
---

Advances the input by one frame and returns the frame's key. Call it once at the top of a frame; the action reads (<a href="input-down.html"><code>Input.down</code></a>, <a href="input-pressed.html"><code>Input.pressed</code></a>) then report on the key it captured. It is the single place input crosses into the frame, which is what makes recording and replay possible: in record mode it saves the live key, and in replay mode it takes the next key from the tape instead of the device — so "read input" and "read a recorded snapshot" are the same call.

```ludic
program Poll {
  entry {
    Input.bind("up", 'w')
    Input.poll()
    if Input.down("up") { print(1) }
  }
}
```
