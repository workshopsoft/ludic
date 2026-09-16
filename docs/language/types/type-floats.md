---
id: type-floats
name: floats
category: types
kind: type
tokens: floats doubles
sig: floats / doubles
tip: A buffer of floats (or doubles) — v[i] reads and writes one.
order: 9
---

<code>floats(n)</code> allocates room for <code>n</code> <code>float</code> values and returns a <code>floats</code> buffer; <code>doubles(n)</code> does the same for <code>double</code>. Index it with <code>v[i]</code> to read or write an element, with no bounds checking. The memory is exactly what a GPU vertex or uniform buffer expects, so a <code>floats</code> buffer uploads as it is.

```ludic
program Vertices {
  entry {
    let v = floats(6)
    v[0] = 0.0;  v[1] = 0.5
    v[2] = -0.5; v[3] = -0.5
    v[4] = 0.5;  v[5] = -0.5
    print(v[1] - v[3])                 # 1.0
  }
}
```
