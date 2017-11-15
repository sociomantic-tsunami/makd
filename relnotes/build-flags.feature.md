## Compiler flags and *flavour* (`$F`) is now part of `version_info`

`Version`, `mkversion.sh`

Now the generated version module will include the build flags and *flavour* (`$F`) used to compile the project. The new keys are named `dflags` and `flavour` respectively.
