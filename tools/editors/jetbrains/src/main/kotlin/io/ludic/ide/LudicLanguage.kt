package io.ludic.ide

import com.intellij.lang.Language
import com.intellij.openapi.fileTypes.LanguageFileType
import com.intellij.openapi.util.IconLoader
import com.intellij.openapi.vfs.VirtualFile
import javax.swing.Icon

/**
 * The language ID matters more than it looks: the IDE's Markdown support
 * resolves a fenced block's info string ("```ludic") against registered
 * language IDs, so registering as "Ludic" is what makes fences in .md files
 * highlight, with no Markdown-specific code on our side.
 */
object LudicLanguage : Language("Ludic") {
    private fun readResolve(): Any = LudicLanguage
    override fun getDisplayName() = "Ludic"
    override fun isCaseSensitive() = true
}

object LudicIcons {
    val FILE: Icon = IconLoader.getIcon("/icons/ludic.svg", LudicIcons::class.java)
}

object LudicFileType : LanguageFileType(LudicLanguage) {
    private fun readResolve(): Any = LudicFileType
    override fun getName() = "Ludic"
    override fun getDescription() = "Ludic source"
    override fun getDefaultExtension() = "ludic"
    override fun getIcon(): Icon = LudicIcons.FILE
    override fun getCharset(file: VirtualFile, content: ByteArray): String = "UTF-8"
}
