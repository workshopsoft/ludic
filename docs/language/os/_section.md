---
id: os
title: Os
order: 6
---

The operating-system interface — the environment *around* the game rather than the game itself: the command line, environment variables, the standard streams, the process exit code, the host platform, and the per-user folders a game writes its saves, config, and cache into. It rounds the bare <a href="ns-System"><code>System</code></a> builtins (<code>arg</code>, <code>getenv</code>, <code>exit</code>) into one coherent, Go-flavored namespace.

It is deliberately small and game-scoped: there is no process spawning, no signals, and no user/permission APIs. Reach for it in launchers, asset pipelines, and dev tools — parsing launch flags like <code>--level 3</code>, reading config from the environment, or resolving where a save file belongs — far more than in the simulation itself.

**Determinism:** <a href="os-args"><code>args</code></a>, the <a href="os-env"><code>env</code></a> family, and <a href="os-platform"><code>platform</code></a>/<a href="os-arch"><code>arch</code></a> are non-deterministic host input. Read them once at startup to configure the game, and keep them out of the replayable simulation so a shared seed still reproduces.

**Platform coverage:** this first version targets the native macOS/BSD host — the fully supported target today. <a href="os-platform"><code>platform</code></a> is portable (the <code>uname</code> system name is available on every Unix); <a href="os-arch"><code>arch</code></a> and the known-folder layout (<a href="os-save_dir"><code>save_dir</code></a>/<a href="os-config_dir"><code>config_dir</code></a>/<a href="os-cache_dir"><code>cache_dir</code></a>) follow the macOS conventions. Linux/Windows/wasm folder resolution and a target-aware <code>arch</code> are documented follow-ups.
