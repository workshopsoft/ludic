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

The per-user directory where an application should store save files, named for the app. Which directory that is, is the platform's decision, not the program's:

| | |
| --- | --- |
| macOS | <code>~/Library/Application Support/&lt;app&gt;</code> |
| Linux | <code>$XDG_DATA_HOME/&lt;app&gt;</code>, or <code>~/.local/share/&lt;app&gt;</code> |

An XDG variable that is set but empty falls back to the default, as the spec requires. The path is returned as a string; creating the directory and reading/writing files is the filesystem library's job (see the <a href="os-config_dir"><code>config_dir</code></a>/<a href="os-cache_dir"><code>cache_dir</code></a> companions).

On macOS <code>save_dir</code> and <code>config_dir</code> are the same directory — Apple's home for a config file that is not an <code>NSUserDefaults</code> plist is Application Support too. On Linux XDG separates them, and so does this.

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
