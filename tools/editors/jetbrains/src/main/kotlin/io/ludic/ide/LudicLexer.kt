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
 * It must never throw and never fail to advance: the IDE lexes half-typed text
 * constantly, so anything unrecognised becomes one BAD character and the scan
 * carries on.
 */
class LudicLexer : LexerBase() {
    private var buffer: CharSequence = ""
    private var startOffset = 0
    private var endOffset = 0
    private var tokenStart = 0
    private var tokenEnd = 0
    private var tokenType: IElementType? = null

    override fun start(buffer: CharSequence, startOffset: Int, endOffset: Int, initialState: Int) {
        this.buffer = buffer
        this.startOffset = startOffset
        this.endOffset = endOffset
        this.tokenStart = startOffset
        this.tokenEnd = startOffset
        advance()
    }

    override fun getState() = 0
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
                word == "true" || word == "false" -> LudicTokens.BOOLEAN
                word in LudicVocabulary.PRIMITIVES -> LudicTokens.PRIMITIVE
                word in LudicVocabulary.PHASES -> LudicTokens.PHASE
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
            '{', '}' -> { emit(i + 1, LudicTokens.BRACE); return }
            '[', ']' -> { emit(i + 1, LudicTokens.BRACKET); return }
            '(', ')' -> { emit(i + 1, LudicTokens.PAREN); return }
            ',' -> { emit(i + 1, LudicTokens.COMMA); return }
        }
        if (c in SINGLE_CHAR_OPS) {
            emit(i + 1, LudicTokens.OPERATOR)
            return
        }
        emit(i + 1, LudicTokens.BAD)
    }

    private fun emit(end: Int, type: IElementType) {
        tokenEnd = end
        tokenType = type
    }

    private companion object {
        val TWO_CHAR_OPS = setOf("->", "+=", "-=", "*=", "/=", "==", "!=", "<=", ">=", "<<", ">>", "..", "=>")
        const val SINGLE_CHAR_OPS = "+-*/%<>=:.!@;&|^~"
    }
}
