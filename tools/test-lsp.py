#!/usr/bin/env python3
"""Drive build/ludic-lsp over real LSP traffic against the real source tree.

Every assertion here is about a feature an editor actually calls: if this
passes, VS Code, JetBrains, Neovim and the rest are exercising code paths that
have been checked, because they all speak to this one binary.
"""
import json
import os
import subprocess
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SERVER = os.path.join(ROOT, "build", "ludic-lsp")

passed = 0
failed = 0


def check(name, got, want):
    global passed, failed
    if got == want:
        passed += 1
        print(f"  ok    {name}")
    else:
        failed += 1
        print(f"  FAIL  {name}\n        expected {want!r}, got {got!r}")


def check_true(name, cond, detail=""):
    check(name, bool(cond), True) if cond else check(name + (f" ({detail})" if detail else ""), False, True)


class Client:
    def __init__(self, cwd):
        self.p = subprocess.Popen([SERVER], stdin=subprocess.PIPE,
                                  stdout=subprocess.PIPE, cwd=cwd)
        self.diagnostics = {}

    def _send(self, obj):
        body = json.dumps(obj).encode()
        self.p.stdin.write(b"Content-Length: %d\r\n\r\n" % len(body) + body)
        self.p.stdin.flush()

    def _read(self):
        header = b""
        while not header.endswith(b"\r\n\r\n"):
            c = self.p.stdout.read(1)
            if not c:
                return None
            header += c
        length = int([l for l in header.decode().split("\r\n")
                      if l.lower().startswith("content-length")][0].split(":")[1])
        return json.loads(self.p.stdout.read(length))

    def request(self, method, params, _id=[0]):
        _id[0] += 1
        rid = _id[0]
        self._send({"jsonrpc": "2.0", "id": rid, "method": method, "params": params})
        while True:
            msg = self._read()
            if msg is None:
                raise RuntimeError(f"server closed during {method}")
            if msg.get("id") == rid:
                return msg.get("result")
            if msg.get("method") == "textDocument/publishDiagnostics":
                p = msg["params"]
                self.diagnostics[os.path.basename(p["uri"])] = [d["message"] for d in p["diagnostics"]]

    def notify(self, method, params):
        self._send({"jsonrpc": "2.0", "method": method, "params": params})

    def open(self, path, language_id="ludic"):
        with open(path) as fh:
            text = fh.read()
        self.notify("textDocument/didOpen", {"textDocument": {
            "uri": "file://" + path, "languageId": language_id, "version": 1, "text": text}})
        return text

    def close(self):
        try:
            self.request("shutdown", None)
            self.notify("exit", None)
        except Exception:
            pass
        self.p.kill()


def position_of(text, needle, offset=0):
    for i, line in enumerate(text.split("\n")):
        if needle in line:
            return {"line": i, "character": line.index(needle) + offset}
    raise AssertionError(f"{needle!r} not found")


