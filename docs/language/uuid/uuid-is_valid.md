---
id: uuid-is_valid
name: Uuid.is_valid
category: uuid
kind: namespace-method
tokens: Uuid.is_valid
sig: Uuid.is_valid(s) -> bool
tip: Is s a well-formed UUID string?
order: 6
ns: Uuid
member: is_valid
---

Reports whether <code>s</code> is a well-formed UUID: exactly 36 characters, hyphens at positions 8, 13, 18 and 23, and hexadecimal digits (either case) everywhere else. This is the guard to run on any UUID that came from outside your program — a save file, a network message, a mod, a command-line flag — before you trust it as an identity.

It checks *shape*, not version: both v4 and v7 IDs (and any other conforming UUID) pass. To also fold a malformed value into a safe default in one step, use <a href="uuid-parse"><code>Uuid.parse</code></a> instead.

Parameters:
- `s` — the string to check

```ludic
program Valid {
  entry {
    if Uuid.is_valid("550e8400-e29b-41d4-a716-446655440000") { print(1) }
    if not Uuid.is_valid("not-a-uuid") { print(2) }
  }
}
```
