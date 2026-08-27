#!/usr/bin/env python3
"""Guard against the failure mode this whole layout exists to prevent.

The Ludic vocabulary — keywords, types, phases, builtins, intrinsics — is
written down in five places that cannot include each other:

    compiler/**/*.c              BUILTINS[]      the language itself
    compiler/**/*.c              INTRINSICS[]    the language itself
    tools/ludic-tools/           ludic_syntax.h  the toolchain's source of truth
    tools/editors/shared/        the TextMate grammar (JSON, no includes)
    tools/editors/jetbrains/     LudicVocabulary (Kotlin, no includes)

Adding a builtin to the compiler and forgetting the rest is silent: the editor
just stops colouring it, and nobody notices for months. So it is checked.
"""
import json
import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
problems = []


def read(*parts):
    with open(os.path.join(ROOT, *parts)) as fh:
        return fh.read()


def c_string_list(text, name):
    """Names in `static const char* NAME[] = { "a", "b", 0 };`"""
    m = re.search(r"\b" + name + r"\s*\[\s*\]\s*=\s*\{(.*?)\}\s*;", text, re.S)
    if not m:
        problems.append(f"{name}: not found")
        return set()
    return set(re.findall(r'"([^"]+)"', m.group(1)))


def c_table_names(text, name):
    """First string of each row in a `{ "name", ... }` table."""
    m = re.search(r"\b" + name + r"\s*\[\s*\]\s*=\s*\{(.*?)\n\s*\}\s*;", text, re.S)
    if not m:
        problems.append(f"{name}: not found")
        return set()
    return set(re.findall(r'\{\s*"([^"]+)"', m.group(1)))


def kotlin_set(text, name):
    """Names in `val NAME = setOf(...)`, found by matching the parentheses —
    a non-greedy regex silently runs past a one-line setOf into the next one."""
    m = re.search(r"\bval\s+" + name + r"\s*=\s*setOf\(", text)
    if not m:
        problems.append(f"Kotlin {name}: not found")
        return set()
    i = m.end()
    depth = 1
    while i < len(text) and depth:
        if text[i] == "(":
            depth += 1
        elif text[i] == ")":
            depth -= 1
        i += 1
    body = re.sub(r"//[^\n]*", "", text[m.end():i - 1])
    return set(re.findall(r'"([^"]+)"', body))


def grammar_alternation(grammar, path, marker):
    """Names in a `\\b(a|b|c)\\b` match inside the TextMate grammar."""
    node = grammar
    for key in path:
        node = node[key]
    for pat in node:
        rx = pat.get("match", "")
        if marker in rx:
            inner = re.search(r"\\b\((.*?)\)\\b", rx)
            if inner:
                return set(inner.group(1).split("|"))
    problems.append(f"grammar: no rule containing {marker!r}")
    return set()


def compare(label, reference, other, other_label, ignore=frozenset()):
    missing = (reference - other) - ignore
    extra = (other - reference) - ignore
    if missing:
        problems.append(f"{other_label} is missing {label}: {', '.join(sorted(missing))}")
    if extra:
        problems.append(f"{other_label} has unknown {label}: {', '.join(sorted(extra))}")


syntax_h = read("tools", "ludic-tools", "ludic_syntax.h")
def read_table_owner(table):
    """Find whichever compiler translation unit declares a table.

    The compiler is split by concern and files move; hardcoding a path here
    turns a routine refactor into a spurious vocabulary failure.
    """
    import glob
    for path in sorted(glob.glob(os.path.join(ROOT, "compiler", "**", "*.c"), recursive=True)):
        text = open(path, encoding="utf-8").read()
        if re.search(r"\b%s\s*\[\s*\]" % re.escape(table), text):
            return text
    return None   # the compiler is now written in Ludic (selfhost/); no C table

ludicc_c = read_table_owner("BUILTINS")
native_c = read_table_owner("INTRINSICS")
kotlin = read("tools", "editors", "jetbrains", "src", "main", "kotlin", "io", "ludic", "ide", "LudicTokens.kt")
grammar = json.loads(read("tools", "editors", "shared", "ludic.tmLanguage.json"))

