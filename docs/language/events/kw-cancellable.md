---
id: kw-cancellable
name: cancellable
category: events
kind: keyword
tokens: cancellable
sig: event cancellable Name { … }
tip: Marks an event whose listeners may veto it with cancel.
order: 50
---

`cancellable` marks an event as a <b>decision, not just a notification</b>. A plain event tells listeners something happened; a `cancellable` event is fired <b>before</b> an action so a listener can veto it by calling `cancel`. The caller reads the verdict back by using `emit` as an expression: it yields `0` when no listener vetoed and `1` when one did, so the action is applied only on `0`. This is the Bukkit / DOM `preventDefault` shape — observation becomes control — and a foreign mod vetoes the same way by setting the payload's trailing cancelled flag over the ABI.

```ludic
program CancellableExample {
  event cancellable BeforeHurt { amount: int = 0 }

  state CancellableExampleState {
    current_health: int = 100
  }

  @On(BeforeHurt) handler AbsorbSmallHits { if amount <= 5 { cancel } }

  handler TakeDamage(cancellable_example_st: mut CancellableExampleState) phase Update {
    if Input.key() == 'h' {
      if emit BeforeHurt(amount: 3) == 0 { cancellable_example_st.current_health = cancellable_example_st.current_health - 3 }
    }
  }

  handler DrawWorld(cancellable_example_st: CancellableExampleState) phase Render {
    Screen.clear(Color.MidnightBlue)
    Screen.draw_number(x: 4, y: 4, value: cancellable_example_st.current_health, color: Color.Crimson, scale: 1)
    Screen.show()
  }
}
```
