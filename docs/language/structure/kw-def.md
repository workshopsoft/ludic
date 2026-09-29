---
id: kw-def
name: def
category: structure
kind: keyword
tokens: def
sig: def Registry key { field: value, ... }  /  def Registry from "file.lres"
tip: Entries of a registry, written in code or read from a resource file.
order: 67
---

<code>def</code> adds entries to a registry: one written inline, or every entry of a resource file. An <code>open</code> registry takes <code>def</code>s from other modules, which is how a package's table gets a game's rows.

```ludic
# doc-check: skip — the registry is declared elsewhere
def Tools lantern { weight: 1.5 }
```
