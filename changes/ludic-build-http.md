bump: patch
type: fix
**`ludic build` links `Http.*`** — a program that uses the HTTP client builds through the CLI.

`compile_app` linked the OpenGL backend when a program named `@lgl_*` but never
`runtime/native/http.ll` and Foundation for `@hs_*`, so a `Http.*` program failed to link
under `ludic build` / `ludic run` while `ludicc -o` built it. It now links them the same way,
windowed and headless.
