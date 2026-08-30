# Changelog

All notable changes to the Ludic toolchain, newest first. Generated from the
changesets under changes/ by x release; do not edit released sections by hand.

## v0.1.0 — 2026-08-30

- **ci**: Continuous integration — Forgejo Actions workflows build the toolchain from the seed, run the regression + editor suites, assert the C-free bootstrap fixpoint, and lint commit messages on every push and pull request.
- **feat**: Editor tooling — `ludic-fmt` (formatter) and `ludic-lsp` (language server), plus VS Code and JetBrains integrations, all built by the toolchain.
- **feat**: Namespaced standard library — Math, Text, List, Random, Time, Screen, Color, Ease, Collide, Memory, Vector, DateTime/Date/Duration/Clock, Unicode, Os, Fs/Path/Mime, Log, Noise, Hash, Crypto and Uuid, each deterministic where a game needs it.
- **feat**: Native 2D backend — an ECS core with a deterministic fixed-point (Q16.16) runtime, a windowed Cocoa target on macOS and a headless PPM renderer that runs anywhere.
- **feat**: Self-hosted, C-free toolchain — the compiler, runtime, task runner and editor tools are all written in Ludic and built from a checked-in LLVM-IR seed with clang alone; `x bootstrap-cfree` proves the compiler rebuilds itself byte-for-byte.
- **feat**: Versioning and releases — SemVer with `ludicc --version`, a changeset-driven `CHANGELOG.md`, and `x release` to bump, tag, and publish a Forgejo release with source and toolchain artifacts.

