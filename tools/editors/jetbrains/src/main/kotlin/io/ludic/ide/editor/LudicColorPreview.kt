package io.ludic.ide.editor

import com.intellij.openapi.command.WriteCommandAction
import com.intellij.openapi.editor.ElementColorProvider
import com.intellij.openapi.util.TextRange
import com.intellij.psi.PsiDocumentManager
import com.intellij.psi.PsiElement
import com.intellij.psi.TokenType
import com.intellij.psi.util.PsiTreeUtil
import com.intellij.psi.util.elementType
import io.ludic.ide.LudicTokens
import java.awt.Color

/**
 * Colour swatches in the gutter, with the colour picker behind them, for the
 * three ways Ludic writes a colour:
 *
 *   Screen.clear(0x0d1020)        a 0xRRGGBB int
 *   Screen.clear(Color.Crimson)   a palette name (docs/language/colors/palette.json)
 *   app splash_bg "#0b1622"       a CSS-style string (package.ludic)
 *
 * Picking a new colour rewrites the literal; a palette name becomes the hex int
 * it now is.
 */
class LudicColorPreview : ElementColorProvider {

    override fun getColorFrom(element: PsiElement): Color? {
        if (element.firstChild != null) return null
        return when (element.elementType) {
            LudicTokens.NUMBER -> HEX_INT.matchEntire(element.text)?.let { rgb(it.groupValues[1]) }
            LudicTokens.STRING -> HEX_STRING.matchEntire(element.text)?.let { rgb(expand(it.groupValues[1])) }
            LudicTokens.IDENTIFIER, LudicTokens.TYPE_NAME -> paletteName(element)?.let { LudicPalette.lookup(it)?.let(::rgb) }
            else -> null
        }
    }

    override fun setColorTo(element: PsiElement, color: Color) {
        val file = element.containingFile ?: return
        val doc = PsiDocumentManager.getInstance(element.project).getDocument(file) ?: return
        val hex = "%02x%02x%02x".format(color.red, color.green, color.blue)
        val (range, text) = when (element.elementType) {
            LudicTokens.NUMBER -> element.textRange to "0x$hex"
            LudicTokens.STRING -> element.textRange to "\"#$hex\""
            else -> {
                // `Color.Crimson` -> `0xrrggbb`
                val start = paletteReceiver(element)?.textRange?.startOffset ?: return
                TextRange(start, element.textRange.endOffset) to "0x$hex"
            }
        }
        WriteCommandAction.runWriteCommandAction(element.project, "Change Colour", null, {
            doc.replaceString(range.startOffset, range.endOffset, text)
            PsiDocumentManager.getInstance(element.project).commitDocument(doc)
        }, file)
    }

    private fun paletteName(element: PsiElement): String? =
        if (paletteReceiver(element) != null) element.text else null

    /** The `Color` of `Color.Name`, when element is the Name. */
    private fun paletteReceiver(element: PsiElement): PsiElement? {
        val dot = prevSignificant(element) ?: return null
        if (dot.elementType != LudicTokens.OPERATOR || dot.text != ".") return null
        val recv = prevSignificant(dot) ?: return null
        return if (recv.text == "Color") recv else null
    }

    private fun prevSignificant(e: PsiElement): PsiElement? {
        var p = PsiTreeUtil.prevLeaf(e)
        while (p != null && p.elementType == TokenType.WHITE_SPACE) p = PsiTreeUtil.prevLeaf(p)
        return p
    }

    private companion object {
        val HEX_INT = Regex("0[xX]([0-9a-fA-F]{6})")
        val HEX_STRING = Regex("\"#([0-9a-fA-F]{6}|[0-9a-fA-F]{3})\"")

        fun expand(h: String) = if (h.length == 3) h.map { "$it$it" }.joinToString("") else h
        fun rgb(hex: String) = Color(hex.toInt(16))
    }
}

/** The named colours `Color.*` resolves, from the palette the docs are generated from. */
object LudicPalette {
    private val names: Map<String, String> by lazy { load() }

    fun lookup(name: String): String? = names[name]
    fun all(): Map<String, String> = names

    private fun load(): Map<String, String> {
        val text = LudicPalette::class.java.getResourceAsStream("/palette.json")?.bufferedReader()?.readText() ?: return emptyMap()
        return parse(text)
    }

    fun parse(json: String): Map<String, String> =
        Regex("\"name\"\\s*:\\s*\"([^\"]+)\"\\s*,\\s*\"hex\"\\s*:\\s*\"([0-9A-Fa-f]{6})\"")
            .findAll(json).associate { it.groupValues[1] to it.groupValues[2] }
}
