package io.ludic.ide.project

import com.intellij.execution.lineMarker.RunLineMarkerContributor
import com.intellij.icons.AllIcons
import com.intellij.ide.IconProvider
import com.intellij.openapi.actionSystem.AnAction
import com.intellij.openapi.actionSystem.AnActionEvent
import com.intellij.openapi.editor.Document
import com.intellij.openapi.fileEditor.FileDocumentManager
import com.intellij.openapi.fileEditor.FileEditor
import com.intellij.openapi.fileEditor.OpenFileDescriptor
import com.intellij.openapi.options.ShowSettingsUtil
import com.intellij.openapi.project.DumbAware
import com.intellij.openapi.project.Project
import com.intellij.openapi.util.IconLoader
import com.intellij.openapi.util.TextRange
import com.intellij.openapi.vfs.LocalFileSystem
import com.intellij.openapi.vfs.VirtualFile
import com.intellij.openapi.vfs.newvfs.BulkFileListener
import com.intellij.openapi.vfs.newvfs.events.VFileEvent
import com.intellij.psi.PsiDocumentManager
import com.intellij.psi.PsiElement
import com.intellij.psi.PsiFile
import com.intellij.ui.EditorNotificationPanel
import com.intellij.ui.EditorNotificationProvider
import com.intellij.ui.EditorNotifications
import io.ludic.ide.LudicConfigurable
import io.ludic.ide.LudicToolchain
import io.ludic.ide.run.LudicCliAction
import io.ludic.ide.run.LudicCommand
import java.io.File
import java.util.function.Function
import javax.swing.Icon
import javax.swing.JComponent

object LudicPackageIcons {
    val MANIFEST: Icon = IconLoader.getIcon("/icons/ludicPackage.svg", LudicPackageIcons::class.java)
}

/** Run a `ludic` command in the package that owns [dir]. */
internal fun runLudic(project: Project, command: LudicCommand, args: String, dir: String) {
    FileDocumentManager.getInstance().saveAllDocuments()
    LudicCliAction.run(project, command, args, dir)
}

internal fun cliAction(text: String, icon: Icon?, project: Project, dir: String, command: LudicCommand, args: String = ""): AnAction =
    object : AnAction(text, null, icon), DumbAware {
        override fun actionPerformed(e: AnActionEvent) = runLudic(project, command, args, dir)
    }

/** The whole line an element sits on, and the words on it. */
internal data class ManifestLine(val index: Int, val range: TextRange, val text: String, val words: List<String>) {
    val directive: String? get() = words.firstOrNull()

    companion object {
        fun at(element: PsiElement): ManifestLine? {
            val file = element.containingFile ?: return null
            val doc = PsiDocumentManager.getInstance(file.project).getDocument(file) ?: return null
            return at(doc, element.textOffset)
        }

        fun at(doc: Document, offset: Int): ManifestLine {
            val line = doc.getLineNumber(offset.coerceIn(0, doc.textLength))
            val range = TextRange(doc.getLineStartOffset(line), doc.getLineEndOffset(line))
            val text = doc.getText(range)
            return ManifestLine(line, range, text, LudicManifest.words(text))
        }
    }

    /** Is the element the first word on its line? */
    fun startsWith(element: PsiElement) = text.substring(0, element.textOffset - range.startOffset).isBlank()
}

/**
 * The bar across the top of package.ludic and package.lock.ludic.
 *
 * On the manifest: the package's identity and the commands that act on it,
 * turning into a prompt to fetch when the lock is missing or older than the
 * manifest, the way a build-file sync does. On the lock: a reminder that it is
 * generated, with the commands that regenerate and check it.
 */
