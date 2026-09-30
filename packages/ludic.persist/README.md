# ludic.persist

What a player owns - a character, money, properties, cars, unlocks - kept by a small authoritative
**service** and read and changed by a **client** that caches it and plays on when the service is away.
The service is a Ludic program ([`tools/persistd.ludic`](tools/persistd.ludic)); the package holds both
halves and the protocol between them. A mechanic of [`ludic.base`](../ludic.base/README.md) that also takes
[`ludic.save`](../ludic.save/README.md)'s migration chain (`module ludic_persist uses ludic_base, ludic_save`).

```ludic
import "ludic.persist"
```

Everything game-specific is data or a port: the namespaces are `PersistSchemas` rows, who a ticket belongs to is
the `PersistAuth` port, the channel is the `PersistServerLink` / `PersistClientLink` ports (ludic.net's, in
`tools/wire.ludic`). Nothing here knows what a car is.

**Why not HTTP.** Ludic has an HTTP client (`Http.*`) and no server, so the service speaks over
[`ludic.net`](../ludic.net/README.md): UDP with reliable ordered delivery, a handshake a stranger must pass
before anything reaches the game, STUN and a relay for the clients behind routers. The protocol below is
independent of it: any reliable ordered channel carries it.

## The model

A **record** is one player's data in one **namespace**: `{ rev, v, d }` - a revision that goes up by one with
every change, the schema version it was written at, and its data, a JSON object. A namespace is a
`PersistSchemas` row and only declared namespaces exist:

```ludic
def PersistSchemas wallet { version: 2, max_bytes: 256, write: PW_SERVICE, txn: PW_SERVICE, init: "{\"cash\":100}" }
def PersistSchemas profile { version: 1, max_bytes: 512, write: PW_PLAYER, txn: PW_PLAYER }
```

`write` says who may replace a record outright (`put`) and `txn` who may change it with a transaction:
`PW_PLAYER` (the player it belongs to, and a service acting for them), `PW_SERVICE` (a game server only) or
`PW_NONE`. Money is the service's: a player's own client cannot put or spend it, the game server - which
decides a mission was won - does. `init` is the data a transaction starts from when there is no record yet.

**Versions.** A record older than its schema is carried forward by the steps the game declares into ludic.save's
open registry, as it is read from disk, put by a client, or cached: `def SaveMigrations wallet_1_2 { format:
"persist.wallet", from: 1, run: fn wallet_1_2 }` (the format is `persist.` and the namespace). A record newer than
the service's build is refused (`VERSION`) and never guessed at.

## The protocol

A **message** is a JSON object of up to 65 536 bytes carried in **frames** of at most 1 009 bytes, so any record
fits a channel with a small MTU. Numbers are little-endian.

```
hello   [1] <JSON text>                                              one frame, sent as the channel's hello
data    [2] message-id:u32  index:u16  count:u16  <bytes of the JSON>   fragment `index` of `count`
```

Fragments of a message arrive in order, each at the next index; anything else is a broken peer and the connection
is closed. A receiver keeps one reassembly buffer per connection.

**Session.**

```
client -> hello     {"p": 1, "t": "<ticket>"}
service-> welcome   {"op":"welcome","p":1,"player":"alice","service":false,"max":65536,"schemas":[{"ns","v"}...]}
   or   deny        {"op":"deny","code":"AUTH"}   and the connection is let go
```

The ticket goes to `PersistAuth.verify`: `""` refuses it, `"service:<name>"` is a game server (which may act for any
player with `"as"`), anything else is a player's id (printable, no spaces, at most 64 bytes). `tools/persistd.ludic`
ships an HMAC check - a ticket is `<id>.<hmac-sha256(secret, id) in hex>`, minted by whatever logs players in - and a
Steam game replaces `verify` with a check of a session ticket against Valve's web API. **Unbound, every ticket is
refused.**

**Requests and answers.** Each request is `{"id": n, "op": ..., ...}`; its answer is `{"id": n, "ok": true|false, ...}`
and a failure has `code` (and `why`, for people). One request at a time is outstanding from a client, in order.

