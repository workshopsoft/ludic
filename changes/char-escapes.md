bump: patch
type: fix
Character literals accept the same escapes as strings (`'\''`, `'\\'` and `'\"'` were silently read as 0); an unterminated character literal is now an error.
