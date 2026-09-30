---
id: annot-broadcast
name: @Broadcast
category: annotations
kind: annotation
tokens: @Broadcast
sig: "@Broadcast(all | owner | none) action Name { … }"
tip: Who hears a @Net action once the host has accepted it.
order: 50
---

<code>@Broadcast</code> says who the host tells after it has reduced a <code>@Net</code> action: <code>all</code> (the default) every guest, <code>owner</code> only the owner of the row its <code>@Target</code> names (the port's <code>owner_of(kind, target)</code> answers with a pid), <code>none</code> nobody. A guest that predicted the action is told only that it was accepted (a confirm) and never gets its own action back; a guest that did not predict it hears the action like any other and reduces it then.

```ludic
program Noises {
  state Log { heard: int = 0 }
  @Net @Broadcast(none) action Ping { }            # the host alone hears it
  reducer Log on Ping(l: mut Log, a: Ping) { l.heard += 1 }
  entry (l: Log) {
    dispatch Ping {}
    drain_actions()
    print(l.heard)                                 # 1
  }
}
```
