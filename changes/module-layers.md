bump: minor
type: feature
**Layers: `module flow in layer app uses base, items`.** The modules of one layer use each other
freely and may go round; anything outside the layer is still held to the module's `uses` (a
layered module with no `uses` reaches nothing outside its layer), and a cycle is refused unless it
stays inside one layer. `ludic deps` shows the layers and counts the largest cycle without the edges
inside them, printing the count with them beside it.
