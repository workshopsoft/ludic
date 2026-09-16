package io.ludic.ide.editor

import com.intellij.codeInsight.template.TemplateActionContext
import com.intellij.codeInsight.template.TemplateContextType
import com.intellij.ide.actions.CreateFileFromTemplateAction
import com.intellij.ide.actions.CreateFileFromTemplateDialog
import com.intellij.ide.fileTemplates.FileTemplate
import com.intellij.openapi.project.DumbAware
import com.intellij.openapi.project.Project
import com.intellij.psi.PsiDirectory
import com.intellij.psi.PsiFile
import com.intellij.psi.util.PsiUtilCore
import io.ludic.ide.LudicIcons
import io.ludic.ide.LudicLanguage
import io.ludic.ide.LudicTokens

/** Live templates (`prog`, `test`, `handler`, `fn`, …) apply in Ludic code, not inside strings or comments. */
class LudicTemplateContext : TemplateContextType("Ludic") {
    override fun isInContext(ctx: TemplateActionContext): Boolean {
        val file = ctx.file
        if (!PsiUtilCore.getLanguageAtOffset(file, ctx.startOffset).isKindOf(LudicLanguage)) return false
        val at = file.findElementAt((ctx.startOffset - 1).coerceAtLeast(0)) ?: return true
        val type = at.node.elementType
        return type != LudicTokens.STRING && type != LudicTokens.COMMENT && type != LudicTokens.CHAR
    }
}

/**
 * File | New | Ludic File. The kinds mirror what a project holds: a program
 * (the entry), a module imported by one, and a test program for tests/.
 */
class CreateLudicFileAction : CreateFileFromTemplateAction(), DumbAware {

    override fun buildDialog(project: Project, directory: PsiDirectory, builder: CreateFileFromTemplateDialog.Builder) {
        builder.setTitle("New Ludic File")
            .addKind("Program", LudicIcons.FILE, PROGRAM)
            .addKind("Module", LudicIcons.FILE, MODULE)
            .addKind("Test", LudicIcons.FILE, TEST)
            .addKind("Empty file", LudicIcons.FILE, EMPTY)
    }

    override fun getActionName(directory: PsiDirectory, newName: String, templateName: String) = "Create Ludic file $newName"

    override fun createFileFromTemplate(name: String, template: FileTemplate, dir: PsiDirectory): PsiFile? {
        val base = name.removeSuffix(".ludic")
        return createFileFromTemplate(base, template, dir, null, true, emptyMap(), mapOf("PROGRAM_NAME" to programName(base)))
    }

    companion object {
        const val PROGRAM = "Ludic Program"
        const val MODULE = "Ludic Module"
        const val TEST = "Ludic Test"
        const val EMPTY = "Ludic File"

        /** `enemy_ai` -> `EnemyAi`: a file name as a program name. */
        fun programName(file: String): String {
            val parts = file.split('_', '-', '.', ' ').filter { it.isNotEmpty() }
            val joined = parts.joinToString("") { p -> p.replaceFirstChar { it.uppercaseChar() } }
            val clean = joined.filter { it.isLetterOrDigit() }
            return if (clean.isEmpty() || clean[0].isDigit()) "P$clean" else clean
        }
    }
}
