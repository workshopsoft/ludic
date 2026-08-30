---
id: os-cache_dir
name: Os.cache_dir
category: os
kind: namespace-method
tokens: Os.cache_dir
sig: Os.cache_dir(app) -> string
tip: Per-user cache directory for an app.
order: 16
ns: Os
member: cache_dir
---

The per-user directory for an application's disposable cache — regenerable data the system may clear under disk pressure. On macOS this is under <code>~/Library/Caches/</code>. Never store anything here you cannot recreate.

Parameters:
- `app` — the application name (used as the folder name)

```ludic
program CacheDir {
  entry {
    let dir = Os.cache_dir("MyGame")
    print(len(dir))
  }
}
```
