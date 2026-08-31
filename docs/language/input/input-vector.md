---
id: input-vector
name: Input.vector
category: input
kind: namespace-method
tokens: Input.vector
sig: Input.vector(left, right, up, down) -> Vector
tip: A normalized 2D vector from four keys.
order: 14
ns: Input
member: vector
---

Returns a 2D movement <a href="vector.html"><code>Vector</code></a> from four direction keys, normalized so a diagonal is not faster than a straight move (each diagonal component is <code>0.7071</code>). The one call for eight-way keyboard movement.

```ludic
program Demo {
  entry {
    Input.press('d')
    Input.press('w')
    Input.poll()
    let v = Input.vector('a', 'd', 'w', 's')
    print(Math.round(Vector.x(v) * 100))
  }
}
```
