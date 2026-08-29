---
id: annot-toserver
name: @ToServer
category: annotations
kind: annotation
tokens: @ToServer
sig: @ToServer event Name { … }
tip: A remote event sent from a client to the server — a client→server request.
order: 50
---

<code>@ToServer</code> marks an <code>event</code> as a directional remote event that travels from a client up to the authority — an RPC, expressed as the ordinary event bus with a direction flag rather than a new concept. At an <code>emit</code> site the event's POD payload is serialized as an event id followed by its packed fields and sent through the transport seam toward the server; it does <b>not</b> run locally. On the far side, draining the transport (the runtime's pump) re-emits it into the normal <code>@On</code> dispatch, so a <code>@Server @On(Name)</code> handler picks it up. Use it for player intent — a move request, a fire command — that the authority must validate before it affects the world. Its mirror is <code>@ToClients</code>, which broadcasts the other way.

```ludic
program FireRequest {
  property AmmoLog { shots_fired: int = 0 }
  model Turret { AmmoLog }

  @ToServer event Fire { direction: int = 0 }        # client -> server request

  @Server @On(Fire) handler HandleFire {             # authority validates and applies
    for (AmmoLog) in query [AmmoLog, {Turret}] {
      AmmoLog.shots_fired = AmmoLog.shots_fired + direction
    }
  }

  entry {
    spawn Turret { AmmoLog { shots_fired: 0 } }
    emit Fire(direction: 1)                           # serialized onto the wire, not run locally
  }
}
```
