---
id: kw-where
name: where
category: control
kind: keyword
tokens: where
sig: for (Binds) in query [Comps] where cond { … }
tip: Filter a query loop to entities that satisfy a condition.
order: 11
---

<code>where</code> attaches a boolean condition to a <code>query</code> loop, so the body runs only for entities whose components satisfy it — the rows that fail the test are skipped entirely. The condition is an ordinary expression over the bound components, such as <code>where Battle.hp &lt;= 0 and Battle.side == 1</code>. It is the imperative twin of a component filter written inside a <code>@Queries</code> annotation, and keeps the guard next to the loop instead of repeating an <code>if</code> at the top of the body.

```ludic
program Cleanup {
  property Health { hp: int = 0 }
  model Foe { Health }

  handler ReapDead phase LateUpdate {
    for (Health) in query [Health, {Foe}] where Health.hp <= 0 {
      # only dead foes reach here
    }
  }
}
```
