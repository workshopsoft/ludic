bump: minor
type: feat
**Check an unsaved buffer.** `ludic build --check --diagnostics=json --stdin-file <path>` (and
`ludicc --check --stdin-file <path>`) checks the program as usual, but wherever the compiler would open
`<path>` - the entry, an import reached through a barrel, a component's `.xml` / `.lss`, an `.lres` -
it reads the text on stdin instead, so an editor's diagnostics follow typing without a save. Paths are
matched after normalising both (separators, relative to the working directory, `.` / `..` folded).
Diagnostics carry the file's usual name with lines and columns in the buffer; a `<path>` the program
never opens is reported as one warning.
