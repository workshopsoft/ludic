package io.ludic.ide

import com.intellij.execution.actions.ConfigurationContext
import com.intellij.execution.executors.DefaultRunExecutor
import com.intellij.execution.filters.OpenFileHyperlinkInfo
import com.intellij.execution.lineMarker.RunLineMarkerContributor
import com.intellij.execution.process.ProcessOutputTypes
import com.intellij.execution.testframework.sm.runner.SMTestLocator
import com.intellij.openapi.util.Key
import com.intellij.psi.PsiElement
import com.intellij.psi.search.GlobalSearchScope
import com.intellij.psi.util.PsiTreeUtil
import com.intellij.testFramework.MapDataContext
import com.intellij.testFramework.fixtures.BasePlatformTestCase
import com.intellij.openapi.actionSystem.CommonDataKeys
import com.intellij.openapi.actionSystem.PlatformCoreDataKeys
import com.intellij.execution.Location
import com.intellij.execution.PsiLocation
import io.ludic.ide.psi.LudicPsi
import io.ludic.ide.run.LudicCommand
import io.ludic.ide.run.LudicConfigurationType
import io.ludic.ide.run.LudicConsoleFilter
import io.ludic.ide.run.LudicRunConfiguration
import io.ludic.ide.run.LudicRunConfigurationProducer
import io.ludic.ide.run.LudicTestConsoleProperties
import io.ludic.ide.run.LudicTestEventsConverter
import io.ludic.ide.run.LudicTestLocator
import io.ludic.ide.run.LudicTestUrls
import com.intellij.execution.configurations.ConfigurationTypeUtil

/**
 * Run configurations, gutter buttons, the test tree and console links —
 * everything between "click the green arrow" and "see which test failed".
 */
class LudicRunTest : BasePlatformTestCase() {

    private val spec = """
        program MathSpec {
          function add(a: int, b: int) -> int { return a + b }

          test "adds" {
            expect_eq(add(1, 1), 2)
          }

          test "it's \"quoted\"" { expect(true) }
        }
    """.trimIndent()

    private val game = """
        program Game {
          handler Boot phase Start { print("hi") }
        }
    """.trimIndent()

    private fun leafAt(marker: String): PsiElement {
        val offset = myFixture.file.text.indexOf(marker)
        assertTrue("marker '$marker' not found", offset >= 0)
        return myFixture.file.findElementAt(offset)!!
    }

    private fun configFor(element: PsiElement): LudicRunConfiguration? {
        val ctx = ConfigurationContext.getFromContext(
            MapDataContext().apply {
                put(CommonDataKeys.PROJECT, project)
                put(PlatformCoreDataKeys.MODULE, myFixture.module)
                put(Location.DATA_KEY, PsiLocation(element))
            },
            "test"
        )
        val producer = LudicRunConfigurationProducer()
        val from = producer.createConfigurationFromContext(ctx) ?: return null
        val config = from.configuration as LudicRunConfiguration
        assertTrue("the producer must recognise its own configuration", producer.isConfigurationFromContext(config, ctx))
        return config
    }

    fun testTestHeaderRunsJustThatTest() {
        myFixture.configureByText("math_test.ludic", spec)
        val c = configFor(leafAt("test \"adds\""))!!
        c.workingDirectory = "/src"
        assertEquals(LudicCommand.TEST, c.command)
        assertEquals("adds", c.testName)
        assertEquals("Test 'adds'", c.name)
        assertEquals(listOf("test", "math_test.ludic", "--verbose", "--test", "adds"), c.cliArguments())
    }

    fun testEscapedTestNamesAreUnescaped() {
        myFixture.configureByText("math_test.ludic", spec)
        val kw = LudicPsi.testKeywords(myFixture.file)
        assertEquals(listOf("adds", "it's \"quoted\""), kw.map { LudicPsi.testNameAt(it) })
        assertEquals("it's \"quoted\"", configFor(kw[1].nextSibling.nextSibling)!!.testName)
    }

    fun testTestFileRunsAllItsTests() {
        myFixture.configureByText("math_test.ludic", spec)
        val c = configFor(leafAt("function"))!!
        assertEquals(LudicCommand.TEST, c.command)
        assertEquals("", c.testName)
        assertEquals("Test math_test.ludic", c.name)
    }

