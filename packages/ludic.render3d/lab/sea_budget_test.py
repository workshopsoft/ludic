#!/usr/bin/env python3
"""sea_budget_test.py - the budget guard of sea_budget.py is a ratio to the old plane's time in the same session, so it does not
move with the machine's load (a ceiling in milliseconds failed an unchanged shader whenever other jobs shared the GPU) and still
fails a regression. Run: python3 lab/sea_budget_test.py"""
import os
import sys
import unittest

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import sea_budget as b

OLD = {"prof_open_sea": 3.9, "prof_horizon": 2.0, "prof_coast": 2.2, "prof_land": 0.7}
NEW = {"prof_open_sea": 0.47, "prof_horizon": 0.27, "prof_coast": 0.45, "prof_land": 0.19}
FIRST_SEA = {"prof_open_sea": 1.46, "prof_horizon": 0.74, "prof_coast": 1.17, "prof_land": 0.50}


class Guard(unittest.TestCase):
    def test_shipped_pass_is_inside(self):
        self.assertEqual(b.ratio_failures(NEW, OLD), [])

    def test_a_busy_machine_scales_both_and_changes_nothing(self):
        for load in (1.5, 2.0, 3.0):
            self.assertEqual(b.ratio_failures({k: v * load for k, v in NEW.items()}, {k: v * load for k, v in OLD.items()}), [], load)

    def test_the_first_sea_is_caught(self):
        shots = {s for s, _, _ in b.ratio_failures(FIRST_SEA, OLD)}
        self.assertEqual(shots, {"prof_open_sea", "prof_horizon", "prof_coast", "prof_land"})

    def test_a_fixed_millisecond_ceiling_would_have_failed_this(self):
        # the former guard: 0.60 ms on the coast. The same pass at the 1.6x a busy machine gives is over it, and inside the ratio
        busy_new = {k: v * 1.6 for k, v in NEW.items()}
        self.assertGreater(busy_new["prof_coast"], 0.60)
        self.assertEqual(b.ratio_failures(busy_new, {k: v * 1.6 for k, v in OLD.items()}), [])

    def test_a_view_that_did_not_report_fails(self):
        self.assertEqual([s for s, r, _ in b.ratio_failures({k: v for k, v in NEW.items() if k != "prof_land"}, OLD)], ["prof_land"])
        self.assertEqual([s for s, r, _ in b.ratio_failures(NEW, {k: v for k, v in OLD.items() if k != "prof_coast"})], ["prof_coast"])


if __name__ == "__main__":
    unittest.main()
