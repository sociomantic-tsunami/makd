* Unit and integration tests changes

  * Starting with v2.0.0 Makd will compile all modules from integration tests as part of the regular unittest target and stop supplying the `-unittest` flag when compiling actual integration tests. This may break compilation of a project so some manual tweaks are required:

    1. If integration test modules don't have module statements or multiple modules have the same name.

       The solution is to add explicit module statements to give each file a distinct module name.

    2. As with modules containing a `main()` in the regular user code in `$(SRC)`, integration test modules containing `main()` functions need to be modified to version out that `main()` function via `version(UnitTest)` (see the notes about changes to test and `main()` in general for more details about this), otherwise the unittest target will fail to link because of multiple `main()`s.

       Again, you could manually add these modules to `TEST_FILTER_OUT`, but it is not recommended as any unit tests present in the module with the `main()` function won't be run this way.

  * Integration tests default location changed from `test` to `integrationtest`

    The location can be set explicitly via the variable `INTEGRATIONTEST`, but you are not required to define it anymore (as it was required in v1.x.x), you just need to define it if you don't want the new default (`integrationtest`). This change was introduced to avoid symbol clashes in D2 (if the root package is named `test` then no symbol named `test` can be used directly, and using the `test()` function in integration tests is very common).
