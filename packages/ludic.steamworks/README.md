# ludic.steamworks

The Steamworks SDK as a Ludic package: the real backend of [`ludic.steam`](../ludic.steam/README.md). It is a
`SteamDriver` over the SDK's flat C API, through bindings **generated from the developer's own
`steam_api.json`** and a small hand-written shim. Steam networking, Cloud, lobbies, Input and the rest are
`ludic.steam`'s; this is only the connection to the library.

**The SDK is not here.** The Steamworks SDK is Valve's, under the SDK Access Agreement, and is not
redistributable in an open toolchain. Nothing of it is committed to this repository, now or ever: its
headers, its `steam_api.json`, its libraries and everything generated from them stay on the developer's
machine, in git-ignored `gen/`, `lib/` and `build/` beside this file.

## Enabling it in a game

1. Get the SDK from Valve (you need a Steamworks partner account and to have accepted the agreement) and
   unpack it somewhere. Its root is the folder holding `public/` and `redistributable_bin/`.
2. Build the bindings and the library from it, once per SDK version:

   ```bash
   STEAMWORKS_SDK=~/sdk/steamworks sh "$(dirname "$(command -v ludic)")/../packages/ludic.steamworks/native/build.sh"
   ```

   That reads `$STEAMWORKS_SDK/public/steam/steam_api.json` and writes `gen/`, compiles the shim and the
   generated wrappers against the SDK's headers, copies the SDK's runtime library beside the result, and
   leaves `lib/<target>/`. It is quick and does nothing when `lib/` and `gen/` are already newer than the SDK's
   JSON and this package's source, so a game may run it from a hook:
   `hook before build "sh <path to>/ludic.steamworks/native/build.sh"`. `STEAMWORKS_REBUILD=1` forces it. It needs
   clang and, like every package's `native/build.sh`, runs in Git Bash on Windows. `LUDIC_NATIVE_TARGET` names
   another target (`macos-x64`, `windows-x64`, `linux-x64`) as it does for every native package.
3. In the game:

   ```ludic
   # doc-check: skip — a fragment of a game
   import "ludic.steamworks"
   import "ludic.steam"
   program Game {
     bind SteamBackend { driver: fn steamworks_driver }
     ...           # then steam_config / steam_start / steam_system(), as ludic.steam's README says
   }
   ```

4. Development runs: `SteamConfig.dev = true` writes `steam_appid.txt` (the app id in the config) beside the
   executable and in the working directory, skips the relaunch through Steam, and so a build started from a
   terminal talks to the Steam client as that app. A release sets `dev = false` (the default): it never writes
   the file, and calls `SteamAPI_RestartAppIfNecessary` first, so a game started outside Steam is started
   again by it (`STEAM_ERR_RESTART`: quit). Keep `dev` out of a release (`dev_mode()` from `ludic.base` is the
   usual switch).
5. `ludic bundle` links and ships what `package.ludic` lists: both `libludicsteam` and Valve's
   `libsteam_api.dylib` (or `steam_api64.dll`) go into `Contents/Frameworks` (beside the `.exe` on Windows),
   the build machine's rpath is removed, and the libraries are signed with the app. The redistributable
   library travels in **your** game, as Valve's agreement lets a published game carry it, never in this
   toolchain. `steam_appid.txt` is not bundled.

Without the library built, a game that imports this package fails to compile with the loader's complaint
about `gen/steam_raw.ludic`; a game that does not import it is untouched. A build without Steam at all just
leaves `SteamBackend` unbound: `ludic.steam` then answers "unavailable" and every call is a no-op.

## What is generated, and why it is not a licence problem

`tools/steam_gen.ludic` (Ludic, compiled by the `ludic` CLI; checked in) reads the JSON and writes, into `gen/`:

| file | what |
| --- | --- |
| `lsg_wrap.cpp` | one C wrapper per flat-API method of the chosen interfaces whose types can cross (int, long, float, double, bool, a C string, a pointer): it fetches the interface through the accessor the SDK names (version suffix and all), and answers 0 / null / `""` while Steam is not up, so nothing through it can touch an interface that does not exist |
| `steam_raw.ludic` | the matching `extern function lsg_<Interface>_<Method>(a0, a1, ...)` declarations, the original parameter names in a comment |
| `steam_enums.ludic` | the chosen enums' values as `int` constants, exactly as this SDK says them (`ELobbyTypePublic`, ...): the driver maps the mechanic's own codes to these and writes no Valve number itself |
| `report.txt` | what was wrapped and what was left out, and why (a struct by value, a C++ reference, a callback object) |

