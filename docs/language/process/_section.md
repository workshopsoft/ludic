---
id: process
title: Process
order: 10
---

Child processes, started and polled — what a launcher is made of. <a href="process-spawn.html"><code>Process.spawn</code></a> starts a program directly, with no shell, and returns at once; each frame <a href="process-poll.html"><code>Process.poll</code></a> answers <code>-1</code> while the child runs and its exit code once it has ended, so a crash is a non-zero code the game can act on. <a href="process-kill.html"><code>Process.kill</code></a> ends a child and <a href="process-free.html"><code>Process.free</code></a> lets a handle go. Pair it with <a href="../app/app-window_hide.html"><code>App.window_hide</code></a> to step aside while the child runs.

The child inherits the environment and the working directory. <code>posix_spawn</code> on macOS; <code>CreateProcessW</code> on Windows, with each argument quoted by the MSVC rules and no console window. Like <code>Http.*</code> it is <strong>out-of-band</strong> and must never feed the deterministic lockstep/replay simulation.
