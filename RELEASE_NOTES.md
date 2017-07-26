New Features
============

* `VAR.fullname` `VAR.shortname`

  Added new variables, available in package definition files. `VAR.fullname` replaces the old `VAR.name` to make it more explicit, `VAR.shortname` contains only the package name, without the `VAR.suffix`.

* `FUN.desc()`

  A simple function to customize `OPTS['description']`. It can add an optional `type` of package (will append ` (<type>)` to the first line (short description), `prolog` (inserted before the long description) and an `epilog` (appended at the end of the long description.

* `FUN.mapfiles()`

  A simple function to ease specifying files to include in the package (with the ability to control whether `VAR.suffix` is appended to each destination file using the named argument `append_suffix`).

* Now the location of integrationtest is configurable through the ``INTEGRATIONTEST`` Make variable.

* `exec_nc`

  There is a new MakD function to get fancy output but that doesn't force colors on the output of the commands that are being run. This is particularly useful for commands that already have colorized output.

Deprecations
============

* `VAR.name` is deprecated, please use `VAR.fullname` instead.

* `FUN.mapbins()` is deprecated, please use `FUN.mapfiles()` instead.

* The `versionInfo` AA containing all the automatically deduced version
  information is deprecated, please use `version_info` instead.

* The default location for integration tests (now defined by ``$(INTEGRATIONTEST)``, will change from `test` to `integrationtest` (see #74). To avoid warnings you can preempively define the variable explicitly (in which case we recommend to start using the new default location instead of the old one: `INTEGRATIONTEST := integrationtest` in `Config.mak`).

Milestone: https://github.com/sociomantic-tsunami/makd/milestone/20?closed=1
