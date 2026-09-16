---
id: type-float
name: float
category: types
kind: type
tokens: float
sig: float
tip: A 32-bit IEEE floating-point number — what the GPU uses.
order: 3
---

A <code>float</code> is an IEEE-754 single-precision number: about seven significant digits, a huge range, and ordinary operators (<code>+ - * / %</code>, comparisons). It is the type for rendering and physics that runs on the GPU or talks to it — positions, normals, colours in shaders, matrices — and for any math where <code>fixed</code>'s ±32768 range is too small.

A decimal literal takes its type from where it is used: `let s: float = 0.5`, `x * 0.5` with a float `x`, and a float parameter all read `0.5` exactly as a float, while an untyped `let k = 0.5` stays <code>fixed</code>. An <code>int</code> promotes to float automatically; everything else converts explicitly with <code>float(x)</code>, <code>int(x)</code>, <code>fixed(x)</code>. <code>Math.*</code> accepts floats and answers in float.

Floats are not deterministic across machines the way <code>fixed</code> is, so simulation that must replay bit-for-bit stays in <code>fixed</code>.

```ludic
program Orbit {
  function radius(x: float, y: float) -> float { return Math.sqrt(x * x + y * y) }

  entry {
    let speed: float = 1.5
    var angle: float = 0.0
    angle = angle + speed * 2          # the int 2 promotes
    print(radius(3, 4))                # 5.0
    print(Math.sin(angle) < 1.0)
  }
}
```
