package io.ludic.ide

import com.intellij.lexer.LexerBase
import com.intellij.psi.TokenType
import com.intellij.psi.tree.IElementType

/**
 * A hand-written lexer matching tools/ludic-tools/ludic_syntax.h token for
 * token. Hand-written rather than generated because the grammar is small, the
 * rules are the ones the shared header already implements, and keeping the two
 * readable side by side is worth more here than a JFlex spec.
 *
 * With [manifest] set it lexes a package.ludic, where the directives
 * (`package`, `require`, `app`…) are the keywords instead.
 *
 * It must never throw and never fail to advance: the IDE lexes half-typed text
 * constantly, so anything unrecognised becomes one BAD character and the scan
 * carries on.
 */
class LudicLexer(private val manifest: Boolean = false) : LexerBase() {
    private var buffer: CharSequence = ""
    private var startOffset = 0
    private var endOffset = 0
    private var tokenStart = 0
    private var tokenEnd = 0
    private var tokenType: IElementType? = null

    /**
     * What the previous significant token was, which decides whether a
     * declaration word is a keyword here (see [isNamePosition]). It is the
     * lexer state, so an incremental restart mid-file lexes the same way.
     */
    private var prev = PREV_START
    private var stateAtToken = PREV_START

    /**
     * Where we are relative to a `template {hole} string`: in code, in the
     * template's text, or in a hole (with how many braces it has opened).
     * Packed into the state with [prev].
     */
    private var mode = MODE_CODE
    private var holeDepth = 0

    override fun start(buffer: CharSequence, startOffset: Int, endOffset: Int, initialState: Int) {
        this.buffer = buffer
        this.startOffset = startOffset
        this.endOffset = endOffset
        this.tokenStart = startOffset
        this.tokenEnd = startOffset
        this.prev = initialState and 3
        this.mode = (initialState shr 2) and 3
        this.holeDepth = initialState shr 4
        advance()
    }

    override fun getState() = stateAtToken
    override fun getTokenType(): IElementType? = tokenType
    override fun getTokenStart() = tokenStart
    override fun getTokenEnd() = tokenEnd
    override fun getBufferSequence() = buffer
    override fun getBufferEnd() = endOffset

    private fun at(i: Int): Char = if (i in startOffset until endOffset) buffer[i] else ' '
    private fun isIdStart(c: Char) = c.isLetter() || c == '_'
    private fun isIdPart(c: Char) = c.isLetterOrDigit() || c == '_'
    private fun isSpace(c: Char) = c == ' ' || c == '\t' || c == '\r' || c == '\n'

    override fun advance() {
        stateAtToken = prev or (mode shl 2) or (holeDepth shl 4)
        if (mode == MODE_TEXT) { lexTemplateText(); return }
        lexOne()
        val t = tokenType ?: return
        if (t != TokenType.WHITE_SPACE && t != LudicTokens.COMMENT) prev = classOf(t)
    }

    private fun classOf(t: IElementType): Int {
        val text = buffer.subSequence(tokenStart, tokenEnd)
        return when {
            t == LudicTokens.LBRACE || t == LudicTokens.RBRACE -> PREV_START
            t == LudicTokens.RPAREN || t == LudicTokens.RBRACKET -> PREV_OTHER
            t == LudicTokens.OPERATOR && text == ";" -> PREV_START
            t == LudicTokens.OPERATOR && text == "." -> PREV_NAME_BEFORE
            t == LudicTokens.OPERATOR || t == LudicTokens.LPAREN || t == LudicTokens.LBRACKET || t == LudicTokens.COMMA -> PREV_NAME_BEFORE
            t == LudicTokens.DECL_KEYWORD && (text == "var" || text == "const") -> PREV_NAME_BEFORE
            t == LudicTokens.KEYWORD && (text == "let" || text == "return") -> PREV_NAME_BEFORE
            else -> PREV_OTHER
        }
    }

    /**
     * The compiler reserves declaration words only as function names, so
     * `var model = …`, `model: Model` and `actor.model` are ordinary names.
     */
    private fun isNamePosition(end: Int): Boolean {
        if (prev == PREV_NAME_BEFORE) return true
        var j = end
        while (j < endOffset && (at(j) == ' ' || at(j) == '\t')) j++
        if (j >= endOffset) return false
        val c = at(j)
        if (c == ':' || c == '.' || c == ')' || c == ',' || c == ']') return true
        if (c == '=' && at(j + 1) != '>') return true      // `x = …`, `x == …`
        if ((c == '+' || c == '-' || c == '*' || c == '/' || c == '!') && at(j + 1) == '=') return true
        return false
    }