    fun testProgramFileRuns() {
        myFixture.configureByText("game.ludic", game)
        val c = configFor(leafAt("print"))!!
        c.workingDirectory = "/src"
        assertEquals(LudicCommand.RUN, c.command)
        assertEquals(listOf("run", "game.ludic"), c.cliArguments())
        c.headless = true
        assertEquals(listOf("run", "game.ludic", "--headless"), c.cliArguments())
    }

    fun testCustomCommandPassesArgumentsThrough() {
        val type = ConfigurationTypeUtil.findConfigurationType(LudicConfigurationType::class.java)
        val c = type.factory.createTemplateConfiguration(project) as LudicRunConfiguration
        c.command = LudicCommand.CUSTOM
        c.arguments = "fmt --check \"src/a b.ludic\""
        assertEquals(listOf("fmt", "--check", "src/a b.ludic"), c.cliArguments())
    }

    fun testConfigurationSurvivesSerialization() {
        val type = ConfigurationTypeUtil.findConfigurationType(LudicConfigurationType::class.java)
        val c = type.factory.createTemplateConfiguration(project) as LudicRunConfiguration
        c.command = LudicCommand.TEST
        c.file = "/tmp/x.ludic"
        c.testName = "adds"
        c.env = mapOf("R3D_GAME" to "aimprobe")
        val element = org.jdom.Element("configuration")
        c.writeExternal(element)
        val back = type.factory.createTemplateConfiguration(project) as LudicRunConfiguration
        back.readExternal(element)
        assertEquals(LudicCommand.TEST, back.command)
        assertEquals("/tmp/x.ludic", back.file)
        assertEquals("adds", back.testName)
        assertEquals(mapOf("R3D_GAME" to "aimprobe"), back.env)
    }

    fun testGutterMarksEveryTestAndTheProgram() {
        myFixture.configureByText("math_test.ludic", spec)
        val marked = PsiTreeUtil.collectElements(myFixture.file) { it.firstChild == null }
            .filter { e -> RunLineMarkerContributor.EXTENSION.allForLanguage(LudicLanguage).any { it.getInfo(e) != null } }
            .map { it.text }
        assertEquals(listOf("program", "test", "test"), marked)
    }

    fun testLocatorFindsTheTestBlock() {
        val file = myFixture.configureByText("math_test.ludic", spec)
        val path = file.virtualFile.path
        val url = LudicTestUrls.test(path, "adds").removePrefix("ludic://")
        val loc = LudicTestLocator.getLocation("ludic", url, project, GlobalSearchScope.allScope(project)).single()
        assertEquals("test", loc.psiElement.text)
        assertEquals(file.text.indexOf("test \"adds\""), loc.psiElement.textOffset)
        val fileLoc = (LudicTestLocator as SMTestLocator).getLocation("ludic", path, project, GlobalSearchScope.allScope(project)).single()
        assertEquals(file, fileLoc.psiElement)
    }

    fun testUrlSplitKeepsHashesInTestNames() {
        assertEquals("/a/b.ludic" to "x # y", LudicTestUrls.split("/a/b.ludic#x # y"))
        assertEquals("/a/b.ludic" to null, LudicTestUrls.split("/a/b.ludic"))
    }

    // ---- the output converter ---------------------------------------------

    private fun convert(vararg lines: String): List<String> {
        val type = ConfigurationTypeUtil.findConfigurationType(LudicConfigurationType::class.java)
        val c = type.factory.createTemplateConfiguration(project) as LudicRunConfiguration
        c.command = LudicCommand.TEST
        c.workingDirectory = "/proj"
        val props = LudicTestConsoleProperties(c, DefaultRunExecutor.getRunExecutorInstance())
        val out = mutableListOf<String>()
        val conv = object : LudicTestEventsConverter("Ludic", props, "/proj") {
            override fun forward(text: String, outputType: Key<*>) {
                if (text.startsWith("##teamcity")) out += text.trim()
            }
            fun feed(l: String) = processConsistentText(l + "\n", ProcessOutputTypes.STDOUT)
        }
        lines.forEach { conv.feed(it) }
        conv.flushBufferOnProcessTermination(0)
        return out.map { it.removePrefix("##teamcity[").substringBefore(" ") + " " + (Regex("name='([^']*)'").find(it)?.groupValues?.get(1) ?: "") }
    }

