bump: minor
type: feature
**`ludic deps` - the module graph as the compiler resolved it.** It compiles the program with
`LUDIC_DEPS` set, and the compiler records every reference its visibility pass sees (from module,
to module) and every assignment to another module's global. It prints the modules, dependencies,
largest cycle, cross-module writes and globals written from outside; `--graph`, `--dot`, `--writes`,
`--uses MOD`, `--check FILE` and `--baseline FILE`.
