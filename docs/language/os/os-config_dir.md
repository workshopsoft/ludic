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

The per-user directory where an application should store configuration, named for the app.

| | |
| --- | --- |
| macOS | <code>~/Library/Application Support/&lt;app&gt;</code> |
| Linux | <code>$XDG_CONFIG_HOME/&lt;app&gt;</code>, or <code>~/.config/&lt;app&gt;</code> |

On macOS this is the same directory as <a href="os-save_dir"><code>save_dir</code></a> — the platform keeps config and saves together, and Apple's home for a config file that is not an <code>NSUserDefaults</code> plist is Application Support. On Linux XDG separates the two. An XDG variable that is set but empty falls back to the default, as the spec requires.

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
