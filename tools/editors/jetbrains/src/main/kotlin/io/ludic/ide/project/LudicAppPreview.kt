package io.ludic.ide.project

import com.intellij.openapi.util.text.StringUtil
import java.io.File

private fun esc(s: String) = StringUtil.escapeXmlEntities(s)

private fun StringBuilder.row(k: String, v: String) {
    append("<tr><td valign='top' class='section'><p>").append(k).append("</p></td><td valign='top'>").append(v).append("</td></tr>")
}

private fun resolve(dir: File?, value: String): File? {
    if (value.isBlank()) return null
    val f = File(value)
    return if (f.isAbsolute) f else dir?.let { File(it, value) }
}

/** The app a manifest's `app` lines describe, as `ludic bundle` would build it. */
object LudicAppPreview {
    fun html(m: LudicManifest, dir: File?, highlight: String? = null): String {
        val app = m.app
        val name = appName(m, dir)
        fun img(key: String, size: Int): String? {
            val f = app[key]?.let { resolve(dir, it) }?.takeIf { it.isFile } ?: return null
            return "<img src='${f.toURI()}' width='$size' height='$size'>"
        }
        fun mark(k: String, v: String) = if (k == highlight) "<b>$v</b>" else v
        return buildString {
            append("<div class='definition'><pre>").append(esc(name)).append(".app</pre></div>")
            append("<div class='content'><table><tr><td valign='top'>")
            append(img("icon", 64) ?: "")
            append("</td><td valign='top'><p><b>").append(esc(name)).append("</b></p><p>")
            append(esc(app["id"] ?: "(no bundle id)")).append("<br>version ")
            append(esc(app["version"] ?: m.version ?: "0.1.0"))
            app["category"]?.let { append("<br>").append(esc(it.removePrefix("public.app-category."))) }
            app["min_macos"]?.let { append("<br>macOS ").append(esc(it)).append("+") }
            append("</p></td></tr></table>")
            app["splash"]?.let { s ->
                val f = resolve(dir, s)
                val bg = app["splash_bg"] ?: "#000000"
                append("<p>Splash</p><table><tr><td bgcolor='").append(esc(bg)).append("'>")
                if (f?.isFile == true) append("<img src='").append(f.toURI()).append("' width='240'>") else append("&nbsp;missing: ").append(esc(s))
                append("</td></tr></table>")
            }
            append("</div><table class='sections'>")
            for ((k, help) in LudicManifest.APP_KEYS) {
                val v = app[k] ?: continue
                val shown = if (k == "splash_bg") "<span style='background-color:${esc(v)}'>&nbsp;&nbsp;&nbsp;&nbsp;</span> ${esc(v)}" else esc(v)
                row(mark(k, k), mark(k, shown) + "<br><span class='grayed'>${esc(help)}</span>")
            }
            append("</table>")
            m.entry?.let { append("<div class='bottom'>entry ").append(esc(it)).append("</div>") }
        }
    }

    fun appName(m: LudicManifest, dir: File?) = m.app["name"] ?: m.module?.substringAfterLast('/') ?: dir?.name ?: "app"
}

/** The Ludic tool window's details pane: one page per kind of node. */
object LudicPackageHtml {

    fun overview(p: LudicPackageInfo): String = buildString {
        val m = p.manifest
        append("<div class='definition'><pre>").append(esc(m.module ?: p.dir.name)).append("</pre></div><div class='content'>")
        val kind = m.kind ?: "source"
        val what = when {
            m.app.isNotEmpty() -> "A game or app, shipped as <b>${esc(LudicAppPreview.appName(m, p.dir))}</b> by <code>ludic bundle</code>."
            m.entry != null -> "A program: <code>ludic run</code> starts <code>${esc(m.entry)}</code>."
            else -> "A library other packages import."
        }
        append("<p>").append(what).append("</p>")
        LudicManifest.KINDS[kind]?.let { append("<p><b>").append(esc(kind)).append("</b>: ").append(esc(it)).append("</p>") }
        append("</div><table class='sections'>")
        row("Version", esc(m.version ?: "(none)") + (m.version?.let { " <span class='grayed'>published by tag v${esc(it)}</span>" } ?: ""))
        m.entry?.let { row("Entry", pathCell(p, it)) }
        row("Location", "<code>${esc(p.dir.path)}</code>")
        row("Dependencies", depSummary(p))
        if (m.scripts.isNotEmpty()) row("Scripts", m.scripts.joinToString(" ") { "<code>${esc(it.name)}</code>" })
        if (m.hooks.isNotEmpty()) row("Hooks", m.hooks.joinToString("<br>") { "${esc(it.phase)} ${esc(it.event)}: <code>${esc(it.command)}</code>" })
        if (m.packs.isNotEmpty()) row("Asset roots", "${m.packs.size}, " + m.packs.count { resolve(p.dir, it)?.exists() != true }.let { if (it == 0) "all present" else "<b>$it missing</b>" })
        m.app["name"]?.let { row("App", "${esc(it)} <span class='grayed'>${esc(m.app["id"] ?: "")}</span>") }
        append("</table>")
    }

    private fun depSummary(p: LudicPackageInfo): String {
        val reqs = p.manifest.requires
        if (reqs.isEmpty()) return "none" + (if (p.transitive.isNotEmpty()) "" else " — everything comes with the toolchain")
        val bad = reqs.count { p.status(it) != LudicPackageInfo.DepStatus.OK }
        val base = "${reqs.size} direct, ${p.transitive.size} through them"
        return p.staleReason?.let { "$base<br><b>${esc(it)}</b>" } ?: if (bad == 0) "$base, all fetched" else "$base, <b>$bad need fetching</b>"
    }

