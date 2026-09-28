# ludic.net

A small party over UDP: a host and up to eleven guests, packets with reliable ordered delivery,
the frame of a handshake, join codes, and room codes through a matchmaker with STUN, hole punching
and a relay for the routers punching cannot get through. Uses
[`ludic.base`](../ludic.base/README.md) and nothing else.

```ludic
import "ludic.net"
```

What a message says, what each kind means, what a hello carries and why a host refuses one are
the game's. The package gets bytes there once, in order, and says what happened to the session.

## The wire

A packet is a 20-byte header - `"ML"`, the protocol byte, `1`, the session token, the sender's pid,
the highest reliable id taken in order, a message count - then messages: a kind, a flags byte, a
reliable id when the message is reliable, a 16-bit length and the payload. A reliable message is
kept until acknowledged and sent again every quarter second; a receiver takes them strictly in
order and drops what arrives early (it comes again). An unreliable one half a second old is
dropped. A message is at most `NET_MTU - 40` bytes and is cut, silently, past that; a string is at
most 200 bytes (`nw_s`), a longer one is `nw_text` with its own cap. Numbers are little-endian and
a float goes as its bits.

The host is pid 1 and hands out 2 upwards (`net_accept`). Kind 1 is `NET_HELLO`, the one kind a
stranger may send a host; kind 0 is the heartbeat, never delivered. Until the game accepts a
stranger, nothing else from it reaches the inbox.

## Nothing a message makes is new

A party sends and takes dozens of messages a second for as long as it plays, and Ludic frees
nothing, so the package keeps what a message needs. A queued message's record and its bytes go back
to a pool once it is sent (unreliable) or taken (reliable); a peer's queue is two lists swapped by a
flush. An inbox message's record comes back two drains after it was handed out: read a drained list
before the drain after next. `net_written()` hands out one kept record, good until the next call.
`nr_s` / `nr_text` intern what they read (a name comes every frame), so equal texts are one string.
The tests hold the heap flat over 6000 messages.

## Config and ports

```ludic
property NetConfig {
  proto (1), port (27415: an address typed without one)
  signal_url ("": room codes off), stun_host, stun_port (27400), stun_at ("ip:port" instead)
  no_stun, force_relay                 # tests on one machine
  relay_port0 (60000), seed            # a relayed guest's port base; the STUN dice
}
port NetWorld { log: fn(string) -> void, trace: fn() -> bool }   # unbound: silence
port NetSocket { open, close, send, recv, from_ip, from_port, port, local_ip }   # unbound: Udp
```

## API

| | |
| --- | --- |
| `net_config(c)` | before the first session |
| `net_host(port, token) -> bool` | open a socket and take guests (and a room, when the matchmaker is on); false: `net_why()` |
| `net_hello_set()` | the message just written is the hello: sent again on every dial |
| `net_join(ip, port) -> bool`, `net_room_join(code) -> bool` | dial an address, or ask the matchmaker for a room's host |
| `net_accept(slot) -> pid`, `net_joined_as(token, pid)` | the host lets a stranger in; a guest was let in |
| `net_dial(ip, port)`, `net_follow(ip, port)`, `net_stand_alone()`, `net_become_host(token)`, `net_room_host()` | a refused guest dialling again, a guest following its host elsewhere, a hand-off's heir |
| `net_hello_wait(secs)` | a slow host gets this much longer (a map switch) |
| `net_begin(dt)`, `net_update(dt)`, `net_end()` | a frame, with the game's own reading and writing between |
| `net_keepalive()`, `net_flush_all()` | a load holding the frame; a machine about to let go |
| `net_reset()`, `net_lose(why)`, `net_fresh()` | leave; out with a reason (`NET_DOWN`); a lost session read and done with |
| `np_queue(slot, kind, rel)`, `np_queue_all(kind, rel, except)`, `np_flush(slot)`, `np_close(slot)`, `np_of_pid(pid)` | the written message to a peer or to all |
| `net_close_when_sent(slot, secs)` | let a peer go once it has taken what was queued for it (`NET_CLOSED`) |
| `nw_begin`, `nw_i`, `nw_b`, `nw_f`, `nw_s`, `nw_text`, `nw_len` | write a message |
| `net_inbox() -> Queue<NetMessage>`, `net_read(m)`, `nr_i`, `nr_b`, `nr_f`, `nr_s`, `nr_text`, `nr_bad()` | what came in, in order, and reading it (a short message reads zeros and sets `nr_bad`) |
| `net_copy_read()`, `net_written()` | pass the message read on; the message written, as if it came in |
| `nb_put8`, `nb_put32`, `nb_get8`, `nb_get32`, `nb_copy` | bytes |
| `net_code_of(ip, port)`, `net_join_code()`, `net_parse_code(text)`, `net_code_ip()`, `net_code_port()`, `net_is_room(text)` | ten letters for an address and port, and back; an `a.b.c.d[:port]` is taken too |
| `net_state()`, `net_live()`, `net_active()`, `net_hosting()`, `net_joined()`, `net_joining()`, `net_my_pid()`, `net_token()`, `net_time()`, `net_why()`, `net_port()`, `net_join_ip()`, `net_join_port()`, `net_peer_on/pid/ip/port/heard(slot)`, `net_peer_count()`, `net_room_on()`, `net_room()`, `net_room_asking()`, `net_via_relay()`, `net_outside_ip/port()` | what the game asks |
| `net_bytes_out()`, `net_kind_bytes(kind)`, `net_kind_out_clear()` | what a party costs the upload |
| `net_facts() -> Queue<NetFact>` | `{ what, slot, pid, why, text }`: `NET_GONE` (a guest went silent), `NET_CLOSED`, `NET_DOWN` (why: `NET_WHY_*`, text: the room nobody had), `NET_ROOM` (text: the code), `NET_ROOM_FAILED` |

A frame, as the game runs it:

```ludic
net_begin(dt)                    # time, and what came in onto the inbox
let got = q_drain(net_inbox())   # the game's own dispatch
for i in 0 .. len(got) { if net_peer_on(got[i].slot) { net_read(got[i]) ... } }
net_update(dt)                   # the matchmaker, the hello, silence
... queue this frame's messages ...
net_end()                        # heartbeats, sending, slots let go
q_drain(net_facts())
```

The words for a reason are the game's: `NET_WHY_*` is a code, and `NET_WHY_GAME` means the game
said why itself before `net_lose`.

## Tests

```bash
ludic test packages/ludic.net
```

A fake socket: the codec, the codes, a host taking a stranger only with a hello, delivery in order,
resending until taken, a stale unreliable message dropped, the hello's timeout, a silent guest, a
slot let go once it took its last message, and no matchmaker. The matchmaker, STUN and the relay
are covered by the game's `tests/net.sh` (`NET_ROOM=1`, `NET_RELAY=1`) against
`tools/partyserver` on localhost.
