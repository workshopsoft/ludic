---
id: os-config_dir
name: Os.config_dir
category: os
kind: namespace-method
tokens: Os.config_dir
sig: Os.config_dir(app) -> string
tip: Per-user config directory for an app.
order: 15
ns: Os
member: config_dir
---

The per-user directory where an application should store configuration, named for the app. On macOS this resolves under <code>~/Library/Application Support/</code> (the platform keeps config and saves together there).

Parameters:
- `app` — the application name (used as the folder name)

```ludic
program ConfigDir {
  entry {
    let dir = Os.config_dir("MyGame")
    print(len(dir))
  }
}
```
