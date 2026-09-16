package io.ludic.ide.project

import com.intellij.navigation.ItemPresentation
import com.intellij.openapi.project.Project
import com.intellij.openapi.roots.AdditionalLibraryRootsProvider
import com.intellij.openapi.roots.SyntheticLibrary
import com.intellij.openapi.vfs.LocalFileSystem
import com.intellij.openapi.vfs.VirtualFile
import io.ludic.ide.LudicIcons
import io.ludic.ide.LudicToolchain
import java.io.File
import javax.swing.Icon

/**
 * External Libraries, one node per thing a build can import:
 *
 *   Ludic built-in runtime          <home>/runtime — the language's own library
 *   Ludic language reference        <home>/docs/language — what hover and go-to open
 *   ludic.render3d 0.4.0            <home>/packages/<name> — packages shipped with the toolchain
 *   git.example.com/me/util 1.2.0   ludic_modules/ or vendor/ — fetched packages, per the lock
 *
 * so they are indexed, searchable and browsable next to the project.
 */
class LudicPackagesLibraryProvider : AdditionalLibraryRootsProvider() {

    override fun getAdditionalProjectLibraries(project: Project): Collection<SyntheticLibrary> {
        val base = project.basePath ?: return emptyList()
        val lfs = LocalFileSystem.getInstance()
        val out = mutableListOf<SyntheticLibrary>()
        fun add(name: String, kind: Kind, path: File) {
            lfs.findFileByIoFile(path)?.takeIf { it.isDirectory }?.let { out += LudicPackagesLibrary(name, kind, it) }
        }

        val home = LudicToolchain.home(project)
        // a checkout of the toolchain already has all of this as project content
        val insideHome = home != null && File(base).canonicalPath.let { it == home.canonicalPath || it.startsWith(home.canonicalPath + "/") }
        if (home != null && !insideHome) {
            add("Ludic built-in runtime", Kind.BUILTIN, File(home, "runtime"))
            add("Ludic language reference", Kind.BUILTIN, File(home, "docs/language"))
            File(home, "packages").listFiles()?.filter { it.isDirectory }?.sortedBy { it.name }?.forEach { pkg ->
                add(labelOf(pkg, pkg.name), Kind.TOOLCHAIN, pkg)
            }
        }

        val lock = File(base, LudicManifest.LOCK_NAME)
        val locked = if (lock.isFile) runCatching { LudicManifest.parseLock(lock.readText()) }.getOrDefault(emptyList()) else emptyList()
        val modules = File(base, System.getenv("LUDIC_MODULES") ?: "ludic_modules")
        val vendor = File(base, "vendor")
        for (m in locked) {
            val dir = listOf(File(vendor, m.module), File(modules, m.module)).firstOrNull { it.isDirectory } ?: continue
            add("${m.module} ${m.version}", Kind.REMOTE, dir)
        }
        if (locked.isEmpty()) {
            // fetched without a lock we can read: show the link roots as they are
            add("Ludic packages (ludic_modules)", Kind.REMOTE, modules)
            add("Ludic packages (vendor)", Kind.REMOTE, vendor)
        }
        return out
    }

    override fun getRootsToWatch(project: Project): Collection<VirtualFile> =
        getAdditionalProjectLibraries(project).flatMap { it.sourceRoots }

    /** `ludic.render3d 0.4.0` from the package's own manifest, when it has one. */
    private fun labelOf(dir: File, fallback: String): String {
        val man = File(dir, LudicManifest.FILE_NAME)
        if (!man.isFile) return fallback
        val m = runCatching { LudicManifest.parse(man.readText()) }.getOrNull() ?: return fallback
        return listOfNotNull(fallback, m.version).joinToString(" ")
    }

    enum class Kind { BUILTIN, TOOLCHAIN, REMOTE }
}

class LudicPackagesLibrary(private val name: String, private val kind: LudicPackagesLibraryProvider.Kind, private val root: VirtualFile) :
    SyntheticLibrary("ludic:" + root.path, ExcludeFileCondition { isDir, filename, _, _, _ ->
        // sources, manifests and docs only: packages also carry large binary assets
        !isDir && !(filename.endsWith(".ludic") || filename.endsWith(".md"))
    }), ItemPresentation {
    override fun getSourceRoots(): Collection<VirtualFile> = listOf(root)
    override fun equals(other: Any?) = other is LudicPackagesLibrary && other.root == root && other.name == name
    override fun hashCode() = root.hashCode()
    override fun getPresentableText() = name
    override fun getLocationString(): String? = when (kind) {
        LudicPackagesLibraryProvider.Kind.BUILTIN -> "built-in"
        LudicPackagesLibraryProvider.Kind.TOOLCHAIN -> "toolchain"
        LudicPackagesLibraryProvider.Kind.REMOTE -> "fetched"
    }
    override fun getIcon(unused: Boolean): Icon = if (kind == LudicPackagesLibraryProvider.Kind.BUILTIN) LudicIcons.FILE else LudicPackageIcons.MANIFEST
}
