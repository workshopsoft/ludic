---
id: reflect-prop_name
name: Reflect.prop_name
category: reflect
kind: namespace-method
tokens: Reflect.prop_name
sig: Reflect.prop_name(index) -> string
tip: The name of the property at an index (or "").
order: 4
ns: Reflect
member: prop_name
---

Returns the name of the property at <code>index</code> (<code>0 .. Reflect.prop_count()</code>), or the empty string if out of range. The reverse of <a href="reflect-prop"><code>Reflect.prop</code></a> — together they let a generic tool list every component by name.

Parameters:
- `index` — the property index

```ludic
program Demo {
  property Health { hp: int = 0 }
  model Unit { Health }
  entry {
    var p = 0
    let n = Reflect.prop_count()
    while p < n {
      print(Reflect.prop_name(p))
      p = p + 1
    }
  }
}
```
