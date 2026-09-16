package io.ludic.ide.psi

import com.intellij.psi.PsiElement
import com.intellij.psi.PsiFile
import com.intellij.psi.TokenType
import com.intellij.psi.util.PsiTreeUtil
import com.intellij.psi.util.elementType
import io.ludic.ide.LudicLanguage
import io.ludic.ide.LudicTokens

/**
 * Questions about a Ludic file answered from its token stream.
 *
 * The PSI is flat (see LudicParserDefinition), so "is this a test block" is a
 * question about neighbouring leaves: a `test` declaration keyword followed by
 * a string literal. That is all the run buttons, the configuration producer and
 * the test locator need, and it holds up in a file that does not parse yet.
 */
object LudicPsi {

    /** The next leaf that is not whitespace or a comment, or null. */
    fun nextSignificant(e: PsiElement): PsiElement? {
        var n = PsiTreeUtil.nextLeaf(e)
        while (n != null && (n.elementType == TokenType.WHITE_SPACE || n.elementType == LudicTokens.COMMENT)) {
            n = PsiTreeUtil.nextLeaf(n)
        }
        return n
    }

    fun isKeyword(e: PsiElement?, word: String): Boolean =
        e != null && e.elementType == LudicTokens.DECL_KEYWORD && e.textMatches(word)

    /** `test "name"`: the keyword leaf's test name, or null when [e] is not one. */
    fun testNameAt(e: PsiElement): String? {
        if (!isKeyword(e, "test")) return null
        val str = nextSignificant(e) ?: return null
        if (str.elementType != LudicTokens.STRING) return null
        return unquote(str.text)
    }

    /** `program Name`: the program's name, or null when [e] is not its keyword. */
    fun programNameAt(e: PsiElement): String? {
        if (!isKeyword(e, "program")) return null
        val name = nextSignificant(e) ?: return null
        return if (name.elementType == LudicTokens.TYPE_NAME) name.text else null
    }

    /**
     * The `test` keyword of the block around [e], when [e] sits on that block's
     * header line: the keyword itself, the name string, or the whitespace
     * between them. A caret deep inside the body is deliberately not enough;
     * "run the test I am in" is decided by the producer from the header.
     */
    fun enclosingTestKeyword(e: PsiElement): PsiElement? {
        if (testNameAt(e) != null) return e
        if (e.elementType == LudicTokens.STRING) {
            val prev = PsiTreeUtil.prevLeaf(e)?.let { if (it.elementType == TokenType.WHITE_SPACE) PsiTreeUtil.prevLeaf(it) else it }
            if (prev != null && testNameAt(prev) != null) return prev
        }
        return null
    }

    /** Every `test "name"` keyword leaf in the file, in source order. */
    fun testKeywords(file: PsiFile): List<PsiElement> = leaves(file).filter { testNameAt(it) != null }.toList()

    fun findTest(file: PsiFile, name: String): PsiElement? = leaves(file).firstOrNull { testNameAt(it) == name }

    fun findProgram(file: PsiFile): PsiElement? = leaves(file).firstOrNull { programNameAt(it) != null }

    /** A file whose only runnable content is its test blocks. */
    fun isTestFile(file: PsiFile): Boolean {
        if (file.language != LudicLanguage) return false
        val name = file.name
        if (name.endsWith("_test.ludic")) return true
        if (file.virtualFile?.parent?.name == "tests") return true
        return hasTests(file) && !hasEntry(file)
    }

    fun hasTests(file: PsiFile) = leaves(file).any { testNameAt(it) != null }

    /** `entry` or a phase handler: something that makes a program run as a game. */
    fun hasEntry(file: PsiFile) = leaves(file).any { isKeyword(it, "entry") || isKeyword(it, "handler") }

    /** A file that is a program in its own right, rather than a module imported by one. */
    fun isProgramFile(file: PsiFile) = file.language == LudicLanguage && findProgram(file) != null

    private fun leaves(file: PsiFile): Sequence<PsiElement> =
        generateSequence(PsiTreeUtil.firstChild(file)) { PsiTreeUtil.nextLeaf(it) }
            .filter { it.elementType == LudicTokens.DECL_KEYWORD }

    /** The value of a Ludic string literal: `"a\"b"` -> `a"b`. */
    fun unquote(lit: String): String {
        val body = lit.removePrefix("\"").let { if (it.endsWith("\"") && !it.endsWith("\\\"")) it.dropLast(1) else it }
        val out = StringBuilder(body.length)
        var i = 0
        while (i < body.length) {
            val c = body[i]
            if (c == '\\' && i + 1 < body.length) {
                when (val n = body[i + 1]) {
                    'n' -> out.append('\n')
                    't' -> out.append('\t')
                    else -> out.append(n)
                }
                i += 2
            } else {
                out.append(c)
                i++
            }
        }
        return out.toString()
    }
}
