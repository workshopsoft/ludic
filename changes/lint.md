bump: minor
type: feature
**`ludic-fmt` enforces a project's style.** `lint` lines in `package.ludic` state it - one statement
per line, file, function and comment-block limits (a file's opening comment its own) - and
`ludic-fmt --check <files>` and `ludic-fmt --lint` (the project's paths) fail what breaks them, at the
line. A baseline file is the ratchet that lets a rule arrive in an existing codebase: the counts a
file had may stay but not grow, and they are lowered as they are fixed.
