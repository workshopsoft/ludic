bump: minor
type: fix
**A renderer that cannot draw says so and stops.** A `LUDIC_HOME` handed over with its `~` unexpanded
(`env LUDIC_HOME=~/x`) left render3d without its shaders: "vulkan cannot start" was printed, and the run
went on, logging "no SPIR-V variant" for every program - a world with no terrain, shadows or impostors.
Now `r3d_home` puts a leading `~` under `$HOME`; the SPIR-V manifest ends with `E <count>` (written by
`ludic-dev shaders`) and one without it, or miscounted, is refused; and every such failure is a fault
(`gpu_fault.ludic`): `r3d_open` and each `r3d_load_step` return false on one, a program with no variant is
listed, and a game asks `r3d_fault()` and ends with `r3d_fault_exit(code)`, which prints the reason and
every missing program. `tests/manifest_test.ludic` holds the parse, the refusals, `r3d_tilde` and that
every program in variants.list resolves in the shipped manifest.
