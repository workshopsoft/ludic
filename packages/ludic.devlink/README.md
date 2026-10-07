# ludic.devlink

An editor's live link into a running dev build: the wire protocol v1 frozen in
`game-editor/proposals/2026-09-29-devlink/protocol-v1.md`. Uses `ludic.base` and nothing else.

- **Transport** is the `DevlinkNet` port (a game binds `Udp.*`, a test a fake). One request a frame, read
  from one fixed 8 KB buffer and answered into another; nothing is made per frame. A request's texts (a string argument, a path) are the request's: made when it is
  read and let go when the next one is, a shot's path when the next shot is - a port member or a verb that wants one
  longer copies it (`keep`). Only a loopback sender
  is answered (`DevlinkNet.loopback`); the socket opens only when `DevlinkWorld.enabled()` says so. Its default is `dev_mode()` from `ludic.base`
  (the `R3D_DEV` environment variable set to anything but `0`, see docs/SHIPPING.md), so a game binds nothing
  and a player's run never opens it; bind `enabled` only for a rule of the game's own.
- **Core verbs** are `DevlinkWorld` members, every default "not offered" (`err unbound`): `ping`, `hello`,
  `cam_get` / `cam_set` / `cam_release`, `shot`, `pause` / `resume`, `step`. `shot` and `step` answer later
  by id (5 s at most, one at a time). While `coop()` says a session is connected, everything but `ping` and
  `hello` is refused. `DevlinkWorld.offers()` names only the core verbs the game bound.
- **Probes** ask the game's physics what a player would meet (not the authored heightmap): `DevlinkWorld.ground`,
  `ray` and `settled`, unbound by default. `ground x z` answers `ok y` (`err failed "no ground there"` when the
  game answers `DL_GROUND_NONE`); `ray ox oy oz dx dy dz max` answers `ok true t x y z` (`t` the distance along the
  direction, which devlink normalises) or `ok false`, with `err bad_args` for a zero direction or a max <= 0;
  `settled` answers `ok true` or `ok false` (the member returns 1, 0, or `DL_UNBOUND`): the world around the
  player is ready for a shot, and the game decides what that takes (physics for the cell made, streaming idle,
  the body grounded). `ground` and `ray` are `unbound` until bound. Numbers are written with three decimals,
  like `cam_get`. **`offers()` stays the game's own string**: a game that binds the probes adds
  `ground,ray,settled` to it so `hello` lists them.
- **`window w h retina?`** pins the drawable so a shot is the same size on every machine: the window's content size
  in points (160 to 7680) and the backing-resolution (Retina) drawable on or off (off unless `true`), through the
  runtime's `Gfx.set_window` / `Gfx.set_retina`. It answers `ok w h retina` with the drawable the window has after
  the call (points times the live pixel scale, what `shot` writes). Always answered, no binding, not listed in
  `hello`'s offers; refused while `coop()` like every verb but `ping` and `hello`; a no-op headless (the answer is the
  asked size at scale 1).
- **Declared verbs** are everything that belongs to a game or a package: `goto`, `time`, `weather`,
  `map_load`, a store's `steam_state` / `unlock`. Whoever owns one declares it with `def DevVerbs` (see below);
  devlink knows none of them.
- **The interface's verbs** are `DevlinkUi` members, the same default: `ui_screen` answers the screen's root
  class and every component up; `ui_focus` answers
  `ok "key" "id" at count "screen"` (the focused control's key, the handle a tool hands back to the interface; its authored
  id, `""` for none; its place among the focusable controls shown, -1 for none; how many there are; the screen they
  belong to), and before the first frame `ok "" "" -1 0 "<screen>"`, not an error; `ui_model "<Class>" "<out>"` and `ui_tree "<out>"` have the game write the
  first instance's model, or the whole tree, to that file (no `..`) and answer `ok "<out>"`, so a datagram
  stays small; `ui_override "<path>" "<file>"` has the interface read a template or stylesheet from that file
  and reload it keeping state (`""` for the file clears one, `"" ""` clears all). All answer at once.
- **Keys and text** are declared by devlink itself (`verbs_key.ludic`), so every game offers them with no binding.
  They go through `Input.press` / `Input.release` / `Input.type`, the layer the window feeds, so a game reads
  them as real input: `key_down` while held, `key_pressed` on the frame it went down.
  - `key "<name|code>" "down"` / `"up"` hold and let go a key at once; `key "<name|code>" "tap" ms?` presses it
    and lets go after `ms` (default 80, 0 to 4000), answering `ok <ms>` once it is let go;
    `key_repeat "<name|code>" n every_ms` presses `n` taps of 80 ms, one every `every_ms` (at least 80), answering
    `ok <n>` after the last. `n * every_ms` is at most 4000 (a late answer has `late_s`, 5 s), anything more is `bad_args`.
  - Names: `up down left right enter escape tab space backspace shift`, `w a s d f r t q e z c x v`, or a code 8 to 255.
  - `text "<string>"` queues the text (at most 256 bytes, `err failed` while 256 bytes are still waiting): the next
    `Input.text()` returns it once, when the window typed nothing that frame.
  - `tap`/`repeat` time in real time, for a running game; in a paused scenario use `down`, `step n`, `up`.
  - A `tap` on a key that `down` is already holding releases it at the end. While a `tap` or `key_repeat` is
    parked, any other `key` or `key_repeat` is `err refused` busy (one late request at a time).
