package io.ludic.ide.project

import com.intellij.openapi.fileEditor.FileDocumentManager
import com.intellij.openapi.vfs.LocalFileSystem
import java.io.File

/**
 * One package as the Ludic tool window shows it: the manifest (read from the
 * open editor when there is one, so unsaved edits show), its lock, and where
 * each dependency is linked.
 */
class LudicPackageInfo(val dir: File, val manifest: LudicManifest, val locked: List<LudicManifest.Locked>?) {

    val name: String get() = manifest.module?.substringAfterLast('/') ?: dir.name
    val manifestFile: File get() = File(dir, LudicManifest.FILE_NAME)
    val lockFile: File get() = File(dir, LudicManifest.LOCK_NAME)

    /** Why the dependencies need fetching, or null when they look current. */
    val staleReason: String? get() = LudicManifest.staleReason(dir, manifest)

    /** Hooks that wrap [event] (a command or a script name). */
    fun hooksOf(event: String) = manifest.hooks.filter { it.event == event }

    fun lockedOf(module: String) = locked?.firstOrNull { it.module == module }

    /** Locked modules nobody in this manifest asked for: pulled in by the dependencies. */
    val transitive: List<LudicManifest.Locked>
        get() = locked.orEmpty().filter { l -> manifest.requires.none { it.module == l.module } }

    /** The directory a module is linked at (vendor/ wins, as in the compiler), or null. */
    fun linkedDir(module: String): File? {
        val modules = File(dir, System.getenv("LUDIC_MODULES") ?: "ludic_modules")
        return listOf(File(dir, "vendor/$module"), File(modules, module)).firstOrNull { it.isDirectory }
    }

    fun status(req: LudicManifest.Require): DepStatus {
        val l = lockedOf(req.module) ?: return DepStatus.NOT_LOCKED
        if (linkedDir(req.module) == null) return DepStatus.NOT_LINKED
        return if (LudicManifest.isSemver(l.version) && LudicManifest.isSemver(req.version) && versionLess(l.version, req.version))
            DepStatus.BELOW_MINIMUM else DepStatus.OK
    }

    enum class DepStatus(val label: String) {
        OK("locked"), NOT_LOCKED("not in the lock"), NOT_LINKED("not linked"), BELOW_MINIMUM("locked below the minimum"),
    }

    companion object {
        private val SKIP = setOf("ludic_modules", "vendor", "build", "node_modules", "out", "dist")
        private const val MAX = 24

        /** Every package.ludic under [base], the root one first, at most two levels down. */
        fun discover(base: File): List<LudicPackageInfo> {
            val found = mutableListOf<File>()
            fun walk(d: File, depth: Int) {
                if (found.size >= MAX) return
                if (File(d, LudicManifest.FILE_NAME).isFile) found += d
                if (depth == 0) return
                d.listFiles()?.filter { it.isDirectory && !it.name.startsWith('.') && it.name !in SKIP }
                    ?.sortedBy { it.name }?.forEach { walk(it, depth - 1) }
            }
            walk(base, 2)
            return found.mapNotNull(::load)
        }

        fun load(dir: File): LudicPackageInfo? {
            val text = read(File(dir, LudicManifest.FILE_NAME)) ?: return null
            val lock = read(File(dir, LudicManifest.LOCK_NAME))?.let { LudicManifest.parseLock(it) }
            return LudicPackageInfo(dir, LudicManifest.parse(text), lock)
        }

        /** The file's text, from its open document when it has one. */
        private fun read(f: File): String? {
            if (!f.isFile) return null
            val vf = LocalFileSystem.getInstance().findFileByIoFile(f)
            val doc = vf?.let { FileDocumentManager.getInstance().getCachedDocument(it) }
            return doc?.text ?: runCatching { f.readText() }.getOrNull()
        }

        fun versionLess(a: String, b: String): Boolean {
            val x = a.substringBefore('-').substringBefore('+').split('.').map { it.toIntOrNull() ?: 0 }
            val y = b.substringBefore('-').substringBefore('+').split('.').map { it.toIntOrNull() ?: 0 }
            for (i in 0 until 3) if (x.getOrElse(i) { 0 } != y.getOrElse(i) { 0 }) return x.getOrElse(i) { 0 } < y.getOrElse(i) { 0 }
            return false
        }

        /** The built-in commands the tool window offers, with what each does. */
        val COMMANDS = listOf(
            Command("Run", "run", "Build the entry program and start it."),
            Command("Build", "build", "Compile the entry program into build/."),
            Command("Test", "test", "Compile and run every test block under the package."),
            Command("Bundle", "bundle", "Build the shippable app from the app lines and the packed assets."),
            Command("Pack", "pack", "Walk the pack roots into a .lpak asset archive."),
            Command("Format", "fmt", "Format every .ludic file in the package."),
            Command("Clean", "clean", "Remove build/."),
            Command("Doctor", "doctor", "Check the toolchain: clang, the install root, the store."),
        )
    }

    data class Command(val title: String, val verb: String, val help: String)
}
