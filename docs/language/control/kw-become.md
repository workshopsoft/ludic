---
id: kw-become
name: become
category: control
kind: keyword
tokens: become
sig: become Name
tip: Transition to another state of the enclosing machine, or to another scene.
order: 8
---

A <code>become</code> statement performs a transition. Inside a <code>machine</code>, `become Name` moves to another `state` of that machine by storing the target state's value back into the machine's store, so the next dispatch runs the new state. Used from a scene's layer handler, `become Scene` instead switches the active scene: the current scene's `on exit` runs, the active-scene register is set, and the target scene's `on enter` runs — two direct calls and a store, with no dispatch table. `become` names its target and knows from context which kind of transition it is, so you rarely think about the machinery. Transitioning is cheap and takes effect immediately for machine states.

```ludic
program EncounterFlow {
  enum Stage { Explore, Battle, Victory }
  var stage: int = Stage.Explore
  var enemies_left: int = 2

  handler RunStage phase Update {
    machine stage {
      state Explore {
        if Input.key() == ' ' { become Battle }
      }
      state Battle {
        if enemies_left <= 0 { become Victory }
      }
      state Victory {
        Screen.status("you win")
      }
    }
  }
}
```
