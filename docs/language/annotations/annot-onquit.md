---
id: annot-onquit
name: @OnQuit
category: annotations
kind: annotation
tokens: @OnQuit
sig: @OnQuit handler Name { … }
tip: Run a handler once at shutdown, after the last frame.
order: 50
---

<code>@OnQuit</code> pins a handler to the program's shutdown moment: it runs exactly once as the program exits, after the final frame. Use it for teardown that must happen once — flushing a save, printing a final tally, releasing a host resource. In the lifecycle timeline it runs after every still-live instance's <code>@OnDespawn</code> hook has fired, so the world has already been torn down by the time <code>@OnQuit</code> sees it. It is the boot-time counterpart of <code>@OnStart</code>; add <code>@Public</code> to also emit a <code>program_quit</code> event other modules can hook.

```ludic
program QuitHook {
  property Score { total: int = 0 }
  model Scoreboard { Score }

  @OnQuit handler ReportFinalScore {                 # runs once at shutdown
    for (Score) in query [Score] { print(Score.total) }
  }

  handler Seed phase Start { spawn Scoreboard { Score { total: 42 } } }

  handler Finish phase Render { quit() }             # triggers shutdown -> prints 42
}
```
