#!/usr/bin/env python3
"""check-docs.py — every ```ludic fence in the docs is checked against the
compiler, so documentation cannot drift away from the language.

A fence declares its own intent with an in-fence comment (`#` is a Ludic
comment, so the marker is valid code and visible to a reader):

    # doc-check: skip           illustrative or pseudo-syntax; not checked
    # doc-check: expect-error   must FAIL to compile (error demonstrations)

Anything else must PARSE. The gate is `ludicc --fmt`, not a full build: it runs
lex + parse, which is what catches syntax drift, but does not resolve
identifiers — so an excerpt may reference components and registers that live in
the surrounding program it was lifted from, and still be checked.

A bare fragment is wrapped first: a declaration list goes inside
`game DocCheck { ... }`, loose statements inside a Start system.
"""
import re, subprocess, sys, os, tempfile

LC = './build/ludicc'
DECL = ('program','property','model','handler','enum','function',
        'extern','const','var','ui','struct','import')

def classify(body):
    first = next((l.strip() for l in body.split('\n')
                  if l.strip() and not l.strip().startswith('#')), '')
    head = first.split('(')[0].split()[0] if first else ''
    if head == 'program': return 'whole'
    return 'decls' if head in DECL else 'stmts'

def wraps(body, kind):
    """Candidate framings, best guess first. An excerpt often mixes declarations
    with loose statements, so both are tried and either parsing counts."""
    if kind == 'whole': return [body]
    as_decls = 'program DocCheck {\n' + body + '\n}\n'
    as_stmts = 'program DocCheck {\n  handler DocS phase Start {\n' + body + '\n  }\n}\n'
    return [as_decls, as_stmts] if kind == 'decls' else [as_stmts, as_decls]

def fences(path):
    t = open(path).read()
    for m in re.finditer(r'^```ludic\n(.*?)^```', t, re.S | re.M):
        yield t[:m.start()].count('\n') + 1, m.group(1)

def main(argv):
    report = '--report' in argv
    docs = [p for p in argv if p.endswith('.md')]
    ok = bad = skipped = 0
    failures = []
    for path in docs:
        for line, body in fences(path):
            if '# doc-check: skip' in body:
                skipped += 1; continue
            expect_error = '# doc-check: expect-error' in body
            kind = classify(body)
            parsed, first_err = False, None
            for src in wraps(body, kind):
                with tempfile.NamedTemporaryFile('w', suffix='.ludic', delete=False) as f:
                    f.write(src); tmp = f.name
                # bytes, not text: a diagnostic may echo a partial multibyte char
                r = subprocess.run([LC, tmp, '--fmt'], capture_output=True)
                os.unlink(tmp)
                if r.returncode == 0: parsed = True; break
                # keep the best-guess framing's error; later ones are fallbacks
                if first_err is None: first_err = r.stderr
            if parsed != (not expect_error):
                bad += 1
                want = 'be rejected' if expect_error else 'parse'
                err = (first_err or b'').decode('utf-8','replace').strip().split('\n')[0]
                failures.append(f"{path}:{line}  expected to {want}: {err[:90]}")
            else:
                ok += 1
    print(f"  doc fences: {ok} as documented, {bad} drifted, {skipped} skipped")
    for f in failures: print(f"    {f}")
    if report: return 0
    return 1 if bad else 0

sys.exit(main(sys.argv[1:]))
