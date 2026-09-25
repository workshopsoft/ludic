bump: minor
type: feature
**A module's private names are its own.** A function, var or const a module does not export no
longer collides with the same spelling in another module, in a file in no module or in the
runtime: each private one is compiled under its module's name (`seed$shop`) and its module's
references follow it. Exported names are still one namespace, and two exports of one name are
still refused. Records and events still share one namespace. A program with no such clash compiles
exactly as before.