def main():
    if not os.access(SERVER, os.X_OK):
        print("  skip  ludic-lsp missing")
        return 2

    c = Client(ROOT)
    caps = c.request("initialize", {"rootUri": "file://" + ROOT, "capabilities": {}})["capabilities"]
    c.notify("initialized", {})

    for cap in ["completionProvider", "hoverProvider", "definitionProvider",
                "referencesProvider", "renameProvider", "documentSymbolProvider",
                "workspaceSymbolProvider", "documentFormattingProvider",
                "semanticTokensProvider", "foldingRangeProvider",
                "signatureHelpProvider", "inlayHintProvider", "documentLinkProvider"]:
        check_true(f"advertises {cap}", cap in caps)

    # ---- a fragment file: no `game` block, only reachable through an import --
    frag = os.path.join(ROOT, "examples/chronorift/combat.ludic")
    text = c.open(frag)
    uri = {"uri": "file://" + frag}

    syms = c.request("textDocument/documentSymbol", {"textDocument": uri})
    check_true("document symbols in an imported fragment", len(syms) >= 3)

    # a field reached through a query binding, declared in ANOTHER file
    pos = position_of(text, "st.guard", 3)
    hov = c.request("textDocument/hover", {"textDocument": uri, "position": pos})
    check_true("hover resolves a field through a query binding",
               hov and "Stats.guard: int" in hov["contents"]["value"])

    d = c.request("textDocument/definition", {"textDocument": uri, "position": pos})
    check_true("go-to-definition crosses files", d and d["uri"].endswith("world.ludic"))

    # a binding is not yet inside its own scope at the point it is written, so
    # resolving it has to go through the declaration table, not scope lookup
    qpos = position_of(text, "for (e) in query", 5)
    qhov = c.request("textDocument/hover", {"textDocument": uri, "position": qpos})
    check_true("hover works on a query binding at its declaration site",
               qhov and "query binding" in qhov["contents"]["value"],
               json.dumps(qhov)[:80])

    comp = c.request("textDocument/completion", {"textDocument": uri,
                                                 "position": position_of(text, "st.guard", 3)})
    labels = [i["label"] for i in comp["items"]]
    check_true("completion after '.' offers only that component's fields",
               "guard" in labels and "hp" in labels and "clear" not in labels)

    # a query's term list admits components and archetypes and nothing else —
    # not the loop variables, not builtins, not keywords
    qsrc = ('game QT {\n  component Pos { x: int = 0 }\n  component Vel { dx: int = 0 }\n'
            '  system S phase Update {\n    for (a, b) in query [Pos, ] { }\n  }\n}\n')
    qfile = "/tmp/ludic_lsp_test_query.ludic"
    with open(qfile, "w") as fh:
        fh.write(qsrc)
    c.open(qfile)
    quri = {"uri": "file://" + qfile}
    qcomp = c.request("textDocument/completion",
                      {"textDocument": quri, "position": position_of(qsrc, "[Pos, ]", 6)})
    qlabels = sorted(i["label"] for i in qcomp["items"])
    check("completion inside query terms lists components only", qlabels, ["Pos", "Vel"])
    body = c.request("textDocument/completion",
                     {"textDocument": quri, "position": position_of(qsrc, "] { }", 3)})
    blabels = [i["label"] for i in body["items"]]
    check_true("completion in the loop body still has locals and builtins",
               "a" in blabels and "clear" in blabels)
    os.unlink(qfile)

    refs = c.request("textDocument/references", {"textDocument": uri,
                                                 "position": position_of(text, "query [Stats", 7),
                                                 "context": {"includeDeclaration": True}})
    files = {os.path.basename(r["uri"]) for r in refs}
    check_true("find-usages spans the compilation unit", len(files) >= 3, str(sorted(files)))

    hints = c.request("textDocument/inlayHint", {"textDocument": uri,
                                                 "range": {"start": {"line": 0, "character": 0},
                                                           "end": {"line": 9999, "character": 0}}})
    check_true("inlay hints name query binding types", any(": Stats" == h["label"] for h in hints))

    sig = c.request("textDocument/signatureHelp",
                    {"textDocument": uri, "position": position_of(text, "rng_chance(", 11)})
    check_true("signature help for a builtin",
               sig and sig["signatures"][0]["label"].startswith("rng_chance("))

    toks = c.request("textDocument/semanticTokens/full", {"textDocument": uri})
    check_true("semantic tokens produced", len(toks["data"]) // 5 > 100)
    check_true("semantic token stream is well formed", len(toks["data"]) % 5 == 0)

    folds = c.request("textDocument/foldingRange", {"textDocument": uri})
    check_true("folding ranges produced", len(folds) > 5)

    # ---- structural diagnostics arrive while typing --------------------------
    c.notify("textDocument/didChange", {"textDocument": {"uri": uri["uri"], "version": 2},
                                        "contentChanges": [{"text": text + "\n{ oops"}]})
    c.request("textDocument/documentSymbol", {"textDocument": uri})
    check_true("unbalanced brace reported while typing",
               any("unclosed" in m for m in c.diagnostics.get("combat.ludic", [])))

    # ---- the LSP analyses opened files on its own ----------------------------
    # (Deep semantic diagnostics once came from `ludicc --fmt`; the compiler is
    #  now written in Ludic and the LSP relies on its own parser. It still opens
    #  any file and answers structural queries without a compiler present.)
    bad = "/tmp/ludic_lsp_test_bad.ludic"
    with open(bad, "w") as fh:
        fh.write("game Bad {\n  component P { x: nosuchtype = 0 }\n}\n")
    c.open(bad)
    syms = c.request("textDocument/documentSymbol", {"textDocument": {"uri": "file://" + bad}})
    check_true("LSP opens and analyses a file with no compiler present",
               any(s["name"] == "Bad" for s in syms))
    os.unlink(bad)

    # ---- markdown: ```ludic fences are real Ludic ---------------------------
    md = "/tmp/ludic_lsp_test.md"
    with open(md, "w") as fh:
        fh.write("# Title\n\nprose\n\n```ludic\ngame D { component Pt { x: int = 0 } }\n```\n\n"
                 "```python\nz = 1\n```\n")
    c.open(md, "markdown")
    mduri = {"uri": "file://" + md}
    mdsyms = c.request("textDocument/documentSymbol", {"textDocument": mduri})
    check_true("symbols found inside a markdown fence", [s["name"] for s in mdsyms] == ["D"])
    mdtoks = c.request("textDocument/semanticTokens/full", {"textDocument": mduri})
    check("markdown tokens start on the fence body line", mdtoks["data"][0], 5)
    # A fence is a snippet: elisions and half-shown blocks are the documentation
    # doing its job, so errors there would be noise. Highlighting still applies.
    check("no diagnostics are reported for markdown", c.diagnostics.get("ludic_lsp_test.md"), [])
    fmt = c.request("textDocument/formatting", {"textDocument": mduri,
                                                "options": {"tabSize": 2, "insertSpaces": True}})
    check_true("markdown formatting leaves prose and other fences alone",
               "prose" in fmt[0]["newText"] and "z = 1" in fmt[0]["newText"])
    os.unlink(md)

    # the repository's own documentation must not light up with false errors
    for doc in ("LANGUAGE.md", "README.md", "COMPILING.md"):
        path = os.path.join(ROOT, doc)
        if not os.path.exists(path):
            continue
        c.open(path, "markdown")
        c.request("textDocument/documentSymbol", {"textDocument": {"uri": "file://" + path}})
        check(f"{doc} opens with no diagnostics", c.diagnostics.get(doc, []), [])
    lang = os.path.join(ROOT, "LANGUAGE.md")
    if os.path.exists(lang):
        t = c.request("textDocument/semanticTokens/full", {"textDocument": {"uri": "file://" + lang}})
        check_true("LANGUAGE.md fences are highlighted", len(t["data"]) // 5 > 100)

    # ---- rename has to be resolution-based, not textual ----------------------
    # `x` here is a field of Pos, a field of Vel, a local, and a parameter.
    # Renaming any one of them must leave the other three alone.
    amb = "/tmp/ludic_lsp_test_rename.ludic"
    with open(amb, "w") as fh:
        fh.write("game R {\n"
                 "  component Pos { x: int = 0, y: int = 0 }\n"
                 "  component Vel { x: int = 0 }\n"
                 "  fn helper(x: int) -> int { return x + 1 }\n"
                 "  system A phase Update {\n"
                 "    for (p) in query [Pos] {\n"
                 "      let x = 5\n"
                 "      p.x = p.x + x\n"
                 "    }\n"
                 "  }\n"
                 "  system B phase Update {\n"
                 "    for (v) in query [Vel] { v.x = v.x + 1 }\n"
                 "  }\n"
                 "}\n")
    atext = c.open(amb)
    auri = {"uri": "file://" + amb}

    def rename_at(pos):
        r = c.request("textDocument/rename",
                      {"textDocument": auri, "position": pos, "newName": "ZZZ"})
        if not r or not r.get("changes"):
            return []
        return list(r["changes"].values())[0]

    def lines_touched(edits):
        return sorted({e["range"]["start"]["line"] for e in edits})

    field = rename_at(position_of(atext, "component Pos { x", 16))
    check("renaming Pos.x touches only its declaration and its uses",
          lines_touched(field), [1, 7])
    local = rename_at(position_of(atext, "let x = 5", 4))
    check("renaming a local touches only that local", lines_touched(local), [6, 7])
    param = rename_at(position_of(atext, "fn helper(x", 10))
    check("renaming a parameter touches only that function", lines_touched(param), [3])
    check("renaming a parameter makes exactly two edits", len(param), 2)

    # find-usages must be equally precise
    refs_x = c.request("textDocument/references",
                       {"textDocument": auri,
                        "position": position_of(atext, "component Vel { x", 16),
                        "context": {"includeDeclaration": True}})
    check("find-usages of Vel.x does not pick up Pos.x",
          sorted({r["range"]["start"]["line"] for r in refs_x}), [2, 11])
    os.unlink(amb)

    # ---- workspace-wide symbol search ---------------------------------------
    ws = c.request("workspace/symbol", {"query": "Stats"})
    check_true("workspace symbol search finds a component", any(s["name"] == "Stats" for s in ws))

    c.close()
    print(f"  {passed} passed, {failed} failed")
    return 1 if failed else 0


if __name__ == "__main__":
    sys.exit(main())
