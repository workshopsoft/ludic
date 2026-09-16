bump: minor
type: feat
The JetBrains plugin covers much more of the IDE:
- Run configurations for `ludic run`/`build`/`test` (plus any other `ludic` command), with
  gutter run buttons on `program` and on every `test "name"` block.
- Test results appear in the IDE's test tree, with navigation back to each test block.
- `file.ludic:line` locations are clickable in every console.
- Smart indentation on Enter and when typing a closing bracket; quotes pair up.
- A Color Scheme page and a Code Style page.
- Live templates, New Ludic File templates, and a Ludic project in File | New | Project.
- A Tools | Ludic menu, and a warning when the toolchain is missing.
- `package.ludic` is treated as a package manifest:
  - a banner offers Fetch, Update, Verify, Run, Test, Build and Bundle, and warns when the lock is
    missing or older than the manifest;
  - gutter actions on `package` and `require` lines;
  - completion and quick documentation for directives and `app` keys;
  - its own icon.
- `script` and `hook` lines complete and are validated; each script has a run button, the
  package banner has script shortcuts, and Tools | Ludic | Run Script… lists them all.
- The toolchain's and the project's packages are listed under External Libraries.
- The Structure view, parameter info and code-block navigation now come from `ludic-lsp`.
- The plugin is now 1.4.0 and requires IntelliJ Platform 2024.2 or newer and LSP4IJ 0.21.
- Fixed: Enter no longer inserts an extra `}`, and Comment Line no longer writes two spaces.
