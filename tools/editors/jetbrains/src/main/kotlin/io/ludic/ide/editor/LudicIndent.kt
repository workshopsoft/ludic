package io.ludic.ide.editor

import com.intellij.application.options.CodeStyle
import com.intellij.codeInsight.editorActions.SimpleTokenSetQuoteHandler
import com.intellij.codeInsight.editorActions.TypedHandlerDelegate
import com.intellij.lang.Language
import com.intellij.openapi.editor.Document
import com.intellij.openapi.editor.Editor
import com.intellij.openapi.project.Project
import com.intellij.psi.PsiFile
import com.intellij.psi.codeStyle.lineIndent.LineIndentProvider
import io.ludic.ide.LudicFileType
import io.ludic.ide.LudicLanguage
import io.ludic.ide.LudicLexer
import io.ludic.ide.LudicTokens

/**
 * Where a line's indentation belongs, from bracket nesting alone.
 *
 * Every open `{`, `[` or `(` before the offset is a level; a level's body is
 * indented one unit past the *line* its opener sits on, so
 *
 *     handler Move phase Update {
 *       for (p) in query [Pos] {
 *         |
 *
 * lands where it should however the header lines were themselves indented.
 * Strings and comments go through the lexer, so a brace inside `"{"` or a
 * comment does not count. A line that starts with a closer lines up with its
 * opener's line.
 */
object LudicIndenter {

    fun indentFor(text: CharSequence, offset: Int, unit: String): String {
        val lexer = LudicLexer()
        lexer.start(text, 0, offset.coerceIn(0, text.length), 0)
        val opens = ArrayDeque<Int>()
        while (true) {
            val type = lexer.tokenType ?: break
            when (type) {
                LudicTokens.LBRACE, LudicTokens.LBRACKET, LudicTokens.LPAREN -> opens.addLast(lexer.tokenStart)
                LudicTokens.RBRACE, LudicTokens.RBRACKET, LudicTokens.RPAREN -> opens.removeLastOrNull()
            }
            lexer.advance()
        }
        val opener = opens.lastOrNull() ?: return ""
        val base = leadingWhitespace(text, lineStart(text, opener))
        return if (startsWithCloser(text, offset)) base else base + unit
    }

    /** Does the text from [offset] to the end of its line begin with a closer? */
    fun startsWithCloser(text: CharSequence, offset: Int): Boolean {
        var i = offset
        while (i < text.length && (text[i] == ' ' || text[i] == '\t')) i++
        return i < text.length && text[i] in "}])"
    }

    fun lineStart(text: CharSequence, offset: Int): Int {
        var i = offset.coerceAtMost(text.length)
        while (i > 0 && text[i - 1] != '\n') i--
        return i
    }

    fun leadingWhitespace(text: CharSequence, from: Int): String {
        var i = from
        while (i < text.length && (text[i] == ' ' || text[i] == '\t')) i++
        return text.subSequence(from, i).toString()
    }

    fun unit(project: Project): String {
        val o = CodeStyle.getSettings(project).getIndentOptions(LudicFileType)
        return if (o.USE_TAB_CHARACTER) "\t" else " ".repeat(o.INDENT_SIZE)
    }
}

/** Enter: the new line starts at the right depth. */
class LudicLineIndentProvider : LineIndentProvider {
    override fun getLineIndent(project: Project, editor: Editor, language: Language?, offset: Int): String? =
        LudicIndenter.indentFor(editor.document.charsSequence, offset, LudicIndenter.unit(project))

    override fun isSuitableFor(language: Language?) = language == LudicLanguage
}

/**
 * Typing a closer as the first thing on a line pulls it back to its opener's
 * depth: `    }` becomes `  }` the moment the brace is typed.
 */
class LudicCloserTypedHandler : TypedHandlerDelegate() {
    override fun charTyped(c: Char, project: Project, editor: Editor, file: PsiFile): Result {
        if (file.fileType != LudicFileType || c !in "}])") return Result.CONTINUE
        val doc = editor.document
        val caret = editor.caretModel.offset
        val closer = caret - 1
        if (closer < 0) return Result.CONTINUE
        val text = doc.charsSequence
        val start = LudicIndenter.lineStart(text, closer)
        if (text.subSequence(start, closer).isNotBlank()) return Result.CONTINUE
        val want = LudicIndenter.indentFor(text, closer, LudicIndenter.unit(project))
        reindent(doc, start, closer, want)
        return Result.CONTINUE
    }

    private fun reindent(doc: Document, start: Int, end: Int, want: String) {
        if (doc.charsSequence.subSequence(start, end).toString() == want) return
        doc.replaceString(start, end, want)
    }
}

class LudicQuoteHandler : SimpleTokenSetQuoteHandler(LudicTokens.STRING, LudicTokens.CHAR, LudicTokens.TEMPLATE_QUOTE)
