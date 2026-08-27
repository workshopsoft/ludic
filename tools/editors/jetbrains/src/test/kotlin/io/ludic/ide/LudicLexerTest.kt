package io.ludic.ide

import com.intellij.psi.TokenType
import com.intellij.psi.tree.IElementType
import org.junit.Assert.assertEquals
import org.junit.Assert.assertTrue
import org.junit.Test

/**
 * Syntax highlighting is the lexer plus a colour map, so this is where a
 * highlighting regression actually shows up. These are plain JUnit tests: the
 * lexer has no platform dependencies, so they run in milliseconds without
 * booting an IDE.
 */
class LudicLexerTest {

    private fun lex(text: String): List<Pair<IElementType, String>> {
        val lexer = LudicLexer()
        lexer.start(text, 0, text.length, 0)
        val out = mutableListOf<Pair<IElementType, String>>()
        while (true) {
            val t = lexer.tokenType ?: break
            if (t != TokenType.WHITE_SPACE) {
                out += t to text.substring(lexer.tokenStart, lexer.tokenEnd)
            }
            lexer.advance()
        }
        return out
    }

    private fun typesOf(text: String) = lex(text).map { it.first }

    @Test
    fun `declaration keywords are distinct from statement keywords`() {
        assertEquals(
            listOf(LudicTokens.DECL_KEYWORD, LudicTokens.TYPE_NAME, LudicTokens.BRACE),
            typesOf("game Hello {")
        )
        assertEquals(LudicTokens.KEYWORD, typesOf("if x { }").first())
    }

    @Test
    fun `clause keywords are their own class`() {
        // `phase` and `query` colour differently from `if`/`let`, which is the
        // whole reason a system signature reads as a signature.
        assertEquals(
            listOf(LudicTokens.DECL_KEYWORD, LudicTokens.TYPE_NAME, LudicTokens.CLAUSE, LudicTokens.PHASE),
            typesOf("system Move phase FixedUpdate")
        )
    }

    @Test
    fun `primitive types and phases are not plain identifiers`() {
        assertEquals(LudicTokens.PRIMITIVE, typesOf("int").single())
        assertEquals(LudicTokens.PRIMITIVE, typesOf("fixed").single())
        assertEquals(LudicTokens.PHASE, typesOf("LateUpdate").single())
        assertEquals(LudicTokens.BOOLEAN, typesOf("true").single())
    }

    @Test
    fun `builtins are recognised, unknown calls are not`() {
        assertEquals(LudicTokens.BUILTIN, typesOf("rng_chance").single())
        assertEquals(LudicTokens.BUILTIN, typesOf("peek32").single())   // intrinsic
        assertEquals(LudicTokens.IDENTIFIER, typesOf("my_helper").single())
    }

    @Test
    fun `capitalised words read as type names`() {
        assertEquals(LudicTokens.TYPE_NAME, typesOf("Pos").single())
        assertEquals(LudicTokens.IDENTIFIER, typesOf("pos").single())
    }

    @Test
    fun `comments run to end of line and keep their text`() {
        val toks = lex("let a = 1  # keep me\nlet b = 2")
        val comment = toks.first { it.first == LudicTokens.COMMENT }
        assertEquals("# keep me", comment.second)
        // the newline ends it: the next line is code again
        assertEquals(LudicTokens.KEYWORD, toks[toks.indexOf(comment) + 1].first)
    }

    @Test
    fun `strings handle escapes and do not swallow the rest of the file`() {
        val toks = lex(""""a\"b" 42""")
        assertEquals(LudicTokens.STRING, toks[0].first)
        assertEquals(""""a\"b"""", toks[0].second)
        assertEquals(LudicTokens.NUMBER, toks[1].first)
    }

    @Test
    fun `an unterminated string stops at the newline`() {
        // A half-typed string must not colour the whole rest of the file.
        val toks = lex("let s = \"oops\nlet t = 1")
        assertEquals(LudicTokens.STRING, toks[3].first)
        assertEquals("\"oops", toks[3].second)
        assertEquals(LudicTokens.KEYWORD, toks[4].first)
    }

    @Test
    fun `numbers cover hex, fixed-point and the range operator`() {
        assertEquals(LudicTokens.NUMBER, typesOf("0x1affff").single())
        assertEquals(LudicTokens.NUMBER, typesOf("1.5").single())
        // `0..10` is two ints and a range op, not a malformed float
        assertEquals(
            listOf(LudicTokens.NUMBER, LudicTokens.OPERATOR, LudicTokens.NUMBER),
            typesOf("0..10")
        )
        assertEquals("..", lex("0..10")[1].second)
    }

    @Test
    fun `annotations lex as one token including the sigil`() {
        val toks = lex("@deterministic")
        assertEquals(LudicTokens.ANNOTATION, toks.single().first)
        assertEquals("@deterministic", toks.single().second)
    }

    @Test
    fun `two-character operators beat one-character ones`() {
        assertEquals(listOf("->"), lex("->").map { it.second })
        assertEquals(listOf("=>"), lex("=>").map { it.second })
        assertEquals(listOf("!="), lex("!=").map { it.second })
        assertEquals(listOf("<="), lex("<=").map { it.second })
    }

    @Test
    fun `the lexer always terminates and covers every character`() {
        // The IDE lexes half-typed text constantly; a lexer that stalls hangs
        // the editor, and one that skips bytes corrupts every offset after it.
        val nasty = "game X { component ¿ { a: int = ' } # é\n query [{Tag}] \"unclosed"
        val lexer = LudicLexer()
        lexer.start(nasty, 0, nasty.length, 0)
        var covered = 0
        var guard = 0
        while (lexer.tokenType != null) {
            assertTrue("token must advance", lexer.tokenEnd > lexer.tokenStart)
            assertEquals("no gaps between tokens", covered, lexer.tokenStart)
            covered = lexer.tokenEnd
            lexer.advance()
            check(guard++ < 10_000) { "lexer did not terminate" }
        }
        assertEquals("every character consumed", nasty.length, covered)
    }

    @Test
    fun `a real source file lexes with no bad characters`() {
        val src = """
            game Hello {
              component Pos { x: int = 0, y: int = 0 }
              archetype Mob { Pos }

              system Move phase FixedUpdate
                query (p) [Pos, {Player}] where p.x > 0
              {
                p.x = p.x + 1
                for i in 0 .. 10 { print_int(i) }
              }

              ui Menu {
                panel id=Root w=288 pad=16 {
                  button id=Go text="Go" size=16
                }
              }
            }
        """.trimIndent()
        val bad = lex(src).filter { it.first == LudicTokens.BAD }
        assertTrue("unexpected bad characters: ${bad.map { it.second }}", bad.isEmpty())
    }
}
