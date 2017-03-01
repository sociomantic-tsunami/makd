Migration Instructions
======================

* The `Version` alias to `versionInfo` provided by the `Version` module has been removed.
  All remaining usage can be replaced with `versionInfo`.

* The `D_GC` variable was removed as it wasn't used internally anymore.
  If you made use of it anywhere, you should define it yourself (in `Config.mak` for example) from now on.
