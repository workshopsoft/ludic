bump: minor
type: feature
**A module's private records and events are its own.** A `property` or `event` a module does not
export no longer collides with the same spelling in another module: each private one is compiled
under its module's name and its module's types, `new`, `emit` and `@On` follow it. Exported ones are
one namespace, and two events of one spelling are now refused (the first used to take the other's
emits silently). Generic records, entity components and component or view records stay global.
