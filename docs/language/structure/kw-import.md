---
id: kw-import
name: import
category: structure
kind: keyword
tokens: import
sig: import "file.ludic"
tip: Splice another Ludic file's declarations into this program.
order: 10
---

An <code>import</code> pulls the declarations of another Ludic file into this program, letting you split a game across many files instead of one giant block. The imported file is a <b>fragment</b> — bare declarations with no `program` wrapper — and its contents are spliced in as if written here. Paths resolve relative to the importing file, imports may nest, and each resolved path is include-guarded, so importing the same file twice (even through different chains) pulls it in exactly once. Diagnostics still point at the real source file, so errors in an imported fragment report that file's name and line.

```ludic
program ChronoRift {
  import "chronorift/world.ludic"     # properties and models
  import "chronorift/combat.ludic"    # the battle handlers

  handler Boot phase Start {
    spawn Hero { Position { column: 4, row: 4 } }
  }
}
```