class LudicPackageNotificationProvider : EditorNotificationProvider, DumbAware {
    override fun collectNotificationData(project: Project, file: VirtualFile): Function<in FileEditor, out JComponent?>? {
        val isManifest = LudicManifest.isManifest(file)
        if (!isManifest && !LudicManifest.isLock(file)) return null
        val dir = file.parent?.path ?: return null
        val cli = LudicToolchain.cli(project)
        if (!isManifest) return lockBanner(project, dir, cli != null)

        val text = FileDocumentManager.getInstance().getCachedDocument(file)?.charsSequence
            ?: runCatching { String(file.contentsToByteArray(), Charsets.UTF_8) }.getOrNull() ?: return null
        val manifest = LudicManifest.parse(text)
        val stale = LudicManifest.staleReason(File(dir), manifest)
        return Function { editor ->
            val panel = if (stale != null) EditorNotificationPanel(editor, EditorNotificationPanel.Status.Warning)
            else EditorNotificationPanel(editor, EditorNotificationPanel.Status.Info)
            panel.icon(LudicPackageIcons.MANIFEST)
            val name = manifest.module ?: File(dir).name
            val ver = manifest.version?.let { " $it" } ?: ""
            val deps = manifest.requires.size.let { if (it == 1) "1 dependency" else "$it dependencies" }
            val entry = manifest.entry?.let { " · entry $it" } ?: ""
            panel.text = when {
                cli == null -> "Ludic package $name$ver — the 'ludic' command was not found."
                stale != null -> "$stale Fetch the dependencies so builds and code insight see them."
                else -> "Ludic package $name$ver · $deps$entry"
            }
            if (cli != null) {
                val get = if (stale != null) "Fetch Dependencies" else "Fetch"
                panel.createActionLabel(get) { runLudic(project, LudicCommand.CUSTOM, "get", dir) }
                if (manifest.requires.isNotEmpty()) {
                    panel.createActionLabel("Update All") { runLudic(project, LudicCommand.CUSTOM, "update", dir) }
                    panel.createActionLabel("Verify") { runLudic(project, LudicCommand.CUSTOM, "verify", dir) }
                }
                panel.createActionLabel("Run") { runLudic(project, LudicCommand.RUN, "", dir) }
                panel.createActionLabel("Test") { runLudic(project, LudicCommand.TEST, "", dir) }
                panel.createActionLabel("Build") { runLudic(project, LudicCommand.BUILD, "", dir) }
                panel.createActionLabel("Bundle") { runLudic(project, LudicCommand.CUSTOM, "bundle", dir) }
                manifest.scripts.take(4).forEach { s ->
                    panel.createActionLabel("▶ ${s.name}") { runLudic(project, LudicCommand.CUSTOM, "script ${s.name}", dir) }
                }
            } else {
                panel.createActionLabel("Set Paths…") {
                    ShowSettingsUtil.getInstance().showSettingsDialog(project, LudicConfigurable::class.java)
                }
            }
            panel
        }
    }

    private fun lockBanner(project: Project, dir: String, hasCli: Boolean) = Function<FileEditor, JComponent?> { editor ->
        val panel = EditorNotificationPanel(editor, EditorNotificationPanel.Status.Info)
        panel.icon(LudicPackageIcons.MANIFEST)
        panel.text = "Generated by `ludic get` — edit package.ludic, then fetch again."
        panel.createActionLabel("Open package.ludic") {
            LocalFileSystem.getInstance().findFileByPath("$dir/${LudicManifest.FILE_NAME}")?.let {
                OpenFileDescriptor(project, it).navigate(true)
            }
        }
        if (hasCli) {
            panel.createActionLabel("Regenerate") { runLudic(project, LudicCommand.CUSTOM, "get", dir) }
            panel.createActionLabel("Verify Hashes") { runLudic(project, LudicCommand.CUSTOM, "verify", dir) }
            panel.createActionLabel("Vendor") { runLudic(project, LudicCommand.CUSTOM, "vendor", dir) }
        }
        panel
    }
}

