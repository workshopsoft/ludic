#!/usr/bin/env python3
"""sea_budget.py <sea_lab binary> [rounds] - the GPU time of the sea pass (R3D_PROF=1, the lab's `sea_prof` and `sea_prof_deep`
scenes, 1080p), the least over `rounds` runs (default 4: a busy machine only ever adds), against the contract's budget.

The contract (OC-39) says at most 1.0 ms on an M1. This machine is an M4 Pro, which draws these views about 3 times faster
(16 GPU cores against 8, the clock and the memory bandwidth up with them), so the same budget is 1.0 / M1_OVER ms here, and a
view is reported against that. What the script FAILS on is the regression guard: a ceiling on each view, a quarter above what the
pass costs now and well under what it cost before (a pass of 0.74 ms on the horizon, 1.17 ms on the coast, 1.46 ms over the open
sea). Run it with LUDIC_HOME set to the checkout the lab was built in (the lab reads its shaders there).

Views (lab/sea_lab.ludic): open_sea 6 m up looking 35 degrees down (the sea fills the frame over a bed 8 m down), horizon 5 m up looking
level, coast the beach at 0.5 m up, land the same beach turned to the land (the plane lies under all of it). `sea_prof_deep` is the
same over a bed 11 m down: the sea deeper than the light reaches.
"""
import os
import re
import subprocess
import sys

M1_OVER = 3.0
M1_BUDGET_MS = 1.0
GUARD_MS = {"prof_open_sea": 0.60, "prof_horizon": 0.40, "prof_coast": 0.60, "prof_land": 0.30}
LAB_STDIN = b"\n" * 4000


def run(binary, scene):
    env = dict(os.environ, R3D_SCENE=scene, R3D_PROF="1")
    out = subprocess.run([binary], input=LAB_STDIN, env=env, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, cwd=os.getcwd()).stdout.decode("utf-8", "replace")
    got = {}
    shot = None
    for line in out.splitlines():
        m = re.match(r"prof: shot (\w+)", line)
        if m:
            shot = m.group(1)
        m = re.match(r"\s*water surface\s+(\d+) us", line)
        if m and shot:
            got[shot] = int(m.group(1)) / 1000.0
    return got


def best(binary, scene, rounds):
    out = {}
    for _ in range(rounds):
        for shot, ms in run(binary, scene).items():
            out[shot] = min(out.get(shot, 1e9), ms)
    return out


def main():
    binary = os.path.abspath(sys.argv[1])
    rounds = int(sys.argv[2]) if len(sys.argv) > 2 else 4
    here = M1_BUDGET_MS / M1_OVER
    failed = 0
    print(f"sea pass, ms on this machine (least of {rounds}); the contract's {M1_BUDGET_MS:.1f} ms on an M1 is {here:.2f} ms here (M1 about {M1_OVER:.0f}x slower)")
    for scene in ("sea_prof", "sea_prof_deep"):
        for shot, ms in sorted(best(binary, scene, rounds).items()):
            guard = GUARD_MS.get(shot)
            note = "meets the scaled budget" if ms <= here else f"over the scaled budget by {ms / here - 1.0:.0%} (about {ms * M1_OVER:.2f} ms on an M1)"
            bad = guard is not None and scene == "sea_prof" and ms > guard
            if bad:
                failed += 1
            print(("FAIL " if bad else "ok   ") + f"{scene} {shot}: {ms:.3f} ms" + (f" (guard {guard:.2f})" if guard and scene == "sea_prof" else "") + f"  {note}")
    print(f"sea_budget: {failed} over the guard")
    return 1 if failed else 0


if __name__ == "__main__":
    sys.exit(main())
