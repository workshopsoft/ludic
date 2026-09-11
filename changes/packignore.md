bump: minor
type: feat
**`.packignore`** — keep build artefacts out of the shipped asset pack.

A pack root is packed wholesale, so everything a model or texture pipeline leaves
beside its output ships too: preview renders, bake intermediates, the `.blend` a
`.gltf` came from. Nothing errors and nothing looks wrong — the app is just bigger
than the game. The only way out was naming every file in `package.ludic`, a list
that goes stale the day someone adds a texture.

Put a `.packignore` beside the assets instead. The rules are **gitignore's**, down
to the parts people rely on without thinking about them: patterns anchored by a
slash or floating without one, `preview/` for directories only, `*` and `?` stopping
at a separator where `**` crosses it, `[a-z]` classes, `!` re-includes with the last
line winning, a deeper file beating a shallower one, and no re-including out of an
ignored directory.

`ludic pack` reports what it left out, and `--no-ignore` packs everything so you can
see what a rule costs. `ludic bundle` gathers the same way. `.packignore` itself is
never packed, and the file only governs your own roots — a package's resources, such
as the renderer's shaders, are added afterwards and cannot be excluded by accident.
