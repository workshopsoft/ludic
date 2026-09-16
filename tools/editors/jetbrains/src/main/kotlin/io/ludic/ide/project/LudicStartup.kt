package io.ludic.ide.project

import com.intellij.notification.NotificationAction
import com.intellij.notification.NotificationGroupManager
import com.intellij.notification.NotificationType
import com.intellij.openapi.application.EDT
import com.intellij.openapi.fileEditor.FileEditorManager
import com.intellij.openapi.options.ShowSettingsUtil
import com.intellij.openapi.vfs.LocalFileSystem
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import com.intellij.openapi.project.Project
import com.intellij.openapi.startup.ProjectActivity
import com.intellij.ide.BrowserUtil
import io.ludic.ide.LudicConfigurable
import io.ludic.ide.LudicToolchain
import java.io.File

/**
 * Opening a Ludic project on a machine without the toolchain would otherwise
 * look like a plugin that half works: colours, but no completion and no run
 * button that does anything. Say so once, with the fix attached.
 */
class LudicToolchainCheck : ProjectActivity {
    override suspend fun execute(project: Project) {
        project.getUserData(OPEN_ON_START)?.let { path ->
            project.putUserData(OPEN_ON_START, null)
            val main = LocalFileSystem.getInstance().refreshAndFindFileByIoFile(File(path))
            if (main != null) {
                withContext(Dispatchers.EDT) { FileEditorManager.getInstance(project).openFile(main, true) }
            }
        }
        val root = project.basePath ?: return
        if (!looksLikeLudic(File(root))) return
        val missing = buildList {
            if (LudicToolchain.cli(project) == null) add("ludic")
            if (LudicToolchain.server(project) == null) add("ludic-lsp")
        }
        if (missing.isEmpty()) return
        NotificationGroupManager.getInstance().getNotificationGroup("Ludic")
            .createNotification(
                "Ludic toolchain not found",
                "Could not find ${missing.joinToString(" or ") { "<code>$it</code>" }}. " +
                    "Highlighting works without it; completion, diagnostics, run and test do not.",
                NotificationType.WARNING
            )
            .addAction(NotificationAction.createSimple("Install instructions") {
                BrowserUtil.browse("https://workshopsoft.pages.workshopsoft.io/ludic/")
            })
            .addAction(NotificationAction.createSimple("Set paths…") {
                ShowSettingsUtil.getInstance().showSettingsDialog(project, LudicConfigurable::class.java)
            })
            .notify(project)
    }

    private fun looksLikeLudic(root: File): Boolean =
        File(root, "package.ludic").isFile ||
            File(root, "src").listFiles()?.any { it.extension == "ludic" } == true ||
            root.listFiles()?.any { it.extension == "ludic" } == true
}
