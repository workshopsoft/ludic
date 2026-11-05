---
id: keychain-delete
name: Keychain.delete
category: keychain
kind: namespace-method
tokens: Keychain.delete
sig: Keychain.delete(service, account) -> bool
tip: Remove a stored secret.
order: 3
ns: Keychain
member: delete
---

Removes the secret stored for (<code>service</code>, <code>account</code>) and returns <code>true</code> when one was removed. When there was none it returns <code>false</code> and <a href="keychain-error.html"><code>Keychain.error</code></a> is <code>""</code>; when the store failed, the error says why. Other accounts under the same service are left alone. Call it on log-out.

```ludic
program Demo {
  entry {
    Keychain.delete("com.example.game", "player")
  }
}
```
