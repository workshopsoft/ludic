bump: minor
type: feat
**A game can use the renderer from outside this repository.** `ludic.render3d` reads two
things from disk at run time — its GLSL, and the scanned CC0 materials — and both were
found only by a path relative to the working directory, so the renderer worked in a
Ludic checkout and nowhere else. A game living in its own repository now needs to copy
neither.

**The shaders come from the package**, wherever the package is. They belong to
`ludic.render3d` and ship with it, so the renderer looks for them beside the project
first (a Ludic checkout, where they are under `packages/`) and then under the install
root, `$LUDIC_HOME/packages/ludic.render3d` — the same place the compiler already
resolves `import "ludic.render3d/r3d.ludic"` from. Nothing to vendor, and no version of
the shaders that can drift from the version of the code that compiles them.

**`ludic assets [--force]`** fetches the scanned materials and the HDRI sky into
`assets/polyhaven/` of whatever project you run it in. The list of what to fetch is the
renderer's own — the renderer decides which materials it wants — so it moved out of the
repository's `assets/` and into the package as
`packages/ludic.render3d/assets.manifest`, where it ships with the toolchain. A game
does not keep its own copy of that list and so cannot fall out of step with the
renderer's material set. `ludic dev fetch-assets` is the same command from a checkout.

**A URL-shaped module built its binary into directories.** `project_name` took
everything after the last dot of the manifest's module path, which for a package
identified the way the package manager identifies them —
`git.host.io/user/name` — is inside the *host*: the build wrote
`build/io/user/name` instead of `build/name`. The last path segment comes first now, and
a dot inside that segment still separates namespace from package, so `ludic.render3d`
still builds as `render3d`.

**The camping game has moved out** to its own repository —
[Maroon Lake](https://git.workshopsoft.io/workshopsoft/maroon-lake) — taking
`examples/rendering/valley.ludic`, `hiker.ludic`, `camp/`, and 175 MB of survey data and
scanned kit with it. It was here as a demo of the renderer and became a game, and an
engine repository should not be carrying a game's assets. It is now the first consumer
of everything above, which is the point: what the renderer needs a game to be able to do,
it can now do from outside. `examples/rendering/smooth.ludic` stays as the renderer's
example in this tree.
