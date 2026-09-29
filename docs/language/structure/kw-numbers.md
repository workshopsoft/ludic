---
id: kw-numbers
name: numbers
category: structure
kind: keyword
tokens: numbers
sig: numbers float
tip: This file's bare decimals are floats.
order: 56
---

<code>numbers float</code> at the top of a file makes a bare decimal such as <code>1.5</code> a <code>float</code> rather than a <code>fixed</code>. Such a file also refuses to promote a computed <code>int</code> silently: write <code>float(n)</code> where a count becomes a number.

```ludic
# doc-check: skip — a file-level line
numbers float
const GRAVITY: float = 9.81
```
