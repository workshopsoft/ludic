#!/usr/bin/env python3
# smoke.py - runs smoke.txt against a ui-preview binary and checks each reply: `> ` lines are requests,
# `< ` a reply line must contain the text (in order), `<= ` the exact final line, `<! ` no line may
#   python3 tools/ui-preview/smoke.py tools/ui-preview/smoke.txt bin/ludic-ui-preview
import subprocess, sys
reqs, exp = [], []
for line in open(sys.argv[1]):
    line = line.rstrip("\n")
    if line.startswith("> ") or line == ">": reqs.append(line[2:]); exp.append([])
    elif line.startswith(("< ", "<= ", "<! ")) and reqs:
        k, _, t = line.partition(" "); exp[-1].append((k, t))
p = subprocess.run([sys.argv[2]], input="\n".join(reqs) + "\n", capture_output=True, text=True, errors="replace", timeout=60)
out = p.stdout.splitlines()
replies, cur = [], []
for l in out:
    cur.append(l)
    if l == "ok" or l.startswith("ok ") or l.startswith("fail"):
        replies.append(cur); cur = []
bad = 0
print(f"{len(reqs)} requests, {len(replies)} replies, exit {p.returncode}")
for i, r in enumerate(reqs):
    rep = replies[i] if i < len(replies) else []
    pos = 0
    for k, t in exp[i]:
        ok = True
        if k == "<":
            j = next((j for j in range(pos, len(rep)) if t in rep[j]), None)
            ok = j is not None; pos = j if ok else pos
        elif k == "<=": ok = bool(rep) and rep[-1] == t
        elif k == "<!": ok = not any(t in x for x in rep)
        if not ok:
            bad += 1; print(f"FAIL request {i+1} `{r[:60]}`: {k} {t!r}\n   reply: {rep[-6:]}")
print("smoke:", "OK" if bad == 0 else f"{bad} expectation(s) failed")
if p.stderr.strip(): print("stderr:", p.stderr.strip()[:500])
