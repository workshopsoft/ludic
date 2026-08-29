---
id: ease-bounce
name: Ease.bounce
category: ease
kind: namespace-method
tokens: Ease.bounce
sig: Ease.bounce(t) -> fixed
tip: Ease out with a settling bounce.
order: 4
ns: Ease
member: bounce
---

Returns an ease-out that overshoots and bounces a few times before settling at <code>1.0</code>, like a ball dropping to the floor. Great for coins landing, badges popping, or a menu that lands with character.

```ludic
program Demo {
  handler Step phase Update {
    let y = Math.lerp(top, floor_y, Ease.bounce(progress))
  }
}
```
