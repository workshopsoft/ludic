---
id: fn-load
name: load
category: builtins
kind: builtin
tokens: load
sig: load() -> bool
tip: Restore the world from a snapshot previously written by save().
order: 4
---

Restores the entire world from the snapshot most recently written by <code>save()</code> — every model instance, property, and program <code>var</code> returns to its saved state. It returns a <code>bool</code>: <code>true</code> when a snapshot existed and was restored, <code>false</code> when there was nothing to load, so you can guard the call and avoid clobbering the current world by mistake. Use it for quick-load, respawning at a checkpoint, or resetting a test to a known state. It takes no arguments.

```ludic
program QuickLoad {
  property Position { column: int = 0, row: int = 0 }
  model Player { Position }

  handler SpawnPlayer phase Start {
    spawn Player { Position { column: 5, row: 5 } }
    save()
  }

  handler ReadInput phase Input {
    if Input.key() == 'r' {
      let restored = load()
      if restored { print(1) }
    }
  }

  handler DrawWorld phase Render {
    Screen.clear(Color.MidnightBlue)
    Screen.show()
  }
}
```
