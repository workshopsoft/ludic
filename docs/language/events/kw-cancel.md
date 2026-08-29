---
id: kw-cancel
name: cancel
category: events
kind: keyword
tokens: cancel
sig: cancel
tip: Inside a listener, veto the cancellable event being emitted.
order: 2
---

`cancel` is used inside an `@On` listener to <b>veto</b> the `cancellable` event currently being emitted. Calling it sets the payload's cancelled flag, and once the `emit` finishes running its listeners that flag comes back to the caller — `emit E(…)` used as an expression yields `1` when any listener cancelled and `0` otherwise. Guard it behind whatever condition should block the action; listeners that do not `cancel` simply observe. `cancel` is only meaningful in a listener for an event declared `cancellable`.

```ludic
program CancelExample {
  event cancellable BeforeOpenDoor { key_count: int = 0 }

  var keys: int = 0
  var doors_opened: int = 0

  @On(BeforeOpenDoor) handler RequireKey { if key_count <= 0 { cancel } }

  handler TryOpen phase Update {
    if Input.key() == 'o' {
      if emit BeforeOpenDoor(key_count: keys) == 0 {
        doors_opened = doors_opened + 1
        keys = keys - 1
      }
    }
  }

  handler DrawWorld phase Render {
    Screen.clear(Color.MidnightBlue)
    Screen.draw_number(x: 4, y: 4, value: doors_opened, color: Color.Gold, scale: 1)
    Screen.show()
  }
}
```
