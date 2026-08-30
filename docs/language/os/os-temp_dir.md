---
id: os-temp_dir
name: Os.temp_dir
category: os
kind: namespace-method
tokens: Os.temp_dir
sig: Os.temp_dir() -> string
tip: The system temporary directory.
order: 17
ns: Os
member: temp_dir
---

The system temporary directory (from <code>TMPDIR</code>, falling back to <code>/tmp</code>) — for short-lived scratch files that need not survive a restart.

```ludic
program TempDir {
  entry {
    let dir = Os.temp_dir()
    print(len(dir))
  }
}
```
