bump: patch
type: fix
Unary minus keeps its operand type: `-f` on a `fixed` is a `fixed` (it was typed `int`, which broke mixed arithmetic and comparisons).
