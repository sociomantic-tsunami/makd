New Features
============

* Submodules are now parsed using `git config`, which should be more robust than
  manual parsing.

* `mkpkg`

  - `FUN.autodeps()` now accepts a `path` to prepend to all passed binaries and
    can receive also the files as a single list instead of as multiple arguments.

  - A new function `FUN.mapbins()` was added to ease specifying binaries to
    include in the package.
