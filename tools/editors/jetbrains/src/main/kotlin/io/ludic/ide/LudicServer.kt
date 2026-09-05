package io.ludic.ide

import com.intellij.openapi.components.PersistentStateComponent
import com.intellij.openapi.components.Service
import com.intellij.openapi.components.State
import com.intellij.openapi.components.Storage
import com.intellij.openapi.components.service
import com.intellij.openapi.project.Project
import com.intellij.openapi.vfs.VirtualFile
import com.intellij.util.xmlb.XmlSerializerUtil
import com.redhat.devtools.lsp4ij.LanguageServerFactory
import com.redhat.devtools.lsp4ij.client.LanguageClientImpl
import com.redhat.devtools.lsp4ij.server.CannotStartProcessException
import com.redhat.devtools.lsp4ij.server.ProcessStreamConnectionProvider
import com.redhat.devtools.lsp4ij.server.StreamConnectionProvider
import java.io.File

/**
 * Where to find the toolchain. Both paths may be left blank, in which case the
 * plugin looks under the project root for what `bin/ludic dev tools` produces —
 * which is the case for anyone working in the Ludic repository itself.
 */
@Service(Service.Level.PROJECT)
@State(name = "LudicSettings", storages = [Storage("ludic.xml")])
class LudicSettings : PersistentStateComponent<LudicSettings> {
    var serverPath: String = ""
    var compilerPath: String = ""
    var compilerDiagnostics: Boolean = true
    var indentSize: Int = 2

    override fun getState(): LudicSettings = this
    override fun loadState(state: LudicSettings) = XmlSerializerUtil.copyBean(state, this)

    companion object {
        fun of(project: Project): LudicSettings = project.service()
    }
}

/**
 * First existing executable among the usual places, or null.
 *
 * Takes the project root as a plain path rather than a Project so it can be
 * tested without booting an IDE — this lookup silently returning null is the
 * difference between a working language server and one that never starts.
 */
internal fun findExecutable(root: String?, configured: String, names: List<String>, subdirs: List<String>): String? {
    if (configured.isNotBlank()) {
        val f = File(expandHome(configured))
        return if (f.canExecute()) f.absolutePath else null
    }
    if (root == null) return searchPath(names)
    for (dir in subdirs) {
        for (name in names) {
            val f = File(File(root, dir), name)
            if (f.isFile && f.canExecute()) return f.absolutePath
        }
    }
    return searchPath(names)
}

/** Fall back to PATH, so a system-wide install works with no configuration. */
private fun searchPath(names: List<String>): String? {
    val path = System.getenv("PATH")
    if (path != null) {
        for (dir in path.split(File.pathSeparator)) {
            for (name in names) {
                val f = File(dir, name)
                if (f.isFile && f.canExecute()) return f.absolutePath
            }
        }
    }
    // The install root, last: an IDE launched from the desktop does not inherit
    // the PATH the installer wrote to the shell profile, so a working ~/.ludic
    // install would otherwise look missing.
    val home = System.getenv("LUDIC_HOME") ?: (System.getProperty("user.home") + "/.ludic")
    for (name in names) {
        val f = File(File(home, "bin"), name)
        if (f.isFile && f.canExecute()) return f.absolutePath
    }
    return null
}

private fun expandHome(p: String) =
    if (p.startsWith("~")) System.getProperty("user.home") + p.substring(1) else p

class LudicConnectionProvider(private val project: Project) : ProcessStreamConnectionProvider() {

    /**
     * Resolve at start(), not at construction.
     *
     * The provider is built when the project opens, which is usually before the
     * toolchain has been compiled. Resolving in an `init` block froze that
     * answer forever: build ludic-lsp afterwards and the server stayed dead
     * until the IDE was restarted, with `commands=[]` as the only clue.
     */
    override fun start() {
        val settings = LudicSettings.of(project)
        val root = project.basePath
        setCommands(serverCommand(root, settings.serverPath)
            ?: throw CannotStartProcessException(notFoundMessage(root, settings.serverPath)))
        root?.let { setWorkingDirectory(it) }
        super.start()
    }

    /**
     * What went wrong, in terms of the user's filesystem. "commands=[]" tells
     * nobody anything; this names every path that was tried.
     */
    private fun notFoundMessage(root: String?, configured: String): String = buildString {
        if (configured.isNotBlank()) {
            append("The Ludic language server configured at '")
            append(configured)
            append("' is missing or not executable.")
        } else {
            append("Could not find the 'ludic-lsp' executable. Looked in:\n")
            SERVER_SUBDIRS.forEach { d ->
                append("  ")
                append(if (root != null) File(File(root, d), "ludic-lsp").path else "<no project root>/$d/ludic-lsp")
                append('\n')
            }
            append("  on PATH, and in ~/.ludic/bin.\n")
        }
        append("\nInstall the toolchain (curl -fsSL https://workshopsoft.pages.workshopsoft.io/ludic/install.sh | sh), ")
        append("build it with `bin/ludic dev tools` from a checkout, ")
        append("or set the path in Settings | Languages & Frameworks | Ludic. ")
        append("Syntax highlighting works without it; completion and diagnostics do not.")
    }

    /**
     * Passed to the server's `initialize`. The server can find `ludicc` on its
     * own, but telling it explicitly means the IDE's setting wins.
     */
    override fun getInitializationOptions(rootUri: VirtualFile?): Any {
        val settings = LudicSettings.of(project)
        val compiler = findExecutable(
            project.basePath, settings.compilerPath,
            listOf("ludicc", "ludicc.exe"),
            COMPILER_SUBDIRS
        ) ?: ""
        return mapOf(
            "compilerPath" to compiler,
            "compilerDiagnostics" to settings.compilerDiagnostics,
            "indentSize" to settings.indentSize
        )
    }
}

/**
 * The exact argv the language server is launched with, or null when the binary
 * cannot be found. Split out from start() so the command line itself is
 * testable — an empty or wrong command here is invisible until LSP4IJ reports
 * `commands=[]`, which says nothing about why.
 */
internal fun serverCommand(root: String?, configured: String): List<String>? {
    val exe = findExecutable(root, configured, listOf("ludic-lsp", "ludic-lsp.exe"), SERVER_SUBDIRS)
    return exe?.let { listOf(it, "--stdio") }
}

/** Where the toolchain is looked for, relative to the project root. */
internal val SERVER_SUBDIRS = listOf("bin", "build", "tools/build", ".")
internal val COMPILER_SUBDIRS = listOf("bin", "build", ".")

class LudicLanguageServerFactory : LanguageServerFactory {
    override fun createConnectionProvider(project: Project): StreamConnectionProvider =
        LudicConnectionProvider(project)

    override fun createLanguageClient(project: Project): LanguageClientImpl =
        LanguageClientImpl(project)
}
