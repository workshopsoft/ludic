bump: patch
type: fix
A `test` block that shows a ludic.ui component works in every test of its file, not only the
first. The runner re-ran the globals' initializers (where each component registers itself) and
only then forgot the states, so every later test started with a fresh `UiState` that had no
components: "there is no screen X". The states are now forgotten first. A screen that does not
exist is still an error in `ui_errors`, and `ui_nodes` hands back an empty screen instead of null,
so looking at it no longer crashes.
