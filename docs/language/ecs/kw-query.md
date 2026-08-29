---
id: kw-query
name: query
category: ecs
kind: keyword
tokens: query
sig: query [PropA, PropB, {Tag}]
tip: Match every entity that carries all listed properties.
order: 2
---

Match every entity that carries all listed properties. Use it in <code>for (a, b) in query […]</code>; a <code>{Tag}</code> filters without binding.

```ludic
for (p, s) in query [Pos, Seg] { … }
```
