bump: patch
type: fix
**A distance a HUD shows is no longer kept once per value.** A game's bracketed line (`txt_line`: a key and its
holes wholly between bytes 29 and 30, "42 m", "mule deer, 62 m") shown as an element's text went to the translator,
and `L` kept one made text per distinct line - two cache entries and their strings for every metre walked - until
its 4000-entry cache was dropped whole and began again, so a player's session grew without end (the fence's
"declared but unbounded" at `kx_flat` / `kx_strip`). ludic.ui now makes such a line through the program's maker
(`md_holes` sees the bracket) and holds it while it is shown, and `i18n_made` makes it by its key (`kx_whole_key`,
then `km_text`) with nothing kept. Five minutes of wandering made 19 + 5 distance lines through `L`; now none.
