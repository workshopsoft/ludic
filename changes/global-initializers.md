bump: minor
type: feat
A program-scope `var` may be initialized with any expression: `var run: Progress = new Progress`, `var speed: int = BASE_SPEED * 2`, `var origin: IVec2 = IVec2.zero()`. Initializers the compiler cannot fold run once at startup (`@L_init_globals`, after the runtime boots and before the `Start` phase), in declaration order. Previously such an initializer was silently replaced by `0` / `null`.
