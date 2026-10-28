package io.ludic.ide.editor

import com.intellij.lang.documentation.AbstractDocumentationProvider
import com.intellij.openapi.util.text.StringUtil
import com.intellij.psi.PsiElement
import com.intellij.psi.PsiFile
import java.io.File

/**
 * The language reference pages (the docs/language pages) as documentation.
 *
 * Go-to-definition on a built-in lands on its page, and the IDE then describes
 * that target — on Cmd/Ctrl-hover and in Quick Documentation — through
 * whatever element the language server handed back, which would otherwise read
 * `LSP Psi Element "---" [type-void.md]`. This renders the page's signature,
 * summary and body instead.
 */
class LudicDocPageDocumentation : AbstractDocumentationProvider() {

    override fun getQuickNavigateInfo(element: PsiElement?, originalElement: PsiElement?): String? {
        val page = pageOf(element) ?: return null
        val sig = page.meta["sig"]?.takeIf { it.isNotBlank() } ?: page.meta["name"] ?: return null
        val tip = page.meta["tip"].orEmpty()
        return "<b>${esc(sig)}</b>" + if (tip.isNotEmpty()) "<br>${esc(tip)}" else ""
    }

    override fun generateDoc(element: PsiElement?, originalElement: PsiElement?): String? {
        val page = pageOf(element) ?: return null
        val sig = page.meta["sig"]?.takeIf { it.isNotBlank() } ?: page.meta["name"] ?: page.meta["title"] ?: return null
        val sb = StringBuilder()
        sb.append("<div class='definition'><pre>").append(esc(sig)).append("</pre></div><div class='content'>")
        page.meta["tip"]?.takeIf { it.isNotBlank() }?.let { sb.append("<p><b>").append(esc(it)).append("</b></p>") }
        sb.append(markdownToHtml(page.body))
        sb.append("</div>")
        page.meta["id"]?.let { id ->
            val url = DOCS_URL + (if (page.file.name == "_section.md") "ns-$id" else id) + ".html"
            sb.append("<div class='bottom'><a href='").append(url).append("'>").append(url).append("</a></div>")
        }
        return sb.toString()
    }

    override fun getUrlFor(element: PsiElement?, originalElement: PsiElement?): List<String>? {
        val page = pageOf(element) ?: return null
        val id = page.meta["id"] ?: return null
        return listOf(DOCS_URL + (if (page.file.name == "_section.md") "ns-$id" else id) + ".html")
    }

    data class Page(val file: File, val meta: Map<String, String>, val body: String)

    companion object {
        const val DOCS_URL = "https://workshopsoft.github.io/ludic/"

        fun pageOf(element: PsiElement?): Page? {
            val file: PsiFile = element?.containingFile ?: (element as? PsiFile) ?: return null
            val path = file.virtualFile?.path ?: return null
            if (!path.contains("/docs/language/") || !path.endsWith(".md")) return null
            return parse(File(path), file.text)
        }

        fun parse(file: File, text: String): Page? {
            if (!text.startsWith("---\n")) return null
            val end = text.indexOf("\n---", 4)
            if (end < 0) return null
            val meta = text.substring(4, end).lines().mapNotNull { line ->
                val c = line.indexOf(':')
                if (c <= 0) null else line.substring(0, c).trim() to line.substring(c + 1).trim()
            }.toMap()
            val body = text.substring(end + 4).trimStart('-', '\n', '\r')
            return Page(file, meta, body)
        }

        private fun esc(s: String) = StringUtil.escapeXmlEntities(s)

        /**
         * Just enough markdown for these pages: paragraphs, `code`, **bold**,
         * fenced ```ludic blocks and the inline HTML the pages already use.
         */
        fun markdownToHtml(md: String): String {
            val out = StringBuilder()
            val lines = md.lines()
            var i = 0
            val para = StringBuilder()
            fun flush() {
                if (para.isNotBlank()) out.append("<p>").append(inline(para.toString().trim())).append("</p>")
                para.setLength(0)
            }
            while (i < lines.size) {
                val line = lines[i]
                if (line.trimStart().startsWith("```")) {
                    flush()
                    val code = StringBuilder()
                    i++
                    while (i < lines.size && !lines[i].trimStart().startsWith("```")) {
                        if (!lines[i].trimStart().startsWith("# doc-check")) code.append(lines[i]).append('\n')
                        i++
                    }
                    out.append("<pre><code>").append(esc(code.toString().trimEnd())).append("</code></pre>")
                } else if (line.isBlank()) {
                    flush()
                } else {
                    para.append(line).append(' ')
                }
                i++
            }
            flush()
            return out.toString()
        }

        private fun inline(s: String): String {
            // the pages mix markdown with a little inline HTML (<code>, <b>);
            // keep those tags, escape everything else
            val keep = Regex("</?(code|b|i|em|strong|br)>")
            val parts = StringBuilder()
            var last = 0
            for (m in keep.findAll(s)) {
                parts.append(mdSpans(esc(s.substring(last, m.range.first))))
                parts.append(m.value)
                last = m.range.last + 1
            }
            parts.append(mdSpans(esc(s.substring(last))))
            return parts.toString()
        }

        private fun mdSpans(s: String): String = s
            .replace(Regex("`([^`]+)`"), "<code>$1</code>")
            .replace(Regex("\\*\\*([^*]+)\\*\\*"), "<b>$1</b>")
            .replace(Regex("\\[([^\\]]+)]\\(([^)]+)\\)"), "<a href='$2'>$1</a>")
    }
}
