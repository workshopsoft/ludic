---
id: kw-uses
name: uses
category: structure
kind: keyword
tokens: uses
sig: module name uses a, b, c
tip: The modules a module may reach; a reach not on the line is a compile error that names the fix.
order: 52
---

<code>uses</code> ends a <code>module</code> line with the modules its files may name. The compiler holds the module to that list and refuses a list that goes round: when adding a module would make a cycle, the question goes through a <code>port</code> the asker declares and the program binds instead.

```ludic
# doc-check: skip — a module spans files
module sky uses base, events, clock
```
