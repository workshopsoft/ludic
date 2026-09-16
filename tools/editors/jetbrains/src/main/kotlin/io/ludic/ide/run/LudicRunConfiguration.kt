package io.ludic.ide.run

import com.intellij.execution.DefaultExecutionResult
import com.intellij.execution.ExecutionException
import com.intellij.execution.ExecutionResult
import com.intellij.execution.Executor
import com.intellij.execution.configurations.CommandLineState
import com.intellij.execution.configurations.ConfigurationFactory
import com.intellij.execution.configurations.ConfigurationTypeBase
import com.intellij.execution.configurations.GeneralCommandLine
import com.intellij.execution.configurations.LocatableConfigurationBase
import com.intellij.execution.configurations.LocatableRunConfigurationOptions
import com.intellij.execution.configurations.RunConfiguration
import com.intellij.execution.configurations.RunProfileState
import com.intellij.execution.configurations.RuntimeConfigurationError
import com.intellij.execution.process.KillableColoredProcessHandler
import com.intellij.execution.process.ProcessEvent
import com.intellij.execution.process.ProcessHandler
import com.intellij.execution.process.ProcessListener
import com.intellij.execution.process.ProcessTerminatedListener
import com.intellij.execution.runners.ExecutionEnvironment
import com.intellij.execution.runners.ProgramRunner
import com.intellij.execution.testframework.sm.SMTestRunnerConnectionUtil
import com.intellij.openapi.components.BaseState
import com.intellij.openapi.options.SettingsEditor
import com.intellij.openapi.project.Project
import com.intellij.openapi.util.NotNullLazyValue
import com.intellij.openapi.vfs.LocalFileSystem
import com.intellij.openapi.vfs.VfsUtil
import com.intellij.util.execution.ParametersListUtil
import io.ludic.ide.LudicIcons
import io.ludic.ide.LudicToolchain
import java.io.File

/** What a Ludic run configuration asks the `ludic` CLI to do. */
enum class LudicCommand(val cli: String, val label: String) {
    RUN("run", "Run"),
    BUILD("build", "Build"),
    TEST("test", "Test"),
    CUSTOM("", "Other ludic command");

    override fun toString() = label

    companion object {
        fun of(name: String?) = entries.firstOrNull { it.name == name } ?: RUN
    }
}

class LudicConfigurationType : ConfigurationTypeBase(
    ID, "Ludic", "Build, run or test a Ludic program with the ludic CLI",
    NotNullLazyValue.createValue { LudicIcons.FILE }
) {
    init {
        addFactory(LudicConfigurationFactory(this))
    }

    val factory: ConfigurationFactory get() = configurationFactories.single()

    companion object {
        const val ID = "LudicRunConfiguration"
    }
}

class LudicConfigurationFactory(type: LudicConfigurationType) : ConfigurationFactory(type) {
    override fun getId() = LudicConfigurationType.ID
    override fun createTemplateConfiguration(project: Project): RunConfiguration =
        LudicRunConfiguration(project, this, "Ludic")
    override fun getOptionsClass(): Class<out BaseState> = LudicRunOptions::class.java
}

class LudicRunOptions : LocatableRunConfigurationOptions() {
    var command by string(LudicCommand.RUN.name)
    /** The .ludic file; empty means "the project" (ludic finds the entry). */
    var file by string("")
    /** One test block to run, by its exact name; empty runs every test. */
    var testName by string("")
    var headless by property(false)
    /** Extra CLI arguments, or the whole command for CUSTOM (e.g. `fmt --check`). */
    var arguments by string("")
    var workingDirectory by string("")
    var env by map<String, String>()
    var passParentEnv by property(true)
}

