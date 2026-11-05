---
id: keychain-set
name: Keychain.set
category: keychain
kind: namespace-method
tokens: Keychain.set
sig: Keychain.set(service, account, secret) -> bool
tip: Store a secret in the OS store, replacing any.
order: 0
ns: Keychain
member: set
---

Stores <code>secret</code> for the pair (<code>service</code>, <code>account</code>) in the operating system's secret store, replacing the secret that was there, and returns <code>true</code> when it was stored. On <code>false</code>, <a href="keychain-error.html"><code>Keychain.error</code></a> says why — a locked keyring the user declined to unlock, no Secret Service on Linux, a secret over Windows' 2560-byte limit.

All three are text. A <code>null</code> is taken as <code>""</code>. Each (service, account) pair is its own item: two accounts under one service never overwrite each other.

```ludic
program Demo {
  entry {
    if not Keychain.set("com.example.game", "player", "token-123") {
      print(`could not save the login: {Keychain.error()}`)
    }
  }
}
```