| op | request | answer |
| --- | --- | --- |
| `get` | `ns` | `found`, `rev`, `v`, `d` |
| `put` | `ns`, `base` (the revision the client has, 0: none), `v`, `d` | `rev`; `CONFLICT` answers with the current `found`, `rev`, `v`, `d` |
| `txn` | `key`, `ops` | `revs: [{ns, rev}]`, `vals` (what each operation left), `replay: true` when the key was seen |
| `del` | `ns` (a service only) | |
| `list` | | `recs: [{ns, rev, v}]` |
| `ping` | | `t` (the service's clock, ms) |

A service adds `"as": "<player>"` to act on that player's records.

**Transactions.** `ops` is 1 to `max_ops` (16) operations over one or more namespaces, applied **all or nothing**
(a refused operation leaves every record as it was and names itself in `op`), each an object with `ns`, `op` and `f`,
a path of up to four names joined by dots into nested objects (made as they go):

| op | fields | does |
| --- | --- | --- |
| `add` | `n`, `min`, `max` | the int at `f` (0 if missing) plus `n`; `INSUFFICIENT` if the result would pass `min` or `max`, or overflow |
| `set` | `v`, `expect` | `f` becomes `v` (an int, a string or a bool); with `expect`, only if `f` holds it now (`null`: only if `f` is not there) |
| `push` | `v`, `unique`, `max` | `v` joins the list at `f` |
| `remove` | `v` | the first `v` leaves the list at `f`, or `NOT_FOUND` |

`key` makes a transaction **idempotent**: the service remembers the last `memos` (64) keys per player - in the
journal and the snapshot, so across restarts - and a key seen again gets the first answer (`"replay": true`)
instead of a second transaction. A client sends the same key again after a lost connection; a game passes the key
a payment already has (ludic.missions' payments carry one). Keys are the player's, whichever connection sends them.

**Errors** (`code`): `BAD` (malformed), `AUTH`, `DENIED`, `UNKNOWN` (namespace or operation), `VERSION`, `SIZE`
(a record past its schema's `max_bytes`, or a player past `max_player_bytes`), `CONFLICT`, `INSUFFICIENT`,
`NOT_FOUND`, `TYPE`, `RATE` (with `retry`, milliseconds), `IO` (the journal could not be written: nothing was done),
`BUSY`.

**Limits.** A token bucket per connection (`rate` requests a second, `burst`; a put, a transaction or a delete costs
`write_cost`): past it the answer is `RATE` with how long to wait, and a connection that keeps pushing is hung up.
Messages past 65 536 bytes, JSON nested past 12 levels, a request that is not one whole object: turned away before
the parser sees them (the runtime's JSON reader is best-effort, so the gate in front of it is strict). What is kept is
always a bounded copy (8 levels, 256 list items, 128 keys), never the parsed tree.

## Storage

One directory (`PersistConfig.dir`):

```
journal.log       append-only: <crc32 of the json, 8 hex> <space> <json> <newline>
journal.prev      the journal the last snapshot covered
snapshot.json     the whole state at a sequence number
snapshot.json.bak the one before
```

A journal line is `{"s": seq, "p": player, "r": [{"ns","rev","v","d"}...], "x": [ns...], "k": txn key, "m": {"ns","revs","vals"}}`:
the **after image** of what a change left, so replaying a line twice or from the middle is harmless. A change is written
to the journal **before** it is applied or answered (a refused write is `IO` and nothing changed). A **snapshot**
(`{"format":"persist","version":1,"seq","players":{id:{"ns":{ns:{rev,v,d}},"memo":[...]}}}`) is taken every
`snapshot_every` entries (200) or when the oldest change not in one is `snapshot_secs` old (300 s); it is written whole
through ludic.save (a temp file renamed into place, read back, the last good one kept as `.bak`), then the journal
becomes `journal.prev` and a fresh one begins.

**Opening** reads the snapshot (the backup when it is damaged, refusing one from a newer build and refusing to open
over two unreadable ones), then replays `journal.prev` and `journal.log` in sequence order, skipping what the snapshot
has, and **stops at the first line that does not check out** - a torn last write - cutting the rest off so nothing
is appended behind garbage (`PSF_RECOVERED` says how many entries and how many bytes). Records of an older version are
migrated as they load. The journal is appended with the OS's own buffering, not fsynced: a killed process loses
nothing, a power cut may lose the last moments (v2: an fsync policy).

## Ports

```ludic
export port PersistServerLink { send: fn(int, []byte, int) -> void, accept: fn(int) -> bool, drop: fn(int) -> void }
export port PersistAuth { verify: fn(string) -> string }
export port PersistClientLink { send: fn([]byte, int) -> void }
export port PersistClientWorld { ticket: fn() -> string, seed: fn() -> int }
```

`tools/wire.ludic` binds the links to ludic.net (a frame as its length and then four bytes to an int in a reliable
message; the client's hello is the net hello; `accept` is `net_accept` and a welcome message carrying the token and
pid, `drop` is `net_close_when_sent`). `seed` is the entropy a client's transaction keys start from: give it a real
one.

## The service

`tools/persistd.ludic` is the whole program: `persistd <dir> [port]` with `PERSIST_SECRET` in the environment. A game
builds its own with its schemas (`tools/schemas.ludic` is the stand-in) and its own `verify`. It frees what a request
allocates (texts and parsed trees) and is meant to be restarted now and then all the same: Ludic frees nothing safe
code allocates, and a restart is cheap because it is the journal and a snapshot.

| | |
| --- | --- |
| `persist_server_config(c)`, `persist_server_open() -> PSO_OK / _FUTURE / _CORRUPT / _IO` | before anything else |
| `persist_server_hello(conn, frame, n) -> bool`, `persist_server_receive(conn, frame, n)`, `persist_server_closed(conn)` | the door |
| `persist_server_tick(dt)`, `persist_server_snapshot()` | the clock; a snapshot now (a clean stop) |
| `persist_server_records()`, `_rev(player, ns)`, `_data(player, ns)`, `_seq()`, `_pending()`, `_is_open()` | what it holds |
| `persist_server_facts() -> Queue<PersistFact>` | `PSF_AUTH`, `_DENY`, `_PUT`, `_TXN`, `_REPLAY`, `_CONFLICT`, `_RATE`, `_SNAPSHOT`, `_RECOVERED`, `_DELETE`, `_ERROR`, `_CLOSED`, `_IO` |

## The client

A session begins when the game's channel reaches the service and the hello goes (`persist_client_hello`); until then,
and whenever the session ends (`persist_client_lost`), **the cache answers and changes queue**. A put replaces the record
in the cache at once and waits its turn (a put not yet sent is replaced by the next: only the last matters); a transaction
is played on the cache with the same operations the service will run and waits with its key. Back online the queue goes
out in order, one request at a time. **The service's word is the last**: a transaction it refuses takes its namespaces
back from it; a put on a record that moved is a conflict the game settles with `persist_take_server` or
`persist_keep_mine`; a put the service already has (an answer lost on the way) is taken as saved.

| | |
| --- | --- |
| `persist_client_hello() -> n`, `persist_client_hello_frame()`, `persist_client_receive(frame, n)`, `persist_client_lost()`, `persist_client_tick(dt)` | the session |
| `persist_get(ns) -> Val`, `persist_loaded`, `persist_rev`, `persist_dirty`, `persist_conflict`, `persist_mine`, `persist_fetch(ns)`, `persist_put(ns, data)` | records |
| `persist_txn_begin(tag) -> key`, `persist_txn_begin_as(player, key)`, `persist_txn_add(ns, f, n, floor)`, `_add_capped`, `_set_int`, `_set_str`, `_swap_str`, `_push_str`, `_remove_str`, `persist_txn_commit() -> bool`, `_cancel`, `persist_txn_vals()` | transactions; `_as` is a game server paying another player by a key it has (nothing is cached of it) |
| `persist_take_server(ns)`, `persist_keep_mine(ns)` | settle a conflict |
| `persist_cache_path(path)`, `persist_cache_save()`, `persist_cache_load()`, `persist_client_reset()` | the cache on disk (also written every couple of seconds while there is something to write) |
| `persist_client_state()`, `persist_online()`, `persist_pending()`, `persist_client_player()` | `PC_OFFLINE`, `_CONNECTING`, `_ONLINE`, `_DENIED` |
| `persist_client_facts() -> Queue<PersistClientFact>` | `PCF_ONLINE`, `_OFFLINE`, `_DENIED`, `_LOADED`, `_SAVED`, `_SAVE_FAILED`, `_CONFLICT`, `_TXN_OK` (`n`: 1 if it had been taken before), `_TXN_FAILED`, `_RATE`, `_SYNCED`, `_QUEUED` |

The cache file (`{"format":"persist.cache","version":1,"player","next","nonce","keys","recs":{ns:{rev,v,d,dirty}},"reqs":[...]}`)
is written whole with a backup; a record read from it is taken as possibly stale and asked for again once a session
begins, unless it has changes waiting.

## Limits, said plainly

- Ludic's JSON reader interns every object key it parses and never frees them: a hostile client can grow the service
  a little with each request it is allowed to make. The rate limit and the size gate bound it; a binary codec is v2.
- `int` is 32-bit: a balance past two billion is refused (`INSUFFICIENT`), not wrapped.
- One request is out at a time per client; pipelining is v2.
- One service process; replication and a hot standby are v2.

## Tests

```bash
ludic test packages/ludic.persist
```

`wire_test` (frames of every size, broken fragment orders, the JSON gate, bounded copies), `ops_test` (every operation
and every refusal), `server_test` (auth, permissions, records and revisions, versions, size, atomic transactions,
idempotency keys and how many are kept, the rate limit, garbage), `store_test` (a restart, a snapshot, a torn write, a
flipped bit, a damaged snapshot and its backup, a newer build's snapshot, a migration on replay, a disk that refuses),
`client_test` (the client against the service in one process: a session, offline play and the queue, conflicts, a refused
transaction, a lost answer, a service paying by a key, several frames, the rate limit, the cache file), and `net_test`:
the service built and run as a **child process** on real UDP, talked to with ludic.net, **killed with no warning** and
started again on its directory (it needs the `ludic` command: `LUDIC_BIN`, else `$LUDIC_HOME/bin/ludic`, else the PATH).
