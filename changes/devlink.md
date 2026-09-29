bump: minor
type: feature
**`ludic.devlink`: an editor's live link into a running dev build** (protocol v1, frozen with Ludic
Studio). Loopback UDP through the `DevlinkNet` port, one request a frame parsed in place from one fixed
8 KB buffer and answered into another; every verb a `DevlinkWorld` member defaulting to "not offered":
`ping`, `hello` (the build's schema hash as 16 hex digits), `cam_get` / `cam_set` / `cam_release`, `goto`,
`map_load`, `time`, `weather`, `shot`, `pause` / `resume` / `step`, the slow three answered later by id.
A socket is opened only when `enabled()` says so (a game binds `dev_tools`), a sender off this machine is
dropped, and a connected co-op session refuses everything but `ping` and `hello`.
