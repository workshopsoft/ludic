package io.ludic.ide.project

import com.intellij.codeInsight.completion.CompletionContributor
import com.intellij.codeInsight.completion.CompletionParameters
import com.intellij.codeInsight.completion.CompletionProvider
import com.intellij.codeInsight.completion.CompletionResultSet
import com.intellij.codeInsight.completion.CompletionType
import com.intellij.codeInsight.lookup.LookupElementBuilder
import com.intellij.codeInsight.navigation.actions.GotoDeclarationHandler
import com.intellij.icons.AllIcons
import com.intellij.lang.annotation.AnnotationHolder
import com.intellij.lang.annotation.Annotator
import com.intellij.lang.annotation.HighlightSeverity
import com.intellij.lang.documentation.AbstractDocumentationProvider
import com.intellij.openapi.editor.Editor
import com.intellij.openapi.util.TextRange
import com.intellij.openapi.util.text.StringUtil
import com.intellij.openapi.vfs.LocalFileSystem
import com.intellij.openapi.vfs.VirtualFile
import com.intellij.patterns.PlatformPatterns
import com.intellij.psi.PsiElement
import com.intellij.psi.PsiFile
import com.intellij.psi.PsiManager
import com.intellij.psi.util.elementType
import com.intellij.util.ProcessingContext
import io.ludic.ide.LudicLanguage
import io.ludic.ide.LudicTokens
import java.io.File

private fun isPackageFile(file: PsiFile?) = LudicManifest.isManifest(file) || LudicManifest.isLock(file)

private fun unquote(s: String) = s.removePrefix("\"").removeSuffix("\"")

/**
 * What a string on a manifest line points at: a file or directory for path
 * values (`entry`, `pack`, `app icon|splash|native|out`), a package directory
 * for `require` / lock `module` lines. Null for anything else.
 */
internal fun manifestTarget(element: PsiElement): VirtualFile? = manifestTargetSpec(element)?.let { spec ->
    when (spec) {
        is TargetSpec.Path -> spec.relative?.let { rel -> spec.base?.findFileByRelativePath(rel) }
            ?: spec.absolute?.let { LocalFileSystem.getInstance().findFileByIoFile(it) }
        is TargetSpec.Package -> spec.dir?.let { LocalFileSystem.getInstance().findFileByIoFile(it) }
    }
}

internal sealed class TargetSpec {
    class Path(val base: VirtualFile?, val relative: String?, val absolute: File?) : TargetSpec()
    class Package(val dir: File?) : TargetSpec()
}

private fun manifestTargetSpec(element: PsiElement): TargetSpec? {
    if (element.elementType != LudicTokens.STRING) return null
    val file = element.containingFile ?: return null
    if (!isPackageFile(file)) return null
    val line = ManifestLine.at(element) ?: return null
    val value = unquote(element.text)
    val words = line.words
    val isPath = when (line.directive) {
        in LudicManifest.PATH_DIRECTIVES -> true
        "app" -> words.getOrNull(1) in LudicManifest.PATH_APP_KEYS && words.getOrNull(2) == value
        else -> false
    }
    if (isPath && value.isNotBlank()) {
        return if (File(value).isAbsolute) TargetSpec.Path(null, null, File(value))
        else TargetSpec.Path(file.originalFile.virtualFile?.parent, value, null)
    }
    if ((line.directive == "require" || line.directive == "module") && words.getOrNull(1) == value) {
        return TargetSpec.Package(packageDir(file, value))
    }
    return null
}

/** Where a required package is on disk: ludic_modules/, vendor/, or the toolchain. */
internal fun packageDir(file: PsiFile, module: String): File? {
    val dir = file.virtualFile?.parent?.path ?: return null
    val modules = System.getenv("LUDIC_MODULES") ?: "ludic_modules"
    return listOfNotNull(
        File(File(dir, modules), module),
        File(File(dir, "vendor"), module),
        io.ludic.ide.LudicToolchain.home(file.project)?.let { File(File(it, "packages"), module) },
    ).firstOrNull { it.exists() }
}

/** Cmd/Ctrl-click on a manifest path or package opens it. */
class LudicManifestGotoHandler : GotoDeclarationHandler {
    override fun getGotoDeclarationTargets(sourceElement: PsiElement?, offset: Int, editor: Editor?): Array<PsiElement>? {
        val el = sourceElement ?: return null
        val vf = manifestTarget(el) ?: return null
        val psi = PsiManager.getInstance(el.project)
        var node = vf
        // a package directory opens on its manifest, where its story starts
        if (vf.isDirectory) vf.findChild(LudicManifest.FILE_NAME)?.let { node = it }
        val found: PsiElement? = if (node.isDirectory) psi.findDirectory(node) else psi.findFile(node)
        return found?.let { arrayOf(it) }
    }
}

