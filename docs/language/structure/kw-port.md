---
id: kw-port
name: port
category: structure
kind: keyword
tokens: port
sig: port Name { member: fn(T) -> R [= default], ... }
tip: The questions a module asks the world, bound once by the program.
order: 59
---

A <code>port</code> is what a module needs to ask the world, as named function members in primitive types. The program answers it once with <code>bind</code>; a member left unbound without a default is a compile error. Ports let a package ask a question without reaching into the module that knows the answer.

```ludic
# doc-check: skip — a module spans files
export port ClockWorld {
  rest_scale: fn() -> float
}
```
