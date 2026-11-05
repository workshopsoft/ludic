---
id: keychain-available
name: Keychain.available
category: keychain
kind: namespace-method
tokens: Keychain.available
sig: Keychain.available() -> bool
tip: Can secrets be stored on this machine?
order: 4
ns: Keychain
member: available
---

Returns <code>true</code> when the OS secret store can be used. It always is on macOS and Windows. On Linux it is when libsecret (<code>libsecret-1-0</code>) is installed and a Secret Service — GNOME Keyring, KWallet, KeePassXC — answers on the session bus; a headless server or a bare container usually has none. When it is <code>false</code>, <a href="keychain-error.html"><code>Keychain.error</code></a> says what is missing, and a game can fall back to asking for the password each time.

```ludic
program Demo {
  entry {
    if not Keychain.available() { print(`no keychain here: {Keychain.error()}`) }
  }
}
```
