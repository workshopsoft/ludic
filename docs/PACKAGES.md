# Ludic packages

Ludic has a package manager built into the task runner (`bin/ludic`). It fetches,
resolves, stores and links third-party packages with no new infrastructure to
run — it drives plain `git` and rides on the Forgejo host and its release tags.

This is the v1 implementation of the direction decided in issue #63.

## The four decisions

| Axis | Ludic's choice |
| --- | --- |
| Where source comes from | **URL-as-identity, no registry.** The import path *is* the git location — `example.com/user/pkg`. A `git tag vX.Y.Z` publishes a version. No account, no publish step, no index to run. |
| Version resolution | **Minimum Version Selection (MVS), Go-style.** A `require` is a *minimum*; the resolver picks, per module, the greatest of every required minimum, then keeps the reachable closure at those versions. Deterministic, no SAT solver. |
| Where dependencies live | **A content-addressed global store + per-project links (pnpm-style).** One immutable store keyed by a file-content hash (`~/.ludic/store/<sha256>`); each project gets a light linked view under `ludic_modules/` instead of a full copy. |
| Manifest / lock | **`package.ludic`** (declared deps + provided namespaces + kind + targets) and **`package.lock.ludic`** (resolved versions + content hashes). |

## Commands

```
ludic new <name> [--template <t>]   a project from a starter; ludic templates [--json] lists them
ludic add <module>[@version]   add a dependency to package.ludic, then resolve + fetch + link
ludic remove <module>          the inverse of add: drop the require, what only it locked, its links
ludic get [--json]             resolve every dependency in package.ludic, link them, write the lock
ludic update [module]          bump a dependency (or all) to its latest published version, then relock
ludic verify                   check every locked package against the store by content hash
ludic vendor                   copy the resolved packages into ./vendor for hermetic/offline builds
```

`ludic add` with no `@version` picks the latest published tag and records it as the
minimum. All the install commands print the resolved build list and write
`package.lock.ludic`.

