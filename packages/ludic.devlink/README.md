# ludic.devlink

An editor's live link into a running dev build: the wire protocol v1 frozen in
`game-editor/proposals/2026-09-29-devlink/protocol-v1.md`. Uses `ludic.base` and nothing else.

- **Transport** is the `DevlinkNet` port (a game binds `Udp.*`, a test a fake). One request a frame, read
  from one fixed 8 KB buffer and answered into another; nothing is made per frame. Only a loopback sender
  is answered (`DevlinkNet.loopback`); the socket opens only when `DevlinkWorld.enabled()` says so (a
  game binds `dev_tools`), so a release build never opens it.
- **Verbs** are `DevlinkWorld` members, every default "not offered" (`err unbound`): `ping`, `hello`,
  `cam_get` / `cam_set` / `cam_release`, `goto`, `map_load`, `time`, `weather`, `shot`, `pause` / `resume`,
  `step`. `map_load`, `shot` and `step` answer later by id (5 s at most, one at a time). While
  `coop()` says a session is connected, everything but `ping` and `hello` is refused.
- **Call `devlink_tick`** once a frame from something that runs while the game is paused (not from a
  system the pause stops), or `resume` could never arrive.

Tests: `ludic test packages/ludic.devlink` (a fake transport and world; each answer byte for byte).