class LudicRunConfiguration(project: Project, factory: ConfigurationFactory, name: String) :
    LocatableConfigurationBase<LudicRunOptions>(project, factory, name) {

    public override fun getOptions(): LudicRunOptions = super.getOptions() as LudicRunOptions

    var command: LudicCommand
        get() = LudicCommand.of(options.command)
        set(v) { options.command = v.name }
    var file: String
        get() = options.file ?: ""
        set(v) { options.file = v }
    var testName: String
        get() = options.testName ?: ""
        set(v) { options.testName = v }
    var headless: Boolean
        get() = options.headless
        set(v) { options.headless = v }
    var arguments: String
        get() = options.arguments ?: ""
        set(v) { options.arguments = v }
    var workingDirectory: String
        get() = options.workingDirectory ?: ""
        set(v) { options.workingDirectory = v }
    var env: Map<String, String>
        get() = options.env
        set(v) { options.env.clear(); options.env.putAll(v) }
    var passParentEnv: Boolean
        get() = options.passParentEnv
        set(v) { options.passParentEnv = v }

    override fun getConfigurationEditor(): SettingsEditor<out RunConfiguration> = LudicRunConfigurationEditor(project)

    override fun checkConfiguration() {
        if (LudicToolchain.cli(project) == null) {
            throw RuntimeConfigurationError("The 'ludic' command was not found. ${LudicToolchain.INSTALL_HINT}")
        }
        if (file.isNotBlank() && !File(file).isFile && !File(resolvedWorkingDirectory(), file).isFile) {
            throw RuntimeConfigurationError("No such file: $file")
        }
        if (command == LudicCommand.CUSTOM && arguments.isBlank()) {
            throw RuntimeConfigurationError("Name the ludic command to run, for example: fmt --check")
        }
    }

    override fun getState(executor: Executor, environment: ExecutionEnvironment): RunProfileState =
        LudicRunState(this, environment)

    override fun suggestedName(): String {
        val f = file.substringAfterLast('/').ifEmpty { project.name }
        return when (command) {
            LudicCommand.TEST -> if (testName.isNotEmpty()) "Test '$testName'" else "Test $f"
            LudicCommand.BUILD -> "Build $f"
            LudicCommand.RUN -> "Run $f"
            LudicCommand.CUSTOM -> "ludic $arguments"
        }
    }

    /**
     * The configured directory, else the package that owns the file (the
     * nearest directory with a package.ludic, which is where `ludic` expects
     * to run), else the project root.
     */
    fun resolvedWorkingDirectory(): String {
        if (workingDirectory.isNotBlank()) return workingDirectory
        val base = project.basePath
        if (file.isNotBlank()) {
            val f = File(file).let { if (it.isAbsolute) it else File(base ?: ".", file) }
            packageRootOf(f.parentFile)?.let { return it.path }
            return base ?: f.parent
        }
        return base ?: File(".").absolutePath
    }

    /** The argv after `ludic`, exactly as it will be passed. */
    fun cliArguments(): List<String> {
        val args = mutableListOf<String>()
        val extra = ParametersListUtil.parse(arguments)
        if (command == LudicCommand.CUSTOM) return extra
        args += command.cli
        if (file.isNotBlank()) args += relativeToWorkingDirectory(file)
        when (command) {
            LudicCommand.TEST -> {
                args += "--verbose"
                if (testName.isNotEmpty()) { args += "--test"; args += testName }
            }
            else -> if (headless) args += "--headless"
        }
        args += extra
        return args
    }

    private fun relativeToWorkingDirectory(path: String): String {
        val wd = File(resolvedWorkingDirectory())
        val f = File(path).let { if (it.isAbsolute) it else File(project.basePath ?: wd.path, path) }
        val rel = runCatching { f.canonicalFile.relativeTo(wd.canonicalFile).path }.getOrNull()
        return if (rel != null && !rel.startsWith("..")) rel else f.path
    }

    fun commandLine(): GeneralCommandLine {
        val cli = LudicToolchain.cli(project)
            ?: throw ExecutionException("The 'ludic' command was not found. ${LudicToolchain.INSTALL_HINT}")
        return GeneralCommandLine(cli)
            .withParameters(cliArguments())
            .withWorkDirectory(resolvedWorkingDirectory())
            .withEnvironment(env)
            .withParentEnvironmentType(
                if (passParentEnv) GeneralCommandLine.ParentEnvironmentType.CONSOLE
                else GeneralCommandLine.ParentEnvironmentType.NONE
            )
            .withCharset(Charsets.UTF_8)
    }

    companion object {
        /** The nearest directory at or above [dir] holding a package.ludic. */
        fun packageRootOf(dir: File?): File? {
            var d = dir
            while (d != null) {
                if (File(d, "package.ludic").isFile) return d
                d = d.parentFile
            }
            return null
        }
    }
}

class LudicRunState(private val config: LudicRunConfiguration, env: ExecutionEnvironment) : CommandLineState(env) {

    override fun startProcess(): ProcessHandler {
        val handler = KillableColoredProcessHandler(config.commandLine())
        ProcessTerminatedListener.attach(handler)
        // get/update/pack/build write files the IDE should see straight away
        val dir = config.resolvedWorkingDirectory()
        handler.addProcessListener(object : ProcessListener {
            override fun processTerminated(event: ProcessEvent) {
                LocalFileSystem.getInstance().findFileByPath(dir)?.let { VfsUtil.markDirtyAndRefresh(true, true, true, it) }
            }
        })
        return handler
    }

    override fun execute(executor: Executor, runner: ProgramRunner<*>): ExecutionResult {
        val filter = LudicConsoleFilter(config.project, config.resolvedWorkingDirectory())
        if (config.command != LudicCommand.TEST) {
            addConsoleFilters(filter)
            return super.execute(executor, runner)
        }
        val handler = startProcess()
        val props = LudicTestConsoleProperties(config, executor)
        val console = SMTestRunnerConnectionUtil.createAndAttachConsole(LudicTestConsoleProperties.FRAMEWORK, handler, props)
        console.addMessageFilter(filter)
        return DefaultExecutionResult(console, handler, *createActions(console, handler, executor))
    }
}
