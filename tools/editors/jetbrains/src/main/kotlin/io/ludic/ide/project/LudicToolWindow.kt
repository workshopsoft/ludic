package io.ludic.ide.project

import com.intellij.icons.AllIcons
import com.intellij.openapi.Disposable
import com.intellij.openapi.actionSystem.ActionManager
import com.intellij.openapi.actionSystem.ActionUpdateThread
import com.intellij.openapi.actionSystem.AnAction
import com.intellij.openapi.actionSystem.AnActionEvent
import com.intellij.openapi.actionSystem.DefaultActionGroup
import com.intellij.openapi.actionSystem.Separator
import com.intellij.openapi.application.ApplicationManager
import com.intellij.openapi.application.ReadAction
import com.intellij.openapi.command.WriteCommandAction
import com.intellij.openapi.editor.EditorFactory
import com.intellij.openapi.editor.event.DocumentEvent
import com.intellij.openapi.editor.event.DocumentListener
import com.intellij.openapi.fileEditor.FileDocumentManager
import com.intellij.openapi.fileEditor.OpenFileDescriptor
import com.intellij.openapi.project.DumbAware
import com.intellij.openapi.project.Project
import com.intellij.openapi.ui.Messages
import com.intellij.openapi.ui.SimpleToolWindowPanel
import com.intellij.openapi.util.Disposer
import com.intellij.openapi.vfs.LocalFileSystem
import com.intellij.openapi.vfs.VirtualFileManager
import com.intellij.openapi.vfs.newvfs.BulkFileListener
import com.intellij.openapi.vfs.newvfs.events.VFileEvent
import com.intellij.openapi.wm.ToolWindow
import com.intellij.openapi.wm.ToolWindowFactory
import com.intellij.openapi.wm.ToolWindowManager
import com.intellij.ui.ColoredTreeCellRenderer
import com.intellij.ui.DoubleClickListener
import com.intellij.ui.JBSplitter
import com.intellij.ui.PopupHandler
import com.intellij.ui.ScrollPaneFactory
import com.intellij.ui.SimpleTextAttributes
import com.intellij.ui.TreeSpeedSearch
import com.intellij.ui.content.ContentFactory
import com.intellij.ui.treeStructure.Tree
import com.intellij.util.Alarm
import com.intellij.util.ui.HTMLEditorKitBuilder
import com.intellij.util.ui.JBUI
import com.intellij.util.ui.tree.TreeUtil
import io.ludic.ide.LudicToolchain
import io.ludic.ide.run.LudicCommand
import java.awt.event.KeyAdapter
import java.awt.event.KeyEvent
import java.awt.event.MouseEvent
import java.io.File
import javax.swing.Icon
import javax.swing.JEditorPane
import javax.swing.JTree
import javax.swing.tree.DefaultMutableTreeNode
import javax.swing.tree.DefaultTreeModel
import javax.swing.tree.TreePath

/**
 * View | Tool Windows | Ludic: the package the way the Gradle window shows a
 * build — what it is, the commands and scripts it runs, the hooks around them,
 * its dependencies against the lock, and its app — with a details pane below.
 */
class LudicToolWindowFactory : ToolWindowFactory, DumbAware {
    override fun shouldBeAvailable(project: Project): Boolean {
        val base = project.basePath ?: return false
        return LudicPackageInfo.discover(File(base)).isNotEmpty()
    }

    override fun createToolWindowContent(project: Project, toolWindow: ToolWindow) {
        val panel = LudicToolWindowPanel(project)
        val content = ContentFactory.getInstance().createContent(panel, "", false)
        Disposer.register(content, panel)
        toolWindow.contentManager.addContent(content)
    }

    companion object {
        const val ID = "Ludic"

        fun show(project: Project) {
            ToolWindowManager.getInstance(project).getToolWindow(ID)?.let { tw ->
                tw.isAvailable = true
                tw.activate(null)
            }
        }
    }
}

/** A row of the tree. [key] survives a refresh so expansion and selection do too. */
internal class LudicTreeItem(
    val key: String,
    val title: String,
    val hint: String?,
    val icon: Icon?,
    val pkg: LudicPackageInfo?,
    val payload: Any? = null,
    val line: Int? = null,
    val warn: Boolean = false,
) {
    override fun toString() = title
}

