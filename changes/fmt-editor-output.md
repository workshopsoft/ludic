bump: minor
type: feat
**`ludic fmt` for editors.** `ludic fmt --lint --json` prints the violations `--lint` reports as one JSON
array on stdout, `[{"file", "line", "col", "rule", "message"}]` ordered by file, line and column (the
summary on stderr, `--lint`'s exit status, and the baseline never rewritten). `ludic fmt -` formats
stdin to stdout under the project found from the working directory (the nearest `package.ludic`
upwards), and refuses a buffer that does not read as Ludic - an open string, a bracket never closed or
closed by the wrong one - with exit 2 and `<name>:<line>:<col>: error: ...` on stderr.
`--stdin-name <path>` makes the buffer that file: the project is found from its directory, and
`ludic fmt - --lint --json --stdin-name <path>` judges it against that file's baseline and `lint
paths`, reporting it under the name given. Hooks around `fmt` and `get` read nothing from stdin and
write to stderr when the command's stdout is a program's (`--json`, `-`).
