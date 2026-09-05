bump: patch
type: fix
`ludic version` reports the version of the toolchain it belongs to. It looked for
`bin/ludicc` and `VERSION` beside the *current* directory, so it answered
"(version unknown)" from a project — which is the only place a user ever runs it.
It now resolves the compiler through the install root, like every other command.

`install.sh` also now puts `ludic` on `PATH` for every shell, not just the one
`$SHELL` names. The PATH edit lives in one file (`~/.ludic/env`) that each
profile sources, and the profiles are chosen to cover what people actually open:
`~/.profile` for sh and login bash, `~/.zshenv` because zsh never reads
`~/.profile`, `~/.bashrc`/`~/.bash_profile` when they already exist, and fish's
config when fish is installed. Re-running the installer does not add a second
copy, and `--no-modify-path` still touches nothing.
