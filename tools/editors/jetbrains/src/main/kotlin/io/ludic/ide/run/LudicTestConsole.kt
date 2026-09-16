package io.ludic.ide.run

import com.intellij.execution.Executor
import com.intellij.execution.Location
import com.intellij.execution.PsiLocation
import com.intellij.execution.process.ProcessOutputTypes
import com.intellij.execution.testframework.TestConsoleProperties
import com.intellij.execution.testframework.sm.ServiceMessageBuilder
import com.intellij.execution.testframework.sm.SMCustomMessagesParsing
import com.intellij.execution.testframework.sm.runner.OutputToGeneralTestEventsConverter
import com.intellij.execution.testframework.sm.runner.SMTRunnerConsoleProperties
import com.intellij.execution.testframework.sm.runner.SMTestLocator
import com.intellij.openapi.project.Project
import com.intellij.openapi.util.Key
import com.intellij.openapi.vfs.LocalFileSystem
import com.intellij.psi.PsiManager
import com.intellij.psi.search.FilenameIndex
import com.intellij.psi.search.GlobalSearchScope
import io.ludic.ide.psi.LudicPsi
import java.io.File

class LudicTestConsoleProperties(config: LudicRunConfiguration, executor: Executor) :
    SMTRunnerConsoleProperties(config, FRAMEWORK, executor), SMCustomMessagesParsing {

    private val workDir = config.resolvedWorkingDirectory()

    init {
        isIdBasedTestTree = false
        isPrintTestingStartedTime = false
    }

    override fun getTestLocator(): SMTestLocator = LudicTestLocator

    override fun createTestEventsConverter(testFrameworkName: String, props: TestConsoleProperties): OutputToGeneralTestEventsConverter =
        LudicTestEventsConverter(testFrameworkName, props, workDir)

    companion object {
        const val FRAMEWORK = "Ludic"
    }
}

/**
 * Test URLs: `ludic://<absolute file>` for a file's suite and
 * `ludic://<absolute file>#<test name>` for one test block. The gutter icons
 * look test state up by the same string, so the two must agree exactly.
 */
object LudicTestUrls {
    const val PROTOCOL = "ludic"

    fun file(path: String) = "$PROTOCOL://$path"
    fun test(path: String, name: String) = "$PROTOCOL://$path#$name"

    /** (file, test name or null) from the part after `ludic://`. */
    fun split(path: String): Pair<String, String?> {
        val at = path.indexOf(".ludic#")
        return if (at < 0) path to null else path.substring(0, at + 6) to path.substring(at + 7)
    }
}

object LudicTestLocator : SMTestLocator {
    override fun getLocation(protocol: String, path: String, project: Project, scope: GlobalSearchScope): List<Location<*>> {
        if (protocol != LudicTestUrls.PROTOCOL) return emptyList()
        val (filePath, name) = LudicTestUrls.split(path)
        val vf = LocalFileSystem.getInstance().findFileByPath(filePath)
            ?: FilenameIndex.getVirtualFilesByName(File(filePath).name, scope).firstOrNull { it.path == filePath }
            ?: return emptyList()
        val psi = PsiManager.getInstance(project).findFile(vf) ?: return emptyList()
        if (name == null) return listOf(PsiLocation(psi))
        val el = LudicPsi.findTest(psi, name) ?: return listOf(PsiLocation(psi))
        return listOf(PsiLocation(el))
    }
}

/**
 * Turns `ludic test --verbose` output into test events.
 *
 * The runner's lines, as the CLI frames them:
 *
 *     RUN  tests/smoke.ludic
 *   smoke.ludic:12: expect_eq failed (got 1, want 2)   <- assertion, before its result
 *   ok   - adds
 *   FAIL - subtracts
 *   == 1 passed, 1 failed ==
 *     FAIL tests/smoke.ludic  (exit 1)
 *
 * Older toolchains have no --verbose: they print only `PASS file` for a
 * passing file and dump the runner output *after* `FAIL file`. Both shapes are
 * accepted, so a file-level result still shows with an old install.
 */
