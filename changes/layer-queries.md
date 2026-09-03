bump: minor
type: feat
A handler inside a scene `layer` may carry `@Queries(these: […], on: Model)`, so a scene can own its per-entity systems (`@Queries(these: [Particle]) handler AgeSparks phase Update { … }` runs once per matching entity only while that scene is active). Any other annotation on a layer handler is reported.
