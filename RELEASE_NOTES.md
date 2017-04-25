New Features
============

* `make example example-run`

  Added new make targets 'example' and 'example-run'. The make targets will search for an `example/` directory in the root dir of the project. Each `*.d` file found will be compiled and copied into `build/last/bin/example/` directory. If `make example-run` is used, then the programs will be executed as well.

* `VAR.fullname` `VAR.shortname`

  Added new variables, available in package definition files. `VAR.fullname` replaces the old `VAR.name` to make it more explicit, `VAR.shortname` contains only the package name, without the `VAR.suffix`.

* `FUN.desc()`

  A simple function to customize `OPTS['description']`. It can add an optional `type` of package (will append ` (<type>)` to the first line (short description), `prolog` (inserted before the long description) and an `epilog` (appended at the end of the long description.

* `FUN.mapfiles()`

  A simple function to ease specifying files to include in the package (with the ability to control whether `VAR.suffix` is appended to each destination file using the named argument `append_suffix`).

Deprecations
============

* `VAR.name` is deprecated, please use `VAR.fullname` instead.

* `FUN.mapbins()` is deprecated, please use `FUN.mapfiles()` instead.

* The `versionInfo` AA containing all the automatically deduced version
  information is deprecated, please use `version_info` instead.

Milestone: https://github.com/sociomantic-tsunami/makd/milestone/20?closed=1
