---
id: op-bitwise
name: Bitwise
category: operators
kind: operator
sig: &  |  ^  ~  <<  >>
tip: Bit-level and, or, xor, not, and shifts — with Go-style precedence.
order: 3
---

The bitwise operators work on the bits of an `int`: `&` (and), `|` (or), `^` (xor), `~` (not), `<<` (shift left), and `>>` (a logical/unsigned shift right). They are the tools for flag sets, packing several small values into one integer, and fast multiply/divide by powers of two. Precedence is Go-style: `<<`, `>>`, and `&` bind like `*` (tightly), while `|` and `^` bind like `+`, and all of them bind <b>tighter than comparison</b> — so `flags & MASK == 0` means `(flags & MASK) == 0` with no parentheses.

```ludic
const FLAG_POISONED: int = 1
const FLAG_SHIELDED: int = 2
let status_flags: int = FLAG_POISONED | FLAG_SHIELDED
let is_shielded: bool = status_flags & FLAG_SHIELDED != 0
```