internal enum class Group { OVERVIEW, APP, COMMANDS, SCRIPTS, HOOKS, DEPENDENCIES, LOCK, ASSETS }

class LudicToolWindowPanel(private val project: Project) : SimpleToolWindowPanel(true, true), Disposable {
    private val root = DefaultMutableTreeNode()
    private val model = DefaultTreeModel(root)
    private val tree = Tree(model)
    private val details = JEditorPane().apply {
        editorKit = HTMLEditorKitBuilder().build()
        isEditable = false
        border = JBUI.Borders.empty(8)
    }
    private val alarm = Alarm(Alarm.ThreadToUse.SWING_THREAD, this)
    private var packages: List<LudicPackageInfo> = emptyList()
    private var firstBuild = true

    private fun isPackagePath(path: String): Boolean {
        val n = path.substringAfterLast('/')
        return n == LudicManifest.FILE_NAME || n == LudicManifest.LOCK_NAME || n == "ludic_modules" || n == "vendor"
    }

    private fun scheduleRefresh() {
        alarm.cancelAllRequests()
        alarm.addRequest({ refresh() }, 300)
    }

    fun refresh() {
        val base = project.basePath ?: return
        ApplicationManager.getApplication().executeOnPooledThread {
            val found = ReadAction.compute<List<LudicPackageInfo>, RuntimeException> { LudicPackageInfo.discover(File(base)) }
            ApplicationManager.getApplication().invokeLater({ rebuild(found) }, project.disposed)
        }
    }

    // ---- the tree ------------------------------------------------------------

    private fun rebuild(found: List<LudicPackageInfo>) {
        val expanded = mutableSetOf<String>()
        TreeUtil.collectExpandedPaths(tree).forEach { p -> item(p)?.let { expanded += it.key } }
        val selected = tree.selectionPath?.let(::item)?.key
        packages = found
        root.removeAllChildren()
        for (p in found) root.add(packageNode(p))
        model.reload()
        if (firstBuild) {
            // packages and their groups open; the long lists stay folded
            TreeUtil.treeNodeTraverser(root).forEach { n ->
                val it = (n as? DefaultMutableTreeNode)?.userObject as? LudicTreeItem ?: return@forEach
                if (it.payload is LudicPackageInfo || it.payload == Group.COMMANDS || it.payload == Group.SCRIPTS) expanded += it.key
            }
            firstBuild = false
        }
        TreeUtil.treeNodeTraverser(root).forEach { n ->
            val node = n as? DefaultMutableTreeNode ?: return@forEach
            val it = node.userObject as? LudicTreeItem ?: return@forEach
            val path = TreePath(node.path)
            if (it.key in expanded) tree.expandPath(path)
            if (it.key == selected) tree.selectionPath = path
        }
        if (tree.selectionPath == null && root.childCount > 0) {
            tree.selectionPath = TreePath((root.getChildAt(0) as DefaultMutableTreeNode).path)
        }
        showDetails()
    }

