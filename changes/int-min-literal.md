bump: patch
type: fix
**The most negative int is emitted as itself.** The compiler's `itoa` negated a negative value before
taking its digits, and `-(-2147483648)` overflows back to itself, so a literal such as `0x80000000` in an
int (`b & 0x80000000`) was written into the IR as a bare `-` and the build failed in LLVM. The digits are
now taken off the value as it is. Needs a reseed to reach `bin/ludicc`.
