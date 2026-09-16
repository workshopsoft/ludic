package io.ludic.ide.editor

import com.intellij.application.options.CodeStyleAbstractConfigurable
import com.intellij.application.options.CodeStyleAbstractPanel
import com.intellij.application.options.IndentOptionsEditor
import com.intellij.application.options.SmartIndentOptionsEditor
import com.intellij.application.options.TabbedLanguageCodeStylePanel
import com.intellij.lang.Language
import com.intellij.openapi.editor.colors.TextAttributesKey
import com.intellij.openapi.fileTypes.SyntaxHighlighter
import com.intellij.openapi.options.colors.AttributesDescriptor
import com.intellij.openapi.options.colors.ColorDescriptor
import com.intellij.openapi.options.colors.ColorSettingsPage
import com.intellij.psi.codeStyle.CodeStyleConfigurable
import com.intellij.psi.codeStyle.CodeStyleSettings
import com.intellij.psi.codeStyle.CommonCodeStyleSettings
import com.intellij.psi.codeStyle.LanguageCodeStyleSettingsProvider
import io.ludic.ide.LudicColors
import io.ludic.ide.LudicIcons
import io.ludic.ide.LudicLanguage
import io.ludic.ide.LudicSyntaxHighlighter
import javax.swing.Icon

private val SAMPLE = """
    # Bouncing balls: properties, a handler per phase, and a test.
    program Demo {
      import "ludic.render3d/r3d.ludic"

      property Pos { x: int = 0, y: int = 0 }
      model Score { value: int, best: int }
      enum Mode { Title, Playing }

      const SPEED: int = 2
      var g_mode: Mode = Mode.Title

      @deterministic
      handler Move phase FixedUpdate {
        for (p) in query [Pos] where p.x < 304 {
          p.x = p.x + SPEED
          if p.x > 0x130 { despawn(self) } else { print("moving") }
        }
      }

      function half(f: fixed) -> fixed { return f / 2 }

      test "half of one" {
        expect_near(half(fixed(1)), 32768, 0)
      }
    }
""".trimIndent()

// the sample with semantic tags, as the server would colour it
private val DEMO = """
    # Bouncing balls: properties, a handler per phase, and a test.
    program Demo {
      import "ludic.render3d/r3d.ludic"

      property <prop>Pos</prop> { <field>x</field>: int = 0, <field>y</field>: int = 0 }
      model <model>Score</model> { <field>value</field>: int, <field>best</field>: int }

      const <const>SPEED</const>: int = 2
      var <global>g_model</global>: int = 0

      @deterministic
      handler <handler>Move</handler> phase FixedUpdate {
        for (<local>p</local>) in query [<prop>Pos</prop>] where <local>p</local>.<field>x</field> < 304 {
          let <local>model</local> = <fpkg>f_clamp</fpkg>(<local>p</local>.<field>x</field>, 0, 0x130)
          <local>p</local>.<field>x</field> = <fcall>half</fcall>(<local>model</local>) + <const>SPEED</const>
          <fbuiltin>print</fbuiltin>(`x is {<local>p</local>.<field>x</field>} of {{304}}`)
          <fbuiltin>print</fbuiltin>(`x is {<local>p</local>.<field>x</field>} of {{304}}\n`)
          <ns>Screen</ns>.<fbuiltin>clear</fbuiltin>(<ns>Color</ns>.<cbuiltin>Crimson</cbuiltin>)
        }
      }

      function <fdecl>half</fdecl>(<param>f</param>: fixed) -> fixed { return <param>f</param> / 2 }

      test "half of one" {
        <fbuiltin>expect_near</fbuiltin>(<fcall>half</fcall>(<fbuiltin>fixed</fbuiltin>(1)), 32768, 0)
      }
    }
""".trimIndent()

