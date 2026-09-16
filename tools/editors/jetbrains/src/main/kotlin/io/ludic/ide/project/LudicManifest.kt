package io.ludic.ide.project

import com.intellij.openapi.vfs.VirtualFile
import com.intellij.psi.PsiFile
import java.io.File

/**
 * `package.ludic`, read the way `parse_manifest` (tools/ludic-cli/pkg.ludic)
 * reads it: one directive per line, `#` comments, double-quoted strings.
 */
data class LudicManifest(
    val module: String?,
    val version: String?,
    val kind: String?,
    val requires: List<Require>,
    val entry: String? = null,
    val app: Map<String, String> = emptyMap(),
    val packs: List<String> = emptyList(),
    val scripts: List<Script> = emptyList(),
    val hooks: List<Hook> = emptyList(),
) {
    data class Script(val name: String, val command: String, val line: Int)
    data class Hook(val phase: String, val event: String, val command: String, val line: Int)

    data class Require(val module: String, val version: String, val line: Int)

    /** One `module "…" version "…" hash "…" kind "…" provides "…"` line of the lock. */
    data class Locked(val module: String, val version: String, val hash: String, val kind: String, val provides: List<String>, val line: Int)

    companion object {
        const val FILE_NAME = "package.ludic"
        const val LOCK_NAME = "package.lock.ludic"

        fun isManifest(file: VirtualFile?) = file?.name == FILE_NAME
        fun isManifest(file: PsiFile?) = file?.name == FILE_NAME

        fun parse(text: CharSequence): LudicManifest {
            var module: String? = null
            var version: String? = null
            var kind: String? = null
            var entry: String? = null
            val requires = mutableListOf<Require>()
            val app = linkedMapOf<String, String>()
            val packs = mutableListOf<String>()
            val scripts = mutableListOf<Script>()
            val hooks = mutableListOf<Hook>()
            text.lines().forEachIndexed { i, raw ->
                val words = words(raw)
                when (words.firstOrNull()) {
                    "package" -> module = words.getOrNull(1)
                    "version" -> version = words.getOrNull(1)
                    "kind" -> kind = words.getOrNull(1)
                    "entry" -> entry = words.getOrNull(1)
                    "require" -> if (words.size > 2) requires += Require(words[1], words[2], i)
                    "pack" -> packs += words.drop(1)
                    "app" -> if (words.size > 2) app[words[1]] = words[2]
                    "script" -> if (words.size > 2) scripts += Script(words[1], words[2], i)
                    "hook" -> if (words.size > 3) hooks += Hook(words[1], words[2], words[3], i)
                }
            }
            return LudicManifest(module, version, kind, requires, entry, app, packs, scripts, hooks)
        }

        fun parseLock(text: CharSequence): List<Locked> = text.lines().mapIndexedNotNull { i, raw ->
            val w = words(raw)
            if (w.size < 2 || w[0] != "module") return@mapIndexedNotNull null
            val kv = mutableMapOf<String, String>()
            val provides = mutableListOf<String>()
            var k = 2
            while (k + 1 < w.size) {
                if (w[k] == "provides") provides += w[k + 1] else kv[w[k]] = w[k + 1]
                k += 2
            }
            Locked(w[1], kv["version"].orEmpty(), kv["hash"].orEmpty(), kv["kind"] ?: "source", provides, i)
        }

        fun isLock(file: VirtualFile?) = file?.name == LOCK_NAME
        fun isLock(file: PsiFile?) = file?.name == LOCK_NAME

        /** Directives whose values are paths, relative to the package root. */
        val PATH_DIRECTIVES = setOf("entry", "pack")
        val PATH_APP_KEYS = setOf("icon", "splash", "native", "out")

        /** The words of a manifest line: bare words and quoted strings, comment dropped. */
        fun words(line: String): List<String> {
            val out = mutableListOf<String>()
            var i = 0
            while (i < line.length) {
                val c = line[i]
                when {
                    c == '#' -> return out
                    c.isWhitespace() -> i++
                    c == '"' -> {
                        // a quoted word, with \" and \\ escapes as the CLI reads them
                        val sb = StringBuilder()
                        i++
                        while (i < line.length && line[i] != '"') {
                            if (line[i] == '\\' && i + 1 < line.length) { sb.append(line[i + 1]); i += 2 } else { sb.append(line[i]); i++ }
                        }
                        out += sb.toString()
                        i++
                    }
                    else -> {
                        val s = i
                        while (i < line.length && !line[i].isWhitespace() && line[i] != '#') i++
                        out += line.substring(s, i)
                    }
                }
            }
            return out
        }

        /**
         * Why the dependencies need fetching, or null when they look current:
         * no lock yet, a manifest edited after the lock, or nothing linked.
         */
        fun staleReason(dir: File, manifest: LudicManifest): String? {
            if (manifest.requires.isEmpty()) return null
            val man = File(dir, FILE_NAME)
            val lock = File(dir, LOCK_NAME)
            if (!lock.isFile) return "There is no $LOCK_NAME yet."
            if (man.lastModified() > lock.lastModified()) return "$FILE_NAME changed after the lock was written."
            val modules = File(dir, System.getenv("LUDIC_MODULES") ?: "ludic_modules")
            if (!modules.isDirectory) return "Nothing is linked into ${modules.name}/ yet."
            return null
        }

        /** Directive -> what it does, for completion and quick documentation. */
        val DIRECTIVES = linkedMapOf(
            "package" to "This package's import path, e.g. \"git.example.com/me/pkg\". Optional for a game.",
            "version" to "The version this checkout publishes (a git tag vX.Y.Z publishes it).",
            "kind" to "source (compiled with the game) or prebuilt (ships a dylib per target).",
            "entry" to "The program `ludic run`, `build` and `bundle` compile, e.g. \"src/game.ludic\".",
            "provides" to "The Foo.* namespace(s) this package registers. Repeatable.",
            "targets" to "For a prebuilt package: the targets it ships, e.g. \"native-arm64\" \"wasm32\".",
            "require" to "A dependency and its minimum version: require \"host/user/pkg\" \"1.0.0\".",
            "pack" to "An asset root `ludic pack` walks into the .lpak. Repeatable, in order.",
            "app" to "App bundle metadata for `ludic bundle`: app <key> \"value\".",
            "script" to "A named command: script \"dev\" \"ludic run --headless\". Run it with `ludic dev` or `ludic script dev`; extra arguments are passed on.",
            "hook" to "A command around another: hook before|after <command> \"…\". A failing before hook stops the command; after hooks run only when it succeeded.",
        )

        val HOOK_PHASES = linkedMapOf(
            "before" to "Runs first; a non-zero exit stops the command.",
            "after" to "Runs once the command succeeded.",
        )

        /** The built-in commands a hook can wrap (tools/ludic-cli/scripts.ludic is_hookable). */
        val HOOK_EVENTS = linkedMapOf(
            "build" to "ludic build", "run" to "ludic run", "test" to "ludic test", "bundle" to "ludic bundle",
            "pack" to "ludic pack", "clean" to "ludic clean", "fmt" to "ludic fmt", "get" to "ludic get",
            "add" to "ludic add", "update" to "ludic update", "verify" to "ludic verify", "vendor" to "ludic vendor",
            "assets" to "ludic assets", "build-lib" to "ludic build-lib",
        )

        /** Commands a script name would be shadowed by (the CLI's own). */
        val BUILTIN_COMMANDS = setOf(
            "new", "build", "run", "test", "clean", "fmt", "lsp", "doctor", "upgrade", "script", "scripts", "add", "get",
            "update", "verify", "vendor", "assets", "pack", "bundle", "build-lib", "link-flags", "version", "help", "dev",
        )

        val KINDS = linkedMapOf(
            "source" to "Compiled from source together with the program that imports it.",
            "prebuilt" to "Ships a compiled library per target (see targets); built with `ludic build-lib`.",
        )

        /** What each lock-file word means. */
        val LOCK_WORDS = linkedMapOf(
            "lock" to "The lock format version.",
            "module" to "A resolved package: its import path, then the pinned facts about it.",
            "version" to "The version Minimum Version Selection picked.",
            "hash" to "The content hash of the package in the store; `ludic verify` re-checks it.",
            "kind" to "source or prebuilt, as the package declares.",
            "provides" to "A Foo.* namespace the package registers.",
        )

        fun isSemver(v: String) = Regex("\\d+\\.\\d+\\.\\d+([-+][0-9A-Za-z.-]+)?").matches(v)

        /** The keys `ludic bundle` reads from `app` lines (tools/ludic-cli/bundle.ludic). */
        val APP_KEYS = linkedMapOf(
            "name" to "The app's display name.",
            "id" to "The bundle identifier, e.g. io.example.game.",
            "version" to "The bundle version (defaults to the package version).",
            "icon" to "A square PNG the .icns is built from.",
            "splash" to "An image shown while the game loads; it must be inside a packed asset root.",
            "splash_bg" to "The splash background colour, \"#rrggbb\".",
            "category" to "The macOS app category, e.g. public.app-category.games.",
            "copyright" to "The copyright line shown in Finder.",
            "min_macos" to "The minimum macOS version, e.g. \"11.0\".",
            "native" to "A directory of native libraries copied beside the executable.",
            "out" to "Where the .app is written (default build/<name>.app).",
            "sign" to "The codesign identity (default \"-\": ad-hoc signing).",
        )
    }
}
