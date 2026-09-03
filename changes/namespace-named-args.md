bump: patch
type: fix
Named arguments now work on namespace functions (`@Namespace(Foo)` and `namespace Foo { export function … }`), not only on builtins and bare functions: `Weapon.def(name: "pistol", fire_rate: 9, damage: 14, speed: 8, spread: 0, pellets: 1, pattern: 0)` reorders to the declared parameter order like any other call. Previously every named call on a namespace function failed with "wrong number of arguments".
