---
id: math-hypot
name: Math.hypot
category: math
kind: namespace-method
tokens: Math.hypot
sig: Math.hypot(x, y) -> fixed
tip: Length of the vector (x, y).
order: 15
ns: Math
member: hypot
---

Returns <code>sqrt(x*x + y*y)</code> — the length of the 2D vector <code>(x, y)</code>, or equivalently the hypotenuse of a right triangle with those legs. It is the one-call form for a magnitude and reads more clearly than spelling out the squares and root. To normalize a vector, divide each component by its <code>Math.hypot</code>.

```ludic
program Demo {
  handler Step phase Update {
    let length = Math.hypot(velocity_x, velocity_y)
  }
}
```
