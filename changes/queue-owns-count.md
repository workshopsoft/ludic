bump: minor
type: feat
**A queue keeps its own count, so a package verb takes only its own state; `ludic migrate state --prune`.**
ludic.base's `Queue<T>` carries its name and pending count itself: `queue_new(name)`, `q_push(q, v)`,
`q_drain(q)`, `q_clear(q)` take no `BaseState`, and neither does any package verb that pushes a fact -
`wallet_earn(wallet_st, n)`, `inv_add(inventory_st, ...)` - so a reducer on a package's state can call
its own package's verbs. `core_undrained(tags)` names the queues given to it (`q_tag(q)`) that still
hold facts. `ludic migrate state --prune` takes out each state parameter a function no longer uses
(nor anything it calls) and the argument that fills it, including an argument for a parameter the
callee has dropped: run it over a game to follow this change.
