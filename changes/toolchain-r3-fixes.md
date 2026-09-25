bump: patch
type: fix
**The action drain is the program's; `--check` is every check; `count` is not a registry key.**
The function that calls every reducer is written in the program's own file, so the module that
declares the actions no longer depends on every module that reduces them (a game's `base` joined a
69-module cycle). `ludic build --check` runs the code writer's checks too - a bind to a function that
is gone, an unknown name - and still writes nothing. A registry entry keyed `count` is refused
(`def Tools count: its constant would be TL_COUNT, which is the registry's size`). And a big
program builds much faster: the emitter's and the checker's lookups by name are tables, not walks of
the whole program (on Maroon Lake a check-only build, lowering included, went from about 20 s to under 10 s, its IR from about 2 minutes to under 10 s).
