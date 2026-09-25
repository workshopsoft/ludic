bump: patch
type: fix
**A template literal inside another's `{…}` hole, and integer literals past 2^31 - 1.** The first
crashed the compiler (the outer literal ended at the inner one's backtick); a hole is now read as
code, so strings, chars and templates inside it are taken whole. The second was read as a wrapped
negative int; a decimal literal past `2147483647`, or a hex one of more than eight digits, is now a
`long` with its value, and giving one to an `int` is refused. Eight hex digits or fewer are still a
32-bit pattern.
