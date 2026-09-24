---
id: input-text
name: Input.text
category: input
kind: namespace-method
tokens: Input.text
sig: Input.text() -> string
tip: The text typed this frame.
order: 61
ns: Input
member: text
---

What the keyboard layout, the modifiers and any dead key produced this frame, as UTF-8 - the only right way to fill a name field, because it is the characters the player meant rather than the keys they pressed (a binding reads keys by position; text reads what they type). Empty in a headless run.

```ludic
program Name {
  entry {
    var name = ""
    name = name + Input.text()
    print(name)
  }
}
```
