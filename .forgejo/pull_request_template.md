<!-- Thanks for contributing to Ludic! Please fill in the checklist below. -->

## What & why

<!-- What does this change and why? Link the issue: Closes #NN -->

Closes #

## Checklist

- [ ] `bin/x test` passes.
- [ ] For compiler/runtime changes: `bin/x reseed && bin/x bootstrap-cfree`
      still reaches the self-hosting fixpoint with no C compiler in the loop.
- [ ] `ludic-fmt` leaves the touched files unchanged (2-space, LF, UTF-8).
- [ ] New/changed stdlib symbols are documented under `docs/language/**` and
      registered in `tools/docgen/inventory.json`
      (`bin/x docs-gen && bin/x docs-check build/pages` passes).
- [ ] Commits follow [Conventional Commits](https://www.conventionalcommits.org).
- [ ] No new C / Python / JS in tooling (Ludic only), and no generated
      artifacts committed outside `build/` / `bin/`.

## Notes for reviewers

<!-- Anything reviewers should look at closely, or follow-ups deferred. -->