private val WORD = Regex("[A-Za-z_][A-Za-z0-9_]*")
private val WORD_OR_DASH = Regex("[A-Za-z_][A-Za-z0-9_-]*")

/** Mistakes the CLI would otherwise report late, or silently ignore. */
class LudicManifestAnnotator : Annotator {
    override fun annotate(element: PsiElement, holder: AnnotationHolder) {
        val file = element.containingFile ?: return
        if (!isPackageFile(file) || element.firstChild != null) return
        val lock = LudicManifest.isLock(file)
        val line = ManifestLine.at(element) ?: return
        when {
            element.elementType == LudicTokens.STRING -> checkString(element, line, file, lock, holder)
            line.startsWith(element) && WORD.matches(element.text) -> {
                val known = if (lock) LudicManifest.LOCK_WORDS.keys else LudicManifest.DIRECTIVES.keys
                if (element.text !in known) {
                    holder.newAnnotation(HighlightSeverity.WARNING, "Unknown directive '${element.text}': ludic ignores this line")
                        .range(element).create()
                }
            }
            !lock && line.directive == "hook" && !line.startsWith(element) && WORD_OR_DASH.matches(element.text) -> {
                val w = line.words
                if (w.getOrNull(1) == element.text && element.text !in LudicManifest.HOOK_PHASES) {
                    holder.newAnnotation(HighlightSeverity.ERROR, "A hook runs before or after").range(element).create()
                } else if (w.getOrNull(2) == element.text && element.text !in LudicManifest.HOOK_EVENTS &&
                    LudicManifest.parse(file.text).scripts.none { it.name == element.text }) {
                    holder.newAnnotation(HighlightSeverity.ERROR, "No command or script named '${element.text}': hooks wrap ${LudicManifest.HOOK_EVENTS.keys.joinToString()} or a script")
                        .range(element).create()
                }
            }
            !lock && line.directive == "kind" && line.words.getOrNull(1) == element.text && !line.startsWith(element) -> {
                if (element.text !in LudicManifest.KINDS) {
                    holder.newAnnotation(HighlightSeverity.ERROR, "kind must be one of: ${LudicManifest.KINDS.keys.joinToString()}")
                        .range(element).create()
                }
            }
        }
    }

    private fun checkString(element: PsiElement, line: ManifestLine, file: PsiFile, lock: Boolean, holder: AnnotationHolder) {
        val value = unquote(element.text)
        val words = line.words
        if (!lock && line.directive == "version" && words.getOrNull(1) == value && !LudicManifest.isSemver(value)) {
            holder.newAnnotation(HighlightSeverity.WARNING, "Not a semantic version (MAJOR.MINOR.PATCH): a git tag v$value will not resolve")
                .range(element).create()
            return
        }
        if (!lock && line.directive == "require" && words.getOrNull(2) == value && !LudicManifest.isSemver(value)) {
            holder.newAnnotation(HighlightSeverity.WARNING, "A minimum version is MAJOR.MINOR.PATCH")
                .range(element).create()
            return
        }
        if (!lock && line.directive == "script" && words.getOrNull(1) == value && value in LudicManifest.BUILTIN_COMMANDS) {
            holder.newAnnotation(HighlightSeverity.WARNING, "'ludic $value' is a built-in command: run this script with `ludic script $value`")
                .range(element).create()
            return
        }
        if (!lock && line.directive == "app" && words.getOrNull(1) == "splash_bg" && words.getOrNull(2) == value &&
            !Regex("#[0-9a-fA-F]{6}").matches(value)) {
            holder.newAnnotation(HighlightSeverity.WARNING, "splash_bg is a colour: \"#rrggbb\"").range(element).create()
            return
        }
        val spec = manifestTargetSpec(element) ?: return
        if (spec is TargetSpec.Package) {
            if (spec.dir == null) {
                holder.newAnnotation(HighlightSeverity.WEAK_WARNING, "$value is not fetched yet: run `ludic get`")
                    .range(element).create()
            }
            return
        }
        if (manifestTarget(element) == null) {
            // `out` names something bundle creates
            if (line.directive == "app" && words.getOrNull(1) == "out") return
            holder.newAnnotation(HighlightSeverity.ERROR, "No such file or directory: $value")
                .range(TextRange(element.textRange.startOffset + 1, element.textRange.endOffset - 1)).create()
        }
    }
}

