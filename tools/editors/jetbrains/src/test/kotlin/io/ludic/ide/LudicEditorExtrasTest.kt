package io.ludic.ide

import com.intellij.testFramework.fixtures.BasePlatformTestCase
import io.ludic.ide.editor.LudicColorPreview
import io.ludic.ide.editor.LudicDocPageDocumentation
import io.ludic.ide.editor.LudicPalette
import io.ludic.ide.editor.LudicSemanticColors
import java.awt.Color
import java.io.File

/** Colour swatches, semantic colours and the reference-page documentation. */
class LudicEditorExtrasTest : BasePlatformTestCase() {

    fun testHexIntsHexStringsAndPaletteNamesHaveSwatches() {
        val file = myFixture.configureByText("c.ludic", "Screen.clear(0x0d1020)\nScreen.clear(Color.Crimson)\nlet mask = 0xff\n")
        val provider = LudicColorPreview()
        val hex = file.findElementAt(file.text.indexOf("0x0d"))!!
        assertEquals(Color(0x0d1020), provider.getColorFrom(hex))
        val named = file.findElementAt(file.text.indexOf("Crimson"))!!
        assertEquals(Color(LudicPalette.lookup("Crimson")!!.toInt(16)), provider.getColorFrom(named))
        assertNull("a short hex is a mask, not a colour", provider.getColorFrom(file.findElementAt(file.text.indexOf("0xff"))!!))
        val man = myFixture.configureByText("package.ludic", "app splash_bg \"#0b1622\"\n")
        assertEquals(Color(0x0b1622), provider.getColorFrom(man.findElementAt(man.text.indexOf("\"#"))!!))
    }

    fun testPickingAColourRewritesTheLiteral() {
        val file = myFixture.configureByText("c.ludic", "Screen.clear(Color.Crimson)\n")
        LudicColorPreview().setColorTo(file.findElementAt(file.text.indexOf("Crimson"))!!, Color(0x123456))
        assertEquals("Screen.clear(0x123456)\n", myFixture.editor.document.text)
    }

    fun testPaletteIsBundled() {
        assertTrue(LudicPalette.all().size > 200)
    }

    fun testSemanticTokensMapToLudicKeys() {
        assertSame(LudicColors.FUNCTION_BUILTIN, LudicSemanticColors.keyFor("function", listOf("defaultLibrary")))
        assertSame(LudicColors.FUNCTION_PACKAGE, LudicSemanticColors.keyFor("function", listOf("vendor")))
        assertSame(LudicColors.FUNCTION_DECLARATION, LudicSemanticColors.keyFor("function", listOf("declaration")))
        assertSame(LudicColors.FUNCTION_CALL, LudicSemanticColors.keyFor("function", emptyList()))
        assertSame(LudicColors.HANDLER, LudicSemanticColors.keyFor("function", listOf("readonly", "declaration")))
        assertSame(LudicColors.CONSTANT_PACKAGE, LudicSemanticColors.keyFor("variable", listOf("readonly", "static", "vendor")))
        assertSame(LudicColors.GLOBAL_VARIABLE, LudicSemanticColors.keyFor("variable", listOf("static")))
        assertSame(LudicColors.LOCAL_VARIABLE, LudicSemanticColors.keyFor("variable", emptyList()))
        assertSame(LudicColors.NAMESPACE_BUILTIN, LudicSemanticColors.keyFor("namespace", listOf("defaultLibrary")))
        assertNull("keywords keep the lexer's colour", LudicSemanticColors.keyFor("keyword", emptyList()))
    }

    fun testReferencePagesRenderAsDocumentation() {
        val md = "---\nid: type-void\nname: void\nkind: type\nsig: void\ntip: No value.\n---\n\n`void` is what a function returns when it returns nothing.\n\n```ludic\n# doc-check: skip\nfunction f() -> void { }\n```\n"
        val page = LudicDocPageDocumentation.parse(File("/x/docs/language/types/type-void.md"), md)!!
        assertEquals("void", page.meta["sig"])
        val html = LudicDocPageDocumentation.markdownToHtml(page.body)
        assertTrue(html, html.contains("<code>void</code> is what a function returns"))
        assertTrue(html, html.contains("function f() -&gt; void"))
        assertFalse(html, html.contains("doc-check"))
        assertFalse(html, html.contains("---"))
    }
}