Default interfaces: `ISteamUser`, `ISteamFriends`, `ISteamUtils`, `ISteamMatchmaking`, `ISteamUserStats`,
`ISteamRemoteStorage`, `ISteamApps`, `ISteamInput`, `ISteamTimeline`, `ISteamNetworkingMessages`,
`ISteamNetworkingSockets` (SDK 1.65: 426 methods wrapped, 19 left out). `--interfaces` and `--enums` choose others.

The reasoning, for whoever audits it:

- **Checked in**: the generator (my code), the shim (my code; it `#include`s the SDK's headers from the
  developer's machine and contains none of Valve's text, only the names of calls, types and fields, which is
  what a binding has to say), the driver and the build script. No header, library, JSON or description of the
  SDK's shape is copied.
- **Generated, never checked in**: the wrappers, externs and enum constants. They are derived from Valve's
  JSON, carry Valve's identifiers and values, and exist only on the machine of a developer who holds the SDK.
  `gen/` is git-ignored here and the toolchain's installer and releases ship the tree without it.
- **Valve's runtime library** is copied into `lib/` on that machine and into the developer's own game bundle.

The generated layer is a safety layer too: a call made while Steam is down cannot crash, and an SDK that
renames or removes an enum value or a method the driver uses fails the build of the game, not the player.

## The shim (`native/shim/steamshim.cpp`)

The shape every shim in `packages/` has ([packages/README.md](../README.md#native-libraries)): only int,
long, float, strings and opaque pointers cross, nothing calls back into Ludic. It does what a generated
wrapper cannot:

- `lsx_init(app_id, dev)`: the relaunch check (release only), `SteamAPI_InitFlat`, then
  `SteamAPI_ManualDispatch_Init` (no callback object ever lives in Ludic). 0 ok, 1 failed, 2 no Steam client,
  3 client out of date, 4 launched outside Steam; `lsx_error` the SDK's message.
- `lsx_pump`: `ManualDispatch_RunFrame`, then `GetNextCallback` until empty; a `SteamAPICallCompleted_t` is
  read with `GetAPICallResult` and decoded by the callback id it names. Every callback and call result the
  mechanic uses becomes a record in a fixed ring of 256 facts (`lsx_poll`, `lsx_fi`, `lsx_fl`, `lsx_ftext`;
  `lsx_lost` counts what did not fit); a frame allocates nothing.
- the structs the generator skips: the game a friend is in, leaderboard entries, Steam Input action data.
- Steam Networking Messages as datagrams: `lsx_net_send` / `lsx_net_recv` and the allow list that
  `SteamNetworkingMessagesSessionRequest_t` is answered from.

## Checking it against the real library

```bash
STEAMWORKS_SDK=~/sdk/steamworks sh packages/ludic.steamworks/check/run.sh
```

`check/smoke.ludic` links the real SDK and starts it. Where no Steam client runs (the expected place for a CI
machine, and what the repository's own suite never needs: `ludic test packages` runs `ludic.steam` on the
fake) it checks that start-up fails cleanly with a reason and that every driver call afterwards answers
"nothing" without touching an interface; where a client does run, it checks the session is real. It is not
under `tests/` for that reason: it needs the SDK, which this repository does not hold.

## Platforms

| target | status |
| --- | --- |
| `macos-arm64` | built and run against SDK 1.65 (start-up fails cleanly with no client; bundling copies and signs both libraries) |
| `macos-x64` | the same script, `LUDIC_NATIVE_TARGET=macos-x64` (the SDK's library is universal); not run here |
| `windows-x64` | written (`steam_api64.dll` + `.lib`, the import libraries `native_link` makes); not run here |
| `linux-x64` | written (`libsteam_api.so`); not run here |

What is verified only against a live Steam client (friends, lobbies, stats, Cloud, Input, the relay) is the
driver's calls into the generated wrappers: each is compiled against the SDK's own headers, so a wrong
signature is a build error, but a run with a client and an app id is the developer's.