/** Completion in package.ludic: directives at the start of a line, then their values. */
class LudicManifestCompletion : CompletionContributor() {
    init {
        extend(CompletionType.BASIC, PlatformPatterns.psiElement().withLanguage(LudicLanguage), object : CompletionProvider<CompletionParameters>() {
            override fun addCompletions(parameters: CompletionParameters, context: ProcessingContext, result: CompletionResultSet) {
                val file = parameters.originalFile
                if (!LudicManifest.isManifest(file)) {
                    if (LudicManifest.isLock(file)) result.stopHere()
                    return
                }
                val doc = parameters.editor.document
                val offset = parameters.offset
                val line = doc.getLineNumber(offset)
                val before = doc.getText(TextRange(doc.getLineStartOffset(line), offset))
                if (before.contains('#')) return
                val words = LudicManifest.words(before)
                val typing = before.isNotEmpty() && !before.last().isWhitespace()
                val inString = before.count { it == '"' } % 2 == 1
                val done = if (typing && !inString) words.dropLast(1) else if (inString) words.dropLast(1) else words
                val dir = file.virtualFile?.parent?.path?.let(::File)
                when {
                    done.isEmpty() -> for ((d, help) in LudicManifest.DIRECTIVES) {
                        result.addElement(LookupElementBuilder.create("$d ").withPresentableText(d).bold().withTypeText(help, true).withIcon(LudicPackageIcons.MANIFEST))
                    }
                    done == listOf("app") -> for ((k, help) in LudicManifest.APP_KEYS) {
                        result.addElement(LookupElementBuilder.create("$k ").withPresentableText(k).withTypeText(help, true))
                    }
                    done == listOf("kind") -> for ((k, help) in LudicManifest.KINDS) {
                        result.addElement(LookupElementBuilder.create(k).withTypeText(help, true))
                    }
                    dir != null && done == listOf("entry") ->
                        paths(dir, inString) { it.isFile && it.extension == "ludic" && isProgram(it) }.forEach(result::addElement)
                    dir != null && done.firstOrNull() == "pack" ->
                        paths(dir, inString) { it.isDirectory }.forEach(result::addElement)
                    dir != null && done.size == 2 && done[0] == "app" && done[1] in setOf("icon", "splash") ->
                        paths(dir, inString) { it.isFile && it.extension.lowercase() in setOf("png", "jpg", "jpeg") }.forEach(result::addElement)
                    dir != null && done.size == 2 && done[0] == "app" && done[1] == "native" ->
                        paths(dir, inString) { it.isDirectory }.forEach(result::addElement)
                    done == listOf("hook") -> for ((p, help) in LudicManifest.HOOK_PHASES) {
                        result.addElement(LookupElementBuilder.create("$p ").withPresentableText(p).withTypeText(help, true))
                    }
                    done.size == 2 && done[0] == "hook" -> {
                        for ((ev, cmd) in LudicManifest.HOOK_EVENTS) {
                            result.addElement(LookupElementBuilder.create("$ev ").withPresentableText(ev).withTypeText(cmd, true))
                        }
                        for (s in LudicManifest.parse(doc.charsSequence).scripts) {
                            result.addElement(LookupElementBuilder.create("${s.name} ").withPresentableText(s.name).withTypeText("script: ${s.command}", true).withIcon(AllIcons.Nodes.Console))
                        }
                    }
                    done.size == 2 && done[0] == "app" && done[1] == "category" -> CATEGORIES.forEach {
                        result.addElement(LookupElementBuilder.create(if (inString) it else "\"$it\""))
                    }
                }
                result.stopHere()
            }
        })
    }

    private fun isProgram(f: File) = runCatching { f.useLines { l -> l.any { it.startsWith("program ") } } }.getOrDefault(false)

    private fun paths(root: File, inString: Boolean, keep: (File) -> Boolean) =
        root.walkTopDown()
            .onEnter { d -> d == root || !(d.name.startsWith(".") || d.name == "build" || d.name == "ludic_modules" || d.name == "node_modules") }
            .maxDepth(4)
            .filter { it != root && keep(it) }
            .take(200)
            .map { f ->
                val rel = f.relativeTo(root).path
                LookupElementBuilder.create(if (inString) rel else "\"$rel\"")
                    .withPresentableText(rel)
                    .withIcon(if (f.isDirectory) AllIcons.Nodes.Folder else AllIcons.FileTypes.Any_type)
            }
            .toList()

