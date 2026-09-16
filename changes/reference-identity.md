bump: patch
type: fix
**`==` / `!=` on records is identity again** — only two strings compare by content.

Every pointer-typed comparison used to be lowered to a C-string content compare,
so two distinct records (properties, slices, enums) compared their bytes up to
the first zero byte: `a == b` could be true for different objects that shared a
leading field, depending on layout. References now compare by identity
(`icmp eq ptr`); `string` (and untyped `pointer`/`pointers` text) still compares by content,
and comparing a `string` with a non-string reference is a compile error.
