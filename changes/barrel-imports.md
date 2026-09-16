bump: minor
type: feat
`import "camp"` imports a directory through its barrel, `camp/index.ludic` (a fragment
listing the directory's own imports). A directory without one is a clear error. Packages
resolve the same way: `import "ludic.render3d"` reads `ludic.render3d/index.ludic`.
