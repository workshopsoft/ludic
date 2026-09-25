bump: minor
type: feature
**`export open registry Items of Item` - a registry other modules may add to, in a stable order.**
A `def` from another module into a registry that is not open is refused, and a def now goes
through visibility like any reference (the registry exported, its module in the definer's `uses`).
An open registry's index order is the declaring module's entries first, then every other module's
by module name, each in the order it is read - independent of the order a barrel imports them in.
