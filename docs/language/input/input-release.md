---
id: input-release
name: Input.release
category: input
kind: namespace-method
tokens: Input.release
sig: Input.release(key)
tip: Release an injected key.
order: 12
ns: Input
member: release
---

Releases a key previously held with <a href="input-press.html"><code>Input.press</code></a>. After the next <a href="input-poll.html"><code>Input.poll</code></a> the key reads as up (and fires <a href="input-key_released.html"><code>Input.key_released</code></a> that frame).

```ludic
program Demo {
  entry {
    Input.press('w')
    Input.poll()
    Input.release('w')
    Input.poll()
    print(0)
  }
}
```
