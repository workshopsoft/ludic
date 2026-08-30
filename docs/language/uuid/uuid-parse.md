---
id: uuid-parse
name: Uuid.parse
category: uuid
kind: namespace-method
tokens: Uuid.parse
sig: Uuid.parse(s) -> string
tip: Normalise an untrusted string to a lowercase UUID, or the nil UUID.
order: 5
ns: Uuid
member: parse
---

Normalises an untrusted string: if <code>s</code> is a well-formed UUID it returns the same value in canonical lowercase form; if it is not, it returns the <a href="uuid-nil"><code>nil</code></a> UUID. This never faults on garbage, so it is safe to call on data that arrived from a file, a network peer, or a mod. When you need to *reject* bad input rather than fold it to nil, gate on <a href="uuid-is_valid"><code>Uuid.is_valid</code></a> first.

Parsing accepts either case and yields the lowercase canonical form, which is what the rest of the library produces — so a parsed ID compares equal (with <code>==</code>) to a freshly generated one of the same value.

Parameters:
- `s` — the string to validate and normalise

```ludic
program Parse {
  entry {
    let id = Uuid.parse("550E8400-E29B-41D4-A716-446655440000")
    print(id[0..8])                          # 550e8400 — lowercased
    if Uuid.parse("nope") == Uuid.nil() { print(1) }
  }
}
```
