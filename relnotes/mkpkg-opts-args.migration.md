* The `OPTS` and `ARGS` variables used when defining packages have become built-ins now, so they should be modified **in-place** (using `OPTS.update()`, `OPTS['xxx']`, and `ARGS.extend()`, `ARGS.append()` or any other functions that mutates the object).

  You should **NEVER** re-bind (re-assign) these variables (`OPTS = ...`, `ARGS = ...` or even `ARGS += ...` and any other operators that re-assign the variable are forbidden).

  Also, if you are using a `defaults.py` file, now just use `ìmport defaults` in `.pkg` files using it, don't explicitly import the `OPTS` and `ARGS` symbols anymore:

  Change `from defaults import OPTS, ARGS` to `import defaults`.

  This change helps making much compact utility functions. See changes on `FUN.desc()` for an example.
