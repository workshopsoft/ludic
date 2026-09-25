---
id: phase-start
name: Start
category: phases
kind: phase
tokens: Start
sig: phase Start
tip: Runs once at boot, before the game loop — the place to set up initial state.
order: 0
---

`Start` is the boot phase: a `handler … phase Start` runs <b>exactly once</b>, before the first frame and before the per-frame loop begins. Use it to build the world that everything else assumes — seed the RNG with `Random.seed`, set the tilemap size with `Map.size`, spawn the starting models, and initialise your program `var`s. It runs before any scene is entered, so it is the one phase a scene `layer` handler may <b>not</b> use; per-scene setup belongs in a scene's `on enter` block instead. Every other phase (`Input`, `FixedUpdate`, `Update`, `LateUpdate`, `Render`) then repeats each frame, but `Start` never runs again.

```ludic
program StartExample {
  property Position { column: int = 0, row: int = 0 }
  model Player { Position }

  const GRID_WIDTH: int = 20
  state StartExampleState {
    score: int = 0
  }

  handler SetUpWorld(start_example_st: mut StartExampleState) phase Start {
    Random.seed(value: 1)
    Map.size(width: GRID_WIDTH, height: 15)
    start_example_st.score = 0
    spawn Player { Position { column: 10, row: 7 } }
  }

  handler DrawWorld(start_example_st: StartExampleState) phase Render {
    Screen.clear(Color.MidnightBlue)
    Screen.draw_number(x: 4, y: 4, value: start_example_st.score, color: Color.Gold, scale: 1)
    Screen.show()
  }
}
```
