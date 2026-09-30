bump: patch
type: fix
**A key used only in a listener counts as used.** The key check walked the program's declarations but
not the bodies kept beside them - `@On` listeners, the lifecycle hooks, tests, computed fields and
scenes - so a key used only there was never checked against en.po and `ludic schema` listed it
unused. They are walked now, as every other pass walks them.
