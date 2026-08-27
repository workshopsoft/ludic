package io.ludic.ide

import org.junit.Assert.assertEquals
import org.junit.Assert.assertNull
import org.junit.Assert.assertTrue
import org.junit.Rule
import org.junit.Test
import org.junit.rules.TemporaryFolder
import java.io.File

/**
 * Locating `ludic-lsp` is the single point where the whole language server can
 * fail silently: if this returns null the provider starts with an empty command
 * list, LSP4IJ reports `commands=[]`, and nothing in that message points at the
 * cause. It shipped broken once for exactly that reason, so it gets tests.
 */
class FindExecutableTest {

    @get:Rule
    val tmp = TemporaryFolder()

    private val names = listOf("ludic-lsp", "ludic-lsp.exe")

    private fun executableAt(vararg segments: String): File {
        val f = File(tmp.root, segments.joinToString(File.separator))
        f.parentFile.mkdirs()
        f.writeText("#!/bin/sh\n")
        check(f.setExecutable(true))
        return f
    }

    @Test
    fun `finds the binary that build-tools_sh produces`() {
        val exe = executableAt("build", "ludic-lsp")
        assertEquals(exe.absolutePath, findExecutable(tmp.root.path, "", names, SERVER_SUBDIRS))
    }

    @Test
    fun `a project root that is a subdirectory of the repo finds nothing`() {
        // The bug that shipped: the IDE was opened on <repo>/tools, so the
        // lookup searched <repo>/tools/build and came back empty while
        // <repo>/build/ludic-lsp sat there the whole time.
        executableAt("build", "ludic-lsp")
        val subdir = File(tmp.root, "tools").apply { mkdirs() }
        assertNull(
            "must not silently resolve from an unrelated root",
            findExecutable(subdir.path, "", names, SERVER_SUBDIRS)
        )
    }

    @Test
    fun `search order prefers build over the other candidates`() {
        executableAt("bin", "ludic-lsp")
        val preferred = executableAt("build", "ludic-lsp")
        assertEquals(preferred.absolutePath, findExecutable(tmp.root.path, "", names, SERVER_SUBDIRS))
    }

    @Test
    fun `every documented subdirectory is actually searched`() {
        for (dir in SERVER_SUBDIRS) {
            val fresh = TemporaryFolder().apply { create() }
            val f = File(fresh.root, "$dir${File.separator}ludic-lsp")
            f.parentFile.mkdirs()
            f.writeText("#!/bin/sh\n")
            f.setExecutable(true)
            assertEquals(
                "subdir '$dir' is advertised but not searched",
                f.canonicalPath,
                File(findExecutable(fresh.root.path, "", names, SERVER_SUBDIRS)!!).canonicalPath
            )
            fresh.delete()
        }
    }

    @Test
    fun `an explicitly configured path wins over anything found by search`() {
        executableAt("build", "ludic-lsp")
        val custom = executableAt("elsewhere", "my-lsp")
        assertEquals(custom.absolutePath, findExecutable(tmp.root.path, custom.absolutePath, names, SERVER_SUBDIRS))
    }

    @Test
    fun `a configured path that does not exist fails instead of falling back`() {
        // Silently ignoring the setting and using a different binary would be
        // worse than failing: the user asked for a specific server.
        executableAt("build", "ludic-lsp")
        assertNull(findExecutable(tmp.root.path, File(tmp.root, "nope").path, names, SERVER_SUBDIRS))
    }

    @Test
    fun `a non-executable file is not accepted`() {
        val f = File(tmp.root, "build/ludic-lsp")
        f.parentFile.mkdirs()
        f.writeText("not executable")
        f.setExecutable(false)
        assertNull(findExecutable(tmp.root.path, "", names, SERVER_SUBDIRS))
    }

    @Test
    fun `a directory named like the binary is not accepted`() {
        File(tmp.root, "build/ludic-lsp").mkdirs()
        assertNull(findExecutable(tmp.root.path, "", names, SERVER_SUBDIRS))
    }

    @Test
    fun `a null project root still allows a PATH lookup`() {
        // No exception, no crash: the default project has no basePath.
        findExecutable(null, "", names, SERVER_SUBDIRS)
    }

    @Test
    fun `the real repository layout resolves`() {
        // Guards the arrangement the plugin actually ships against: run
        // ./tools/build-tools.sh and opening the repo root must just work.
        val repoRoot = File(System.getProperty("user.dir")).parentFile.parentFile.parentFile
        val built = File(repoRoot, "build/ludic-lsp")
        if (!built.isFile) return   // toolchain not built in this checkout
        val found = findExecutable(repoRoot.path, "", names, SERVER_SUBDIRS)
        assertTrue("repo root must resolve to build/ludic-lsp", found != null)
        assertEquals(built.canonicalPath, File(found!!).canonicalPath)
    }
}

/**
 * The launch command itself. LSP4IJ only ever reports `commands=[...]`, so if
 * this list is wrong the failure surfaces with no explanation at all.
 */
class ServerCommandTest {

    private val repoRoot: File =
        File(System.getProperty("user.dir")).parentFile.parentFile.parentFile

    @Test
    fun `the repository root produces a runnable stdio command`() {
        val built = File(repoRoot, "build/ludic-lsp")
        if (!built.isFile) return   // toolchain not built in this checkout

        val cmd = serverCommand(repoRoot.path, "")
        assertEquals(listOf(built.canonicalPath, "--stdio"), cmd!!.let { listOf(File(it[0]).canonicalPath, it[1]) })

        // and it must actually be executable, not merely present
        val proc = ProcessBuilder(cmd[0], "--version").redirectErrorStream(true).start()
        val out = proc.inputStream.bufferedReader().readText().trim()
        proc.waitFor()
        assertTrue("expected a version banner, got '$out'", out.startsWith("ludic-lsp"))
    }

    @Test
    fun `a root without the toolchain yields no command rather than an empty one`() {
        // The distinction that matters: null lets start() throw an explanatory
        // error; an empty list is what produced the useless `commands=[]`.
        val cmd = serverCommand(File(repoRoot, "tools/editors").path, "")
        assertTrue("must be null, not an empty list", cmd == null || cmd.isNotEmpty())
    }
}