    private fun packageNode(p: LudicPackageInfo): DefaultMutableTreeNode {
        val m = p.manifest
        val k = p.dir.path
        val node = leaf(LudicTreeItem(k, p.name, listOfNotNull(m.version, m.kind ?: "source").joinToString(" · "),
            LudicPackageIcons.MANIFEST, p, p, 0, warn = p.staleReason != null))
        node.add(leaf(LudicTreeItem("$k/overview", "Overview", m.module, AllIcons.General.Information, p, Group.OVERVIEW, 0)))
        if (m.app.isNotEmpty()) {
            node.add(leaf(LudicTreeItem("$k/app", "App", LudicAppPreview.appName(m, p.dir), AllIcons.Nodes.Artifact, p, Group.APP,
                m.app.keys.firstOrNull()?.let { key -> lineOf(p, "app", key) })))
        }
        val cmds = group("$k/commands", "Commands", null, AllIcons.Nodes.ConfigFolder, p, Group.COMMANDS)
        LudicPackageInfo.COMMANDS.forEach { c ->
            val hooks = p.hooksOf(c.verb).joinToString(", ") { "${it.phase}: ${it.command}" }
            cmds.add(leaf(LudicTreeItem("$k/cmd/${c.verb}", c.title, "ludic ${c.verb}" + if (hooks.isNotEmpty()) "  ⟲ $hooks" else "",
                commandIcon(c.verb), p, c)))
        }
        node.add(cmds)
        if (m.scripts.isNotEmpty()) {
            val g = group("$k/scripts", "Scripts", m.scripts.size.toString(), AllIcons.Nodes.ConfigFolder, p, Group.SCRIPTS)
            m.scripts.forEach { s -> g.add(leaf(LudicTreeItem("$k/script/${s.name}", s.name, s.command, AllIcons.Actions.Execute, p, s, s.line))) }
            node.add(g)
        }
        if (m.hooks.isNotEmpty()) {
            val g = group("$k/hooks", "Hooks", m.hooks.size.toString(), AllIcons.Nodes.ConfigFolder, p, Group.HOOKS)
            m.hooks.forEach { h ->
                g.add(leaf(LudicTreeItem("$k/hook/${h.line}", "${h.phase} ${h.event}", h.command, AllIcons.Nodes.Tag, p, h, h.line)))
            }
            node.add(g)
        }
        val deps = group("$k/deps", "Dependencies", depHint(p), AllIcons.Nodes.PpLibFolder, p, Group.DEPENDENCIES, warn = p.staleReason != null)
        m.requires.forEach { r ->
            val st = p.status(r)
            val locked = p.lockedOf(r.module)?.version
            val hint = ">= ${r.version}" + (locked?.let { " · locked $it" } ?: "") + if (st != LudicPackageInfo.DepStatus.OK) " · ${st.label}" else ""
            deps.add(leaf(LudicTreeItem("$k/dep/${r.module}", r.module, hint, AllIcons.Nodes.PpLib, p, r, r.line, warn = st != LudicPackageInfo.DepStatus.OK)))
        }
        p.transitive.forEach { l ->
            deps.add(leaf(LudicTreeItem("$k/dep/${l.module}", l.module, "${l.version} · indirect", AllIcons.Nodes.PpLibFolder, p, l)))
        }
        val lockHint = when {
            p.locked == null -> if (m.requires.isEmpty()) "not needed" else "missing"
            p.staleReason != null -> "out of date"
            else -> "${p.locked.size} pinned"
        }
        deps.add(leaf(LudicTreeItem("$k/lock", LudicManifest.LOCK_NAME, lockHint, LudicPackageIcons.MANIFEST, p, Group.LOCK, warn = p.staleReason != null)))
        node.add(deps)
        if (m.packs.isNotEmpty()) {
            val g = group("$k/assets", "Asset Roots", m.packs.size.toString(), AllIcons.Nodes.Folder, p, Group.ASSETS)
            m.packs.forEach { v ->
                val ok = File(v).let { if (it.isAbsolute) it else File(p.dir, v) }.exists()
                g.add(leaf(LudicTreeItem("$k/pack/$v", v, if (ok) null else "missing", AllIcons.Nodes.Folder, p, v, lineOf(p, "pack", v), warn = !ok)))
            }
            node.add(g)
        }
        return node
    }

    private fun depHint(p: LudicPackageInfo): String {
        val n = p.manifest.requires.size
        return p.staleReason?.let { "fetch needed" } ?: if (n == 0) "none" else n.toString()
    }

    private fun commandIcon(verb: String): Icon = when (verb) {
        "run" -> AllIcons.Actions.Execute
        "build" -> AllIcons.Actions.Compile
        "test" -> AllIcons.RunConfigurations.TestState.Run_run
        "bundle", "pack" -> AllIcons.Nodes.Artifact
        "clean" -> AllIcons.Actions.GC
        else -> AllIcons.Nodes.Console
    }

    /** The line of the first `<directive> <word>` in the package's manifest. */
    private fun lineOf(p: LudicPackageInfo, directive: String, word: String): Int? {
        val text = runCatching { p.manifestFile.readText() }.getOrNull() ?: return null
        return text.lines().indexOfFirst { l -> LudicManifest.words(l).let { it.getOrNull(0) == directive && it.getOrNull(1) == word } }
            .takeIf { it >= 0 }
    }

