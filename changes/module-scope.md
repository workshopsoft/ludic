bump: minor
type: feature
**Modules.** `module NAME` in a barrel makes its directory a module, and a module's
declarations are private to it unless they say `export`: a function, global, record or event of
another module used without one is an error naming the module and where to mark it. `friend
module NAME` sees everything (a test harness), a file in no module is public, and a package keeps
its own module. `LUDIC_VIS_REPORT=1` lists every violation instead of stopping, so an existing
program can be given its exports by a script before the rule applies to it.
