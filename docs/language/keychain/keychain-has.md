---
id: keychain-has
name: Keychain.has
category: keychain
kind: namespace-method
tokens: Keychain.has
sig: Keychain.has(service, account) -> bool
tip: Is a secret stored for this pair?
order: 2
ns: Keychain
member: has
---

Returns <code>true</code> when a secret is stored for (<code>service</code>, <code>account</code>). It reads the secret to find out, so on macOS and Linux it may ask the user exactly as <a href="keychain-get.html"><code>Keychain.get</code></a> would. <code>false</code> covers both "none" and a failure; see <a href="keychain-error.html"><code>Keychain.error</code></a>.

```ludic
program Demo {
  entry {
    if Keychain.has("com.example.game", "player") { print("welcome back") }
  }
}
```
