* `main.d` files in `$(SRC)` will no longer be automatically added to `TEST_FILTER_OUT` and it's not recommended to add them back manually either. It is recommended to conditionally compile the `main()` function only when not unit-testing instead:

  ```d
  version (UnitTest) {} else
  void main()
  {
      // stuff
  }
  ```

  This applies too to the integration tests `main.d` files.
