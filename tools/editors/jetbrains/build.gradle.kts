import org.jetbrains.intellij.platform.gradle.TestFrameworkType
import org.jetbrains.intellij.platform.gradle.IntelliJPlatformType

plugins {
    id("java")
    id("org.jetbrains.kotlin.jvm") version "2.4.10"
    // The IntelliJ Platform Gradle Plugin 2.x. The 1.x line (org.jetbrains.intellij)
    // is superseded and does not run on current Gradle.
    id("org.jetbrains.intellij.platform") version "2.18.1"
}

group = providers.gradleProperty("pluginGroup").get()
version = providers.gradleProperty("pluginVersion").get()

repositories {
    mavenCentral()
    intellijPlatform {
        defaultRepositories()
    }
}

dependencies {
    testImplementation("junit:junit:4.13.2")
    intellijPlatform {
        // Community, deliberately: the plugin must work in the free IDEs, which
        // is also why the language server is wired up through LSP4IJ rather
        // than com.intellij.platform.lsp (Ultimate and friends only).
        // useInstaller = false takes the Maven artifact (com.jetbrains.intellij.idea:ideaIC)
        // instead of the .dmg/.tar.gz installer. Since 2025.x the Community installer is
        // published as `idea-<version>`, not `ideaIC-<version>`, and the installer path
        // cannot find it; the Maven coordinate is unaffected by that rename.
        intellijIdeaCommunity(providers.gradleProperty("platformVersion").get()) {
            useInstaller = false
        }
        bundledPlugin("org.intellij.plugins.markdown")
        plugin("com.redhat.devtools.lsp4ij", providers.gradleProperty("lsp4ijVersion").get())
        // JetBrains' Plugin Verifier CLI, used by the verifyPlugin task below
        pluginVerifier()
        // headless fixtures for the platform tests in src/test
        testFramework(TestFrameworkType.Platform)
    }
}

kotlin {
    jvmToolchain(17)
}

intellijPlatform {
    pluginConfiguration {
        name = providers.gradleProperty("pluginName")
        version = providers.gradleProperty("pluginVersion")
        ideaVersion {
            sinceBuild = providers.gradleProperty("pluginSinceBuild")
            untilBuild = providers.gradleProperty("pluginUntilBuild")
        }
    }
    // Compatibility is claimed up to pluginUntilBuild, so it gets checked
    // against that IDE rather than assumed: `./gradlew verifyPlugin` runs
    // JetBrains' own Plugin Verifier over the built artifact.
    pluginVerification {
        ides {
            // The platform this is compiled against, which is also the newest
            // that exists (2025.3 = build 253). until-build claims 262, which
            // no released IDE reaches yet.
            create(IntelliJPlatformType.IntellijIdeaCommunity, providers.gradleProperty("platformVersion").get()) {
                useInstaller = false
            }
        }
    }

    buildSearchableOptions = false

    // The platform's bytecode instrumenter only adds @NotNull assertions and
    // compiles .form files. This plugin is Kotlin with no GUI forms, so it has
    // nothing to instrument — and skipping it avoids the instrumenter's JBR
    // probing, which fails on a plain JDK layout.
    instrumentCode = false
}

// `./gradlew runIde` opens the Ludic repository itself, so the sandbox has real
// .ludic files to look at and build/ludic-lsp sitting where the plugin expects.
// Three levels up: jetbrains -> editors -> tools -> repository root. Getting
// this wrong points the IDE at tools/, where no build/ludic-lsp exists, and the
// language server then cannot find itself.
val repoRoot: File = rootProject.projectDir.parentFile.parentFile.parentFile
tasks.named<JavaExec>("runIde") {
    args = listOf(repoRoot.absolutePath)
}

tasks.test {
    useJUnit()
    testLogging {
        events("passed", "failed", "skipped")
        showStandardStreams = false
    }
}
