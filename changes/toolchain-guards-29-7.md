bump: patch
type: fix
**Four guards an editor and a game asked for.**

- **Two registries with one prefix say so.** Two registries that both say `as DRK` both make
  `DRK_COUNT`, which was already refused as `'DRK_COUNT' is defined twice (first in ...)`; the
  message now names both registries and the prefix they share (`registries DrinkSteps and
  DrinkRules both say 'as DRK' - give one of them a prefix of its own`), and a const written by
  hand that meets a registry's says which registry made the other.
- **`@Asset("kind", optional)` needs no `map`.** A path under the game's root may be optional too;
  it changes nothing the compiler checks and tells an editor that a row may leave the field empty.
  `@Asset("kind")`, `@Asset("kind", map)` and `@Asset("kind", map, optional)` are as they were, and
  `map` still comes before `optional`.
- **`ludic schema` lists a package with no module line.** `code.modules` names it for its folder
  (`ludic_render3d`), with its files, as `ludic deps` already did, so an editor reading the schema
  no longer has to mirror `pkg_name_of`.
- **A handler's body is type-checked.** The checker read a function's body, the entry, the tests and
  the listeners, and left a handler's to the emitter, so a call from a handler that left out an
  argument or a state, gave one too many, or a `let s: string = 3` compiled (a left-out state
  arrived as null). A handler is checked as a function is now; a C function called from one wants
  `--unsafe` like any other (L7). Three examples that did arithmetic on a `bool` or a `countdown`
  say `int(...)`.
