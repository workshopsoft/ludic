# ludic.steam

The Steamworks runtime API as a mechanic: the start-up state machine, the user and friends, rich
presence, lobbies, achievements, stats and leaderboards driven by data rows, Steam Cloud files, Steam
Input mapped to the game's own actions, DLC, the recording timeline, and Steam's relay as the socket
under [`ludic.net`](../ludic.net/README.md). Uses [`ludic.base`](../ludic.base/README.md) and nothing
else.

It does not talk to the SDK itself. It asks a `SteamDriver` (a record of function values), and
[`ludic.steamworks`](../ludic.steamworks/README.md) is the real one, built from the developer's own
copy of the SDK (Valve's SDK cannot live in an open toolchain). With no backend bound, or with one that
cannot start, **every call is a safe no-op that answers "nothing"**: a game calls every verb on a machine
with no Steam and the parts of it that are Steam's are simply not there. `fake.ludic` is a third driver, a
Steam in memory, so the tests (this package's and a game's) need no Steam, no SDK and no app id.

```ludic
# doc-check: skip — a fragment of a game
import "ludic.steam"
import "ludic.steamworks"                               # the real backend (or steam_fake_driver for tests)
program Game {
  bind SteamBackend { driver: fn steamworks_driver }
  def SteamAchievements from "data/steam_achievements.lres"
  def SteamStats        from "data/steam_stats.lres"

  function game_start(base_st: mut BaseState, steam_st: mut SteamState) -> void {
    let c = new SteamConfig
    c.app_id = 1234560
    c.dev = true                                        # a development run: steam_appid.txt, no relaunch
    steam_config(steam_st, c)
    steam_start(steam_st)                               # STEAM_OK, or why not; the game runs either way
    core_add(base_st, steam_system())                   # the pump in PH_SENSE, and the save section
  }
  # anywhere: steam_achievement_unlock(steam_st, SACH_FIRST_CATCH), steam_stat_add_int(steam_st, SSTAT_FISH, 1) ...
}
```

## Start-up

```
STEAM_IDLE --steam_start--> STEAM_READY
                       \--> STEAM_UNAVAILABLE   steam_why: STEAM_ERR_NO_CLIENT / _OUTDATED / _FAILED / _NO_APP / _NO_BACKEND;
                       |                         steam_error: Steam's own message; steam_start may be tried again
                       \--> STEAM_RESTARTING    STEAM_ERR_RESTART: not launched through Steam, which starts the game
                                                again; this run should quit (a release build only: `dev` skips the check)
STEAM_READY --steam_stop--> STEAM_STOPPED
```

`SteamConfig { app_id, dev, auto_join, store_after, accept_any_peer }`. `steam_start` makes a
`STF_READY` or `STF_UNAVAILABLE` fact. `steam_tick(steam_st, t)` pumps Steam's callbacks and call
results into facts, stores stats that changed and reads Steam Input; `steam_system()` is that as a
`System` in `PH_SENSE` (key `"steam"`). It allocates nothing per frame (the tests hold the heap flat over
thousands of frames of facts); a fact that carries text (a chat line, a typed name) makes one string.

## Data: the registries

Each is an open `@ByKey` registry the game fills in `.lres` files (or with `def`), so an editor can author
them: `@Text` names for the game's own toasts, `@Asset("png")` icons, `@Ref`s between them, `@OneOf` and
`@Range`. A row's key is how the game names it; the `api_name` is what the Steamworks partner site calls it
(the key when left empty). The constants are `SACH_<KEY>`, `SSTAT_<KEY>`, `SLB_<KEY>`, `SRP_<KEY>`,
`SACT_<KEY>`, each with a `_COUNT`, and `steamachievements_find(key)` and its siblings return a row or -1.

| registry | row | fields |
| --- | --- | --- |
| `SteamAchievements` | `SteamAchievement` | `api_name`, `@Text name`, `@Text desc`, `@Asset("png") icon`, `hidden`, `@Ref(SteamStats) stat` + `goal` (unlocks itself when the stat reaches it) |
| `SteamStats` | `SteamStat` | `api_name`, `kind` (`STAT_INT`, `STAT_FLOAT`), `cap` (a value written or added is held to it, and never below 0) |
| `SteamLeaderboards` | `SteamLeaderboard` | `api_name`, `sort` (`LB_SORT_DESC`, `LB_SORT_ASC`), `display` (`LB_DISPLAY_NUMBER`, `_SECONDS`, `_MILLIS`), `create` (make it when missing), `method` (`LB_UPLOAD_BEST`, `LB_UPLOAD_FORCE`) |
| `SteamPresence` | `SteamPresenceRow` | `display` (a `#Token` the partner site translates), `@Text text`, `status`, `group`, `group_size`, `pairs: [{ key, value }]` |
| `SteamActions` | `SteamAction` | `name` (the action in the game's Steam Input manifest), `set`, `kind` (`SIA_DIGITAL`, `SIA_ANALOG`) |

```
# data/steam_achievements.lres
first_catch { api_name: "ACH_FIRST_CATCH", icon: "ui/ach/first_catch.png" }
angler      { api_name: "ACH_ANGLER", stat: SSTAT_FISH_CAUGHT, goal: 50 }
```

## API

All verbs take the state first (`steam_st`). Ids (users, lobbies) are `long`.

| | |
| --- | --- |
| `steam_config`, `steam_start`, `steam_stop`, `steam_tick`, `steam_system` | the session above |
| `steam_status`, `steam_ready`, `steam_why`, `steam_error`, `steam_online` | where it stands; `steam_online` is false between `STF_DISCONNECTED` and `STF_CONNECTED` |
| `steam_id`, `steam_persona`, `steam_app_id`, `steam_logged_on`, `steam_language`, `steam_on_deck`, `steam_proton`, `steam_overlay_enabled` | the user and where they run |
| `steam_auth_ticket`, `steam_ticket_bytes`, `steam_ticket_len`, `steam_ticket_hex`, `steam_auth_cancel` | an auth ticket for a server to check |
| `steam_id_text`, `steam_parse_id`, `steam_connect_string`, `steam_parse_connect`, `steam_launch_lobby` | ids as decimal text, the `+connect_lobby <id>` a Join Game sends, and the lobby a launch named |
| `steam_friend_count / _at / _name / _state / _game / _lobby`, `steam_request_user`, `steam_avatar`, `steam_avatar_size`, `steam_avatar_rgba` | friends (`PERSONA_*`), and avatars as RGBA |
| `steam_overlay`, `steam_overlay_user`, `steam_overlay_url`, `steam_overlay_invite`, `steam_overlay_position` | the overlay |
| `steam_presence_set / _clear / _show(row) / _show_key / _row`, `steam_friend_presence` | rich presence; a row shown twice is left alone, and the lobby's connect string stays across a change of row |
| `steam_lobby_create(kind, max)`, `_join`, `_leave`, `_id`, `_state`, `_in`, `_owner`, `_is_owner`, `_limit`, `_member_count`, `_member(i)` | one lobby at a time (`LOBBY_PRIVATE`, `_FRIENDS`, `_PUBLIC`, `_INVISIBLE`) |
| `steam_lobby_set / _get / _set_member / _member_get / _joinable / _kind / _chat / _invite / _transfer`, `steam_invite_friend` | its data, chat, and who runs it |
| `steam_lobby_search_begin`, `_filter_text / _num / _near / _slots / _distance / _limit`, `_search`, `_found_count`, `_found(i)`, `_found_data`, `_found_members`, `_found_limit` | a search with filters (`LOBBY_CMP_*`) |
| `steam_achievement_unlock(row)`, `_unlock_key`, `_clear`, `_unlocked`, `_count`, `_progress` | achievements |
| `steam_stat_set_int / _add_int / _int / _set_float / _add_float / _float / _key_int`, `steam_stats_store`, `steam_stats_ready`, `steam_reset(all)` | stats |
| `steam_lb_find`, `steam_lb_upload(row, score)`, `steam_lb_download(row, request, from, to)`, `steam_lb_found`, `steam_lb_count / _user / _score / _rank` | leaderboards (`LB_FROM_TOP`, `LB_AROUND_USER`, `LB_FRIENDS`) |
| `steam_cloud_put / _get / _exists / _delete / _count / _name / _size / _time / _enabled`, `steam_cloud_push_file`, `steam_cloud_pull_file` | Steam Cloud files |
| `steam_save_written(path, name)`, `steam_save_before_read(path, name)` | the two calls that make the cloud a companion to `ludic.save` |
| `steam_input_start`, `steam_input_count`, `steam_input_set`, `steam_action_down / _x / _y / _glyph` | Steam Input by `SteamActions` row |
| `steam_dlc_count / _app_id / _owned / _name`, `steam_beta`, `steam_text_input` | the app, and Steam's text box for a gamepad |
| `steam_timeline_mode / _marker / _range / _phase / _phase_end / _tooltip` | the game recording's timeline |
| `steam_net_open / _close / _send / _recv / _from_ip / _from_port / _port / _local_ip`, `steam_net_peer`, `steam_net_user`, `steam_pid`, `steam_net_ready` | the ludic.net socket, below |

### Facts

`steam_facts(steam_st) -> Queue<SteamFact>`: `{ what, id, other, n, m, key, text }`, `what` one of the
`STF_*` constants (state.ludic documents each one's fields): `STF_READY`, `STF_UNAVAILABLE`,
`STF_CONNECTED`, `STF_DISCONNECTED`, `STF_PERSONA`, `STF_AVATAR`, `STF_OVERLAY`, `STF_JOIN_REQUEST`,
`STF_LOBBY_JOIN_REQUEST`, `STF_LOBBY_CREATED`, `STF_LOBBY_ENTERED`, `STF_LOBBY_MEMBER`,
`STF_LOBBY_DATA`, `STF_LOBBY_CHAT`, `STF_LOBBY_KICKED`, `STF_LOBBY_LEFT`, `STF_LOBBY_LIST`,
`STF_STATS_RECEIVED`, `STF_STATS_STORED`, `STF_STAT_CHANGED`, `STF_ACH_UNLOCKED`, `STF_ACH_STORED`,
`STF_LB_FOUND`, `STF_LB_UPLOADED`, `STF_LB_DOWNLOADED`, `STF_DLC_INSTALLED`, `STF_GAMEPAD_TEXT`,
`STF_NET_SESSION_REQUEST`, `STF_NET_SESSION_FAILED`, `STF_PRESENCE`, `STF_CLOUD_PULLED` and the rest.
A mechanic never acts on another's behalf: the game drains them and routes them.

### Achievements earned with no Steam are kept

`steam_achievement_unlock` while Steam is unavailable (or before the stats arrive) remembers the unlock,
says `STF_ACH_UNLOCKED` at once, and sends it as soon as Steam is there. The remembered list is the
mechanic's save section (`"steam": { "v": 1, "pending": [keys] }`), so an offline session loses none. Stats
are refused (false) until `steam_stats_ready`: Steam has not said what they are yet.

## Lobbies and friends: joining

A lobby made or entered publishes `connect = "+connect_lobby <id>"` as rich presence, so a friend's
**Join Game** reaches the game: as `STF_JOIN_REQUEST` while it runs (`other` is the lobby parsed from the
string), or as the launch command line when it does not (`steam_launch_lobby`, read at `steam_start`).
An invite from the overlay is `STF_LOBBY_JOIN_REQUEST`. With `auto_join` (the default) the mechanic joins
the lobby itself; a game that wants to ask first turns it off and calls `steam_lobby_join` on the fact.

### Into `ludic.session`

The roster is keyed by a small pid; `steam_pid(steam_st, id)` gives one for a Steam user, the same for the
whole session. The game's route (the only code that knows both mechanics; `tests/route_test.ludic` runs it):

```ludic
# doc-check: skip — a fragment of a game
function route_lobby_roster(steam_st: mut SteamState, session_st: mut SessionState, t: Tick) -> void {
  let fs = q_drain(steam_facts(steam_st))
  for i in 0 .. len(fs) {
    if fs[i].what == STF_LOBBY_MEMBER and fs[i].other != steam_id(steam_st) {
      let pid = steam_pid(steam_st, fs[i].other)
      if fs[i].n == 1 { ply_join(session_st, pid) } else { ply_leave(session_st, ply_slot_of(session_st, pid)) }
    }
  }
}
```

## The network option: Steam's relay under `ludic.net`

Steam networking is an option, not the default: `ludic.net` keeps its UDP socket unless the game binds
this one. `ludic.net` talks in ip and port and a Steam user has neither, so each user the socket hears of
or is told of gets a stand-in address (10.254.x.y, `steam_net_peer(steam_st, id)`), and `net_join(ip, port)`
dials it. Datagrams are `ISteamNetworkingMessages`': they go through Steam's relay (no router to open,
no NAT to punch), sessions are accepted from the lobby's members and from peers the game named (or
anyone, with `accept_any_peer`), and `ludic.net`'s own acks, resends and ordering ride on it unchanged.

```ludic
# doc-check: skip — a fragment of a game
bind NetSocket {
  open: fn steam_net_open, close: fn steam_net_close, send: fn steam_net_send, recv: fn steam_net_recv,
  from_ip: fn steam_net_from_ip, from_port: fn steam_net_from_port, port: fn steam_net_port, local_ip: fn steam_net_local_ip
}
# host: net_host(27000, token) in a lobby it made; guest: net_join(steam_net_peer(steam_st, steam_lobby_owner(steam_st)), 27000)
```

## Saves: Steam Cloud beside `ludic.save`

`ludic.save` writes a file; Steam Cloud keeps it across machines. The game keeps writing and reading
saves the way it does and brackets them: `steam_save_before_read(steam_st, path, "slot1")` takes the
cloud's copy first when it is newer than what this machine last pushed or pulled (the time is kept beside
the file, `path + ".cloud"`; CLOUD_PULLED / CLOUD_KEPT / CLOUD_NONE), and `steam_save_written(steam_st, path,
"slot1")` sends the file after `save_write`. Or use the text calls (`steam_cloud_put / _get`) without a file.

## Dev verbs

Declared with `def DevVerbs` (a dev build's [`ludic.devlink`](../ludic.devlink/README.md) reads them;
nothing opens without the link). The studio's Steam screen calls these.

| verb | args | reply |
| --- | --- | --- |
| `steam_state` | | `ok <status> "<steam id>" "<persona>" <logged on> <app id> "<lobby id or 0>" <lobby members> <achievements unlocked> <achievements total>` |
| `steam_unlock` | `key:string` | `ok <1 unlocked now, 0 already>`; `err bad_args` for an unknown key, naming a near one |
| `steam_reset` | `all:bool?` | `ok`: the stats forgotten, and the achievements too with `all` |
| `steam_lobby_create` | `kind:string max:int` | answers later: `ok "<lobby id>"` (kind: `private`, `friends`, `public`, `invisible`) |
| `steam_lobby_leave` | | `ok` |
| `steam_stat` | `key:string value:float` | `ok <the value now>` |
| `steam_presence` | `key:string` | `ok`: a row of `SteamPresence` shown |

Every verb but `steam_state` is `err failed "steam is not available: ..."` while Steam is not there.

## The fake

```ludic
# doc-check: skip — a fragment of a test
bind SteamBackend { driver: fn steam_fake_driver }
test "a friend's Join Game click joins the lobby" (steam_st: mut SteamState, fake_st: mut FakeSteamState) {
  fake_remote_lobby(fake_st, long(900), fake_friend_id, 4)
  steam_start(steam_st)
  fake_join_request(fake_st, fake_friend_id, "+connect_lobby 900")
  steam_tick(steam_st, tick_new(0.016, 0, 0.0))
  ...
}
```

`fake_*` plays the other side: `fake_fail_init`, `fake_hold_stats` / `fake_stats_arrive`, `fake_add_friend`,
`fake_remote_lobby`, `fake_member_join / _leave / _data`, `fake_chat`, `fake_join_request`,
`fake_lobby_invite_accepted`, `fake_kick_me`, `fake_board_entry`, `fake_add_dlc`, `fake_add_controller`,
`fake_pad`, `fake_net_inject`, `fake_disconnect` / `fake_connect`, and readers of what the game did
(`fake_presence_value`, `fake_ach`, `fake_stat`, `fake_stores`, `fake_net_sent_*`, `fake_overlay_calls`, ...).

## Tests

```bash
ludic test packages/ludic.steam
```

On the fake: unavailable and restarting starts, every verb a no-op with no Steam, the user, friends and
avatars, presence rows, a lobby's whole life (create, publish, data, members, chat, joins by click, invite,
launch argument and kick, search with filters), achievements by name and by stat goal, stats held to caps
and stored after a shared wait, stats arriving late, reset, offline unlocks through the save section,
leaderboards (find, upload keeping the best, download by range, around the player, friends), cloud text and
files with the newer-copy rule, Steam Input by action, DLC and the timeline, the socket (addresses, send,
receive, sessions), the dev verbs byte for byte, the system, and the heap flat over 3000 frames of facts.
`route_test` wires it under `ludic.net`, `ludic.session` and `ludic.save`.
