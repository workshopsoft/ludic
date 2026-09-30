---
id: annot-validate
name: @Validate
category: annotations
kind: annotation
tokens: @Validate
sig: "@Validate(fn) action Name { … }"
tip: The host's check of a guest's @Net action, before it is reduced.
order: 50
---

<code>@Validate(fn)</code> names the function the host runs on a guest's <code>@Net</code> action at its place in the drain, before its reducers: <code>fn(states it reads..., a: Action, sender: int) -> bool</code>. The states are supplied like a reducer's and the function writes nothing; <code>sender</code> comes from the wire's slot, never from the message. False refuses the action: its reducers do not run, nothing is broadcast, and the guest is told (its <code>@Predicted</code> work is rolled back and the port's <code>rejected(kind, seq, why)</code> is called). An action the host dispatches itself is not checked. The function is exported when it sits in a module.

```ludic
program Checked {
  state Wallet { coins: int = 10 }
  @Net @Validate(may_spend) action Spend { n: int = 1 }
  export function may_spend(w: Wallet, a: Spend, sender: int) -> bool { return a.n <= w.coins }
  reducer Wallet on Spend(w: mut Wallet, a: Spend) { w.coins -= a.n }
  entry (w: Wallet) {
    dispatch Spend { n: 4 }
    drain_actions()
    print(w.coins)                                 # 6
  }
}
```
