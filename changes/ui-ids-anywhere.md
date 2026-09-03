bump: patch
type: fix
A `UI_Name` handle can be read from any code — a plain function, an `@On(UiClicked)` listener, a global initializer — not only from handlers and scene hooks. The widget table it indexes is now built on first use instead of when `@ui_build` is emitted, which came after functions and listeners and crashed the compiler on such a reference.
