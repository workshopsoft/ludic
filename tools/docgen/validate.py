#!/usr/bin/env python3
"""Compile-validate every ```ludic example in the docs against the real ludicc.
Full programs (start with program/module) compile directly; fragments are wrapped
(as declarations, then as statements) like tools/check-docs.py. Reports failures."""
import os, re, subprocess, tempfile, sys
REPO=os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))); LC=os.path.join(REPO,"bin","ludicc")
FENCE=re.compile(r"```ludic\n(.*?)\n```", re.S)
DECL=("program","property","model","handler","enum","function","extern","const","var","ui","event","module","import","scene","machine")

def first_kw(body):
    for l in body.split("\n"):
        s=l.strip()
        if s and not s.startswith("#"): return s.split("(")[0].split()[0].split("{")[0]
    return ""

def candidates(body):
    kw=first_kw(body)
    if kw in ("program","module"): return [body]
    d="program DocCheck {\n"+body+"\n}\n"
    s="program DocCheck {\n  handler DocS phase Start {\n"+body+"\n  }\n}\n"
    return [d,s] if kw in DECL else [s,d]

def compiles(src, full):
    with tempfile.NamedTemporaryFile("w",suffix=".ludic",delete=False) as f:
        f.write(src); tmp=f.name
    flag=["--emit-llvm","-o",tmp+".ll"] if full else ["--fmt"]
    r=subprocess.run([LC,tmp]+flag,capture_output=True)
    os.unlink(tmp)
    try: os.unlink(tmp+".ll")
    except OSError: pass
    return r.returncode==0, (r.stderr or b"").decode("utf-8","replace").strip().split("\n")[0]

def files():
    for base in ("docs/language","docs/site/snippets"):
        for root,_,fs in os.walk(os.path.join(REPO,base)):
            for fn in fs:
                if fn.endswith(".md") or fn.endswith(".ludic"): yield os.path.join(root,fn)

ok=fail=skip=0; fails=[]
for p in files():
    t=open(p).read()
    blocks=FENCE.findall(t) if p.endswith(".md") else [t]
    for b in blocks:
        if 'import "' in b: skip+=1; continue
        good=False; err=""
        full = first_kw(b) in ("program","module")
        for cand in candidates(b):
            c,e=compiles(cand, full)
            if c: good=True; break
            if not err: err=e
        if good: ok+=1
        else: fail+=1; fails.append((os.path.relpath(p,REPO),err))
print(f"examples: {ok} compile, {fail} fail, {skip} skipped (import)")
for p,e in fails: print(f"  FAIL {p}: {e[:100]}")
sys.exit(1 if fail else 0)
