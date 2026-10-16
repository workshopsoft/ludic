#!/usr/bin/env python3
"""sea_budget.py <sea_lab binary> [rounds] - the GPU time of the sea pass (R3D_PROF=1, the lab's `sea_prof` and `sea_prof_deep`
scenes, 1080p), the least over `rounds` runs (default 4: a busy machine only ever adds), against the contract's budget.

The contract (OC-39) says at most 1.0 ms on an M1. This machine is an M4 Pro, which draws these views about 3 times faster
(16 GPU cores against 8, the clock and the memory bandwidth up with them), so the same budget is 1.0 / M1_OVER ms here, and a
view is reported against that. What the script FAILS on is the regression guard: a ceiling on each view, a quarter above what the
pass costs now and well under what it cost before (a pass of 0.74 ms on the horizon, 1.17 ms on the coast, 1.46 ms over the open
sea). Run it with LUDIC_HOME set to the checkout the lab was built in (the lab reads its shaders there).

THE GUARD IS A RATIO, NOT MILLISECONDS. The GPU is shared: with other games and builds running on this machine the same pass reads
2x its idle time (0.45 ms coast idle, 0.70 under load; the old plane 2.2 ms and 4 ms), so a ceiling in milliseconds fails on a busy
machine and passes on a quiet one. The old still-water plane (`sea_prof_old`, the same four views) is run in the same rounds,
interleaved, so the load is the same to both, and the pass FAILS when it costs more than RATIO of the old plane's time in a view.
Idle that ratio is 0.12-0.17 (open sea), 0.14-0.18 (horizon), 0.20-0.27 (coast), 0.27-0.43 (land: the old plane is cheap there
and noisy); the guard is a quarter to a half above it. The
milliseconds are printed for the record and against the scaled contract line, and never fail the script.

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
# the guard: the pass's time over the old plane's time in the same view
RATIO_GUARD = {"prof_open_sea": 0.35, "prof_horizon": 0.35, "prof_coast": 0.40, "prof_land": 0.65}
OLD_OF = {}
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


def best(binary, scenes, rounds):
    """the least over `rounds` of each scene's shots; the scenes run one after another inside a round, so a load that comes and goes
    reaches all of them"""
    out = {s: {} for s in scenes}
    for _ in range(rounds):
        for scene in scenes:
            for shot, ms in run(binary, scene).items():
                out[scene][shot] = min(out[scene].get(shot, 1e9), ms)
    return out


def ratio_failures(new, old, guards=RATIO_GUARD, old_of=OLD_OF):
    """[(shot, ratio, guard)] of the views where `new` (shot -> ms) costs more than the guarded share of `old`'s time"""
    bad = []
    for shot, guard in guards.items():
        n, o = new.get(shot), old.get(old_of.get(shot, shot))
        if n is None or o is None or o <= 0.0:
            bad.append((shot, -1.0, guard))          # a view that did not report is a failure, not a pass
        elif n / o > guard:
            bad.append((shot, n / o, guard))
    return bad


def main():
    binary = os.path.abspath(sys.argv[1])
    rounds = int(sys.argv[2]) if len(sys.argv) > 2 else 4
    here = M1_BUDGET_MS / M1_OVER
    print(f"sea pass, ms on this machine (least of {rounds}); the contract's {M1_BUDGET_MS:.1f} ms on an M1 is {here:.2f} ms here (an ESTIMATE: no M1 was run, M1 taken as {M1_OVER:.0f}x slower)")
    got = best(binary, ("sea_prof", "sea_prof_deep", "sea_prof_old"), rounds)
    old = got["sea_prof_old"]
    for scene in ("sea_prof", "sea_prof_deep"):
        for shot, ms in sorted(got[scene].items()):
            note = "meets the scaled line" if ms <= here else f"over the scaled line by {ms / here - 1.0:.0%} (about {ms * M1_OVER:.2f} ms on an M1, estimated)"
            o = old.get(OLD_OF.get(shot, shot))
            print(f"     {scene} {shot}: {ms:.3f} ms" + (f", {ms / o:.2f} of the old plane's {o:.2f} ms" if o else "") + f"  {note}")
    bad = ratio_failures(got["sea_prof"], old)
    for shot, r, g in bad:
        print(f"FAIL sea_prof {shot}: " + (f"{r:.2f} of the old plane's time, over the guard {g:.2f}" if r >= 0 else "no time reported"))
    print(f"sea_budget: {len(bad)} over the guard")
    return 1 if bad else 0


if __name__ == "__main__":
    sys.exit(main())
