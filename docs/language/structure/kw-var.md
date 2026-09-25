---
id: kw-var
name: var
category: structure
kind: keyword
tokens: var
sig: var name: T = value
tip: A mutable binding — at program scope, your game's persistent named state.
order: 6
---

A <code>var</code> declares a <b>mutable</b> binding: unlike `let`, you may reassign it later with `=`, `+=`, `-=`, and friends. Where it appears decides its lifetime — inside a handler or function body it is a local, and at program scope it is persistent, named game state that every handler shares. Program-scope `var`s are the modern replacement for numeric registers: instead of `reg(0)`, you write `var score: int = 0` and read and write `score` by name. Use `var` for anything that genuinely changes — accumulators, the current score, a mode flag, an elapsed-frame counter — and prefer `let` for values that never change.

```ludic
program Scorekeeper {
  state ScorekeeperState {
    score: int = 0
    elapsed_frames: int = 0
  }

  handler Tick(scorekeeper_st: mut ScorekeeperState) phase Update {
    scorekeeper_st.elapsed_frames = scorekeeper_st.elapsed_frames + 1
    if scorekeeper_st.elapsed_frames % 60 == 0 { scorekeeper_st.score = scorekeeper_st.score + 1 }
  }

  handler DrawWorld(scorekeeper_st: ScorekeeperState) phase Render {
    Screen.clear(Color.MidnightBlue)
    Screen.draw_text(x: 6, y: 4, text: "SCORE", color: Color.White, scale: 1)
    Screen.draw_number(x: 52, y: 4, value: scorekeeper_st.score, color: Color.Gold, scale: 1)
    Screen.show()
  }
}
```
