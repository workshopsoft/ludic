bump: patch
type: fix
**A name that meets a package's export says whose it is; ludic.ui's `UiAct` is its own.** A game's
`UiAct` collided with ludic.ui's, which no program uses - it is private to ludic.ui now, so the game
may have one. A real clash - a type named like one a package exports - is still refused, and the
message names the package and the way out: `'UiNode' is defined twice (...): ludic_ui exports it, and
exported names are one namespace - rename this one, or declare it without export inside a module of
your own`.
