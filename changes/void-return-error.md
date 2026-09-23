bump: patch
type: fix
**`return <value>` in a function that returns nothing is an error.** It used to reach clang as
`store void`, which fails the link with an LLVM message about void types and no line in the
program; it now says where, in words.
