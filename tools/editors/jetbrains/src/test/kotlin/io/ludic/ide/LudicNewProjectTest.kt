package io.ludic.ide

import io.ludic.ide.project.packageSlug
import io.ludic.ide.project.scaffold
import org.junit.Assert.assertEquals
import org.junit.Assert.assertNotNull
import org.junit.Assert.assertNull
import org.junit.Assert.assertTrue
import org.junit.Rule
import org.junit.Test
import org.junit.rules.TemporaryFolder
import java.io.File

class LudicNewProjectTest {

    @get:Rule
    val tmp = TemporaryFolder()

    private val repoCli: File =
        File(System.getProperty("user.dir")).parentFile.parentFile.parentFile.resolve("bin/ludic")

    @Test
    fun `project names become names ludic new accepts`() {
        assertEquals("my-game", packageSlug("my game"))
        assertEquals("Maroon-Lake", packageSlug("Maroon Lake!"))
        assertEquals("space_1.0", packageSlug("space_1.0"))
        assertEquals("game", packageSlug("!!!"))
    }

    @Test
    fun `scaffold fills a directory the wizard already created`() {
        if (!repoCli.canExecute()) return   // toolchain not built in this checkout
        val dir = File(tmp.root, "My Game").apply { mkdirs() }
        File(dir, ".idea").mkdirs()
        File(dir, "README.md").writeText("mine")

        assertNull(scaffold(dir, "My Game", repoCli.path))

        assertTrue(File(dir, "package.ludic").readText().contains("My-Game"))
        assertTrue(File(dir, "src/main.ludic").readText().contains("program "))
        assertTrue(File(dir, "tests/smoke.ludic").isFile)
        assertTrue(File(dir, "assets").isDirectory)
        assertTrue(File(dir, ".idea").isDirectory)
        assertEquals("an existing file is never overwritten", "mine", File(dir, "README.md").readText())
    }

    @Test
    fun `scaffold without a toolchain explains itself`() {
        val msg = scaffold(File(tmp.root, "x"), "x", cli = null)
        assertNotNull(msg)
        assertTrue(msg!!.contains("install", ignoreCase = true))
    }
}
