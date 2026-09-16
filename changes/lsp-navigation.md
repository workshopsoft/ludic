bump: minor
type: feat
`ludic-lsp` navigates like the compiler resolves:
- Package imports (`import "ludic.render3d/r3d.ludic"`) resolve from `ludic_modules/` and the
  toolchain's `packages/`, so their names hover, complete and jump. Import strings are links.
- `var` locals are tracked (declaration, usages, rename).
- Hover shows the declared or inferred type of locals, parameters and globals.
- Hover and go-to-definition on built-ins, built-in types and namespaces show the reference
  page, with a link to the online docs. Release archives now ship `docs/language` for this.
- Go to type declaration (`textDocument/typeDefinition`) is supported.
- Signature help carries per-parameter ranges and follows named arguments.
- Completion inside a call offers the parameter names not given yet, `Namespace.` offers its
  members, and results are ranked: locals first, then globals, built-ins and keywords.
