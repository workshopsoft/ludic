package io.ludic.ide.run

import com.intellij.execution.lineMarker.ExecutorAction
import com.intellij.execution.lineMarker.RunLineMarkerContributor
import com.intellij.icons.AllIcons
import com.intellij.psi.PsiElement
import io.ludic.ide.psi.LudicPsi

/**
 * The green gutter buttons: one on every `test "name"` (showing that test's
 * last result), and one on `program` — run it, or run all of its tests when
 * the file is a test program.
 */
class LudicRunLineMarker : RunLineMarkerContributor() {

    override fun getInfo(element: PsiElement): Info? {
        LudicPsi.testNameAt(element)?.let { name ->
            val path = element.containingFile?.virtualFile?.path ?: return null
            val icon = getTestStateIcon(LudicTestUrls.test(path, name), element.project, false)
            return Info(icon, ExecutorAction.getActions(0)) { "Run test '$name'" }
        }
        if (LudicPsi.programNameAt(element) != null) {
            val file = element.containingFile ?: return null
            if (LudicPsi.isTestFile(file)) {
                val path = file.virtualFile?.path ?: return null
                val icon = getTestStateIcon(LudicTestUrls.file(path), element.project, true)
                return Info(icon, ExecutorAction.getActions(0)) { "Run all tests in ${file.name}" }
            }
            return Info(AllIcons.RunConfigurations.TestState.Run, ExecutorAction.getActions(0)) { "Run ${file.name}" }
        }
        return null
    }
}