    private fun pathCell(p: LudicPackageInfo, v: String): String {
        val ok = resolve(p.dir, v)?.exists() == true
        return "<code>${esc(v)}</code>" + if (ok) "" else " <b>missing</b>"
    }

    fun dependency(p: LudicPackageInfo, req: LudicManifest.Require): String = buildString {
        append("<div class='definition'><pre>require \"").append(esc(req.module)).append("\" \"").append(esc(req.version)).append("\"</pre></div>")
        append("<div class='content'><p>Needs at least <b>").append(esc(req.version)).append("</b>; Minimum Version Selection picks the lowest version that satisfies every requirement.</p></div>")
        append("<table class='sections'>")
        row("Status", esc(p.status(req).label))
        p.lockedOf(req.module)?.let { lockedRows(it) }
        row("On disk", p.linkedDir(req.module)?.let { "<code>${esc(it.path)}</code>" } ?: "not linked — Fetch")
        append("</table>")
    }

    fun locked(p: LudicPackageInfo, l: LudicManifest.Locked): String = buildString {
        append("<div class='definition'><pre>").append(esc(l.module)).append("</pre></div>")
        append("<div class='content'><p>Pulled in by a dependency, not required here directly.</p></div><table class='sections'>")
        lockedRows(l)
        row("On disk", p.linkedDir(l.module)?.let { "<code>${esc(it.path)}</code>" } ?: "not linked — Fetch")
        append("</table>")
    }

    private fun StringBuilder.lockedRows(l: LudicManifest.Locked) {
        row("Locked", esc(l.version))
        row("Kind", esc(l.kind))
        if (l.provides.isNotEmpty()) row("Provides", l.provides.joinToString { "<code>${esc(it)}.*</code>" })
        row("Hash", "<code>${esc(l.hash)}</code>")
    }

    fun lock(p: LudicPackageInfo): String = buildString {
        append("<div class='definition'><pre>").append(LudicManifest.LOCK_NAME).append("</pre></div><div class='content'>")
        append("<p>Written by <code>ludic get</code>: the exact version and content hash of every package the build uses, so every checkout builds the same thing. Commit it; do not edit it.</p>")
        val state = when {
            p.manifest.requires.isEmpty() && p.locked.isNullOrEmpty() -> "Nothing to lock: this package has no dependencies."
            p.staleReason != null -> "<b>${esc(p.staleReason!!)}</b> Fetch to bring it up to date."
            else -> "Up to date with package.ludic."
        }
        append("<p>").append(state).append("</p></div><table class='sections'>")
        p.locked?.forEach { row(esc(it.module), "${esc(it.version)} <span class='grayed'>${esc(it.hash.take(12))}…</span>") }
        append("</table>")
    }

    fun command(p: LudicPackageInfo, c: LudicPackageInfo.Command): String = buildString {
        append("<div class='definition'><pre>ludic ").append(c.verb).append("</pre></div><div class='content'><p>").append(esc(c.help)).append("</p>")
        if (c.verb in setOf("run", "build", "bundle")) p.manifest.entry?.let { append("<p>Entry: <code>").append(esc(it)).append("</code></p>") }
        hooks(p, c.verb)
        append("</div>")
    }

    fun script(p: LudicPackageInfo, s: LudicManifest.Script): String = buildString {
        val how = if (s.name in LudicManifest.BUILTIN_COMMANDS) "ludic script ${s.name}" else "ludic ${s.name}"
        append("<div class='definition'><pre>").append(esc(how)).append("</pre></div><div class='content'>")
        append("<p>Runs <code>").append(esc(s.command)).append("</code> from the package root; extra arguments are passed on.</p>")
        hooks(p, s.name)
        append("</div>")
    }

    fun hook(h: LudicManifest.Hook): String = buildString {
        append("<div class='definition'><pre>hook ").append(esc(h.phase)).append(' ').append(esc(h.event)).append("</pre></div><div class='content'>")
        append("<p><code>").append(esc(h.command)).append("</code></p>")
        LudicManifest.HOOK_PHASES[h.phase]?.let { append("<p>").append(esc(it)).append("</p>") }
        append("<p>Runs through the shell in the package root with <code>LUDIC_EVENT</code>, <code>LUDIC_PHASE</code> and <code>LUDIC_PACKAGE_ROOT</code> set.</p></div>")
    }

    fun assets(p: LudicPackageInfo): String = buildString {
        append("<div class='definition'><pre>pack</pre></div><div class='content'><p>")
            .append(esc(LudicManifest.DIRECTIVES["pack"] ?: "")).append("</p></div><table class='sections'>")
        p.manifest.packs.forEach { v ->
            val f = resolve(p.dir, v)
            row("<code>${esc(v)}</code>", if (f?.exists() != true) "<b>missing</b>" else if (f.isDirectory) "directory" else "file")
        }
        append("</table>")
    }

    private fun StringBuilder.hooks(p: LudicPackageInfo, event: String) {
        val hs = p.hooksOf(event)
        if (hs.isEmpty()) return
        append("<p>Hooks:</p><ul>")
        hs.forEach { append("<li>").append(esc(it.phase)).append(": <code>").append(esc(it.command)).append("</code></li>") }
        append("</ul>")
    }
}
