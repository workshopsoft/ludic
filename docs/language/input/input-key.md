---
id: input-key
name: Input.key
category: input
kind: namespace-method
tokens: Input.key
sig: Input.key() -> int
tip: The key pressed this frame, as a character code (0 when nothing is pressed).
order: 0
---

The key pressed this frame, as a character code (0 when nothing is pressed). Compare against character literals like <code>'w'</code>.

```ludic
let k = Input.key()
if k == 'w' { … }
```
