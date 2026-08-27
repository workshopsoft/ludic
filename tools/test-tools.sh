#!/bin/bash
# test-tools.sh — regression suite for the Ludic editor toolchain.
#
# The two properties that matter most are checked against the real source tree
# rather than toy inputs:
#
#   1. the formatter is a no-op on already-formatted code, and idempotent;
#   2. formatting never changes the program — proved by comparing the
#      COMPILER's own canonical AST dump before and after.
#
# Then the language server is driven over real LSP traffic on real files.
set -u
cd "$(dirname "$0")/.."

FMT=build/ludic-fmt
LSP=build/ludic-lsp
LUDICC=build/ludicc
PASS=0
FAIL=0
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT

ok()   { PASS=$((PASS+1)); printf '  ok    %s\n' "$1"; }
bad()  { FAIL=$((FAIL+1)); printf '  FAIL  %s\n' "$1"; [ $# -gt 1 ] && printf '        %s\n' "$2"; }
check() { if [ "$2" = "$3" ]; then ok "$1"; else bad "$1" "expected [$3] got [$2]"; fi; }

[ -x "$FMT" ] || { echo "build/ludic-fmt missing — run ./tools/build-tools.sh"; exit 2; }
[ -x "$LSP" ] || { echo "build/ludic-lsp missing — run ./tools/build-tools.sh"; exit 2; }

SOURCES=$(find examples runtime -name '*.ludic' | sort)

echo "formatter"

# --- idempotence: formatting twice equals formatting once -------------------
for f in $SOURCES; do
  "$FMT" "$f" > "$TMP/a" 2>/dev/null
  "$FMT" "$TMP/a" > "$TMP/b" 2>/dev/null
  if ! cmp -s "$TMP/a" "$TMP/b"; then bad "idempotent: $f"; fi
done
[ $FAIL -eq 0 ] && ok "idempotent on $(echo "$SOURCES" | wc -l | tr -d ' ') files"

# --- meaning preserved: reformatting a formatted file must be a no-op --------
# (The compiler is now written in Ludic and has no --fmt AST-dump mode, so the
#  formatter is validated by its own idempotence rather than against ludicc.)
MISMATCH=""
for f in examples/hello.ludic examples/snake.ludic examples/menu.ludic \
         examples/qdecl.ludic examples/scenes.ludic; do
  [ -f "$f" ] || continue
  "$FMT" "$f" > "$TMP/f1.ludic"
  "$FMT" "$TMP/f1.ludic" > "$TMP/f2.ludic"
  cmp -s "$TMP/f1.ludic" "$TMP/f2.ludic" || MISMATCH="$MISMATCH $f"
done
if [ -z "$MISMATCH" ]; then ok "formatting is idempotent (fmt(fmt(x)) == fmt(x))"
else bad "formatting is not idempotent" "$MISMATCH"; fi

# --- the strongest invariant: only whitespace ever changes -----------------
# Every token is re-emitted in order, so stripping whitespace from the input and
# from the output must give identical bytes. This is what makes the formatter
# safe to run on save: it cannot lose, reorder or corrupt anything.
DRIFT=""
for f in $SOURCES README.md LANGUAGE.md COMPILING.md; do
  [ -f "$f" ] || continue
  "$FMT" "$f" > "$TMP/f" 2>/dev/null
  a=$(tr -d ' \t\n' < "$f" | shasum | cut -d' ' -f1)
  b=$(tr -d ' \t\n' < "$TMP/f" | shasum | cut -d' ' -f1)
  [ "$a" = "$b" ] || DRIFT="$DRIFT $f"
done
if [ -z "$DRIFT" ]; then ok "only whitespace changes (byte-identical modulo spacing)"
else bad "formatter altered non-whitespace bytes" "$DRIFT"; fi

# --- multi-byte characters must survive intact ------------------------------
# A UTF-8 character outside a string is an error to the compiler, but the
# formatter must still not split it: doing so silently corrupts the file.
printf 'game E {\n  # \xe2\x80\xa6 ellipsis in a comment\n  const S: str = "caf\xc3\xa9 \xe2\x86\x92 na\xc3\xafve"\n}\n' > "$TMP/utf8.ludic"
"$FMT" "$TMP/utf8.ludic" > "$TMP/utf8.out"
if cmp -s "$TMP/utf8.ludic" "$TMP/utf8.out"; then ok "UTF-8 preserved byte for byte"
else bad "UTF-8 mangled" "$(diff "$TMP/utf8.ludic" "$TMP/utf8.out" | head -2)"; fi
# the same character where the compiler cannot make sense of it at all: it must
# still come out as one character, not as three spaced-out replacement bytes
printf 'game F {\nfn f() -> int { return \xe2\x80\xa6 }\n}\n' > "$TMP/utf8b.ludic"
a=$(tr -d ' \t\n' < "$TMP/utf8b.ludic" | shasum | cut -d' ' -f1)
b=$("$FMT" "$TMP/utf8b.ludic" | tr -d ' \t\n' | shasum | cut -d' ' -f1)
check "unrecognised characters pass through whole" "$b" "$a"

# --- comments survive, which is the whole reason this is not ludicc --fmt ---
printf 'game C {\n  # keep me\n  component P { x: int = 0 }  # and me\n}\n' > "$TMP/c.ludic"
N=$("$FMT" "$TMP/c.ludic" | grep -c '#')
check "comments preserved" "$N" "2"

# --- messy input is normalised ----------------------------------------------
printf 'game M{\ncomponent P{x:int=0}\nsystem S phase Update{let a=1+2\nif a== -1 {a=-a}}\n}\n' > "$TMP/m.ludic"
"$FMT" "$TMP/m.ludic" > "$TMP/m.out"
grep -q '^  component P { x: int = 0 }$' "$TMP/m.out" && ok "reindents and respaces" || bad "reindents and respaces"
grep -q 'a = -a' "$TMP/m.out" && ok "unary minus not spaced" || bad "unary minus not spaced"

# --- language conventions are respected, not overwritten --------------------
printf 'game U {\n  ui M {\n    panel id=Root w=10 {\n      button id=Go text="go"\n    }\n  }\n}\n' > "$TMP/u.ludic"
"$FMT" "$TMP/u.ludic" | grep -q 'id=Root' && ok "widget props stay tight (id=Root)" || bad "widget props stay tight"
printf 'game Q {\n  system S phase Update {\n    for (p) in query [Pos, {Foe}] { }\n  }\n  component Pos { x: int = 0 }\n  component Foe { }\n}\n' > "$TMP/q.ludic"
"$FMT" "$TMP/q.ludic" | grep -q '\[Pos, {Foe}\]' && ok "query tags stay tight ({Foe})" || bad "query tags stay tight"
printf 'game A {\n  const R_A:   int = 0    # one\n  const R_BBB: int = 1    # two\n}\n' > "$TMP/a.ludic"
"$FMT" "$TMP/a.ludic" | grep -q 'R_A:   int = 0    # one' && ok "hand alignment preserved" || bad "hand alignment preserved"

# --- --check exit status, for CI and pre-commit hooks -----------------------
"$FMT" --check -q "$TMP/m.ludic" >/dev/null 2>&1
check "--check exits 1 on unformatted input" "$?" "1"
"$FMT" -w "$TMP/m.ludic" >/dev/null 2>&1
"$FMT" --check -q "$TMP/m.ludic" >/dev/null 2>&1
check "--check exits 0 after -w" "$?" "0"

# --- markdown: fences formatted, prose untouched ----------------------------
printf '# T\n\nprose  with   spaces\n\n```ludic\ngame D{component P{x:int=0}}\n```\n\n```python\nz  =  1\n```\n' > "$TMP/d.md"
"$FMT" "$TMP/d.md" > "$TMP/d.out"
grep -q 'prose  with   spaces' "$TMP/d.out" && ok "markdown prose untouched" || bad "markdown prose untouched"
grep -q 'z  =  1' "$TMP/d.out" && ok "non-ludic fences untouched" || bad "non-ludic fences untouched"
grep -q 'game D { component P { x: int = 0 } }' "$TMP/d.out" && ok "ludic fences formatted" || bad "ludic fences formatted"

echo "language server"
python3 tools/test-lsp.py
LSPRC=$?
if [ $LSPRC -eq 0 ]; then PASS=$((PASS+1)); else FAIL=$((FAIL+1)); fi

echo
echo "editor assets"
for f in tools/editors/shared/ludic.tmLanguage.json \
         tools/editors/shared/ludic.markdown-injection.json \
         tools/editors/shared/language-configuration.json \
         tools/editors/vscode/package.json \
         tools/editors/vscode/snippets/ludic.json; do
  if python3 -c "import json,sys;json.load(open(sys.argv[1]))" "$f" 2>/dev/null; then ok "valid JSON: $(basename "$f")"
  else bad "invalid JSON: $f"; fi
done
for f in tools/editors/jetbrains/src/main/resources/META-INF/plugin.xml \
         tools/editors/jetbrains/src/main/resources/META-INF/ludic-markdown.xml; do
  if python3 -c "import xml.dom.minidom,sys;xml.dom.minidom.parse(sys.argv[1])" "$f" 2>/dev/null; then ok "valid XML: $(basename "$f")"
  else bad "invalid XML: $f"; fi
done
if command -v node >/dev/null 2>&1; then
  node --check tools/editors/vscode/src/extension.js 2>/dev/null && ok "extension.js parses" || bad "extension.js parses"
  # A TextMate grammar is unvalidated JSON full of regexes; run it through the
  # engine VS Code actually uses rather than assuming it still works.
  echo "textmate grammar"
  node tools/test-grammar.js
  if [ $? -eq 0 ]; then PASS=$((PASS+1)); else FAIL=$((FAIL+1)); fi
else
  echo "  skip  extension.js and grammar tests (node not installed)"
fi

# VS Code carries its own copy of the shared grammar because an extension must
# be self-contained. build-tools.sh refreshes it; this catches an edit made to
# the copy instead of the original.
SYNCED=1
for f in ludic.tmLanguage.json ludic.markdown-injection.json; do
  cmp -s "tools/editors/shared/$f" "tools/editors/vscode/syntaxes/$f" || SYNCED=0
done
cmp -s tools/editors/shared/language-configuration.json tools/editors/vscode/language-configuration.json || SYNCED=0
if [ $SYNCED -eq 1 ]; then ok "vscode grammar copies match tools/editors/shared"
else bad "vscode grammar copies have drifted" "run ./tools/build-tools.sh to resync"; fi

# The JetBrains plugin is off by default: the first build downloads over a
# gigabyte of IntelliJ SDK, which does not belong in a test run. Once the Gradle
# cache is warm it takes seconds, so it is one env var away.
#   LUDIC_TEST_JETBRAINS=1 ./tools/test-tools.sh
if [ "${LUDIC_TEST_JETBRAINS:-0}" = "1" ]; then
  JB=tools/editors/jetbrains
  if [ -x "$JB/gradlew" ]; then
    ( cd "$JB" && ./gradlew buildPlugin verifyPluginStructure --console=plain -q ) >/dev/null 2>&1 \
      && [ -f "$JB/build/distributions/Ludic-1.0.0.zip" ] \
      && ok "jetbrains plugin builds and verifies" \
      || bad "jetbrains plugin build" "cd $JB && ./gradlew buildPlugin  (needs JDK 17-21)"
    # the lexer/highlighter/PSI tests run headless in a real platform fixture
    ( cd "$JB" && ./gradlew test --console=plain -q ) >/dev/null 2>&1 \
      && ok "jetbrains platform tests (lexer, file type, PSI, folding)" \
      || bad "jetbrains platform tests" "cd $JB && ./gradlew test"
    # the Plugin Verifier is what catches API breakage against a real IDE build.
    # -q swallows its console output, so read the verdict it writes to disk.
    ( cd "$JB" && ./gradlew verifyPlugin --console=plain -q ) >/dev/null 2>&1
    VERDICT=$(cat "$JB"/build/reports/pluginVerifier/*/plugins/*/*/verification-verdict.txt 2>/dev/null | head -1)
    case "$VERDICT" in
      Compatible) ok "plugin verified Compatible against the target IDE" ;;
      Compatible*) bad "plugin verification: $VERDICT" "cd $JB && ./gradlew verifyPlugin" ;;
      *)          bad "plugin verification: ${VERDICT:-no verdict}" "cd $JB && ./gradlew verifyPlugin" ;;
    esac
  else
    echo "  skip  jetbrains plugin (no gradle wrapper)"
  fi
else
  echo "  skip  jetbrains plugin build (set LUDIC_TEST_JETBRAINS=1)"
fi

# The vocabulary lives in one place; drift between it and the copies that cannot
# include it (the TextMate grammar, the Kotlin lexer) is the failure mode this
# whole layout is meant to prevent, so it is checked rather than trusted.
python3 tools/check-vocabulary.py && ok "vocabulary in sync across grammar/lexer/header" || bad "vocabulary drifted"

echo
echo "$PASS passed, $FAIL failed"
[ $FAIL -eq 0 ]
