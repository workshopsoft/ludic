bump: minor
type: feature
**`ludic test <dir>`, and every test block in a fresh process.** A directory stands for the
`*_test.ludic` files under it and the files straight inside any `tests/` directory under it. Each
`test` block now runs in a child process of its own (the runner answers `--list` and runs one test
by name), so tests no longer share globals; a file's line says how many tests it ran. A failed
`expect` names the file it is written in, not only the base name of the program's root.
