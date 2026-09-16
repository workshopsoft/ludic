package io.ludic.ide

import com.intellij.execution.lineMarker.RunLineMarkerContributor
import com.intellij.ide.IconProvider
import com.intellij.psi.util.PsiTreeUtil
import com.intellij.testFramework.fixtures.BasePlatformTestCase
import io.ludic.ide.project.LudicManifest
import io.ludic.ide.project.LudicManifestDocumentation
import io.ludic.ide.project.LudicPackageIcons
import io.ludic.ide.project.LudicPackageNotificationProvider
import java.io.File
import java.nio.file.Files

/** package.ludic as a package file: the banner, gutter actions, completion, docs. */
class LudicManifestTest : BasePlatformTestCase() {

    private val manifest = """
        package "git.example.com/me/game"   # the import path
        version "0.2.0"
        kind source

        require "git.example.com/me/util" "1.0.0"
        require "git.example.com/me/fx" "0.3.1"

        app name "My Game"
        pack "assets/kit"
    """.trimIndent()

    fun testParsingFollowsTheCli() {
        val m = LudicManifest.parse(manifest)
        assertEquals("git.example.com/me/game", m.module)
        assertEquals("0.2.0", m.version)
        assertEquals("source", m.kind)
        assertEquals(listOf("git.example.com/me/util", "git.example.com/me/fx"), m.requires.map { it.module })
        assertEquals(listOf(4, 5), m.requires.map { it.line })
        assertEquals(listOf("app", "name", "My Game"), LudicManifest.words("app name \"My Game\"  # comment"))
    }

    fun testStaleWhenTheLockIsMissingOrOlder() {
        val dir = Files.createTempDirectory("ludic-manifest").toFile()
        try {
            val m = LudicManifest.parse(manifest)
            File(dir, "package.ludic").writeText(manifest)
            assertNotNull("no lock yet", LudicManifest.staleReason(dir, m))
            val lock = File(dir, "package.lock.ludic").apply { writeText("lock 1\n") }
            File(dir, "ludic_modules").mkdirs()
            lock.setLastModified(File(dir, "package.ludic").lastModified() + 5_000)
            assertNull("lock newer than the manifest", LudicManifest.staleReason(dir, m))
            File(dir, "package.ludic").setLastModified(lock.lastModified() + 5_000)
            assertNotNull("manifest edited after the lock", LudicManifest.staleReason(dir, m))
            assertNull("no requires, nothing to fetch", LudicManifest.staleReason(dir, LudicManifest.parse("package \"x\"")))
        } finally {
            dir.deleteRecursively()
        }
    }

    fun testDirectivesCompleteAtLineStart() {
        myFixture.configureByText("package.ludic", "package \"x\"\nre<caret>")
        val items = myFixture.completeBasic()?.map { it.lookupString } ?: listOf(myFixture.editor.document.text)
        assertTrue(items.toString(), items.any { it.startsWith("require") } || myFixture.editor.document.text.contains("require "))
        assertFalse("no Ludic keywords in a manifest", items.contains("let"))
    }

    fun testAppKeysAndKindsComplete() {
        myFixture.configureByText("package.ludic", "app <caret>")
        val keys = myFixture.completeBasic().map { it.lookupString.trim() }
        assertTrue(keys.containsAll(listOf("name", "id", "icon", "splash_bg")))
        myFixture.configureByText("package.ludic", "kind <caret>")
        assertEquals(setOf("source", "prebuilt"), myFixture.completeBasic().map { it.lookupString }.toSet())
    }

    fun testManifestCompletionStaysOutOfSource() {
        myFixture.configureByText("main.ludic", "program X {\n  re<caret>\n}")
        val items = myFixture.completeBasic()?.map { it.lookupString } ?: emptyList()
        assertFalse(items.any { it.startsWith("require ") })
    }

    fun testGutterActionsOnPackageAndRequireLines() {
        myFixture.configureByText("package.ludic", manifest)
        val marked = PsiTreeUtil.collectElements(myFixture.file) { it.firstChild == null }
            .mapNotNull { e ->
                RunLineMarkerContributor.EXTENSION.allForLanguage(LudicLanguage)
                    .firstNotNullOfOrNull { it.getInfo(e) }?.let { e.text to it.actions.size }
            }
        assertEquals(listOf("package" to 5, "require" to 3, "require" to 3), marked)
    }

    fun testDirectivesHaveQuickDocumentation() {
        myFixture.configureByText("package.ludic", manifest)
        val file = myFixture.file
        val req = file.findElementAt(file.text.indexOf("require"))!!
        val doc = LudicManifestDocumentation().generateDoc(req, req)
        assertNotNull(doc)
        assertTrue(doc!!.contains("minimum version"))
        val key = file.findElementAt(file.text.indexOf("name \"My"))!!
        assertTrue(LudicManifestDocumentation().generateDoc(key, key)!!.contains("display name"))
        val str = file.findElementAt(file.text.indexOf("0.2.0"))!!
        assertTrue("a version value explains its tag", LudicManifestDocumentation().generateDoc(str, str)!!.contains("v0.2.0"))
        val comment = file.findElementAt(file.text.indexOf("the import path"))!!
        assertNotNull(LudicManifestDocumentation().generateDoc(comment, comment))
    }

    fun testBannerAppearsOnlyOnTheManifest() {
        val provider = LudicPackageNotificationProvider()
        val man = myFixture.configureByText("package.ludic", manifest).virtualFile
        assertNotNull(provider.collectNotificationData(project, man))
        val src = myFixture.configureByText("main.ludic", "program X {}").virtualFile
        assertNull(provider.collectNotificationData(project, src))
    }