    fun testVerboseOutputBecomesATestTree() {
        val events = convert(
            "  RUN  tests/smoke.ludic",
            "ok   - adds",
            "smoke.ludic:12: expect_eq failed (got 1, want 2)",
            "FAIL - subtracts",
            "== 1 passed, 1 failed ==",
            "  [31mFAIL[0m tests/smoke.ludic  (exit 1)",
            "  RUN  tests/other.ludic",
            "ok   - x.ludic",
            "== 1 passed, 0 failed ==",
            "  [32mPASS[0m tests/other.ludic",
            "",
            "== 1 of 2 test files failed ==",
        )
        assertEquals(
            listOf(
                "testSuiteStarted tests/smoke.ludic",
                "testStarted adds", "testFinished adds",
                "testStarted subtracts", "testFailed subtracts", "testFinished subtracts",
                "testSuiteFinished tests/smoke.ludic",
                "testSuiteStarted tests/other.ludic",
                "testStarted x.ludic", "testFinished x.ludic",
                "testSuiteFinished tests/other.ludic",
            ),
            events
        )
    }

    fun testCompileFailureShowsAsAFailedNode() {
        val events = convert(
            "  RUN  tests/broken.ludic",
            "broken.ludic:2: error: unknown identifier zz",
            "  FAIL tests/broken.ludic  (did not compile)",
        )
        assertEquals(
            listOf(
                "testSuiteStarted tests/broken.ludic",
                "testStarted (compile)", "testFailed (compile)", "testFinished (compile)",
                "testSuiteFinished tests/broken.ludic",
            ),
            events
        )
    }

    fun testUnknownTestNameIsAFailure() {
        val events = convert("  RUN  tests/a.ludic", "no test named \"nope\"", "  FAIL tests/a.ludic  (exit 1)")
        assertEquals(
            listOf("testSuiteStarted tests/a.ludic", "testStarted nope", "testFailed nope", "testFinished nope", "testSuiteFinished tests/a.ludic"),
            events
        )
    }

    fun testOldToolchainOutputStillGivesFileResults() {
        // an install without --verbose: PASS lines alone, and a failing
        // file's runner output after its FAIL line
        val events = convert(
            "  PASS tests/a.ludic",
            "  FAIL tests/b.ludic  (exit 1)",
            "ok   - one",
            "FAIL - two",
            "== 1 passed, 1 failed ==",
            "  PASS tests/c.ludic",
            "",
            "== 1 of 3 test files failed ==",
        )
        assertEquals(
            listOf(
                "testSuiteStarted tests/a.ludic", "testSuiteFinished tests/a.ludic",
                "testSuiteStarted tests/b.ludic",
                "testStarted one", "testFinished one",
                "testStarted two", "testFailed two", "testFinished two",
                "testSuiteFinished tests/b.ludic",
                "testSuiteStarted tests/c.ludic", "testSuiteFinished tests/c.ludic",
            ),
            events
        )
    }

    // ---- console links -----------------------------------------------------

    fun testConsoleLinksResolveBaseNamesAcrossTheProject() {
        val file = myFixture.addFileToProject("tests/smoke.ludic", "program S {\n  test \"t\" { expect(false) }\n}\n")
        val filter = LudicConsoleFilter(project, "/nonexistent")
        val line = "smoke.ludic:2: expect failed\n"
        val result = filter.applyFilter(line, line.length)!!
        val item = result.resultItems.single()
        assertEquals(0, item.highlightStartOffset)
        assertEquals("smoke.ludic:2".length, item.highlightEndOffset)
        val info = item.hyperlinkInfo as OpenFileHyperlinkInfo
        assertEquals(file.virtualFile, info.descriptor!!.file)
        assertEquals(file.text.indexOf("  test"), info.descriptor!!.offset)
    }

    fun testConsoleLinksIgnoreOtherText() {
        val filter = LudicConsoleFilter(project, null)
        assertNull(filter.applyFilter("built build/demo\n", 17))
        assertNull(filter.applyFilter("missing.ludic:3: error\n", 23))
    }
}
