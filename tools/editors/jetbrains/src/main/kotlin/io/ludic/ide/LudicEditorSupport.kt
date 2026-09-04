package io.ludic.ide

import com.intellij.lang.BracePair
import com.intellij.lang.Commenter
import com.intellij.lang.PairedBraceMatcher
import com.intellij.lang.folding.FoldingBuilderEx
import com.intellij.lang.folding.FoldingDescriptor
import com.intellij.openapi.editor.Document
import com.intellij.openapi.project.DumbAware
import com.intellij.openapi.util.TextRange
import com.intellij.psi.PsiElement
import com.intellij.psi.PsiFile
import com.intellij.psi.tree.IElementType

/**
 * The small editor mechanics the platform expects a language to provide: how to
 * comment a line, which delimiters pair up, and what can be folded. None of
 * this needs the language server, so none of it waits for one.
 */
class LudicCommenter : Commenter {
    override fun getLineCommentPrefix() = "# "
    override fun getBlockCommentPrefix(): String? = null
    override fun getBlockCommentSuffix(): String? = null
    override fun getCommentedBlockCommentPrefix(): String? = null
    override fun getCommentedBlockCommentSuffix(): String? = null
}

class LudicBraceMatcher : PairedBraceMatcher {
    override fun getPairs(): Array<BracePair> = PAIRS

    override fun isPairedBracesAllowedBeforeType(lbraceType: IElementType, next: IElementType?): Boolean = true

    override fun getCodeConstructStart(file: PsiFile?, openingBraceOffset: Int): Int = openingBraceOffset

    private companion object {
        // Structural braces only: a record literal shares the token type, so
        // marking them all structural would make the "matched brace" gutter
        // noisy inside `spawn Hero { Pos { x: 1 } }`.
        val PAIRS = arrayOf(
            BracePair(LudicTokens.BRACE, LudicTokens.BRACE, true),
            BracePair(LudicTokens.BRACKET, LudicTokens.BRACKET, false),
            BracePair(LudicTokens.PAREN, LudicTokens.PAREN, false)
        )
    }
}

/**
 * Folds every braced block. Working off the lexer's token stream rather than a
 * PSI tree keeps this correct for a flat PSI, and it degrades gracefully on a
 * file with unbalanced braces, which is most files while they are being typed.
 */
class LudicFoldingBuilder : FoldingBuilderEx(), DumbAware {
    override fun buildFoldRegions(root: PsiElement, document: Document, quick: Boolean): Array<FoldingDescriptor> {
        val text = root.containingFile?.text ?: return emptyArray()
        val lexer = LudicLexer()
        lexer.start(text, 0, text.length, 0)

        val opens = ArrayDeque<Int>()
        val regions = mutableListOf<FoldingDescriptor>()
        val node = root.node ?: return emptyArray()

        while (lexer.tokenType != null) {
            if (lexer.tokenType == LudicTokens.BRACE) {
                when (text[lexer.tokenStart]) {
                    '{' -> opens.addLast(lexer.tokenStart)
                    '}' -> {
                        val open = opens.removeLastOrNull()
                        if (open != null) {
                            val end = lexer.tokenEnd
                            // only worth folding when it actually spans lines
                            if (document.getLineNumber(end) > document.getLineNumber(open)) {
                                regions += FoldingDescriptor(node, TextRange(open, end))
                            }
                        }
                    }
                }
            }
            lexer.advance()
        }
        return regions.toTypedArray()
    }

    override fun getPlaceholderText(node: com.intellij.lang.ASTNode) = "{...}"
    override fun isCollapsedByDefault(node: com.intellij.lang.ASTNode) = false
}
