---
id: fn-local_id
name: local_id
category: networking
kind: builtin
tokens: local_id
sig: local_id() -> int
tip: This peer's own network id.
order: 50
---

<code>local_id</code> returns the network id assigned to the local peer by the runtime. It is the value <code>is_owner</code> compares an instance's <code>owner</code> against, so it answers "which of these owned instances are mine?" when you drive ownership logic by hand. Offline, with no networking runtime spliced in, it defaults to <code>0</code>. You rarely need it directly — <code>is_owner</code> already folds the comparison — but it is useful when tagging spawned instances or addressing a specific peer.

```ludic
program IdentifyPeer {
  @Sync property Position { column: int = 0, row: int = 0 }
  @Owned model Player { @Sync Position }

  entry {
    spawn Player { Position { column: 0, row: 0 } }
    for (Position) in query [Position, {Player}] {
      let player_id = self()
      set_owner(player_id, local_id())   # claim this instance for the local peer
      print(is_owner(player_id))         # 1 — owner now equals local_id()
    }
  }
}
```
