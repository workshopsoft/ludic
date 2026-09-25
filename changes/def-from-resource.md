bump: minor
type: feature
**`def Recipes from "recipes.lres"` - a game fills a package's open registry from its own resource
file.** The entries are checked against the registry's record as the file is read, with errors at
the resource file's line, and they are defs of the module that wrote the line: the registry must be
open to it, and they sit in the stable order (the declaring module's entries, then other modules'
by name, and file order within a file).
