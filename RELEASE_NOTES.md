New Features
============

* `mkpkg`: `FUN.autodeps()` now accepts multiple arguments. The set of dependencies for all of them are returned.

* A new `graph-deps` target generates a dependencies graph (by default only with cyclic dependencies). To generate the graph the `dot` tool from the [graphviz](http://www.graphviz.org/) visualization software is used.

* Add minimal and experimental support to create Non-Debian packages (in particular Arch Linux).

* [d1to2fix v0.7.0](https://github.com/sociomantic-tsunami/d1to2fix/releases/tag/v0.7.0) new batch conversion is used if available.
