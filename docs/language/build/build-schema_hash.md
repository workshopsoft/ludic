---
id: build-schema_hash
name: Build.schema_hash
category: build
kind: namespace-method
tokens: Build.schema_hash
sig: Build.schema_hash() -> long
tip: FNV-1a 64 of the program's schema.
order: 1
ns: Build
member: schema_hash
---

Returns FNV-1a 64 of the bytes <code>ludic schema</code> prints for the program being built, worked out once and only when the program names it. A tool talking to a running build can compare it to tell whether the build came from the data in front of it. It is 0 in a release (<code>ludicc --release</code>, which <code>ludic bundle</code> passes).