`ludic get --json` prints what the run changed in the lock as one JSON object on stdout (the
resolver's lines go to stderr): `{"added": [...], "removed": [...], "changed": [...], "unchanged": n}`,
an added or removed entry being the lock's line - `{"name", "version", "hash", "kind", "provides"}` -
and a changed one `{"name", "from", "to", "from_hash", "to_hash"}` (the versions, and the content
hashes beside them). The lock is compared before and after, in memory.

`ludic remove <module>` takes the `require` line out of `package.ludic` and re-reads the dependency
graph from the store's own copy of each locked package's manifest - no network - so the lock keeps
exactly what the remaining requires still reach: a package another one still requires stays locked
(at the version it had; `ludic get` settles versions), and what only the removed one brought in
leaves the lock with it. Each package leaving the lock loses its `ludic_modules/` link - the link
`add` made, never the store entry it points at, which other projects share; anything there that is
not such a link is left and reported, as is a copy under `vendor/`. A module `package.ludic` does
not require is refused (exit 1). Source that still imports a removed package is a warning, not a
failure - the caller may be about to delete it. If the store has no copy of a locked package, only
the named module leaves the lock, and it says so.

## Starter templates

`ludic new <name> [--template <t>]` copies a starter; `ludic templates [--json]` lists them (name,
title, a line on what it is, the packages it imports). `blank` (the default) is the original
scaffold and is built in. The others are directories under the toolchain's `templates/`, installed
beside `packages/`:

```
templates/third-person/
  template.ludic        title "..."  description "..."  uses "ludic.character" "ludic.lab"
  package.ludic         package "{{name}}"  ...
  src/main.ludic        program {{ident}} { ... }
  tests/smoke.ludic
```

Everything but `template.ludic` is copied, with `{{name}}` (the project's name) and `{{ident}}` (its
`program` identifier) replaced in every file; a `.gitignore`, `README.md` and `assets/` are added when
the template has none. Each one compiles: `ludic-dev test-templates` creates every template in a
scratch directory and runs `ludic build --check` on it. `ludic templates --json` is an array of
`{"name", "title", "description", "packages": [...]}`.

## The manifest — `package.ludic`

A line-oriented manifest. `#` starts a comment; strings are double-quoted.

```
package "example.com/you/greeter"   # this package's import path
version "1.2.0"                               # the version this checkout publishes
kind    source                                # source | prebuilt
provides "Greet"                              # the Foo.* namespace(s) it registers (repeatable)

require "example.com/you/util" "1.0.0"   # a dependency and its minimum version

# a prebuilt lib also declares the targets it ships:
# kind    prebuilt
# targets "native-arm64" "wasm32"
```

A consumer project's manifest is the same file, usually with only `require`
lines (the `package`/`version` fields describe a *publishable* package and are
optional for a leaf application).

### Release lines

`release <key> <value>...` lines configure `ludic release` (packing and uploading a bundled game with
Velopack's `vpk`): `release id`, `title`, `authors`, `channel <os> "<name>"`, `feed`, `keep`, `notes`,
`entitlements`, `sign`, `notary_profile`, `upload s3 "<bucket>" "<endpoint>"`, and `dir`, `exe`, `icon`.
They are read by the CLI and ignored by the compiler and the resolver. Credentials are never in the
manifest (`AWS_ACCESS_KEY_ID` / `AWS_SECRET_ACCESS_KEY`, or `--key-id` / `--secret`). Every line and
the steps it becomes are in [SHIPPING.md](SHIPPING.md#releasing-ludic-release).

### The entry program

`entry "src/game.ludic"` names the program `ludic run`, `build` and `bundle` compile
when no file is given. Without it the CLI tries `src/main.ludic`, `main.ludic`, then
the one file under `src/` that declares a `program`.

### Scripts and hooks

```
script "dev"    "ludic run --headless"       # ludic dev   (or: ludic script dev)
script "shots"  "tools/shots.sh"             # ludic shots a b  -> tools/shots.sh 'a' 'b'
hook before build  "tools/gen_atlas.sh"      # a failing before hook stops the build
hook after  bundle "tools/notarize.sh"       # after hooks run only when the command succeeded
hook before dev    "ludic fmt --check"       # a script is an event too
```

A **script** is a named shell command, run from the package root. `ludic <name>` runs
it when no built-in command has that name; `ludic script <name>` always does, and
`ludic scripts` lists them. Arguments after the name are passed on, quoted.

A **hook** runs a command `before` or `after` a built-in command (`build`, `run`,
`test`, `bundle`, `pack`, `clean`, `fmt`, `get`, `add`, `update`, `verify`, `vendor`,
`assets`, `build-lib`) or a script. Hooks of one event run in the order written. A
`before` hook that exits non-zero stops the command with that exit code; `after`
hooks run only when the command succeeded.

Both run through the shell with the toolchain's `bin/` first on `PATH` and
`LUDIC_PACKAGE_ROOT`, `LUDIC_EVENT` (the command or script) and `LUDIC_PHASE`
(`before`, `after` or `run`) set. Inside a quoted value, `\"` is a quote and `\\` a
backslash.

## The lockfile — `package.lock.ludic`

Generated by `ludic get`; do not edit by hand. One line per resolved module, pinning
its selected version, content hash, kind and provided namespaces:

```
# package.lock.ludic — generated by `ludic get`. Do not edit by hand.
lock 1
module "example.com/you/greeter" version "1.2.0" hash "sha256:…" kind "source" provides "Greet"
module "example.com/you/util"    version "1.0.0" hash "sha256:…" kind "source" provides "Util"
```

`ludic verify` rehashes each store entry and confirms the project links to it, so a
tampered or missing dependency is caught before it reaches a build.

## The store and the project view

Fetched packages live once in a global, immutable, content-addressed store:

```
~/.ludic/store/<sha256>/…        the package tree at a version (no .git)
~/.ludic/store/cache/<module>/   a git clone cache used during resolution
```

Each project gets a lightweight view — `ludic_modules/<import-path>` is a symlink
into the store — so many projects share one copy and nothing is duplicated
per-project. Override the store location with `$LUDIC_STORE`.

## Names two packages must not share

Everything a package **exports** is one namespace with every other package's and the game's: a type,
a property, a registry, a constant, an `export function`. So is a registry's **prefix**
(`registry Regions of Region as REGION` makes `REGION_*` constants), and so are an action's and a
`@Net` action's names. Two packages that compile alone can therefore refuse each other inside a
game (`'X' is defined twice`, a `@Ref` that names a property instead of a registry) and the first
sign is in the game that imports both.

The rule: **a package's prefixes and exported names start with a stem that is its own.**

- A registry prefix is the package's stem, then the thing: `lobby` -> `LBO_`, `missions` ->
  `MISSTEP` (not `MSTEP`, which `ludic.melee` has). Take the first letters of the package name, and
  when the stem is short or another package's, lengthen it. A prefix that is an English word
  (`REGION`, `STEP`, `ZONE`) is not a stem: it will be another package's word too.
- A type, registry or function name a package exports carries its own word (`Lobby*`,
  `Vitals*`, `Crew*`) or, for a generic noun (`Step`, `Node`, `Zone`), is not exported: declare it
  without `export` inside a module of the package, where only the package sees it.
- A `@Unit` is one of the compiler's list (`LANGUAGE.md`); a package cannot add one.
- A `@Ref(X)` to a registry the **game** supplies (`Items`, `Resources`, `Stats`) stays a
  warning in a program that has no `X`; it is the game's to declare, never the package's.

`ludic-dev check-packages` holds the line: it generates one program that imports every first-party
package that can be imported from a checkout, binds nothing, and runs `ludicc --check`. A
declaration error fails it and names the packages in the message (`packages involved:
ludic.lobby, ludic.crews`). What it expects and ignores, matched exactly: `port X is used here but
never bound` and the `@Ref(X): this program has no X` warnings. The older single-file library
packages (`ludic.core`, `ludic.gameplay`, `ludic.rpg`, ...) are checked together in a second
program, since they define unprefixed names (`Stats`) that the modern ones leave to the game. Run
it after adding a package, a registry or an export; CI runs it on every push.

## Naming a model — how a row reaches the game's own model table

A package never draws, so a record that stands for something on screen has to say which mesh. The convention is one
pair of fields, the same in every package:

```ludic
@Asset("gltf") model: string = ""      # the glTF file, as a path under the game's assets
@Node(model) node: string = ""         # a node inside it ("" for the file's root); a record with several nodes
                                       # names each by its purpose (`body_node`, `muzzle`, `mount_*`)
```

The **path is the link**. A package row does not hold a key into a registry only the game has (a `@Ref(Models)` would
be a reference the package cannot declare and a game's table it cannot know the name of), and the game does not match
rows to models by a naming convention in code (`models_find(CarModels[m].key)`). The game's own model table declares
the same file as a field of its own row (`@Asset("gltf") path`) and finds a row by the path a package row carries.
The studio's model viewer, socket editor and seat editor read `model`, and `@Node(model)` and `@Clip(model)` validate
and offer the names inside that file, so they need nothing from the game.

Where it is: `CarModel.model` / `body_node` (ludic.cars; its sockets and seats name nodes of the same file),
`Weapon.model` and its `mount_*` / `muzzle` nodes, `Attachment.model`, `AvatarBody.model`, `VehicleSpec.model`,
`FurnitureItem.model`, `PedLook.model`, and the city's `model` / `node` pairs. A new package that has a record drawn
as a model uses these two names, with `@Clip(model)` for any animation the model carries. A record that can only
be given a body by a game's own rules (a citizen archetype's `look`, a pool of bodies per kind of person) keeps a
key string for the game and says so in its comment; it does not invent a second way to name a file.

## Consuming a package — namespace registration

A **source package** ships plain Ludic. The consumer imports the package files by
their import path:

```
program App {
  import "example.com/you/greeter/greet.ludic"
  entry { print(greet_hello()) }
}
```

The compiler resolves an import first relative to the importing file, then — for
a non-absolute path that is not found — under the package module root
(`$LUDIC_MODULES`, default `ludic_modules/`). So a fetched package's code is
spliced into the build and its namespace becomes available exactly the way the
built-in stdlib namespaces (Regex.\*, Grid.\*, …) are.

The **engine runtime is the exception** (issue #75): the compiler auto-splices
`runtime/native/*` for any ECS game, and that runtime ships with the *toolchain*,
not the project. A `runtime/...` import that is not found relative to the build is
resolved from the install root **`$LUDIC_HOME`** (default: the compiler binary's
directory — the same place the platform `.ll` files come from), *before* the
package module root. So an external game does not have to copy or symlink the
engine runtime into its `ludic_modules/`; that directory holds only third-party
packages. In-repo builds are unaffected — the runtime resolves locally there. Because Ludic compiles
ahead-of-time, a source package is compiled *into* the consumer's binary — no
ABI seam, and the whole-program guarantees (determinism, replay, `world_save`)
still hold.

Two packages may not register the same `Foo.*` namespace — a collision is a hard
error naming both modules.

## Package-declarable namespaces and engine systems (issue #62)

A package's namespace can also be an `alias` block (L6): `namespace Weapon { alias fire(slot) =
wp_fire_slot }` names each method and the function it calls, with its own labels, so the public
names need not be the implementation's. The engine's own `Http.*`, `Json.*`, `Screen.*` and the
rest are declared exactly this way, in `runtime/native/namespaces.ludic`.

A package can register two things that used to be compiler-hardcoded — a `Foo.*`
namespace and an engine-owned system — with **no compiler edit**, via two
keyword-free annotations. This is what lets gameplay-controller libraries ship as
ordinary packages instead of living in the compiler's stdlib.

- `@Namespace(Name)` on a function opens a `Name.method(…)` namespace that
  dispatches to the bare `name_method(…)` (the same generic path the built-in
  namespaces use, applied only after them so it never shadows a core one):

  ```
  @Namespace(Coach) function coach_bonus() -> int { return 99 }
  # a consumer then writes  Coach.bonus()
  ```

- `@EngineSystem(Component, Phase)` registers an engine-owned system: the frame
  loop calls it every `Phase` (after the game's own handlers) whenever the named
  `Component` is present — the package-declarable form of the built-in
  `SpriteAnim`/`Motion`/`Light2D` systems. It reads and writes components by name
  through the reflection ABI, so an unused registration is byte-identical:

  ```
  @EngineSystem(Score, Update) function esys_score() -> void { … }
  ```

The core stdlib namespaces and engine systems keep their own optimized codegen;
packages flow through the generic registry alongside them. (For a *prebuilt*
binary module, the runtime counterpart of `@EngineSystem` is `@System(Phase)` —
see below.)

## Prebuilt binary packages (issue #64)

A `kind prebuilt` package ships a **compiled artifact** (a native dylib per
target it lists in `targets`) instead of source. A consumer uses its exported
**functions, systems and components** without ever seeing the source. This is
the escape hatch for closed-source or other-language code; source packages stay
the default because they keep cross-compilation (including wasm) and the
compile-time ECS first-class. Prebuilt packages are **native-only** and ride the
stable reflection C-ABI — second-class ECS (dynamic, by-name components; one
indirect call per registered system), not part of the deterministic/replay core.

**How a binary module works.** The module is compiled with `--emit-module`: no
`main`, no world table (the consumer owns the single world). It carries a
load-time constructor that, when the dylib loads, registers its pieces against
the host through the C-ABI:

- **Components** — `world_register_prop(name, nfields)` in a `module_init`
  function; the host owns storage, the module reads/writes by name with
  `world_get`/`world_set`/`world_has`/`world_attach_dyn`.
- **Systems** — a function marked `@System(Phase)` is registered with
  `ludic_register_system`; the host's frame loop calls it every frame in that
  phase, after its own handlers. Phases: `Input`, `FixedUpdate`, `Update`,
  `LateUpdate`, `Render`, `Start`, `OnQuit`.
- **Functions** — plain functions become dylib symbols; a consumer binds them
  with `extern function name(...) -> T = "fn_name"`.

A module registers its `ludic_*` calls as undefined and binds them back to the
host image at load (`-undefined dynamic_lookup`); the host exports its ABI
(`-export_dynamic`). Every Ludic game is a capable host — the reflection ABI is
always emitted (unused parts dead-strip).

**Publishing.** In the package repo:

```
ludic build-lib module.ludic     # -> lib/<target>/lib<name>.dylib
# add `kind prebuilt` and `targets "<target>"` to package.ludic, commit lib/, git tag
```

**Consuming.** In the game project:

```
ludic add git.host/user/module   # kind prebuilt is resolved + the dylib linked into the view
ludic get                         # links the artifact for the build target (hard error if the target is missing)
```

then link the module dylibs into the game build. `ludic link-flags` prints the exact
clang flags (the dylib, an rpath to the store, `-export_dynamic`) for any build
system to splice into its link step:

```
clang -O2 game.ll $(ludic link-flags) -o game
```

(`ludic build` links them automatically when building in-repo.) If the package does
not ship the build target, `ludic get` fails — build from source instead where the
package offers it.

## Native libraries - a source package that carries a C/C++ library (phase 15)

A source package may link a native library of its own - a physics engine, a navmesh builder, an
audio renderer - by naming it per target in its `package.ludic`:

```
native "macos-arm64" "lib/macos-arm64/libjoltc.dylib"
native "windows-x64" "lib/windows-x64/joltc.dll"
```

The targets are `macos-arm64`, `macos-x64`, `windows-x64` and `linux-x64`
(`$LUDIC_NATIVE_TARGET` names another). The package's Ludic reaches the library through
`extern function` declarations, which only a package (or the runtime) may call (L7).

**Linked at build time, not opened with `dlopen`.** When the compiler loads a file from a
package, it reads that package's manifest once and keeps the libraries for the build's target;
they are written into the IR as `; ludic-native: <path>` lines, and every link reads that one
list - `ludicc -o`, `ludic build`, `ludic test` and `ludic bundle`. A program that imports no
such package links nothing new. Linking was chosen over a Vulkan-style loader because a missing
or mismatched library then fails at start-up, with the loader's own message naming it, rather
than at the first call deep in a frame; because an `extern function` is all the binding needs (no
generated thunk table per library); and because nothing here is optional the way Vulkan is - a
game that imports the physics package cannot run without it.

- **macOS**: the dylib's install name is `@rpath/lib<name>.dylib`. A build gets an rpath to the
  package's `lib/<target>/` (so `ludic run` and `ludic test` work in place) and one to
  `@executable_path/../Frameworks`. `ludic bundle` copies each library into
  `Contents/Frameworks` - never `Contents/MacOS`, which holds mach-o executables only (a Velopack
  update strips a detached signature) - removes the build machine's rpath from the executable,
  and signs every library before the app.
- **Windows**: the `.dll` is linked through its import library, `<name>.lib` beside it; `ludicc`
  copies the `.dll` beside the executable it writes, and `ludic bundle` beside the game's `.exe`.

**Built here from a pinned source.** A package's `native/build.sh` fetches the upstream tag,
checks its SHA-256, compiles the library and the package's shim with clang, and writes
`lib/<target>/` (committed through Git LFS). `tools/native/lib.sh` is what every such script
shares - `native_fetch`, `native_link`, the target and compiler - and it runs unchanged in Git
Bash on Windows with the LLVM installer's clang. The shim's rules (what may cross, how a
callback comes back) are in [packages/README.md](../packages/README.md#native-libraries);
`ludic.nativeecho` is the worked example.

### A native library you may not redistribute

Some libraries cannot be committed, downloaded by a script or shipped with the toolchain: the Steamworks SDK
(Valve's SDK Access Agreement) is the case. The package still declares them with `native` lines, but the files
those lines name do not exist in the repository; they are made on the developer's machine from their own copy:

```text
packages/ludic.steamworks/
  package.ludic        native "macos-arm64" "lib/macos-arm64/libludicsteam.dylib"
                       native "macos-arm64" "lib/macos-arm64/libsteam_api.dylib"    (Valve's, copied in)
                       native "windows-x64" "lib/windows-x64/ludicsteam.dll"  ... steam_api64.dll
  native/build.sh      STEAMWORKS_SDK=<sdk> sh native/build.sh  -> gen/ and lib/<target>/   (both git-ignored)
  native/shim/         the hand-written half, compiled against the SDK's headers (contains none of Valve's text)
  tools/steam_gen.ludic  reads <sdk>/public/steam/steam_api.json, writes gen/: C wrappers, Ludic externs, enum constants
```

- **Found at build time, from an environment variable.** `native/build.sh` needs `STEAMWORKS_SDK` (the SDK's
  root) and nothing else; it names the variable when it is missing. A second `native` line lists the vendor's
  runtime library, so `ludic bundle` copies and signs it into `Contents/Frameworks` (beside the `.exe` on
  Windows) like any other native library, and the game that ships it does so under its own agreement.
- **Bindings are generated, on the developer's machine.** The generator is checked in; its output - wrappers,
  `extern function` lines, enum values - is derived from the vendor's description of its own API, carries the
  vendor's identifiers, and is never committed (the package's `.gitignore` holds `gen/`, `lib/` and `build/`).
  Code that uses it says so by importing `gen/...`: without the build, only a game that imports the package fails.
- **The mechanic stays testable without it.** The package that uses the binding (`ludic.steam`) talks to a driver
  record, not to the library; its tests run on a fake, so `ludic test packages` needs no SDK, and a smoke check
  that does (`ludic.steamworks/check`) is not under `tests/`.
- **A build script must run from an install.** `~/.ludic` holds `packages/` and not `tools/`, so such a package carries
  its own copy of `tools/native/lib.sh` (`native/lib.sh`).

## Offline / hermetic builds

`ludic vendor` copies the resolved packages out of the store into `./vendor`. Build
against the copy with `LUDIC_MODULES=vendor`, so the build needs neither the
network nor the global store.
