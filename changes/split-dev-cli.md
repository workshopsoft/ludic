bump: minor
type: refactor
**`ludic` is only the language's command line now.** The toolchain's own tasks —
building the compiler from its IR seed, the regression suites, the docs site,
releases — moved out of it into a separate `ludic-dev` binary that is built from
a checkout and is not part of an install.

- **`ludic help` is what a user can actually do**: `new`, `run`, `build`, `test`,
  `add`, `fmt`, `lsp`, `doctor`, `upgrade`. No section about a repository they do
  not have. Typing `ludic dev …` says where those tasks went rather than failing
  as an unknown command.
- **`ludic dev <task>` becomes `ludic-dev <task>`** for contributors; every task
  is otherwise unchanged. The bootstrap is now
  `bin/ludicc tools/ludic-cli/dev.ludic -o bin/ludic-dev && bin/ludic-dev build`.
- The shipped binary drops from ~880 KB to ~190 KB, since none of the release,
  docs-generation or bootstrap machinery is linked into it any more.