- **Call `devlink_tick`** once a frame from something that runs while the game is paused (not from a
  system the pause stops), or `resume` could never arrive.

## Port and run file: several games on one machine

The link no longer owns port 47200 alone. `LUDIC_DEVLINK_PORT` picks the UDP port the game opens: a number, or
`0` for any free one (unset, or not a number up to 65535, keeps 47200). A game that binds `DevlinkWorld.port`
keeps its own rule. When the socket opens, the game writes what it actually bound to a **run file**:

`<dir>/ludic-devlink-<pid>.json`, one line:
`{"v":1,"pid":123,"port":53412,"game":"meridian","project":"/path/to/project","build":"/path/to/binary"}`

- `dir` is `LUDIC_DEVLINK_RUN_DIR` when set (a launcher that wants the files in a project passes
  `<project>/.studio/local/run`, which it creates: Ludic has no mkdir), else `Os.temp_dir()` (`$TMPDIR`, or `/tmp`).
- `project` is `LUDIC_PROJECT`, else the shell's `PWD`; `build` is `argv[0]`. The file's mtime is the start time.
- The port comes from `DevlinkNet.bound` (default `Udp.port`), the write goes through `DevlinkNet.publish`
  (default `Fs.write_bytes`); both are ports so a test captures them.
- Ludic has no file removal and no exit hook, so a game that quits **leaves its file**. A client checks that the
  pid is alive (and that the port answers `hello`) and deletes the file when not.

Model: Chrome's `--remote-debugging-port=0`, which writes the chosen port to `DevToolsActivePort` in the profile
directory so a driver can find it. Same idea, one file per process so several games coexist.

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
(started: devlink calls `late(c)` every frame until it answers 1 done, 0 not yet or -1 failed (a done answer's values are written in `late`, `run`'s are not kept), within
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

## Entity verbs: `player`, `<kind>_near`, `<kind>_get`

The packages that own entities declare the same three shapes, so any game using them offers them with no code
and a studio fans out to whichever `*_near` verbs `hello` lists. Today: `ludic.character` declares `player`,
`ludic.crowd` `peds_near` / `ped_get`, `ludic.cars` `cars_near` / `car_get`.

- `player` answers `x y z yaw vx vy vz grounded`.
- `<kind>_near x z r max?` answers `n`, then `n` records of a fixed number of values, nearest first (ties: the
  lower id first). `max` defaults to `DV_NEAR_DEFAULT` = 12 and is clamped to `DV_NEAR_MAX` = 16 (and to what the
  reply holds), so the answer stays inside the `DV_OUT` = 1024 byte cap: a list answer is always bounded, and a
  record is at most about 60 bytes. A negative `r` is `bad_args`. Records start with the id:
  `peds_near`: `id x y z yaw act speed`; `cars_near`: `id x y z yaw speed engine_on`.
- `<kind>_get id` answers the record without the id: `ped_get`: `x y z yaw act speed lod`; `car_get`:
  `x y z yaw speed engine_on`. An id that is gone is `bad_args`.
- **yaw**: degrees, render3d's, 0 -> -z, 90 -> -x, [0, 360). A package whose own yaw faces (sin, cos) converts
  with `dv_reply_yaw(c, yaw + pi)`. Positions are metres, speeds m/s, a bool is `dv_reply_bool`.

A package adds its own kind by declaring `<kind>_near` and `<kind>_get` in this shape and using
`dv_near_limit` (`ludic.base`) for the bound.

## `hello`, with shapes

`<id> ok 1 "<game>" "<build>" "<schema hash or 0>" "<map key>" "<verb,verb,...>" "<shapes>"`

- The sixth value (v1): the core verbs the game offers, the interface's (`DevlinkUi.offers()`, which the game states itself: a member is never probed, some act), then the declared ones, comma-separated. A v1 client
  reads it as before.
- The seventh value (added, protocol v1.1; a v1 client reads six values and ignores it): the declared verbs
  with their shapes, `;` between verbs, each `key` or `key name:type name:type?...`, for example
  `"goto x:float z:float yaw:float?;time hour:float day:int?;weather key:string;steam_state"`. No seventh
  value means a devlink older than this one: names only. The shapes are the `args` text verbatim, so
  a client splits on `;`, then on the first space, then on spaces, then on the last `:` and a trailing `?`.

Tests: `ludic test packages/ludic.devlink` (a fake transport, world and interface; each answer byte for byte).
