bump: minor
type: feat
**A schema for editors, and every error as JSON.** `ludicc --emit-schema out.json` (and `ludic
schema [file] [-o FILE]`) writes what the compiler resolved once the program type-checks: every
record with its fields' types, defaults, doc comments and places; every registry with its record,
prefix, resource file, openness and its entries in their final order after the open-registry merge
(key, constant, index, file:line:col of the entry and of each field value, and which file brought
which entries in); every const; and the functions a `fn` value can name with no arguments.
Deterministic, `"schema_version": 1`. Fields and registries carry editor attributes on the existing
`@` syntax - `@Ref(Registry)`, `@OneOf(PREFIX_)`, `@Range(lo, hi)`, `@Unit("m/s")`, `@Asset("gltf")`,
`@Color`, and `@AppendOnly` / `@ByKey` on a registry - which change nothing but go into the schema;
`@Ref` naming no registry is an error. A field may now carry several attributes. `ludicc --check
--diagnostics=json` (`ludic build --check --diagnostics=json`) prints every error as one JSON array
of `{file, line, col, severity, message}` on stdout; tokens and nodes now know their column.