    private fun leaf(item: LudicTreeItem) = DefaultMutableTreeNode(item)

    private fun group(key: String, title: String, hint: String?, icon: Icon, p: LudicPackageInfo, g: Group, warn: Boolean = false) =
        DefaultMutableTreeNode(LudicTreeItem(key, title, hint, icon, p, g, warn = warn))

    private fun item(path: TreePath?): LudicTreeItem? =
        (path?.lastPathComponent as? DefaultMutableTreeNode)?.userObject as? LudicTreeItem

    private fun selected(): LudicTreeItem? = item(tree.selectionPath)

    private fun currentPackage(): LudicPackageInfo? = selected()?.pkg ?: packages.firstOrNull()

    // ---- the details pane ------------------------------------------------------

    private fun showDetails() {
        val it = selected()
        val p = it?.pkg
        val html = when (val x = it?.payload) {
            null -> if (packages.isEmpty()) "<p>No package.ludic in this project. Create one with <code>ludic new</code>.</p>" else ""
            is LudicPackageInfo -> LudicPackageHtml.overview(x)
            Group.OVERVIEW -> LudicPackageHtml.overview(p!!)
            Group.APP -> LudicAppPreview.html(p!!.manifest, p.dir)
            Group.LOCK, Group.DEPENDENCIES -> LudicPackageHtml.lock(p!!)
            Group.ASSETS -> LudicPackageHtml.assets(p!!)
            Group.COMMANDS -> "<p>Double-click a command to run it; its output goes to the Run tool window.</p>"
            Group.SCRIPTS -> "<p>The package's own commands, from its <code>script</code> lines. Double-click one to run it.</p>"
            Group.HOOKS -> "<p>Commands package.ludic runs before or after another command.</p>"
            is LudicPackageInfo.Command -> LudicPackageHtml.command(p!!, x)
            is LudicManifest.Script -> LudicPackageHtml.script(p!!, x)
            is LudicManifest.Hook -> LudicPackageHtml.hook(x)
            is LudicManifest.Require -> LudicPackageHtml.dependency(p!!, x)
            is LudicManifest.Locked -> LudicPackageHtml.locked(p!!, x)
            is String -> LudicPackageHtml.assets(p!!)
            else -> ""
        }
        details.text = "<html><body>$html</body></html>"
        details.caretPosition = 0
    }

    // ---- acting on a row ---------------------------------------------------------

    /** What Enter or a double-click does: run a command or script, or open the line. */
    private fun activate(): Boolean {
        val it = selected() ?: return false
        return when (it.payload) {
            is LudicPackageInfo.Command, is LudicManifest.Script -> { runSelected(); true }
            Group.LOCK -> { open(it.pkg!!.lockFile, 0); true }
            is LudicManifest.Locked -> { open(it.pkg!!.lockFile, 0); true }
            else -> if (it.line != null) { open(it.pkg!!.manifestFile, it.line); true } else false
        }
    }

    private fun runnable(it: LudicTreeItem?): Pair<LudicCommand, String>? = when (val x = it?.payload) {
        is LudicPackageInfo.Command -> when (x.verb) {
            "run" -> LudicCommand.RUN to ""
            "build" -> LudicCommand.BUILD to ""
            "test" -> LudicCommand.TEST to ""
            else -> LudicCommand.CUSTOM to x.verb
        }
        is LudicManifest.Script -> LudicCommand.CUSTOM to "script ${x.name}"
        is LudicManifest.Hook -> LudicCommand.CUSTOM to (if (x.event in LudicManifest.HOOK_EVENTS) x.event else "script ${x.event}")
        is LudicPackageInfo, Group.OVERVIEW -> LudicCommand.RUN to ""
        Group.APP -> LudicCommand.CUSTOM to "bundle"
        else -> null
    }

    private fun runSelected() {
        val p = currentPackage() ?: return
        val (cmd, args) = runnable(selected()) ?: return
        run(p, cmd, args)
    }

    private fun run(p: LudicPackageInfo, cmd: LudicCommand, args: String) = runLudic(project, cmd, args, p.dir.path)

