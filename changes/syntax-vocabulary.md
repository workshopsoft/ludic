bump: minor
type: feat
**One vocabulary, from the compiler, for every editor.** `ludicc --emit-syntax` (`ludic syntax [--json] [-o FILE]`)
prints the language's words from the compiler's own table (`selfhost/frontend/vocab.ludic`): every keyword with its
role (declaration, modifier, statement, operator, constant) and whether the parser reserves it, every declaration's
form, the built-in types and phases, every attribute with what it goes on, its arguments and a one-line doc
(`@Ref`, `@OneOf`, `@Range`, `@Unit`, `@Asset`, `@Color`, `@Node`, `@Clip`, `@Material`, `@Tint`, `@Derived`,
`@Text`, `@Multiline`, `@Key`, `@AppendOnly`, `@ByKey`, `@PerMap`, `@Chunked`, `@max`, `@owns`, `@frame`, `@Sync`,
`@Computed`, `@alloc_ok`, ...), the operators and the literal forms. `"syntax_version": 1`. The emitter asks the
parser's own recognisers of every row and refuses one they disagree with.

`ludic-dev syntax` writes the keyword, type and phase lists of `ludic_syntax.h`, the TextMate grammar, the JetBrains
lexer, `ludic-mode.el` and the language server between marked lines; `ludic-dev syntax --check` (also run by
`check-vocabulary` and the regression suite) fails when one falls behind or lacks a word, when docs/language has no
page for a keyword, type, phase or attribute, or when the parser tests a word or reads an attribute the vocabulary
lacks. The grammars gain `module uses port bind action reducer dispatch registry def open component prop view alias
friend unsafe numbers of as from mut system` and more; docs/language gains a page for each of them and for every
editor, registry and memory attribute.

The language server's outline names every declaration by its own kind: `export property` / `state` are structs with
every field as a child (a field's default no longer swallows the fields after it), `event` / `action` events, `port`
an interface, `registry`, `enum` with its members, `component` / `view` with their props, state and events, and
`reducer S on A`. Hover and go-to-definition resolve an attribute's argument - `@Ref(Kits)` to the registry,
`@Node(model)` to the field it names - and hover on the attribute shows its reference page; a `fn(...) -> T` field
shows its whole type.
