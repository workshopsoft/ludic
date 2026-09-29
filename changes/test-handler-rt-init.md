bump: patch
type: fix
**A test program may hold a phase handler.** A program with `test` blocks and a `handler ... phase`
(its own, or one a module it imports declares) failed to compile with LLVM's "use of undefined value
'@rt_init'": the test runner called the runtime's `rt_init` whenever the program had systems, and a
handler alone makes none. It now calls it only when it exists, as an `entry` program's `main` does.
