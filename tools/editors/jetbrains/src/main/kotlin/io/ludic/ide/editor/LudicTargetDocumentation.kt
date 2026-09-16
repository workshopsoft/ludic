package io.ludic.ide.editor

import com.intellij.lang.documentation.AbstractDocumentationProvider
import com.intellij.openapi.util.text.StringUtil
import com.intellij.psi.PsiDocumentManager
import com.intellij.psi.PsiElement
import com.redhat.devtools.lsp4ij.LanguageServerManager
import io.ludic.ide.LudicLanguage
import org.eclipse.lsp4j.HoverParams
import org.eclipse.lsp4j.Position
import org.eclipse.lsp4j.TextDocumentIdentifier
import java.util.concurrent.TimeUnit

/**
 * What the IDE says about a declaration the language server navigated to.
 *
 * Go-to-definition hands the IDE a synthetic element for the target, which it
 * would describe on Cmd/Ctrl-hover as `LSP Symbol "dists" [valley.ludic]`.
 * This asks ludic-lsp for its hover at that spot instead, so the tooltip is
 * the declaration and its type: `let dists: words`.
 */
class LudicTargetDocumentation : AbstractDocumentationProvider() {

    override fun getQuickNavigateInfo(element: PsiElement?, originalElement: PsiElement?): String? {
        val md = hoverAt(element) ?: return null
        val code = codeOf(md) ?: return null
        val where = element?.containingFile?.name?.let { " <span class='grayed'>$it</span>" } ?: ""
        return "<b>${StringUtil.escapeXmlEntities(code)}</b>$where"
    }

    override fun generateDoc(element: PsiElement?, originalElement: PsiElement?): String? {
        val md = hoverAt(element) ?: return null
        val code = codeOf(md)
        val rest = md.substringAfter("```", "").substringAfter("```", md).trim()
        val sb = StringBuilder()
        if (code != null) sb.append("<div class='definition'><pre>").append(StringUtil.escapeXmlEntities(code)).append("</pre></div>")
        if (rest.isNotEmpty()) sb.append("<div class='content'>").append(LudicDocPageDocumentation.markdownToHtml(rest)).append("</div>")
        return sb.toString().ifEmpty { null }
    }

    private fun codeOf(md: String): String? {
        val m = Regex("```ludic\\n([\\s\\S]*?)\\n```").find(md) ?: return null
        return m.groupValues[1].trim()
    }

    /** ludic-lsp's hover markdown at the element's start, or null. */
    private fun hoverAt(element: PsiElement?): String? {
        if (element == null || !element.javaClass.name.startsWith("com.redhat.devtools.lsp4ij")) return null
        val file = element.containingFile ?: return null
        if (file.language != LudicLanguage) return null
        val vf = file.virtualFile ?: return null
        val doc = PsiDocumentManager.getInstance(file.project).getDocument(file) ?: return null
        val offset = element.textOffset.coerceIn(0, doc.textLength)
        val line = doc.getLineNumber(offset)
        val pos = Position(line, offset - doc.getLineStartOffset(line))
        return runCatching {
            val item = LanguageServerManager.getInstance(file.project).getLanguageServer("ludic").get(500, TimeUnit.MILLISECONDS)
                ?: return null
            val params = HoverParams(TextDocumentIdentifier(vf.toNioPath().toUri().toString()), pos)
            val hover = item.server.textDocumentService.hover(params).get(800, TimeUnit.MILLISECONDS) ?: return null
            val contents = hover.contents
            if (contents.isRight) contents.right.value else null
        }.getOrNull()
    }
}
