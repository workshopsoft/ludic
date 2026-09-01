---
id: sync-len
name: Sync.len
category: sync
kind: namespace-method
tokens: Sync.len
sig: Sync.len(channel) -> int
tip: How many values are queued.
order: 13
ns: Sync
member: len
---

How many values are queued.

```ludic
let ch = Sync.channel()
let n = Sync.len(ch)
```
