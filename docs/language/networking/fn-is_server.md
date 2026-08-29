---
id: fn-is_server
name: is_server
category: networking
kind: builtin
tokens: is_server
sig: is_server() -> bool
tip: Whether this peer is the authority.
order: 50
---

<code>is_server</code> returns whether the local peer is currently acting as the authority. The networking runtime sets the peer's role register (via <code>set_role</code>); offline it defaults to server, so an un-networked build reports <code>true</code> and every role guard collapses to "run here." This is the low-level read behind the <code>@Server</code> handler annotation — and in ordinary gameplay code you should reach for the annotation instead, since scattering <code>is_server()</code> branches through your simulation is exactly the readability footgun the role annotations exist to remove. Use the raw check only when you are driving the loop yourself.

```ludic
program AuthorityGate {
  property Score { total: int = 0 }
  model Scoreboard { Score }

  @Server handler AwardPoints phase Update {
    for (Score) in query [Score] { Score.total = Score.total + 10 }
  }

  entry {
    spawn Scoreboard { Score { total: 0 } }
    if is_server() { print(1) } else { print(0) }   # 1 offline — defaults to authority
  }
}
```
