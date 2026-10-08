bump: patch
type: fix
**A count in the hole of a made line is no longer kept once per count.** `i18n_made` makes a line for a caller that lets
it go, but an argument that held a key or a bracket - a game's step and its count, "Catch 5 trout  ({count})", where the
count is itself a bracketed `fmt.count_of` line - was made by `L` through `km_kept_arg`: the argument's string kept for
good in `ka_s`, and its text in `L`'s cache, for every count a HUD ever showed (the fence's "declared but unbounded" at
`keyed_buf.ludic` `km_kept_arg` and `nest.ludic` `kx_flat` / `kx_strip`). Inside `i18n_made` such an argument is now made
the same way and let go once written (`km_made_arg`); `L` keeps what it makes as before. Five hundred counts of a step
made through the maker kept 1000 lines and 500 arguments; now none (`tests/made_args_test.ludic`).
