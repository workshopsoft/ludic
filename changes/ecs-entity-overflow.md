bump: patch
type: fix
**The 1,025th entity stops the program instead of corrupting it.** The built-in ECS keeps every
component in a fixed array of 1024 slots, and `L_alloc` never checked: one entity more was written
past the end of every component array at once. A spawn past the store now stops with `more than
1024 entities: the built-in ECS holds 1024; keep many things in a ludic.base Table`. A game that
keeps thousands of something keeps them as rows of `ludic.base`'s `Table<T>`, which grows.
