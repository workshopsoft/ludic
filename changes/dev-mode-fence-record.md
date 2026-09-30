bump: minor
type: feat
**`dev_mode()` (ludic.base)** is the one documented dev switch (`R3D_DEV` set, not `0`); `ludic.devlink`'s `DevlinkWorld.enabled` defaults to it, and the docs no longer name a `dev_tools` symbol.

**An allocation-fence failure (exit 86/87) leaves a crash record** when the `ludic.crash` handler is installed: signame `ALLOC_FENCE`, the frame, bytes kept and the top three allocation sites first in `context`. `crash_exit_name` names 86/87.

**App name and version reach the program:** `Build.app_name()`, `Build.app_version()`, `Build.app_id()` from `package.ludic`. `Os.save_dir()` (and config/cache_dir, and every Os call) with the wrong argument count is a clean compile error instead of a compiler crash.

**`ludic.crash`:** `crash_boot(build)` wires the handler from package.ludic and a `CrashSettings` row (dir, keep_n, enabled, context); dev verbs `crash_pending` and `crash_context`. **`ludic.vitals`** gives a removed actor's record to the next `vitals_add` (a spawning crowd no longer trips the fence).

**`ludic.lab` `LabSteps`:** rows of named setup steps; `lab_boot` draws a first frame and a progress bar between them before the scene's setup, and prints `lab: step <key> (i of n)`.
