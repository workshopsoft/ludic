# ludic.session

Who is in a party and who runs the world, whatever carries its messages: the roster, the roles,
the shared night, votes, and "a world-changing act asks the party". It sends nothing - what the
other machines have to hear comes out as facts, and the game puts them on its wire. Uses
[`ludic.base`](../ludic.base/README.md) and nothing else.

```ludic
import "ludic.session"
```

## The roster

Slot 0 is this machine's player, read live through the `SessionLocal` port; slots 1 to
`PLY_MAX - 1` are remote players, holding what their own machines reported (where they stand,
their heading and speed, how much their rest speeds the clock, whether they have turned in, their
name). World code asks the roster, never "the player": `for p in 0 .. PLY_MAX { if ply_on(p) ...
ply_x(p) ... }`, or `ply_near(x, z)` and `ply_near_i()`.

```ludic
port SessionLocal {
  x, y, z: fn() -> float                   # required
  yaw, speed: fn() -> float (0), rest: fn() -> float (1), name: fn() -> string ("")
}
```

## Roles

`SES_SOLO` owns the world and has no company; `SES_HOST` owns it and has company; `SES_GUEST`
owns only its own player. `ses_owns_world()`, `ses_live()`, `ses_night_passes()` (alone, lying
down ends the night). The transport says what this machine became (`ses_set_role`).

## API

| | |
| --- | --- |
| `ply_join(pid) -> slot`, `ply_leave(p)`, `ply_leave_all()` | the roster (-1: full, or pid 0) |
| `ply_report(p, x, y, z, yaw, speed)`, `ply_report_rest(p, rest, sleeping)`, `ply_report_name(p, name)` | what a remote machine said |
| `ply_on`, `ply_is_local`, `ply_slot_of(pid)`, `ply_count`, `ply_pid`, `ply_name`, `ply_x/y/z/yaw/speed/rest(p)`, `ply_sleeping(p)` | who and where |
| `ply_rest_least()` | the party's rest for the clock: the least any player on is resting (1 while one is on their feet) |
| `ply_near(x, z)`, `ply_near_d2`, `ply_near_i()`, `ply_dist(p, x, z)` | the nearest player |
| `ses_role()`, `ses_set_role(r)`, `ses_owns_world()`, `ses_live()`, `ses_hosting()`, `ses_guest()`, `ses_night_passes()` | roles |
| `ses_set_party(max, open)`, `ses_set_open(b)`, `ses_max()`, `ses_open()`, `ses_room_for_one()` | the party a host allows |
| `ses_sleep(on) -> bool`, `ses_sleeping()`, `ses_sleep_ready(p, on)`, `ses_night_check()`, `ses_night_passed()`, `ses_sleep_waiting()` | the shared night: false alone; the host counts |
| `ses_may(kind, param, text) -> SES_MAY_GO / _ASKED / _BUSY / _HOSTS` | a world-changing act |
| `ses_vote_open`, `ses_vote_cast`, `ses_vote_heard(id, yes)`, `ses_vote_told(id, kind, text)`, `ses_vote_ended(id, passed)`, `ses_vote_tick(dt)` | a majority of the players, the host included, within thirty seconds |
| `ses_vote_live/id/kind/text/left/yes/no/mine/passed()` | the vote as it stands |
| `ses_reset()` | everyone else gone, alone, nothing asked, nobody asleep |
| `ses_facts() -> Queue<SessionFact>` | `SES_JOINED` / `SES_LEFT` (slot, pid), `SES_ROLE` (role), `SES_VOTE_OPENED`, `SES_VOTE_CAST` (a guest's answer to send), `SES_VOTE_RESOLVED` (yes: passed), `SES_NIGHT` (the host: everyone is in), `SES_SLEEP` (this player turned in or got up) |

It is not a `System`: a party exists before any world does (a join from the title), so the game
calls `ses_vote_tick` and drains `ses_facts()` in its own frame.

## Tests

```bash
ludic test packages/ludic.session
```

A fake local player: the roster filling and emptying, the nearest player, roles, the party's size,
the night, votes passing, failing and timing out, and a guest's side of each.
