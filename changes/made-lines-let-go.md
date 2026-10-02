bump: patch
type: fix
**A line with holes a screen shows is let go once it is not shown.** A HUD's `t('fmt.percent', n)`
or a marked "mule deer, 62 m" was kept for good twice over - ludic.ui's memo kept the marked line and
its Value, and ludic.i18n's `L` kept the made text (with a list of arguments and their pieces made on
the way, never given back) - so every value a meter or a distance passed through stayed, about 3 KB a
600 frames at an idle camp, and the alloc fence ended the run as "declared but unbounded". Now
`ui_maker(f)` gives ludic.ui a maker that hands back a NEW string and keeps nothing
(`i18n_made`), and while a screen is built a t() with holes, or a marked line with holes as an
element's text, is made through it and held by the screen's pool like its nodes: let go (`free`)
once two builds of that screen pass without it. A memo now keeps its own copy of the text it is keyed
by. `L` makes a key into a kept buffer (`keyed_make.ludic`), so a miss costs the one string it keeps;
an argument that holds a key is kept once per distinct text. `ludic.ui/tests/ui_made_test` shows
fifty values made and at most two held; `ludic.i18n/tests/made_test` that `i18n_made` makes what `L`
makes.
