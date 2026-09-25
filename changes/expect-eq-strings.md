bump: patch
type: fix
**`expect_eq` on strings compares their text.** It lowered to an integer compare of two pointers,
which the IR refused; now two strings with the same text are equal (a null only to a null), and a
failure prints both: `expect_eq failed (got "camp", want "lake")`.
