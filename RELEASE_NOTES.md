New Features
============

* `VAR.fullname` `VAR.shortname`

  Added new variables, available in package definition files. `VAR.fullname`
  replaces the old `VAR.name` to make it more explicit, `VAR.shortname` contains
  only the package name, without the `VAR.suffix`.

Deprecations
============

* `VAR.name` is deprecated, please use `VAR.fullname` instead.
