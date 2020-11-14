* `FUN.autodeps()`

  This function now uses `dpkg-shlibdeps`, which should fix https://github.com/sociomantic-tsunami/makd/issues/76 and provide more precise results for dependencies. This means now you also need to `apt-get install dpkg-dev` to use `autodeps()`.
