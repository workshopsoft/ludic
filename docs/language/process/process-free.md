---
id: process-free
name: Process.free
category: process
kind: namespace-method
tokens: Process.free
sig: Process.free(handle) -> void
tip: Let a process handle go.
order: 3
ns: Process
member: free
---

Releases the handle so it can be reused. It does <strong>not</strong> stop a child that is still running — use <a href="process-kill.html"><code>Process.kill</code></a> first for that; such a child keeps running and is reaped by the runtime when it ends, so it never lingers as a zombie. After <code>free</code>, polling the old handle answers <code>255</code>.

```ludic
program Demo {
  entry {
    let h = Process.spawn("/bin/sh", ["-c", "exit 0"])
    var code = Process.poll(h)
    while code == -1 { code = Process.poll(h) }
    Process.free(h)
  }
}
```
