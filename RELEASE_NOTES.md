New Features
============

* `VAR.fullname` `VAR.shortname`

  Added new variables, available in package definition files. `VAR.fullname`
  replaces the old `VAR.name` to make it more explicit, `VAR.shortname` contains
  only the package name, without the `VAR.suffix`.

* `FUN.desc()`

  A simple function to customize `OPTS['description']`. It can add an optional
  `type` of package (will append ` (<type>)` to the first line (short
  description), `prolog` (inserted before the long description) and an `epilog`
  (appended at the end of the long description.


Deprecations
============

* `VAR.name` is deprecated, please use `VAR.fullname` instead.