    private fun lexOne() {
        tokenStart = tokenEnd
        if (tokenStart >= endOffset) {
            tokenType = null
            return
        }

        var i = tokenStart
        val c = at(i)

        if (isSpace(c)) {
            while (i < endOffset && isSpace(at(i))) i++
            emit(i, TokenType.WHITE_SPACE)
            return
        }
        if (c == '#') {
            while (i < endOffset && at(i) != '\n') i++
            emit(i, LudicTokens.COMMENT)
            return
        }
        if (c == '`') {
            // opens a template, or (from a hole) closes it: the compiler ends a
            // template at the next backtick whatever it is inside
            mode = if (mode == MODE_CODE) MODE_TEXT else MODE_CODE
            holeDepth = 0
            emit(i + 1, LudicTokens.TEMPLATE_QUOTE)
            return
        }
        if (mode == MODE_HOLE && c == '}' && holeDepth == 0) {
            mode = MODE_TEXT
            emit(i + 1, LudicTokens.TEMPLATE_HOLE_END)
            return
        }
        if (mode == MODE_HOLE && c == '{') holeDepth++
        if (mode == MODE_HOLE && c == '}') holeDepth--
        if (c == '"') {
            i++
            while (i < endOffset && at(i) != '"' && at(i) != '\n') {
                if (at(i) == '\\' && i + 1 < endOffset) i += 2 else i++
            }
            if (i < endOffset && at(i) == '"') i++
            emit(i, LudicTokens.STRING)
            return
        }
        if (c == '\'') {
            i++
            if (at(i) == '\\' && i + 1 < endOffset) i += 2 else if (i < endOffset && at(i) != '\n') i++
            if (i < endOffset && at(i) == '\'') i++
            emit(i, LudicTokens.CHAR)
            return
        }
        if (c.isDigit()) {
            if (c == '0' && (at(i + 1) == 'x' || at(i + 1) == 'X')) {
                i += 2
                while (i < endOffset && (at(i).isDigit() || at(i) in 'a'..'f' || at(i) in 'A'..'F')) i++
            } else {
                while (i < endOffset && at(i).isDigit()) i++
                if (at(i) == '.' && at(i + 1).isDigit()) {
                    i++
                    while (i < endOffset && at(i).isDigit()) i++
                }
            }
            emit(i, LudicTokens.NUMBER)
            return
        }
        // @deterministic is one token: the sigil never stands alone
        if (c == '@' && isIdStart(at(i + 1))) {
            i++
            while (i < endOffset && isIdPart(at(i))) i++
            emit(i, LudicTokens.ANNOTATION)
            return
        }
        if (isIdStart(c)) {
            while (i < endOffset && isIdPart(at(i))) i++
            val word = buffer.subSequence(tokenStart, i).toString()
            val type = when {
                manifest && word in LudicVocabulary.MANIFEST -> LudicTokens.MANIFEST_KEYWORD
                word == "true" || word == "false" -> LudicTokens.BOOLEAN
                word in LudicVocabulary.PRIMITIVES -> LudicTokens.PRIMITIVE
                word in LudicVocabulary.PHASES -> LudicTokens.PHASE
                word in LudicVocabulary.CONTEXTUAL && isNamePosition(i) -> LudicTokens.IDENTIFIER
                word in LudicVocabulary.DECL -> LudicTokens.DECL_KEYWORD
                word in LudicVocabulary.CLAUSE -> LudicTokens.CLAUSE
                word in LudicVocabulary.STMT -> LudicTokens.KEYWORD
                word in LudicVocabulary.BUILTINS -> LudicTokens.BUILTIN
                word[0].isUpperCase() -> LudicTokens.TYPE_NAME
                else -> LudicTokens.IDENTIFIER
            }
            emit(i, type)
            return
        }
        // two-character operators before one-character ones
        val two = if (i + 1 < endOffset) buffer.subSequence(i, i + 2).toString() else ""
        if (two in TWO_CHAR_OPS) {
            emit(i + 2, LudicTokens.OPERATOR)
            return
        }
        when (c) {
            '{' -> { emit(i + 1, LudicTokens.LBRACE); return }
            '}' -> { emit(i + 1, LudicTokens.RBRACE); return }
            '[' -> { emit(i + 1, LudicTokens.LBRACKET); return }
            ']' -> { emit(i + 1, LudicTokens.RBRACKET); return }
            '(' -> { emit(i + 1, LudicTokens.LPAREN); return }
            ')' -> { emit(i + 1, LudicTokens.RPAREN); return }
            ',' -> { emit(i + 1, LudicTokens.COMMA); return }
        }
        if (c in SINGLE_CHAR_OPS) {
            emit(i + 1, LudicTokens.OPERATOR)
            return
        }
        emit(i + 1, LudicTokens.BAD)
    }

    /** One run of template text, an escape, a hole opener or the closing backtick. */
    private fun lexTemplateText() {
        tokenStart = tokenEnd
        if (tokenStart >= endOffset) { tokenType = null; return }
        var i = tokenStart
        val c = at(i)
        when {
            c == '`' -> { mode = MODE_CODE; emit(i + 1, LudicTokens.TEMPLATE_QUOTE); return }
            (c == '{' && at(i + 1) == '{') || (c == '}' && at(i + 1) == '}') -> { emit(i + 2, LudicTokens.TEMPLATE_ESCAPE); return }
            c == '{' -> { mode = MODE_HOLE; holeDepth = 0; emit(i + 1, LudicTokens.TEMPLATE_HOLE_START); return }
            c == '\\' && i + 1 < endOffset -> { emit(i + 2, LudicTokens.TEMPLATE_ESCAPE); return }
        }
        while (i < endOffset) {
            val d = at(i)
            if (d == '`' || d == '{' || d == '\\' || (d == '}' && at(i + 1) == '}')) break
            i++
        }
        emit(maxOf(i, tokenStart + 1), LudicTokens.TEMPLATE_TEXT)
    }

    private fun emit(end: Int, type: IElementType) {
        tokenEnd = end
        tokenType = type
    }

    companion object {
        const val MODE_CODE = 0
        const val MODE_TEXT = 1
        const val MODE_HOLE = 2
        const val PREV_START = 0         // file start, `{`, `}`, `;`: a declaration may begin
        const val PREV_OTHER = 1
        const val PREV_NAME_BEFORE = 2   // `.`, an operator, `(`, `var`, `let`, `return`: a name follows
        val TWO_CHAR_OPS = setOf("->", "+=", "-=", "*=", "/=", "==", "!=", "<=", ">=", "<<", ">>", "..", "=>")
        const val SINGLE_CHAR_OPS = "+-*/%<>=:.!@;&|^~"
    }
}
