bump: minor
type: feat
**Steam as a package.** `ludic.steam` is the Steamworks runtime API as a `ludic.base` mechanic: a start-up state machine
(`steam_start`: ready, unavailable with a reason, or restarting outside Steam), the user, friends and avatars, rich presence
from `SteamPresence` rows, lobbies (create, join by Join Game click, invite or launch argument, search with filters, data, chat),
achievements, stats and leaderboards driven by the data registries `SteamAchievements`, `SteamStats` and `SteamLeaderboards`
(an achievement can unlock itself at a stat's goal; one earned with no Steam is kept in the save section and sent when Steam
is there), Steam Cloud files beside `ludic.save`, Steam Input by `SteamActions` row, DLC, the recording timeline, and Steam's
relay as a `ludic.net` socket option (`bind NetSocket { open: fn steam_net_open, ... }`; UDP stays the default). With no
backend, or one that cannot start, every call is a safe no-op. A dev build's link gets the verbs `steam_state`, `steam_unlock`,
`steam_reset`, `steam_lobby_create`, `steam_lobby_leave`, `steam_stat` and `steam_presence`. `steam_fake_driver` is a Steam in
memory, so a game's tests need no Steam.

**`ludic.steamworks` is the real backend, built from your own SDK.** The Steamworks SDK is Valve's and cannot be in an open
toolchain, so nothing of it is committed: `STEAMWORKS_SDK=<sdk> sh native/build.sh` runs a checked-in generator
(`tools/steam_gen.ludic`) over the SDK's `steam_api.json` (426 flat-API methods wrapped, each answering "nothing" while Steam is
down), compiles it and a hand-written shim against the SDK's headers into git-ignored `gen/` and `lib/<target>/`, and copies
the SDK's runtime library beside them. `ludic bundle` puts both libraries in the app and signs them. `docs/PACKAGES.md` has the
pattern for a native library that may not be redistributed.
