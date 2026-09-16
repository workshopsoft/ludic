bump: minor
type: feat
Run a single test by name: a compiled test program takes the test's exact name as its
first argument (`./tests "adds"`), and `ludic test` gains `--test NAME` to pass it through.
A name that matches no test is reported and fails the run. `ludic test --verbose` (`-v`)
prints every test's `ok`/`FAIL` line, framed by `RUN <file>` … `PASS|FAIL <file>`, which is
what editor test views parse.
