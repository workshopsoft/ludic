package io.ludic.ide.project

import com.intellij.execution.configurations.GeneralCommandLine
import com.intellij.execution.util.ExecUtil
import com.intellij.ide.util.projectWizard.WizardContext
import com.intellij.ide.wizard.AbstractNewProjectWizardStep
import com.intellij.ide.wizard.GeneratorNewProjectWizard
import com.intellij.ide.wizard.GeneratorNewProjectWizardBuilderAdapter
import com.intellij.ide.wizard.GitNewProjectWizardStep
import com.intellij.ide.wizard.NewProjectWizardBaseData.Companion.baseData
import com.intellij.ide.wizard.NewProjectWizardBaseStep
import com.intellij.ide.wizard.NewProjectWizardChainStep.Companion.nextStep
import com.intellij.ide.wizard.NewProjectWizardStep
import com.intellij.ide.wizard.RootNewProjectWizardStep
import com.intellij.openapi.application.ApplicationManager
import com.intellij.openapi.module.GeneralModuleType
import com.intellij.openapi.module.ModuleTypeManager
import com.intellij.openapi.project.Project
import com.intellij.openapi.ui.Messages
import com.intellij.openapi.util.Key
import com.intellij.openapi.vfs.LocalFileSystem
import com.intellij.ui.dsl.builder.Panel
import io.ludic.ide.LudicIcons
import io.ludic.ide.LudicToolchain
import java.io.File
import java.nio.file.Files

/**
 * File | New | Project | Ludic. The project is whatever `ludic new` makes,
 * so the IDE never carries its own copy of the template to drift from the CLI.
 */
class LudicNewProjectWizard : GeneratorNewProjectWizard {
    override val id = "Ludic"
    override val name = "Ludic"
    override val icon = LudicIcons.FILE
    override val description = "A Ludic game: package.ludic, src/main.ludic and a test, as <code>ludic new</code> creates them."

    override fun createStep(context: WizardContext): NewProjectWizardStep =
        RootNewProjectWizardStep(context)
            .nextStep(::NewProjectWizardBaseStep)
            .nextStep(::GitNewProjectWizardStep)
            .nextStep(::LudicProjectStep)
}

/** A file a freshly created project should show first. */
internal val OPEN_ON_START = Key.create<String>("ludic.openOnStart")

class LudicModuleBuilder : GeneratorNewProjectWizardBuilderAdapter(LudicNewProjectWizard())

private class LudicProjectStep(parent: NewProjectWizardStep) : AbstractNewProjectWizardStep(parent) {

    override fun setupUI(builder: Panel) {
        val cli = LudicToolchain.cli()
        builder.row {
            if (cli != null) comment("Toolchain: $cli")
            else comment("The <code>ludic</code> command was not found. ${LudicToolchain.INSTALL_HINT}")
        }
    }

    override fun setupProject(project: Project) {
        val data = baseData ?: return
        val dir = File(data.path, data.name)
        val error = scaffold(dir, data.name)
        if (error != null) {
            ApplicationManager.getApplication().invokeLater {
                Messages.showErrorDialog(project, error, "Could Not Create the Ludic Project")
            }
        }
        // a plain module whose content root is the project directory, so the
        // Project view shows the files
        val builder = ModuleTypeManager.getInstance().findByID(GeneralModuleType.TYPE_ID).createModuleBuilder()
        builder.name = data.name
        builder.contentEntryPath = dir.path
        builder.moduleFilePath = File(File(dir, ".idea"), "${data.name}.iml").path
        builder.commit(project)

        // LudicToolchainCheck opens it once the project window is up
        project.putUserData(OPEN_ON_START, File(dir, "src/main.ludic").path)
    }
}

/**
 * Run `ludic new` in a scratch directory and move the result into [dir],
 * which the wizard may already have created (with .idea/ inside). Returns an
 * error message, or null on success.
 */
internal fun scaffold(dir: File, displayName: String, cli: String? = LudicToolchain.cli()): String? {
    cli ?: return "The 'ludic' command was not found.\n${LudicToolchain.INSTALL_HINT}"
    val slug = packageSlug(displayName)
    val scratch = Files.createTempDirectory("ludic-new").toFile()
    try {
        val out = ExecUtil.execAndGetOutput(
            GeneralCommandLine(cli, "new", slug).withWorkDirectory(scratch).withCharset(Charsets.UTF_8),
            60_000
        )
        val made = File(scratch, slug)
        if (out.exitCode != 0 || !made.isDirectory) {
            return "ludic new $slug failed (exit ${out.exitCode}):\n${out.stderr.ifBlank { out.stdout }}"
        }
        dir.mkdirs()
        made.walkTopDown().filter { it.isFile }.forEach { src ->
            val dst = File(dir, src.relativeTo(made).path)
            if (!dst.exists()) {
                dst.parentFile.mkdirs()
                src.copyTo(dst)
            }
        }
        // keep the empty directories (assets/) the template promises
        made.walkTopDown().filter { it.isDirectory }.forEach { File(dir, it.relativeTo(made).path).mkdirs() }
        LocalFileSystem.getInstance().refreshAndFindFileByIoFile(dir)?.refresh(false, true)
        return null
    } finally {
        scratch.deleteRecursively()
    }
}

/** A name `ludic new` accepts: letters, digits, '-', '_' and '.'. */
internal fun packageSlug(name: String): String {
    val s = name.trim().map { if (it.isLetterOrDigit() || it in "-_.") it else '-' }.joinToString("")
        .trim('-', '.').ifEmpty { "game" }
    return s
}
