Dependencies
============

Migration Instructions
======================

Bug Fixes
=========

New Features
============

* ``Makd.mak``

  If ``UnitTestRunner.d`` module is neither found not explicitly
  configured by developer, makd will resort to using default D test
  runner instead.

* ``Makd.mak``

  Now `DVER` variable is set only if it was not already defined,
  allow to put it into `Config.makd` for D2-only projects.