/** Keeps the bars and the library list current as manifests, locks and linked packages change. */
class LudicManifestWatcher(private val project: Project) : BulkFileListener {
    override fun after(events: List<VFileEvent>) {
        val relevant = events.any { e ->
            val n = e.path.substringAfterLast('/')
            n == LudicManifest.FILE_NAME || n == LudicManifest.LOCK_NAME || n == "ludic_modules" || n == "vendor"
        }
        if (relevant && !project.isDisposed) EditorNotifications.getInstance(project).updateAllNotifications()
    }
}

/**
 * Gutter actions: the package line runs the package, the entry line runs the
 * entry, a require (or lock module) line updates that dependency.
 */
class LudicManifestLineMarker : RunLineMarkerContributor() {
    override fun getInfo(element: PsiElement): Info? {
        val file = element.containingFile ?: return null
        val manifest = LudicManifest.isManifest(file)
        if (!manifest && !LudicManifest.isLock(file)) return null
        if (element.firstChild != null) return null
        val word = element.text
        if (word != "package" && word != "require" && word != "entry" && word != "module" && word != "script") return null
        val line = ManifestLine.at(element) ?: return null
        if (!line.startsWith(element)) return null
        val dir = file.virtualFile?.parent?.path ?: return null
        val project = file.project
        return when {
            manifest && word == "package" -> Info(
                AllIcons.RunConfigurations.TestState.Run,
                arrayOf(
                    cliAction("Run Package", AllIcons.Actions.Execute, project, dir, LudicCommand.RUN),
                    cliAction("Test Package", AllIcons.RunConfigurations.TestState.Run_run, project, dir, LudicCommand.TEST),
                    cliAction("Build Package", AllIcons.Actions.Compile, project, dir, LudicCommand.BUILD),
                    cliAction("Fetch Dependencies", AllIcons.Actions.Download, project, dir, LudicCommand.CUSTOM, "get"),
                    cliAction("Bundle App", AllIcons.Nodes.Artifact, project, dir, LudicCommand.CUSTOM, "bundle"),
                )
            ) { "Run, test or build this package" }
            manifest && word == "entry" -> Info(
                AllIcons.RunConfigurations.TestState.Run,
                arrayOf(
                    cliAction("Run Entry", AllIcons.Actions.Execute, project, dir, LudicCommand.RUN),
                    cliAction("Build Entry", AllIcons.Actions.Compile, project, dir, LudicCommand.BUILD),
                )
            ) { "Run the entry program" }
            manifest && word == "script" -> {
                val name = line.words.getOrNull(1) ?: return null
                Info(
                    AllIcons.RunConfigurations.TestState.Run,
                    arrayOf(cliAction("Run Script '$name'", AllIcons.Actions.Execute, project, dir, LudicCommand.CUSTOM, "script $name"))
                ) { "ludic script $name" }
            }
            word == "require" || word == "module" -> {
                val module = line.words.getOrNull(1) ?: return null
                Info(
                    AllIcons.Actions.Refresh,
                    arrayOf(
                        cliAction("Update $module", AllIcons.Actions.Refresh, project, dir, LudicCommand.CUSTOM, "update $module"),
                        cliAction("Fetch Dependencies", AllIcons.Actions.Download, project, dir, LudicCommand.CUSTOM, "get"),
                        cliAction("Verify Locked Packages", AllIcons.Actions.Checked, project, dir, LudicCommand.CUSTOM, "verify"),
                    )
                ) { "Update $module" }
            }
            else -> null
        }
    }
}

/** package.ludic and its lock get the package icon in the Project view and on their tabs. */
class LudicManifestIconProvider : IconProvider(), DumbAware {
    override fun getIcon(element: PsiElement, flags: Int): Icon? =
        if (element is PsiFile && (LudicManifest.isManifest(element) || LudicManifest.isLock(element))) LudicPackageIcons.MANIFEST else null
}

/** A manifest path value, resolved against the package root. */
internal fun resolveManifestPath(file: PsiFile, value: String): File? {
    val dir = file.virtualFile?.parent?.path ?: return null
    if (value.isBlank()) return null
    return File(value).let { if (it.isAbsolute) it else File(dir, value) }
}
