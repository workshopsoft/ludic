bump: patch
type: fix
**`--emit-schema`: an empty `def X from "f.lres"` file is a contributor.** A resource file that a `def` (or a
registry's `from`) reads but that holds no entries yet is now listed in the registry's `contributors` as
`{"kind": "resource", "file": ..., "via": ..., "module": ..., "keys": []}`, after the files that brought entries.
Before, the registry exported `"contributors": []` and a tool could not tell which file its first row belongs in.
