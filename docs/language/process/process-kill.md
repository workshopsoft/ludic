---
id: process-kill
name: Process.kill
category: process
kind: namespace-method
tokens: Process.kill
sig: Process.kill(handle) -> void
tip: End a running child.
order: 2
ns: Process
member: kill
---

Ends the child at once — <code>SIGKILL</code> on macOS, <code>TerminateProcess</code> on Windows — with no chance for it to save anything. A later <a href="process-poll.html"><code>Process.poll</code></a> answers <code>137</code> once it has gone. Does nothing for a child that has already ended, or a handle that is not one.

```ludic
program Demo {
  entry {
    let h = Process.spawn("/bin/sleep", ["30"])
    Process.kill(h)
  }
}
```
