package io.ludic.ide.run

import com.intellij.execution.filters.ConsoleFilterProvider
import com.intellij.execution.filters.Filter
import com.intellij.execution.filters.OpenFileHyperlinkInfo
import com.intellij.openapi.application.ApplicationManager
import com.intellij.openapi.project.Project
import com.intellij.openapi.vfs.LocalFileSystem
import com.intellij.openapi.vfs.VirtualFile
import com.intellij.psi.search.FilenameIndex
import com.intellij.psi.search.GlobalSearchScope
import java.io.File

/**
 * Makes `path/to/file.ludic:42:` clickable. That is the shape of every
 * compiler error (`game.ludic:4: error: unknown function foo`) and every failed
 * assertion (`smoke.ludic:12: expect_eq failed`).
 *
 * The compiler often prints only the file's base name, so a path that does not
 * resolve against the working directory falls back to a project-wide lookup by
 * name, preferring a match under the working directory.
 */
class LudicConsoleFilter(private val project: Project, private val workDir: String?) : Filter {

    override fun applyFilter(line: String, entireLength: Int): Filter.Result? {
        val m = LOCATION.find(line) ?: return null
        val path = m.groupValues[1]
        val lineNo = m.groupValues[2].toIntOrNull() ?: return null
        val col = m.groupValues[3].toIntOrNull()
        val file = resolve(path) ?: return null
        val lineStart = entireLength - line.length
        val start = lineStart + m.groups[1]!!.range.first
        val end = lineStart + m.range.last + 1
        return Filter.Result(start, end, OpenFileHyperlinkInfo(project, file, lineNo - 1, (col ?: 1) - 1))
    }

    private fun resolve(path: String): VirtualFile? {
        val lfs = LocalFileSystem.getInstance()
        val candidates = buildList {
            val f = File(path)
            if (f.isAbsolute) add(f)
            if (workDir != null) add(File(workDir, path))
            project.basePath?.let { add(File(it, path)) }
        }
        for (c in candidates) {
            if (c.isFile) lfs.findFileByIoFile(c)?.let { return it }
        }
        val name = File(path).name
        return ApplicationManager.getApplication().runReadAction<VirtualFile?> {
            if (project.isDisposed) return@runReadAction null
            val found = FilenameIndex.getVirtualFilesByName(name, GlobalSearchScope.projectScope(project))
                .filter { it.path.endsWith("/$path") || it.name == path }
            val wd = workDir?.let { File(it).path + "/" }
            found.firstOrNull { wd != null && it.path.startsWith(wd) } ?: found.singleOrNull()
        }
    }

    private companion object {
        val LOCATION = Regex("""((?:[A-Za-z]:)?[^\s:"'(]*\.ludic):(\d+)(?::(\d+))?""")
    }
}

/** The same links in every console: Run, Terminal-launched tasks, external tools. */
class LudicConsoleFilterProvider : ConsoleFilterProvider {
    override fun getDefaultFilters(project: Project): Array<Filter> = arrayOf(LudicConsoleFilter(project, project.basePath))
}
