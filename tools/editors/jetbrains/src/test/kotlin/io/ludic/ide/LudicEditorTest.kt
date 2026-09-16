package io.ludic.ide

import com.intellij.application.options.CodeStyle
import com.intellij.codeInsight.template.impl.TemplateManagerImpl
import com.intellij.codeInsight.template.impl.TemplateSettings
import com.intellij.ide.fileTemplates.FileTemplateManager
import com.intellij.openapi.actionSystem.IdeActions
import com.intellij.openapi.options.colors.ColorSettingsPages
import com.intellij.psi.search.PsiTodoSearchHelper
import com.intellij.testFramework.fixtures.BasePlatformTestCase
import io.ludic.ide.editor.CreateLudicFileAction
import io.ludic.ide.editor.LudicColorSettingsPage
import io.ludic.ide.editor.LudicIndenter

/**
 * Typing in a .ludic file: indentation, closers, quotes, comments, templates.
 * Each test drives the real editor actions in a headless fixture, so these
 * fail when an extension is registered wrongly, not only when the logic is.
 */
class LudicEditorTest : BasePlatformTestCase() {

    private fun type(before: String, typed: String, after: String) {
        myFixture.configureByText("t.ludic", before)
        myFixture.type(typed)
        val doc = myFixture.editor.document.text
        val caret = myFixture.editor.caretModel.offset
        assertEquals(after, doc.substring(0, caret) + "<caret>" + doc.substring(caret))
    }

    fun testEnterAfterAnOpeningBraceIndentsOneLevel() {
        type(
            "program X {<caret>\n}",
            "\n",
            "program X {\n  <caret>\n}"
        )
    }

    fun testEnterInsideNestedBlocksFollowsTheOpenersLine() {
        type(
            "program X {\n  handler H phase Update {\n    for (p) in query [Pos] {<caret>\n    }\n  }\n}",
            "\n",
            "program X {\n  handler H phase Update {\n    for (p) in query [Pos] {\n      <caret>\n    }\n  }\n}"
        )
    }

    fun testEnterAfterAPlainStatementKeepsTheDepth() {
        type(
            "program X {\n  entry {\n    let a = 1<caret>\n  }\n}",
            "\n",
            "program X {\n  entry {\n    let a = 1\n    <caret>\n  }\n}"
        )
    }

    fun testBracesInStringsAndCommentsDoNotCount() {
        val text = "program X {\n  let s = \"{{{\"  # {\n"
        assertEquals("  ", LudicIndenter.indentFor(text, text.length, "  "))
    }

    fun testTypingAClosingBraceDedentsTheLine() {
        type(
            "program X {\n  entry {\n    let a = 1\n    <caret>\n}",
            "}",
            "program X {\n  entry {\n    let a = 1\n  }<caret>\n}"
        )
    }

    fun testAClosingBraceAfterCodeIsLeftAlone() {
        type(
            "program X {\n  entry { let a = 1 <caret>\n}",
            "}",
            "program X {\n  entry { let a = 1 }<caret>\n}"
        )
    }

    fun testQuotesAndBracketsPairUp() {
        type("program X {\n  let s = <caret>\n}", "\"", "program X {\n  let s = \"<caret>\"\n}")
        type("program X {\n  f<caret>\n}", "(", "program X {\n  f(<caret>)\n}")
        type("program X {\n  let a = <caret>\n}", "[", "program X {\n  let a = [<caret>]\n}")
    }

    fun testBackticksPairAndHolesMatch() {
        type("program X {\n  let s = <caret>\n}", "`", "program X {\n  let s = `<caret>`\n}")
    }

    fun testLineCommentActionUsesHash() {
        myFixture.configureByText("t.ludic", "let a = 1<caret>\n")
        myFixture.performEditorAction(IdeActions.ACTION_COMMENT_LINE)
        assertEquals("# let a = 1\n", myFixture.editor.document.text)
    }

    fun testTodoCommentsAreIndexed() {
        val file = myFixture.configureByText("t.ludic", "# TODO: make it faster\nlet a = 1\n")
        val todos = PsiTodoSearchHelper.getInstance(project).findTodoItems(file)
        assertEquals(1, todos.size)
    }

