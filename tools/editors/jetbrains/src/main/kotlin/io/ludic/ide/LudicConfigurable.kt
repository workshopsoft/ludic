package io.ludic.ide

import com.intellij.openapi.options.Configurable
import com.intellij.openapi.project.Project
import com.intellij.openapi.ui.TextFieldWithBrowseButton
import com.intellij.openapi.fileChooser.FileChooserDescriptorFactory
import com.intellij.ui.components.JBCheckBox
import com.intellij.ui.components.JBLabel
import com.intellij.util.ui.FormBuilder
import javax.swing.JComponent
import javax.swing.JPanel
import javax.swing.JSpinner
import javax.swing.SpinnerNumberModel

/** Settings -> Languages and Frameworks -> Ludic */
class LudicConfigurable(private val project: Project) : Configurable {
    private val serverField = TextFieldWithBrowseButton()
    private val compilerField = TextFieldWithBrowseButton()
    private val diagnostics = JBCheckBox("Report compiler errors on save")
    private val indent = JSpinner(SpinnerNumberModel(2, 1, 8, 1))
    private var panel: JPanel? = null

    override fun getDisplayName() = "Ludic"

    override fun createComponent(): JComponent {
        // The title travels on the descriptor now; the four-argument overload
        // that took it separately is scheduled for removal.
        serverField.addBrowseFolderListener(
            project,
            FileChooserDescriptorFactory.createSingleFileNoJarsDescriptor().withTitle("Path to ludic-lsp")
        )
        compilerField.addBrowseFolderListener(
            project,
            FileChooserDescriptorFactory.createSingleFileNoJarsDescriptor().withTitle("Path to ludicc")
        )

        panel = FormBuilder.createFormBuilder()
            .addLabeledComponent(JBLabel("Language server (ludic-lsp):"), serverField, 1, false)
            .addComponentToRightColumn(
                JBLabel("Leave empty to use build/ludic-lsp under the project, then PATH.")
            )
            .addLabeledComponent(JBLabel("Compiler (ludicc):"), compilerField, 1, false)
            .addComponentToRightColumn(
                JBLabel("Used for authoritative diagnostics. Empty means build/ludicc.")
            )
            .addComponent(diagnostics)
            .addLabeledComponent(JBLabel("Formatter indent:"), indent, 1, false)
            .addComponentFillVertically(JPanel(), 0)
            .panel
        reset()
        return panel!!
    }

    private fun settings() = LudicSettings.of(project)

    override fun isModified(): Boolean {
        val s = settings()
        return serverField.text != s.serverPath ||
            compilerField.text != s.compilerPath ||
            diagnostics.isSelected != s.compilerDiagnostics ||
            (indent.value as Int) != s.indentSize
    }

    override fun apply() {
        val s = settings()
        s.serverPath = serverField.text.trim()
        s.compilerPath = compilerField.text.trim()
        s.compilerDiagnostics = diagnostics.isSelected
        s.indentSize = indent.value as Int
    }

    override fun reset() {
        val s = settings()
        serverField.text = s.serverPath
        compilerField.text = s.compilerPath
        diagnostics.isSelected = s.compilerDiagnostics
        indent.value = s.indentSize
    }

    override fun disposeUIResources() {
        panel = null
    }
}
