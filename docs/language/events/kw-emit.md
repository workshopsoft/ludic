---
id: kw-emit
name: emit
category: events
kind: keyword
tokens: emit
sig: emit Name(field: value)
tip: Fire an event, running every listener; as an expression it yields the veto flag.
order: 1
---

`emit Name(field: value, …)` fires an event: it runs every `@On(Name)` listener in declaration order, passing the named payload fields (any you omit take the event's declared defaults). It desugars to a direct call into the event's generated function, so firing an event is as cheap as calling a function. For a `cancellable` event, `emit` can be used as an <b>expression</b> that yields the cancelled flag — `0` if no listener vetoed, `1` if one did — which is the "check the decision before acting" shape: apply the effect only when the emit returns `0`.

```ludic
program EmitExample {
  event cancellable BeforeSpend { amount: int = 0 }

  var coins: int = 50

  @On(BeforeSpend) handler RejectOverdraft { if amount > coins { cancel } }

  handler TrySpend phase Update {
    if Input.key() == 'b' {
      if emit BeforeSpend(amount: 20) == 0 { coins = coins - 20 }
    }
  }

  handler DrawWorld phase Render {
    Screen.clear(Color.MidnightBlue)
    Screen.draw_number(x: 4, y: 4, value: coins, color: Color.Gold, scale: 1)
    Screen.show()
  }
}
```
