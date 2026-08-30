---
id: crypto-ct_equal
name: Crypto.ct_equal
category: crypto
kind: namespace-method
tokens: Crypto.ct_equal
sig: Crypto.ct_equal(a, b) -> bool
tip: Constant-time string equality for secrets.
order: 5
ns: Crypto
member: ct_equal
---

Compares two strings for equality without short-circuiting: every character is examined even once a difference is found, so the time taken does not reveal where — or whether — the strings first diverged. Reach for it whenever you compare a secret, token, or MAC that an attacker might be probing. For the common case of checking a message tag, <a href="crypto-verify_hmac"><code>Crypto.verify_hmac</code></a> already does this for you; use <code>ct_equal</code> directly when you hold both values yourself. Strings of different length return <code>false</code> at once (length is not secret). For ordinary, non-secret text just use <code>==</code> — the constant-time guarantee is not free.

Parameters:
- `a` — one string
- `b` — the other string

```ludic
program CompareToken {
  entry {
    if Crypto.ct_equal("abc", "abc") { print(1) } else { print(0) }   # 1
    if Crypto.ct_equal("abc", "abd") { print(1) } else { print(0) }   # 0
  }
}
```
