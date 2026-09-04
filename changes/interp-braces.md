bump: patch
type: fix
A `{` or `}` inside a string literal within an interpolation hole (`` `{f("{")}` ``) is text, not structure; the hole scanner used to miscount it.
