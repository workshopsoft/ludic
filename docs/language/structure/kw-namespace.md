---
id: kw-namespace
name: namespace
category: structure
kind: keyword
tokens: namespace
sig: namespace Name { export function foo(…) … internal function bar(…) … }
tip: Group functions into a Name.* namespace and control its public surface.
order: 16
---

A <code>namespace</code> block declares a <code>Name.*</code> namespace once and controls its public surface declaratively, instead of annotating every function with <code>@Namespace(Name)</code> one at a time. Inside the block each <code>function short(…)</code> is emitted as <code>namelower_short</code>; an <code>export</code> function (the default) is callable from anywhere as <code>Name.short(…)</code>, while an <code>internal</code> function is a private helper — emitted, and callable by its short name from other functions in the same block, but not part of the <code>Name.*</code> surface (calling <code>Name.internalOne()</code> is a compile error). It is the block sugar for the per-function <code>@Namespace</code> annotation, so a package's public API reads at a glance.

Sibling calls inside the block use the short name (<code>base()</code>), and the compiler rewrites them to the emitted name — so a namespace reads like a self-contained module.

```ludic
program Demo {
  namespace Combat {
    export function amount() -> int { return base() + 5 }
    internal function base() -> int { return 10 }
    export function double(n: int) -> int { return n + n }
  }
  entry {
    print(Combat.amount())      # 15
    print(Combat.double(21))    # 42
  }
}
```
