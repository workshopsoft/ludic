# ludic.telemetry

What a game says about how it is played, sent to an analytics server without ever costing a
frame. Each event is encoded once into a line held in memory; the lines go out in batches on
Http's own thread; a failed send keeps its lines and waits twice as long next time; the queue is
on disk every few seconds, so a crash or a quit loses little and the next start sends it; and a
player who says no has nothing queued and the file deleted. Uses
[`ludic.base`](../ludic.base/README.md) and nothing else.

```ludic
import "ludic.telemetry"
```

The wire format is PostHog's batch API: `POST <host><path>` with
`{"api_key": <key>, "batch": [{"event", "distinct_id", "properties", "timestamp"}, ...]}`. Every
event carries `$session_id` (a fresh one each start) and `$lib`. What an event is called and
what else its properties say are the game's.

The player id is one per machine: the operating system's own id (Windows `MachineGuid` through
PowerShell, macOS `IOPlatformUUID` through `ioreg`, Linux `/etc/machine-id`) hashed with the
game's salt, so a reinstall comes back as the same player and the raw id never leaves the
machine. With no salt, or where it cannot be read within ten seconds, it is random (`r-...`). It
lives in the game's id file as `{"id": ...}`; any other key the game keeps there is left alone.
An event queued before the id is known carries a mark that the batch replaces.

## Nothing is made per event

Ludic gives nothing back, so an event is never a tree of values or a string of its own. Its
properties are written as JSON into a kept buffer (`telemetry_props`), the line into another, and
the line's bytes into one ring made at the start (`ring_bytes`, at most `queue_max` lines): past
either, the oldest are overwritten. A batch and the queue file are written into a third kept buffer
and go out as bytes (`Http.body_bytes`, `Fs.write_bytes`). An event's time is worked out from the
clock's seconds, not formatted. `tests/ring_test` holds it: ten thousand events past the cap, 0 bytes.

## Config and ports (`bind`)

```ludic
property TelemetryConfig {
  host, key, path ("/batch/"), lib        # an empty host or key sends nothing, ever
  queue_file, id_file, id_salt, id_scratch
  flush_ms (30000), flush_at (50), batch (200), queue_max (5000), ring_bytes (1 MB), backoff_max (6), save_ms (5000)
  line_max (2048)                         # the longest event's line, properties included; a longer one is dropped
}
port TelemetryWorld {
  can_send: fn() -> bool     # may this run send at all - a test, a headless run (unbound: yes)
  enabled: fn() -> bool      # the player's switch (unbound: on)
  now_ms: fn() -> int        # a clock (unbound: the wall clock, by the second)
  clock_s: fn() -> int       # the wall clock in seconds since 1970, for an event's time (unbound: now)
}
port TelemetryTransport {    # unbound: Http
  send: fn(string, []byte, int) -> int   # url, body, its length -> a handle, < 0 if it could not start
  poll: fn(int) -> int              # -1 pending, 0 failed, 1 taken
  drop: fn(int) -> void             # abandon one
}
```

The game binds what it needs once, where it is put together:

```ludic
bind TelemetryWorld { can_send: fn my_can_send, enabled: fn my_switch }
```

## API

| | |
| --- | --- |
| `telemetry_config(c)` | before the start |
| `telemetry_start()` | once, at boot: the id, a session, and the queue an earlier start left (or none, if off) |
| `telemetry_props()`, `telemetry_str(p, k, s)`, `telemetry_int(p, k, n)`, `telemetry_bool(p, k, b)` | the next event's properties, written into a buffer the state keeps |
| `telemetry_event(name, props)` | queue one (props may be null); nothing is kept while off or while the run may not send |
| `telemetry_tick()` | every frame: the machine id's child, a batch when due (every `flush_ms`, or at `flush_at` events), its answer, the backoff, the queue on disk every `save_ms`; off forgets |
| `telemetry_save()` | the queue on disk now (a quit, a child about to start) |
| `telemetry_forget()` | nothing queued, nothing on disk, the request in flight dropped |
| `telemetry_set_id(id)`, `telemetry_random_hex(n)` | an id outright; random hex that is distinct per start on Windows too (its `Crypto.random_hex` is zeros) |
| `telemetry_on()`, `telemetry_get_config()`, `telemetry_id()`, `telemetry_session()`, `telemetry_ready()`, `telemetry_queued()`, `telemetry_line(i)`, `telemetry_batch_body(n)`, `telemetry_fails()`, `telemetry_next_ms()`, `telemetry_in_flight()` | what the game asks |
| `telemetry_facts() -> Queue<TelemetryFact>` | `{ what, count, status, retry_ms }`: `TELEMETRY_SENT`, `TELEMETRY_FAILED`, `TELEMETRY_ID` |
| `telemetry_reset()` | back to before the start (tests) |

It is not a `System`: it runs from the first frame of a launcher, before any world exists, so the
game calls `telemetry_tick()` itself.

## Tests

```bash
ludic build packages/ludic.telemetry/tests/telemetry_test.ludic --headless -o /tmp/telemetry_test && /tmp/telemetry_test
```

A fake clock and a fake transport: nothing reaches a network.
