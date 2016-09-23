New Features
============

* `mkpkg`: `FUN.autodeps()` now accepts multiple arguments. The set of
  dependencies for all of them are returned.

* A new `graph-deps` target generates a dependencies graph (by default only with
  cyclic dependencies). To generate the graph the ``dot`` tool from the
  `graphviz <http://www.graphviz.org/>`_ visualization software is used.