    private fun open(f: File, line: Int) {
        val vf = LocalFileSystem.getInstance().refreshAndFindFileByIoFile(f) ?: return
        OpenFileDescriptor(project, vf, line, 0).navigate(true)
    }

    private fun addDependency() {
        val p = currentPackage() ?: return
        val spec = Messages.showInputDialog(project,
            "Module path, optionally with a version:\ngit.example.com/me/util  or  git.example.com/me/util@1.2.0",
            "Add Ludic Dependency", AllIcons.General.Add)?.trim().orEmpty()
        if (spec.isEmpty() || spec.any { it.isWhitespace() || it == '"' || it == '\'' }) return
        run(p, LudicCommand.CUSTOM, "add $spec")
    }

    private fun removeDependency(p: LudicPackageInfo, r: LudicManifest.Require) {
        val ok = Messages.showYesNoDialog(project, "Remove ${r.module} from package.ludic and fetch again?", "Remove Dependency", null)
        if (ok != Messages.YES) return
        val vf = LocalFileSystem.getInstance().refreshAndFindFileByIoFile(p.manifestFile) ?: return
        val doc = FileDocumentManager.getInstance().getDocument(vf) ?: return
        if (r.line >= doc.lineCount || LudicManifest.words(doc.getText(com.intellij.openapi.util.TextRange(doc.getLineStartOffset(r.line), doc.getLineEndOffset(r.line)))).getOrNull(1) != r.module) return
        WriteCommandAction.runWriteCommandAction(project, "Remove Dependency", null, {
            val end = if (r.line + 1 < doc.lineCount) doc.getLineStartOffset(r.line + 1) else doc.getLineEndOffset(r.line)
            doc.deleteString(doc.getLineStartOffset(r.line), end)
        })
        run(p, LudicCommand.CUSTOM, "get")
    }

    // ---- actions -----------------------------------------------------------------

    private inner class Act(text: String, icon: Icon?, private val enabled: () -> Boolean = { currentPackage() != null }, private val body: () -> Unit) :
        AnAction(text, null, icon), DumbAware {
        override fun getActionUpdateThread() = ActionUpdateThread.EDT
        override fun update(e: AnActionEvent) {
            val cli = LudicToolchain.cli(project) != null
            e.presentation.isEnabled = enabled() && (cli || templatePresentation.text == "Refresh" || templatePresentation.text.startsWith("Open"))
        }
        override fun actionPerformed(e: AnActionEvent) = body()
    }

    private fun pkgCmd(text: String, icon: Icon, verb: String) = Act(text, icon) { currentPackage()?.let { run(it, LudicCommand.CUSTOM, verb) } }

    private val runAct by lazy {
        Act("Run", AllIcons.Actions.Execute, { runnable(selected()) != null }) { runSelected() }
    }
    private val refreshAct by lazy {
        Act("Refresh", AllIcons.Actions.Refresh, { true }) { refresh() }
    }
    private val fetchAct by lazy {
        pkgCmd("Fetch Dependencies (ludic get)", AllIcons.Actions.Download, "get")
    }
    private val updateAllAct by lazy {
        pkgCmd("Update All Dependencies (ludic update)", AllIcons.Actions.CheckOut, "update")
    }
    private val verifyAct by lazy {
        pkgCmd("Verify Locked Packages (ludic verify)", AllIcons.Actions.Checked, "verify")
    }
    private val vendorAct by lazy {
        pkgCmd("Vendor Dependencies (ludic vendor)", AllIcons.Nodes.PpLibFolder, "vendor")
    }
    private val addAct by lazy {
        Act("Add Dependency…", AllIcons.General.Add) { addDependency() }
    }
    private val openManifestAct by lazy {
        Act("Open package.ludic", AllIcons.Actions.EditSource) {
        val it = selected()
        currentPackage()?.let { p -> open(p.manifestFile, it?.line ?: 0) }
    }
    }
    private val updateOneAct by lazy {
        Act("Update This Dependency", AllIcons.Actions.CheckOut, { selected()?.payload is LudicManifest.Require }) {
        val it = selected()
        (it?.payload as? LudicManifest.Require)?.let { r -> run(it.pkg!!, LudicCommand.CUSTOM, "update ${r.module}") }
    }
    }
    private val removeAct by lazy {
        Act("Remove Dependency…", AllIcons.General.Remove, { selected()?.payload is LudicManifest.Require }) {
        val it = selected()
        (it?.payload as? LudicManifest.Require)?.let { r -> removeDependency(it.pkg!!, r) }
    }
    }
    private val openLockAct by lazy {
        Act("Open package.lock.ludic", AllIcons.Actions.EditSource, { currentPackage()?.lockFile?.isFile == true }) {
        currentPackage()?.let { open(it.lockFile, 0) }
    }
    }
    private fun toolbarGroup() = DefaultActionGroup().apply {
        add(refreshAct); add(runAct); add(Separator.getInstance())
        add(fetchAct); add(updateAllAct); add(verifyAct); add(addAct); add(Separator.getInstance())
        add(openManifestAct)
    }

