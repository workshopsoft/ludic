---
id: op-comment
name: Comment
category: operators
kind: operator
sig: # to end of line
tip: Everything after # on a line is a comment, ignored by the compiler.
order: 9
---

A comment begins with `#` and runs to the end of the line; the compiler ignores everything after it. Ludic has only this one line-comment form — there is no block-comment syntax — so to comment out several lines put a `#` on each. Use comments to explain intent next to a `const`, to label a section of a handler, or to note a gotcha. The source formatter (`ludic-fmt`) works on tokens, so your comments and blank lines survive a reformat.

```ludic
const TILE_SIZE: int = 16          # pixels per grid cell
var score: int = 0                 # reset in the Start phase
# the head is drawn brighter than the body
```
