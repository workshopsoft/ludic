bump: patch
type: fix
**`ludic new` scaffolded a project that would not compile.** The project name went
straight into the `program <Name>` identifier, so `ludic new my-game` wrote
`program My-Game` — a subtraction — and the first `ludic run` failed with
`expected '{', got '-'`. A name is now turned into a valid identifier
(`my-game` → `MyGame`, `2048` → `Game2048`), and a name that cannot be a
directory or a package is refused with the rule rather than mangled.

Found while auditing every command's flags and arguments, along with:

- **Unknown options are errors.** `ludic build --headles` silently built a
  windowed binary; `ludic build -o` with no path silently ignored it. Both now
  say what is wrong and exit non-zero.
- **`ludic fmt` formats in place**, as its help always claimed — it was printing
  the file to stdout and changing nothing. `ludic fmt --check` reports drift
  without writing, for a hook or CI.
- **`ludic test nosuch.ludic`** says the file does not exist instead of passing it
  to the compiler.
- **`ludic build-lib`** reported failures as a shell syntax error (an
  interpolation written in a non-interpolating string), and its no-argument
  auto-detection picked up `package.lock.ludic` as a module to compile.
- Error messages that still began with `x:` — the CLI's old name — now say
  `ludic:`.
