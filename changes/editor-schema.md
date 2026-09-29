bump: minor
type: feat
**A schema for editors, and every error as JSON.** `ludicc --emit-schema out.json` (and `ludic
schema [file] [-o FILE]`) writes what the compiler resolved once the program type-checks: every
record with its fields' types, defaults, doc comments and places; every registry with its record,
prefix, resource file, openness and its entries in their final order after the open-registry merge
(key, constant, index, file:line:col of the entry and of each field value, and which file brought
which entries in); every const; and every function a `fn` value can name, with the `fn_type` a field sees (its states stripped).
Deterministic, `"schema_version": 1`. Fields and registries carry editor attributes on the existing
`@` syntax - `@Ref(Registry)`, `@OneOf(PREFIX_)`, `@Range(lo, hi)`, `@Unit("m/s")`, `@Asset("gltf")`,
`@Color`, `@Node(field)`, `@Clip(field)`, `@Material(field)`, `@Tint(SLOT)`, `@Derived`, `@Text`, `@Multiline`, `@Key`, and `@AppendOnly` / `@ByKey` on
a registry - which change nothing but go into the schema; `@Ref` naming no registry is an error, and
so is `@Node` / `@Clip` naming a field that is not a glTF (`@Asset("gltf")`, or an `@Ref` to one), and
a listing `@OneOf` (`@OneOf(A, B)`, not a prefix `@OneOf(P_)`) naming a constant that does not exist, and `@Tint` naming no constant. A field may now carry several attributes. `ludicc --check
--diagnostics=json` (`ludic build --check --diagnostics=json`) prints every error as one JSON array
of `{file, line, col, severity, message}` on stdout; tokens and nodes now know their column.

`Build.schema_hash()` answers FNV-1a 64 of the program's own schema (the bytes `ludic schema` prints),
computed only when a program names it, and 0 under `ludicc --release`, which `ludic bundle` now passes.

A target no part of the program declares (an `@Ref` registry, an `@Tint` or listed `@OneOf` constant) is
a warning and `"unresolved": true` in the schema, so a package can name the game's registry; a name of
another kind is an error. `@OneOf` on a string field takes words, and every registry row's value is
checked against them.

The schema has a `components` list: each UI component's module, place, doc, template and stylesheet
paths, its `props` and `state` (type, default as written, place, doc), `states_read` (the states its
header names, apart from its model), `derived` fields with their types, and the `functions` and
`events` its template calls with their parameters (states and instance stripped), and the
registered native tags its template uses. A `natives` list gives every `ui_native` /
`ui_native_input` call with a literal tag: the tag, the function called, its handler and its place.
