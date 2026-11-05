bump: minor
type: feat
**`Keychain.*` — the operating system's secret store** on macOS, Windows and Linux: keep a login token or password where the OS keeps them, never in a save file.

- `Keychain.set(service, account, secret)`, `Keychain.get` (null when there is none), `Keychain.has`, `Keychain.delete`, `Keychain.available()` and `Keychain.error()` (the OS's reason, `""` when a call succeeded or simply found nothing).
- **macOS** — the login keychain through Security.framework (a generic password item). **Windows** — Credential Manager through advapi32 (a generic credential named `service/account`). **Linux** — the Secret Service (GNOME Keyring, KWallet, KeePassXC) through libsecret, opened at run time, so a program still starts where it is not installed and `Keychain.available()` says so.
- Items use the names keytar and `secret-tool` use, so other tools read what a game stores and the other way round.
