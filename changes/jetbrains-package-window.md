bump: minor
type: feat
The JetBrains plugin (1.6.0) has a Ludic tool window for the package, like the Gradle one:
- an overview of the package (what it is, entry, version, dependencies, scripts, hooks, app);
- its commands, scripts and hooks, run by double-click, with each command's hooks shown;
- its dependencies against package.lock.ludic: the locked version, whether it is fetched
  and linked, the indirect ones, and Fetch, Update, Verify, Vendor, Add and Remove;
- the app preview the `app` lines describe, and the asset roots with missing ones marked.
The bar over package.ludic now appears only when something needs doing (fetch, or no
toolchain), instead of carrying every command.