    fun testManifestDirectivesHighlightOnlyInPackageLudic() {
        val manifest = LudicSyntaxHighlighterFactory().getSyntaxHighlighter(project, myFixture.configureByText("package.ludic", "require \"x\" \"1\"").virtualFile)
        val lexer = manifest.highlightingLexer
        lexer.start("require \"x\" \"1\"")
        assertEquals(LudicTokens.MANIFEST_KEYWORD, lexer.tokenType)

        val plain = LudicSyntaxHighlighterFactory().getSyntaxHighlighter(project, myFixture.configureByText("main.ludic", "require").virtualFile)
        val plainLexer = plain.highlightingLexer
        plainLexer.start("require")
        assertEquals(LudicTokens.IDENTIFIER, plainLexer.tokenType)
    }

    fun testColorSettingsPageIsRegisteredAndCoversEveryKey() {
        val page = ColorSettingsPages.getInstance().registeredPages.filterIsInstance<LudicColorSettingsPage>().single()
        val keys = page.attributeDescriptors.map { it.key }.toSet()
        for (field in LudicColors::class.java.declaredFields) {
            val value = runCatching { field.isAccessible = true; field.get(LudicColors) }.getOrNull()
            if (value is com.intellij.openapi.editor.colors.TextAttributesKey) {
                assertTrue("color key ${value.externalName} missing from the settings page", value in keys)
            }
        }
        // the demo text must lex cleanly, or the preview shows red
        val lexer = page.highlighter.highlightingLexer
        lexer.start(page.demoText)
        while (lexer.tokenType != null) {
            assertNotSame("bad character in demo text at ${lexer.tokenStart}", LudicTokens.BAD, lexer.tokenType)
            lexer.advance()
        }
    }

    fun testCodeStyleDefaultsToTwoSpaces() {
        val opts = CodeStyle.getSettings(project).getIndentOptions(LudicFileType)
        assertEquals(2, opts.INDENT_SIZE)
        assertFalse(opts.USE_TAB_CHARACTER)
    }

    fun testLiveTemplatesAreRegisteredAndExpand() {
        val template = TemplateSettings.getInstance().getTemplate("test", "Ludic")
        assertNotNull("the `test` live template is not registered", template)
        TemplateManagerImpl.setTemplateTesting(testRootDisposable)
        myFixture.configureByText("t.ludic", "program X {\n  test<caret>\n}")
        myFixture.performEditorAction(IdeActions.ACTION_EXPAND_LIVE_TEMPLATE_BY_TAB)
        assertTrue(myFixture.editor.document.text, myFixture.editor.document.text.contains("test \"it works\" {"))
    }

    fun testLiveTemplatesStayOutOfStringsAndComments() {
        myFixture.configureByText("t.ludic", "# test<caret>\n")
        myFixture.performEditorAction(IdeActions.ACTION_EXPAND_LIVE_TEMPLATE_BY_TAB)
        assertFalse(myFixture.editor.document.text.contains("it works"))
    }

    fun testNewFileTemplatesExistAndRenderAProgramName() {
        val mgr = FileTemplateManager.getInstance(project)
        for (name in listOf(CreateLudicFileAction.PROGRAM, CreateLudicFileAction.MODULE, CreateLudicFileAction.TEST, CreateLudicFileAction.EMPTY)) {
            val t = mgr.getInternalTemplate(name)
            assertEquals("ludic", t.extension)
        }
        val props = mgr.defaultProperties.apply {
            setProperty("NAME", "enemy_ai")
            setProperty("PROGRAM_NAME", CreateLudicFileAction.programName("enemy_ai"))
        }
        val text = mgr.getInternalTemplate(CreateLudicFileAction.PROGRAM).getText(props)
        assertTrue(text, text.contains("program EnemyAi {"))
        val lexer = LudicLexer()
        lexer.start(text)
        while (lexer.tokenType != null) {
            assertNotSame(LudicTokens.BAD, lexer.tokenType)
            lexer.advance()
        }
    }

    fun testProgramNamesFromFileNames() {
        assertEquals("EnemyAi", CreateLudicFileAction.programName("enemy_ai"))
        assertEquals("Hud", CreateLudicFileAction.programName("hud"))
        assertEquals("P2d", CreateLudicFileAction.programName("2d"))
        assertEquals("MyGame", CreateLudicFileAction.programName("my-game"))
    }
}