# --- the toolchain header is the reference ---------------------------------
h_decl = c_string_list(syntax_h, "LUDIC_KW_DECL")
h_clause = c_string_list(syntax_h, "LUDIC_KW_CLAUSE")
h_stmt = c_string_list(syntax_h, "LUDIC_KW_STMT")
h_types = c_string_list(syntax_h, "LUDIC_TYPES")
h_phases = c_string_list(syntax_h, "LUDIC_PHASES")
h_widgets = c_string_list(syntax_h, "LUDIC_WIDGETS")
h_builtins = c_table_names(syntax_h, "LUDIC_BUILTINS")
h_intrinsics = c_table_names(syntax_h, "LUDIC_INTRINSICS")

# --- against the compiler's builtin/intrinsic tables, when a C compiler is
#     present. The compiler is now written in Ludic (selfhost/), so this
#     cross-check is skipped; the editor tools remain checked against each other.
if ludicc_c is not None:
    compare("builtins", c_table_names(ludicc_c, "BUILTINS"), h_builtins, "ludic_syntax.h")
if native_c is not None:
    compare("intrinsics", c_table_names(native_c, "INTRINSICS"), h_intrinsics, "ludic_syntax.h")

# --- against the JetBrains lexer -------------------------------------------
compare("declaration keywords", h_decl, kotlin_set(kotlin, "DECL"), "LudicTokens.kt")
compare("clause keywords", h_clause, kotlin_set(kotlin, "CLAUSE"), "LudicTokens.kt")
compare("statement keywords", h_stmt, kotlin_set(kotlin, "STMT"), "LudicTokens.kt")
compare("primitive types", h_types, kotlin_set(kotlin, "PRIMITIVES"), "LudicTokens.kt")
compare("phases", h_phases, kotlin_set(kotlin, "PHASES"), "LudicTokens.kt")
compare("widgets", h_widgets, kotlin_set(kotlin, "WIDGETS"), "LudicTokens.kt")
compare("builtins", h_builtins | h_intrinsics, kotlin_set(kotlin, "BUILTINS"), "LudicTokens.kt")

# --- against the TextMate grammar ------------------------------------------
gpath = ["repository", "builtin", "patterns"]
compare("builtins", h_builtins, grammar_alternation(grammar, gpath, "rng_chance"), "ludic.tmLanguage.json")
compare("intrinsics", h_intrinsics, grammar_alternation(grammar, gpath, "mem_alloc"), "ludic.tmLanguage.json")
kpath = ["repository", "keyword", "patterns"]
compare("phases", h_phases, grammar_alternation(grammar, kpath, "FixedUpdate"), "ludic.tmLanguage.json")
compare("primitive types", h_types, grammar_alternation(grammar, kpath, "fixed"), "ludic.tmLanguage.json")

# --- against the actual self-hosted parser ---------------------------------
# The compiler moved to Ludic, so the old C cross-check (above) is dark. This
# replaces it: a declaration or clause keyword the highlighter colours must be
# one the parser actually dispatches on, or nobody notices when a keyword is
# highlighted but silently unparsed (exactly what happened to `scene`, `edge`,
# `needs`, …). RESERVED is the escape hatch for documented, not-yet-implemented
# keywords — and it is checked too, so a reserved word that gets implemented
# must be promoted out of it.
def parser_keywords():
    kws = set()
    for name in ("parse.ludic", "parse_game.ludic"):
        text = open(os.path.join(ROOT, "selfhost", name), encoding="utf-8").read()
        kws |= set(re.findall(r'is_id\("([a-z]+)"\)', text))
        kws |= set(re.findall(r'streq\(t\.text,\s*"([a-z]+)"\)', text))
    return kws

pkw = parser_keywords()
h_reserved = c_string_list(syntax_h, "LUDIC_KW_RESERVED")
if not pkw:
    problems.append("could not extract any keywords from selfhost/parse*.ludic")
else:
    for label, kws in (("declaration keywords", h_decl), ("clause keywords", h_clause)):
        unparsed = (kws - pkw) - h_reserved
        if unparsed:
            problems.append(f"ludic_syntax.h lists {label} the selfhost parser never dispatches on: {', '.join(sorted(unparsed))}")
    promoted = h_reserved & pkw
    if promoted:
        problems.append(f"LUDIC_KW_RESERVED lists keywords the parser now accepts — promote them into the highlighted vocabulary: {', '.join(sorted(promoted))}")

if problems:
    print("vocabulary drift:", file=sys.stderr)
    for p in problems:
        print("  -", p, file=sys.stderr)
    sys.exit(1)
sys.exit(0)
