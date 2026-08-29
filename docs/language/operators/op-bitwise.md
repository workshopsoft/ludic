---
id: op-bitwise
name: Bitwise
category: operators
kind: operator
sig: &  |  ^  ~  <<  >>
tip: And, or, xor, not, shift left/right.
order: 3
---

And, or, xor, not, shift left/right. Shifts and <code>&amp;</code> bind like <code>*</code>; <code>|</code>/<code>^</code> bind like <code>+</code> — tighter than comparison, so <code>flags &amp; MASK == 0</code> needs no parentheses.
