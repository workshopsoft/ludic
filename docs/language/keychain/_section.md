---
id: keychain
title: Keychain
order: 51
---

The operating system's own secret store — the place for a login token, a password or a session key, so it never sits in a save file. A secret is a short string named by a <em>service</em> (your game, e.g. <code>"com.example.game"</code>) and an <em>account</em> (whose secret it is). <a href="keychain-set.html"><code>Keychain.set</code></a> stores or replaces it, <a href="keychain-get.html"><code>Keychain.get</code></a> reads it back, <a href="keychain-has.html"><code>Keychain.has</code></a> asks whether there is one, and <a href="keychain-delete.html"><code>Keychain.delete</code></a> removes it. When a call fails, <a href="keychain-error.html"><code>Keychain.error</code></a> says why, in the OS's words.

<table>
<tr><th>Platform</th><th>Store</th><th>Where to see it</th></tr>
<tr><td>macOS</td><td>The login keychain (Security.framework), a generic password item</td><td>Keychain Access; <code>security find-generic-password -s SERVICE -a ACCOUNT -w</code></td></tr>
<tr><td>Windows</td><td>Credential Manager (advapi32), a generic credential named <code>service/account</code></td><td>Control Panel › Credential Manager › Windows Credentials</td></tr>
<tr><td>Linux</td><td>The Secret Service on the session bus (GNOME Keyring, KWallet, KeePassXC) through libsecret</td><td>Seahorse; <code>secret-tool lookup service SERVICE account ACCOUNT</code></td></tr>
</table>

The names are the ones keytar and <code>secret-tool</code> use, so other tools read what a game stores. On Linux, libsecret is opened when the program runs rather than linked, so a game that uses <code>Keychain.*</code> still starts on a machine without it; <a href="keychain-available.html"><code>Keychain.available</code></a> is then false and every call fails with the reason.

Every call is synchronous and may wait on the OS — a locked keyring asks the user to unlock it, and on macOS a program that did not create an item may be asked to allow access — so call it at start-up or from a menu, never every frame. Secrets are text: a secret cannot hold a zero byte (use <code>Base64.*</code> for binary data), and Windows keeps at most 2560 bytes. Like <code>Http.*</code> it is <strong>out-of-band</strong> and must never feed the deterministic lockstep/replay simulation.