    private companion object {
        val CATEGORIES = listOf(
            "public.app-category.games", "public.app-category.action-games", "public.app-category.adventure-games",
            "public.app-category.arcade-games", "public.app-category.puzzle-games", "public.app-category.role-playing-games",
            "public.app-category.simulation-games", "public.app-category.strategy-games", "public.app-category.sports-games",
        )
    }
}

/**
 * Quick documentation (F1 / hover) in package.ludic and its lock: what each
 * directive and value means, and for any `app` line a preview of the app all
 * the `app` lines describe together.
 */
class LudicManifestDocumentation : AbstractDocumentationProvider() {
    override fun generateDoc(element: PsiElement?, originalElement: PsiElement?): String? {
        val el = originalElement ?: element ?: return null
        val file = el.containingFile ?: return null
        if (!isPackageFile(file)) return null
        val line = ManifestLine.at(el) ?: return null
        if (LudicManifest.isLock(file)) return lockDoc(file, line)
        return when (line.directive) {
            "app" -> appPreview(file, highlight = line.words.getOrNull(1))
            null -> null
            else -> directiveDoc(file, line)
        }
    }

    override fun getCustomDocumentationElement(editor: Editor, file: PsiFile, contextElement: PsiElement?, targetOffset: Int): PsiElement? =
        if (isPackageFile(file)) contextElement else null

    private fun esc(s: String) = StringUtil.escapeXmlEntities(s)

    private fun directiveDoc(file: PsiFile, line: ManifestLine): String? {
        val d = line.directive ?: return null
        val help = LudicManifest.DIRECTIVES[d] ?: return null
        val value = line.words.getOrNull(1)
        val sb = StringBuilder("<div class='definition'><pre>").append(esc(line.text.substringBefore('#').trim())).append("</pre></div>")
        sb.append("<div class='content'><p>").append(esc(help)).append("</p>")
        when (d) {
            "kind" -> LudicManifest.KINDS[value]?.let { sb.append("<p><b>").append(esc(value!!)).append("</b>: ").append(esc(it)).append("</p>") }
            "version" -> if (value != null) sb.append("<p>Published by the git tag <code>v").append(esc(value)).append("</code>.</p>")
            "package" -> if (value != null) sb.append("<p>Others depend on it with <code>require \"").append(esc(value)).append("\" \"").append(esc(LudicManifest.parse(file.text).version ?: "1.0.0")).append("\"</code>.</p>")
            "require" -> requireDetail(file, line, sb)
            "hook" -> {
                line.words.getOrNull(1)?.let { p -> LudicManifest.HOOK_PHASES[p]?.let { sb.append("<p><b>").append(esc(p)).append("</b>: ").append(esc(it)).append("</p>") } }
                line.words.getOrNull(2)?.let { ev ->
                    val what = LudicManifest.HOOK_EVENTS[ev] ?: LudicManifest.parse(file.text).scripts.firstOrNull { it.name == ev }?.let { "the script ${it.name}: ${it.command}" }
                    if (what != null) sb.append("<p>Wraps <code>").append(esc(what)).append("</code></p>")
                }
                sb.append("<p>Runs through the shell in the package root with <code>LUDIC_EVENT</code>, <code>LUDIC_PHASE</code> and <code>LUDIC_PACKAGE_ROOT</code> set.</p>")
            }
            "script" -> {
                val name = line.words.getOrNull(1)
                if (name != null) {
                    val how = if (name in LudicManifest.BUILTIN_COMMANDS) "ludic script $name" else "ludic $name"
                    sb.append("<p>Run with <code>").append(esc(how)).append(" [args]</code>.</p>")
                    val hooks = LudicManifest.parse(file.text).hooks.filter { it.event == name }
                    hooks.forEach { sb.append("<p>").append(esc(it.phase)).append(": <code>").append(esc(it.command)).append("</code></p>") }
                }
            }
            "entry", "pack" -> line.words.drop(1).forEach { p ->
                val f = resolveManifestPath(file, p)
                sb.append("<p><code>").append(esc(p)).append("</code> — ")
                    .append(if (f?.exists() == true) (if (f.isDirectory) "directory" else "file") else "<b>missing</b>").append("</p>")
            }
        }
        sb.append("</div>")
        return sb.toString()
    }

