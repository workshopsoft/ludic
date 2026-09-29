---
id: kw-module
name: module
category: structure
kind: keyword
tokens: module
sig: module name [in layer L] [uses a, b]
tip: Names the module a directory's files belong to; only what it exports is reachable from outside.
order: 51
---

<code>module</code> opens a directory's barrel (<code>index.ludic</code>) and says which module every file under it belongs to. A name a module does not <code>export</code> is private to it: another module that names it is refused at compile time, which is what makes a private name safe to change. The line may place the module in a layer (<code>in layer L</code>) and say what it may reach (<code>uses</code>).

```ludic
# doc-check: skip — a module spans files
# bank/index.ludic
module bank uses base
import "ledger.ludic"
```