    fun testPathValuesNavigateAndMissingOnesAreErrors() {
        myFixture.addFileToProject("assets/app/icon.png", "png")
        myFixture.addFileToProject("src/game.ludic", "program G {}")
        val file = myFixture.configureByText("package.ludic", "entry \"src/game.ludic\"\napp icon \"assets/app/icon.png\"\npack \"assets/nope\"\nkind sauce\nbogus 1\n")
        val entry = file.findElementAt(file.text.indexOf("\"src/"))!!
        val targets = io.ludic.ide.project.LudicManifestGotoHandler().getGotoDeclarationTargets(entry, entry.textOffset, myFixture.editor)
        assertEquals("game.ludic", (targets!!.single() as com.intellij.psi.PsiFile).name)
        val icon = file.findElementAt(file.text.indexOf("\"assets/app"))!!
        assertNotNull(io.ludic.ide.project.manifestTarget(icon))
        val problems = myFixture.doHighlighting().map { it.description }
        assertTrue(problems.toString(), problems.any { it?.contains("No such file or directory: assets/nope") == true })
        assertTrue(problems.toString(), problems.any { it?.startsWith("kind must be one of") == true })
        assertTrue(problems.toString(), problems.any { it?.contains("Unknown directive 'bogus'") == true })
        assertFalse(problems.toString(), problems.any { it?.contains("icon.png") == true })
    }

    fun testAppLinesPreviewTheWholeApp() {
        val file = myFixture.configureByText("package.ludic", "app name \"Maroon Lake\"\napp id \"io.x.lake\"\napp splash_bg \"#0b1622\"\nversion \"0.1.7\"\n")
        val el = file.findElementAt(file.text.indexOf("io.x"))!!
        val doc = LudicManifestDocumentation().generateDoc(el, el)!!
        assertTrue(doc, doc.contains("Maroon Lake.app"))
        assertTrue(doc, doc.contains("io.x.lake"))
        assertTrue(doc, doc.contains("0.1.7"))
        assertTrue(doc, doc.contains("#0b1622"))
        val kind = myFixture.configureByText("package.ludic", "kind source\n")
        val src = kind.findElementAt(kind.text.indexOf("source"))!!
        assertTrue(LudicManifestDocumentation().generateDoc(src, src)!!.contains("Compiled from source"))
    }

    fun testLockFileIsReadAsALock() {
        val text = "# generated\nlock 1\nmodule \"git.x/me/util\" version \"1.2.0\" hash \"abc\" kind \"source\" provides \"Util\"\n"
        val locked = LudicManifest.parseLock(text).single()
        assertEquals("git.x/me/util", locked.module)
        assertEquals("1.2.0", locked.version)
        assertEquals(listOf("Util"), locked.provides)
        val file = myFixture.configureByText("package.lock.ludic", text)
        assertNotNull(LudicPackageNotificationProvider().collectNotificationData(project, file.virtualFile))
        val mod = file.findElementAt(file.text.indexOf("module"))!!
        val doc = LudicManifestDocumentation().generateDoc(mod, mod)!!
        assertTrue(doc, doc.contains("1.2.0") && doc.contains("Util.*"))
        val problems = myFixture.doHighlighting().map { it.description }
        assertTrue(problems.toString(), problems.any { it?.contains("not fetched yet") == true })
    }

    fun testScriptsAndHooks() {
        val text = "script \"dev\" \"ludic run --headless\"\nscript \"build\" \"echo \\\"x\\\"\"\nhook before build \"tools/prep.sh\"\nhook after dev \"echo done\"\nhook during build \"x\"\nhook before deploy \"x\"\n"
        val m = LudicManifest.parse(text)
        assertEquals(listOf("dev", "build"), m.scripts.map { it.name })
        assertEquals("echo \"x\"", m.scripts[1].command)
        assertEquals(listOf("before build", "after dev", "during build", "before deploy"), m.hooks.map { "${it.phase} ${it.event}" })

        myFixture.configureByText("package.ludic", text)
        val problems = myFixture.doHighlighting().mapNotNull { it.description }
        assertTrue(problems.toString(), problems.any { it.startsWith("A hook runs before or after") })
        assertTrue(problems.toString(), problems.any { it.startsWith("No command or script named 'deploy'") })
        assertTrue(problems.toString(), problems.any { it.contains("'ludic build' is a built-in command") })
        assertFalse(problems.toString(), problems.any { it.contains("'dev'") })

        val marked = PsiTreeUtil.collectElements(myFixture.file) { it.firstChild == null }
            .mapNotNull { e -> RunLineMarkerContributor.EXTENSION.allForLanguage(LudicLanguage).firstNotNullOfOrNull { it.getInfo(e) }?.let { e.text } }
        assertEquals(listOf("script", "script"), marked)

        val hook = myFixture.file.findElementAt(text.indexOf("hook after"))!!
        assertTrue(LudicManifestDocumentation().generateDoc(hook, hook)!!.contains("the script dev"))
    }

    fun testHookEventsComplete() {
        myFixture.configureByText("package.ludic", "script \"dev\" \"x\"\nhook before <caret>")
        val items = myFixture.completeBasic().map { it.lookupString.trim() }
        assertTrue(items.toString(), items.containsAll(listOf("build", "bundle", "test", "dev")))
        myFixture.configureByText("package.ludic", "hook <caret>")
        assertEquals(setOf("before", "after"), myFixture.completeBasic().map { it.lookupString.trim() }.toSet())
    }

    fun testManifestHasItsOwnIcon() {
        val file = myFixture.configureByText("package.ludic", manifest)
        val icon = IconProvider.EXTENSION_POINT_NAME.extensionList.firstNotNullOfOrNull { it.getIcon(file, 0) }
        assertSame(LudicPackageIcons.MANIFEST, icon)
    }
}
