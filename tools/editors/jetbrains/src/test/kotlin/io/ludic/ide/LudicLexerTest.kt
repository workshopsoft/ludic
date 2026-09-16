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
            listOf(LudicTokens.DECL_KEYWORD, LudicTokens.TYPE_NAME, LudicTokens.LBRACE),
            typesOf("program Hello {")
        )
        assertEquals(LudicTokens.KEYWORD, typesOf("if x { }").first())
    }

    @Test
    fun `clause keywords are their own class`() {
        // `phase` and `query` colour differently from `if`/`let`, which is the
        // whole reason a handler signature reads as a signature.
        assertEquals(
            listOf(LudicTokens.DECL_KEYWORD, LudicTokens.TYPE_NAME, LudicTokens.CLAUSE, LudicTokens.PHASE),
            typesOf("handler Move phase FixedUpdate")
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
        assertEquals(LudicTokens.BUILTIN, typesOf("arg_count").single())   // intrinsic
        assertEquals(LudicTokens.IDENTIFIER, typesOf("my_helper").single())
    }

    @Test
    fun `declaration words used as names are names`() {
        // the compiler reserves these only as function names
        assertEquals(LudicTokens.IDENTIFIER, lex("var model = look_model(x)")[1].first)
        assertEquals(LudicTokens.IDENTIFIER, lex("  model: Model,")[0].first)
        assertEquals(LudicTokens.IDENTIFIER, lex("a.model = m")[2].first)
        assertEquals(LudicTokens.IDENTIFIER, lex("if model == null { }")[1].first)
        assertEquals(LudicTokens.IDENTIFIER, lex("f(model, 1)")[2].first)
        assertEquals(LudicTokens.DECL_KEYWORD, lex("model Actor {")[0].first)
        assertEquals(LudicTokens.DECL_KEYWORD, lex("{\n  model Score { a: int }")[1].first)
        assertEquals(LudicTokens.CLAUSE, lex("for (p) in query [Pos] { }").first { it.second == "query" }.first)
        assertEquals(LudicTokens.DECL_KEYWORD, lex("@On(Hit) handler Armor { }").first { it.second == "handler" }.first)
    }

    @Test
    fun `restarting mid-file with the saved state lexes the same`() {
        val text = "program X {\n  var model = 1\n  model Foo { model: int }\n}"
        val full = LudicLexer()
        full.start(text, 0, text.length, 0)
        val states = mutableListOf<Triple<Int, Int, IElementType>>()
        while (full.tokenType != null) { states += Triple(full.tokenStart, full.state, full.tokenType!!); full.advance() }
        for ((start, state, _) in states) {
            val part = LudicLexer()
            part.start(text, start, text.length, state)
            val rest = states.filter { it.first >= start }.map { it.third }
            val got = mutableListOf<IElementType>()
            while (part.tokenType != null) { got += part.tokenType!!; part.advance() }
            assertEquals("restart at $start", rest, got)
        }
    }

    @Test
    fun `template strings lex their holes as code`() {
        val toks = lex("push(lods, gltf_load(dir, \"rock.gltf\", `rock_{variant}_LOD{k}`))")
        val t = toks.dropWhile { it.first != LudicTokens.TEMPLATE_QUOTE }
        assertEquals(
            listOf(
                LudicTokens.TEMPLATE_QUOTE to "`", LudicTokens.TEMPLATE_TEXT to "rock_",
                LudicTokens.TEMPLATE_HOLE_START to "{", LudicTokens.IDENTIFIER to "variant", LudicTokens.TEMPLATE_HOLE_END to "}",
                LudicTokens.TEMPLATE_TEXT to "_LOD",
                LudicTokens.TEMPLATE_HOLE_START to "{", LudicTokens.IDENTIFIER to "k", LudicTokens.TEMPLATE_HOLE_END to "}",
                LudicTokens.TEMPLATE_QUOTE to "`", LudicTokens.RPAREN to ")", LudicTokens.RPAREN to ")",
            ),
            t
        )
    }

    @Test
    fun `template escapes, nested braces and strings in holes`() {
        val toks = lex("`a {{b}} \\n {Pos { x: 1 }.x} {f(\"}\")}`")
        assertEquals(2, toks.count { it.first == LudicTokens.TEMPLATE_QUOTE })
        assertEquals(listOf("{{", "}}", "\\n"), toks.filter { it.first == LudicTokens.TEMPLATE_ESCAPE }.map { it.second })
        assertEquals(listOf(LudicTokens.LBRACE, LudicTokens.RBRACE), toks.filter { it.first == LudicTokens.LBRACE || it.first == LudicTokens.RBRACE }.map { it.first })
        assertEquals(2, toks.count { it.first == LudicTokens.TEMPLATE_HOLE_END })
        assertEquals("\"}\"", toks.single { it.first == LudicTokens.STRING }.second)
        // code after the template is code again
        val after = lex("`x {y}` let z = 1")
        assertEquals(LudicTokens.KEYWORD, after.first { it.second == "let" }.first)
    }

    @Test
    fun `a multi-line template restarts correctly mid-text`() {
        val text = "let s = `one {a}\ntwo {b} three`\nlet t = 1"
        val full = LudicLexer()
        full.start(text, 0, text.length, 0)
        val all = mutableListOf<Triple<Int, Int, IElementType>>()
        while (full.tokenType != null) { all += Triple(full.tokenStart, full.state, full.tokenType!!); full.advance() }
        for ((start, state, _) in all) {
            val part = LudicLexer()
            part.start(text, start, text.length, state)
            val got = mutableListOf<IElementType>()
            while (part.tokenType != null) { got += part.tokenType!!; part.advance() }
            assertEquals("restart at $start", all.filter { it.first >= start }.map { it.third }, got)
        }
        assertEquals(LudicTokens.KEYWORD, lex(text).last { it.second == "let" }.first)
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
        val nasty = "program X { property ¿ { a: int = ' } # é\n query [{Tag}] \"unclosed"
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
            program Hello {
              property Pos { x: int = 0, y: int = 0 }
              model Mob { a: int, b: fixed }

              handler Move phase FixedUpdate {
                for (p) in query [Pos] where p.x > 0 {
                  p.x = p.x + 1
                  Screen.fill_rectangle(x: p.x, y: 0, width: 4, height: 4, color: Color.White)
                }
                for i in 0 .. 10 { print(string(i)) }
              }

              test "adds" { expect_eq(1 + 1, 2) }

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
