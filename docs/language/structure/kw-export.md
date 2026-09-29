---
id: kw-export
name: export
category: structure
kind: keyword
tokens: export
sig: export function / property / state / registry ...
tip: Makes a declaration visible outside its module.
order: 54
---

<code>export</code> in front of a declaration makes it reachable from other modules; without it a module's names are its own. It works on every declaration - functions, records, states, events, actions, ports, registries, views and components - and <code>@export</code> is the same thing written as an attribute. Export deliberately: a name nobody else asks for stays private.

```ludic
# doc-check: skip — a module spans files
export function balance(b: Bank) -> int { return b.total }
```
