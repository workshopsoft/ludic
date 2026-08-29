---
id: world-query_next
name: World.query_next
category: world
kind: namespace-method
tokens: World.query_next
sig: World.query_next(query_id, cursor) -> int
tip: Advance a reflective query.
order: 15
ns: World
member: query_next
---

Returns the next entity matching query <code>query_id</code> after <code>cursor</code>, or a terminal value when the query is exhausted.
