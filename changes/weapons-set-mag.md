bump: minor
type: feat
ludic.weapons: `weapons_set_mag(weapons_st, h, gun, n)` sets the rounds in a gun's magazine outright, held to 0 .. its capacity, the reserve untouched; refused for no such gun and while that gun reloads. A game that keeps its own inventory (a save read back, a shop that sells a gun loaded) puts back what the magazine held: `weapons_give` always fills it.
