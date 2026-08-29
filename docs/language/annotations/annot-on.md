---
id: annot-on
name: @On
category: annotations
kind: annotation
tokens: @On
sig: @On(Event) handler Name { … }
tip: Register a compile-time listener that runs whenever an event is emitted.
order: 2
---

<code>@On(Event)</code> turns a handler into a listener for a named <code>event</code>: whenever any code runs <code>emit Event(...)</code>, this handler's body runs with the event's fields bound by name. It is how systems talk to each other without referencing one another directly — the emitter never knows who is listening, so gameplay, UI and mods can all react to the same moment independently. Several handlers may listen to one event; they run in declaration order. On a <code>cancellable event</code>, a listener may <code>cancel</code> to veto it, and the emitter sees that outcome. Related lifecycle hooks such as <code>@OnSpawn</code>, <code>@OnEnable</code> and <code>@OnDespawn</code> are specialized event listeners the compiler wires up for you.

```ludic
program Events {
  property Health { current: int = 100, maximum: int = 100 }
  model Player { Health }

  event Damaged { amount: int = 0 }

  handler SpawnPlayer phase Start {
    spawn Player { Health { current: 100, maximum: 100 } }
    emit Damaged(amount: 25)
  }

  @On(Damaged)
  handler ReportDamage {
    print(amount)
  }
}
```
