# ludic.devlink

An editor's live link into a running dev build: the wire protocol v1 frozen in
`game-editor/proposals/2026-09-29-devlink/protocol-v1.md`. Uses `ludic.base` and nothing else.

- **Transport** is the `DevlinkNet` port (a game binds `Udp.*`, a test a fake). One request a frame, read
  from one fixed 8 KB buffer and answered into another; nothing is made per frame. Only a loopback sender
  is answered (`DevlinkNet.loopback`); the socket opens only when `DevlinkWorld.enabled()` says so. Its default is `dev_mode()` from `ludic.base`
  (the `R3D_DEV` environment variable set to anything but `0`, see docs/SHIPPING.md), so a game binds nothing
  and a player's run never opens it; bind `enabled` only for a rule of the game's own.
- **Core verbs** are `DevlinkWorld` members, every default "not offered" (`err unbound`): `ping`, `hello`,
  `cam_get` / `cam_set` / `cam_release`, `shot`, `pause` / `resume`, `step`. `shot` and `step` answer later
  by id (5 s at most, one at a time). While `coop()` says a session is connected, everything but `ping` and
  `hello` is refused. `DevlinkWorld.offers()` names only the core verbs the game bound.
- **Declared verbs** are everything that belongs to a game or a package: `goto`, `time`, `weather`,
  `map_load`, a store's `steam_state` / `unlock`. Whoever owns one declares it with `def DevVerbs` (see below);
  devlink knows none of them.
- **The interface's verbs** are `DevlinkUi` members, the same default: `ui_screen` answers the screen's root
  class and every component up; `ui_model "<Class>" "<out>"` and `ui_tree "<out>"` have the game write the
  first instance's model, or the whole tree, to that file (no `..`) and answer `ok "<out>"`, so a datagram
  stays small; `ui_override "<path>" "<file>"` has the interface read a template or stylesheet from that file
  and reload it keeping state (`""` for the file clears one, `"" ""` clears all). All answer at once.
- **Call `devlink_tick`** once a frame from something that runs while the game is paused (not from a
  system the pause stops), or `resume` could never arrive.

## Declaring a verb

```ludic
# doc-check: skip — a fragment of a game or package module
function goto_verb(c: DevCall) -> int {                       # its own states are supplied, as for a system
  if not teleport(dv_float(c, 0), dv_float(c, 1)) { return DV_UNBOUND }
  dv_reply_float(c, px())                                     # the values after "ok"
  return DV_OK
}
def DevVerbs goto { args: "x:float z:float yaw:float?", run: fn goto_verb }
```

A verb is a row of the open registry `DevVerbs` (`ludic.base/devverb.ludic`): `key`, `args`, `run`, and for
a verb that can take a while `late` and `late_s`. Its `run(c: DevCall) -> int` answers `DV_OK`, `DV_LATER`
(started: devlink calls `late(c)` every frame until it answers 1 done, 0 not yet or -1 failed, within
`late_s`, 5 s by default, one at a time, the later request refused `busy`), `DV_FAILED` (`err failed`),
`DV_BAD` (`err bad_args`, for a value out of range) or `DV_UNBOUND` (`err unbound`, this build does not
offer it). `c.why` is the message of a failure, and `dv_reply_int` / `_float` / `_bool` / `_str` write the
values after `ok`.

**`args`** is the shape: space-separated `name:type` words, type `int`, `float`, `string` or `bool`, a `?`
after the type making it optional (optionals come last; at most `DV_MAX_ARGS` = 8). Devlink reads the request
against it before `run` is called: too few, too many, or one that does not parse is
`err bad_args "bad arguments: goto x:float z:float yaw:float?"`. `run` reads argument `k` (by position) with
`dv_float(c, k)`, `dv_int`, `dv_bool`, `dv_str`, and `dv_has(c, k)` says whether an optional one was given.
Wire syntax: an int is decimal, a float a plain decimal, a string double-quoted, a bool the word `true` or
`false`. A verb whose shape is malformed, or whose key has a space, a quote, a comma or a semicolon, is
not listed and answers `err failed "the verb is declared badly"`; a verb with no `run` does not exist.

**Why an open registry.** The fixed `if` chain had one place for every verb, so a package could never add one.
Options weighed: a port (one binding: the game would have to forward every package's verbs by hand and could
not describe them), an `@Attribute` on functions (needs compiler work, and the shape would be a string anyway),
`@On` events (fire every listener, no reply and no lookup by name). `ludic.base` already answers "a package
adds a row to a table someone else reads" with `open registry Systems` and `def Systems key { ... }`: the rows
are compiled into an array before any code runs, the owner declares the verb next to its function in its own
module, a duplicate key is a compile error, nothing is registered at run time and nothing is made per frame.
The registry and `DevCall` live in `ludic.base` (not here) because a mechanic may use only `ludic.base`: a
package such as a Steam mechanic can declare its verbs without depending on devlink. Devlink is the only reader.
A release build carries the rows (a few function values) but never opens the socket.

## `hello`, with shapes

`<id> ok 1 "<game>" "<build>" "<schema hash or 0>" "<map key>" "<verb,verb,...>" "<shapes>"`

- The sixth value (v1): the core verbs the game offers, then the declared ones, comma-separated. A v1 client
  reads it as before.
- The seventh value (added, protocol v1.1; a v1 client reads six values and ignores it): the declared verbs
  with their shapes, `;` between verbs, each `key` or `key name:type name:type?...`, for example
  `"goto x:float z:float yaw:float?;time hour:float day:int?;weather key:string;steam_state"`. No seventh
  value means a devlink older than this one: names only. The shapes are the `args` text verbatim, so
  a client splits on `;`, then on the first space, then on spaces, then on the last `:` and a trailing `?`.

Tests: `ludic test packages/ludic.devlink` (a fake transport, world and interface; each answer byte for byte).
