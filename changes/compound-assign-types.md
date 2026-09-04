bump: patch
type: fix
`x += y` / `-=` / `*=` / `/=` now lower exactly like `x = x op y`: a Q16.16 `fixed` multiplies and divides through the 64-bit path, a string `+=` concatenates, and an `int` added to a `long` widens (they previously emitted raw integer arithmetic on the LLVM type).
