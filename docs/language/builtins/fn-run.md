---
id: fn-run
name: run
category: builtins
kind: builtin
tokens: run
sig: run(cmd)
tip: Run a string as a shell command.
order: 22
---

Executes its string argument as a shell command on the host. It exists so build steps and developer tooling can be written in Ludic itself — invoking the compiler, moving files, or chaining tools — rather than in a separate shell script. It is a tooling and scripting facility, not something a shipped game loop would normally use. Treat the command string carefully, since it runs with the same privileges as the program.

Parameters:
- `cmd` — the shell command line to run

```ludic
program BuildStep {
  handler RunTool phase Start {
    run("mkdir -p build")
    run("echo built")
  }
}
```
