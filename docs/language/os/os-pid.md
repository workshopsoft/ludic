---
id: os-pid
name: Os.pid
category: os
kind: namespace-method
tokens: Os.pid
sig: Os.pid() -> int
tip: This process's id.
order: 18
ns: Os
member: pid
---

The operating system's id for this process — unique among the processes alive right now, so it is the natural suffix for scratch files that concurrent runs of the same tool must not share.

```ludic
program Pid {
  entry {
    let scratch = `{Os.temp_dir()}/mytool_{Os.pid()}.log`
    print(len(scratch) > 0)
  }
}
```
