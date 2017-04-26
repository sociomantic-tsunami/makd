Migration Instructions
======================

* The `Version` and `versionInfo` aliases to `version_info` provided by the
  `Version` module has been removed. All remaining usage can be replaced with
  `version_info`.

* The `D_GC` variable was removed as it wasn't used internally anymore.
  If you made use of it anywhere, you should define it yourself (in `Config.mak`
  for example) from now on.

* The deprecated packaging function `FUN.mapbins()` was removed, use
  `FUN.mapfiles()` instead.

* The deprecated packaging variable `VAR.name` was removed, use `VAR.fullname`
  instead.

* The ``OPTS`` and ``ARGS`` variables used when defining packages have become
  built-ins now, so they should be modified **in-place** (using
  ``OPTS.update()``, ``OPTS['xxx']``, and ``ARGS.extend()``, ``ARGS.append()``
  or any other functions that mutates the object).

  You should **NEVER** re-bind (re-assign) these variables (``OPTS = ...``,
  ``ARGS = ...`` or even ``ARGS += ...`` and any other operators that re-assign
  the variable are forbidden).

  Also, if you are using a ``defaults.py`` file, now just use ``ìmport
  defaults`` in ``.pkg`` files using it, don't explicitly import the ``OPTS``
  and ``ARGS`` symbols anymore:

  Change ``from defaults import OPTS, ARGS`` to ``import defaults``.

  This change helps making much compact utility functions. See changes on
  ``FUN.desc()``.

* The ``FUN.desc()`` function for defining packages now doesn't take ``OPTS`` as
  an argument, it just gets the ``OPTS['description']`` from the built-in
  ``OPTS``.

  Change ``FUN.desc(OPTS, ...)`` to ``FUN.desc(...)``.

* The `integrationtest` target is not compiled using `-unittest -debug=UnitTest
  -version=UnitTest` anymore as it complicates debugging and it wastes resources
  (as not only the unit tests for those programs will be run but also all the
  test for the library code will be run too).

  Unit tests for the integrations tests are still run but now by the `unittest`
  and `fastunittest` targets instead of `integrationtest`.

* `main.d` files in `$(SRC)` will no longer be automatically added to
  `TEST_FILTER_OUT` and it's not recommended to add them back manually either.
   It is recommended to conditionally compile the `main()` function only when
   not unit-testing instead:

   ```d
    version (UnitTest) {} else
    void main()
    {
        // stuff
    }
    ```

    This applies too to the integration tests `main.d` files.

