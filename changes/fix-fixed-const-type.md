bump: patch
type: fix
**`const` of a non-int type is no longer miscompiled.** A `const` reference used
to lower to its initializer's raw integer bits hardcoded as type `int`, so a
`const X: fixed = 10.0` compared and computed as the raw Q16.16 value `655360`
instead of `10.0` — silently corrupting fixed-point math (and, in one case, spinning
an infinite loop). A const reference now emits its initializer expression with that
expression's real type, so `fixed` / `bool` / `string` consts behave correctly (and
computed const initializers work too). Every existing const is an `int` literal, for
which the lowering is byte-identical, so the bootstrap fixpoint and all golden
renders are unchanged. Covered by selfhost/tests/const.ludic.
