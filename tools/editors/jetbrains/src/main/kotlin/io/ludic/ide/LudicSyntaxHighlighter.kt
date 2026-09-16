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
    val STRING_ESCAPE = key("LUDIC_STRING_ESCAPE", D.VALID_STRING_ESCAPE)
    val TEMPLATE_BRACES = key("LUDIC_TEMPLATE_BRACES", D.KEYWORD)
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
    val MANIFEST = key("LUDIC_MANIFEST_DIRECTIVE", D.KEYWORD)

    // Semantic colours, painted from ludic-lsp's tokens. "Built-in" is the
    // language and its standard library, "package" a ludic.* or fetched
    // package, and the plain key the program's own code.
    val FUNCTION_DECLARATION = key("LUDIC_FUNCTION_DECLARATION", D.FUNCTION_DECLARATION)
    val FUNCTION_CALL = key("LUDIC_FUNCTION_CALL", D.FUNCTION_CALL)
    val FUNCTION_PACKAGE = key("LUDIC_FUNCTION_PACKAGE", D.FUNCTION_CALL)
    val FUNCTION_BUILTIN = key("LUDIC_FUNCTION_BUILTIN", D.PREDEFINED_SYMBOL)
    val HANDLER = key("LUDIC_HANDLER", D.FUNCTION_DECLARATION)
    val CONSTANT = key("LUDIC_CONSTANT", D.CONSTANT)
    val CONSTANT_PACKAGE = key("LUDIC_CONSTANT_PACKAGE", D.CONSTANT)
    val CONSTANT_BUILTIN = key("LUDIC_CONSTANT_BUILTIN", D.STATIC_FIELD)
    val GLOBAL_VARIABLE = key("LUDIC_GLOBAL_VARIABLE", D.GLOBAL_VARIABLE)
    val GLOBAL_VARIABLE_PACKAGE = key("LUDIC_GLOBAL_VARIABLE_PACKAGE", D.GLOBAL_VARIABLE)
    val LOCAL_VARIABLE = key("LUDIC_LOCAL_VARIABLE", D.LOCAL_VARIABLE)
    val PARAMETER = key("LUDIC_PARAMETER", D.PARAMETER)
    val FIELD = key("LUDIC_FIELD", D.INSTANCE_FIELD)
    val PROPERTY_TYPE = key("LUDIC_PROPERTY_TYPE", D.CLASS_NAME)
    val MODEL_TYPE = key("LUDIC_MODEL_TYPE", D.CLASS_NAME)
    val TYPE_PACKAGE = key("LUDIC_TYPE_PACKAGE", D.CLASS_REFERENCE)
    val NAMESPACE = key("LUDIC_NAMESPACE", D.CLASS_REFERENCE)
    val NAMESPACE_BUILTIN = key("LUDIC_NAMESPACE_BUILTIN", D.PREDEFINED_SYMBOL)
    val BAD = createTextAttributesKey("LUDIC_BAD_CHARACTER", HighlighterColors.BAD_CHARACTER)

    private fun key(name: String, base: TextAttributesKey) = createTextAttributesKey(name, base)
}

class LudicSyntaxHighlighter(private val manifest: Boolean = false) : SyntaxHighlighterBase() {
    override fun getHighlightingLexer(): Lexer = LudicLexer(manifest)

    override fun getTokenHighlights(tokenType: IElementType): Array<TextAttributesKey> = pack(
        when (tokenType) {
            LudicTokens.COMMENT -> LudicColors.COMMENT
            LudicTokens.STRING, LudicTokens.CHAR, LudicTokens.TEMPLATE_QUOTE, LudicTokens.TEMPLATE_TEXT -> LudicColors.STRING
            LudicTokens.TEMPLATE_ESCAPE -> LudicColors.STRING_ESCAPE
            LudicTokens.TEMPLATE_HOLE_START, LudicTokens.TEMPLATE_HOLE_END -> LudicColors.TEMPLATE_BRACES
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
            LudicTokens.LBRACE, LudicTokens.RBRACE -> LudicColors.BRACE
            LudicTokens.LBRACKET, LudicTokens.RBRACKET -> LudicColors.BRACKET
            LudicTokens.LPAREN, LudicTokens.RPAREN -> LudicColors.PAREN
            LudicTokens.COMMA -> LudicColors.COMMA
            LudicTokens.MANIFEST_KEYWORD -> LudicColors.MANIFEST
            LudicTokens.BAD -> LudicColors.BAD
            else -> null
        }
    )
}

class LudicSyntaxHighlighterFactory : SyntaxHighlighterFactory() {
    override fun getSyntaxHighlighter(project: Project?, virtualFile: VirtualFile?): SyntaxHighlighter =
        LudicSyntaxHighlighter(manifest = virtualFile?.name == "package.ludic" || virtualFile?.name == "package.lock.ludic")
}
