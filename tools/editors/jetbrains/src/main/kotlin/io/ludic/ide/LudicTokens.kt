package io.ludic.ide

import com.intellij.psi.tree.IElementType
import com.intellij.psi.tree.IFileElementType
import com.intellij.psi.tree.TokenSet

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
    // `text {hole} text`: the pieces of a template string
    val TEMPLATE_QUOTE = LudicTokenType("TEMPLATE_QUOTE")
    val TEMPLATE_TEXT = LudicTokenType("TEMPLATE_TEXT")
    val TEMPLATE_ESCAPE = LudicTokenType("TEMPLATE_ESCAPE")      // {{ }} \n
    val TEMPLATE_HOLE_START = LudicTokenType("TEMPLATE_HOLE_START")
    val TEMPLATE_HOLE_END = LudicTokenType("TEMPLATE_HOLE_END")
    val TEMPLATE_PARTS = TokenSet.create(TEMPLATE_QUOTE, TEMPLATE_TEXT, TEMPLATE_ESCAPE)
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
    val MANIFEST_KEYWORD = LudicTokenType("MANIFEST_KEYWORD") // package.ludic: package, require, app, ...
    val OPERATOR = LudicTokenType("OPERATOR")
    // Opening and closing delimiters are distinct types: the platform's brace
    // matching (and Enter's "close the unmatched brace") cannot tell `{` from
    // `}` by text, only by token type.
    val LBRACE = LudicTokenType("LBRACE")
    val RBRACE = LudicTokenType("RBRACE")
    val LBRACKET = LudicTokenType("LBRACKET")
    val RBRACKET = LudicTokenType("RBRACKET")
    val LPAREN = LudicTokenType("LPAREN")
    val RPAREN = LudicTokenType("RPAREN")
    val BRACES = TokenSet.create(LBRACE, RBRACE)
    val BRACKETS = TokenSet.create(LBRACKET, RBRACKET)
    val PARENS = TokenSet.create(LPAREN, RPAREN)
    val DELIMITERS = TokenSet.orSet(BRACES, BRACKETS, PARENS)
    val COMMA = LudicTokenType("COMMA")
    val BAD = LudicTokenType("BAD_CHARACTER")
}

/**
 * The vocabulary. The keyword, type and phase sets are written by `ludic-dev
 * syntax` from the compiler's own table (`ludicc --emit-syntax`); the rest
 * mirrors tools/ludic-tools/ludic_syntax.h.
 */
object LudicVocabulary {
    // ludic-dev syntax: begin - generated from `ludicc --emit-syntax` (selfhost/frontend/vocab.ludic); run `ludic-dev syntax`, do not edit
    val DECL = setOf(
        "program", "module", "import", "property", "state", "event", "action", "reducer", "enum",
        "model", "prefab", "scene", "handler", "ui", "namespace", "alias", "port", "bind",
        "registry", "def", "component", "view", "prop", "const", "var", "function", "fn", "extern",
        "entry", "test"
    )
    val CLAUSE = setOf(
        "export", "internal", "friend", "uses", "open", "of", "as", "from", "numbers", "unsafe",
        "mut", "phase", "query", "on", "cancellable", "public", "layer", "start", "shows", "lasts",
        "then", "loads", "system"
    )
    val STMT = setOf(
        "let", "if", "else", "while", "for", "in", "where", "match", "machine", "become", "return",
        "break", "continue", "new", "spawn", "despawn", "enable", "disable", "attach", "detach",
        "emit", "cancel", "dispatch", "try", "and", "or", "not"
    )
    val PRIMITIVES = setOf(
        "int", "long", "float", "double", "fixed", "bool", "byte", "string", "Key", "pointer",
        "void", "entity", "countdown", "words", "floats", "doubles", "fixeds", "pointers", "Vector",
        "IVec2", "Rect"
    )
    val PHASES = setOf(
        "Start", "Input", "FixedUpdate", "Update", "LateUpdate", "Render", "Overlay"
    )
    // ludic-dev syntax: end
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

    /**
     * Declaration and clause words the compiler does not reserve as names
     * (selfhost/frontend/parse.ludic is_reserved_word only guards function
     * names): they are keywords only where a declaration can start.
     */
    val CONTEXTUAL = setOf(
        "program", "import", "property", "model", "enum", "ui", "namespace", "function", "extern",
        "handler", "entry", "event", "scene", "test", "phase", "query", "on", "cancellable", "public",
        "layer", "start"
    )

    /**
     * The directives parse_manifest (tools/ludic-cli/pkg.ludic) understands,
     * and the words of the lock file parse_lock reads.
     */
    val MANIFEST = setOf(
        "package", "version", "kind", "entry", "provides", "targets", "require", "pack", "app", "script", "hook",
        "lock", "module", "hash"
    )

    fun isKeyword(w: String) = w in DECL || w in CLAUSE || w in STMT
}
