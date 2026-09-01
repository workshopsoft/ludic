---
id: sync
title: Sync
order: 39
---

The advanced, opt-in tier — <strong>here be dragons</strong>. Raw building blocks for engine-level systems that pass data around: a <code>mutex</code> (cooperative lock), an <code>atomic</code> counter (<code>get</code> / <code>set</code> / <code>add</code> / <code>cas</code>) and a bounded <code>channel</code> (<code>send</code> / <code>recv</code> / <code>can_recv</code> / <code>len</code>). On today's single-threaded deterministic runtime these are cooperative — correct, ordered, replayable and impossible to deadlock — and exist so message-passing code reads the same now as it will when a preemptive OS-thread backend lands behind this same API. Beginners never need this; reach for <code>Job.*</code> / <code>Promise.*</code> instead. Spliced in only when a program mentions <code>Sync.*</code>.
