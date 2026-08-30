---
id: uuid-nil
name: Uuid.nil
category: uuid
kind: namespace-method
tokens: Uuid.nil
sig: Uuid.nil() -> string
tip: The all-zero UUID.
order: 9
ns: Uuid
member: nil
---

Returns the nil UUID — <code>00000000-0000-0000-0000-000000000000</code> — the reserved all-zero value that means "no UUID". Use it as a sentinel for an unset or absent identity, and as the value <a href="uuid-parse"><code>Uuid.parse</code></a> returns when it is handed something that is not a valid UUID. It is a well-formed UUID string, so it passes <a href="uuid-is_valid"><code>Uuid.is_valid</code></a>; test for "no id" by comparing against <code>Uuid.nil()</code> explicitly.

```ludic
program Nil {
  entry {
    let none = Uuid.nil()
    print(none)   # 00000000-0000-0000-0000-000000000000
  }
}
```
