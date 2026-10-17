#!/usr/bin/env python3
"""sea_budget_test.py - what sea_budget.py fails on. Two guards:
  the CONTRACT LINE (OC-39 Budget, M-23): 0.33 ms where the sea is at most half the frame and 0.53 ms where it fills the frame or covers
    a foam-filled beach, on an M4 Pro (1.0 and 1.6 ms on an M1), held to the least frame of a view; a pass over its line fails, whatever
    its share of the old plane's time is (the former guard compared shares only and called a pass 44 % over the scaled line a pass).
  the REGRESSION GUARD: a share of the old plane's time in the same session, which does not move with the machine's load.
Run: python3 lab/sea_budget_test.py"""
import os
import sys
import unittest

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import sea_budget as b

OLD = {"prof_open_sea": 3.9, "prof_horizon": 2.0, "prof_coast": 2.2, "prof_land": 0.7}
# what the shipped pass reads (least frame, an M4 Pro under a busy machine's load; the sea's deep-bed coast is the dearest view)
NEW = {"prof_open_sea": 0.45, "prof_horizon": 0.27, "prof_coast": 0.42, "prof_land": 0.15}
DEEP = {"prof_open_sea": 0.44, "prof_horizon": 0.27, "prof_coast": 0.46, "prof_land": 0.13}
FIRST_SEA = {"prof_open_sea": 1.46, "prof_horizon": 0.74, "prof_coast": 1.17, "prof_land": 0.50}
# the pass as the verifier measured it before this change (the mean on a loaded machine): inside the ratio guard, over the contract line
BEFORE = {"prof_open_sea": 0.487, "prof_horizon": 0.289, "prof_coast": 0.601, "prof_land": 0.178}
# a real row of the lab's report: the mean, its share, then the least single frame
REPORT = """prof: shot prof_coast

GPU time per pass (mean over the run; least = the least single frame, which a busy GPU cannot lower):
  resolve MSAA                28 us   0%   least 18 us
  water capture               44 us   1%   least 30 us
  water surface              454 us   11%   least 433 us
  blended actors             205 us   5%   least 1 us
prof: shot prof_land
  water surface              171 us   4%   least 112 us
"""


class Line(unittest.TestCase):
    def test_the_lines_are_the_contracts(self):
        # 1.0 ms and 1.6 ms on an M1, a third of each here (M-23): 0.33 and 0.53
        self.assertAlmostEqual(b.HALF_FRAME_MS, 1.0 / b.M1_OVER, delta=0.005)
        self.assertAlmostEqual(b.FULL_FRAME_MS, 1.6 / b.M1_OVER, delta=0.005)

    def test_each_view_is_held_to_its_line(self):
        self.assertEqual(b.LINE_MS["prof_horizon"], b.HALF_FRAME_MS)       # the sea at most half the frame
        self.assertEqual(b.LINE_MS["prof_land"], b.HALF_FRAME_MS)
        self.assertEqual(b.LINE_MS["prof_open_sea"], b.FULL_FRAME_MS)      # the sea fills the frame
        self.assertEqual(b.LINE_MS["prof_coast"], b.FULL_FRAME_MS)         # a foam-filled beach
        self.assertEqual(set(b.LINE_MS), set(b.RATIO_GUARD))               # no view is left to the ratio alone

    def test_the_shipped_pass_is_inside_on_both_scenes(self):
        self.assertEqual(b.line_failures(NEW), [])
        self.assertEqual(b.line_failures(DEEP), [])

    def test_over_the_line_but_inside_the_ratio_fails(self):
        # the former guard (a share of the old plane) let this through: 0.60 of 2.2 ms is 0.27, under its 0.40
        self.assertEqual(b.ratio_failures(BEFORE, OLD), [])
        self.assertEqual([s for s, _, _ in b.line_failures(BEFORE)], ["prof_coast"])

    def test_the_half_frame_line_is_the_tighter_one(self):
        self.assertEqual([s for s, _, _ in b.line_failures(dict(NEW, prof_horizon=0.34))], ["prof_horizon"])
        self.assertEqual([s for s, _, _ in b.line_failures(dict(NEW, prof_land=0.34))], ["prof_land"])
        self.assertEqual(b.line_failures(dict(NEW, prof_coast=0.34, prof_open_sea=0.34)), [])      # fine on a full-frame view
        self.assertEqual([s for s, _, _ in b.line_failures(dict(NEW, prof_coast=0.54))], ["prof_coast"])
        self.assertEqual([s for s, _, _ in b.line_failures(dict(NEW, prof_open_sea=0.54))], ["prof_open_sea"])

    def test_exactly_on_the_line_is_inside(self):
        self.assertEqual(b.line_failures(dict(NEW, prof_horizon=0.33, prof_coast=0.53)), [])

    def test_the_first_sea_is_over_every_line(self):
        self.assertEqual({s for s, _, _ in b.line_failures(FIRST_SEA)}, set(b.LINE_MS))

    def test_a_view_that_did_not_report_fails(self):
        self.assertEqual([s for s, ms, _ in b.line_failures({k: v for k, v in NEW.items() if k != "prof_coast"})], ["prof_coast"])
        self.assertEqual([ms for _, ms, _ in b.line_failures(dict(NEW, prof_coast=0.0))], [-1.0])
        self.assertEqual({s for s, _, _ in b.line_failures({})}, set(b.LINE_MS))


class Report(unittest.TestCase):
    def test_the_mean_and_the_least_frame_of_each_shot_are_read(self):
        self.assertEqual(b.parse(REPORT), {"prof_coast": (0.454, 0.433), "prof_land": (0.171, 0.112)})

    def test_a_report_without_the_least_frame_reads_nothing_so_every_view_fails(self):
        # a lab built before the profiler printed `least` must not pass for want of numbers
        old = "\n".join(l.split("   least")[0] for l in REPORT.splitlines())
        self.assertEqual(b.parse(old), {})
        self.assertEqual({s for s, _, _ in b.line_failures(b.least_of(b.parse(old)))}, set(b.LINE_MS))

    def test_the_least_is_what_is_held_to_the_line(self):
        got = b.parse(REPORT)
        self.assertGreater(got["prof_coast"][0], got["prof_coast"][1])
        self.assertEqual(b.least_of(got), {"prof_coast": 0.433, "prof_land": 0.112})


class Ratio(unittest.TestCase):
    def test_shipped_pass_is_inside(self):
        self.assertEqual(b.ratio_failures(NEW, OLD), [])

    def test_a_busy_machine_scales_both_and_changes_nothing(self):
        for load in (1.5, 2.0, 3.0):
            self.assertEqual(b.ratio_failures({k: v * load for k, v in NEW.items()}, {k: v * load for k, v in OLD.items()}), [], load)

    def test_the_first_sea_is_caught(self):
        shots = {s for s, _, _ in b.ratio_failures(FIRST_SEA, OLD)}
        self.assertEqual(shots, {"prof_open_sea", "prof_horizon", "prof_coast", "prof_land"})

    def test_a_view_that_did_not_report_fails(self):
        self.assertEqual([s for s, r, _ in b.ratio_failures({k: v for k, v in NEW.items() if k != "prof_land"}, OLD)], ["prof_land"])
        self.assertEqual([s for s, r, _ in b.ratio_failures(NEW, {k: v for k, v in OLD.items() if k != "prof_coast"})], ["prof_coast"])


if __name__ == "__main__":
    unittest.main()
