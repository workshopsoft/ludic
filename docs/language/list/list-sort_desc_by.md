---
id: list-sort_desc_by
name: List.sort_desc_by
category: list
kind: namespace-method
tokens: List.sort_desc_by
sig: List.sort_desc_by(s, key) -> void
tip: Sort a slice descending by a key each element maps to.
order: 15
ns: List
member: sort_desc_by
---

Like <code>List.sort_by</code>, but descending — highest key first. The everyday case is a leaderboard: sort players by score so the top scorer lands at index 0. <code>key</code> is a function taking one element and returning a number (<code>int</code>, <code>fixed</code>, or <code>long</code>). The sort is <strong>stable</strong> (O(n log n) merge sort): players tied on score keep their prior order, so a stable tie-break (say, who reached the score first) survives the sort.

```ludic
# doc-check: skip — illustrative; `key` is any fn(element) -> number in scope
function score_of(p: Player) -> int { return p.score }

program Demo {
  handler Step phase Update {
    List.sort_desc_by(players, score_of)   # players[0] is the leader
  }
}
```
