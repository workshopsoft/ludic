bump: patch
type: fix
**`match` on a string compares by content, and on a `long` or a `double` by value.** Every arm was
lowered as `icmp eq i32` whatever the subject was, so `match word { "embers" => ... }` named a
pointer as an `i32` and the module did not assemble (`'%t1' defined with type 'ptr' but expected
'i32'`). An arm now compares exactly as `==` does: a string by content, a `long` as 64 bits, a
`float` or `double` as floating point; two 32-bit integers keep their single compare. A subject the
`match` built itself (a template) is freed once an arm is chosen.
