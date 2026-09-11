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

The per-user directory for an application's disposable cache — regenerable data the system may clear under disk pressure. Never store anything here you cannot recreate.

| | |
| --- | --- |
| macOS | <code>~/Library/Caches/&lt;app&gt;</code> |
| Linux | <code>$XDG_CACHE_HOME/&lt;app&gt;</code>, or <code>~/.cache/&lt;app&gt;</code> |

An XDG variable that is set but empty falls back to the default, as the spec requires.

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
