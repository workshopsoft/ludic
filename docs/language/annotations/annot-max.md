---
id: annot-max
name: @max
category: annotations
kind: annotation
tokens: @max
sig: @max(64) rows: []Row
tip: The most a list may hold; growing past it fails the run.
order: 77
---

<code>@max(n)</code> bounds a list field: it never holds more than <code>n</code>, and a push past it fails the run (exit 87) rather than growing a list that should not grow.

```ludic
property Log {
  @max(64) lines: []int
}
```
