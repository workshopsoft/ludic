---
id: reflect-prop_count
name: Reflect.prop_count
category: reflect
kind: namespace-method
tokens: Reflect.prop_count
sig: Reflect.prop_count() -> int
tip: How many properties the world schema defines.
order: 3
ns: Reflect
member: prop_count
---

Returns the number of properties in the world — every declared <code>property</code>, plus any the runtime or a mod registered. Walk <code>0 .. Reflect.prop_count()</code> with <a href="reflect-prop_name"><code>Reflect.prop_name</code></a> to enumerate the whole schema.

```ludic
program Demo {
  property Health { hp: int = 0 }
  model Unit { Health }
  entry {
    print(Reflect.prop_count())
  }
}
```
