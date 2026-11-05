---
id: keychain-get
name: Keychain.get
category: keychain
kind: namespace-method
tokens: Keychain.get
sig: Keychain.get(service, account) -> string
tip: The stored secret, or null.
order: 1
ns: Keychain
member: get
---

Returns the secret stored for (<code>service</code>, <code>account</code>), or <code>null</code> when there is none. A <code>null</code> is also what a failure gives; <a href="keychain-error.html"><code>Keychain.error</code></a> tells the two apart — it is <code>""</code> when there was simply nothing stored.

```ludic
program Demo {
  entry {
    let token = Keychain.get("com.example.game", "player")
    if token == null {
      if Keychain.error() != "" { print(`the keychain failed: {Keychain.error()}`) }
      else { print("not logged in yet") }
    }
  }
}
```
