package io.ludic.ide.editor

import com.intellij.openapi.editor.colors.TextAttributesKey
import io.ludic.ide.LudicColors

/**
 * ludic-lsp's semantic tokens, in the plugin's own colour keys, so every
 * colour is on Settings | Editor | Color Scheme | Ludic and tells the program's
 * code, package code and the built-in language apart.
 *
 * Keywords, literals, comments and operators return null: the lexer already
 * colours those (including contextual keywords and manifest directives), and a
 * semantic colour on top would only flatten them.
 */
object LudicSemanticColors {
    fun keyFor(type: String, modifiers: List<String>): TextAttributesKey? {
        val builtin = "defaultLibrary" in modifiers
        val pkg = "vendor" in modifiers
        val decl = "declaration" in modifiers
        val readonly = "readonly" in modifiers
        val global = "static" in modifiers
        return when (type) {
            "function" -> when {
                readonly -> LudicColors.HANDLER                 // ludic-lsp marks handlers readonly
                builtin -> LudicColors.FUNCTION_BUILTIN
                pkg -> LudicColors.FUNCTION_PACKAGE
                decl -> LudicColors.FUNCTION_DECLARATION
                else -> LudicColors.FUNCTION_CALL
            }
            "variable" -> when {
                readonly && builtin -> LudicColors.CONSTANT_BUILTIN
                readonly && pkg -> LudicColors.CONSTANT_PACKAGE
                readonly -> LudicColors.CONSTANT
                global && pkg -> LudicColors.GLOBAL_VARIABLE_PACKAGE
                global -> LudicColors.GLOBAL_VARIABLE
                else -> LudicColors.LOCAL_VARIABLE
            }
            "parameter" -> LudicColors.PARAMETER
            "property" -> LudicColors.FIELD
            "struct" -> if (pkg) LudicColors.TYPE_PACKAGE else LudicColors.PROPERTY_TYPE
            "class" -> when {
                builtin -> LudicColors.KEYWORD           // ui widgets: panel, button, …
                pkg -> LudicColors.TYPE_PACKAGE
                else -> LudicColors.MODEL_TYPE
            }
            "namespace" -> if (builtin) LudicColors.NAMESPACE_BUILTIN else LudicColors.NAMESPACE
            "enumMember" -> if (readonly && builtin) LudicColors.PHASE else LudicColors.CONSTANT_BUILTIN
            "decorator" -> LudicColors.ANNOTATION
            "type" -> if (builtin) null else LudicColors.TYPE_NAME
            else -> null
        }
    }
}