    private fun popupGroup() = DefaultActionGroup().apply {
        add(runAct); add(openManifestAct); add(Separator.getInstance())
        add(updateOneAct); add(removeAct); add(addAct); add(Separator.getInstance())
        add(fetchAct); add(updateAllAct); add(verifyAct); add(vendorAct); add(openLockAct)
    }

    // last, so every action above exists before the toolbar and menu are built
    init {
        tree.isRootVisible = false
        tree.showsRootHandles = true
        tree.cellRenderer = Renderer()
        TreeSpeedSearch.installOn(tree)
        tree.addTreeSelectionListener { showDetails() }
        object : DoubleClickListener() {
            override fun onDoubleClick(event: MouseEvent): Boolean = activate()
        }.installOn(tree)
        tree.addKeyListener(object : KeyAdapter() {
            override fun keyPressed(e: KeyEvent) { if (e.keyCode == KeyEvent.VK_ENTER && activate()) e.consume() }
        })
        PopupHandler.installPopupMenu(tree, popupGroup(), "LudicToolWindowPopup")

        val splitter = JBSplitter(true, "ludic.toolwindow.split", 0.6f)
        splitter.firstComponent = ScrollPaneFactory.createScrollPane(tree, true)
        splitter.secondComponent = ScrollPaneFactory.createScrollPane(details, true)
        setContent(splitter)

        val bar = ActionManager.getInstance().createActionToolbar("LudicToolWindow", toolbarGroup(), true)
        bar.targetComponent = this
        toolbar = bar.component

        project.messageBus.connect(this).subscribe(VirtualFileManager.VFS_CHANGES, object : BulkFileListener {
            override fun after(events: List<VFileEvent>) {
                if (events.any { isPackagePath(it.path) }) scheduleRefresh()
            }
        })
        EditorFactory.getInstance().eventMulticaster.addDocumentListener(object : DocumentListener {
            override fun documentChanged(event: DocumentEvent) {
                val f = FileDocumentManager.getInstance().getFile(event.document) ?: return
                if (LudicManifest.isManifest(f) || LudicManifest.isLock(f)) scheduleRefresh()
            }
        }, this)
        refresh()
    }

    override fun dispose() {}

    private class Renderer : ColoredTreeCellRenderer() {
        override fun customizeCellRenderer(tree: JTree, value: Any?, selected: Boolean, expanded: Boolean, leaf: Boolean, row: Int, hasFocus: Boolean) {
            val it = (value as? DefaultMutableTreeNode)?.userObject as? LudicTreeItem ?: return
            icon = if (it.warn && it.payload !is LudicPackageInfo) AllIcons.General.Warning else it.icon
            val attrs = when {
                it.payload is LudicPackageInfo -> SimpleTextAttributes.REGULAR_BOLD_ATTRIBUTES
                it.warn -> SimpleTextAttributes.ERROR_ATTRIBUTES
                else -> SimpleTextAttributes.REGULAR_ATTRIBUTES
            }
            append(it.title, attrs)
            it.hint?.let { h -> append("  $h", SimpleTextAttributes.GRAYED_ATTRIBUTES) }
            toolTipText = it.hint
        }
    }
}
