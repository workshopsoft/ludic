---
id: annot-server
name: @Server
category: annotations
kind: annotation
tokens: @Server
sig: @Server handler Name { … }
tip: Run a handler only on the authority; clients receive the result via @Sync.
order: 50
---

<code>@Server</code> marks a handler as server-authoritative: it runs only on the peer acting as the authority, and clients receive its effects through ordinary <code>@Sync</code> replication rather than by running the handler themselves. This is the declarative alternative to sprinkling <code>is_server()</code> branches through gameplay code — the role is a property of the handler, so every line's placement stays legible. Unmarked handlers are the shared, deterministic simulation that runs everywhere; use <code>@Server</code> for decisions that must have a single source of truth, like awarding score, resolving damage, or spawning authoritative entities. Offline the role register defaults to server, so the guard collapses to "run here" and a single-player build is unchanged.

```ludic
program AuthoritativeScore {
  property Score { total: int = 0 }
  model Scoreboard { Score }

  handler Tick phase Update {                        # unmarked -> runs on every peer
    for (Score) in query [Score] { Score.total = Score.total + 1 }
  }

  @Server handler AwardBonus phase Update {          # authority only
    for (Score) in query [Score] { Score.total = Score.total + 100 }
  }

  handler SpawnScoreboard phase Start {
    spawn Scoreboard { Score { total: 0 } }
  }
}
```
