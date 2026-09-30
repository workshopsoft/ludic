bump: patch
type: fix
**`ludic.character`'s fact pool is presized and capped.** `chr_fact_more` made a new `CharacterFact` whenever every record was held, so a game that did not drain the facts promptly grew the pool for good and the alloc fence reported it unbounded. The pool is now 1024 records made with the state; a fact that finds all of them held is dropped and counted (`char_facts_dropped()`), and nothing is made in play. A regression test runs thousands of frames of jumping with nothing drained under the alloc fence.
