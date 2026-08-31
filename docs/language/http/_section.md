---
id: http
title: Http
order: 8
---

A poll-based HTTP / HTTPS client for out-of-band data — leaderboards, cloud saves, remote config, telemetry, downloads. Open a request with <a href="http-get.html"><code>Http.get</code></a> / <a href="http-post.html"><code>Http.post</code></a> (or <a href="http-open.html"><code>Http.open</code></a> to add headers first), then each frame call <a href="http-poll.html"><code>Http.poll</code></a> — it returns <code>-1</code> while pending, <code>0</code> on error, or the status code — so the frame never blocks. Read the reply with <a href="http-status.html"><code>Http.status</code></a> / <a href="http-ok.html"><code>ok</code></a> / <a href="http-text.html"><code>text</code></a> / <a href="http-header.html"><code>header</code></a>, and pair it with <code>Json.*</code> for (de)serialization. TLS is the system's, on by default.

HTTP depends on the network and the wall clock, so — like <code>Net.*</code> and <code>Time.now</code> — it is <strong>out-of-band</strong> and must never feed the deterministic lockstep/replay simulation. The transport is macOS-only for now; the raw-response parser (<a href="http-parse.html"><code>Http.parse</code></a>) is pure and portable.
