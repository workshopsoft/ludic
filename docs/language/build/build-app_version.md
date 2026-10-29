---
id: build-app_version
name: Build.app_version
category: build
kind: namespace-method
tokens: Build.app_version
sig: Build.app_version() -> string
tip: The app version from package.ludic.
order: 3
ns: Build
member: app_version
---

Returns the <code>app version</code> of the nearest <code>package.ludic</code>, falling back to its <code>version</code> line and then <code>0.1.0</code>. A compile-time constant; it takes no arguments.
