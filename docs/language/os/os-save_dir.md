---
id: os-save_dir
name: Os.save_dir
category: os
kind: namespace-method
tokens: Os.save_dir
sig: Os.save_dir(app) -> string
tip: Per-user save directory for an app.
order: 14
ns: Os
member: save_dir
---

The per-user directory where an application should store save files, named for the app. On macOS this is under <code>~/Library/Application Support/</code>. The path is returned as a string; creating the directory and reading/writing files is the filesystem library's job (see the <a href="os-config_dir"><code>config_dir</code></a>/<a href="os-cache_dir"><code>cache_dir</code></a> companions).

Parameters:
- `app` — the application name (used as the folder name)

```ludic
program SaveDir {
  entry {
    let dir = Os.save_dir("MyGame")
    print(len(dir))
  }
}
```
