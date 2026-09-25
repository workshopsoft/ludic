bump: patch
type: fix
**`expect_eq` and `expect_near` take floats.** On a float or a double they compared with an integer
instruction, and the build failed in clang ("defined with type 'float' but expected 'i32'"); they
compare as floats now (the wider kind of the two) and a failure prints the numbers.
