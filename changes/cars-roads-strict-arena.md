bump: patch
type: fix
**`ludic.roads`, `ludic.cars`: clean under `arena strict`.** A project that declares `arena strict` refused to build with either package: `RoadsState.rd_dice` was made in the frame by `rng_new` the first time traffic needed it (it is now a state default, `rd_dice_ok` says whether `RoadsWorld.seed()` has seeded it), and the editor verb `car_get` built its refusal text in a verb the fence reached (the text is `@alloc_ok`). No behaviour changes: the dice roll the same numbers from the same seed.
