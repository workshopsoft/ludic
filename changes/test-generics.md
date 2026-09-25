bump: patch
type: fix
**A generic function called from a `test` block works.** Test blocks were never type-checked, and
the checker is what makes a generic call real, so `q_new()` inside a test was "unknown function".
They are checked like `entry` now - which also means a type error in a test is reported.
