bump: patch
type: fix
The GPU allocator's list of spare ids keeps room for every id it has made, and that room grows as new ids are made. A long run on a big
streamed world used to free more than the 4096 ids the list was capped at, and the allocation fence then failed the run.
