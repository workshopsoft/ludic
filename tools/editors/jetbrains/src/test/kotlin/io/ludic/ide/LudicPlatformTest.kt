package io.ludic.ide

import com.intellij.lang.LanguageParserDefinitions
import com.intellij.openapi.fileTypes.FileTypeManager
import com.intellij.psi.PsiFile
import com.intellij.testFramework.fixtures.BasePlatformTestCase

/**
 * The IDE-side wiring, exercised in a real (headless) platform fixture. These
 * cover the things that make a file feel like a supported language rather than
 * plain text: the extension is claimed, a PSI tree is built (which is what
 * indexing and Markdown injection both stand on), folds appear, braces pair up
 * and Ctrl+/ comments.
 */
class LudicPlatformTest : BasePlatformTestCase() {

    private val sample = """
        program Hello {
          property Pos { x: int = 0, y: int = 0 }
          model Mob { hp: int }

          # move everything that has a position
          handler Move phase FixedUpdate {
            for (p) in query [Pos] {
              p.x = p.x + 1
            }
          }
        }
    """.trimIndent()

    private fun ludicFile(text: String = sample): PsiFile =
        myFixture.configureByText("sample.ludic", text)

    fun testExtensionIsClaimedByTheLudicFileType() {
        val type = FileTypeManager.getInstance().getFileTypeByExtension("ludic")
        assertEquals("Ludic", type.name)
        assertEquals(LudicFileType, type)
    }

    fun testFileTypeIsNotBinaryAndUsesUtf8() {
        assertFalse(LudicFileType.isBinary)
        assertEquals("ludic", LudicFileType.defaultExtension)
    }

    fun testParserDefinitionIsRegisteredForTheLanguage() {
        // Markdown fence injection needs a PSI tree, so this registration is
        // what makes ```ludic blocks highlight in a .md file.
        val def = LanguageParserDefinitions.INSTANCE.forLanguage(LudicLanguage)
        assertNotNull("no ParserDefinition registered for Ludic", def)
    }

    fun testPsiTreeIsBuiltAndCoversTheWholeFile() {
        val file = ludicFile()
        assertEquals(LudicLanguage, file.language)
        assertEquals(sample, file.text)
        assertTrue("expected a non-empty PSI tree", file.children.isNotEmpty())
        // every character must be reachable through the tree, or offsets drift
        assertEquals(sample.length, file.textLength)
    }

    fun testHighlighterAssignsColoursToEveryMeaningfulToken() {
        val highlighter = LudicSyntaxHighlighter()
        val coloured = listOf(
            LudicTokens.DECL_KEYWORD, LudicTokens.KEYWORD, LudicTokens.CLAUSE,
            LudicTokens.PRIMITIVE, LudicTokens.PHASE, LudicTokens.BOOLEAN,
            LudicTokens.BUILTIN, LudicTokens.TYPE_NAME, LudicTokens.STRING,
            LudicTokens.NUMBER, LudicTokens.COMMENT, LudicTokens.ANNOTATION,
            LudicTokens.OPERATOR, LudicTokens.LBRACE, LudicTokens.RBRACE, LudicTokens.LBRACKET,
            LudicTokens.RBRACKET, LudicTokens.LPAREN, LudicTokens.RPAREN, LudicTokens.COMMA,
            LudicTokens.IDENTIFIER, LudicTokens.MANIFEST_KEYWORD
        )
        for (token in coloured) {
            val keys = highlighter.getTokenHighlights(token)
            assertTrue("no colour mapped for $token", keys.isNotEmpty())
        }
    }

    fun testFoldingCollapsesMultiLineBlocksOnly() {
        val file = ludicFile()
        val regions = LudicFoldingBuilder().buildFoldRegions(file.node, file.viewProvider.document!!)

        // The sample has exactly three blocks that span lines: the `program`
        // body, the `handler` body and the `for` loop. `property Pos { … }` and
        // `model Mob { … }` fit on one line, and folding a single line gains
        // nothing, so they are deliberately skipped.
        assertEquals("multi-line blocks only", 3, regions.size)

        val outermost = regions.maxByOrNull { it.range.length }!!
        assertEquals("outermost fold starts at the program block's brace",
            sample.indexOf('{'), outermost.range.startOffset)
        assertEquals("outermost fold ends at the last brace",
            sample.length, outermost.range.endOffset)

        for (r in regions) {
            assertTrue("fold region must be non-empty", r.range.length > 0)
            assertEquals("{...}", LudicFoldingBuilder().getPlaceholderText(file.node))
        }
    }

    fun testCommenterUsesHashWithASpace() {
        // No trailing space in the prefix: the code style's "add a space"
        // option supplies it, so Ctrl+/ gives "# code" and not "#  code".
        val commenter = LudicCommenter()
        assertEquals("#", commenter.lineCommentPrefix)
        assertNull("Ludic has no block comments", commenter.blockCommentPrefix)
    }

    fun testBraceMatcherPairsEveryBracketKind() {
        val matcher = LudicBraceMatcher()
        val pairs = matcher.pairs
        val open = pairs.map { it.leftBraceType }.toSet()
        assertEquals(setOf(LudicTokens.LBRACE, LudicTokens.LBRACKET, LudicTokens.LPAREN, LudicTokens.TEMPLATE_HOLE_START), open)
        assertEquals(setOf(LudicTokens.RBRACE, LudicTokens.RBRACKET, LudicTokens.RPAREN, LudicTokens.TEMPLATE_HOLE_END), pairs.map { it.rightBraceType }.toSet())
    }

    fun testHalfTypedFileStillProducesAPsiTree() {
        // The IDE must survive what a file looks like mid-keystroke; a parser
        // that throws here takes highlighting and indexing down with it.
        val broken = "program X {\n  property P { x: int =\n  handler"
        val file = myFixture.configureByText("broken.ludic", broken)
        assertEquals(broken.length, file.textLength)
        assertEquals(LudicLanguage, file.language)
    }
}
