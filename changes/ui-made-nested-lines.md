bump: patch
type: fix
**An element's text with a line bracketed in it is made and let go like a line with holes.** "[E / L click] Pick up
firewood" shown as an element's text went to the translator, which kept one per distinct line; while a screen is
built it now goes through the backend's maker (`md_holes`, `md_nested`) and is held by the screen's pool, let go two
builds after the last that showed it.
