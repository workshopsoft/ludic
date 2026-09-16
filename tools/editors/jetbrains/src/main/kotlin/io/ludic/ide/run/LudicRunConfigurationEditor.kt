package io.ludic.ide.run

import com.intellij.execution.configuration.EnvironmentVariablesTextFieldWithBrowseButton
import com.intellij.openapi.fileChooser.FileChooserDescriptorFactory
import com.intellij.openapi.options.SettingsEditor
import com.intellij.openapi.project.Project
import com.intellij.openapi.ui.ComboBox
import com.intellij.openapi.ui.TextFieldWithBrowseButton
import com.intellij.ui.RawCommandLineEditor
import com.intellij.ui.components.JBCheckBox
import com.intellij.ui.components.JBLabel
import com.intellij.ui.components.JBTextField
import com.intellij.util.ui.FormBuilder
import io.ludic.ide.LudicFileType
import javax.swing.JComponent

class LudicRunConfigurationEditor(private val project: Project) : SettingsEditor<LudicRunConfiguration>() {
    private val command = ComboBox(LudicCommand.entries.toTypedArray())
    private val file = TextFieldWithBrowseButton()
    private val testName = JBTextField()
    private val headless = JBCheckBox("Headless (no window: frames go to build/out.ppm, keys come from stdin)")
    private val arguments = RawCommandLineEditor()
    private val workingDirectory = TextFieldWithBrowseButton()
    private val env = EnvironmentVariablesTextFieldWithBrowseButton()
    private val argumentsLabel = JBLabel("Extra arguments:")

    init {
        file.addBrowseFolderListener(
            project,
            FileChooserDescriptorFactory.createSingleFileDescriptor(LudicFileType).withTitle("Ludic File")
        )
        workingDirectory.addBrowseFolderListener(
            project,
            FileChooserDescriptorFactory.createSingleFolderDescriptor().withTitle("Working Directory")
        )
        testName.emptyText.text = "all tests in the file (or the project's tests/)"
        file.textField.let { (it as? JBTextField)?.emptyText?.text = "the project's entry program" }
        workingDirectory.textField.let { (it as? JBTextField)?.emptyText?.text = "the package root that owns the file" }
        command.addActionListener { updateEnabled() }
    }

    private fun updateEnabled() {
        val c = command.item ?: LudicCommand.RUN
        testName.isEnabled = c == LudicCommand.TEST
        headless.isEnabled = c == LudicCommand.RUN || c == LudicCommand.BUILD
        file.isEnabled = c != LudicCommand.CUSTOM
        argumentsLabel.text = if (c == LudicCommand.CUSTOM) "ludic" else "Extra arguments:"
    }

    override fun createEditor(): JComponent = FormBuilder.createFormBuilder()
        .addLabeledComponent("Command:", command)
        .addLabeledComponent("File:", file)
        .addLabeledComponent("Test name:", testName)
        .addComponent(headless)
        .addLabeledComponent(argumentsLabel, arguments)
        .addLabeledComponent("Working directory:", workingDirectory)
        .addLabeledComponent("Environment variables:", env)
        .panel

    override fun resetEditorFrom(c: LudicRunConfiguration) {
        command.item = c.command
        file.text = c.file
        testName.text = c.testName
        headless.isSelected = c.headless
        arguments.text = c.arguments
        workingDirectory.text = c.workingDirectory
        env.envs = c.env
        env.isPassParentEnvs = c.passParentEnv
        updateEnabled()
    }

    override fun applyEditorTo(c: LudicRunConfiguration) {
        c.command = command.item ?: LudicCommand.RUN
        c.file = file.text.trim()
        c.testName = testName.text
        c.headless = headless.isSelected
        c.arguments = arguments.text
        c.workingDirectory = workingDirectory.text.trim()
        c.env = env.envs
        c.passParentEnv = env.isPassParentEnvs
    }
}
