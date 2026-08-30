---
id: log
title: Log
order: 6
---

Levelled, structured logging — the default way to answer "what is my game doing?" and "why did that break?", and a real step up from scattering <code>print</code> calls through your code. Each message carries a level, from <a href="log-trace"><code>trace</code></a> (most verbose) through <a href="log-debug"><code>debug</code></a>, <a href="log-info"><code>info</code></a>, and <a href="log-warn"><code>warn</code></a> to <a href="log-error"><code>error</code></a>, and a runtime threshold set with <a href="log-set_level"><code>Log.set_level</code></a> decides which ones actually appear — so a development build can be chatty and a release build quiet, without touching the call sites.

Messages go to standard error, kept separate from a program's real stdout, tagged with their level. Beyond the message you can pass **structured fields** as trailing key/value pairs — <code>Log.warn("missing texture", "path", p, "id", n)</code> prints <code>[WARN] missing texture path=... id=...</code> — cheap to write and easy to grep. Numeric values (int, long) are formatted for you; the level tag is chosen at compile time, so a filtered-out level costs only a threshold comparison at runtime.

Logging never touches the simulation — it writes to stderr and returns — so it has no effect on gameplay determinism or replays. This first version ships the console (stderr) sink; a rotating-file sink and an in-engine overlay sink are planned follow-ups.
