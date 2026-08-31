---
id: input-press
name: Input.press
category: input
kind: namespace-method
tokens: Input.press
sig: Input.press(key)
tip: Inject a held key (AI, tutorial, testing, network).
order: 11
ns: Input
member: press
---

Injects a held key into the input state — the same idea as Godot's <code>action_press</code>. It persists until <a href="input-release.html"><code>Input.release</code></a>, and combines with the platform's real keys, so an AI, a replay, a tutorial, or the network can drive input exactly as a player would. Deterministic on every target.

```ludic
program Demo {
  entry {
    Input.press('w')
    Input.poll()
    if Input.key_down('w') { print(1) }
  }
}
```
