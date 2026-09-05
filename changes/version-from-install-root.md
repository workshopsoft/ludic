bump: patch
type: fix
`ludic version` reports the version of the toolchain it belongs to. It looked for
`bin/ludicc` and `VERSION` beside the *current* directory, so it answered
"(version unknown)" from a project — which is the only place a user ever runs it.
It now resolves the compiler through the install root, like every other command.
