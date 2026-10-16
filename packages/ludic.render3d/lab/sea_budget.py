#!/usr/bin/env python3
"""sea_budget.py <sea_lab binary> [rounds] - the GPU time of the sea pass (R3D_PROF=1, the lab's `sea_prof` and `sea_prof_deep`
scenes, 1080p) against the contract's budget, and the exit code is the verdict: 0 inside, 1 over.

THE CONTRACT LINE (OC-39 'Budget', amended 2026-10-16 as M-23): the sea pass at most 1.0 ms GPU at 1080p on an M1 in a view where the
sea is at most half the frame, and at most 1.6 ms where it fills the frame or covers a foam-filled beach; measured on an M4 Pro at a
third of those, 0.33 ms and 0.53 ms, until a run on an M1 replaces the factor of 3 (the factor is an ESTIMATE: no M1 was run). This
script FAILS when a view's pass costs more than its line, on either scene: `sea_prof` (the sea over a bed 8 m down) and
`sea_prof_deep` (the same lab with the sea 3 m up, the bed 11 m down and a deeper sea under the foam).

Views (lab/sea_lab.ludic) and the line each is held to:
  prof_horizon  5 m up looking level: half the frame is sea                          0.33 ms
  prof_land     the beach turned to the land (the plane lies under all of it)         0.33 ms
  prof_open_sea 6 m up looking 35 degrees down: the sea fills the frame               0.53 ms
  prof_coast    the beach at 0.5 m up: sea, foam band and wet sand                    0.53 ms

WHAT IS MEASURED. The GPU is shared (other games and builds run on this machine: the same pass has read twice its idle time), and a
busy GPU only ever ADDS to a pass, so the figure held to the line is the LEAST single frame over the run of a view (the profiler
prints it as `least`; prof.ludic), and then the least over `rounds` runs. The mean is printed beside it for the record and is never
held to anything. A line that is still crossed by the least frame of every run is crossed.

The second guard is a regression guard and stays: the pass must cost no more than a share of the old still-water plane's time in the
same view (the old plane, `sea_prof_old`, runs interleaved in the same rounds, so the load is the same to both). It catches a pass
that grew while the line still holds. Run it with LUDIC_HOME set to the checkout the lab was built in (the lab reads its shaders there).
"""
import os
import re
import subprocess
import sys

M1_OVER = 3.0                                   # an ESTIMATE (8 GPU cores against 16, bandwidth 68 against 273 GB/s); no M1 was run
# the contract's lines on an M4 Pro, ms (docs/tech/mvp-contracts.md, OC-39 Budget; M-23)
HALF_FRAME_MS = 0.33                            # 1.0 ms on an M1: the sea at most half the frame
FULL_FRAME_MS = 0.53                            # 1.6 ms on an M1: the sea fills the frame, or a foam-filled beach
LINE_MS = {"prof_horizon": HALF_FRAME_MS, "prof_land": HALF_FRAME_MS, "prof_open_sea": FULL_FRAME_MS, "prof_coast": FULL_FRAME_MS}
# the regression guard: the pass's time over the old plane's time in the same view
RATIO_GUARD = {"prof_open_sea": 0.35, "prof_horizon": 0.35, "prof_coast": 0.40, "prof_land": 0.65}
OLD_OF = {}
SCENES = ("sea_prof", "sea_prof_deep")
LAB_STDIN = b"\n" * 4000


def parse(out):
    """{shot: (mean ms, least ms)} from the lab's output: the `prof: shot X` line and then the `water surface` row of the report"""
    got = {}
    shot = None
    for line in out.splitlines():
        m = re.match(r"prof: shot (\w+)", line)
        if m:
            shot = m.group(1)
        m = re.match(r"\s*water surface\s+(\d+) us\s+\d+%\s+least\s+(\d+) us", line)
        if m and shot:
            got[shot] = (int(m.group(1)) / 1000.0, int(m.group(2)) / 1000.0)
    return got


def run(binary, scene):
    env = dict(os.environ, R3D_SCENE=scene, R3D_PROF="1")
    out = subprocess.run([binary], input=LAB_STDIN, env=env, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, cwd=os.getcwd()).stdout.decode("utf-8", "replace")
    return parse(out)


def best(binary, scenes, rounds):
    """{scene: {shot: (least mean, least frame)}} over `rounds`; the scenes run one after another inside a round, so a load that comes
    and goes reaches all of them"""
    out = {s: {} for s in scenes}
    for _ in range(rounds):
        for scene in scenes:
            for shot, (mean, least) in run(binary, scene).items():
                m0, l0 = out[scene].get(shot, (1e9, 1e9))
                out[scene][shot] = (min(m0, mean), min(l0, least))
    return out


def least_of(measured):
    return {shot: v[1] for shot, v in measured.items()}


def line_failures(new, lines=LINE_MS):
    """[(shot, ms, line)] of the views whose pass (shot -> least ms) is over its contract line, or did not report"""
    bad = []
    for shot, line in lines.items():
        ms = new.get(shot)
        if ms is None or ms <= 0.0:
            bad.append((shot, -1.0, line))           # a view that did not report is a failure, not a pass
        elif ms > line:
            bad.append((shot, ms, line))
    return bad


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
    rounds = int(sys.argv[2]) if len(sys.argv) > 2 else 3
    print(f"sea pass, ms on this machine, the least frame of the least of {rounds} runs; lines {HALF_FRAME_MS:.2f} (sea at most half the frame) and {FULL_FRAME_MS:.2f} "
          f"(sea fills the frame, or a foam beach) = 1.0 and 1.6 ms on an M1 (ESTIMATE: no M1 was run, M1 taken as {M1_OVER:.0f}x slower)")
    got = best(binary, SCENES + ("sea_prof_old",), rounds)
    old = least_of(got["sea_prof_old"])
    bad = 0
    for scene in SCENES:
        new = least_of(got[scene])
        for shot in sorted(LINE_MS):
            mean, ms = got[scene].get(shot, (0.0, 0.0))
            o = old.get(OLD_OF.get(shot, shot))
            note = f"inside the {LINE_MS[shot]:.2f} line (about {ms * M1_OVER:.2f} ms on an M1, estimated)"
            if ms > LINE_MS[shot] or ms <= 0.0:
                note = f"OVER the {LINE_MS[shot]:.2f} line by {ms / LINE_MS[shot] - 1.0:.0%}"
            print(f"     {scene} {shot}: least {ms:.3f} ms (mean {mean:.3f})" + (f", {ms / o:.2f} of the old plane's {o:.2f}" if o else "") + f"  {note}")
        for shot, ms, line in line_failures(new):
            print(f"FAIL {scene} {shot}: " + (f"{ms:.3f} ms, over the contract line {line:.2f} ms" if ms >= 0 else "no time reported"))
            bad += 1
        for shot, r, g in ratio_failures(new, old):
            print(f"FAIL {scene} {shot}: " + (f"{r:.2f} of the old plane's time, over the guard {g:.2f}" if r >= 0 else "no time reported"))
            bad += 1
    print(f"sea_budget: {bad} over")
    return 1 if bad else 0


if __name__ == "__main__":
    sys.exit(main())
