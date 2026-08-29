---
id: annot-toclients
name: @ToClients
category: annotations
kind: annotation
tokens: @ToClients
sig: @ToClients event Name { … }
tip: A remote event broadcast from the server to clients — a server→clients notification.
order: 50
---

<code>@ToClients</code> marks an <code>event</code> as a directional remote event that travels from the authority down to clients — a broadcast, again the ordinary event bus with a direction flag. When the server <code>emit</code>s it, the POD payload is serialized as an event id plus its packed fields and sent through the transport seam to the clients; each client's pump re-emits it into normal <code>@On</code> dispatch, so an <code>@On(Name)</code> handler on every client reacts. Use it for authoritative notifications a client should present but not decide — an explosion happened, a round ended, a pickup was granted. Its mirror is <code>@ToServer</code>, which carries client requests the other way.

```ludic
program ExplosionBroadcast {
  property EffectLog { count: int = 0 }
  model Client { EffectLog }

  @ToClients event Boom { column: int = 0, row: int = 0 }   # server -> clients broadcast

  @On(Boom) handler PlayExplosion {                  # every client reacts
    for (EffectLog) in query [EffectLog, {Client}] {
      EffectLog.count = EffectLog.count + 1
    }
  }

  entry {
    spawn Client { EffectLog { count: 0 } }
    emit Boom(column: 8, row: 3)                      # serialized to clients, re-emitted on arrival
  }
}
```
