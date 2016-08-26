Dependencies
============

New Features
============

* Don't search for any `UnitTestRunner.d` file, just use the `UnitTestRunner`
  Ocean's module if Ocean is configured as a submodule.

* `doc` target will now generate documentation using
  [harbored-mod](https://github.com/kiith-sa/harbored-mod)
  tool by default.

* Make `TEST_RUNNER_STRING` overrideable. In case you need to plug-in a custom
  test runner, now you can also override this variable to make it even more
  flexible.
