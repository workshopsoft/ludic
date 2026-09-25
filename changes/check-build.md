bump: minor
type: feature
**`ludic build --check` / `ludicc --check`: check without building.** The parse, the type checker
and the module rules (`export`, `uses`, layers, ports, registries) run, and nothing is emitted or
linked - about three seconds on Maroon Lake where a build takes about a minute. In this mode the
checker asks the module rules at each reference it resolves, since the emitter that usually asks
them does not run.
