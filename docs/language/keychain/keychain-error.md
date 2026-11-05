---
id: keychain-error
name: Keychain.error
category: keychain
kind: namespace-method
tokens: Keychain.error
sig: Keychain.error() -> string
tip: Why the last Keychain call failed, or "".
order: 5
ns: Keychain
member: error
---

Returns why the last <code>Keychain.*</code> call failed, in the operating system's words — on macOS the <code>OSStatus</code> and its text (<code>OSStatus -25308 (User interaction is not allowed.)</code>), on Windows the system message for the error code, on Linux the Secret Service's message, or that libsecret is not installed. It is <code>""</code> after a call that succeeded <em>and</em> after one that simply found nothing, so it separates "no secret stored" from "the store failed".

```ludic
program Demo {
  entry {
    let t = Keychain.get("com.example.game", "player")
    if t == null and Keychain.error() != "" { print(Keychain.error()) }
  }
}
```
