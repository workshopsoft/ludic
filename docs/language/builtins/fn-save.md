---
id: fn-save
name: save
category: builtins
kind: builtin
tokens: save
sig: save()
tip: Serialize the whole world — every model instance, property, and program var — in one call.
order: 3
---

Captures a complete snapshot of the running world in a single call: every spawned model instance and its properties, plus every program-level <code>var</code>. The compiler generates the serialization for you from your declarations, so you never write it by hand. Pair it with <code>load</code> to implement quick-save / quick-load, checkpoints, or deterministic test fixtures. It takes no arguments and writes to the runtime's snapshot slot; calling it again overwrites the previous snapshot.

```ludic
program QuickSave {
  property Position { column: int = 0, row: int = 0 }
  model Player { Position }

  handler SpawnPlayer phase Start {
    spawn Player { Position { column: 5, row: 5 } }
  }

  handler ReadInput phase Input {
    let pressed = Input.key()
    if pressed == 's' { save() }
    if pressed == 'l' { load() }
  }

  handler DrawWorld phase Render {
    Screen.clear(Color.MidnightBlue)
    Screen.show()
  }
}
```
