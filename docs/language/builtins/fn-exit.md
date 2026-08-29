---
id: fn-exit
name: exit
category: builtins
kind: builtin
tokens: exit
sig: exit(code)
tip: Exit the process immediately with a status code.
order: 21
---

Terminate the process now with the given status code. Unlike <code>quit()</code>, which ends the game loop cleanly after the current frame, <code>exit</code> stops the program at once.
