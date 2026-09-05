# Ludic for JetBrains IDEs

Works in IntelliJ IDEA (Community and Ultimate), CLion, GoLand, PyCharm, Rider,
WebStorm — anything on the IntelliJ Platform 2023.2 through 2026.2
(`since-build` 232, `until-build` 262.*).

`until-build` 262 is deliberately ahead of the newest released platform — 2025.3
is build **253**, and no 262 IDE exists yet. That headroom is the point: an
`until-build` pinned to today's IDE gets the plugin auto-disabled the moment a
user upgrades.

Two things are machine-checked rather than assumed, because a plugin that
packages cleanly can still fail to load:

- `./gradlew verifyPlugin` runs JetBrains' own Plugin Verifier over the built
  artifact against 2025.3 and reports **Compatible**, with no deprecated or
  scheduled-for-removal API usages.
- `./gradlew runIde` boots a real IDEA 2025.3 with the plugin installed. The
  sandbox log line to look for is
  `Loaded custom plugins: LSP4IJ (0.20.1), Ludic (1.0.0)` in
  `.intellijPlatform/sandbox/Ludic/IC-2025.3/log/idea.log`.

**If the plugin does not appear in Settings -> Plugins after installing**, the
cause is almost always that the IDE's build number is outside
`since-build`..`until-build`. IntelliJ installs the declared dependency (LSP4IJ)
from Marketplace first and only then rejects the incompatible plugin, so the
symptom is "LSP4IJ got installed, mine did not". Check **Help -> About** for the
build number and widen `pluginUntilBuild` in `gradle.properties` to match.

## Building

Gradle must run on **JDK 17–21**. A newer JDK fails with a bare version number
as the error message, which is not obvious the first time you see it:

```bash
export JAVA_HOME=$(/usr/libexec/java_home -v 21)     # macOS
cd tools/editors/jetbrains
./gradlew buildPlugin        # -> build/distributions/Ludic-1.0.0.zip
./gradlew runIde             # try it in a sandbox IDE
```

The first build downloads an IntelliJ IDEA Community distribution (over 1 GB),
so expect it to take a while; later builds take seconds. Once the cache is warm,

```bash
LUDIC_TEST_JETBRAINS=1 bin/ludic-dev test-tools
```

includes the plugin build in the toolchain's own test run.

Install the zip with **Settings -> Plugins -> ⚙ -> Install Plugin from Disk**.
LSP4IJ is a required dependency; the IDE offers to install it for you.

## Settings

**Settings -> Languages & Frameworks -> Ludic** — the path to `ludic-lsp` and to
`ludicc`. Both default to `bin/` under the project root, which is where
`bin/ludic-dev tools` puts them.
