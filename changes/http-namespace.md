bump: minor
type: feat
**HTTP client standard library (#6).** `Http.*` — a poll-based HTTP/HTTPS client
for out-of-band data (leaderboards, cloud saves, remote config, telemetry,
downloads). `Http.get` / `Http.post` / `Http.request` start a request (or
`Http.open` + `Http.set` headers + `Http.body` + `Http.send` to build one up);
`Http.poll` returns `-1` while pending, `0` on error, else the status code, so
the frame never blocks; `Http.status` / `ok` / `text` / `body_len` / `header`
read the reply, and `Http.free` releases it. TLS is the system's, on by default
with certificate verification — an `https://` URL just works. Pairs with the
`Json.*` companion (already shipped in #44): `Json.parse(Http.text(h))`.

The transport (`runtime/native/http.ll`) drives NSURLConnection through the objc
runtime's C ABI on a detached pthread — same hand-written-IR, no-ObjC/no-C style
as cocoa.ll — and is spliced with Foundation only when a program uses `Http.*`
(macOS for now). The response parser (`Http.parse`, header lookup) is pure Ludic
and portable, so the suite exercises it offline with no network. HTTP depends on
the network and wall clock and is explicitly out-of-band: it must never feed the
deterministic lockstep/replay simulation, like `Net.*` and `Time.now`. Also adds
the `\r` string/char escape the protocol needs.
