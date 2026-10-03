bump: patch
type: fix
**A line with a line bracketed in it, made for a caller, keeps nothing.** `i18n_made` handed a line such as
"[E / L click] Pick up firewood" or "Open your stash ([0/40])" to `L`, which kept the whole line and every count
inside it once per distinct text, so each prompt a player aimed at and each count it showed stayed for good
(`kx_flat`, `kx_strip`, `km_kept_arg`: the alloc fence's "declared but unbounded" in a long session). Now such a
line, and a key glued to words, is written into the kept buffer a piece at a time - each bracket made the same way and
let go once written - and handed back as the one string it makes; `i18n_let_go(s)` lets a caller that only reads it
(a HUD splitting its prompt) give it back. `i18n_cached` says how many lines `L` keeps. `tests/made_test`: fifty
prompts made and let go leave `L`'s cache as it was.
