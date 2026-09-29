bump: patch
type: fix
**`ludic build --check` reads the maps only for the package's entry.** A partial program - a unit test, a
molecule, a bake's runner - lacks the game's constants, so checking every map's tables against it refused
rows the game reads fine (`TH_*`, `NPCK_*` unknown). The maps are now checked with the `entry` package.ludic
names (as `ludic build --check` with no file, and tests/pack.sh, do); `--maps` checks them anyway, `--no-maps`
never. `ludicc` itself is unchanged: it reads them unless told `--no-maps`.