    private fun requireDetail(file: PsiFile, line: ManifestLine, sb: StringBuilder) {
        val module = line.words.getOrNull(1) ?: return
        val lockFile = file.virtualFile?.parent?.findChild(LudicManifest.LOCK_NAME)
        val locked = lockFile?.let { runCatching { LudicManifest.parseLock(String(it.contentsToByteArray())) }.getOrNull() }
            ?.firstOrNull { it.module == module }
        if (locked == null) sb.append("<p>Not in the lock yet: run <code>ludic get</code>.</p>")
        else sb.append("<p>Locked at <b>").append(esc(locked.version)).append("</b> (").append(esc(locked.kind)).append(")<br>hash <code>")
            .append(esc(locked.hash.take(16))).append("…</code></p>")
        val dir = packageDir(file, module)
        sb.append("<p>").append(if (dir != null) "Linked at <code>${esc(dir.path)}</code>" else "Not linked into ludic_modules/").append("</p>")
    }

    private fun lockDoc(file: PsiFile, line: ManifestLine): String? {
        if (line.directive != "module") return line.directive?.let { LudicManifest.LOCK_WORDS[it] }?.let { "<div class='content'>${esc(it)}</div>" }
        val m = LudicManifest.parseLock(line.text).firstOrNull() ?: return null
        val dir = packageDir(file, m.module)
        return buildString {
            append("<div class='definition'><pre>").append(esc(m.module)).append("</pre></div><table class='sections'>")
            row("Version", esc(m.version))
            row("Kind", esc(m.kind))
            if (m.provides.isNotEmpty()) row("Provides", m.provides.joinToString { "<code>${esc(it)}.*</code>" })
            row("Hash", "<code>${esc(m.hash)}</code>")
            row("On disk", if (dir != null) "<code>${esc(dir.path)}</code>" else "not linked — run <code>ludic get</code>")
            append("</table>")
        }
    }

    private fun StringBuilder.row(k: String, v: String) {
        append("<tr><td valign='top' class='section'><p>").append(k).append("</p></td><td valign='top'>").append(v).append("</td></tr>")
    }

    /** The app the `app` lines describe, as `ludic bundle` would build it. */
    private fun appPreview(file: PsiFile, highlight: String?): String {
        val m = LudicManifest.parse(file.text)
        val app = m.app
        val name = app["name"] ?: m.module?.substringAfterLast('/') ?: file.virtualFile?.parent?.name ?: "app"
        fun img(key: String, size: Int): String? {
            val f = app[key]?.let { resolveManifestPath(file, it) }?.takeIf { it.isFile } ?: return null
            return "<img src='${f.toURI()}' width='$size' height='$size'>"
        }
        fun mark(k: String, v: String) = if (k == highlight) "<b>$v</b>" else v
        return buildString {
            append("<div class='definition'><pre>").append(esc(name)).append(".app</pre></div>")
            append("<div class='content'><table><tr><td valign='top'>")
            append(img("icon", 64) ?: "")
            append("</td><td valign='top'><p><b>").append(esc(name)).append("</b></p><p>")
            append(esc(app["id"] ?: "(no bundle id)")).append("<br>version ")
            append(esc(app["version"] ?: m.version ?: "0.1.0"))
            app["category"]?.let { append("<br>").append(esc(it.removePrefix("public.app-category."))) }
            app["min_macos"]?.let { append("<br>macOS ").append(esc(it)).append("+") }
            append("</p></td></tr></table>")
            app["splash"]?.let { s ->
                val f = resolveManifestPath(file, s)
                val bg = app["splash_bg"] ?: "#000000"
                append("<p>Splash</p><table><tr><td bgcolor='").append(esc(bg)).append("'>")
                if (f?.isFile == true) append("<img src='").append(f.toURI()).append("' width='240'>") else append("&nbsp;missing: ").append(esc(s))
                append("</td></tr></table>")
            }
            append("</div><table class='sections'>")
            for ((k, help) in LudicManifest.APP_KEYS) {
                val v = app[k] ?: continue
                val shown = if (k == "splash_bg") "<span style='background-color:${esc(v)}'>&nbsp;&nbsp;&nbsp;&nbsp;</span> ${esc(v)}" else esc(v)
                row(mark(k, k), mark(k, shown) + "<br><span class='grayed'>${esc(help)}</span>")
            }
            append("</table>")
            m.entry?.let { append("<div class='bottom'>entry ").append(esc(it)).append("</div>") }
        }
    }
}
