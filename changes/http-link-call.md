bump: patch
type: fix
**`ludic build` links `http.ll` only into a program that uses `Http.*`.**

The check that added it grepped the IR for `@hs_`, which every program's header declares,
so the HTTP transport and Foundation were linked into everything. That cost nothing visible
on macOS and failed the link on Linux, where `ludic build`, `ludic run` and a new project all
broke in CI. It now looks for a call to `hs_send`.