/** Settings | Editor | Color Scheme | Ludic */
class LudicColorSettingsPage : ColorSettingsPage {
    override fun getIcon(): Icon = LudicIcons.FILE
    override fun getHighlighter(): SyntaxHighlighter = LudicSyntaxHighlighter()
    override fun getDemoText() = DEMO
    override fun getAdditionalHighlightingTagToDescriptorMap(): Map<String, TextAttributesKey> = mapOf(
        "fdecl" to LudicColors.FUNCTION_DECLARATION,
        "fcall" to LudicColors.FUNCTION_CALL,
        "fpkg" to LudicColors.FUNCTION_PACKAGE,
        "fbuiltin" to LudicColors.FUNCTION_BUILTIN,
        "handler" to LudicColors.HANDLER,
        "const" to LudicColors.CONSTANT,
        "cbuiltin" to LudicColors.CONSTANT_BUILTIN,
        "global" to LudicColors.GLOBAL_VARIABLE,
        "local" to LudicColors.LOCAL_VARIABLE,
        "param" to LudicColors.PARAMETER,
        "field" to LudicColors.FIELD,
        "prop" to LudicColors.PROPERTY_TYPE,
        "model" to LudicColors.MODEL_TYPE,
        "ns" to LudicColors.NAMESPACE_BUILTIN,
    )
    override fun getColorDescriptors(): Array<ColorDescriptor> = ColorDescriptor.EMPTY_ARRAY
    override fun getDisplayName() = "Ludic"
    override fun getAttributeDescriptors(): Array<AttributesDescriptor> = arrayOf(
        AttributesDescriptor("Keywords//Declaration (program, property, handler, function…)", LudicColors.DECL_KEYWORD),
        AttributesDescriptor("Keywords//Statement (if, for, spawn, return…)", LudicColors.KEYWORD),
        AttributesDescriptor("Keywords//Clause (phase, query, on…)", LudicColors.CLAUSE),
        AttributesDescriptor("Keywords//Boolean", LudicColors.BOOLEAN),
        AttributesDescriptor("Types//Built-in type (int, fixed, entity…)", LudicColors.PRIMITIVE),
        AttributesDescriptor("Types//Type or namespace name", LudicColors.TYPE_NAME),
        AttributesDescriptor("Phase (Start, Update, Render…)", LudicColors.PHASE),
        AttributesDescriptor("Built-in function", LudicColors.BUILTIN),
        AttributesDescriptor("Annotation", LudicColors.ANNOTATION),
        AttributesDescriptor("Identifier", LudicColors.IDENTIFIER),
        AttributesDescriptor("Literals//String and char", LudicColors.STRING),
        AttributesDescriptor("Literals//Number", LudicColors.NUMBER),
        AttributesDescriptor("Literals//Escape ({{, }}, \\n)", LudicColors.STRING_ESCAPE),
        AttributesDescriptor("Literals//Template hole braces", LudicColors.TEMPLATE_BRACES),
        AttributesDescriptor("Comment", LudicColors.COMMENT),
        AttributesDescriptor("Braces and Operators//Operator", LudicColors.OPERATOR),
        AttributesDescriptor("Braces and Operators//Braces", LudicColors.BRACE),
        AttributesDescriptor("Braces and Operators//Brackets", LudicColors.BRACKET),
        AttributesDescriptor("Braces and Operators//Parentheses", LudicColors.PAREN),
        AttributesDescriptor("Braces and Operators//Comma", LudicColors.COMMA),
        AttributesDescriptor("Bad character", LudicColors.BAD),
        AttributesDescriptor("Manifest directive (package.ludic)", LudicColors.MANIFEST),
        AttributesDescriptor("Functions//Declaration", LudicColors.FUNCTION_DECLARATION),
        AttributesDescriptor("Functions//Call (this program)", LudicColors.FUNCTION_CALL),
        AttributesDescriptor("Functions//Call (package)", LudicColors.FUNCTION_PACKAGE),
        AttributesDescriptor("Functions//Call (built-in)", LudicColors.FUNCTION_BUILTIN),
        AttributesDescriptor("Functions//Handler", LudicColors.HANDLER),
        AttributesDescriptor("Constants//This program", LudicColors.CONSTANT),
        AttributesDescriptor("Constants//Package", LudicColors.CONSTANT_PACKAGE),
        AttributesDescriptor("Constants//Built-in (Color.Gold, …)", LudicColors.CONSTANT_BUILTIN),
        AttributesDescriptor("Variables//Global (this program)", LudicColors.GLOBAL_VARIABLE),
        AttributesDescriptor("Variables//Global (package)", LudicColors.GLOBAL_VARIABLE_PACKAGE),
        AttributesDescriptor("Variables//Local", LudicColors.LOCAL_VARIABLE),
        AttributesDescriptor("Variables//Parameter", LudicColors.PARAMETER),
        AttributesDescriptor("Variables//Field", LudicColors.FIELD),
        AttributesDescriptor("Types//Property (component)", LudicColors.PROPERTY_TYPE),
        AttributesDescriptor("Types//Model", LudicColors.MODEL_TYPE),
        AttributesDescriptor("Types//From a package", LudicColors.TYPE_PACKAGE),
        AttributesDescriptor("Types//Namespace", LudicColors.NAMESPACE),
        AttributesDescriptor("Types//Built-in namespace (Screen, Math, …)", LudicColors.NAMESPACE_BUILTIN),
    )
}

/**
 * Settings | Editor | Code Style | Ludic. Two-space indents, spaces not tabs:
 * the house style `ludic fmt` produces. Enter, closing braces and Reformat all
 * read the indent from here.
 */
class LudicCodeStyleSettingsProvider : LanguageCodeStyleSettingsProvider() {
    override fun getLanguage(): Language = LudicLanguage

    override fun getCodeSample(settingsType: SettingsType) = SAMPLE

    override fun getIndentOptionsEditor(): IndentOptionsEditor = SmartIndentOptionsEditor()

    override fun customizeDefaults(common: CommonCodeStyleSettings, indentOptions: CommonCodeStyleSettings.IndentOptions) {
        indentOptions.INDENT_SIZE = 2
        indentOptions.CONTINUATION_INDENT_SIZE = 2
        indentOptions.TAB_SIZE = 2
        indentOptions.USE_TAB_CHARACTER = false
        common.LINE_COMMENT_AT_FIRST_COLUMN = false
        common.LINE_COMMENT_ADD_SPACE = true
    }

    override fun createConfigurable(baseSettings: CodeStyleSettings, modelSettings: CodeStyleSettings): CodeStyleConfigurable =
        object : CodeStyleAbstractConfigurable(baseSettings, modelSettings, "Ludic") {
            override fun createPanel(settings: CodeStyleSettings): CodeStyleAbstractPanel =
                object : TabbedLanguageCodeStylePanel(LudicLanguage, currentSettings, settings) {
                    override fun initTabs(settings: CodeStyleSettings) {
                        addIndentOptionsTab(settings)
                    }
                }
        }

    override fun getConfigurableDisplayName() = "Ludic"
}
