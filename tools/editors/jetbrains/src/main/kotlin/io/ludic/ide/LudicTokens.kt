package io.ludic.ide

import com.intellij.psi.tree.IElementType
import com.intellij.psi.tree.IFileElementType

/**
 * One token type per thing the highlighter needs to tell apart. This is a
 * lexer-only language on the JetBrains side: the token set is the whole grammar
 * the platform sees, and ludic-lsp supplies everything structural.
 */
class LudicTokenType(debugName: String) : IElementType(debugName, LudicLanguage)

object LudicTokens {
    val FILE = IFileElementType(LudicLanguage)

    val COMMENT = LudicTokenType("COMMENT")
    val STRING = LudicTokenType("STRING")
    val CHAR = LudicTokenType("CHAR")
    val NUMBER = LudicTokenType("NUMBER")
    val IDENTIFIER = LudicTokenType("IDENTIFIER")
    val TYPE_NAME = LudicTokenType("TYPE_NAME")       // Capitalised: component, archetype, scene
    val KEYWORD = LudicTokenType("KEYWORD")
    val DECL_KEYWORD = LudicTokenType("DECL_KEYWORD") // program, property, model, handler, function, ...
    val CLAUSE = LudicTokenType("CLAUSE")             // phase, query, on, layer, ...
    val PRIMITIVE = LudicTokenType("PRIMITIVE")       // int, fixed, bool, entity, string, pointer, void
    val PHASE = LudicTokenType("PHASE")               // Start, Update, Render, ...
    val BOOLEAN = LudicTokenType("BOOLEAN")
    val BUILTIN = LudicTokenType("BUILTIN")           // runtime surface + compiler intrinsics
    val ANNOTATION = LudicTokenType("ANNOTATION")     // @deterministic
    val OPERATOR = LudicTokenType("OPERATOR")
    val BRACE = LudicTokenType("BRACE")
    val BRACKET = LudicTokenType("BRACKET")
    val PAREN = LudicTokenType("PAREN")
    val COMMA = LudicTokenType("COMMA")
    val BAD = LudicTokenType("BAD_CHARACTER")
}

/**
 * The vocabulary, mirroring tools/ludic-tools/ludic_syntax.h. When the language
 * grows a keyword both sides change together; that header is the reference.
 */
object LudicVocabulary {
    val DECL = setOf(
        "program", "import", "property", "model", "enum", "ui", "namespace",
        "const", "var", "function", "extern", "handler", "entry", "event", "scene", "test"
    )
    val CLAUSE = setOf(
        "phase", "query", "on", "cancellable", "public", "layer", "start"
    )
    val STMT = setOf(
        "let", "return", "if", "else", "while", "for", "in", "spawn", "despawn",
        "enable", "disable", "match", "machine", "prefab", "state", "become", "where",
        "and", "or", "not", "break", "continue", "new", "emit", "cancel", "try"
    )
    val PRIMITIVES = setOf("int", "long", "fixed", "countdown", "bool", "entity", "string", "pointer", "byte", "words", "fixeds", "pointers", "Vector", "IVec2", "Rect", "void")
    val PHASES = setOf("Start", "Input", "FixedUpdate", "Update", "LateUpdate", "Render", "Overlay")
    val WIDGETS = setOf("panel", "col", "row", "label", "button", "image", "spacer")

    val BUILTINS = setOf(
        "min", "max", "abs", "clamp", "seed", "rng_range", "rng_chance", "fixed", "floor",
        "map_size", "map_row", "tile", "clear", "present", "fill_rect", "frame_rect",
        "put_px", "text", "text_int", "font_load", "text_ttf", "text_w", "text_h",
        "image_load", "draw_image", "draw_image_scaled", "draw_9slice", "png_load",
        "sprites_load", "draw_sprite", "draw_sprite_scaled", "ui_build", "ui_open",
        "ui_tick", "ui_render", "ui_clicked", "ui_set_text", "ui_set_int", "ui_focus",
        "ui_focused", "ui_visible", "key", "reg", "set_reg", "self", "save", "load",
        "status", "print", "string", "quit", "panic", "assert",
        "ok", "err", "is_ok", "is_err",
        "some", "none", "is_some", "is_none", "unwrap_or",
        // compiler intrinsics: the floor the Ludic-written runtime stands on
        "bytes", "words", "resize", "free", "fill",         "arg_count", "arg", "file_stderr", "file_stdout",
        "offset",
        "as_fixed", "as_int", "file_open", "file_read", "file_write",
        "file_seek", "file_tell", "file_close", "read_char",         "exit",         "is_windowed", "game_title", "win_open", "win_poll", "win_present",
        "win_running", "win_close"
    )

    fun isKeyword(w: String) = w in DECL || w in CLAUSE || w in STMT
}
