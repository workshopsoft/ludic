package io.ludic.ide

import com.intellij.lang.ASTNode
import com.intellij.lang.ParserDefinition
import com.intellij.lang.PsiParser
import com.intellij.lexer.Lexer
import com.intellij.openapi.project.Project
import com.intellij.psi.FileViewProvider
import com.intellij.psi.PsiElement
import com.intellij.psi.PsiFile
import com.intellij.psi.TokenType
import com.intellij.psi.tree.IFileElementType
import com.intellij.psi.tree.TokenSet
import com.intellij.extapi.psi.ASTWrapperPsiElement
import com.intellij.extapi.psi.PsiFileBase

/**
 * A flat PSI: every token becomes a leaf under the file node, with no tree
 * structure above it.
 *
 * That is enough for the two things the platform genuinely needs a parser for —
 * injecting Ludic into Markdown fences, and letting the editor treat a .ludic
 * file as a real language rather than plain text — while all actual analysis
 * stays in ludic-lsp, where it is shared with every other editor. Building a
 * second, divergent parser in Kotlin would mean two grammars to keep honest
 * against one compiler.
 */
class LudicParserDefinition : ParserDefinition {
    override fun createLexer(project: Project?): Lexer = LudicLexer()

    override fun createParser(project: Project?): PsiParser = PsiParser { root, builder ->
        val mark = builder.mark()
        while (!builder.eof()) builder.advanceLexer()
        mark.done(root)
        builder.treeBuilt
    }

    override fun getFileNodeType(): IFileElementType = LudicTokens.FILE
    override fun getCommentTokens(): TokenSet = TokenSet.create(LudicTokens.COMMENT)
    override fun getStringLiteralElements(): TokenSet = TokenSet.create(LudicTokens.STRING, LudicTokens.CHAR, LudicTokens.TEMPLATE_TEXT)
    override fun getWhitespaceTokens(): TokenSet = TokenSet.create(TokenType.WHITE_SPACE)
    // Only ever reached for composite nodes, and this grammar marks none beyond
    // the file itself — but the platform requires an answer, so give it a real
    // PSI element rather than something that would surprise it later.
    override fun createElement(node: ASTNode): PsiElement = ASTWrapperPsiElement(node)
    override fun createFile(viewProvider: FileViewProvider): PsiFile = LudicPsiFile(viewProvider)
}

class LudicPsiFile(viewProvider: FileViewProvider) : PsiFileBase(viewProvider, LudicLanguage) {
    override fun getFileType() = LudicFileType
    override fun toString() = "Ludic file"
}
