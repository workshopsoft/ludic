package io.ludic.ide.run

import com.intellij.execution.actions.ConfigurationContext
import com.intellij.execution.actions.LazyRunConfigurationProducer
import com.intellij.execution.configurations.ConfigurationFactory
import com.intellij.execution.configurations.ConfigurationTypeUtil
import com.intellij.openapi.util.Ref
import com.intellij.psi.PsiDirectory
import com.intellij.psi.PsiElement
import com.intellij.psi.PsiFile
import io.ludic.ide.LudicFileType
import io.ludic.ide.psi.LudicPsi
import java.io.File

/**
 * Right-click -> Run, and the gutter buttons. What gets run follows from
 * where the user is:
 *
 *  - a `test "name"` header          -> ludic test <file> --test name
 *  - a test file (tests/, *_test, or
 *    a program made only of tests)    -> ludic test <file>
 *  - a file declaring a `program`     -> ludic run <file>
 *  - any other .ludic file (a module) -> ludic run, for the package that owns it
 *  - the `tests` directory            -> ludic test
 *  - a package root directory         -> ludic run
 */
class LudicRunConfigurationProducer : LazyRunConfigurationProducer<LudicRunConfiguration>() {

    override fun getConfigurationFactory(): ConfigurationFactory =
        ConfigurationTypeUtil.findConfigurationType(LudicConfigurationType::class.java).factory

    private data class Target(val command: LudicCommand, val file: String, val testName: String)

    private fun targetFor(element: PsiElement): Target? {
        if (element is PsiDirectory) {
            val dir = File(element.virtualFile.path)
            return when {
                dir.name == "tests" && LudicRunConfiguration.packageRootOf(dir.parentFile) == dir.parentFile ->
                    Target(LudicCommand.TEST, "", "")
                File(dir, "package.ludic").isFile -> Target(LudicCommand.RUN, "", "")
                else -> null
            }
        }
        val file: PsiFile = element.containingFile ?: return null
        if (file.fileType != LudicFileType) return null
        val vf = file.virtualFile ?: return null
        if (file.name == "package.ludic") return Target(LudicCommand.RUN, "", "")

        LudicPsi.enclosingTestKeyword(element)?.let { kw ->
            return Target(LudicCommand.TEST, vf.path, LudicPsi.testNameAt(kw)!!)
        }
        if (LudicPsi.isTestFile(file)) return Target(LudicCommand.TEST, vf.path, "")
        if (LudicPsi.isProgramFile(file)) return Target(LudicCommand.RUN, vf.path, "")
        // a module on its own does not run; its package does
        return if (LudicRunConfiguration.packageRootOf(File(vf.path).parentFile) != null) Target(LudicCommand.RUN, "", "") else null
    }

    override fun setupConfigurationFromContext(
        configuration: LudicRunConfiguration,
        context: ConfigurationContext,
        sourceElement: Ref<PsiElement>,
    ): Boolean {
        val element = context.psiLocation ?: return false
        val t = targetFor(element) ?: return false
        configuration.command = t.command
        configuration.file = t.file
        configuration.testName = t.testName
        if (t.file.isEmpty()) {
            // a project-level run executes from the package root
            val start = (element as? PsiDirectory)?.virtualFile?.path ?: element.containingFile?.virtualFile?.parent?.path
            start?.let { LudicRunConfiguration.packageRootOf(File(it)) }?.let { configuration.workingDirectory = it.path }
        }
        configuration.setGeneratedName()
        return true
    }

    override fun isConfigurationFromContext(configuration: LudicRunConfiguration, context: ConfigurationContext): Boolean {
        val element = context.psiLocation ?: return false
        val t = targetFor(element) ?: return false
        return configuration.command == t.command &&
            configuration.file == t.file &&
            configuration.testName == t.testName &&
            configuration.arguments.isBlank()
    }
}
