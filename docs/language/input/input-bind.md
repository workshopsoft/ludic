---
id: input-bind
name: Input.bind
category: input
kind: namespace-method
tokens: Input.bind
sig: Input.bind(action: str, key: int) -> void
tip: Bind a physical key to a named action, so gameplay reads the action, not the key.
order: 1
ns: Input
member: bind
---

Binds a physical key (a character code such as <code>'w'</code> or <code>' '</code>) to a named <em>action</em>, creating the action the first time it is named. Gameplay then reads the action with <a href="input-down.html"><code>Input.down</code></a> / <a href="input-pressed.html"><code>Input.pressed</code></a> instead of a raw key, which is what makes rebinding and alternate control schemes clean. Call it more than once with the same action to bind several keys to it; binding a key already on the action is a no-op. Actions are advanced once per frame by <a href="input-poll.html"><code>Input.poll</code></a>.

```ludic
program Bindings {
  entry {
    Input.bind("jump", ' ')
    Input.bind("up", 'w')
    Input.poll()
    if Input.down("jump") { print(1) }
  }
}
```
