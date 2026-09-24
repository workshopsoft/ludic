---
id: app-monitor_count
name: App.monitor_count
category: app
kind: namespace-method
tokens: App.monitor_count
sig: App.monitor_count() -> int
tip: How many displays the machine has.
order: 49
ns: App
member: monitor_count
---

The number of displays attached, for a setting that chooses which one the game opens on; 1 on a platform that reports only the main one.

```ludic
program Screens {
  entry { print(App.monitor_count()) }
}
```
