Dependencies
============

New Features
============

* If `UnitTestRunner.d` module is neither found not explicitly
  configured by developer, makd will resort to using default D test
  runner instead.

* Now `DVER` variable is set only if it was not already defined,
  allow to put it into `Config.makd` for D2-only projects.
