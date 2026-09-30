bump: patch
type: fix
The phone home grid draws an app name once.

An app with no icon drew its title inside the tile as well as under it (cut off, "Messages Mes"), and each app laid out as a row instead of a column. Tiles without an icon are now plain and the label sits under the tile.
