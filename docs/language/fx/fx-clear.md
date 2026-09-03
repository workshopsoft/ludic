---
id: fx-clear
name: Fx.clear
category: fx
kind: namespace-method
tokens: Fx.clear
sig: Fx.clear()
tip: Drop every spark and number at once.
order: 3
ns: Fx
member: clear
---

Removes every effect in flight — call it when the world changes under them (a room change, a new run).

```ludic
# doc-check: skip — illustrative
function clear_room() -> void {
  for (p) in query [Position] { despawn self() }
  Fx.clear()
}
```
