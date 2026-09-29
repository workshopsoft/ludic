---
id: kw-system
name: system
category: ecs
kind: keyword
tokens: system
sig: disable system SystemFunction
tip: Leaves an engine system out at compile time.
order: 51
---

<code>disable system S</code> names a package's engine system (declared with <code>@EngineSystem</code>) and leaves it out of the program at compile time, for a game that drives that component itself.
