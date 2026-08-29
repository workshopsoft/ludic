---
id: kw-entry
name: entry
category: structure
kind: keyword
tokens: entry
sig: entry { … }
tip: The program's main block — runs once, top to bottom.
order: 10
---

<code>entry</code> declares the program's entry point: a single block that runs once when the program starts, in order, and then the program exits. It is the counterpart to the ECS game loop — where a game is built from <code>handler</code>s driven by phases each frame, an <code>entry</code> program is a straight-line script, which is why the compiler and tools in this repo are written with it. Use it for command-line programs and one-shot tools; use <code>program</code> with handlers for interactive games.

```ludic
program Greet {
  entry {
    print("hello")
    print(2 + 2)
  }
}
```
