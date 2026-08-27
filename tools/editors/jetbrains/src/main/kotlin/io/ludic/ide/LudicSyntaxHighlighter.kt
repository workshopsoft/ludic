package io.ludic.ide

import com.intellij.lexer.Lexer
import com.intellij.openapi.editor.DefaultLanguageHighlighterColors as D
import com.intellij.openapi.editor.colors.TextAttributesKey
import com.intellij.openapi.editor.colors.TextAttributesKey.createTextAttributesKey
import com.intellij.openapi.editor.HighlighterColors
import com.intellij.openapi.fileTypes.SyntaxHighlighter
import com.intellij.openapi.fileTypes.SyntaxHighlighterBase
import com.intellij.openapi.fileTypes.SyntaxHighlighterFactory
import com.intellij.openapi.project.Project
import com.intellij.openapi.vfs.VirtualFile
import com.intellij.psi.tree.IElementType

/**
 * Colours are all derived from the IDE's own semantic keys rather than hard
 * coded, so Ludic looks native in whatever theme the user has, dark or light,
 * without shipping a colour scheme.
 */
object LudicColors {
    val COMMENT = key("LUDIC_COMMENT", D.LINE_COMMENT)
    val STRING = key("LUDIC_STRING", D.STRING)
    val NUMBER = key("LUDIC_NUMBER", D.NUMBER)
    val KEYWORD = key("LUDIC_KEYWORD", D.KEYWORD)
    val DECL_KEYWORD = key("LUDIC_DECL_KEYWORD", D.KEYWORD)
    val CLAUSE = key("LUDIC_CLAUSE", D.METADATA)
    val PRIMITIVE = key("LUDIC_PRIMITIVE", D.KEYWORD)
    val PHASE = key("LUDIC_PHASE", D.STATIC_FIELD)
    val BOOLEAN = key("LUDIC_BOOLEAN", D.KEYWORD)
    val BUILTIN = key("LUDIC_BUILTIN", D.PREDEFINED_SYMBOL)
    val TYPE_NAME = key("LUDIC_TYPE", D.CLASS_NAME)
    val IDENTIFIER = key("LUDIC_IDENTIFIER", D.IDENTIFIER)
    val ANNOTATION = key("LUDIC_ANNOTATION", D.METADATA)
    val OPERATOR = key("LUDIC_OPERATOR", D.OPERATION_SIGN)
    val BRACE = key("LUDIC_BRACE", D.BRACES)
    val BRACKET = key("LUDIC_BRACKET", D.BRACKETS)
    val PAREN = key("LUDIC_PAREN", D.PARENTHESES)
    val COMMA = key("LUDIC_COMMA", D.COMMA)
    val BAD = createTextAttributesKey("LUDIC_BAD_CHARACTER", HighlighterColors.BAD_CHARACTER)

    private fun key(name: String, base: TextAttributesKey) = createTextAttributesKey(name, base)
}

class LudicSyntaxHighlighter : SyntaxHighlighterBase() {
    override fun getHighlightingLexer(): Lexer = LudicLexer()

    override fun getTokenHighlights(tokenType: IElementType): Array<TextAttributesKey> = pack(
        when (tokenType) {
            LudicTokens.COMMENT -> LudicColors.COMMENT
            LudicTokens.STRING, LudicTokens.CHAR -> LudicColors.STRING
            LudicTokens.NUMBER -> LudicColors.NUMBER
            LudicTokens.KEYWORD -> LudicColors.KEYWORD
            LudicTokens.DECL_KEYWORD -> LudicColors.DECL_KEYWORD
            LudicTokens.CLAUSE -> LudicColors.CLAUSE
            LudicTokens.PRIMITIVE -> LudicColors.PRIMITIVE
            LudicTokens.PHASE -> LudicColors.PHASE
            LudicTokens.BOOLEAN -> LudicColors.BOOLEAN
            LudicTokens.BUILTIN -> LudicColors.BUILTIN
            LudicTokens.TYPE_NAME -> LudicColors.TYPE_NAME
            LudicTokens.IDENTIFIER -> LudicColors.IDENTIFIER
            LudicTokens.ANNOTATION -> LudicColors.ANNOTATION
            LudicTokens.OPERATOR -> LudicColors.OPERATOR
            LudicTokens.BRACE -> LudicColors.BRACE
            LudicTokens.BRACKET -> LudicColors.BRACKET
            LudicTokens.PAREN -> LudicColors.PAREN
            LudicTokens.COMMA -> LudicColors.COMMA
            LudicTokens.BAD -> LudicColors.BAD
            else -> null
        }
    )
}

class LudicSyntaxHighlighterFactory : SyntaxHighlighterFactory() {
    override fun getSyntaxHighlighter(project: Project?, virtualFile: VirtualFile?): SyntaxHighlighter =
        LudicSyntaxHighlighter()
}
