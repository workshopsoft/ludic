---
id: kw-scene
name: scene
category: scenes
kind: keyword
tokens: scene
sig: scene Name [start] { on enter{} on exit{} layer … }
tip: A mutually-exclusive game state — a title screen, the overworld, a battle.
order: 0
---

A `scene` is one of the mutually-exclusive states a game moves between — a title screen, the overworld, a battle, a shop. Exactly <b>one scene is active</b> at a time, and only the active scene's `layer` handlers run each phase; handlers declared outside any scene are global and run every frame regardless. A scene may carry an `on enter` / `on exit` pair of lifecycle hooks and one or more `layer` blocks that group its handlers. Under the hood a scene lowers to an implicit state machine the compiler writes for you (scenes number themselves by declaration order), so `become` from one scene to another costs two direct calls and a register store — no dispatch table.

```ludic
program SceneExample {
  state SceneExampleState {
    elapsed_frames: int = 0
  }

  scene Title start {
    on enter (scene_example_st: mut SceneExampleState) { scene_example_st.elapsed_frames = 0 }
    layer Main {
      handler WaitForStart(scene_example_st: mut SceneExampleState) phase Update {
        scene_example_st.elapsed_frames = scene_example_st.elapsed_frames + 1
        if Input.key() != 0 { become Overworld }
      }
      handler DrawTitle phase Render {
        Screen.clear(Color.MidnightBlue)
        Screen.draw_text(x: 60, y: 100, text: "PRESS ANY KEY", color: Color.White, scale: 1)
        Screen.show()
      }
    }
  }

  scene Overworld {
    on enter (scene_example_st: mut SceneExampleState) { scene_example_st.elapsed_frames = 0 }
    layer World {
      handler DrawWorld phase Render {
        Screen.clear(Color.MidnightBlue)
        Screen.fill_rectangle(x: 80, y: 80, width: 16, height: 16, color: Color.LimeGreen)
        Screen.show()
      }
    }
  }
}
```
