package io.ludic.ide.run

import com.intellij.execution.ProgramRunnerUtil
import com.intellij.execution.RunManager
import com.intellij.execution.configurations.ConfigurationTypeUtil
import com.intellij.execution.executors.DefaultRunExecutor
import com.intellij.openapi.actionSystem.ActionUpdateThread
import com.intellij.openapi.actionSystem.AnAction
import com.intellij.openapi.actionSystem.AnActionEvent
import com.intellij.openapi.actionSystem.CommonDataKeys
import com.intellij.openapi.fileEditor.FileDocumentManager
import com.intellij.openapi.project.DumbAware
import com.intellij.openapi.project.Project
import java.io.File

/**
 * Tools | Ludic. Each action is a throwaway run configuration, so its output
 * lands in the Run tool window with the same clickable locations as any run.
 */
abstract class LudicCliAction(private val command: LudicCommand, private val args: String = "") : AnAction(), DumbAware {

    override fun getActionUpdateThread() = ActionUpdateThread.BGT

    override fun update(e: AnActionEvent) {
        e.presentation.isEnabledAndVisible = e.project != null
    }

    override fun actionPerformed(e: AnActionEvent) {
        val project = e.project ?: return
        FileDocumentManager.getInstance().saveAllDocuments()
        run(project, command, args, packageRootFor(e, project))
    }

    private fun packageRootFor(e: AnActionEvent, project: Project): String? {
        val start = e.getData(CommonDataKeys.VIRTUAL_FILE)?.let { if (it.isDirectory) it.path else it.parent?.path }
            ?: project.basePath ?: return null
        return LudicRunConfiguration.packageRootOf(File(start))?.path ?: project.basePath
    }

    companion object {
        fun run(project: Project, command: LudicCommand, args: String, workDir: String?) {
            val type = ConfigurationTypeUtil.findConfigurationType(LudicConfigurationType::class.java)
            val settings = RunManager.getInstance(project).createConfiguration("ludic", type.factory)
            val config = settings.configuration as LudicRunConfiguration
            config.command = command
            config.arguments = args
            workDir?.let { config.workingDirectory = it }
            settings.name = config.suggestedName()
            settings.isTemporary = true
            ProgramRunnerUtil.executeConfiguration(settings, DefaultRunExecutor.getRunExecutorInstance())
        }
    }
}

class LudicRunProjectAction : LudicCliAction(LudicCommand.RUN)
class LudicBuildProjectAction : LudicCliAction(LudicCommand.BUILD)
class LudicTestProjectAction : LudicCliAction(LudicCommand.TEST)
class LudicFormatProjectAction : LudicCliAction(LudicCommand.CUSTOM, "fmt")
class LudicGetPackagesAction : LudicCliAction(LudicCommand.CUSTOM, "get")
class LudicPackAction : LudicCliAction(LudicCommand.CUSTOM, "pack")
class LudicBundleAction : LudicCliAction(LudicCommand.CUSTOM, "bundle")
class LudicCleanAction : LudicCliAction(LudicCommand.CUSTOM, "clean")
class LudicDoctorAction : LudicCliAction(LudicCommand.CUSTOM, "doctor")

/** Tools | Ludic | Run Script…: pick one of package.ludic's scripts. */
class LudicRunScriptAction : AnAction(), DumbAware {
    override fun getActionUpdateThread() = ActionUpdateThread.BGT

    override fun update(e: AnActionEvent) {
        e.presentation.isEnabledAndVisible = e.project != null
    }

    override fun actionPerformed(e: AnActionEvent) {
        val project = e.project ?: return
        val base = project.basePath ?: return
        val start = e.getData(CommonDataKeys.VIRTUAL_FILE)?.let { if (it.isDirectory) it.path else it.parent?.path } ?: base
        val root = LudicRunConfiguration.packageRootOf(File(start)) ?: File(base)
        val manifest = File(root, "package.ludic").takeIf { it.isFile }?.let { io.ludic.ide.project.LudicManifest.parse(it.readText()) }
        val scripts = manifest?.scripts.orEmpty()
        if (scripts.isEmpty()) {
            com.intellij.openapi.ui.Messages.showInfoMessage(project,
                "package.ludic defines no scripts. Add one:\n\nscript \"dev\" \"ludic run --headless\"", "Ludic Scripts")
            return
        }
        com.intellij.openapi.ui.popup.JBPopupFactory.getInstance()
            .createPopupChooserBuilder(scripts)
            .setTitle("Run Ludic Script")
            .setRenderer(com.intellij.ui.SimpleListCellRenderer.create { label, s, _ -> label.text = "${s.name}   —   ${s.command}" })
            .setItemChosenCallback { s ->
                FileDocumentManager.getInstance().saveAllDocuments()
                LudicCliAction.run(project, LudicCommand.CUSTOM, "script ${s.name}", root.path)
            }
            .createPopup()
            .showCenteredInCurrentWindow(project)
    }
}