open class LudicTestEventsConverter(
    name: String,
    props: TestConsoleProperties,
    private val workDir: String,
) : OutputToGeneralTestEventsConverter(name, props) {

    private var suite: String? = null
    private var suitePath: String? = null
    private var testsInSuite = 0
    private var framed = false                // saw a RUN line: this CLI speaks --verbose
    private val pending = StringBuilder()     // assertion lines awaiting their test's result
    private val suiteOutput = StringBuilder() // everything else inside the suite (compile errors)

    override fun processConsistentText(text: String, outputType: Key<*>) {
        val line = ANSI.replace(text, "").trimEnd('\n', '\r')
        val t = line.trim()
        // runner lines start in column 0; the CLI's own lines are indented,
        // which is what keeps a test named "x.ludic" from reading as a file
        TEST_RESULT.matchEntire(line)?.let { m ->
            val (verdict, testName) = m.destructured
            if (suite == null) openSuite("tests", outputType)
            reportTest(testName, verdict == "ok", outputType)
            return
        }
        RUN.matchEntire(t)?.let { m ->
            framed = true
            closeSuite(outputType)
            openSuite(m.groupValues[1], outputType)
            return
        }
        FILE_RESULT.matchEntire(t)?.let { m ->
            val (verdict, file, why) = m.destructured
            if (!framed) closeSuite(outputType)
            if (suite == null) {
                openSuite(file, outputType)
                // legacy: a passing file prints nothing more; a failing one
                // dumps its runner output next, so keep the suite open for it
                if (verdict == "PASS") closeSuite(outputType)
                else if (why.contains("did not compile")) reportCompileFailure(outputType, why)
                return
            }
            if (verdict == "FAIL" && testsInSuite == 0) reportCompileFailure(outputType, why)
            closeSuite(outputType)
            return
        }
        NO_SUCH_TEST.matchEntire(t)?.let { m ->
            if (suite == null) openSuite("tests", outputType)
            pending.append(line).append('\n')
            reportTest(m.groupValues[1], false, outputType)
            return
        }
        if (t.startsWith("== ") && t.endsWith(" ==")) {
            if (FILES_SUMMARY.matches(t)) closeSuite(outputType)
            forward(text, outputType)
            return
        }
        if (suite != null) {
            if (ASSERTION.containsMatchIn(t)) pending.append(line).append('\n')
            else if (t.isNotEmpty()) suiteOutput.append(line).append('\n')
        }
        forward(text, outputType)
    }

    override fun flushBufferOnProcessTermination(code: Int) {
        closeSuite(ProcessOutputTypes.STDOUT)
        super.flushBufferOnProcessTermination(code)
    }

    private fun openSuite(file: String, outputType: Key<*>) {
        val abs = File(file).let { if (it.isAbsolute) it else File(workDir, file) }.path
        suite = file
        suitePath = abs
        testsInSuite = 0
        pending.setLength(0)
        suiteOutput.setLength(0)
        emit(ServiceMessageBuilder.testSuiteStarted(file).addAttribute("locationHint", LudicTestUrls.file(abs)), outputType)
    }

    private fun closeSuite(outputType: Key<*>) {
        val s = suite ?: return
        suite = null
        emit(ServiceMessageBuilder.testSuiteFinished(s), outputType)
    }

    private fun reportTest(name: String, passed: Boolean, outputType: Key<*>) {
        testsInSuite++
        val path = suitePath ?: return
        emit(ServiceMessageBuilder.testStarted(name).addAttribute("locationHint", LudicTestUrls.test(path, name)), outputType)
        if (!passed) {
            val message = pending.lines().firstOrNull { it.isNotBlank() }?.let { ASSERTION_PREFIX.replace(it, "") } ?: "test failed"
            emit(ServiceMessageBuilder.testFailed(name).addAttribute("message", message).addAttribute("details", pending.toString()), outputType)
        }
        emit(ServiceMessageBuilder.testFinished(name), outputType)
        pending.setLength(0)
    }

    /** A file that never ran shows as one failed node carrying the compiler's output. */
    private fun reportCompileFailure(outputType: Key<*>, why: String) {
        val path = suitePath ?: return
        val node = "(compile)"
        testsInSuite++
        emit(ServiceMessageBuilder.testStarted(node).addAttribute("locationHint", LudicTestUrls.file(path)), outputType)
        val details = suiteOutput.toString().ifBlank { why }
        val first = suiteOutput.lines().firstOrNull { it.isNotBlank() } ?: why.trim().removeSurrounding("(", ")")
        emit(ServiceMessageBuilder.testFailed(node).addAttribute("message", first).addAttribute("details", details), outputType)
        emit(ServiceMessageBuilder.testFinished(node), outputType)
    }

    private fun emit(msg: ServiceMessageBuilder, outputType: Key<*>) {
        forward("$msg\n", outputType)
    }

    /** Hands text on to the platform's parser; the tests intercept it here. */
    internal open fun forward(text: String, outputType: Key<*>) {
        super.processConsistentText(text, outputType)
    }

    private companion object {
        val ANSI = Regex("\\[[0-9;]*m")
        val RUN = Regex("RUN\\s+(.+\\.ludic)")
        val FILE_RESULT = Regex("(PASS|FAIL)\\s+(\\S.*?\\.ludic)(\\s+\\(.*\\))?")
        val TEST_RESULT = Regex("(ok|FAIL) +- (.*)")
        val NO_SUCH_TEST = Regex("no test named \"(.*)\"")
        val FILES_SUMMARY = Regex("== .*test files (passed|failed) ==")
        val ASSERTION = Regex("\\.ludic:\\d+: .*failed")
        val ASSERTION_PREFIX = Regex("^\\S+\\.ludic:\\d+: ")
    }
}
